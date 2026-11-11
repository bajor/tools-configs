---
name: apple-debug
description: Reproduce and diagnose Apple application crashes, hangs, UI failures and concurrency defects using official Xcode capabilities, native logs, LLDB and focused regression verification.
license: MIT; see LICENSE
compatibility: Approved macOS/Xcode target environment; device debugging requires supported pairing, permissions and signing.
---

# Apple debugging

Inputs: revision, owning feature/scenario, expected behavior, reproducible failure,
approved target/destination, fixtures and a run-owned evidence directory.
Native execution remains unverified on Linux. Read the adapted
[debugging workflow](references/debugging-workflow.md); read the
[concurrency triage](references/concurrency-triage.md) for isolation/race failures.

1. Record the failure before editing. Use `apple-build-verify` for toolchain,
   build/test evidence and actual official MCP capability discovery. Identify
   the precise process, scheme, bundle ID and destination; never select by name alone.
2. Discover simulators with `xcrun simctl list devices --json`. Select an isolated
   approved booted device. A created run-owned simulator must be booted and
   reach readiness with help-confirmed `simctl boot`/`bootstatus` operations before
   installation. Existing personal simulator state must not be repurposed.
   After checking installed help, install/launch the source-identified artifact:

```sh
xcrun simctl install "$APPLE_UDID" "$APPLE_APP_BUNDLE"
xcrun simctl launch "$APPLE_UDID" "$APPLE_BUNDLE_ID"
xcrun simctl io "$APPLE_UDID" screenshot "$APPLE_SCREENSHOT"
```

3. Prefer advertised official MCP inspection/run/UI/debug operations within the
   authorized task. Use the harness's normal reviewed edit workflow for repairs;
   an MCP connection grants no additional editing permission. Otherwise use
   official CLI capabilities or the feature's XCUITest scenario.
   Capture scoped OSLog/process output and native crash diagnostics. Use LLDB or
   `xcdebug` only with available supported debug access and inspected help;
   capture symbolicated stacks for hangs/crashes, with source-matched symbols.
4. Trace UI state, request cancellation and actor/effect ownership to a concrete
   cause. Use Instruments for hangs/allocations and supported sanitizer runs for
   memory/race defects. Do not replace immutable domain logic with hidden shared
   state, blanket `@MainActor`, or unproven `@unchecked Sendable` to remove errors.
5. Apply a focused repair; rerun the exact failing scenario and affected tests,
   including consumer-required checks from the local verification skill.
   Keep failure-before and repair-after evidence at their actual source identities,
   including dirty patch/untracked digests as described in apple-build-verify.
6. Stop log/debug sessions, shut down/delete only simulators created for this run,
   and restore only its fixture state. Retain resource IDs in cleanup records. Redact
   private content from retained artifacts; never erase unrelated devices or logs.

Acceptance: a concrete diagnosis and observed repair are supported by reproducible
commands, logs/stacks and regression results. Unsupported access is a blocker,
not a claimed diagnosis. [Provenance and hashes](provenance.json).
