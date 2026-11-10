---
name: correct
description: "Find the mistakes agents keep repeating in this repo and make each one impossible. Try architecture and immutable explicit state first, then types, deterministic checks and sensitive tests; write docs last. Prove each check fails on a real past mistake. Repeat this each time the operator corrects you. Use for /correct."
disable-model-invocation: true
---

# Correct

## Adoption and authority

Source, changes and verification limits are in [provenance.json](provenance.json);
retain the upstream [LICENSE](LICENSE). Invocation remains explicit. Scheduled or
PR-triggered invocation needs separately authorized automation. Follow the
repository's planning and confirmation rules. This skill does not authorize
commits, publication, merges, tool installation, or changes to remote, account,
agent, or protected CI configuration. Report unavailable prerequisites as
`blocked`; do not claim unexecuted verification passed.

The operator keeps correcting agents in this repo for the same mistakes. Change the repo so the next agent can't make them.

Assume every contributor is an agent that sees only the files it opened, copies the nearest example, and takes the shortest path that compiles. Design the repo so a change that looks right from one file is right for the whole repo.

## Find the mistake classes

First, read recent commits, reverts, review findings, agent instruction files, contracts and existing workaround evidence; do not add new source comments. Group the mistakes into classes. A class counts once it has happened twice.

## Fix each class at the highest level that works

1. **Eliminate it with architecture.** Give each piece of state one owner and each task one supported way. Prefer pure deterministic domain functions with explicit immutable inputs/outputs; isolate storage, clocks, randomness and network effects in adapters. Hide internals so the wrong import fails. Replace hand-synced lists with one source of truth. Delete old ways and dead code an agent would copy.
2. **Enforce it with types so the bad state can't be written.** If bad code still compiles, add a lint or CI check whose error names the file, type, or function to use instead. Do not grandfather violations of mandatory rules such as zero comments, feature colocation or forbidden hidden state. Report existing violations and obtain any migration policy through independent approval rather than weaken the gate.
3. **Test the behavior.** Use property-based tests for invariants and record seeds and counterexamples. Demonstrate targeted behavior mutations fail the intended tests; compilation failure alone is not a killed behavioral mutant. Repair weak tests within scope without deleting independent requirements or protected regression coverage. Run the relevant approved CI commands and keep revision-bound evidence.
4. **Write docs or agent rules last, only for judgment calls.** Nothing fails when an agent skips them.

## Fix and prove

Then prepare the most frequent authorized fixes as separate logical changes; follow repository planning and confirmation requirements before committing or publishing. Prove each new check fails on a real past mistake. Run the same command locally and in CI. Do not add inline exceptions, documentation comments, TODOs or lint/type suppressions. Preserve legally required notices and unavoidable tool directives only when a protected external exception record identifies exact scope, bytes, reason, human approval and expiry/review date. Do not create or edit those approvals to pass the check.

## Keep the rule table

Last, update the repository's existing enforcement table with rule, prevention, deterministic check, CI gate, evidence and failure behavior; link it from agent instructions instead of duplicating shared policy. When the operator corrects you, fix the mistake and add the rule. If the rule was already there and nothing enforces it, that's a repeat, so fix it at the highest level in the same change. Keep the rule linked to the mechanism that prevents its violation; retire it only when the requirement itself is explicitly retired.

**Reply:** each class with its evidence, the level you picked, and why a higher level didn't work.
