# MRI01 Ambition Graph Runtime Objects Report

## status
YELLOW

## operating system
Ambition Lifecycle Engine

## product loop
Goal-to-life-direction

## source truth inspected
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- Phase 01-seeded boundary and plan artifacts for `MRI01-AMBITION-GRAPH-RUNTIME-OBJECTS`

## files changed
- `Native/Ambitions/Domain/AmbitionGraphModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift`
- `docs/audits/mri01-ambition-graph-runtime-objects-report.md`

## changes implemented
### Domain contracts added
- Added `IdentityDirection` contract.
- Added `Outcome` contract with `AmbitionOutcomeKind`.
- Added graph-scoped step contract as `AmbitionGraphStep` to avoid collision with existing `Step`.
- Added `ClosureEvent` contract using `AmbitionClosureState`.
- Extended `AmbitionGraphSnapshot` with optional/default-safe arrays for the new types to preserve compatibility.

### Validation additions
- Added focused test coverage for the new contracts in an existing snapshot flow.
- Added decode compatibility test that decodes a legacy `AmbitionGraphSnapshot` payload without new fields and verifies defaults are used.

### Phase 03 review repair
- Added custom `AmbitionGraphSnapshot` decoding so absent collection fields and absent `schemaVersion` decode to safe defaults instead of failing synthesized `Codable` decoding.

### Phase 04 repair pass
- Re-reviewed the MRI01 source/test diff against the Phase 01 approved boundary.
- No additional in-boundary source repair was identified.
- Left unrelated compile blockers outside the MRI01 boundary untouched.

## validation commands and exit codes
- `xcodegen generate` -> `0`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AmbitionGraphModelsTests test CODE_SIGNING_ALLOWED=NO` -> `65` (failures in existing unrelated scope: `fileprivate` access/type-check in `GoalsOverviewProjector.swift` and related files)
- `git diff --check` -> `0`
- `python3 scripts/ambitions-state-advance-validate.py || true` -> `0`
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/AmbitionGraphModels.swift Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift docs/audits/mri01-ambition-graph-runtime-objects-report.md 2>/dev/null || true` -> `0`

Phase 03 rerun:
- `xcodegen generate` -> `0`
- `mcp__xcodebuildmcp__.test_sim` with `-only-testing:AmbitionsTests/AmbitionGraphModelsTests CODE_SIGNING_ALLOWED=NO` -> failed before test execution due unrelated compile error in `Native/Ambitions/Features/Today/TodayReadModelProjector.swift:44`: `TodayTimeApertureState` has no member `summary`.
- `git diff --check` -> `0`
- `python3 scripts/ambitions-state-advance-validate.py || true` -> `0`
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/AmbitionGraphModels.swift Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift docs/audits/mri01-ambition-graph-runtime-objects-report.md 2>/dev/null || true` -> `0`

Phase 04 rerun:
- `xcodegen generate` -> `0`
- `git diff --check` -> `0`
- `python3 scripts/ambitions-state-advance-validate.py || true` -> `0`
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/AmbitionGraphModels.swift Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift docs/audits/mri01-ambition-graph-runtime-objects-report.md 2>/dev/null || true` -> `0`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AmbitionGraphModelsTests test CODE_SIGNING_ALLOWED=NO` -> not executed; shell command rejected by outer policy before launch.
- `mcp__xcodebuildmcp__.session_show_defaults` -> `0`, defaults initially missing.
- `mcp__xcodebuildmcp__.list_schemes` -> `0`, found `Ambitions`.
- `mcp__xcodebuildmcp__.list_sims` -> `0`, found booted `iPhone 17` simulator on iOS 26.3.
- `mcp__xcodebuildmcp__.session_set_defaults` for `Ambitions.xcodeproj`, `Ambitions`, `iPhone 17` -> `0`.
- `mcp__xcodebuildmcp__.test_sim` with `-only-testing:AmbitionsTests/AmbitionGraphModelsTests CODE_SIGNING_ALLOWED=NO` -> failed before MRI01 test execution due unrelated test-target compile errors in `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28`, `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109`, and `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110`.

GPT-5.5 final-gate rerun:
- `xcodegen generate` -> `0`
- `git diff --check` -> `0`
- `python3 scripts/ambitions-state-advance-validate.py || true` -> `0`
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/AmbitionGraphModels.swift Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift docs/audits/mri01-ambition-graph-runtime-objects-report.md prompts/batches/MRI01-AMBITION-GRAPH-RUNTIME-OBJECTS.md 2>/dev/null || true` -> `0`
- `mcp__xcodebuildmcp__.session_show_defaults` -> `0`, defaults initially missing.
- `mcp__xcodebuildmcp__.list_schemes` for `Ambitions.xcodeproj` -> `0`, found `Ambitions`.
- `mcp__xcodebuildmcp__.list_sims` -> `0`, found booted `iPhone 17` simulator on iOS 26.3.
- `mcp__xcodebuildmcp__.session_set_defaults` for `Ambitions.xcodeproj`, `Ambitions`, `iPhone 17` -> `0`.
- `mcp__xcodebuildmcp__.test_sim` with `-only-testing:AmbitionsTests/AmbitionGraphModelsTests CODE_SIGNING_ALLOWED=NO` -> failed before MRI01 test execution due unrelated test-target compile errors in `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28`, `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109`, and `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110`.
- `git status --short --branch` -> `0`, on `main`; tracked MRI01 source/test files modified; this report and MRI prompt files are untracked.
- `git diff --stat` -> `0`, tracked diff limited to `Native/Ambitions/Domain/AmbitionGraphModels.swift` and `Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift`.

## loop behavior added or deferred
- Loop-level behavioral transitions and lifecycle orchestration are still deferred in this phase. Contract additions only.
- This phase added structured runtime objects for graph planning/closure continuity without executing loop transition behavior.

## claims not made
- release readiness
- TestFlight readiness
- App Store readiness
- device proof
- public accessibility conformance
- performance validation
- privacy/legal approval
- visual runtime completion
- global train completion

## EFC applicability
Invoked for proof/loop discipline only. Not used to authorize release, accessibility, privacy/legal, or performance claims.

## rollback notes
Rollback command:
```bash

git restore --source=8a7fc17113977f52d18772635347e00e9517eb43 -- Native/Ambitions/Domain/AmbitionGraphModels.swift Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift
rm -f docs/audits/mri01-ambition-graph-runtime-objects-report.md
```

## next handoff
- Route next phase to close loop behavior and cross-object integration in domain services or projection runtime.
- Keep this as a contract-first slice; proceed only after owner confirms intended loop transitions and ownership boundaries.
- Resolve current branch compile debt before claiming focused unit test proof for MRI01. Latest Phase 04 blocker is unrelated test-target compile debt in `PolicyGuardedCommandExecutorTests.swift`, `PortableRestoreRollbackTests.swift`, and `PreMigrationBackupTests.swift`; Phase 03 also observed unrelated `TodayReadModelProjector.swift` compile debt.
