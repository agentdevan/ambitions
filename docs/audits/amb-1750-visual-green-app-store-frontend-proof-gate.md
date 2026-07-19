# AMB-1750 Visual Green / App Store Frontend Proof Gate

Status: Ready for review
Date: 2026-07-04
Scope: AMB-1750, Architecture Simplification + Flagship Readiness Remediation
Baseline SHA: `e445cbfe35c9549d7514ab2fa39458fcfdc8d778`
Linear status before execution: `Spec Ready`

## Purpose

AMB-1750 installs the release-facing frontend proof gate. Release evidence can
now name frontend quality only through an explicit Green, Yellow, or Red status,
and the current status is Yellow.

This is a gate, not frontend release proof. It does not produce the current
rendered screenshot matrix, independent visual review, manual VoiceOver review,
Dynamic Type screenshot review, Reduce Motion walkthrough, physical iPhone
evidence, signed archive validation, live support/privacy URLs, App Store
Connect validation, or sibling frontend recovery completion.

## Release Packet Wiring

Retained artifacts:

- Gate source: `Native/Ambitions/Quality/ReleaseFrontendProofGate.swift`
- Gate tests: `Native/AmbitionsTests/Quality/ReleaseFrontendProofGateTests.swift`
- RC decision report:
  `Native/Ambitions/Support/ReleaseCandidateLockDecisionReport.swift`
- External truth packet:
  `Native/Ambitions/Support/ReleaseExternalTruthReadinessPacket.swift`
- Audit manifest:
  `docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.json`
- Audit packet:
  `docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.md`

The RC decision report now includes blocker
`frontend-visual-app-store-proof`. The external truth packet summary now keeps
frontend quality blocked at Yellow until human/device gates are complete.

## Required Proof Before Frontend Green

AMB-1750 requires current evidence for:

- Root shell, Capture, Today, Goals, Time, You, inspection details, and key
  empty/error/offline screenshots.
- Root/Capture/Today/Goals/Time/You journey proof plus inspection details.
- Manual VoiceOver, focus order, semantic grouping, contrast, tap-target, and
  non-color meaning review.
- Accessibility-size Dynamic Type screenshots and clipping/overlap review.
- Reduce Motion static-equivalent review for release-critical paths.
- Physical iPhone proof for visual fit, safe areas, keyboard behavior, device
  performance, and device-sensitive submission claims.
- Sibling frontend recovery dependencies: AMB-1733 through AMB-1744, AMB-1749,
  and AMB-1751.
- Strict separation between Accepted Yellow / Ready for Review evidence and
  Green release claims.

## Acceptance Mapping

| AMB-1750 acceptance criterion | Current result |
| --- | --- |
| Release proof states whether frontend quality is Green, Yellow, or Red. | Present. `ReleaseFrontendProofGate.currentStatus` is Yellow and is referenced by the RC decision report and external truth packet. |
| Accepted Yellow is not counted as Green. | Present. `acceptedYellowCountsAsGreen` is false and the gate includes an explicit Accepted Yellow separation requirement. |
| Device-sensitive claims require device evidence. | Present. `deviceSensitiveClaimsRequireDeviceEvidence` is true and the device requirement is blocked until physical-device evidence exists. |
| The sibling frontend recovery project is linked as a release dependency. | Present. AMB-1749, AMB-1744, AMB-1743, AMB-1733 through AMB-1742, and AMB-1751 are listed as release dependencies. |

## Test Duration Finding

The AMB-1749/AMB-1750 split is also the answer to the current test-duration
issue. The test bodies themselves are fast; Xcode project/scheme/package,
simulator, result-bundle, and evidence-extraction overhead dominate focused
test wall time.

Observed during this execution:

- Wrapper focused test of `AmbitionsTests/RuntimeDoctorTests`: 7 tests ran in
  `0.111s`, while wall time was `60.51s`.
- Direct project `xcodebuild test-without-building`: 7 tests ran in `0.240s`,
  while wall time was `51.03s`.
- Direct `.xctestrun` execution from an existing build-for-testing bundle: 7
  tests ran in `0.402s`, while wall time was `18.63s`.

Root causes:

- The Ambitions scheme still loads a broad project graph that includes the app,
  widget, share extension, unit tests, UI tests, and coverage settings.
- `scripts/ambitions-xcode-test-focused.sh` uses the full project/scheme path,
  result bundles, simulator health checks, and result extraction.
- `scripts/ambitions-xcode-result-extract.sh` extracts attachments,
  screenshots, logs, and coverage whenever a result bundle exists.
- Xcode still resolves the local Swift package graph for focused invocations.

AMB-1749 separates fast local checks from screenshot/release lanes. AMB-1750
keeps slow visual, accessibility, and device proof out of ordinary unit-test
Green.

## Proof Ceiling

Claim status for AMB-1750: Implemented Yellow / Ready for review.

Allowed claim:

- Current repo now has a release-facing frontend proof gate that keeps frontend
  quality Yellow, prevents Accepted Yellow from counting as Green, requires
  device evidence for device-sensitive claims, and wires the gate into release
  decision packets.

Forbidden claims from this packet:

- current rendered screenshot coverage
- rendered visual quality
- accessibility conformance
- physical-device behavior
- frontend Visual Green
- TestFlight submission readiness
- App Store submission readiness
- Release Green
- sibling frontend recovery completion

## Validation

Validation run for this packet:

- `python3 -m py_compile scripts/ambitions-frontend-evidence-harness.py`:
  passed.
- `git diff --check`: passed.
- `xcodegen generate`: passed.
- `python3 scripts/ambitions-remediation-governance-check.py`: passed.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py`: passed.
- `python3 scripts/ambitions-unsupported-claim-scan.py Native/Ambitions/Quality/ReleaseFrontendProofGate.swift Native/AmbitionsTests/Quality/ReleaseFrontendProofGateTests.swift Native/Ambitions/Support/ReleaseCandidateLockDecisionReport.swift Native/AmbitionsTests/App/ReleaseCandidateLockDecisionReportTests.swift Native/Ambitions/Support/ReleaseExternalTruthReadinessPacket.swift Native/AmbitionsTests/App/ReleaseExternalTruthReadinessPacketTests.swift docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.md docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.json`:
  passed.
- `python3 scripts/ambitions-screenshot-artifact-audit.py`: passed.
- `python3 scripts/ambitions-device-proof-required.py`: passed.
- `bash scripts/release-claim-safety-scan.sh`: passed.
- `python3 scripts/ambitions-copy-contract-lint.py`: passed.
- `scripts/ambitions-xcode-validate.sh --batch AMB_1750_FRONTEND_RELEASE_PROOF_GATE --lane focused-test --test AmbitionsTests/ReleaseFrontendProofGateTests,AmbitionsTests/ReleaseCandidateLockDecisionReportTests,AmbitionsTests/ReleaseExternalTruthReadinessPacketTests --json`:
  passed; 16 focused tests, prebuild required, 574 seconds wall time.

## Closeout Notes

- Private Life Orchestration relationship: preserved. The gate protects the
  proof side of `Intent -> Context -> Path -> Time Fit -> Reflow -> Action ->
  Proof -> Learning` by keeping frontend quality evidence separate from
  architecture/source proof.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `App/`, `Stage/`, `DesignSystem/`,
  `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`,
  `Composer/Capture`, `Trust/`, `Quality/`, and release support.
- Canonical owners touched: `Quality/` and release support.
- Files created:
  `Native/Ambitions/Quality/ReleaseFrontendProofGate.swift`,
  `Native/AmbitionsTests/Quality/ReleaseFrontendProofGateTests.swift`,
  `docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.json`, and
  `docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.md`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: current rendered screenshot, manual accessibility,
  independent visual review, and physical-device proof remain required before
  frontend Green or release claims.
- Next proof train: complete the sibling frontend recovery proof lanes and
  current device/visual/accessibility evidence before promoting release claims.
- No equivalent folder/path interpretation was used.
