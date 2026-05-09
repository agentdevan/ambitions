# Platform Kernel Risk Register

<!-- markdownlint-disable MD013 -->

Status: Active PK risk register.
Date: 2026-05-08

| Risk | Status | Owner batch | Current boundary |
| --- | --- | --- | --- |
| Multi-repository mutation is product-flow-proven for goal creation, clarification/materialization, and Capture promotion. | Closed Green | PK04-PK06 | PK04 proves SwiftData-backed goal creation through a local UnitOfWork with rollback before draft save. PK05 proves SwiftData-backed clarification/materialization through the same UnitOfWork seam. PK06 proves Capture promotion across Goal, Draft, and Capture writes with rollback before Capture save. |
| Schema version ledger, migration scaffold, unknown raw-value degradation, storage invariant checking, and pre-migration backup are PK-proven, but migration safety is not. | Open Yellow | PK12-PK13 | PK07 names current storage versions; PK08 scaffolds blocked migration planning gates; PK09 proves deterministic unknown raw-value degradation; PK10 proves read-only invariant checking; PK11 proves a local pre-migration backup gate. No migration-safe or data-loss-proof claim until import dry run and rollback are proven. |
| Side effects can be triggered from multiple platform paths. | Open Yellow | PK22-PK25 | No side-effect-isolated claim until SideEffectLedger routes notifications, EventKit, and external snapshots. |
| Sync readiness is architectural only. | Open Yellow | PK29-PK31 | No sync-ready, cloud-ready, or conflict-safe claim until revisions, tombstones, conflict policy, and manual merge proof exist. |
| Intelligence output must stay claim-bounded. | Open Yellow | PK32-PK34 | No AI-ready or autonomous-intelligence claim; quarantine uncertain/generated intelligence until PK proof exists. |
| Performance scale has not been PK-budget-proven. | Open Yellow | PK35-PK37 | No performance-budget-proven claim until large-store fixtures, budgets, and cache invalidation proof exist. |
| Package/module moves can destabilize builds. | Scanner Yellow | PK12-PK41 | PK01 boundary scaffold and PK02 scanner exist; current scanner findings are Yellow and no package-split claim is allowed until later focused builds pass. |
| Pre-sync stash contains source-truth conflicts. | Parked Yellow | Repo steward / sequencing reconciliation | Stash remains preserved and unapplied; do not drop it until a future reconciliation confirms every useful piece is merged or obsolete. |

Hard Red entries: none recorded by PK08 as of 2026-05-08.

## PK00 Baseline Findings

PK00 completed a report-only backend/platform proof baseline. It found current
SwiftData repository, portable snapshot, runtime service, notification,
EventKit, external snapshot, local-only sync, and test evidence, but it did not
prove migration safety, full rollback across all storage flows, side-effect
isolation, sync readiness, intelligence readiness, performance-budget
compliance, or package split safety. PK03 proves a single-context
AppUnitOfWork commit/rollback foundation. PK04 extends that proof to
SwiftData-backed goal creation. PK05 extends it to focused clarification/
materialization write-back. PK06 extends it to focused Capture promotion.
PK07 adds storage schema version ledger coverage without proving migration
safety. PK08 adds a blocked migration plan scaffold without proving migration
execution safety. PK09 adds unknown persisted raw-value degradation coverage
without proving migration execution or data-loss safety. PK10 adds read-only
storage invariant checking without proving import dry run, restore rollback,
migration execution, or data-loss safety. PK11 adds a pre-migration backup gate
without proving import dry run, restore rollback, migration execution, or
data-loss safety.

## AFI / PK Ordering Finding

AFI01-AFI16 are complete / Accepted Yellow. PK01 now starts the Platform
Kernel safety ladder before applicable LDI/backend/platform, mutation, sync,
migration, intelligence, package split, or major expansion work. PK00 remains
useful safety baseline evidence, PK01 adds docs-only module-boundary scaffold
evidence without moving code, PK02 adds non-mutating scanner evidence, and
PK03 adds focused AppUnitOfWork commit/rollback evidence. PK04 adds focused
atomic goal-creation evidence. PK05 adds focused atomic clarification/
materialization evidence. PK06 adds focused atomic Capture promotion evidence,
and PK07 adds storage schema version ledger evidence without proving migration,
backup, side-effect, sync, intelligence, performance, or package-split flows.
