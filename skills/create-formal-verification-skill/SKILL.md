---
name: create-formal-verification-skill
description: "Generate a project-local skill that formally verifies the code where a bug costs the most and tests reach the least, in any language, with whichever verification tool fits. Use for /create-formal-verification-skill, \"model-check this race\", \"prove this invariant\", or when concurrency, retries, state machines, parsers, or unsafe code need more than tests."
disable-model-invocation: true
---

# Create a formal verification skill

## Adoption and authority

Source, changes and verification limits are in [provenance.json](provenance.json);
retain the upstream [LICENSE](LICENSE). Invocation remains explicit. Scheduled or
PR-triggered invocation needs separately authorized automation. Follow the
repository's planning and confirmation rules. This skill does not authorize
commits, publication, merges, tool installation, or changes to remote, account,
agent, or protected CI configuration. Report unavailable prerequisites as
`blocked`; do not claim unexecuted verification passed.

A test checks the cases that someone thought to write. Formal verification checks every case in a stated scope: every order of steps in a model, every input up to a bound, or every input. This skill finds the part of the repo where that matters most, verifies one property of it, and leaves a project-local skill that lets the next agent check a change against that property. Write that skill for an agent who reads it cold, mid-change, and has never seen your work. The user must be able to trust the result and act on it without learning the verification language.

## Choose the target from the code

Answer from the codebase, and ask the user only what you cannot observe. If the user named an area or a bug, start there.

A good target is a promise the code makes, where a break harms users and tests rarely reach the case that breaks it. Choose the strongest such target in the repo, not the one that is easiest to verify.

## Let the question choose the tool

Pick the tool that answers the question at the lowest cost: a model checker, a proof assistant, an SMT-backed verifier, or another tool. Whether events can happen in a bad order usually suits a model checker over a small model of the design, and TLA+ is the default for that in any language. Whether the code itself behaves for every input, as with memory safety, overflow, or a data-structure invariant, usually suits a verifier that runs on the code. If no verifier runs on this language, say so, and test the real code with generated inputs, not a hand model of the function. A property that must hold at every size, where a bound is not enough, can need a proof. Prefer a tool that the repo's developers can install and run, and tell the user why you chose it.

## What makes it good

- **True to the code.** Every part of the model or proof points to code that a reviewer can open. What the verification treats as one indivisible step is one indivisible step in the code. Names come from this repo.
- **Able to fail.** A check that you have never seen fail proves nothing. Show each property failing on a broken variant of the code it guards, such as a removed check or a reordered step.
- **Findings stay findings.** When the current code breaks the property, report it with the counterexample in the code's terms. Do not weaken the property or the model until it passes, and do not change product code unless the user asks.
- **Honest about scope.** Say what is verified, under which bounds and assumptions, and what is left out. A pass covers the model or the bound, not the whole system.
- **Readable without the tool.** State the property and the harm in one plain sentence each. Tell a counterexample as a short sequence of steps in the code's words.
- **Cheap to rerun.** One command, a reproducible tool version, and a run short enough that the next agent will use it on every relevant change.
- **Kept in step with the code.** Record which files and functions each check covers, and the commit at which you last confirmed that the verification describes them. When the covered code changes after that commit, the next agent can see that the verification needs another look.

## Generate the verify skill

Write a project-local skill under `.agents/skills/` using approved harness discovery configuration, with frontmatter that names the area and says when to use it. Without frontmatter, the skill never registers. From the skill alone, the next agent must be able to tell whether a change touches the verified code, run the check, tell a real bug from a modeling error, and update the verification when a change is intended. Put the coverage record and the sync commit in the skill, and tell the next agent to move the sync commit forward only after it confirms that the verification describes the code at the new commit. Use this repo's real commands, paths, and nouns, and leave no placeholders.

For TLA+ reporting, pstack's optional [statechart skill at the adopted pin](https://github.com/backnotprop/pstack/tree/4161d4ef5051574e825ffe70e2f43a2e49e4b3db/skills/statechart) is not included in this package. If that reporting workflow is selected, stop as blocked until its complete skill directory and runtime dependencies are separately approved, pinned, installed and demonstrated; do not invoke a nonexistent local skill or install tools implicitly. It reports counterexample paths and can render small state graphs, but its reporting bounds are not proof that every property was checked. The repository's pinned direct TLC command can still provide model-checking evidence when that is the approved workflow; record that statechart reporting was not run.

Feature-specific models, properties, fixtures and verification support remain
under the unique owning feature directory. The local skill orchestrates them or
contains generated projections; it must not become a second feature implementation
root. Register an explicit shared owner for a genuinely cross-feature protocol
model and enforce its dependencies before adding it.

## Implementation relation and CI

Make pure transition functions, immutable inputs/outputs and explicit effect
boundaries part of the property when they enforce a real requirement. Map each
model step to the implementation's actual atomicity and state owner. Use
property-based state-machine tests against real code and targeted mutations to
check that relation. Record actual CI commands, tool versions, seeds, assumptions,
bounds and revision-bound evidence. A design model, parser check or attractive
chart alone does not verify implementation. Do not add source-code comments or
weaken independent requirements to make a check pass.

## Prove it before you hand off

Follow the generated skill once, as the next agent would, on a scratch change that breaks the property in the real code. It must catch the break. Then drop the scratch change and confirm that the check is back where it started: passing, or failing only on the findings you will report. A verify skill that was never run is a draft. If the skill misses the break or a step does not run, fix the skill or the verification, not the scratch change.

## Hand off

Tell the user what you verified, which tool you used and why, the bounds, what the check found in plain words, how to run it, and what it does not cover. Suggest a second target only if you found a close one. Point the user at `/maintain-formal-verification-skill` for bringing the verification back in line after changes that did not recheck it.
