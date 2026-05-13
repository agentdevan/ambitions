# MRI12 Personal Runtime Inspection Report

Status: Green

Operating system: Inspectable Intelligence Engine

Product loop: Personal Runtime trust/control

## Source Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `.codex/state/active-batch.yml`
- Phase 01 handoff for `MRI12-PERSONAL-RUNTIME-INSPECTION`
- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`

## Files Changed

- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Services/LargeStoreFixtureGenerator.swift`
- `Native/Ambitions/Domain/AmbitionGraphModels.swift`
- `Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift`
- `Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift`
- `Native/AmbitionsTests/Domain/AmbitionLifecycleGoldenScenarioTests.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`
- `docs/audits/mri12-personal-runtime-inspection-report.md`

## Loop Behavior Added Or Deferred

Added a narrow You -> What Ambitions Knows runtime inspection readout for:

- Learned: user-confirmed correction signals.
- Used: local proof, feedback, and Event Ledger records used for reviews, receipts, and Why Changed.
- Ignored: open captures held back from stronger memory use until placement, edit, archive, or rejection.
- Changed: recent local Event Ledger changes, with review routed to receipts or owning surfaces.

The patch does not add a new memory engine, hosted backend, persistence migration, hidden recommendation behavior, top-level route, or destructive delete/reset path. Durable rejected-memory rules, broad forgetting, and destructive deletion remain future-owned or confirmation-gated.

Phase 04 repaired the compile-blocking `RecommendationTrace` name collision by keeping the recommendation explanation/trust-seam type as `RecommendationTrace` and making the graph snapshot compatibility model explicit as `AmbitionGraphRecommendationTrace`. This was a bounded source compatibility repair for the validation lane, not a new recommendation architecture.

Final repair carried starter-plan fixture metadata through `LargeStoreFixtureGenerator` so the focused Profile proof lane can compile through the existing local large-store fixture seam.

## Validation Commands And Exit Codes

- `xcodegen generate` -> exit `0`.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/ProfileFeatureServiceTests test` -> not executed; outer policy rejected the direct command before process start.
- Phase 03 post-repair rerun: XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/ProfileFeatureServiceTests` -> failed before tests ran. Current compile blockers are outside this batch boundary in unchanged domain files: duplicate/ambiguous `RecommendationTrace` declarations and related type lookups in `Native/Ambitions/Domain/AmbitionGraphModels.swift`, `Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift`, and `Native/Ambitions/Domain/RecommendationExplanationModels.swift`. Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T08-30-27-277Z_pid33560_172dea46.log`.
- Phase 04 repair rerun: XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/ProfileFeatureServiceTests` -> failed before tests ran after the `RecommendationTrace` collision was repaired. Current blockers are unchanged tests outside MRI12 scope: `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28` actor-isolated `value()` called inside an `XCTAssertEqual` autoclosure, `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109` test double does not conform to `PortableSnapshotServicing`, and `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110` test double does not conform to `PortableSnapshotServicing`. Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T08-44-22-256Z_pid34893_94382f4a.log`.
- Final gate rerun: XcodeBuildMCP `test_sim` with `-only-testing:AmbitionsTests/ProfileFeatureServiceTests` -> failed before tests ran. Current blocker is unchanged app-target compile debt outside MRI12 scope: `Native/Ambitions/Services/LargeStoreFixtureGenerator.swift:89` constructs `GoalPlannedResult` without the now-required `metadata` argument. Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-05-13T08-52-56-573Z_pid36242_b03a3862.log`.
- Final repair `scripts/ambitions-xcode-validate.sh --batch MRI12-PERSONAL-RUNTIME-INSPECTION --lane focused-test --test AmbitionsTests/ProfileFeatureServiceTests` -> exit `0`; output was `xcode validation passed`.
- `git diff --check` -> exit `0`.
- Phase 04 `git diff --check` -> exit `0`.
- Final gate `git diff --check` -> exit `0`.
- `python3 scripts/ambitions-state-advance-validate.py || true` -> exit `0`; output was `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`.
- Phase 04 `python3 scripts/ambitions-state-advance-validate.py || true` -> exit `0`; output was `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`.
- Final gate `python3 scripts/ambitions-state-advance-validate.py || true` -> exit `0`; output was `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`.
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/ProfileModels.swift Native/Ambitions/Features/Profile/ProfileFeatureService.swift Native/Ambitions/Features/Profile/ProfileScreen.swift Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift docs/audits/mri12-personal-runtime-inspection-report.md 2>/dev/null || true` -> exit `0`; output was `GREEN: unsupported completion/readiness claim scan passed`.
- Phase 04 `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/AmbitionGraphModels.swift Native/Ambitions/Domain/ProfileModels.swift Native/Ambitions/Features/Profile/ProfileFeatureService.swift Native/Ambitions/Features/Profile/ProfileScreen.swift Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift Native/AmbitionsTests/Domain/AmbitionLifecycleGoldenScenarioTests.swift Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift docs/audits/mri12-personal-runtime-inspection-report.md 2>/dev/null || true` -> exit `0`; output was `GREEN: unsupported completion/readiness claim scan passed`.
- Final gate `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Domain/AmbitionGraphModels.swift Native/Ambitions/Domain/ProfileModels.swift Native/Ambitions/Features/Profile/ProfileFeatureService.swift Native/Ambitions/Features/Profile/ProfileScreen.swift Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift Native/AmbitionsTests/Domain/AmbitionLifecycleGoldenScenarioTests.swift Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift docs/audits/mri12-personal-runtime-inspection-report.md 2>/dev/null || true` -> exit `0`; output was `GREEN: unsupported completion/readiness claim scan passed`.

## EFC Applicability

Invoked. This batch touches user-facing trust behavior, personal runtime inspection, local learning controls, correction/rejection language, and unsupported-claim safety.

## Claims Not Made

- Release readiness
- TestFlight readiness
- App Store readiness
- Device proof
- Public accessibility conformance
- Performance validation
- Privacy/legal approval
- Visual runtime completion
- Global train completion

## Cleanup

No branch was created. No dependency, entitlement, privacy manifest, signing, release, `project.yml`, shell routing, persistence migration, hosted/backend/cloud/LLM, or `.codex` train-state file was modified.

## Rollback Notes

Rollback this batch with:

```bash
git restore -- Native/Ambitions/Domain/ProfileModels.swift Native/Ambitions/Features/Profile/ProfileFeatureService.swift Native/Ambitions/Features/Profile/ProfileScreen.swift Native/Ambitions/Services/LargeStoreFixtureGenerator.swift Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift
```

If the audit report remains untracked, remove only this batch report separately: `rm docs/audits/mri12-personal-runtime-inspection-report.md`.

Include the Phase 04 compatibility repair files if rolling back this repair pass:

```bash
git restore -- Native/Ambitions/Domain/AmbitionGraphModels.swift Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift Native/AmbitionsTests/Domain/AmbitionLifecycleGoldenScenarioTests.swift
```

## Next Handoff

MRI12 is Green for focused owner proof. Continue with MRI13 or the next MRI sidecar batch due before SA17.
