---
name: create-verification-skill
description: "Generate a project-local verification skill that drives your app the way a user does: any language, framework, or platform. Use for /create-verification-skill, \"make a control skill for this repo\", or when a project has no scripted way to prove UI/CLI/service behavior."
disable-model-invocation: true
---

# Create a verification skill

## Adoption and authority

Source, changes and verification limits are in [provenance.json](provenance.json);
retain the upstream [LICENSE](LICENSE). Invoke for an authorized request or
approved automation. The retained upstream `disable-model-invocation` field is
not a demonstrated cross-harness control. Follow repository authorization and
policy; this skill grants no commit, publication, installation or settings access.
Report missing prerequisites as `blocked`; never claim unexecuted checks passed.
Consumer rules determine colocation, functional purity and comment policy.

Every serious project needs a scripted way to drive the real app and prove behavior: launch it, exercise a feature the way a user would, and capture evidence. This skill generates that as a project-local skill (`<skills>/verify-<app>/`) tailored to the repo. `<skills>` is the repository's approved local skill directory. Resolve existing harness configuration and skills before choosing a path; `.agents/skills/` is the Unpolar convention, not a universal requirement. Expose one canonical copy through supported discovery; never assume every harness scans the same path. If discovery has not been configured and demonstrated, report it blocked rather than change global settings. You write the generator's output for the next agent, not for a human: it will be read cold, mid-task, by an agent that has never seen the app.

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

Inventory every user-facing feature against independent requirements and current routes, commands and menus. Generate `<skills>/verify-<app>/features/README.md` and one entry per feature; omitted or unknown required features block completeness. Follow the illustrative [map format](references/feature-map-example/). Record owner, expected behavior, access paths, contracts/requirements, commands, device needs, shared skills, debugging/performance scenarios and required evidence. Identify missing requirement IDs honestly; do not invent approvals.

Use the consumer's established descriptor/registry/generator when present. If its policy requires feature-owned descriptors and generated projections, absence blocks generation until that infrastructure is approved. Otherwise the local map may be the initial authoritative inventory: label inferred behavior for confirmation and keep tests/fixtures in their existing owners. Do not impose a new feature layout on an unrelated consumer. Never duplicate existing scenario sources or silently redefine expected behavior to match the implementation.

## Contract and test sensitivity

Discover the consumer's required contract, compiler, architecture, comment,
property and mutation checks. Run applicable existing commands and record seeds,
counterexamples and detecting assertions. Where the consumer requires a pure
immutable core, identify its real compiler/AST restrictions and effect owners;
a missing mandatory gate blocks readiness. Do not create new policy by assumption.
For native Apple targets, follow the approved official MCP/CLI policy and available
shared Apple skills. If required skills are absent, report the missing dependency.
Changes to independent requirements or protected gates require their own approval.

## 4. Prove the generated skill before handing it over

Run its own instructions end to end once: launch, doctor, drive an initial mapped feature, capture evidence, clean up. This proves only that initial journey. Reconcile every registered feature in the map and keep each unexecuted required journey explicitly blocked. Do not present the application verification skill or repository as fully verified until every mandatory feature/scenario for the selected profile has current evidence. After cleanup, confirm the evidence still exists at the named location: a cleanup that eats the proof fails this step. Fix what fails, and run the generated cleanup after every failed iteration too, so broken attempts don't strand processes and ports. A generated skill that was never executed is a draft, not a deliverable. If you proved it in a stand-in for the real target (a container in place of a fresh VM, a local stack in place of a remote one), list every setup step the stand-in did that the target will not. Those steps stay unverified until a run on the real target covers them.

## 5. Offer the maintenance loop

Point the user at the sibling [maintain-verification-skill](../maintain-verification-skill/SKILL.md) for keeping the map honest as the app changes. Suggest a cadence only if they ask.
