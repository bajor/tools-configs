# Pi Configuration

This directory contains configuration and agent definitions for [pi](https://pi.dev), the minimalist coding agent harness.

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
