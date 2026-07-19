---
name: gmail-artifact-delivery
description: Send formal, content-first plain-text artifacts through the `gmail-send-to-list-only` MCP. Use when the user asks to email, send, or deliver notes, reports, analyses, memos, findings, status updates, decisions, checklists, or similar work products. Treat email as a transport envelope for the artifact, not as conversational correspondence.
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
- use plain-text headings, bullets, and numbered lists when they improve scanning
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
- The MCP sends plain text only. Do not imply HTML formatting, attachments, drafts, replies, Cc, or Bcc are available.
- Never write "see attached" or depend on an attachment; include the useful content directly in the body.
- Before sending, verify recipient IDs, subject, body, and that conversational filler has not crept in.
- Sending is immediate and non-idempotent. Do not automatically retry after a timeout or ambiguous transport failure; report the uncertainty and require checking Gmail Sent before any resend.

When the user says things like "send me the analysis", "email the report", or "deliver these notes", interpret the request as:
1. produce the best structured artifact for the content;
2. remove ordinary email small talk and ceremony;
3. use a precise subject;
4. send the artifact directly in the plain-text body through `gmail-send-to-list-only`.

Only use conventional email framing when the user explicitly asks for a normal email, greeting, personal note, or conversational tone.