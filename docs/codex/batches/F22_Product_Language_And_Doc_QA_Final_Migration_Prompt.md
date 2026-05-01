# F22 Product Language And Doc QA Final Migration Prompt

Status: Queued after F21/F21.5 Green

Scope:

- remove active user-facing legacy language
- clean deprecated product language
- align app copy with Product Language System
- improve doc QA backlog materially
- classify remaining markdown/link issues
- no broad app behavior changes

Run:

```bash
rg -n --hidden --glob '!/.git/**' 'Start Focus|Focus Session|best next move|next best move|AI confidence|productivity score|profile tab|insights tab|habits tab|overdue|failed|missed' . || true
scripts/run-doc-qa.sh || true
```

Trigger F22.5 if doc QA cannot be called Green after the migration.
