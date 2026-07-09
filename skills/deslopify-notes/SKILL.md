---
name: deslopify-notes
description: Refactor notes by removing duplication, merging related ideas, and simplifying structure using DRY principles.
---

# deslopify-notes

Analyze the whole notes repository before editing.

Goals:
- find repeated ideas, even with different wording
- merge overlapping notes
- create one canonical place for each concept
- replace duplicates with links/references
- remove filler, verbose explanations, and obvious statements

Treat notes like code:
- duplication = technical debt
- files = modules
- concepts should have single ownership

Workflow:
1. Find duplicate clusters:
   - topic
   - files involved
   - what should be merged

2. Suggest refactor plan:
   - merge
   - delete
   - extract
   - rename/reorganize

3. After approval, edit:
   - preserve unique insights
   - keep personal voice
   - keep useful examples
   - remove repetition only

Prefer:
short, dense, maintainable notes.

Do not:
- summarize away important details
- make notes generic
- remove opinions just because they repeat

Output final cleanup summary.

