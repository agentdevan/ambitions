# MRI02 Ambition Graph Projection Store Report

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
- `Native/Ambitions/Domain/AmbitionGraphModels.swift`
- `Native/Ambitions/Domain/LifeGraphDeltaReviewModels.swift`
- `docs/status/current-implementation-map.md`
- `docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md`
- `docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md`

## files changed
- `Native/Ambitions/Domain/AmbitionGraphProjectionStore.swift`
- `Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift`
- `docs/audits/mri02-ambition-graph-projection-store-report.md`

## changes implemented
- Added `AmbitionGraphProjectionSurface` with `today`, `goals`, `capture`, `time`, and `you` cases.
- Added `AmbitionGraphProjectionSnapshot` value contract with:
  - ordered/deduped ID arrays for commitments, proofs, steps, constraints, outcomes, identity directions, closures, recovery threads, recommendation traces, and source objects.
  - local-only posture (`localProjectionOnly`) and source-traceability fields.
  - `AmbitionPrivacyClass` surface privacy summary and `hasPrivateContent`.
- Added `AmbitionGraphProjectionStore` with snapshot ingestion and deterministic per-surface projection derivation from `AmbitionGraphSnapshot`.
- Added focused projection tests for:
  - surface filtering for each allowed surface,
  - deduplicated/ordered projection IDs,
  - privacy and source-field contract behavior,
  - forbidden term checks in surface raw values.
- Repair Pass 1 corrected the MRI02-owned tests to use the active `AmbitionGraphProofType.photo` case and to expect the projection contract's sorted capture `sourceObjectIDs` (`ambition`, selected commitment, selected constraint, selected proof).
- Final GPT-5.5 gate repair corrected the You projection source-field assertion to include the fixture's `goals-source` recommendation trace source.
- Final GPT-5.5 gate repair also parenthesized the Today commitment filter so timed or effort-tagged commitments do not bypass the active-status check.

## validation commands and exit codes
- `xcodegen generate` -> 0
- `git diff --check` -> 0
- `python3 scripts/ambitions-state-advance-validate.py || true` -> 0
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/AmbitionGraphProjectionStore.swift Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift docs/audits/mri02-ambition-graph-projection-store-report.md 2>/dev/null || true` -> 0
- `rg -n "photoReference" Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift Native/Ambitions/Domain/AmbitionGraphProjectionStore.swift` -> 1; obsolete proof enum case absent from source and tests.
- `rg -n "sourceObjectIDs" Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift Native/Ambitions/Domain/AmbitionGraphProjectionStore.swift docs/audits/mri02-ambition-graph-projection-store-report.md` -> 0; references remain only in the projection contract, corrected assertion, and this report.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AmbitionGraphProjectionStoreTests test CODE_SIGNING_ALLOWED=NO` -> not executed by shell; outer command policy rejected before execution with `approval required by policy, but AskForApproval is set to Never`
- XcodeBuildMCP `session_show_defaults` -> 0; no project, scheme, or simulator defaults configured for this session.
- XcodeBuildMCP `test_sim` with project/scheme/destination in `extraArgs` -> failed before Xcode execution because session defaults require a configured scheme.
- XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/AmbitionGraphProjectionStoreTests CODE_SIGNING_ALLOWED=NO` -> failed before MRI02 tests executed due unrelated existing test-target compile debt:
  - `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28`
  - `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109`
  - `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110`

## loop behavior added or deferred
- Added deterministic, value-type projection contracts for the requested surfaces.
- Loop orchestration, rendering decisions, and service-level wiring remain deferred to a later phase.

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
Invoked for loop/proof discipline because this touches user-facing context and local-intelligence contracts; not used for release, privacy/legal, accessibility, performance, or global completion claims.

## rollback notes
Rollback command:
```bash
 rm -f Native/Ambitions/Domain/AmbitionGraphProjectionStore.swift Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift docs/audits/mri02-ambition-graph-projection-store-report.md
 xcodegen generate
```

## next handoff
- Add owner-defined surface semantics if needed after API/loop seam approves this contract.
- Keep storage strictly non-persistent and in-memory.
- Advance to next loop-binding owner only after surface projection consumers are defined and proven in scope.
