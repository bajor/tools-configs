import timers from "node:timers/promises";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const BASE_DELAY_MS = 60_000;
const MAX_DELAY_MS = 3_600_000;
const STATUS_KEY = "limit-retry";
const PERMANENT_ERROR = new RegExp([
  "\\b(?:401|402|403)\\b",
  "invalid.{0,20}(?:key|auth)|authentication_error|permission_denied",
  "insufficient_quota|out of (?:budget|credits)|insufficient (?:balance|credits)",
  "payment required|billing.{0,20}(?:error|limit)|account.{0,20}(?:suspended|disabled)",
  "context[_\\s-]*(?:length|window|overflow)|maximum.{0,20}tokens",
  "model_not_found|model.{0,20}(?:not found|does not exist)",
  "subscription_sharing_workplace_individual_usage_limit_exceeded",
].join("|"), "i");
const TEMPORARY_LIMIT = /\b429\b|rate[\s_-]*limit|too many requests|usage[\s_-]*limit|(?:free|go)usagelimiterror|(?:you've|you’ve|you have).{0,20}(?:hit|reached).{0,20}limit|(?:hour|day|daily|week|month).{0,30}quota/i;

export function isTemporaryLimit(error: string): boolean {
  return !PERMANENT_ERROR.test(error) && TEMPORARY_LIMIT.test(error);
}

export function retryDelay({ attempt, error }: { attempt: number; error: string }): number {
  const backoff = Math.min(MAX_DELAY_MS, BASE_DELAY_MS * 2 ** Math.min(attempt - 1, 6));
  const hint = /(?:retry after|try again in)\s*:?\s*~?(\d+(?:\.\d+)?)\s*(seconds?|secs?|s|minutes?|mins?|m|hours?|hrs?|h)\b/i.exec(error);
  if (!hint) return backoff;
  const unitMs = /^h/i.test(hint[2]) ? 3_600_000 : /^m/i.test(hint[2]) ? 60_000 : 1_000;
  return Math.max(backoff, Number(hint[1]) * unitMs);
}

export default function limitRetry(pi: ExtensionAPI) {
  let attempt = 0;
  let pending: AbortController | undefined;
  let unsubscribe: (() => void) | undefined;

  const cancel = () => {
    pending?.abort();
    attempt = 0;
  };

  pi.on("session_start", (_event, ctx) => {
    cancel();
    unsubscribe?.();
    if (ctx.mode !== "tui") return;
    unsubscribe = ctx.ui.onTerminalInput((data) => {
      // Escape in legacy terminals and CSI-u/Kitty keyboards. Do not consume it:
      // Pi must also interrupt its run and clear queued messages.
      if (/^\x1b(?:\[27(?:;1)?u)?$/.test(data)) cancel();
      return undefined;
    });
  });
  pi.on("session_shutdown", () => { cancel(); unsubscribe?.(); });
  pi.on("input", () => { cancel(); });
  pi.on("model_select", () => { cancel(); });
  pi.on("turn_end", (event) => {
    if (event.message.role === "assistant" && event.message.stopReason !== "error") cancel();
  });

  pi.on("agent_before_settle", async (event, ctx) => {
    const entry = event.context.contextEntries.findLast((item) => item.messages.length > 0);
    if (!entry) return;
    const message = entry.messages.at(-1);
    if (event.outcome === "aborted" || event.continue || ctx.hasPendingMessages()) return;
    if (message?.role !== "assistant" || message.stopReason !== "error") return;
    if (!isTemporaryLimit(message.errorMessage ?? "")) { cancel(); return; }

    const controller = new AbortController();
    pending = controller;
    const delayMs = retryDelay({ attempt: ++attempt, error: message.errorMessage ?? "" });
    const signal = ctx.signal ? AbortSignal.any([controller.signal, ctx.signal]) : controller.signal;
    ctx.ui.setStatus(STATUS_KEY, `Limit retry #${attempt} at ${new Date(Date.now() + delayMs).toLocaleTimeString()}. Esc cancels.`);
    try {
      // Node timers overflow above ~25 days. Chunk long provider hints instead
      // of accidentally turning a long reset window into a 1 ms retry loop.
      let remaining = delayMs;
      const MAX_TIMER_MS = 2_147_483_647;
      while (remaining > 0) {
        await timers.setTimeout(Math.min(remaining, MAX_TIMER_MS), undefined, { signal });
        remaining -= Math.min(remaining, MAX_TIMER_MS);
      }
      if (signal.aborted || ctx.hasPendingMessages()) return;
      return {
        entries: [...event.entries, {
          type: "context_edit" as const,
          targetId: entry.sourceEntry.id,
          replacement: null,
        }],
        continue: true,
      };
    } catch (error) {
      if (!signal.aborted) throw error;
    } finally {
      pending = undefined;
      ctx.ui.setStatus(STATUS_KEY, undefined);
    }
  });
}
