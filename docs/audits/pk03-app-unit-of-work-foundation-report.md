# PK03 AppUnitOfWork Foundation Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Batch: PK03 AppUnitOfWork Foundation
Result: Green
Owner: PK/PFC

## Scope

PK03 adds a local SwiftData AppUnitOfWork foundation for later atomic product
flows. The implementation creates one `ModelContext`, disables autosave, runs
the requested operation, saves only when the context has changes, and returns a
receipt with write scope, commit, rollback, and side-effect metadata.

This pass does not wire the UnitOfWork into goal creation, capture placement,
side-effect routes, sync, migration, import/export, UI, release, or platform
automation.

## Files Changed

- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/platform-kernel-current-state.md`
- `docs/audits/platform-kernel-train-report.md`
- `docs/audits/platform-kernel-risk-register.md`
- `docs/audits/pk03-app-unit-of-work-foundation-report.md`

Pre-existing local production-toolchain files remain dirty and were not used as
PK03 app-source evidence.

## MCP Evidence

Ambitions Repo MCP calls succeeded:

- `get_active_batch`
- `summarize_repo_posture`
- `get_efc_overlay_status`
- `changed_file_impact`
- `check_efc_applicability`

Pre-edit repo evidence reported PK02 Architecture Boundary Scanner as the
current active batch, PK03 AppUnitOfWork Foundation as the next eligible batch,
and the EFC overlay as active. Changed-file impact classified the persistence
files as PK/PFC persistence scope and required privacy, degraded-state, test,
release-claim, recovery, and performance proof. Docs/state files required
release-claim and continuation proof. No hard-Red MCP risk was reported.

## EFC Flagship Proof Overlay

EFC applicability: invoked.

- Product proof: not a user-facing product/UI pass. The proof is bounded to a
  persistence foundation for future product flows.
- Trust proof: `AppUnitOfWorkReceipt` records write scope, commit status,
  rollback behavior, and side-effect policy.
- Privacy proof: the UnitOfWork is local SwiftData only and introduces no
  network, server, telemetry, analytics, hosted AI, account, sync, or secret
  path.
- Accessibility proof: not applicable to runtime UI because no UI changed and
  no public accessibility claim is made.
- Degraded-state proof: focused rollback test proves a thrown operation does
  not persist the inserted capture before save.
- Test proof: focused persistence suite passed with 14 tests and 0 failures.
- Release-claim boundary: no release, device, App Store, TestFlight, public
  accessibility, legal/privacy, hosted CI, or all-tests-pass claim is made.
- Recovery proof: rollback behavior is explicit in the receipt contract and
  covered by the thrown-error rollback test.
- Performance proof: this pass avoids broad runtime rewiring and uses one
  bounded `ModelContext` per UnitOfWork. No large-store performance budget is
  claimed.
- Continuation proof: PK04 Atomic Goal Creation is now the next eligible batch.

Yellow owners: PK04-PK06 own atomic product-flow mutation proof. PK07-PK13 own
storage migration, backup, import dry-run, and restore rollback proof. PK22-PK25
own side-effect isolation. PK35-PK37 own performance/scale proof.

## Validation

Passed:

- `python3 tools/mcp/ambitions_repo_mcp/server.py --self-test`
- `xcodegen generate`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/PersistenceRepositoryTests`
- `git diff --check`
- `python3 scripts/ai/acx_impact.py ...`
- `python3 scripts/ai/acx_local.py bundle batch-closeout`
- `python3 scripts/ai/acx_local.py bundle docs`

Accepted Yellow:

- `python3 scripts/ai/pk_boundary_scan.py` reported existing
  `Native/Ambitions/Domain/AppSession.swift` SwiftUI import boundary drift.
  This is carried as PK scanner Yellow and does not block PK03.
- ACX/CQS advisory scans reported broad historical terms outside the PK03
  persistence files. These remain review triggers, not PK03 product changes.

Not run:

- Full app build.
- Full test suite.
- Simulator visual proof.
- Manual VoiceOver or public accessibility proof.
- Physical-device proof.
- Signed archive, TestFlight, App Store, hosted CI, or legal/privacy review.
- xcodebuildmcp; shell Xcode validation was sufficient for this focused batch.

Focused test log:

- `output/logs/pk03-persistence-tests-2026-05-08.log`

## Non-Claims

PK03 does not claim production readiness, backend completion, atomic product
flow safety, migration safety, data-loss-proof behavior, sync readiness, cloud
readiness, hosted AI readiness, telemetry, analytics, privacy compliance, legal
approval, CI green, all-tests-pass, public accessibility conformance,
physical-device proof, signed archive proof, TestFlight readiness, App Store
readiness, performance-budget proof, or release readiness.

## Rollback Path

Revert the PK03 implementation/status commit. The UnitOfWork foundation is
additive and not yet wired into product flows, so rollback should be scoped to
the persistence contract/implementation, focused tests, and PK03 status docs.

## Next Eligible Batch

PK04 Atomic Goal Creation.
