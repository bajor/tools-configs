---
name: send-notes
description: Use when the user asks to turn Markdown notes or an Obsidian note folder into one nicely rendered temporary PDF and deliver the result by email through the Gmail MCP.
---

# Send Notes

Create one polished PDF from Markdown notes, keep generated artifacts out of the notes repository, and deliver the result through the available Gmail MCP.

## Trigger

Use this skill when the user asks to:

- make one big PDF from notes;
- render Markdown or Obsidian notes as a PDF;
- email notes, a rendered note bundle, or a note PDF;
- send notes while keeping generated files out of the vault or repository.

## Hard Rules

- Never write generated PDFs, generated HTML, renderer scripts, or intermediate files into the source notes folder.
- Use a temporary directory outside the vault or repository, preferably `/tmp/opencode/<task-name>`.
- If a renderer cannot write to `/tmp` because of sandboxing, use a clearly temporary directory outside the vault, such as `/home/ubuntu/opencode-tmp/<task-name>`.
- Do not commit generated PDFs, generated HTML, screenshots, or temporary renderer scripts.
- Before finishing, state exactly where the temporary PDF is located or confirm that it was deleted.
- If the user asks for deletion after delivery, delete the generated PDF and intermediate files after the delivery step succeeds.

## Email Constraint

The `gmail-send-to-list-only` MCP sends plain-text email only. It does not support attachments, HTML email, drafts, replies, Cc, Bcc, or raw MIME.

Therefore:

- Do not claim that a PDF was attached unless a different attachment-capable tool is available and was used.
- When only `gmail-send-to-list-only` is available, send a plain-text delivery report that includes the local PDF path, source folder, generated filename, included note list, and any limitation.
- If the user requires a real PDF attachment, stop and ask for an attachment-capable delivery method.

## Workflow

1. Identify source notes.
   - Prefer the current working directory when it contains the requested notes.
   - Use `Glob` for `*.md` and inspect index or README files before choosing order.
   - Exclude generated files, visual sidecars, archives, templates, and unrelated notes unless the user asks for them.

2. Determine document order.
   - Prefer README/index first.
   - Put overview, sending checklist, shared brief, strategy, RFQ documents, contact lists, and analysis in a logical reading order.
   - Preserve original note content; do not rewrite facts while rendering.

3. Render Markdown cleanly.
   - Preserve headings, lists, tables, code spans, code fences, and Obsidian wikilinks.
   - Convert wikilinks to readable labels when the PDF renderer does not support them natively.
   - Add a cover page and table of contents when rendering multiple notes.
   - Use readable A4 styling: strong title hierarchy, table borders, code styling, page breaks between notes, and sufficient margins.

4. Generate PDF outside the notes repository.
   - Prefer `pandoc` when installed.
   - If `pandoc` is unavailable but Chromium is installed, generate temporary HTML and print it with headless Chromium.
   - Keep all generated files in the temporary directory.

5. Verify output.
   - Check that the PDF exists and has a non-zero size.
   - If possible, inspect page count with `pdfinfo`.
   - Confirm that no PDF was created inside the source notes folder.

6. Deliver by email.
   - Use `gmail_list_allowed_recipients` before sending unless the recipient ID is already known in the current task.
   - Use `gmail_send_email` only with allowed recipient IDs.
   - Write a plain-text artifact, not a conversational email.
   - Include the exact PDF path and the attachment limitation if using the plain-text-only MCP.

7. Cleanup.
   - If the user explicitly requires local deletion after sending and the delivery method actually included the PDF content, delete the generated PDF and intermediate files.
   - If the available MCP could not attach the PDF, keep the PDF only in the temporary directory unless the user explicitly says to delete it immediately.
   - Never move the PDF into the notes folder.

## Acceptance Criteria

- One PDF exists or existed in a temporary directory outside the notes repository.
- Source notes were not modified unless the user separately requested note edits.
- No generated PDF or temporary renderer artifact was added to the notes repository.
- Email delivery was attempted only through an allowed MCP recipient.
- The final response states the PDF path or deletion status, email status, and any delivery limitation.
