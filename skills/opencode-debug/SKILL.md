---
name: opencode-debug
description: Use when debugging opencode, OpenCode, opencode config, agents, skills, plugins, MCP servers, permissions, startup failures, tool failures, or unexpected agent behavior; the primary agent must analyze the issue, identify the root cause, and suggest or apply the smallest durable solution.
---

# OpenCode Debug

Use this skill as the primary agent when the user reports an opencode issue or
asks to debug opencode behavior.

## Goal

Diagnose the issue before changing files. The final answer must separate:

- observed symptoms
- verified root cause
- recommended solution
- changes made, if the user asked for execution
- validation performed

## Workflow

1. Capture the exact failure mode from the user's message, terminal output,
   logs, config files, and recent edits.
2. Inspect the relevant opencode files before assuming the cause. Check global
   config, project config, agent files, skill files, command files, plugins,
   MCP server config, and permission rules when they are in scope.
3. Validate config shape against the opencode schema or documented config rules
   before editing. opencode fails fast on invalid config.
4. Prefer the smallest durable fix. Do not add compatibility layers,
   speculative fallbacks, or broad rewrites unless the issue requires them.
5. If the failure involves agent behavior, distinguish prompt ambiguity from
   config loading, model selection, permissions, tools, and skill activation.
6. If the failure involves a skill, verify the folder name, `SKILL.md` file
   name, required frontmatter, `name` value, and trigger description.
7. If the failure involves an agent, verify frontmatter fields, `mode`, model,
   permissions, hidden/disabled state, and whether `default_agent` points to a
   non-hidden primary agent.
8. If the failure involves MCP, verify `type`, command array shape, environment,
   credentials interpolation, enablement state, and timeout assumptions.
9. If editing config, tell the user to restart opencode because config-time
   files are loaded once at startup.

## Output

State the root cause directly. If the root cause is not proven, say what is
known, what remains unverified, and the next concrete check.

When suggesting a fix, include exact file paths and the smallest change needed.
When making a fix, inspect the diff and run the most relevant available
validation before reporting completion.
