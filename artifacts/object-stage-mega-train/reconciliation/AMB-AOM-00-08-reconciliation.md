# AMB-AOM 00-08 Reconciliation Boundary

AMB-AOM-09 through AMB-AOM-12 remain blocked until the listed Red and Yellow predecessors are reconciled.

## Verdict table

| Batch | Verdict | Action | Reason |
|---|---|---|---|
| AMB-AOM-00 | YELLOW | audit_report_quality_first | Audit batch may be artifact-only, but bootstrap and true batch scope must be separated. |
| AMB-AOM-01A | GREEN_SOURCE_DELTA_YELLOW_PROOF | accept_source_delta_require_scope_proof | Real source/test delta exists; runner proof is incomplete. |
| AMB-AOM-01B | GREEN_SOURCE_DELTA_YELLOW_PROOF | accept_source_delta_require_scope_proof | Routing/app-intent/test delta exists; scope checklist proof remains required. |
| AMB-AOM-01C | YELLOW | prove_scope_or_replay | Tests and guard scripts changed, but app source did not. |
| AMB-AOM-02 | GREEN_SOURCE_DELTA_YELLOW_PRODUCT_PROOF | accept_source_delta_require_runtime_ui_proof | RootView, Motion, Projection, and Stage source changed; runtime proof remains required. |
| AMB-AOM-03 | YELLOW_LIKELY_REPLAY | audit_preexisting_source_or_replay | Only tests changed for a source behavior batch. |
| AMB-AOM-04 | RED_REMEDIATION_REQUIRED | reconcile_repair_commit_and_report | Original run was invalid Green; later source repair must be reconciled formally. |
| AMB-AOM-05 | GREEN_SOURCE_DELTA_YELLOW_SCOPE_PROOF | accept_source_delta_require_language_cleanup_proof | Today and Time source changed; trust-language cleanup proof remains required. |
| AMB-AOM-06 | RED_OR_YELLOW_PENDING_SCHEMA_DECISION_REVIEW | review_schema_decision_or_replay | Original run was invalid Green; schema decision artifact must be quality reviewed or replayed. |
| AMB-AOM-07 | YELLOW_LIKELY_UNDERSCOPED | scope_audit_or_replay | Shell/visual foundation delta was suspiciously small. |
| AMB-AOM-08 | YELLOW_VALIDATE_AGAINST_APP_REPORT | audit_today_blockers | Today source changed; must be checked against app testing blockers. |
| AMB-AOM-09 | BLOCKED | do_not_start | Blocked until AMB-AOM-00 through AMB-AOM-08 are reconciled. |
| AMB-AOM-10 | BLOCKED | do_not_start | Blocked until AMB-AOM-00 through AMB-AOM-08 are reconciled. |
| AMB-AOM-11 | BLOCKED | do_not_start | Blocked until AMB-AOM-00 through AMB-AOM-08 are reconciled. |
| AMB-AOM-12 | BLOCKED | do_not_start | Blocked until AMB-AOM-00 through AMB-AOM-08 are reconciled. |

## Required order

1. AMB-AOM-04 formal repair report/state reconciliation
1. AMB-AOM-06 schema decision quality review or replay
1. AMB-AOM-03 source-behavior audit or replay
1. AMB-AOM-07 shell/visual foundation scope audit or replay
1. AMB-AOM-08 Today blocker validation against App Testing Report
1. AMB-AOM-00/01/02/05 proof-quality closeout
