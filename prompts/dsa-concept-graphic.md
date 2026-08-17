# DSA concept graphic prompt

Copy-paste the prompt below into ChatGPT. Change **only the first line** after `DSA CONCEPT:`.

```text
DSA CONCEPT: MONOTONIC STACK

Treat this message as self-contained. The text after `DSA CONCEPT:` is the only user-provided variable. Use that value as the algorithm/data structure/concept everywhere below.

TASK
Generate ONE educational diagram that explains the DSA concept named above.

Generate the diagram immediately. The response to this message should be the diagram, not a plan, explanation, rewritten prompt, confirmation, or clarification question.

GOAL
Make the concept understandable almost entirely from the picture. Use a simple physical analogy that matches the actual mechanism of the concept, not merely its appearance.

Before generating the diagram, reason through the concept internally and choose one small concrete example whose states are algorithmically correct. Verify every value, ordering, push/pop/move, pointer, comparison, transition, and final state. The labels and visible objects MUST match exactly.

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
- no paragraphs inside the diagram
- prefer labels, arrows, numbers, and state transitions

LAYOUT
Use as many sequential stages as the concept actually requires.

Do NOT impose a fixed number of panels or steps. Prefer the smallest number of stages that preserves correctness and makes the mechanism visually obvious. A simple concept may need only a few stages; a concept with important intermediate state changes may need more.

Possible stage roles include:
- initial state
- incoming value or action
- comparison or decision
- state-changing operation
- repeated operation when required by the algorithm
- final state or result

Choose only the stages that are useful for the specific concept.

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
- If one incoming value causes several repeated operations, show every algorithmically necessary operation or combine them only when the resulting transition remains unambiguous.
- The final state must be exactly correct.
- Never invent an operation because it makes the picture look better.
- If the concept has increasing/decreasing, min/max, left/right, or similar variants and the variant is specified in `DSA CONCEPT:`, follow it exactly.

TEXT INSIDE THE DIAGRAM
- ALL text inside the generated diagram MUST be in English, regardless of the language of the surrounding chat.
- Keep text extremely short.
- Prefer labels like `start`, `push 5`, `pop 2`, `left`, `right`, `current`, `result`.
- No explanatory paragraphs.
- At most one short English sentence summarizing the invariant.

COMPOSITION
- landscape orientation
- simple visual separation between sequential stages when useful
- main visual centered or left-aligned
- small state summary on the right only when useful
- arrows clearly indicate motion or state change
- removed/rejected objects may move to a small `OUT` area and use red outlines/arrows
- large readable numeric labels

The result should look like a clean textbook/whiteboard teaching diagram designed for manual tracing, NOT like a polished marketing infographic.

FINAL INTERNAL CHECK
1. Does the analogy faithfully model the real mechanism?
2. Do all visible values exactly match the intended state?
3. Are all transitions valid?
4. Are all algorithmically necessary intermediate operations represented clearly?
5. Is the final state correct?
6. Is every piece of text inside the diagram in English?
7. Are there any shadows, gradients, decoration, or unnecessary text? Remove them.

Generate the diagram now.
```