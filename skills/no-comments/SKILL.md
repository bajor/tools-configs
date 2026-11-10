---
name: no-comments
description: "Review scoped source comments, preserve required legal notices, and remove prohibited comments using the repository's deterministic checker."
disable-model-invocation: true
---

# No comments

## Adoption and authority

Source, changes and verification limits are in [provenance.json](provenance.json);
retain the upstream [LICENSE](LICENSE). Invocation remains explicit. Scheduled or
PR-triggered invocation needs separately authorized automation. Follow the
repository's planning and confirmation rules. This skill does not authorize
commits, publication, merges, tool installation, or changes to remote, account,
agent, or protected CI configuration. Report unavailable prerequisites as
`blocked`; do not claim unexecuted verification passed.

Use the caller's approved files or diff. Otherwise inspect the current diff
against the repository's base branch, including the working tree. This workflow
adapts pstack's Comment Sicko review; the deterministic checker remains mandatory.

## Steps

1. Locate and run the repository's approved syntax-aware comment checker before
   editing. If none exists or it cannot parse a selected language, record an
   enforcement blocker. Do not invent a checker command or change its policy.
2. Give [the adapted review prompt](references/comment-sicko.md) and the scope to
   a read-only reviewer when delegation is supported and authorized. Otherwise
   perform a fresh serial pass and disclose that independent review was unavailable.
   No named pstack subagent, poteto-mode, how, why or architect skill is required
   or assumed installed; inspect source, contracts and primary documentation
   directly when their analysis would have been needed.
3. Reject scope escapes, application edits by the reviewer, deletion of required
   legal notices and unsupported behavioral claims. Inline, block, documentation,
   TODO/FIXME, commented-out code and lint/type suppression comments are prohibited
   in first-party source. Strings, URLs and language syntax are not comments.
4. Before removing a comment that describes a constraint, preserve its valid
   requirement in the authoritative Markdown/contract and identify enforceable
   architecture, type, property-test or CI protection. Prefer explicit immutable
   state and pure functions over hidden effects. Make behavior changes only within
   approved scope; otherwise report the necessary fix. Never remove a suppression
   and hide the resulting compiler or linter failure.
5. Remove accepted prohibited comments in scope. A legal notice or unavoidable
   tool directive may remain only under an existing human-approved external
   exception identifying exact scope/bytes, reason and review/expiry date.
   Third-party notices retain their protections. Do not invent an exception,
   weaken the checker, add a suppression, or treat an unverified outside rule as
   permission to pass. Report unresolved requirements and blocked exceptions.
6. Rerun the deterministic checker and affected behavior/property tests. For a new
   prevention gate, demonstrate it rejects a representative violating fixture;
   use targeted mutation evidence when behavior changes. Report executed commands,
   source revision, deletion count, preserved legal/tool exceptions, failures and
   remaining work. A review alone cannot establish CI enforcement or completion.

Completion requires the approved checker and relevant checks to pass with retained
evidence; missing capabilities remain blocked. Prepare a reviewable diff and follow
existing confirmation rules before committing or publication.
