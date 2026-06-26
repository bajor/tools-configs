# Agent Coding Guidelines

## Core Principles

1. **Plan before coding** — Use Plan mode for medium+ tasks
2. **Type-level correctness** — Make invalid states irrepresentable
3. **Test thoroughly** — Unit + Component tests, happy paths + edge cases
4. **Keep it simple** — Minimum code that solves the problem; readable over clever
5. **Make surgical changes** — Touch only what the request requires; clean up only your own mess
6. **Clean as you go** — Remove unused code created by your changes; simplify your own work relentlessly
7. **Minimize dependencies** — Prefer standard library; every external lib is a liability
8. **Verify before committing** — `make test` must pass (tests + types + lint)
9. **Split large work** — Multiple focused PRs (<500 lines each)
10. **Commit frequently** — One logical change per commit
11. **Branch from main** — Every task gets a fresh branch
12. **DRY** — Search first, reuse and extend existing code
13. **Name every value** — Give constants and thresholds descriptive identifiers
14. **Push and PR** — Every completed branch gets pushed with a PR immediately

**Keep it simple. Make surgical changes. Commit after every task. Branch from main. Push and PR.**

---

## 1. Planning

Use Plan mode for multi-file refactors, bug investigations, multi-component changes, anything >30 minutes. Go straight to code only for trivial fixes or explicit unambiguous instructions. When in doubt, plan.

---

## 2. PR Strategy

Break large work into focused PRs. Each: reviewable in ~15 min, single purpose, <500 lines, all tests pass.

**Workflow:** Identify scope → break into feature-slice chunks → number by merge dependency `[1/N]`, `[2/N]` → for each: branch from main → implement → `make test` → push → create PR → merge → next chunk. Use `[2a/5]`/`[2b/5]` for independent parallel PRs.

**Example:**

```text
[1/5] Add user database schema and models (150 lines)
[2/5] Implement auth service with JWT (200 lines)
[3/5] Add login/logout API endpoints (180 lines)
[4/5] Add frontend login UI (220 lines)
[5/5] Add password reset flow (190 lines)
```

---

## 3. Type-Level Design

Design types so invalid states are unconstructable. Wrap primitives in domain types (`Age` over `Int`, `UserId` over `String`). Use sum types/enums over boolean flags. Reject invalid values at construction time.

**Example:**

```scala
opaque type Age = Int

object Age:
  inline def apply(inline n: Int): Age =
    inline if n < 0 then error("Age cannot be negative") else n

birthday(Age(25))   // works
birthday(Age(-5))   // compile error
```

---

## 4. Testing

Ship unit + E2E tests covering happy paths and edge cases with every implementation.

**Workflow:** `make test` before changes (baseline) → implement → write/update tests → `make test` after → fix regressions → verify CI locally before pushing.

`make test` must include: unit tests, E2E tests, type checking, linting. If incomplete, fix it first.

---

## 5. Type Checking and Linting

Run on every verification cycle. Compiled languages: strict flags, zero warnings. Interpreted: type checker (mypy/pyright/tsc) + linter (eslint/ruff/clippy), both in `make test`.

```makefile
test:
	npm run typecheck && npm run lint && npm run test:unit && npm run test:e2e
```

---

## 6. Code Simplicity (KISS)

Minimum code that solves the problem. Nothing speculative.

Write code a junior developer can understand. One abstraction level per function. Functions under 30 lines, nesting under 3 levels. Prefer boring technology.

**Rules:**

* No features beyond what was asked.
* No abstractions for single-use code.
* No flexibility or configurability that was not requested.
* No error handling for impossible scenarios.
* Let the code speak — if a comment explains *what* it does, rewrite it.
* If you write 200 lines and it could be 50, rewrite it.
* Ask: would a senior engineer say this is overcomplicated? If yes, simplify.

---

## 7. Surgical Changes

Touch only what you must. Clean up only your own mess.

When editing existing code:

* Do not improve adjacent code, comments, or formatting.
* Do not refactor code that is not broken.
* Match existing style, even if you would do it differently.
* If you notice unrelated dead code, mention it; do not delete it.

When your changes create orphans:

* Remove imports, variables, functions, files, and tests that your changes made unused.
* Do not remove pre-existing dead code unless asked.

Every changed line must trace directly to the user's request.

---

## 8. DRY

Every piece of logic has a single authoritative location.

**Before writing:** search the codebase (grep/IDE/AST) → if found, reuse or generalize → if new, place in shared location designed for reuse → consolidate any duplication found during work.

**Rules:** Read before writing. Extend the original module for new behavior. One fact in one place (config, rules, validation, types). Get it right the first time. Shared logic in shared modules.

**Example — shared validation:**

```python
# validation.py — single source of truth
def validate_email(email: str) -> Email:
    if not re.match(r'^[\w.+-]+@[\w-]+\.[\w.]+$', email):
        raise ValueError("Invalid email")
    return Email(email)

# user_api.py / invite_api.py — both call validate_email()
```

**Example — extending an existing module:**

```python
# notifications.py — add priority param to existing function
def send_notification(user_id, message, channel, priority=Priority.NORMAL):
    ...

def send_urgent_notification(user_id, message):
    for ch in ("sms", "email"):
        send_notification(user_id, message, channel=ch, priority=Priority.URGENT)
```

---

## 9. Commit Discipline

Each commit = one logical unit of work. Target 1–50 lines, 50–100 acceptable, 100+ rare.

**Every task follows this flow:**

```bash
git checkout main && git pull origin main
git checkout -b <descriptive-branch-name>
# ... work, committing after each logical change ...
make test
git push origin <branch-name>
gh pr create --title "<title>" --body "<description>"
```

Commit after: adding a function, fixing a bug, adding a test, refactoring a component, updating config, changing a dependency. Use multiple `-m` flags for details.

Before pushing: fetch origin, rebase main, resolve conflicts, re-run `make test`. After pushing: create PR immediately. Multi-PR tasks use `[X/N]` in title.

---

## 10. Code Review

Complete implementation → `make test` → commit/push/PR → fresh Claude session → `/review` with PR link → fix issues → `make test` → push → re-run `/review` if significant changes.

---

## 11. Minimal Dependencies

Before adding: can it be done in <50 lines? Is it well-maintained with a small dep tree and compatible license? Prefer standard library > single-purpose lib > framework.

---

## 12. Explicit Communication

When explaining something, writing documentation, or creating notes, write so that a reader never has to infer missing meaning. The result must be unambiguous and directly actionable.

**Rules:**

* Define every non-obvious term, acronym, and domain concept before using it.
* State scope, assumptions, prerequisites, inputs, outputs, units, defaults, constraints, exceptions, and ownership explicitly when relevant.
* Give procedures as ordered steps. For each step, state the actor, action, location or tool, input, expected result, and failure condition when relevant.
* Separate facts, assumptions, requirements, options, recommendations, and examples. Label them explicitly.
* Use exact values instead of vague language: concrete dates with timezones, versions, file paths, commands, input formats, thresholds, and identifiers where applicable.
* Do not rely on implication, omitted context, “obvious”, “usually”, “etc.”, “appropriate”, “as needed”, or ambiguous references such as “this”, “that”, “above”, or “the previous step”.
* When more than one interpretation is possible, list the interpretations and either choose one with a stated reason or ask for clarification. Do not silently guess.
* Include a concrete example for abstract rules and edge cases, and state the expected result.
* End instructions with explicit acceptance criteria: what must be true for the work to be considered complete.
* Prefer repetition over ambiguity.

---

## Checklist

* [ ] Fresh branch from main
* [ ] Plan mode used (if medium+ task)
* [ ] Large task split into focused PRs with `[X/N]` merge order
* [ ] Types prevent invalid states
* [ ] Unit + E2E tests (happy path + edge cases)
* [ ] `make test` passes (tests + types + lint)
* [ ] CI verified locally
* [ ] Code is minimal: no speculative features, single-use abstractions, or unrequested configurability
* [ ] Changed lines trace directly to the request
* [ ] Only your own unused imports, variables, functions, files, and tests were removed
* [ ] Dependencies justified
* [ ] DRY — searched codebase, reused/extended existing code
* [ ] Commits small, frequent.
* [ ] Branch pushed, PR created with clear title/description
* [ ] Code review in fresh session with `/review`
