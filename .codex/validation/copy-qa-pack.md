# Copy QA Pack

## Purpose

Validate Ambitions language and deprecated-term risk.

## Commands

```bash
scripts/run-doc-qa.sh || true
rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' Native Sources AppUI docs .codex || true
```

## Evidence

New copy reviewed, scan results, historical hits separated from active issues.
