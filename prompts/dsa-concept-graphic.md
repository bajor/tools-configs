# DSA concept graphic prompt

Copy-paste the prompt below into ChatGPT. Change **only the first line** after `DSA CONCEPT:`.

```text
DSA CONCEPT: MONOTONIC STACK

The text after `DSA CONCEPT:` above is the only user-editable input. Treat that value as the algorithm/data structure/concept to explain everywhere below. Do not ask the user to repeat or substitute it anywhere else.

TASK
Create and render ONE brand-new educational image that explains the DSA concept named above.

EXECUTION MODE — CRITICAL
- This is a NEW text-to-image generation request.
- Generate the image immediately.
- Do NOT treat this as an edit of a previous image.
- Do NOT ask for a reference image, previous diagram, upload, attachment, or image target.
- Do NOT say that an image must be uploaded before you can continue.
- Ignore previous images in the conversation as edit targets unless the user explicitly says: "edit this attached image".
- Phrases such as "same style", "similar to the previous one", "like before", or contextual references to earlier diagrams describe STYLE ONLY. They must never convert this task into image editing.
- Recreate the required style entirely from the written instructions below.
- Do NOT answer with a plan, explanation, rewritten prompt, or clarification question.
- If an image-generation tool is available, CALL IT directly and return the generated image.

GOAL
Make the concept understandable almost entirely from the picture. Use a simple physical analogy that matches the actual mechanism of the concept, not merely its appearance.

Before rendering, reason through the concept internally and choose one small concrete example whose states are algorithmically correct. Verify every value, ordering, push/pop/move, pointer, comparison, transition, and final state. The labels and visible objects MUST match exactly.

VISUAL STYLE
- clean technical line drawing / engineering sketch
- white background
- black outlines
- flat 2D shapes
- NO shadows
- NO gradients
- NO textures
- NO photorealism
- NO decorative background
- minimal use of color
- green only for the new/current/successful element
- red only for removed/rejected/invalidated elements or arrows
- everything else black/white
- thick outlines, easy to manually trace from an iPad screen in Freeform
- large simple shapes
- generous spacing
- minimal text
- no paragraphs inside the image
- prefer labels, arrows, numbers, and state transitions

LAYOUT
Use 3-5 simple numbered panels showing the concept step by step.

Typical structure:
1. initial state
2. new input/action
3. key algorithm operation(s)
4. final state

Adapt this sequence when another layout explains the concept more faithfully, but keep it simple and sequential.

ANALOGY
Choose ONE physical analogy that makes the invariant or mechanism visually obvious.

Possible analogy families:
- stack -> objects physically stacked on a rod or shelf
- queue -> people or objects in a line
- monotonic stack -> different-size discs/weights where physical size encodes numeric order and incompatible top elements are removed
- heap -> physical tree or tournament hierarchy
- sliding window -> movable frame over a row
- two pointers -> two markers moving over one sequence
- binary search -> progressively narrowed search interval
- BFS -> expanding frontier/wave
- DFS -> one path explored deeply before backtracking
- union-find -> groups physically connected into components
- graph shortest path -> nodes/roads with highlighted frontier/path

Do not force these examples. Prefer a different analogy if it represents the concept named above more faithfully.

CORRECTNESS — NON-NEGOTIABLE
- Determine the exact invariant/mechanism first.
- Use a tiny example, usually 4-7 elements.
- Simulate every step internally before drawing.
- Every visible object must have the correct value/label.
- Written state and drawn state must contain EXACTLY the same elements in EXACTLY the same order.
- Example: if the state is `[9, 7, 4, 2]`, the drawing must visibly contain 9, 7, 4, and 2 in that order — no missing 7, no extra value, no reordered objects.
- If elements are removed, show only the exact elements that the algorithm removes.
- The final state must be exactly correct.
- Never invent an operation because it makes the picture look better.
- If the concept has increasing/decreasing, min/max, left/right, or similar variants and the variant is specified in `DSA CONCEPT:`, follow it exactly.

TEXT INSIDE THE IMAGE
- ALL text inside the generated image MUST be in English, regardless of the language of the surrounding chat.
- Keep text extremely short.
- Prefer labels like `start`, `push 5`, `pop 2`, `left`, `right`, `current`, `result`.
- No explanatory paragraphs.
- At most one short English sentence summarizing the invariant.

COMPOSITION
- landscape orientation
- simple panel separation
- main visual centered or left-aligned
- small state summary on the right only when useful
- arrows clearly indicate motion or state change
- removed/rejected objects may move to a small `OUT` area and use red outlines/arrows
- large readable numeric labels

The result should look like a clean textbook/whiteboard teaching diagram designed for manual tracing, NOT like a polished marketing infographic.

FINAL INTERNAL CHECK BEFORE RENDERING
1. Does the analogy faithfully model the real mechanism?
2. Do all visible values exactly match the intended state?
3. Are all transitions valid?
4. Is the final state correct?
5. Is every piece of text inside the image in English?
6. Are there any shadows, gradients, decoration, or unnecessary text? Remove them.
7. Is this being generated as a NEW image rather than treated as an edit? It must be a NEW image.

After these checks, GENERATE THE IMAGE. Do not ask for an image upload or confirmation.
```