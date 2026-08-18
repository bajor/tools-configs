# DSA Python snippet prompt

Copy-paste the prompt below into ChatGPT. Change **only the first line** after `DSA CONCEPT:`.

```text
DSA CONCEPT: STACK

Treat this message as self-contained. The text after `DSA CONCEPT:` is the only user-provided variable. Use that value as the algorithm/data structure/concept everywhere below.

TASK
Generate ONE compact, runnable Python snippet that teaches how the DSA concept named above is actually used in LeetCode-style problem solving.

The response must contain:
1. a minimal Python representation / implementation of the concept,
2. a tiny concrete example showing the important operations,
3. ONE popular, general problem-solving technique that uses this concept,
4. clear recognition signals for WHEN to think about using this concept,
5. a short complexity summary.

GOAL
Teach the reusable pattern, not the solution to a particular problem. The reader should finish knowing what the DSA does, what kind of state it stores, and what clues in a new problem suggest using it.

GENERIC EXAMPLE — CRITICAL
- Do NOT reproduce or closely paraphrase the solution to a specific well-known LeetCode problem.
- Do NOT mention LeetCode problem numbers or titles.
- Do NOT choose an example whose main value is memorizing one famous solution.
- Use a small synthetic input created only to demonstrate the reusable technique.
- Prefer generic structures such as arbitrary values, nodes, tasks, states, intervals, or events.
- The example should transfer naturally to many different problems.
- Explain the pattern without revealing a problem-specific trick.

CODE REQUIREMENTS
- Python 3.
- Standard library only unless the concept genuinely requires otherwise.
- Keep the code small enough to understand at a glance.
- Use descriptive variable names.
- Include concise inline comments that explain the technique and WHY each important operation is performed.
- Comments must explain the algorithmic idea, invariant, stored state, or decision point — not merely restate the code.
- Clearly comment what each pushed/stored element represents and why it can later be removed or processed.
- Show actual input and output where useful.
- Do not hide the important operation behind an unnecessary helper/library abstraction.
- If Python already has a natural representation for the structure, use it instead of reimplementing it from scratch unless an implementation is necessary to explain the mechanism.
- Use a tiny example, usually 4-8 values/nodes/states.
- Ensure every operation and output is correct.

NORMAL VS SPECIALIZED VARIANTS
Do not silently turn the requested concept into a specialized variant.
Examples:
- `STACK` means a normal LIFO stack; values may be unsorted.
- `MONOTONIC STACK` must explicitly maintain its monotonic invariant.
- `QUEUE` must preserve FIFO order.
- `HEAP` must preserve heap order.
If a variant is specified in `DSA CONCEPT:`, follow it exactly.

POPULAR TECHNIQUE
Demonstrate ONE common reusable technique where this DSA is useful. Choose a pattern rather than a particular famous problem.

Examples of suitable generic patterns:
- stack -> iterative DFS, backtracking/deferred states, nested context, undo/history
- monotonic stack -> maintain unresolved candidates until a later value resolves them
- queue -> BFS / process work in discovery order
- deque -> maintain useful candidates at both ends of a moving region
- heap -> repeatedly retrieve the best/current-priority candidate
- hash map -> remember previously seen information for O(1)-average lookup
- set -> membership / duplicate-state detection
- two pointers -> move two positions according to an invariant
- sliding window -> maintain state for one contiguous moving range
- prefix sum -> transform repeated range aggregation into prefix differences
- union-find -> maintain dynamically merging connected components
- trie -> maintain prefix state while consuming characters
- graph -> generic traversal/frontier processing as appropriate

Do not force these examples if another reusable pattern is more canonical for the requested concept.

For `STACK`, prefer a generic iterative DFS/backtracking/deferred-work example over matching-brackets-style examples, unless the user explicitly requests parsing or brackets.

RECOGNITION SIGNALS
Include a short section explaining 2-4 clues that should make someone consider this DSA in a new problem.
Focus on mechanism, for example:
- "I need the most recently deferred state first"
- "I need to return to the latest unfinished choice"
- "I repeatedly need the current minimum/maximum"
- "I need FIFO processing by discovery time"
Do not phrase these as clues tied to one specific known problem.

OUTPUT FORMAT
Return exactly these sections:

## <DSA concept>

```python
# one runnable snippet containing:
# - minimal/basic operations where useful
# - one generic popular usage technique
# - inline comments explaining WHY the technique works
```

### When to think of it
- 2-4 concise recognition signals.

### What to notice
- 2-4 concise bullets explaining the mechanism, stored state, and invariant.

### Complexity
- concise operation/pattern complexities only.

Do not include long theory, history, unrelated variants, or a full solution to a recognizable LeetCode problem.
```
