---
name: gmail-artifact-delivery
description: Send formal, content-first artifacts through the `gmail-send-to-list-only` MCP with plain text, optional HTML, and optional attachments. Use when the user asks to email, send, or deliver notes, reports, analyses, memos, findings, status updates, decisions, checklists, or similar work products.
---

# gmail-artifact-delivery

Use the `gmail-send-to-list-only` MCP as a delivery channel for structured work products.

Core rule:
- The email is a transport container for the actual artifact.
- Default to a note, report, analysis, memo, brief, status, decision record, checklist, or other structured content.
- Do not turn the content into a conventional conversational email unless the user explicitly asks for that style.

Writing style:
- no greeting unless explicitly requested
- no small talk or pleasantries
- no phrases such as "I hope you're well", "just wanted to", "please find below", or similar filler
- no closing or sign-off unless explicitly requested
- start immediately with the purpose, conclusion, title, or most important result
- use formal, precise, neutral language
- prefer dense, useful information over politeness padding
- use headings, bullets, and numbered lists when they improve scanning
- prefer `body_html` for Markdown, notes, reports, tables, or structured artifacts that benefit from visual hierarchy
- always provide `body_text` as a readable fallback containing the same essential information
- make the artifact self-contained enough to understand without prior chat context
- distinguish facts, assumptions, risks, decisions, and recommendations when relevant

Choose the artifact shape that best fits the task. Useful defaults:

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

Do not force these headings when a simpler structure is clearer.

Subject line:
- make it specific and informative
- describe the artifact and topic, not the social act of emailing
- prefer forms such as `Analysis: <topic>`, `Report: <topic>`, `Notes: <topic>`, or `Decision: <topic>` when appropriate
- avoid vague subjects such as `Hello`, `Update`, `Quick question`, or `FYI` unless the user explicitly wants them

Recipient handling:
1. Use `gmail_list_allowed_recipients` when the requested recipient has not already been unambiguously mapped to an allowed recipient ID in the current task.
2. Never invent or guess an email address or recipient ID.
3. Pass only allowed recipient IDs to `gmail_send_email`.
4. Remember that recipients selected in one send are all visible together in `To`. Send separately when recipients must not see one another.

Sending rules:
- Call `gmail_send_email` only when the user explicitly asks to send, email, or deliver the artifact now.
- If the user asks only to prepare, draft, write, or review content, do not send it.
- The MCP supports `body_text`, optional `body_html`, and optional `attachments`. It does not support drafts, replies, Cc, Bcc, raw MIME, or arbitrary recipients.
- Put the artifact directly in the email body whenever practical. Use attachments only when they add value, such as requested source files, data files, images, or generated artifacts the user explicitly asked to receive.
- Do not write "see attached" as the only useful content; the body must explain what is attached and include the core message.
- Before sending, verify recipient IDs, subject, body, optional HTML, attachments, and that conversational filler has not crept in.
- Sending is immediate and non-idempotent. Do not automatically retry after a timeout or ambiguous transport failure; report the uncertainty and require checking Gmail Sent before any resend.

When the user says things like "send me the analysis", "email the report", or "deliver these notes", interpret the request as:
1. produce the best structured artifact for the content;
2. remove ordinary email small talk and ceremony;
3. use a precise subject;
4. send the artifact directly in `body_html` when useful, with a readable `body_text` fallback through `gmail-send-to-list-only`.

Only use conventional email framing when the user explicitly asks for a normal email, greeting, personal note, or conversational tone.
