# Context Compaction Recovery

1. Stop implementation.
2. Read the newest user request.
3. Run `git status --short` and `git log -1 --oneline`.
4. Read `.codex/reports/current-run-state.md`.
5. Inspect staged and unstaged diffs.
6. Re-read selected source docs and context pack.
7. Resume only if task, phase, and next action are clear.
8. If unclear, write a partial report instead of guessing.
