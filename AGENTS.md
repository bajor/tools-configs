# Agent Coding Guidelines

## 1. Writing Code

Prefer the smallest clear, correct change that fully solves the task.

Before editing, understand the affected flow and check whether existing code,
the standard library, native platform features, or installed dependencies
already solve it.

* Build only what the task requires. Avoid speculative abstractions, flexibility,
  boilerplate, and unnecessary dependencies.
* Avoid magic values. Name any literal whose meaning is not obvious at the call site.
* For bug fixes, inspect every caller of the function being changed. Fix the shared
  root cause and check affected sibling paths.
* Prefer deletion and reuse. Never sacrifice correctness or readability to reduce
  line count or diff size.
* Suggest a simpler approach when it meets the same requirements. Make routine
  implementation decisions without stopping for approval.
* Comment only on non-obvious intent or constraints. Mark deliberate shortcuts with
  a `ponytail` comment naming the limit and upgrade path. For example:
  `// ponytail: Loads the bounded export in memory; stream it if exports become unbounded.`
* Keep hand-written source files at 1,000 lines or fewer. Split before exceeding
  the limit. Exclude generated files, lockfiles, and fixtures.
* Keep functions focused and at one abstraction level. Prefer functions under
  30 lines and fewer than 3 nesting levels when that improves readability.
* Keep each rule or piece of logic in one authoritative place. Extend existing
  modules and consolidate duplication affected by the task. Do not create shared
  abstractions for hypothetical reuse.
* Before adding a dependency, check whether a small, clear implementation suffices.
  Require a maintained package, a compatible license, and a justified dependency tree.

### Change Scope

* Touch only what the request requires. Match the surrounding structure and style.
* Do not refactor unrelated code or change adjacent comments and formatting.
* Remove imports, variables, functions, files, and tests made unused by your changes.
* Mention unrelated dead code when relevant; do not delete it without a request.
* Preserve unrelated user changes. Every changed line must trace to the task.

## 2. Writing Tests

Do not write excessive tests. Only add a test if its failure would tell you
something is actually broken.

* Test observable behavior and contracts. Assertions on styling values, colors,
  or internal structure fail on harmless changes and pass on real bugs, so leave
  them out.
* Choose unit, component, integration, or end-to-end tests according to the failure
  being checked. Do not add every test layer to every change.
* Cover meaningful happy paths, failure paths, and edge cases without duplicating
  existing coverage or mirroring the implementation.
* For a bug fix, add a focused regression test when it can reproduce the real failure.
* For documentation or low-impact configuration changes, use relevant validation
  instead of inventing application tests.

## 3. Writing Style

No em-dashes. No mannered prose. Use direct, literal language instead of metaphor
or flourish. Write "a parameter worth varying," not "a dial worth turning," and
"still matters," not "earns its keep." Say what you mean.

* Define non-obvious terms, acronyms, and domain concepts before using them.
* State relevant scope, assumptions, prerequisites, inputs, outputs, units, defaults,
  constraints, exceptions, and ownership explicitly.
* Give procedures as ordered steps. Identify the actor, action, tool or location,
  expected result, and failure condition when relevant.
* Distinguish facts, assumptions, requirements, recommendations, and examples.
* Use concrete dates with timezones, versions, paths, commands, and thresholds.
  Replace vague references with the exact subject when their meaning is unclear.
* Include an example when an abstract rule or edge case needs one. State its result.
* End instructions with explicit acceptance criteria. Prefer a necessary repetition
  over ambiguity, but omit filler and repeated summaries.

## 4. Planning

Use Plan mode for medium or larger tasks: multi-file refactors, bug investigations,
multi-component changes, or work expected to exceed 30 minutes. Proceed directly
for trivial fixes or explicit, unambiguous instructions.

State consequential assumptions. Ask for clarification when competing interpretations
would materially change the result; decide routine implementation details yourself.

## 5. Type-Level Design

Design types so invalid states are unconstructable. Use domain types where they
enforce a real invariant, such as a non-negative `Age` or distinct `UserId`.
Use sum types or enums instead of boolean combinations that permit invalid states.
Reject invalid values at construction time. Keep these types proportional to the
domain rather than adding wrappers without a correctness benefit.

## 6. Long-Term Architecture

Use iDesign-style volatility-based decomposition. Structure the system around
parts that change for different reasons and at different rates, so each unit owns
one stable responsibility and can evolve with minimal impact on others.

Prefer boundaries that isolate likely change: policy from mechanism, domain logic
from infrastructure, orchestration from execution, and stable contracts from
volatile implementations. Optimize for low coupling and high cohesion, not for
technology layers, framework boundaries, or speculative microservices.

Choose a durable design that satisfies current requirements. If the correct
architecture exceeds the task's scope, split it into focused pull requests (PRs)
that move directly toward that design.

Do not add temporary abstractions, compatibility layers, duplicated paths, or
throwaway implementations unless required for a safe migration of persisted data,
shipped behavior, or external consumers. A deliberate shortcut must still satisfy
current requirements; a `ponytail` comment does not justify incorrect behavior.

## 7. Verification

1. Run the relevant existing checks before editing to establish a baseline.
2. After editing, run the repository's required checks. Use `make test` where it is
   defined; otherwise use the documented equivalent. Include applicable tests,
   type checking, and linting. Use strict compiler settings where supported and
   introduce no warnings.
3. Fix regressions caused by the change. Report pre-existing failures or unavailable
   checks explicitly instead of claiming a pass. Do not build unrelated test
   infrastructure for a documentation-only change.
4. Verify the applicable continuous integration (CI) checks locally before pushing.
   Repeat checks after further changes or failures, not after an unchanged pass.

## 8. PRs and Commit Discipline

Keep each PR focused on one purpose and reviewable in about 15 minutes. Target fewer
than 500 changed lines per PR, but do not harm correctness or readability to meet
a diff-size target. Commit completed logical changes frequently, one purpose per commit.

1. Inspect the working tree and preserve unrelated work.
2. Update `main` from `origin` and create a fresh, descriptive branch from `main`.
3. Implement the focused change, verify it, and commit it.
4. Before pushing, fetch `origin` and rebase onto `origin/main`. Resolve conflicts
   and rerun affected checks if the code changed.
5. Push the branch and create a PR immediately with a clear title, description,
   and verification results.
6. Complete the review below, fix findings, verify the fixes, and push them.

For dependent PRs, number titles by merge order, such as `[1/3]` and `[2/3]`.
Merge each dependency before starting the next branch from updated `main`.
Use labels such as `[2a/5]` and `[2b/5]` for independent parallel PRs.

## 9. Visual Explanations

Create visual explanations for changes that alter architecture, module ownership, workflows, data flow, control flow, storage layout, API contracts, or review-critical process.

Visual explanations are PR review artifacts, not permanent documentation.

1. Write Mermaid source in a temporary file and render it with `mmdc`.
2. Review the rendered diagram. Use separate diagrams when one would hide important
   sequencing or combine unrelated concerns.
3. Commit only the resulting SVG files under `visual-explanations/`. Do not commit
   Mermaid source, `.mmd` files, Mermaid Markdown fences, generated HTML,
   screenshots, PNG fallbacks, or temporary render outputs.
4. Configure cleanup on `push` to `main` through
   `bajor/github-workflows/.github/workflows/delete-visual-explanation-svgs.yml@main`.
   The caller must grant `contents: write`, pass the required `REMOVE_VISUALS_MAIN`
   secret, and keep deletion scoped to `visual-explanations/`.

Link each SVG in the PR body or changed documentation and explicitly describe:

* what changed,
* what existed before the change,
* what exists after the change,
* which files own the behavior,
* what reviewers should verify,
* when the SVG will be deleted from `main`.

## 10. Code Review

After creating the PR, start a fresh Claude session and run `/review` with the PR
link. Fix findings, rerun relevant checks, and push the fixes. Repeat the review
after significant changes. Report explicitly if the review tool is unavailable.

## Completion Checklist

* [ ] The requested behavior is complete, clear, and correct.
* [ ] Existing code was checked for reuse; scope and dependencies are justified.
* [ ] Types enforce relevant invariants; source files respect the size limit.
* [ ] Added tests detect real failures; applicable checks pass or blockers are reported.
* [ ] Required SVGs and their descriptions are included, with cleanup configured.
* [ ] Writing is direct, unambiguous, and free of em-dashes.
* [ ] Changes are committed on a fresh branch, pushed, and submitted as a reviewed PR.
