# Platform Kernel Risk Register

<!-- markdownlint-disable MD013 -->

Status: Active PK risk register.
Date: 2026-05-08

| Risk | Status | Owner batch | Current boundary |
| --- | --- | --- | --- |
| Multi-repository mutation is only foundation-proven. | Open Yellow | PK04-PK06 | PK03 proves a local SwiftData AppUnitOfWork commit/rollback boundary. No atomic product-flow or multi-repository mutation-safety claim until PK04-PK06 pass focused proof. |
| Schema/migration safety is not PK-proven. | Open Yellow | PK07-PK13 | No migration-safe or data-loss-proof claim until version ledger, migration plan, backup, import dry run, and rollback are proven. |
| Side effects can be triggered from multiple platform paths. | Open Yellow | PK22-PK25 | No side-effect-isolated claim until SideEffectLedger routes notifications, EventKit, and external snapshots. |
| Sync readiness is architectural only. | Open Yellow | PK29-PK31 | No sync-ready, cloud-ready, or conflict-safe claim until revisions, tombstones, conflict policy, and manual merge proof exist. |
| Intelligence output must stay claim-bounded. | Open Yellow | PK32-PK34 | No AI-ready or autonomous-intelligence claim; quarantine uncertain/generated intelligence until PK proof exists. |
| Performance scale has not been PK-budget-proven. | Open Yellow | PK35-PK37 | No performance-budget-proven claim until large-store fixtures, budgets, and cache invalidation proof exist. |
| Package/module moves can destabilize builds. | Scanner Yellow | PK04-PK41 | PK01 boundary scaffold and PK02 scanner exist; current scanner findings are Yellow and no package-split claim is allowed until later focused builds pass. |
| Pre-sync stash contains source-truth conflicts. | Parked Yellow | Repo steward / sequencing reconciliation | Stash remains preserved and unapplied; do not drop it until a future reconciliation confirms every useful piece is merged or obsolete. |

Hard Red entries: none recorded by PK integration as of 2026-05-08.

## PK00 Baseline Findings

PK00 completed a report-only backend/platform proof baseline. It found current
SwiftData repository, portable snapshot, runtime service, notification,
EventKit, external snapshot, local-only sync, and test evidence, but it did not
prove atomic product-flow mutation safety, migration safety, full rollback,
side-effect isolation, sync readiness, intelligence readiness,
performance-budget compliance, or package split safety. PK03 now proves a
single-context AppUnitOfWork commit/rollback foundation only.

## AFI / PK Ordering Finding

AFI01-AFI16 are complete / Accepted Yellow. PK01 now starts the Platform
Kernel safety ladder before applicable LDI/backend/platform, mutation, sync,
migration, intelligence, package split, or major expansion work. PK00 remains
useful safety baseline evidence, PK01 adds docs-only module-boundary scaffold
evidence without moving code, PK02 adds non-mutating scanner evidence, and
PK03 adds focused AppUnitOfWork commit/rollback evidence without proving
atomic product flows.
