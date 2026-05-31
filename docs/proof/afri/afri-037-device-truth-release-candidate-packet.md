# AFRI-037 Device-Truth Release Candidate Packet

Issue: AMB-389 / AFRI-037  
Date: 2026-05-31  
Commit under validation: `2731e487a`

## Status

Green for creating the release-candidate packet and for current simulator/source evidence captured during AMB-389.

Blocked for release Green. Physical-device validation, signed archive/export validation, human App Store Connect review, legal/privacy review, public accessibility approval, and submission approval are not proven.

Pre-guard status was accepted Yellow because this issue creates a release proof packet and does not change runtime implementation. No duplicate owner, runtime wiring gap, old-term violation, or locked-concept violation was reported.

## Verified

| Gate | Evidence | Status |
| --- | --- | ---: |
| RC packet exists | This file separates verified, failed, not verified, blocked, and human/device follow-up. | Green |
| Current commit captured | `git rev-parse --short HEAD` returned `2731e487a` before AMB-389 packet creation. | Green |
| Privacy manifest proof | AFRI-036 packet records manifest lint, focused privacy/local-runtime tests, and App Store Connect/legal/device blocks. | Green source/simulator evidence |
| Migration proof | `StorageMigrationRecoveryTests` passed 3 tests, 0 failures. Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_19-45-12--0400.xcresult` | Green focused tests |
| UI screenshot smoke | `AmbitionsUITests/AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs` passed 1 test, 0 failures, and attached Today, Goals, Capture, Time, and You screenshots. Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_19-47-21--0400.xcresult` | Green simulator UI test |
| Screenshot helper smoke | `bash scripts/visual-qa/capture_matrix.sh --smoke --output-dir output/visual-qa/afri-037-rc-smoke` produced a Green report and three PNGs for `today-normal`, `today-recovery`, and `you-reduce-motion`. | Green simulator helper evidence |
| Accessibility evidence | AFRI-034 packet records source/test accessibility matrix proof and keeps public accessibility claims blocked until manual proof exists. | Green source/test evidence, public claim blocked |
| Performance/observability evidence | AFRI-035 packet records focused performance/local diagnostic tests and keeps release-grade performance claims blocked. | Green source/test evidence, performance claim blocked |

## Failed

No AMB-389 validation command failed.

## Not Verified

- Full unit test suite.
- Full UI test suite.
- Full 18-state screenshot matrix during AMB-389.
- Real device install, launch, permission prompt, widget, Live Activity, notification, App Intent, Spotlight, share extension, and App Group I/O behavior.
- Signed archive, export, notarization-equivalent submission validation, or uploaded build review.
- Manual VoiceOver traversal, Dynamic Type device-band screenshots, Reduce Motion walkthrough, Increase Contrast measured pass, tap-target/motor review, and non-color visual review.
- Memory/performance measurement with Instruments, memory graph, battery, thermal, launch timing, or scroll/render timing.
- Human App Store Connect privacy questionnaire completion.
- Human legal/privacy approval.

## Blocked

Release Green is blocked until all of the following have current evidence:

1. Physical-device matrix with device model, OS version, install source, bundle id, and pass/fail result.
2. Signed archive/export validation tied to the exact build submitted for review.
3. App Store Connect privacy labels reconciled to the final signed binary, permission prompts, support URL, and privacy URL.
4. Manual accessibility review covering VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, motor access, and non-color meaning.
5. Screenshot set captured from the final submitted build with privacy-safe data and human visual approval.
6. Widget, Live Activity, notification, App Intent, Spotlight, share extension, and App Group behavior checked on device where the platform feature requires it.
7. Migration rehearsal against representative persisted stores or an owner-approved no-user-data release rationale.
8. Legal/privacy and human release owner approval.

## Human / Device Follow-Up

- Run the device matrix on at least the intended minimum and current flagship iPhone-class OS/device combinations.
- Export and inspect screenshots from the final candidate build, not only simulator smoke runs.
- Confirm all permission prompts match App Store Connect declarations before submission.
- Attach signed archive/export logs and App Store Connect validation artifacts to the final release packet.
- Record manual accessibility review notes with screenshots or screen recordings where relevant.
- Review known limitations with the release owner before any public submission claim.

## Validation Log

- Pre guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-389 --batch-type guard-repair --prompt /tmp/AMB-389-AFRI-037-guard-prompt.md`
  - Result: Yellow, accepted for proof-only packet boundary.
  - Report: `build/reports/parallel-implementation-guard/AMB-389-pre.md`
- Screenshot helper smoke: `bash scripts/visual-qa/capture_matrix.sh --smoke --output-dir output/visual-qa/afri-037-rc-smoke`
  - Result: Green.
  - Report: `output/visual-qa/afri-037-rc-smoke/visual-qa-matrix-report.md`
- Migration tests: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/StorageMigrationRecoveryTests`
  - Result: 3 tests, 0 failures.
- UI screenshot smoke: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs`
  - Result: 1 test, 0 failures.

## Claim Boundaries

This packet does not make a release, TestFlight, App Store, physical-device, public accessibility, performance, legal/privacy, CI, signed-build, or human-approval claim.

It only records current local simulator/source evidence and the gates still required before any release Green status can be claimed.

## Rollback

Revert this packet. Release Green remains blocked with or without this packet until the missing device, signed-build, human, and submission evidence exists.
