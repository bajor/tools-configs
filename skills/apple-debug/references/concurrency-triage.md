# Adapted Swift concurrency triage

Derived from Dimillian's Swift Concurrency Expert and Approachable Concurrency
guide. Inspect pinned compiler documentation before relying on versioned behavior.

1. Capture the exact compiler/runtime diagnostic, feature owner and affected
   callers. Record Swift compiler/language mode, strict checking, default actor
   isolation and relevant opt-in feature flags from effective build settings.
   Compiler version alone does not establish enabled concurrency semantics.
2. Identify state owners and actor/task boundaries. Keep domain transformations
   pure over immutable values; keep storage, UI, clocks, randomness and I/O in
   explicit effect owners. Inspect cancellation, retries and stale async results.
3. For UI-bound state, use the correct existing UI isolation boundary. For actor
   crossing values, establish actual `Sendable` safety. Prefer isolated protocol
   conformances where supported instead of weakening isolation to satisfy a call.
4. Avoid introducing global/shared mutable state. Protect necessary mutable state
   in its declared owner. Do not treat main-actor-by-default as evidence that
   expensive work is off the main actor or that hidden state is acceptable.
5. Where configured Swift supports it, explicitly concurrent async work can leave
   the caller's actor. Check semantics against actual flags and SDK constraints.
   `Task.detached` loses inherited context and is not a general compiler-error fix;
   preserve structured lifetime/cancellation unless a reviewed requirement differs.
6. Rebuild with unchanged required checking, run affected behavior/property tests,
   reproduce race/cancellation scenarios and run applicable sanitizer checks.
   Reject blanket `@MainActor`, unproven `@unchecked Sendable` or ignored warnings
   as substitutes for state ownership. Repeat performance scenarios when a repair
   changes the executor used for CPU-intensive/model work.

Record the isolation diagnosis, before/after source revisions, executed checks,
runtime evidence and remaining assumptions. A clean compiler alone cannot prove
correct ordering, cancellation, idempotency or responsiveness.
