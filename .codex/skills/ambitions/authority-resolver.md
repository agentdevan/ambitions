---
name: authority-resolver
description: Route Ambitions questions about active truth, source hierarchy, duplicate authority, and file classification to the current truth files and truth-oriented reviewers.
---

# Authority Resolver

Use this wrapper when a batch needs to decide what is active, supporting, historical, obsolete, archive-candidate, or delete-candidate.

## Route to existing skills

- `repo-truth-enforcer`
- `source-truth-librarian`
- `active-canon-linker`
- `evidence-hierarchy-enforcer`

## Minimum check

1. Read `docs/truth/README.md`.
2. Identify the highest authority for the task.
3. Refuse duplicate authority paths.
4. Classify the file before editing.
