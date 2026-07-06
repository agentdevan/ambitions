# AMB-1818 File Size Cleanup Queue

Status: Implemented Yellow / live queue produced and support oversize backlog
quarantined in the governance guard

Date: 2026-07-06

Baseline SHA: `5793532a60fb7b514c65946088850d3bd3a7bdfe`

Linear state before source work: `Needs Repair`, then `In Progress`

## Scope

AMB-1818 is a bounded child of AMB-1697. The live remediation guard currently
reports no production Swift file above the hard cap:

- `swift_hard_line_cap=600`
- `overHardLineCapFiles=0`

Because there was no production oversized file to split, this leaf produced the
current cleanup queue and quarantined the support/test oversize backlog in the
governance guard output instead of taking an unproved XCTest/UI-test monolith
split under the current no-testing instruction.

The support/test backlog is not ignored. It is now visible in every
`scripts/ambitions-remediation-governance-check.py` run as:

- `support_swift_files=475`
- `support_over_hard_line_cap_files=41`
- `support_largest_files`

## Script Change

Changed:

- `scripts/ambitions-remediation-governance-check.py`

The guard now reports a nonblocking support-file queue from:

- `Native/AmbitionsTests/`
- `Native/AmbitionsUITests/`
- `Native/Ambitions/PreviewSupport/`
- `Sources/Previews/`

This does not weaken the production hard-cap rule. Production files still fail
diff-scoped remediation governance when a changed production Swift file exceeds
`600` lines.

## Current Production Queue

Top production Swift files from the live guard:

| Lines | Path |
| ---: | --- |
| 599 | `Native/Ambitions/Core/Domain/CorrectionFoldModels.swift` |
| 595 | `Native/Ambitions/Core/Domain/CommitmentWaitingModels.swift` |
| 593 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift` |
| 583 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackRemoteTransport.swift` |
| 572 | `Native/Ambitions/Core/Domain/ProofResourceGraphModels.swift` |
| 571 | `Native/Ambitions/Core/LocalRuntimeOS/Repair/DryRunMigration.swift` |
| 570 | `Native/Ambitions/Core/Domain/ReminderModels.swift` |
| 561 | `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift` |
| 552 | `Native/Ambitions/Core/Domain/Reschedule/RescheduleEngine.swift` |
| 547 | `Native/Ambitions/Core/Domain/AmbitionsProductCanonV2Models.swift` |

## Current Support Queue

Top support/test Swift files from the live guard:

| Lines | Path |
| ---: | --- |
| 3215 | `Native/AmbitionsUITests/AmbitionsUITests.swift` |
| 2485 | `Native/AmbitionsTests/You/YouFeatureServiceTests.swift` |
| 2048 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackLifecycleRefreshServiceTests.swift` |
| 1753 | `Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift` |
| 1644 | `Native/AmbitionsTests/Time/TimeProjectionServiceTests.swift` |
| 1628 | `Native/AmbitionsTests/Today/TodayViewModelTests.swift` |
| 1606 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasRuntimeBridgeCoverageGauntletTests.swift` |
| 1399 | `Native/AmbitionsTests/Domain/ProjectStepOperationModelsTests.swift` |
| 1373 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPackModelsTests.swift` |
| 1350 | `Native/AmbitionsTests/Domain/AmbitionsMoatScenarioProof98Tests.swift` |
| 1348 | `Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift` |
| 1223 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackRemoteTransportTests.swift` |
| 1218 | `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift` |
| 1216 | `Native/AmbitionsTests/LocalRuntimeOS/Inspection/ActionClosureReceiptModelsTests.swift` |
| 1173 | `Native/AmbitionsTests/Domain/LifeKnowledgeOperationModelsTests.swift` |

## Split / Quarantine Decision

Selected support quarantine:

- `Native/AmbitionsUITests/AmbitionsUITests.swift`

Decision:

- Do not mechanically split this file in AMB-1818 without UI-test discovery,
  build, or simulator proof.
- Quarantine it in the new guard support queue as the current top support-file
  cleanup candidate.
- Treat follow-up work as a separate UI-test monolith split leaf with XCTest/UI
  discovery proof when testing is re-enabled or separately authorized.

Reasoning:

- Production source has no over-cap file.
- The largest support candidate is a UI test monolith with test discovery,
  helper visibility, launch URL, screenshot, and simulator behavior risk.
- Existing `docs/qa/ui-tests/amb-1813-ui-test-monolith-split-inventory.md`
  already shows the UI-test monolith has required focused-lane handling.
- Under the current no-testing instruction, splitting test declarations or
  helpers would create unproved XCTest discovery risk.

## Validation

Commands completed:

- `python3 scripts/ambitions-remediation-governance-check.py --self-test`
  - passed.
- `python3 scripts/ambitions-remediation-governance-check.py`
  - passed with `production_swift_files=1425`, `support_swift_files=475`,
    `support_over_hard_line_cap_files=41`, `overHardLineCapFiles=0`, and
    `changed_paths=1`.
- `python3 scripts/ambitions-remediation-governance-check.py --json`
  - passed and emitted the support queue.

Additional commands completed:

- `git diff --check`
  - passed.
- `jq -e . docs/audits/amb-1818-file-size-cleanup-queue.json`
  - passed.
- `npx markdownlint-cli2 --no-globs docs/audits/amb-1818-file-size-cleanup-queue.md`
  - passed with `0` errors.
- `python3 scripts/ambitions-unsupported-claim-scan.py
  docs/audits/amb-1818-file-size-cleanup-queue.md
  docs/audits/amb-1818-file-size-cleanup-queue.json`
  - passed.
- `scripts/release-claim-safety-scan.sh
  docs/audits/amb-1818-file-size-cleanup-queue.md
  docs/audits/amb-1818-file-size-cleanup-queue.json`
  - passed.
- `scripts/ambitions-xcodegen-needed.sh`
  - passed with `XCODEGEN_NEEDED=0`.
- `python3 scripts/ambitions-architecture-inventory.py`
  - passed with final-tree parity.
- `python3 scripts/ambitions-vocabulary-drift-scan.py`
  - passed.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py`
  - passed.
- `python3 scripts/ambitions-green-standard-audit.py`
  - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py`
  - passed.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py`
  - passed.
- `python3 scripts/ambitions-screenshot-artifact-audit.py`
  - passed as a static guard; no screenshot artifact was produced.
- `python3 scripts/ambitions-device-proof-required.py`
  - passed as a static guard; no device proof was produced.
- `scripts/no-unsupported-ai-claim-scan.sh
  docs/audits/amb-1818-file-size-cleanup-queue.md
  docs/audits/amb-1818-file-size-cleanup-queue.json`
  - completed with advisory hits reviewed as context and non-claims.
- `scripts/privacy-boundary-scan.sh
  docs/audits/amb-1818-file-size-cleanup-queue.md
  docs/audits/amb-1818-file-size-cleanup-queue.json`
  - completed with advisory hits reviewed as context and non-claims.

Commands not run by current user authorization:

- focused XCTest
- UI test discovery
- full XCTest
- build
- simulator
- screenshot capture
- physical device
- performance
- signed archive
- App Store Connect validation

## Proof Ceiling

Allowed claims:

- AMB-1818 produced the current production and support file-size queues from live
  source.
- The remediation guard now reports a nonblocking support/test oversize queue.
- No production Swift file currently exceeds the hard line cap.

Forbidden claims:

- repo-wide file-size cleanup Green
- support/test monolith cleanup complete
- UI-test monolith split complete
- focused tests passed
- build validation passed
- simulator validation passed
- device proof exists
- release proof exists
- TestFlight readiness
- App Store readiness
- Release Green

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: governance script, audit docs.
- Files moved or created: audit packet only.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remains: production files close to the 600-line cap,
  `41` support/test files over the support queue threshold, and unrun
  test/build/simulator proof.
- Next repair train if debt remains: split `Native/AmbitionsUITests/AmbitionsUITests.swift`
  into focused UI-test lanes with XCTest discovery proof, or take the next
  production file before it crosses the hard cap.
- Equivalent folder/path interpretation used: no.
