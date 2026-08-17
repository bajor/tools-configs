# DSA concept graphic prompt

Use this prompt by replacing `{{ALGORITHM}}` with the DSA algorithm/data structure/concept you want to explain.

```text
Create a single educational diagram that explains this DSA concept:

{{ALGORITHM}}

Goal:
Make the concept understandable almost entirely from the picture. Use a simple physical analogy that matches the actual mechanism of the algorithm/data structure, not just its appearance.

Before drawing, reason through the algorithm and choose one small concrete example whose states are mathematically and algorithmically correct. Verify every value, ordering, push/pop/move, pointer, comparison, and final state before rendering. The written labels and the objects visible in the drawing MUST match exactly.

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
- thick enough outlines to be easy to trace manually from an iPad screen in Freeform
- large simple shapes with generous spacing
- minimal text
- avoid paragraphs
- prefer labels, arrows, numbers, and state transitions

LAYOUT
Use 3-5 horizontal numbered panels showing the concept step by step.

Typical structure:
1. initial state
2. a new input/action arrives
3. the algorithm performs its key operation(s)
4. final state

If the concept is better explained with another sequence, adapt the panels, but keep the diagram simple and sequential.

ANALOGY
Choose ONE physical analogy that makes the invariant/mechanism obvious.
Examples of acceptable analogy types:
- stack -> objects physically stacked on a rod/shelf
- queue -> people/objects in a line
- monotonic stack -> different-size discs/weights stacked so physical size encodes numeric order; a new disc removes incompatible discs from the top
- heap -> physical tree / tournament hierarchy
- sliding window -> movable frame over a row of objects
- two pointers -> two markers moving over one sequence
- binary search -> progressively narrowed physical search interval
- BFS -> expanding wave/frontier
- DFS -> one path explored deeply before backtracking
- union-find -> groups physically connected into components
- graph shortest path -> simple nodes/roads with highlighted frontier/path

Do NOT force any of these if another analogy represents {{ALGORITHM}} more faithfully.

IMPORTANT CORRECTNESS RULES
- First determine the exact invariant of {{ALGORITHM}}.
- Pick a tiny example, usually 4-7 elements.
- Simulate every step internally before drawing.
- Every object drawn must have the correct label/value.
- If a state says `[9, 7, 4, 2]`, the image must visibly contain exactly 9, 7, 4, 2 in that order.
- If elements are removed, show only those exact elements as removed.
- The final state must be exactly what the algorithm produces.
- Do not invent an operation merely because it makes the visual nicer.
- If the algorithm has increasing/decreasing variants, infer the requested one from the name; if explicitly specified, follow it exactly.

TEXT
- ALL text rendered inside the image MUST be in English, regardless of the language of the user's request.
- Keep text extremely short.
- Prefer labels such as:
  - `1. start`
  - `2. enters 5`
  - `3. pop 2, pop 4`
  - `4. push 5`
  - `stack: 9, 7, 5`
- Do not include explanatory paragraphs inside the image.
- At most one short English sentence at the bottom summarizing the invariant.

COMPOSITION
- landscape orientation
- each panel separated by a thin horizontal line or simple border
- main diagram centered/left
- small textual state summary on the right when useful
- arrows should clearly show direction of change
- removed objects may be moved to a small `OUT` area and outlined in red
- keep numeric/value labels large and readable

The result should look like a textbook/whiteboard teaching diagram designed for manual tracing, not like an infographic poster.

Final internal check before rendering:
1. Is the analogy faithful to the algorithm's actual mechanism?
2. Do all visible values exactly match the stated state?
3. Are all transitions valid?
4. Is the final state correct?
5. Is every piece of text inside the image in English?
6. Is there any unnecessary text, shading, decoration, or visual noise? Remove it.

Generate the image only after these checks pass.
```