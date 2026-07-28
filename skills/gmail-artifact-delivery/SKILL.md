---
name: gmail-artifact-delivery
description: Send polished HTML-first artifacts, Markdown notes, Obsidian note bundles, reports, analyses, memos, findings, status updates, decisions, checklists, and optional attachments through the `gmail-send-to-list-only` MCP.
---

# gmail-artifact-delivery

Use the `gmail-send-to-list-only` MCP as the single delivery channel for structured work products, rendered notes, and useful attachments.

## Core Rule

- The email is a transport container for the artifact.
- Default to a note, report, analysis, memo, brief, status, decision record, checklist, rendered Markdown note bundle, or structured link collection.
- Do not turn the content into a conventional conversational email unless the user explicitly asks for that style.
- Use this skill instead of a separate note-sending skill when the user asks to email Markdown notes, Obsidian folders, or selected note files.

## HTML-First Default

- Treat `body_html` as the primary output format unless the user explicitly asks for plain text only.
- Send visually polished, email-safe HTML by default: centered container, clear title hierarchy, readable line length, generous spacing, subtle borders, card-like sections where useful, and mobile-friendly widths.
- Use inline CSS only. Do not use external stylesheets, JavaScript, forms, iframes, or embedded media players.
- For link-heavy artifacts, use cards with a prominent clickable title, a short explanation, and a clear call-to-action link or button.
- When linking to YouTube or other video pages, embed a clickable thumbnail image when a stable thumbnail URL is available. Make the thumbnail, title, and button normal links because email clients usually block embedded video players.
- Keep colors restrained and accessible: high-contrast text, light backgrounds, and one accent color for buttons or important links.
- Do not let visual polish replace substance; the HTML design should make the artifact easier to scan, not shorter or vaguer.
- If the MCP schema requires `body_text`, provide only the minimal readable fallback needed for deliverability: title, one-line purpose, and the essential URLs or attachment names. Do not duplicate the full artifact in plain text unless the user asks for it.

## Writing Style

- no greeting unless explicitly requested
- no small talk or pleasantries
- no phrases such as "I hope you're well", "just wanted to", "please find below", or similar filler
- no closing or sign-off unless explicitly requested
- start immediately with the purpose, conclusion, title, or most important result
- use formal, precise, neutral language
- prefer dense, useful information over politeness padding
- use headings, bullets, tables, and numbered lists when they improve scanning
- make the artifact self-contained enough to understand without prior chat context
- distinguish facts, assumptions, risks, decisions, recommendations, and next actions when relevant

## Artifact Shapes

Choose the shape that best fits the task. Do not force headings when a simpler structure is clearer.

Analysis:
- Summary
- Findings
- Evidence / reasoning
- Risks or uncertainties
- Recommendation

Report:
- Objective
- Current state / result
- Important details
- Issues / risks
- Next actions

Notes:
- Topic / context
- Key points
- Decisions
- Open questions
- Actions

Brief / recommendation:
- Situation
- Assessment
- Recommendation
- Consequences / tradeoffs

Rendered notes:
- Source notes
- Table of contents when rendering multiple notes
- Rendered note sections in the intended reading order
- Source links or attachment list when useful

## Markdown And Obsidian Notes

When the user asks to send Markdown notes, an Obsidian note folder, or selected note files:

1. Identify source notes.
   - Prefer the current working directory when it contains the requested notes.
   - Use `Glob` for `*.md` and inspect index or README files before choosing order.
   - Exclude generated files, visual sidecars, archives, templates, and unrelated notes unless the user asks for them.

2. Determine document order.
   - Prefer README/index first.
   - Put overview, checklist, shared brief, strategy, RFQ documents, contact lists, and analysis in a logical reading order when those document types exist.
   - Preserve original note facts; do not rewrite source content while rendering unless the user explicitly asks for summarization or editing.

3. Render Markdown as polished email HTML.
   - Preserve headings, lists, tables, code spans, code fences, and links.
   - Convert Obsidian wikilinks to readable labels when the email renderer does not support them natively.
   - Render Obsidian embeds as readable references unless the referenced asset is intentionally attached.
   - Add a compact table of contents when rendering multiple notes.
   - Keep generated HTML, renderer scripts, screenshots, PDFs, and scratch files outside the notes repository, preferably under `/tmp/opencode/<task-name>`.

4. Cleanup.
   - Do not commit generated HTML, PDFs, screenshots, or temporary renderer scripts.
   - Delete generated intermediate files after sending unless the user asked to keep them.
   - Never move generated files into the source notes folder.

## Attachments

- The MCP supports `body_text`, optional `body_html`, and optional `attachments` to allowed recipients.
- The MCP does not support drafts, replies, Cc, Bcc, raw MIME, or arbitrary recipients.
- Attach files when they add value or when the user asks for them: source Markdown files, PDFs, images, diagrams, spreadsheets, data files, or generated artifacts.
- Do not attach a PDF by default when the HTML body already contains the useful content.
- If the user asks for a PDF, generate it outside the source repository and attach it only when the MCP accepts the file from an allowed attachment root.
- Do not write "see attached" as the only useful content; the HTML body must state what is attached and why it matters.
- Before sending, verify each attachment is necessary, accessible to the MCP, and not a duplicate of content already readable in the HTML body unless the user requested that duplicate.

## Subject Line

- Make it specific and informative.
- Describe the artifact and topic, not the social act of emailing.
- Prefer forms such as `Analysis: <topic>`, `Report: <topic>`, `Notes: <topic>`, or `Decision: <topic>` when appropriate.
- Avoid vague subjects such as `Hello`, `Update`, `Quick question`, or `FYI` unless the user explicitly wants them.

## Recipient Handling

1. Use `gmail_list_allowed_recipients` when the requested recipient has not already been unambiguously mapped to an allowed recipient ID in the current task.
2. Never invent or guess an email address or recipient ID.
3. Pass only allowed recipient IDs to `gmail_send_email`.
4. Remember that recipients selected in one send are all visible together in `To`. Send separately when recipients must not see one another.

## Sending Rules

- Call `gmail_send_email` only when the user explicitly asks to send, email, or deliver the artifact now.
- If the user asks only to prepare, draft, write, or review content, do not send it.
- Put the artifact directly in `body_html` whenever practical.
- Use a minimal `body_text` fallback only when required by the MCP schema or explicitly requested.
- Add attachments only when useful or explicitly requested.
- Before sending, verify recipient IDs, subject, HTML body, minimal fallback, attachments, and that conversational filler has not crept in.
- Sending is immediate and non-idempotent. Do not automatically retry after a timeout or ambiguous transport failure; report the uncertainty and require checking Gmail Sent before any resend.

## Acceptance Criteria

- The email body is polished HTML by default.
- The plain-text fallback is minimal unless the user asks for full plain text.
- Markdown and Obsidian notes can be rendered directly in the HTML body.
- Attachments are supported and included when useful or requested.
- Source notes are not modified unless the user separately requested note edits.
- Generated intermediate files are kept outside source repositories and cleaned up when applicable.
