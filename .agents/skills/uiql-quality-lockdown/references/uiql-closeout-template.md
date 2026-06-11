# uiql-closeout-template

Use this reference during UIQL closeout. It reinforces no product Yellow, screenshot path is not proof, read-only reviewers, exact proof paths, rollback, Linear closeout, and no release/owner approval claims.

Linear identifier rule: Codex must never fetch, update, close, or comment on Linear using synthetic `UIQL-*` labels. Codex must always use the mapped `AMB-*` issue ID for Linear operations. `UIQL-*` is a title/sequence label only, not a Linear identifier. The closeout title may include both, for example `AMB-962 / UIQL-007 - Today Reconstruction`, but the Linear parent must be `AMB-962`.

If the AMB issue cannot be fetched, stop and include exact manual comment text for that AMB issue. Do not fall back to `UIQL-*`.
