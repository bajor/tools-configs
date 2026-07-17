---
name: visual-note-refactor
description: "Transform existing Markdown notes into visual-first notes optimized for comprehension, navigation, and recall. Use when the user asks to augment, refactor, or create sidecar versions of Markdown notes, note sets, or note folders with visual summaries, Mermaid diagrams, callouts, comparison tables, recall questions, or Obsidian-friendly structure while preserving original meaning and technical accuracy."
---

# Visual Note Refactor

## Core Contract

Transform existing Markdown notes into visual-first notes optimized for comprehension, navigation, and recall.

Preserve the original meaning and technical accuracy. You may reorganize, summarize, and visualize information, but you must not invent facts, dependencies, chronology, causal relationships, quantities, actors, states, or technical claims.

## Inputs

Accept:

- One Markdown note
- A set of Markdown notes
- A folder of Markdown notes
- Optional target application, especially `obsidian`
- Refactoring mode: `sidecar`, `augment`, or `refactor`
- Visual density: `low`, `medium`, or `high`
- Intended use: `learning`, `reference`, `project`, `architecture`, or `research`

Defaults:

- Mode: `sidecar`
- Visual density: `medium`
- Target application: infer `obsidian` when the source uses wikilinks, embeds, properties/frontmatter, or Obsidian callouts
- Intended use: infer from note content only when obvious; otherwise use `reference`

## Modes

### sidecar

Do not modify the original note.

Create a sibling visual note:

- Source: `Original note.md`
- Output: `Original note.visual.md`

For folder inputs, preserve the source folder layout where practical and create one `.visual.md` file per processed `.md` file. This is the default and safest mode.

### augment

Keep the existing note structure. Add only useful visual scaffolding:

- A visual summary
- Callouts
- Diagrams where useful
- Comparison tables
- Recall questions

Do not reorder existing sections unless the user explicitly asks.

### refactor

Reorganize the complete note into a visual-first structure while preserving all relevant information.

Use this mode only when requested, or when the user explicitly asks for a complete rewrite of the note structure.

## Processing Pipeline

1. Parse Markdown structure: frontmatter, headings, paragraphs, lists, tables, links, code blocks, blockquotes, citations, embeds, and existing diagrams.
2. Identify the source facts: main subject, key concepts, relationships, processes, actors, chronology, states, comparisons, quantitative data, examples, warnings, and exceptions.
3. Classify each section by information pattern: concept, process, interaction, state, timeline, task plan, entity model, type model, system architecture, comparison, cause analysis, quantity flow, example, warning, or reference material.
4. Select the smallest useful visualization for each visual opportunity.
5. Generate one visual overview near the top of the note.
6. Reorganize prose into short semantic sections.
7. Add callouts only for high-value information: assumptions, requirements, constraints, warnings, exceptions, decisions, examples, and uncertainties.
8. Preserve code, command blocks, quotations, citations, source links, frontmatter, embeds, and internal links.
9. Validate Mermaid syntax using an available renderer when one is already installed. If no renderer is available, inspect Mermaid syntax manually and report that validation was manual.
10. Produce a change report and uncertainty warnings.

## Diagram Selection

Use the smallest useful diagram. Prefer no diagram over a diagram that implies unsupported structure.

- Use a flowchart when the source contains ordered operations, decisions, conditional branches, or causes leading to outcomes.
- Use a sequence diagram when the source contains multiple actors or components, requests and responses, events ordered over time, API interactions, or protocol interactions.
- Use a state diagram when the source describes a finite set of states, events that cause transitions, or valid and invalid transitions.
- Use a mind map when the source contains one central topic with hierarchical subtopics, taxonomies, or categories.
- Use a timeline when dates or periods are important and dependencies are not the primary concern.
- Use a Gantt chart when tasks have durations, task dependencies, milestones, or scheduling constraints.
- Use an ER diagram when entities have attributes and relationships have cardinality.
- Use a class diagram when types, interfaces, inheritance, or structural relationships are described.
- Use an architecture or block diagram when the note describes system components and data or control crosses component boundaries.
- Use a quadrant chart when items are compared against two explicit dimensions.
- Use an Ishikawa diagram when the note investigates causes of a single problem.
- Use a Sankey diagram only when numeric quantities move between categories and the quantities are available in the source.

Never invent quantities to create a chart.

## Visual Hierarchy

When applicable, structure generated notes in this order:

```markdown
# Title
> [!abstract] At a glance
> Three to six lines describing the central idea.

## Visual overview
One Mermaid diagram or one compact visual table.

## Key concepts
Short definitions and relationships.

## How it works
Detailed explanation, diagrams, and examples.

## Comparison
A table or quadrant diagram when useful.

## Edge cases and limitations
Warnings, exceptions, and failure conditions.

## Practical example
A concrete example preserving source details.

## Recall
Questions that test relationships and application rather than simple recognition.

## Related notes
Internal Obsidian links.
```

Omit sections that do not apply. Do not create empty sections.

## Visual Density

- `low`: one visual overview, sparse callouts, few or no recall questions.
- `medium`: one visual overview, section-level callouts where useful, compact tables, and three to seven recall questions.
- `high`: one visual overview plus additional section diagrams or tables for dense material, stronger callout coverage, and five to twelve recall questions.

Even at high density, avoid visual noise. Prefer compact diagrams of about 5 to 12 nodes or steps when the source supports it. Split larger diagrams by concern instead of making one unreadable diagram.

## Intended Use

- `learning`: emphasize definitions, progressive explanation, examples, and recall questions.
- `reference`: emphasize stable headings, quick lookup tables, constraints, and source links.
- `project`: emphasize actors, tasks, decisions, dependencies, risks, and next actions that already exist in the source.
- `architecture`: emphasize components, boundaries, data flow, control flow, interfaces, and failure modes stated by the source.
- `research`: emphasize sources, claims, confidence, evidence, open questions, and uncertainty warnings.

## Obsidian Handling

When the target application is `obsidian`:

- Preserve YAML frontmatter exactly unless the user asks to change it.
- Preserve wikilinks, aliases, embeds, tags, and block references.
- Use Obsidian callouts such as `[!abstract]`, `[!note]`, `[!tip]`, `[!warning]`, `[!example]`, `[!question]`, and `[!cite]`.
- Put internal links in `## Related notes` when the relationship is present in the source.
- Do not replace wikilinks with standard Markdown links unless the user asks.

## Preservation Rules

Always preserve:

- Code blocks and inline code
- Shell commands and flags
- API names, type names, identifiers, paths, versions, dates, units, and numeric values
- Tables, citations, footnotes, blockquotes, and source links
- Existing warnings, caveats, constraints, exceptions, and open questions

When summarizing, preserve the source meaning. If compression loses an important qualifier, keep the qualifier.

## Uncertainty Rules

If a relationship, chronology, dependency, or cause is ambiguous:

- Do not encode it as definite in a diagram.
- Add an uncertainty warning near the relevant section.
- State exactly what is known from the source and what is not established.

Use this callout pattern:

```markdown
> [!warning] Uncertainty
> The source states X and Y, but does not establish whether X caused Y.
```

## Recall Questions

Write recall questions that test application and relationships, not simple recognition.

Prefer questions like:

- "What condition causes this process to take the fallback path?"
- "Which component owns this responsibility, and what crosses its boundary?"
- "What limitation would make this recommendation invalid?"

Avoid questions like:

- "What is the title of this note?"
- "Name one thing mentioned above."

## Validation

Before finishing:

1. Confirm every generated claim is traceable to the source note or explicitly marked as an inference.
2. Confirm every diagram type matches the source information pattern.
3. Confirm Mermaid blocks use valid diagram syntax for the selected diagram type.
4. Confirm no quantities were invented for charts.
5. Confirm original notes are unchanged in `sidecar` mode.
6. Confirm links, embeds, code blocks, citations, and frontmatter were preserved.
7. Run `git diff --check` when working inside a Git repository.

If Mermaid CLI or another local renderer is available, render or parse-check Mermaid diagrams. Do not install new dependencies only for validation unless the user approves.

## Change Report

End with a concise report listing:

- Input files processed
- Output files created or modified
- Mode, visual density, target application, and intended use
- Diagrams or visual tables added
- Source content preserved without change, especially code, citations, and links
- Uncertainty warnings added
- Validation performed
- Any validation not performed and why
