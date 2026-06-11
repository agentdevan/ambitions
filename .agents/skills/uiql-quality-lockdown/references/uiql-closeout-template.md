# uiql-closeout-template

Use this reference during UIQL closeout. It reinforces no product Yellow, screenshot path is not proof, read-only reviewers, exact proof paths, rollback, Linear closeout, and no release/owner approval claims.

Linear identifier rule: use the actual AMB issue ID, never the synthetic `UIQL-*` label, for fetch/comment/status work. The closeout title may include both, for example `AMB-962 / UIQL-007 - Today Reconstruction`, but the Linear parent must be `AMB-962`.

If the AMB issue cannot be fetched, stop and include exact manual comment text for that AMB issue. Do not fall back to `UIQL-*`.
