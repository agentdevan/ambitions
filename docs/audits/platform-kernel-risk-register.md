# Platform Kernel Risk Register

<!-- markdownlint-disable MD013 -->

Status: Active PK risk register.
Date: 2026-05-08

| Risk | Status | Owner batch | Current boundary |
| --- | --- | --- | --- |
| Multi-repository mutation is not transaction-proven. | Open Yellow | PK03-PK06 | No transaction-safety claim until UnitOfWork and atomic flows pass focused proof. |
| Schema/migration safety is not PK-proven. | Open Yellow | PK07-PK13 | No migration-safe or data-loss-proof claim until version ledger, migration plan, backup, import dry run, and rollback are proven. |
| Side effects can be triggered from multiple platform paths. | Open Yellow | PK22-PK25 | No side-effect-isolated claim until SideEffectLedger routes notifications, EventKit, and external snapshots. |
| Sync readiness is architectural only. | Open Yellow | PK29-PK31 | No sync-ready, cloud-ready, or conflict-safe claim until revisions, tombstones, conflict policy, and manual merge proof exist. |
| Intelligence output must stay claim-bounded. | Open Yellow | PK32-PK34 | No AI-ready or autonomous-intelligence claim; quarantine uncertain/generated intelligence until PK proof exists. |
| Performance scale has not been PK-budget-proven. | Open Yellow | PK35-PK37 | No performance-budget-proven claim until large-store fixtures, budgets, and cache invalidation proof exist. |
| Package/module moves can destabilize builds. | Open Yellow | PK38-PK41 | No package-split claim until boundary scaffold, scanner, and focused builds pass. |
| Pre-sync stash contains source-truth conflicts. | Parked Yellow | Repo steward / sequencing reconciliation | Stash remains preserved and unapplied; do not drop it until a future reconciliation confirms every useful piece is merged or obsolete. |

Hard Red entries: none recorded by PK integration as of 2026-05-08.

## PK00 Baseline Findings

PK00 completed a report-only backend/platform proof baseline. It found current
SwiftData repository, portable snapshot, runtime service, notification,
EventKit, external snapshot, local-only sync, and test evidence, but it did not
prove transaction safety, migration safety, rollback, side-effect isolation,
sync readiness, intelligence readiness, performance-budget compliance, or
package split safety.
