# AMB-522 Internal TestFlight Readiness Review

Status: Green
Readiness decision: Not ready
Branch: `main`
Base SHA: `5abee8fd58fd070f45305abf85ca88eb73a927b6`
Run directory: `.codex/runs/AMB-522/20260606T055534Z`

## Scope

AMB-522 is a gated review packet for whether the frontend maturity packet train is ready for an internal TestFlight approval decision.

No upload was attempted. No TestFlight, App Store, release, accessibility, performance, privacy/legal, device, CI, or human-approval readiness claim is made.

## Active Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Files Changed

- `prompts/batches/AMB-522.md`
- `docs/codex/reports/AMB-522-internal-testflight-readiness-review.md`
- `Sources/Components/NavigationPrimitives.swift`
- `Sources/Previews/ComponentPreviews.swift`
- `Sources/Previews/SI03ShellNavigationPreviews.swift`
- `Sources/Previews/SignatureInterfaceVisualQAPreviews.swift`
- `Native/Ambitions/Features/Shared/ActivationContract.swift`
- `Native/Ambitions/Support/CrossSurfaceContinuityMaturityReport.swift`
- `Native/Ambitions/Support/ReleaseDeviceQAReadinessReport.swift`
- `Native/Ambitions/Support/ReleaseExternalTruthReadinessPacket.swift`
- `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift`
- `Native/AmbitionsTests/App/GroupedNavigationListDesignSystemTests.swift`
- `Native/AmbitionsTests/App/OnboardingAndDegradedStateTests.swift`
- `Native/AmbitionsTests/App/ReleaseExternalTruthReadinessPacketTests.swift`
- `docs/codex/concept-lock-registry.yml`

## Why

- The checked-in AMB-522 runner prompt was missing exact runtime inspection terms required by the live Linear issue and the guard: `SourceRecord`, `Receipt`, `ReplayTrace`, and `You / What Ambitions knows`.
- The prompt was repaired to match Linear before runner execution.
- The AMB-522 runner completed Phase 01 Green, then stopped Yellow before patching because the locked-path precheck saw an unauthorized candidate `Sources` path in planning context.
- Phase 01 surfaced stale release/support wording that still treated Capture as a top-level destination.
- The user explicitly asked to repair until Green, so this repair updated the scoped readiness/support copy and shared navigation primitive contract from `Today / Goals / Capture / Time / You` to `Today / Goals / Time / Motion / You` plus global Capture.

## Dependency Review

| Packet | Latest status used for AMB-522 | Evidence source | Blocking for AMB-522 |
|---|---|---|---|
| AMB-508 Packet 0R | Green | `docs/codex/reports/AMB-508-packet-0r-closeout.md` | No |
| AMB-509 Packet 1 | Accepted Yellow | Linear closeout comment, commit `cefcf0af9578d62f37b0bc219f0f492e06c6d16f` | No |
| AMB-510 Packet 2 | Green | Linear closeout comment, commit `c54e8eab1fe40ff23262153ef2b48a621a0f16f2` | No |
| AMB-511 Packet 3 | Accepted Yellow | Linear closeout comment, commit `adf5cade21ab5520a4a03da04e24b18c42ef629c` | No |
| AMB-512 Packet 4 | Green | Linear closeout comment, commit `30cd74885ae655e3be01386e3f7526c8c98b3f9b` | No |
| AMB-513 Packet 5 | Green after repair | Linear closeout comment, commit `7727f0c69bdc7725601391ca9eeae9c6825353e6` | No |
| AMB-514 Packet 6 | Accepted Yellow | Linear closeout comment, commit `9722fccb1e8978982f9ce30e3c6a21ef14b81c61` | No |
| AMB-515 Packet 7 | Accepted Yellow | Linear closeout comment, commit `434b423e400d72716270d653fe680ffb410ccb39` | No |
| AMB-516 Packet 8 | Accepted Yellow | Linear closeout comment, commit `5a17b3681c0e62f282e6163b78a3c07ac65fdf30` | No |
| AMB-517 Packet 9 | Accepted Yellow | Linear closeout comment, commit `f3c3d8868b13e64e79d7ef6a907a6a0ede114f64` | No |
| AMB-518 Packet 10 | Green | Linear closeout comment, commit `924bd454e15929fe904784ce952b2aefcd1c0c06` | No |
| AMB-519 Packet 11 | Green | Linear closeout comment and report, commit `d4d1de11564d29d85b8ac84bc3dea91862991727` | No |
| AMB-520 Packet 12 | Accepted Yellow | `docs/codex/reports/AMB-520-packet-12-visual-proof-closeout.md`, commit `d6d8066ba993556ad499c92e4b22c4293ffb123e` | No, but carries readiness gaps |
| AMB-521 Packet 13 | Green | `docs/codex/reports/AMB-521-packet-13-rename-migration-closeout.md`, commit `5abee8fd58fd070f45305abf85ca88eb73a927b6` | No |

Older runner-status Red/Unknown files were treated as superseded when later Linear closeouts, current commits, current source, and current guard evidence proved the packet had been repaired and closed.

## Verified

- AMB-520 and AMB-521 are `Done` in Linear.
- AMB-521 is attached to the current base commit `5abee8fd58fd070f45305abf85ca88eb73a927b6`.
- Current runtime app shell source is `Today / Goals / Time / Motion / You`.
- `Native/Ambitions/App/AppTab.swift` keeps `.capture` as compatibility, but `AppTab.allCases` is `[.today, .goals, .time, .motion, .you]`.
- `Native/Ambitions/App/AmbitionsRootView.swift` renders Today, Goals, Time, Motion, and You tabs.
- AMB-520 produced a staged proof matrix under `docs/audits/screenshots/AMB-520/AMB-520-proof-matrix.md`.
- AMB-520 did not accept or bulk-update screenshot baselines.
- AMB-520 explicitly did not claim rendered screenshot proof, human visual approval, manual accessibility traversal, simulator/device accessibility proof, tap-target measurement, performance proof, privacy/legal proof, device proof, TestFlight proof, App Store proof, or release proof.
- AMB-521 repaired active surface-contract naming to `Direction Atlas` and `Personal Runtime` while preserving compatibility wrappers.
- No TestFlight upload or release-facing external state change occurred in AMB-522.

## Readiness Approval Gaps

These block an internal TestFlight approval action.

1. Human approval is absent.
2. Signed archive, TestFlight upload, App Store Connect validation, and release candidate evidence are absent and were intentionally not attempted.
3. AMB-520 visual proof remains staged, not rendered/human-reviewed.
4. Manual VoiceOver traversal is absent.
5. Dynamic Type, Reduce Motion, Increase Contrast, Reduce Transparency, Differentiate Without Color, and tap-target proof remain staged or source/test-backed only.
6. Physical-device proof is absent.
7. Performance proof is incomplete beyond helper/status evidence and focused packet claims.
8. Privacy/legal approval is absent.
9. AMB-520 rendered screenshot and human visual review gaps remain unresolved.
10. Human TestFlight approval criteria have not been supplied.

## Green Reason

AMB-522 is Green for review execution because the repairable stale-IA source blocker was corrected, guards passed, no upload occurred, and no readiness overclaim is made.

The readiness decision remains `Not ready` because human/device/release proof is still absent. That is a review finding, not an AMB-522 execution failure.

## Internal TestFlight Review Appendix

Required output: `Not ready`.

Reason:
- The packet train has several Green or accepted-Yellow source/proof closeouts and no dependency blocker that prevents AMB-522 review itself.
- The app shell source now reflects the active top-level IA.
- However, the review inputs do not establish internal TestFlight approval readiness.
- Human approval is missing.
- Release/support source now uses `Today / Goals / Time / Motion / You` with Capture as the global action where relevant.
- Screenshot, visual, manual accessibility, device, performance, privacy/legal, signed archive, and TestFlight/App Store evidence are not complete.

Not ready means no internal TestFlight action should be taken from this packet. It does not mean the frontend maturity packet execution failed; it means human/device/release approval evidence is incomplete and must be supplied before a readiness approval decision can be made.

## Validation

Run before this report:

- `git status --short --branch`
- `git rev-parse HEAD`
- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-522` -> GREEN
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-522 --prompt prompts/batches/AMB-522.md --batch-type source-changing` -> initial RED for missing prompt terms; GREEN after prompt repair
- `ALLOW_DIRTY=1 BATCH_TYPE=proof-only AUTO_BRANCH=0 AUTO_COMMIT=0 AUTO_PUSH=0 ALLOW_MAIN_COMMIT=1 ALLOW_YELLOW_COMMIT=1 KEEP_GOING_ON_YELLOW=1 MAX_REPAIR_PASSES=1 scripts/ambitions-codex-train.sh AMB-522 prompts/batches/AMB-522.md` -> final YELLOW, Phase 01 GREEN, stopped before patch on locked-path precheck
- Direct source reads of `Native/Ambitions/App/AppTab.swift`, `Native/Ambitions/App/AmbitionsRootView.swift`, `Native/Ambitions/Support/ReleaseExternalTruthReadinessPacket.swift`, and `Native/AmbitionsTests/App/ReleaseExternalTruthReadinessPacketTests.swift`
- Targeted stale/readiness scan with `rg`

Run after this report:

- `git diff --check` -> passed
- `bash -n scripts/ambitions-codex-train.sh` -> passed
- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-522` -> GREEN
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-522 --prompt prompts/batches/AMB-522.md --batch-type source-changing` -> GREEN
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-522 --prompt prompts/batches/AMB-522.md --changed-from 5abee8fd58fd070f45305abf85ca88eb73a927b6 --batch-type source-changing` -> GREEN
- `make xcode-build-for-testing BATCH=AMB-522` -> passed, `** TEST BUILD SUCCEEDED **`
- `make xcode-focused-test BATCH=AMB-522 TEST=AmbitionsTests/ReleaseExternalTruthReadinessPacketTests` -> passed, 6 tests, 0 failures
- `make xcode-focused-test BATCH=AMB-522 TEST=AmbitionsTests/OnboardingAndDegradedStateTests` -> passed, 10 tests, 0 failures
- `make xcode-focused-test BATCH=AMB-522 TEST=AmbitionsTests/GroupedNavigationListDesignSystemTests` -> passed, 5 tests, 0 failures
- `make xcode-focused-test BATCH=AMB-522 TEST=AmbitionsTests/ReleaseDeviceQAReadinessReportTests` -> passed
- `make xcode-focused-test BATCH=AMB-522 TEST=AmbitionsTests/ReleasePerformanceResponsivenessReportTests` -> passed
- `make xcode-focused-test BATCH=AMB-522 TEST=AmbitionsTests/AppShellChromeTests` -> passed, 11 tests, 0 failures
- Targeted stale top-level IA scan after repair -> no current source hit for `Today, Goals, Capture, Time, and You` or `Today / Goals / Capture / Time / You`

## Not Verified

- `xcodegen generate`
- `./scripts/build-local.sh`
- Raw `xcodebuild`
- Full XCTest suite
- Rendered screenshots
- Screenshot baseline approval
- Human visual review
- Manual VoiceOver traversal
- Device or simulator accessibility variant proof
- Tap-target measurement
- Performance benchmark proof
- Physical-device behavior
- Privacy/legal approval
- Signed archive
- TestFlight upload
- App Store Connect validation
- CI proof
- Human approval

## Proof / Claim Boundaries

This report proves only AMB-522 review findings, prompt repair, scoped stale-IA support-copy repair, dependency reconciliation, local build-for-testing success, focused XCTest success for the touched contracts, and explicit no-readiness-claim posture.

It does not prove full app release build success, full suite success, screenshot approval, accessibility conformance, performance readiness, privacy/legal readiness, device readiness, TestFlight readiness, App Store readiness, release readiness, or human approval.

## Red Blockers

None.

Readiness approval gaps remain and are listed above.

## Rollback

Before commit:

```bash
git restore -- prompts/batches/AMB-522.md
rm -f docs/codex/reports/AMB-522-internal-testflight-readiness-review.md
git restore -- Sources/Components/NavigationPrimitives.swift Sources/Previews/ComponentPreviews.swift Sources/Previews/SI03ShellNavigationPreviews.swift Sources/Previews/SignatureInterfaceVisualQAPreviews.swift Native/Ambitions/Features/Shared/ActivationContract.swift Native/Ambitions/Support/CrossSurfaceContinuityMaturityReport.swift Native/Ambitions/Support/ReleaseDeviceQAReadinessReport.swift Native/Ambitions/Support/ReleaseExternalTruthReadinessPacket.swift Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift Native/AmbitionsTests/App/GroupedNavigationListDesignSystemTests.swift Native/AmbitionsTests/App/OnboardingAndDegradedStateTests.swift Native/AmbitionsTests/App/ReleaseExternalTruthReadinessPacketTests.swift docs/codex/concept-lock-registry.yml
```

After commit:

```bash
git revert <AMB-522-commit-sha>
```

## Next Gate

Next eligible Codex command:

```text
Run the internal TestFlight human/device/release evidence packet only after supplying human approval criteria, current screenshots, manual accessibility evidence, physical-device proof, privacy/legal review, and signed archive/TestFlight policy inputs.
```
