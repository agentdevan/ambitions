# uiql-reviewer-prompts

Use this reference during UIQL closeout. It reinforces no product Yellow, screenshot path is not proof, read-only reviewers, exact proof paths, rollback, Linear closeout, and no release/owner approval claims.

Reviewer prompt identifier rule: reviewers may use `UIQL-*` only as a sequence label. Findings and closeout references must name the actual AMB issue ID from `UIQL_GOAL.md`. If the prompt only provides `UIQL-*`, the reviewer must return Yellow for issue-ID ambiguity and ask the main Codex agent to resolve the AMB issue before closeout.

Codex must never fetch, update, close, or comment on Linear using synthetic `UIQL-*` labels. Codex must always use the mapped `AMB-*` issue ID for Linear operations. `UIQL-*` is a title/sequence label only, not a Linear identifier.
