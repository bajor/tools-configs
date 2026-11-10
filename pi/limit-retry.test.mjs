import assert from "node:assert/strict";
import test from "node:test";
import limitRetry, { isTemporaryLimit, retryDelay } from "./limit-retry.ts";

function harness() {
  const handlers = new Map();
  let terminalInput;
  limitRetry({ on: (name, handler) => handlers.set(name, handler) });
  const context = {
    mode: "tui",
    hasPendingMessages: () => false,
    ui: {
      setStatus() {},
      onTerminalInput: (handler) => { terminalInput = handler; return () => {}; },
    },
  };
  const event = {
    outcome: "error",
    entries: [],
    continue: false,
    context: { contextEntries: [{
      sourceEntry: { id: "failed-response" },
      messages: [{ role: "assistant", stopReason: "error", errorMessage: "You've hit your usage limit" }],
    }] },
  };
  const emit = (name, value = event) => handlers.get(name)?.(value, context);
  emit("session_start", {});
  return { emit, event, context, key: (data) => terminalInput(data) };
}

test("only temporary usage limits qualify for automatic retry", () => {
  for (const error of ["429 rate_limit_error", "usage_limit_reached", "You've hit your limit", "GoUsageLimitError", "Daily quota exceeded"]) {
    assert.equal(isTemporaryLimit(error), true, error);
  }
  for (const error of ["429 insufficient_quota", "429 out of credits", "401 invalid API key", "402 payment required", "HTTP 403 rate limit", "status code: 401 usage limit", "429 account suspended", "subscription_sharing_workplace_individual_usage_limit_exceeded", "unknown failure", "You've hit your context window limit", "429 model_not_found"]) {
    assert.equal(isTemporaryLimit(error), false, error);
  }
});

test("Codex reset durations are not mistaken for HTTP error statuses", () => {
  for (const minutes of [400, 401, 402, 403, 404]) {
    assert.equal(isTemporaryLimit(`You have hit your ChatGPT usage limit. Try again in ~${minutes} min.`), true);
  }
});

test("ambiguous provider-normalized Codex quota errors stop", () => {
  // Pi 1.5.0 emits these same messages for insufficient_quota and workspace limits.
  for (const error of ["You have hit your ChatGPT usage limit.", "You have hit your ChatGPT usage limit (plus plan)."]) {
    assert.equal(isTemporaryLimit(error), false);
  }
});

test("backoff grows to an hourly cap without an attempt cutoff", () => {
  assert.deepEqual([1, 2, 3, 7, 8, 1024].map((attempt) => retryDelay({ attempt, error: "429" })),
    [60_000, 120_000, 240_000, 3_600_000, 3_600_000, 3_600_000]);
});

test("an explicit provider wait longer than the cap takes precedence", () => {
  assert.equal(retryDelay({ attempt: 1, error: "Try again in 2 hours" }), 7_200_000);
  assert.equal(retryDelay({ attempt: 1, error: "You have hit your ChatGPT usage limit. Try again in ~120 min." }), 7_200_000);
});

test("a temporary limit resumes unchanged context after the backoff", async (t) => {
  t.mock.timers.enable({ apis: ["setTimeout"] });
  const { emit, event } = harness();
  const earlierDraft = { type: "custom", customType: "another-extension", data: {} };
  event.entries.push(earlierDraft);
  const result = emit("agent_before_settle");
  t.mock.timers.tick(60_000);
  assert.deepEqual(await result, {
    entries: [earlierDraft, { type: "context_edit", targetId: "failed-response", replacement: null }],
    continue: true,
  });
});

test("successful progress resets the retry delay", async (t) => {
  t.mock.timers.enable({ apis: ["setTimeout"] });
  const { emit } = harness();
  const first = emit("agent_before_settle");
  t.mock.timers.tick(60_000);
  await first;
  emit("turn_end", { message: { role: "assistant", stopReason: "toolUse" } });
  const next = emit("agent_before_settle");
  t.mock.timers.tick(60_000);
  assert.equal((await next).continue, true);
});

test("interruption prevents the pending retry", async (t) => {
  for (const interruption of ["escape", "kitty-escape", "input", "model_select", "session_shutdown"]) {
    await t.test(interruption, async (t) => {
      t.mock.timers.enable({ apis: ["setTimeout"] });
      const { emit, key } = harness();
      const result = emit("agent_before_settle");
      if (interruption === "escape") key("\x1b");
      else if (interruption === "kitty-escape") key("\x1b[27u");
      else emit(interruption, {});
      assert.equal(await result, undefined);
    });
  }
});

test("settlement does not retry terminal or already superseded work", async () => {
  for (const scenario of ["permanent", "aborted", "successful", "queued", "another-extension"]) {
    const { emit, event, context } = harness();
    if (scenario === "permanent") event.context.contextEntries[0].messages[0].errorMessage = "429 insufficient_quota";
    if (scenario === "aborted") event.outcome = "aborted";
    if (scenario === "successful") event.context.contextEntries[0].messages[0].stopReason = "stop";
    if (scenario === "queued") context.hasPendingMessages = () => true;
    if (scenario === "another-extension") event.continue = true;
    assert.equal(await emit("agent_before_settle"), undefined, scenario);
  }
});
