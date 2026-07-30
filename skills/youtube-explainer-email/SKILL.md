---
name: youtube-explainer-email
description: Find YouTube videos that explain a requested topic, using the current folder or provided notes for context when available, then send a polished HTML watchlist email through the `gmail-send-to-list-only` MCP with embedded clickable links and explanations.
---

# youtube-explainer-email

Find useful YouTube explainers for a topic, folder, or set of notes, explain why each video is worth watching, and deliver the watchlist as a polished HTML email through the Gmail MCP.

## Trigger

Use this skill when the user asks to:

- find YouTube videos, clips, explainers, tutorials, comparisons, reviews, lectures, or walkthroughs for a topic;
- use notes in the current folder to choose videos that explain the decisions, equipment, concepts, or tradeoffs in those notes;
- send or email a watchlist with links to videos;
- explain why each video should be watched and what the user will learn from it;
- produce a clickable HTML email containing YouTube links, thumbnails, and short guidance.

Example requests:

- "find videos explaining the gear in this folder and email them to me"
- "send me YouTube explainers for this topic"
- "znajdz filmiki na YT tlumaczace te sprzety i wyslij mailem"
- "make a watchlist from these notes and email it"

## Core Outcome

The delivered email must answer three questions clearly:

1. What should I watch?
2. Why is this video relevant to the topic or notes?
3. What decision, concept, or tradeoff will I understand after watching it?

## Source Context Workflow

1. Identify the source context.
   - If the user names a folder, inspect that folder first.
   - If the current working directory contains relevant notes, inspect the most likely README, index, overview, recommendation, decision, RFQ, or analysis files first.
   - Use `Glob` for Markdown files and `Grep` for key terms when the folder is large.
   - Do not read unrelated notes unless needed to understand the requested topic.

2. Extract search targets.
   - Identify concrete concepts, products, brands, model names, decisions, and tradeoffs.
   - Prefer search targets that match the user's decision problem, not just isolated nouns.
   - Examples: `split vs monoblok pompa ciepla`, `Komfovent CF ER vs R400 wymiennik obrotowy`, `Mini VRF vs multi split`, `klimatyzacja kanalowa vs scienna`.

3. Decide the watchlist shape.
   - For a narrow topic, choose 3-5 videos that explain the same topic in different ways.
   - For a folder with multiple decisions, choose 5-9 videos grouped by decision area.
   - Prefer a mix of explanation, comparison, installation/walkthrough, and expert/practical perspective when available.
   - Avoid padding the list with weak videos.

## YouTube Search Workflow

1. Search the web for YouTube results.
   - Use YouTube search when it returns usable results.
   - If YouTube search pages are blocked or too generic, use a search engine query such as `site:youtube.com <topic> porownanie`, `site:youtube.com <topic> explained`, or `site:youtube.com <model> review`.
   - Search in the language that best matches the user's notes and request. Add English searches when Polish results are weak or the topic is technical.

2. Verify each candidate before including it.
   - Include only URLs that appear to be actual YouTube watch, shorts, playlist, or channel/video pages.
   - Prefer direct video URLs over search result URLs.
   - Use the available title/snippet/date/channel information to judge relevance.
   - Do not invent titles, channels, durations, publication dates, or claims that were not visible in search results or page content.

3. Select for diversity and usefulness.
   - Choose videos that explain different angles: basics, comparison, practical installation, mistakes, sizing, setup, maintenance, or decision tradeoffs.
   - Prefer videos that map directly to the user's notes or decision criteria.
   - Avoid multiple near-duplicate videos unless each has a distinct reason to watch.
   - Flag vendor or installer videos as potentially biased when relevant, but do not reject them automatically if they show useful product details.

## Watchlist Item Format

For each included video, write:

- Title: the visible video title or a careful descriptive label based on the visible search result.
- Link: the direct YouTube URL.
- Why watch: one short paragraph tied to the user's topic, notes, products, or decision.
- What you will learn: one short paragraph or 2-3 bullets naming the concrete concept, comparison, risk, or choice the video clarifies.
- Optional note: bias, uncertainty, language, or why the video is a supporting reference rather than a final recommendation.

## HTML Email Requirements

- Send a polished `body_html` email by default.
- Use inline CSS only. Do not use JavaScript, external stylesheets, forms, iframes, or embedded YouTube players.
- Use a centered container, readable line length, clear headings, card-like sections, subtle borders, and mobile-friendly widths.
- For every video card, make the title, thumbnail if present, and button clickable.
- For YouTube watch URLs, use the stable thumbnail pattern when possible: `https://img.youtube.com/vi/<VIDEO_ID>/hqdefault.jpg`.
- If the video ID is not clear, skip the thumbnail and use a prominent text link/button.
- Include a short intro that states what source notes or topic were used.
- Include a closing "How to watch" or "Watch order" section when order matters.
- Keep plain text minimal when the MCP requires `body_text`: title, one-line purpose, and the list of URLs. Do not duplicate the full HTML artifact unless the user asks for full plain text.

## Gmail MCP Rules

- Use `gmail_list_allowed_recipients` when the recipient ID is not already known in the current task.
- Use `gmail_send_email` only with allowed recipient IDs.
- The MCP supports `body_text`, optional `body_html`, and optional `attachments`.
- Attachments are usually unnecessary for a watchlist, but may be included if the user asks for source notes, a generated report, images, PDFs, or other files.
- Sending is immediate and non-idempotent. Do not retry automatically after an ambiguous transport failure; ask the user to check Gmail Sent first.

## Quality Bar

- The list must be tailored to the user's topic or folder, not a generic YouTube dump.
- Every video must have a clear reason to watch.
- Every explanation must connect back to the user's decision, equipment, concept, or tradeoff.
- The email must be pleasant to scan on desktop and mobile.
- The final response must state the recipient, subject, number of videos sent, and PR/local-install status when relevant.

## Acceptance Criteria

- Source notes or topic were inspected before searching when available.
- Searches produced direct YouTube links or clearly labeled YouTube pages.
- The selected videos cover the topic from multiple useful angles.
- The email was sent as polished HTML with clickable links.
- The minimal text fallback contains the essential URLs.
- No video facts were invented beyond visible search/page evidence.
