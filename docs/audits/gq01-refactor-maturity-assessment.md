# GQ01 Refactor Maturity Assessment

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Result: Accepted Yellow, no broad GQ01 production refactor

## Scope

This assessment reviews refactor readiness after dirty-worktree resolution and queue maturity. It does not change app behavior.

## Findings

| Area | Assessment | Owner |
| --- | --- | --- |
| Oversized Swift files | Existing service/surface owners remain large enough to warrant extraction review. GQ01 did not re-run a full large-file extraction because production Swift changes are out of scope. | RHC02, PK17-PK21 |
| Duplicated domain models | No new duplication introduced by GQ01. Existing proof/receipt/status overlap remains better handled by PK14-PK16 and PK32-PK34. | PK14-PK16, PK32-PK34 |
| SwiftUI imported into domain/runtime layers | PK02 scanner already carries `Native/Ambitions/Domain/AppSession.swift` SwiftUI import drift as Yellow. | PK02 scanner Yellow, PK38-PK41 |
| Feature services doing too much | Today, Goals, Capture, Time/Plan, and You service extraction remains scheduled, not safe to widen in GQ01. | PK17-PK21, RHC02 |
| Cross-feature leakage | Route/raw-value and Plan/Time compatibility seams remain intentional until proof gates exist. | CS conditional triggers |
| Hidden route/raw-value coupling | `.plan`, `PlanScreen`, `planNavigation()`, App Intent/widget/deep-link compatibility remain active debt. | CS02C-CS06C/CS09C only when triggered |
| Duplicated receipt/proof/status models | Existing shared trust primitives reduce duplication, but durable backend proof remains future PK work. | PK14-PK16 |
| Stale compatibility seams | Present and intentionally preserved. | CS/RHC |
| Tests encoding old Plan-era truth | Search found Plan-era names in tests/source compatibility. No unsafe rename performed. | CS/RHC focused tests |
| Preview/test fixtures | Some Plan-era fixture labels remain as historical or compatibility labels. | RHC04/RHC05 |
| Package/module boundary drift | PK01/PK02 created scaffold/scanner; package moves remain future work. | PK38-PK41 |
| Doc/script validators too noisy | GQ01 made next-batch scripts deterministic. Broader scan noise remains. | RHC05 |
| Prompt residue | Completed batch prompts and old canon remain evidence-linked. | RHC04/RHC06 |

## Refactors Executed In GQ01

- Canonical JSON-backed queue selection for `scripts/global-train-next-batch.sh` and `scripts/global-train-status-summary.sh`.
- Time/Plan active-language repair in `docs/implementation-backlog.md`.
- Local generated artifact cleanup.

## Refactors Deferred

No new RFM01-RFM06 train was added. Existing PK, RHC, and CS owners are sufficient and more precise:

- Architecture boundary refactor: PK17-PK21, PK38-PK41.
- Oversized owner extraction: RHC02.
- Domain/runtime/UI separation: PK38-PK41.
- Compatibility seam retirement proof: CS conditional triggers.
- Test/preview fixture modernization: RHC04/RHC05.
- Refactor closeout/regression proof: RHC06.

## GQ01 Decision

Do not execute broad production Swift refactors in GQ01. Proceed to PK04 after GQ01 validation because PK04 is the next bounded implementation batch and uses the PK03 UnitOfWork foundation.
