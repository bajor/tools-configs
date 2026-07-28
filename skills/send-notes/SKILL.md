---
name: send-notes
description: Use when the user asks to render Markdown notes or an Obsidian note folder as a nicely formatted HTML email and deliver the result through the Gmail MCP, optionally with attachments when they add value.
---

# Send Notes

Render Markdown notes as a polished HTML email, keep generated artifacts out of the notes repository, and deliver the result through the available Gmail MCP.

## Trigger

Use this skill when the user asks to:

- render Markdown or Obsidian notes as a nicely formatted email;
- email notes, a rendered note bundle, or selected Markdown files;
- send notes with useful attachments when the body alone is not enough;
- send notes while keeping generated files out of the vault or repository.

## Hard Rules

- Prefer a rendered HTML email over a PDF. Generate a PDF only when the user explicitly asks for one or when a non-email use case requires fixed-page output.
- Never write generated HTML, renderer scripts, intermediate files, or generated PDFs into the source notes folder.
- Use a temporary directory outside the vault or repository, preferably `/tmp/opencode/<task-name>`.
- If a renderer cannot write to `/tmp` because of sandboxing, use a clearly temporary directory outside the vault, such as `/home/ubuntu/opencode-tmp/<task-name>`.
- Do not commit generated PDFs, generated HTML, screenshots, or temporary renderer scripts.
- Before finishing, state whether temporary files were created and whether they were deleted.
- If the user asks for deletion after delivery, delete generated intermediate files after the delivery step succeeds.

## Email Capabilities

The `gmail-send-to-list-only` MCP can send plain text, optional HTML, and optional attachments to allowed recipients. It does not support drafts, replies, Cc, Bcc, raw MIME, or arbitrary recipients.

Therefore:

- Put the rendered notes directly in `body_html` when the content makes sense as an email body.
- Always include a readable `body_text` fallback with the same essential content.
- Use attachments only when they add value: requested source Markdown files, non-inline assets, data files, or generated artifacts the user explicitly asked to receive.
- Do not attach a PDF by default. If the user asks for a PDF, generate it outside the notes repository and attach it only when the MCP accepts the file from an allowed attachment root.

## Workflow

1. Identify source notes.
   - Prefer the current working directory when it contains the requested notes.
   - Use `Glob` for `*.md` and inspect index or README files before choosing order.
   - Exclude generated files, visual sidecars, archives, templates, and unrelated notes unless the user asks for them.

2. Determine document order.
   - Prefer README/index first.
   - Put overview, sending checklist, shared brief, strategy, RFQ documents, contact lists, and analysis in a logical reading order.
   - Preserve original note content; do not rewrite facts while rendering.

3. Render Markdown cleanly as email HTML.
   - Preserve headings, lists, tables, code spans, code fences, and Obsidian wikilinks.
   - Convert wikilinks to readable labels when the email renderer does not support them natively.
   - Render Obsidian embeds as readable references unless the referenced asset is intentionally attached.
   - Add a compact table of contents when rendering multiple notes.
   - Use email-safe inline CSS: strong title hierarchy, table borders, code styling, readable line length, and mobile-friendly spacing.

4. Prepare email bodies.
   - Prefer direct Markdown-to-HTML rendering with available local tools when installed.
   - If no renderer is available, create simple semantic HTML manually from the selected notes instead of falling back to PDF.
   - Keep generated HTML and any renderer scratch files in the temporary directory.
   - Prepare `body_text` as a plain-text fallback with headings, bullets, and links readable without HTML.

5. Verify output.
   - Confirm the HTML contains the selected notes in the intended order.
   - Confirm the plain-text fallback contains the essential content.
   - Confirm no generated artifact was created inside the source notes folder.
   - Confirm each attachment is necessary, available to the MCP, and not a duplicate of content already readable in the email body.

6. Deliver by email.
   - Use `gmail_list_allowed_recipients` before sending unless the recipient ID is already known in the current task.
   - Use `gmail_send_email` only with allowed recipient IDs.
   - Send the rendered notes in `body_html` and the fallback in `body_text`.
   - Add attachments only when they are useful or explicitly requested.
   - Write a content-first artifact, not a conversational email.

7. Cleanup.
   - Delete generated intermediate files after sending unless the user asked to keep them.
   - Never move generated files into the notes folder.

## Acceptance Criteria

- The selected notes are rendered directly in the email body as HTML, with a readable plain-text fallback.
- Source notes were not modified unless the user separately requested note edits.
- No generated HTML, PDF, or temporary renderer artifact was added to the notes repository.
- Email delivery was attempted only through an allowed MCP recipient.
- Attachments were included only when useful or explicitly requested.
- The final response states email status, included notes, attachment status, and temporary-file cleanup status.
