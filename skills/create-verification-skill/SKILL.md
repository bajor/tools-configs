---
name: create-verification-skill
description: "Generate a project-local verification skill that drives your app the way a user does: any language, framework, or platform. Use for /create-verification-skill, \"make a control skill for this repo\", or when a project has no scripted way to prove UI/CLI/service behavior."
disable-model-invocation: true
---

# Create a verification skill

## Adoption and authority

Source, changes and verification limits are in [provenance.json](provenance.json);
retain the upstream [LICENSE](LICENSE). Invocation remains explicit. Scheduled or
PR-triggered invocation needs separately authorized automation. Follow the
repository's planning and confirmation rules. This skill does not authorize
commits, publication, merges, tool installation, or changes to remote, account,
agent, or protected CI configuration. Report unavailable prerequisites as
`blocked`; do not claim unexecuted verification passed.

Every serious project needs a scripted way to drive the real app and prove behavior: launch it, exercise a feature the way a user would, and capture evidence. This skill generates that as a project-local skill (`<skills>/verify-<app>/`) tailored to the repo. `<skills>` is the canonical repository-local `.agents/skills/` directory. Use the repository's approved harness discovery configuration to expose that directory to Claude Code, Codex, Pi and OpenCode; never create independently maintained copies or assume every harness scans it. If discovery has not been configured and demonstrated, report it blocked rather than change global settings. You write the generator's output for the next agent, not for a human: it will be read cold, mid-task, by an agent that has never seen the app.

## 1. Interview the repo, not the user

Answer these from the codebase and only ask the user what you cannot observe:

- **Surface:** what does a user actually touch? A web UI, a CLI/TUI, a desktop app, an API, a mobile app, a library? A repo can have several; pick the primary one and note the rest.
- **Run:** how does the app start locally? Prefer the repo's own documented dev command (package scripts, Makefile, README quickstart). Note ports, env vars, seed data, auth.
- **Drive:** how can an agent interact with it programmatically? Existing harnesses first: Playwright/Cypress specs, expect scripts, PTY helpers, curl-able endpoints, a debug port. Only then pick a generic recipe: browser/CDP for web and Electron, a tmux/PTY harness for CLI/TUI, plain HTTP for services.
- **Observe:** what evidence can be captured? Screenshots, terminal transcripts, response bodies, logs, exit codes, DB state.
- **Isolate:** can two instances run side by side (ports, data dirs, profiles)? If not, say so in the generated skill: refusing to double-drive a shared instance beats corrupting the user's session.

If the checkout does not build or start as-is, report the blocker before generating. Fix product code only within separately authorized scope. A skill written against a broken base teaches wrong steps. When an irrelevant missing asset blocks startup (a static dir the API never serves, a sample config), the generated skill may create it, clearly marked as verification scaffolding, and remove it in cleanup.

## 2. Generate the skill

Write `<skills>/verify-<app>/SKILL.md` with YAML frontmatter (`name: verify-<app>` and a `description` that names the app, the surface, and when to reach for it: without frontmatter the skill never registers) and these sections, each grounded in what the interview actually found (no placeholders left):

- **Launch:** the exact command that starts the app for verification, and how to tell it's ready (a log line, a prompt). Launch must reach a usable state from an empty data dir, including any migrations and seed data. Ready means usable, not just that a process answers. A database health check can pass while its init scripts are still running. Include teardown. For a short-lived CLI or TUI there is no server to keep alive: launch means build the binary (or install deps) once, then start each drive in its own isolated PTY or tmux session.
- **Doctor:** one read-only check that answers "is this instance worth driving?": process up, right version/build, port owned by us, auth valid. An agent runs this first whenever anything looks off.
- **Drive:** the harness recipe with real selectors/commands from this repo, not examples. Prefer stable handles (ARIA labels, data attributes, prompt strings, route paths) over coordinates and tab order.
- **Evidence:** what to capture for a proof and where it goes. State the proof standards: exercise the real user path, not internal setters or test-only endpoints; capture the action and the resulting state, not just the final screen; verify side effects (files written, rows inserted, messages sent) alongside what's visible; mocks only where a production boundary already isolates the external system. When the safe path is a dry-run or test mode, verify what it actually skips by observing (files, network, git refs) rather than trusting its name: some dry-runs still touch the network or open a browser.
- **Cleanup:** how to tear down instances the run created. Never kill by process name; kill what you started. Cleanup removes instances and scratch state, never the evidence: proof artifacts survive the teardown, in a location the skill names.
- **Helpers:** any script the skill ships is executable and its invocation is shown in the skill body. A helper the reader has to reverse-engineer is not a helper.

## 3. Seed the feature map

Keep the authoritative feature verification descriptor under its unique owning feature directory, using the repository's established descriptor format. Generate `<skills>/verify-<app>/features/README.md` and any per-feature skill projections from those descriptors, with one entry per registered or independently required user-facing feature, reconciled against the complete feature registry and current routes, commands, menus and requirements. Do not stop at a top-feature sample. Unknown or omitted features make the map incomplete and blocked. Follow the shape in [`references/feature-map-example/`](references/feature-map-example/), with a README index and one file per feature. Each file answers, from the user's point of view: what the feature is, how to reach it, how to drive it with the harness, and what observable end state proves it works. The four H2s are `Sub-features`, `How to get to it (user POV)`, `Driving it with <harness>`, and `Gotchas`. Record the unique owning feature directory, independent requirement IDs, contract versions, supported device/configuration matrix, relevant shared skills, debugging and performance scenarios, test commands and required evidence. Keep feature-owned tests and fixtures in that feature directory; the skill map references them or contains generated projections, without moving implementation into the skill. If the seed data lacks a precondition that a journey needs, the journey reports a failure and the reason goes in that feature's `Gotchas`. Never weaken the journey to make it pass. The feature-owned descriptors are the maintained scenario source; the skill map is a generated index/projection, not an independently edited duplicate; a proof that drives one convenient entry point is incomplete when the map lists others.

## Contract and test sensitivity

For domain logic, require pure deterministic functions that take all inputs
explicitly, return new values, and have no hidden mutable state, clock, random
generator, storage or network dependency.
Keep effects in explicit adapters. Name the compiler, AST/dependency check and
runtime tests that enforce those boundaries; prose alone is not enforcement.
Use property-based tests for invariants and state transitions, record seeds and
shrunk counterexamples, and demonstrate a targeted behavior mutation is caught.
Identify the actual CI commands and evidence for these checks. A missing gate or
an unexecuted command is blocked, not a completed safeguard. Changes to independent
requirements or protected checks need their own approval.
For Apple targets, use the repository's approved Apple skills and official
MCP/CLI policy; do not assume another MCP exposes equivalent capabilities.

## 4. Prove the generated skill before handing it over

Run its own instructions end to end once: launch, doctor, drive an initial mapped feature, capture evidence, clean up. This proves only that initial journey. Reconcile every registered feature in the map and keep each unexecuted required journey explicitly blocked. Do not present the application verification skill or repository as fully verified until every mandatory feature/scenario for the selected profile has current evidence. After cleanup, confirm the evidence still exists at the named location: a cleanup that eats the proof fails this step. Fix what fails, and run the generated cleanup after every failed iteration too, so broken attempts don't strand processes and ports. A generated skill that was never executed is a draft, not a deliverable. If you proved it in a stand-in for the real target (a container in place of a fresh VM, a local stack in place of a remote one), list every setup step the stand-in did that the target will not. Those steps stay unverified until a run on the real target covers them.

## 5. Offer the maintenance loop

Point the user at the sibling [maintain-verification-skill](../maintain-verification-skill/SKILL.md) for keeping the map honest as the app changes. Suggest a cadence only if they ask.
