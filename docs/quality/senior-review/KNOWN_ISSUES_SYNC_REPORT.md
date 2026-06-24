# SCG-007A Known-Issues Sync Report

Issue: `AMB-1298 / SCG-007A`  
Scope: known-issues synchronization, dedupe verification, generated sync artifacts, and Linear closeout only.  
Input commit: `45f51ac86874a8c09c4b5a2a3a6f17d4222693fe`

## Verdict

`Ready for bounded child issue generation`

This verdict is limited to SCG-008 child issue generation. It is not senior-readiness, Visual Green, Release Green, app readiness, runtime Green, or production repair approval.

SCG-008 was not started. No repair child issues were created. No production behavior changed.

## Inputs Reviewed

- `docs/qa/KNOWN_ISSUES.md`
- `docs/quality/senior-review/BUILD_GRAPH_INVENTORY.json`
- `docs/quality/senior-review/FILE_INVENTORY.json`
- `docs/quality/senior-review/AUTOMATED_FINDINGS.json`
- `docs/quality/senior-review/AUTOMATED_FINDINGS.md`
- `docs/quality/senior-review/SENIOR_CODE_REVIEW_LEDGER.json`
- `docs/quality/senior-review/SENIOR_CODE_REVIEW_LEDGER.md`
- `docs/quality/senior-review/SENIOR_CODE_REVIEW_SUMMARY.md`
- `docs/quality/senior-review/FLOW_TRACE_AUDIT.json`
- `docs/quality/senior-review/FLOW_TRACE_AUDIT.md`
- `docs/quality/senior-review/ROOT_CAUSE_MAP.json`
- `docs/quality/senior-review/ROOT_CAUSE_MAP.md`
- `docs/quality/senior-review/REPAIR_TRAINS.json`
- `docs/quality/senior-review/REPAIR_TRAINS.md`
- `docs/quality/senior-review/SCG_007_REPAIR_TRAIN_PLAN.md`

## Summary Counts

| Metric | Count |
|---|---:|
| Total SCG records reviewed | 2205 |
| Known-issues rows already present | 53 |
| Known-issues rows added | 0 |
| Known-issues rows updated | 0 |
| Rows deduped against existing QA/runtime issues | 52 |
| Rows exempted because Yellow/B3/B4/non-blocking | 631 |
| Fixture-only findings excluded | 16 |
| Governance-only Unknown rows carried forward | 117 |
| Open B0 count | 0 |
| Open B1 count | 0 |
| Open B2 count | 0 |
| Open B3 count | 622 |
| Open B4 count | 25 |

The B counts are reviewed SCG finding records, not unique production defects. Repair-train rows are owner routing and are excluded from B-count totals.

## Known-Issues Register Decision

`SCG-BG-001` remains present in `docs/qa/KNOWN_ISSUES.md` and remains resolved. The register records the package-relative SwiftPM resource path audit and confirms no `Package.swift` change was required.

No new real Red/B0/B1/B2 finding from SCG-004 through SCG-007 was missing from `docs/qa/KNOWN_ISSUES.md`. Therefore `docs/qa/KNOWN_ISSUES.md` was not modified.

The SCG sync report is a verification artifact only. It does not replace the canonical known-issues register.

## SCG-004 Automated Findings

| Category | Count |
|---|---:|
| Total automated findings | 29 |
| Real repo findings | 13 |
| Fixture-only findings | 16 |
| B3 findings | 11 |
| B4 findings | 18 |
| Real Red/B0/B1/B2 findings | 0 |

Decision:

- Real repo findings are Yellow/B3/B4 only.
- Fixture-only findings `SCG-004-900` through `SCG-004-915` are audit detector proof only and are excluded from known issues.
- Governance/intake findings `SCG-004-001`, `SCG-004-002`, and `SCG-004-012` are carried forward through SCG artifacts.
- Runtime/proof findings are deduped through SCG-006 root-cause mappings and existing `AMB-ISSUE-*` rows.

## SCG-005 Ledger Findings

| Category | Count |
|---|---:|
| Files reviewed | 2136 |
| Red/B0/B1/B2 | 0 |
| B3 | 602 |
| B4 | 6 |
| Yellow rows | 361 |
| Unknown rows | 117 |
| Green rows | 1658 |

Decision:

- No known-issues row was added.
- SCG-005 discovered no new real Red/B0/B1/B2 finding.
- B3/B4 findings remain ledger evidence and owner-train input.
- Unknown rows remain governance/ownership risk, not runtime known-issues rows.

## SCG-006 Flow And Root-Cause Findings

| Category | Count |
|---|---:|
| Flows traced | 16 |
| Yellow flows | 16 |
| Green flows | 0 |
| Red flows | 0 |
| Root causes | 10 |
| Root-cause B3 | 9 |
| Root-cause B4 | 1 |

Decision:

- No known-issues row was added.
- Nine root causes dedupe to existing `AMB-ISSUE-*` rows.
- `RC-SCG006-008` is governance-only and remains carried in SCG artifacts.

Root-cause dedupe summary:

| Root cause | Known-issues sync decision |
|---|---|
| `RC-SCG006-001` | Deduped to proof/accessibility rows including `AMB-ISSUE-0014`, `AMB-ISSUE-0807`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802`. |
| `RC-SCG006-002` | Deduped to Capture rows including `AMB-ISSUE-0003`, `AMB-ISSUE-0008`, `AMB-ISSUE-0012`, `AMB-ISSUE-1101`-`1107`. |
| `RC-SCG006-003` | Deduped to Goals/Today rows including `AMB-ISSUE-1301`, `AMB-ISSUE-1302`, `AMB-ISSUE-1303`, `AMB-ISSUE-1304`, `AMB-ISSUE-1309`, `AMB-ISSUE-0004`, `AMB-ISSUE-0005`. |
| `RC-SCG006-004` | Deduped to Today/proof rows including `AMB-ISSUE-0004`, `AMB-ISSUE-0005`, `AMB-ISSUE-1001`-`1007`, `AMB-ISSUE-0014`, `AMB-ISSUE-0807`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802`. |
| `RC-SCG006-005` | Deduped to Time rows including `AMB-ISSUE-0009`, `AMB-ISSUE-0501`, `AMB-ISSUE-0502`, `AMB-ISSUE-0503`, `AMB-ISSUE-0506`, `AMB-ISSUE-0507`, `AMB-ISSUE-0913`, `AMB-ISSUE-1401`-`1404`. |
| `RC-SCG006-006` | Deduped to Search rows `AMB-ISSUE-0701`, `AMB-ISSUE-1601`-`1605`. |
| `RC-SCG006-007` | Deduped to proof/accessibility rows `AMB-ISSUE-0014`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802`. |
| `RC-SCG006-008` | Governance-only. No runtime known-issues row added. |
| `RC-SCG006-009` | Deduped to release/proof row `AMB-ISSUE-0014`. |
| `RC-SCG006-010` | Deduped to shell/accessibility rows including `AMB-ISSUE-0806`, `AMB-ISSUE-0807`, `AMB-ISSUE-1706`, `AMB-ISSUE-1709`, `AMB-ISSUE-1801`, `AMB-ISSUE-1802`. |

## SCG-007 Repair Trains

SCG-007 has 13 repair trains. Every root cause maps to at least one train. No root cause is unmapped. Every train has a known-issues sync requirement or explicit sync rule.

| Train | Root causes | Known-issues sync requirement |
|---|---|---|
| `SCG-007A` | `RC-SCG006-008` | Required before SCG-008; add rows only for real Red/B0/B1/B2, otherwise record no new rows. |
| `SCG-007B` | `RC-SCG006-008` | Update `KNOWN_ISSUES` only if ownership review discovers real Red/B0/B1/B2. |
| `SCG-007C` | `RC-SCG006-001`, `RC-SCG006-004`, `RC-SCG006-007` | Update rows only for real B0/B1/B2; otherwise keep Yellow until flow proof. |
| `SCG-007D` | `RC-SCG006-002`, `RC-SCG006-001`, `RC-SCG006-010` | Reconcile Capture rows; do not close without proof matrix. |
| `SCG-007E` | `RC-SCG006-003`, `RC-SCG006-004`, `RC-SCG006-001` | Reconcile Goals/Today rows; keep Yellow if visual/device/accessibility proof remains missing. |
| `SCG-007F` | `RC-SCG006-005`, `RC-SCG006-007`, `RC-SCG006-009`, `RC-SCG006-001` | Reconcile Time rows; keep Yellow if proof is simulator-only or manual accessibility proof absent. |
| `SCG-007G` | `RC-SCG006-006`, `RC-SCG006-007`, `RC-SCG006-009`, `RC-SCG006-001` | Reconcile Search rows; do not close without runtime/device evidence. |
| `SCG-007H` | `RC-SCG006-010`, `RC-SCG006-001` | Update `AMB-ISSUE-0010` only with scan plus screenshot evidence. |
| `SCG-007I` | `RC-SCG006-010`, `RC-SCG006-001` | Reconcile shell/visual rows only with reviewable screenshots; keep Yellow without device/accessibility proof. |
| `SCG-007J` | `RC-SCG006-010`, `RC-SCG006-001` | Keep accessibility rows Yellow unless current manual/device evidence exists. |
| `SCG-007K` | `RC-SCG006-009`, `RC-SCG006-001` | Update only if B0/B1/B2 discovered; otherwise record Yellow proof gaps. |
| `SCG-007L` | `RC-SCG006-001`-`010` | Known-issues sync must happen before SCG-008; close rows only with row-specific proof. |
| `SCG-007M` | `RC-SCG006-001`, `RC-SCG006-010` | Final sync/dedupe before SCG-008. No row closure from screenshot paths alone. |

## Proof Gaps Carried Forward

- SCG-005 missing review ledger schema remains accepted Yellow/governance risk unless repaired or explicitly waived in successor scope.
- SCG-005 carries 117 Unknown rows and 361 Yellow rows; no senior-readiness claim is allowed.
- SCG-006 traces all 16 flows as Yellow; no flow is Green.
- Current runtime/device/manual accessibility/offline/account proof remains absent or incomplete per known issues and release truth.
- Visual Green, Release Green, app readiness, and senior-readiness remain unclaimed.

## Production Behavior Posture

No production source path was modified. No runtime/UI behavior changed. No repair train was started. `SCG-008` remains unstarted in this pass.

Rollback: remove `docs/quality/senior-review/KNOWN_ISSUES_SYNC_REPORT.json` and `docs/quality/senior-review/KNOWN_ISSUES_SYNC_REPORT.md`.
