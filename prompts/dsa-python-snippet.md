# DSA Python snippet prompt

Copy-paste the prompt below into ChatGPT. Change **only the first line** after `DSA CONCEPT:`.

````text
DSA CONCEPT: STACK

Treat this message as self-contained. The text after `DSA CONCEPT:` is the only user-provided variable. Use that value as the algorithm/data structure/concept everywhere below.

TASK
Generate exactly THREE separate snippets that teach how this DSA is used in LeetCode-style problem solving.

The output is intended to be copied into Apple Freeform on iOS, so formatting must be simple and stable.

GOAL
Teach a reusable problem-solving pattern, not the solution to a particular known problem. Give the synthetic example a light real-world flavor so the mechanism is easier to remember.

GENERIC EXAMPLE — CRITICAL
- Do NOT reproduce or closely paraphrase a specific well-known LeetCode solution.
- Do NOT mention LeetCode problem numbers or titles.
- Use a small synthetic example created only to demonstrate the reusable technique.
- Give the example a simple real-world setting that naturally matches the DSA mechanism, such as rooms, tasks, deliveries, browser history, folders, jobs, roads, customers, containers, or events.
- The real-world setting is only a memory aid. Keep the algorithmic structure explicit and transferable to abstract problems.
- Do NOT force an analogy that changes the real behavior of the DSA.
- Avoid cute stories, long narratives, fictional characters, or decorative details.
- Prefer short domain names in code such as `rooms`, `tasks`, `routes`, `jobs`, `history`, `next_stops`, or `pending_work` instead of meaningless `A`, `B`, `x`, `state1` when a natural real-world name exists.
- The example must still transfer naturally to many problems.
- For `STACK`, prefer a generic deferred-work / iterative DFS / backtracking-state pattern with a realistic setting, such as exploring connected rooms, nested folders, or deferred repair tasks, over matching-brackets examples unless parsing is explicitly requested.

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
- Use a small real-world-flavored synthetic example whose physical/logical behavior genuinely matches the technique.
- Include concise inline comments explaining WHY each important operation is done.
- Comments must explain the stored state, invariant, deferred work, or decision point — not merely restate the code.
- Clearly explain in comments what each pushed/stored element represents.
- Keep comments algorithmic even when variable names use real-world flavor.
- Use a tiny input, usually 4-8 values/nodes/states.
- Show a small output only if it helps understanding.
- No prose before or after this code block except Snippet 2 and Snippet 3 below.

SNIPPET 2 — WHEN TO THINK OF IT
Immediately after the code block, output normal proportional-font text, NOT another code block.

Use exactly this heading:
When to think of it

Under it, write 2-4 short bullet points describing recognition signals for this DSA in a new problem.
Focus on the abstract mechanism, NOT the real-world example, so the recognition clues transfer to LeetCode-style problems.
Examples of the right abstraction level:
- I need the most recently deferred state first.
- I need to return to the latest unfinished choice.
- I repeatedly need the best-priority candidate.
- I need FIFO processing in discovery order.

Do not add `What to notice`, `Complexity`, or a conclusion.

SNIPPET 3 — FULL DRY RUN
Immediately after Snippet 2, output ONE separate fenced `text` code block that dry-runs the exact example from Snippet 1.

Use a compact execution-trace style like this:
- Begin with `START`.
- Show the important initial data structures directly underneath.
- Then show each loop iteration or processing step in execution order using the loop/index/current-value variables from the code, for example `i = 2, size = 6` or `room = kitchen`.
- Under each step, show the actual checks, comparisons, pushes, pops, skips, updates, or pointer moves one after another in the exact order they execute.
- Write comparisons explicitly when useful, for example `4 < 6 ? yes`.
- After the operations for that step, show the resulting important data structures.
- Separate consecutive iterations with a line containing exactly `----------`.
- End with `FINAL`, then show the final result/state.

Do NOT use artificial labels such as:
- `Iteration 1`
- `state before:`
- `current:`
- `action:`
- `state after:`

The trace should read like a human manually stepping through the code, not like a generic logging template.

Additional dry-run requirements:
- Show EVERY loop iteration / processing step. Do not skip iterations.
- If one iteration performs several repeated operations, show every one in order.
- For a stack/queue/heap/deque, explicitly show its contents whenever they change and at the end of each outer iteration.
- For pointer/window/traversal techniques, explicitly show the relevant indices/pointers/window/frontier whenever they change.
- Show visited/seen/result/output state whenever it materially changes.
- Use exactly the same values, names, ordering, and behavior as Snippet 1.
- Do NOT use a Markdown table.
- Do NOT omit duplicate/skip/continue iterations if they really occur in the code.
- Keep blank lines between logical groups so the trace is easy to scan in Freeform.

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

OUTPUT FORMAT — EXACTLY THREE SNIPPETS

```python
# runnable generic example with light real-world flavor
# and explanatory algorithmic comments
```

When to think of it
- recognition signal
- recognition signal
- optional recognition signal

```text
START
important_state = ...
result = ...

loop/index/current = ...

check / comparison
operation
update

important_state = ...
result = ...
----------
loop/index/current = ...

check / comparison
operation
update

important_state = ...
result = ...

FINAL
result = ...
```

Nothing else.
````
