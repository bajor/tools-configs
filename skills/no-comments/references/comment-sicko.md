# Scoped comment review

Adapted from pstack's Comment Sicko prompt. Return findings only; do not edit
application code, comments, checker policy or approval records.

1. Inspect the supplied scope and nearby source/contracts. Identify actual comment
   syntax with the repository's parser-aware checker; distinguish strings, URLs,
   regular expressions and language syntax. Report parse failures as blocked.
2. Flag all first-party inline, block, documentation, TODO/FIXME, commented-out
   code and linter/type suppression comments. Name the file, span and rule.
   A claimed constraint alone cannot authorize a passing exception.
3. Preserve third-party legal protections. Identify required legal notices or
   unavoidable tool directives only through existing human-approved external
   exception records with exact scope/bytes, reason and review/expiry date.
   Missing records block the affected file; never delete semantic directives or
   notices while their approval/licensing is unresolved.
4. For a non-obvious constraint, inspect source, contracts and current primary
   documentation. Report whether it can be expressed through names, explicit
   state ownership, pure functions, types, tests or a deterministic gate. Preserve
   valid requirements in Markdown before deletion. Mark uncertain claims for
   review without calling them verified or allowing a passing result.
5. Report prohibited comments, protected notices/directives with their approval
   records, suggested in-scope prevention, blocked claims and skipped files.
   Suggest a behavior change only when source evidence supports it; do not widen
   the task or claim the deterministic checker passed unless it was executed.
