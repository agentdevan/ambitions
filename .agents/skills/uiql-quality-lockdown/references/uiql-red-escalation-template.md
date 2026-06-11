# uiql-red-escalation-template

Use this reference during UIQL closeout. It reinforces no product Yellow, screenshot path is not proof, read-only reviewers, exact proof paths, rollback, Linear closeout, and no release/owner approval claims.

Issue-ID drift is a Red escalation. If Codex cannot map the current `UIQL-*` sequence label to an actual AMB issue ID, stop source work and create/update the reconciliation report. Do not post to Linear with a synthetic `UIQL-*` identifier.

Codex must never fetch, update, close, or comment on Linear using synthetic `UIQL-*` labels. Codex must always use the mapped `AMB-*` issue ID for Linear operations. `UIQL-*` is a title/sequence label only, not a Linear identifier.
