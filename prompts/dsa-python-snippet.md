# DSA Python snippet prompt

Copy-paste the prompt below into ChatGPT. Change **only the first line** after `DSA CONCEPT:`.

````text
DSA CONCEPT: STACK

Treat this message as self-contained. The text after `DSA CONCEPT:` is the only user-provided variable. Use that value as the algorithm/data structure/concept everywhere below.

TASK
Generate exactly TWO separate snippets that teach how this DSA is used in LeetCode-style problem solving.

The output is intended to be copied into Apple Freeform on iOS, so formatting must be simple and stable.

GOAL
Teach a reusable problem-solving pattern, not the solution to a particular known problem.

GENERIC EXAMPLE — CRITICAL
- Do NOT reproduce or closely paraphrase a specific well-known LeetCode solution.
- Do NOT mention LeetCode problem numbers or titles.
- Use a small synthetic example created only to demonstrate the reusable technique.
- Prefer generic values, nodes, tasks, states, intervals, events, or positions.
- The example must transfer naturally to many problems.
- For `STACK`, prefer a generic deferred-work / iterative DFS / backtracking-state pattern over matching-brackets examples unless parsing is explicitly requested.

NORMAL VS SPECIALIZED VARIANTS
Do not silently turn the requested concept into a specialized variant.
Examples:
- `STACK` means a normal LIFO stack; values may be unsorted.
- `MONOTONIC STACK` must maintain its monotonic invariant.
- `QUEUE` must preserve FIFO order.
- `HEAP` must preserve heap order.
If a variant is specified in `DSA CONCEPT:`, follow it exactly.

SNIPPET 1 — CODE EXAMPLE
- Output ONE fenced `python` code block.
- Python 3, standard library only unless genuinely necessary.
- Keep it compact and runnable.
- Demonstrate one canonical reusable technique for this DSA.
- Include concise inline comments explaining WHY each important operation is done.
- Comments must explain the stored state, invariant, deferred work, or decision point — not merely restate the code.
- Clearly explain in comments what each pushed/stored element represents.
- Use a tiny synthetic input, usually 4-8 values/nodes/states.
- Show a small output only if it helps understanding.
- No prose before or after this code block except Snippet 2 below.

SNIPPET 2 — WHEN TO THINK OF IT
Immediately after the code block, output normal proportional-font text, NOT another code block.

Use exactly this heading:
When to think of it

Under it, write 2-4 short bullet points describing recognition signals for this DSA in a new problem.
Focus on mechanism, not a named problem.
Examples of the right abstraction level:
- I need the most recently deferred state first.
- I need to return to the latest unfinished choice.
- I repeatedly need the best-priority candidate.
- I need FIFO processing in discovery order.

Do not add `What to notice`, `Complexity`, a conclusion, or any third section.

POPULAR TECHNIQUE GUIDANCE
Choose one reusable pattern, for example:
- stack -> iterative DFS, deferred states, backtracking context, undo/history
- monotonic stack -> unresolved candidates resolved by a later value
- queue -> BFS / discovery-order processing
- deque -> useful candidates maintained at both ends
- heap -> repeatedly retrieve the best/current-priority candidate
- hash map -> remember prior information for O(1)-average lookup
- set -> membership / duplicate-state detection
- two pointers -> move two positions according to an invariant
- sliding window -> maintain state for one contiguous moving range
- prefix sum -> answer repeated range aggregation using prefix differences
- union-find -> dynamically merging connected components
- trie -> prefix state while consuming characters

OUTPUT FORMAT — EXACTLY TWO SNIPPETS

```python
# runnable generic example with explanatory comments
```

When to think of it
- recognition signal
- recognition signal
- optional recognition signal

Nothing else.
````
