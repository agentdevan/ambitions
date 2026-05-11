---
name: ambitions-repo-hygiene-rollback
description: Keep repo changes reversible and bounded with clear restoration paths.
---

## Steps
1. Precompute final changed files list.
2. Verify diff stays under approved boundary.
3. Record exact rollback commands.
4. Prefer `git checkout -- <path>` and explicit directory removal over hard reset.

## Exit criteria
- Scoped diffs only.
- Clear rollback and next-batch recommendation.
