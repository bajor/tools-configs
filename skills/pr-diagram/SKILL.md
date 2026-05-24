Analyze PR using `gh pr diff`.

First, create a timestamped output directory using these EXACT commands:
```bash
TIMESTAMP=$(date '+%Y-%m-%d %H-%M-%S')
OUTPUT_DIR="./pr-diagram/${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"
```
ALL output files MUST be written to `$OUTPUT_DIR` (e.g., `$OUTPUT_DIR/summary.md`).

Identify:
- All changed files and their roles (controller, service, model, config, test, etc.)
- The dependency graph of changed files (what imports what)
- Which unchanged modules depend on the changed ones (blast radius)
- The key behavioral change (before vs after)

Generate THREE Mermaid diagrams, saving each as a separate `.mmd` file in `$OUTPUT_DIR`:
1. **$OUTPUT_DIR/file-changes.mmd** — files changed, grouped by layer/module
2. **$OUTPUT_DIR/blast-radius.mmd** — how changes propagate to unchanged parts of the system. Focus on modules that transitively depend on changed files but are NOT themselves changed.
3. **$OUTPUT_DIR/before-after-flow.mmd** — the main logic change as two sequence diagrams (before and after)

Generate **$OUTPUT_DIR/summary.md** containing:
- PR number and title
- One-paragraph summary of what changed and why it matters
- List of high-risk areas (unchanged code most likely to break)
- Links to the three diagrams (relative links: `./file-changes.mmd`, etc.)

After writing all files, print the full absolute path to `$OUTPUT_DIR` and list its contents with `ls -la "$OUTPUT_DIR"`.
