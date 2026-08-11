---
name: note-review
description: Review Markdown or Obsidian notes for AI slop, duplication, filler, weak structure, and missing context, then deslopify them while preserving unique ideas and the author's voice. Use when the user asks to review, clean up, deslopify, simplify, consolidate, or improve notes.
---

# Note Review

Review the complete requested scope before editing. Default to reviewing and
cleaning the notes in the same run unless the user asks for review only.

## Identify Slop

Treat content as slop when it adds words or structure without adding meaning:

- repeated ideas, including paraphrased repetition
- filler introductions, conclusions, transitions, and meta commentary
- vague, generic, or inflated language
- unnecessary headings, fragments, callouts, and list items
- duplicated summaries or examples that add no new detail
- template text and unsupported claims presented as established facts

Do not classify a passage as slop only because it is informal, opinionated,
personal, or detailed.

## Preserve

Keep unique insights, decisions, opinions, examples, qualifications, source
links, citations, dates, quantities, identifiers, code, commands, and the
author's voice. Preserve YAML frontmatter, wikilinks, embeds, tags, block
references, and valid Markdown structure.

## Workflow

1. Read every note in scope and enough linked context to understand ownership
   of repeated ideas.
2. Identify concrete slop and structural problems. For review-only requests,
   report findings in severity order with file and line references, then stop.
3. For cleanup requests, make the smallest edits that remove the identified
   slop. Consolidate each repeated idea in one canonical location and replace
   useful cross-note repetition with links when possible.
4. Ask before deleting, merging, renaming, or moving whole files unless the
   user explicitly authorized those operations.
5. Re-read edited sections and inspect the diff. Confirm that no unique facts,
   caveats, sources, metadata, or links were lost. Run `git diff --check` when
   working in a Git repository.

## Output

Summarize:

- files reviewed
- files changed
- slop removed or consolidated
- issues intentionally retained and why
- validation performed
