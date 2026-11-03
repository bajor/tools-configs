# Shared agent instructions

Keep one global instruction file at `~/AGENTS.md`, in the root of your home
directory, not the filesystem root. Use [AGENTS.md](AGENTS.md) as the template.

Migrating from `<checkout>/AGENTS.md`? Repoint existing links before updating the
checkout; the template now lives in `agents/AGENTS.md`.

1. Create or update `~/AGENTS.md` by merging the template with any existing rules
   from that file and the harness instruction files below.
2. Back up existing harness instruction files, then replace them with direct
   symlinks to `~/AGENTS.md`:

   | Harness | Global instruction file |
   | --- | --- |
   | Claude Code | `~/.claude/CLAUDE.md` |
   | OpenAI Codex | `~/.codex/AGENTS.md` |
   | OpenCode | `~/.config/opencode/AGENTS.md` |

   These are the default paths; use the configured directories if overridden.
3. Start new Claude Code and Codex sessions. OpenCode reloads global instructions
   automatically before its next model request.

Do not link global instructions to a Git checkout: switching branches must not
change your global rules. Update `~/AGENTS.md` deliberately when adopting changes
from this template.

Setup is complete when all three symlinks resolve directly to `~/AGENTS.md` and
the tools load the same rules.
