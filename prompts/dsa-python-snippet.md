# DSA Python snippet prompt

Copy-paste the prompt below into ChatGPT. Change **only the first line** after `DSA CONCEPT:`.

```text
DSA CONCEPT: STACK

Treat this message as self-contained. The text after `DSA CONCEPT:` is the only user-provided variable. Use that value as the algorithm/data structure/concept everywhere below.

TASK
Generate ONE compact, runnable Python snippet that teaches how the DSA concept named above is actually used.

The response must contain:
1. a minimal Python representation / implementation of the concept,
2. a tiny concrete example showing the important operations,
3. one popular DSA/interview technique that uses this concept,
4. a short complexity summary.

GOAL
Make the concept immediately useful for solving problems. Prefer executable code and concrete state changes over theory.

CODE REQUIREMENTS
- Python 3.
- Standard library only unless the concept genuinely requires otherwise.
- Keep the code small enough to understand at a glance.
- Use descriptive variable names.
- Include concise inline comments that explain the technique and WHY each important operation is performed.
- The comments must explain the algorithmic idea, not merely restate the code.
- Comment the key state transitions, invariant, or decision points.
- Show actual input and output.
- Do not hide the important operation behind an unnecessary helper/library abstraction.
- If Python already has a natural representation for the structure, use it instead of reimplementing it from scratch unless an implementation is necessary to explain the mechanism.
- Use a tiny example, usually 4-8 values.
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
After the basic example, demonstrate ONE common pattern where this DSA is useful.
Choose the most canonical pattern for the requested concept, for example:
- stack -> matching brackets, expression evaluation, DFS/backtracking, or undo
- monotonic stack -> next greater/smaller element
- queue -> BFS
- deque -> sliding-window maximum
- heap -> top-k / priority queue
- hash map -> frequency counting / lookup
- set -> membership / duplicate detection
- two pointers -> inward scan / fast-slow pointers
- sliding window -> longest/shortest valid subarray or substring
- prefix sum -> range sums / subarray counts
- union-find -> dynamic connectivity
- trie -> prefix lookup
- graph -> BFS/DFS/shortest path as appropriate
Do not force these examples if another pattern is more canonical.

OUTPUT FORMAT
Return exactly these sections:

## <DSA concept>

```python
# one runnable snippet containing both:
# - basic operations
# - one popular usage technique
# - inline comments explaining the mechanism and technique
```

### What to notice
- 2-4 concise bullets explaining the mechanism and why the technique works.

### Complexity
- concise operation/pattern complexities only.

Do not include long theory, history, or unrelated variants.
```
