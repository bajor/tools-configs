---
name: no-comments
description: "Review scoped source comments, preserve required legal notices, and remove prohibited comments using the repository's deterministic checker."
disable-model-invocation: true
---

# No comments

## Adoption and authority

Source, changes and verification limits are in [provenance.json](provenance.json);
retain the upstream [LICENSE](LICENSE). Invoke for an authorized request or
approved automation. The retained upstream `disable-model-invocation` field is
not a demonstrated cross-harness control. Follow repository authorization and
policy; this skill grants no commit, publication, installation or settings access.
Report missing prerequisites as `blocked`; never claim unexecuted checks passed.
Consumer rules determine colocation, functional purity and comment policy.

Use the caller's approved files or diff. Otherwise inspect the current diff
against the repository's base branch, including the working tree. This workflow
adapts pstack's Comment Sicko review; the deterministic checker remains mandatory.

## Steps

1. Locate and run the repository's approved syntax-aware comment checker before
   editing. Confirm the consumer has adopted a no-comments policy. If policy or
   a checker is absent, or a selected language is unsupported, stop before any
   deletion and report blocked. Do not invent a command or change policy.
2. Give [the adapted review prompt](references/comment-sicko.md) and the scope to
   a read-only reviewer when delegation is supported and authorized. Otherwise
   perform a fresh serial pass and disclose that independent review was unavailable.
   No named pstack subagent, poteto-mode, how, why or architect skill is required
   or assumed installed; inspect source, contracts and primary documentation
   directly when their analysis would have been needed.
3. Reject scope escapes, application edits by the reviewer, deletion of required
   legal notices and unsupported behavioral claims. Inline, block, documentation,
   TODO/FIXME, commented-out code and lint/type suppression comments are prohibited
   by an adopted absolute policy. Python AST docstrings are included when that
   policy requires it; arbitrary strings and URLs are not comments.
4. Before removing a comment that describes a constraint, preserve its valid
   requirement in the authoritative Markdown/contract and identify enforceable
   architecture, type, property-test or CI protection. Prefer explicit immutable
   state and pure functions over hidden effects. Make behavior changes only within
   approved scope; otherwise report the necessary fix. Never remove a suppression
   and hide the resulting compiler or linter failure.
5. Remove accepted prohibited comments in scope. Preserve required legal notices
   and behavior-bearing directives such as go:embed, build tags and shebangs.
   If their required protected exception record is absent, leave the affected
   file untouched and report blocked until approved; never delete a directive
   or notice to pass. Third-party protections remain. Do not invent approvals,
   weaken the checker or add suppressions.
6. Rerun the deterministic checker and affected behavior/property tests. For a new
   prevention gate, demonstrate it rejects a representative violating fixture;
   use targeted mutation evidence when behavior changes. Report executed commands,
   source revision, deletion count, preserved legal/tool exceptions, failures and
   remaining work. A review alone cannot establish CI enforcement or completion.

Completion requires the approved checker and relevant checks to pass with retained
evidence; missing capabilities remain blocked. Prepare a reviewable diff and follow
existing confirmation rules before committing or publication.
