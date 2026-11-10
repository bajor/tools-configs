# Pi Configuration

This directory contains configuration and agent definitions for [pi](https://pi.dev), the minimalist coding agent harness.

## Automatic usage-limit recovery

[`limit-retry.ts`](limit-retry.ts) retries temporary usage limits on the same model
until a request succeeds. It waits 1, 2, 4, 8, 16, 32, then 60 minutes between
attempts, with no attempt cutoff. Explicit `retry after N seconds/minutes/hours`
or `try again in N seconds/minutes/hours` text can extend that wait beyond an hour.
It never enables paid overflow, switches providers, or changes permissions.

1. Install Python 3 and Pi 1.5.0 or newer. Run from the repository root:
   ```sh
   python3 setup-auto-resume.py --target pi
   ```
   This copies the extension to `~/.pi/agent/extensions/limit-retry.ts`, respecting
   `PI_CODING_AGENT_DIR`, and backs up an existing file before replacing it.
2. In an existing Pi session, run `/reload`. New sessions discover it automatically.
3. Keep Pi running. After native retries finish, a recognized temporary limit
   shows the next retry time in the status area. Escape cancels the wait in the
   terminal UI. New submitted input, model changes, and session shutdown also cancel it.
4. To uninstall, remove the installed `limit-retry.ts` and run `/reload`.

The extension uses Pi's `agent_before_settle` boundary and a durable `context_edit`
to omit only the failed response from model context. Raw history and completed
tool results remain intact; it adds no synthetic user prompts. Successful progress
resets the backoff. Timers do not survive process exit or reload. In non-terminal
modes, a host abort suppresses continuation, but may not release the sleeping
handler until its timer expires; prompt cancellation is verified for the terminal UI.

Recognized errors include HTTP 429, rate limits, usage limits, and daily/window
quotas. Invalid credentials, insufficient API quota/credits, payment failures,
suspended accounts, administrator-imposed ChatGPT workspace limits, context
overflow, and unrecognized errors stop normally. This is opt-in unattended
execution: once quota returns, Pi can resume tool use under its existing permissions.

Research: Pi's [native retry settings](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/settings.md)
default to three retries and exclude some subscription limits.
[@monotykamary/pi-retry](https://github.com/monotykamary/pi-retry) also excludes
quota/session exhaustion. This implementation is purpose-built using Pi's
[documented extension boundary](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/extensions.md),
not copied third-party source. Do not install another quota-retry extension alongside it.

Validation, with Node.js 22.23.4 or newer and no npm dependencies:

```sh
npm --prefix pi test
```

Acceptance: a temporary limit waits before resuming the same context; repeated
limits increase the delay; successful progress resets it; Escape prevents resumption.

## Prerequisites

Install pi-open-agents to enable primary agent management:

```bash
pi install npm:pi-open-agents
```

Add the package to `~/.pi/agent/settings.json`:

```json
{
  "packages": ["npm:pi-open-agents"]
}
```

See [pi-open-agents](https://github.com/andrea-tomassi/pi-open-agents) for full documentation.

## Agents

This configuration defines two primary agents matching OpenCode's build/plan pattern:

### `build` (default)

Full-capability implementation agent with unrestricted tool access. Use for writing code, modifying files, running tests, and completing implementation work.

**Switch to build:**

```bash
pi --agent build
```

Or interactively: `/agent build` or `Ctrl+Shift+M` to cycle agents.

### `plan`

Read-only investigation and planning agent. Explores codebases, proposes solutions, and designs implementations without modifying files. Enforces `permission: { edit: deny, write: deny }`.

**Switch to plan:**

```bash
pi --agent plan
```

The plan agent is ideal for:
- Understanding unfamiliar codebases
- Designing implementation approaches before coding
- Analyzing architecture and trade-offs
- Creating detailed implementation plans for the build agent

## Installation

**Global (affects all pi sessions):**

```bash
ln -sf $(pwd)/agents/*.md ~/.pi/agent/agents/
```

**Project-local (affects only this project):**

```bash
mkdir -p .pi/agents
ln -sf $(pwd)/pi/agents/*.md .pi/agents/
```

Pi discovers agents from multiple locations (project overrides global by name):
- `~/.pi/agent/agents/*.md` (global)
- `.pi/agents/*.md` (project)
- `.opencode/agents/*.md` (OpenCode compatibility)

See the [pi packages documentation](https://pi.dev/docs/packages) for advanced configuration options.

## Usage

List available agents:

```bash
pi
/agents
```

Switch agents mid-session:

```text
/agent plan
```

Start pi with a specific agent:

```bash
pi --agent plan
```

Search agents by name or description:

```text
/agent-search planning
```

## Agent Definition Format

Agent files use YAML frontmatter with the pi-open-agents schema:

```yaml
---
name: agent-name
mode: primary                   # primary | subagent | all
description: One-line summary
permission:                     # optional: tool restrictions
  edit: deny
  write: deny
---
Your agent system prompt goes here.
```

See the [pi-open-agents README](https://github.com/andrea-tomassi/pi-open-agents#agent-definition-format) for the complete specification.
