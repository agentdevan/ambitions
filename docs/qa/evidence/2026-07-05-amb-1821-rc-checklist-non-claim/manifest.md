# AMB-1821 Release Candidate Checklist Non-Claim Packet

Status: Blocked / Not Ready for Release Candidate; Implemented Yellow / Ready For Review for this checklist packet only
Date: 2026-07-05T16:17:19Z
Branch: `main`
Baseline main SHA: `0081eb05c47f8ba38d90d4257169df01b7a79725`
Commit SHA: artifact commit SHA is recorded in Linear after commit/push
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Simulator or device: simulator tooling proof exists from the current XcodeBuildMCP/simulator preflight repair packet, but no app build, app launch, XCTest, focused test, UI screenshot run, archive, upload, or physical-device procedure is claimed for AMB-1821
Exit code(s): listed in Validation Run below
Artifact paths: this manifest and `docs/qa/evidence/2026-07-05-amb-1821-rc-checklist-non-claim/rc-checklist.json`
Parent: `AMB-1700` Parent Feature - Release Candidate Gate
Issue: `AMB-1821` Release Candidate Leaf - RC checklist non-claim packet

## Scope

This packet creates the first Release Candidate checklist/evidence bundle that
blocks TestFlight, App Store, Release Green, and release-readiness claims until
current proof exists for every required gate.

This is docs/control-plane and QA evidence scaffolding only. It does not change
Swift source, XcodeGen project source, Package.swift, signing configuration,
runtime behavior, rendered UI, privacy behavior, account behavior, R2 behavior,
device behavior, archive/export behavior, upload behavior, or release behavior.

## Release Claim Rule

`docs/truth/RELEASE_TRUTH.md` is the authority:

```text
If proof is absent, readiness is absent.
```

This packet records absence honestly. It is not release proof.

## Checklist Summary

| Gate | Required current proof before RC Green | Current AMB-1821 state | Blocking owner / follow-up |
| --- | --- | --- | --- |
| Metadata bundle | Branch, commit, environment, Xcode, destination, commands, exit codes, artifacts, skipped checks, non-claims. | Partial for this packet only; final artifact commit is recorded after commit/push. | This packet plus future RC evidence bundle. |
| XcodeGen generation | `xcodegen generate` at the release candidate commit. | Not run. | Future RC run. |
| Package resolution | `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies`. | Not run. | Future RC run. |
| Simulator preflight | `scripts/ambitions-xcode-sim-health.sh --json --timeout 30s` at the RC commit. | Tooling preflight was verified before this packet, but not as RC app proof. | Future RC run. |
| Debug simulator build | `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO`. | Not run. | Future RC run. |
| Build for testing | `scripts/ambitions-xcode-build-for-testing.sh --batch <RC_BATCH>`. | Not run. | Future RC run. |
| Test plans | Smoke, Runtime, Accessibility, Screenshots, and ReleaseCandidate plans configured and run. | Not run; test-plan architecture still open. | `AMB-1691`; future RC run. |
| Focused runtime and system tests | Current focused proof for touched runtime, storage, projection, adapter, privacy, and system-surface risks. | Not run. | `AMB-1665`, `AMB-1668`, `AMB-1687`, `AMB-1688`, `AMB-1690`, `AMB-1705`. |
| UI screenshots and visual review | Current screenshots tied to build SHA, target comparison, and independent visual acceptance. | Not run. | Visual review owner and future screenshot packet. |
| Accessibility | VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, accessible actions, and keyboard/safe-area proof where relevant. | Not run. | Accessibility owner and future accessibility packet. |
| Physical device matrix | Physical-device or explicitly scoped device proof for release-sensitive behavior. | Not run. | `AMB-1701`, `AMB-1822`. |
| Privacy manifest and App Store disclosure | Current data-flow inventory, `PrivacyInfo.xcprivacy` review, accessed API reasons, App Store disclosure mapping, privacy/legal approval. | Not run. | `AMB-1683`, `AMB-1685`, `AMB-1758`. |
| Account and identity | Sign in with Apple / Google Sign-In implementation and entitlement proof if claimed. | Not run; no account readiness claimed. | Account launch owner; future release packet. |
| Source Atlas / R2 boundary | Public/reference/freshness-only request-shape proof; no private life graph egress; production credential/deployment proof if claimed. | Not run; no production R2 or Source Atlas readiness claimed. | `AMB-1682`, `AMB-1725` through `AMB-1728`, `AMB-1762`. |
| System surfaces | Widgets, App Intents, Share Extension, notifications, EventKit/Reminders, App Group, and lifecycle proof. | Not run. | `AMB-1685`, `AMB-1687`, `AMB-1688`, `AMB-1690`, `AMB-1701`, `AMB-1822`. |
| Archive sanity | Unsigned archive or approved signed archive at the RC commit, with logs and exit code. | Not run. | Future RC run. |
| App Store Connect validation | Human-approved signed archive validation in Xcode Organizer or equivalent App Store Connect proof. | Not run. | Release owner; future Apple-side proof. |
| TestFlight upload | Human-approved upload and processing proof. | Not run. | Release owner; future Apple-side proof. |
| Known-risk delta | Current delta from risk ledger and accepted Yellow residuals. | Present as blocker references, not burn-down. | `AMB-1824`, `AMB-1760`, `AMB-1705`. |
| Rollback plan | Rollback plan template tied to the exact RC artifact and commit. | Template included below; not exercised. | Future RC owner. |
| Human approvals | Release owner, privacy/legal, visual, accessibility, and device-proof approvals where required. | Not obtained. | Required before release claims. |

## Required Future RC Command Set

The future RC evidence bundle must record exact commands, exit codes, and
artifact paths. The minimum command set is:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies
scripts/ambitions-xcode-sim-health.sh --json --timeout 30s
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "<simulator>" build CODE_SIGNING_ALLOWED=NO
scripts/ambitions-xcode-build-for-testing.sh --batch <RC_BATCH>
scripts/ambitions-xcode-test-focused.sh --batch <RC_BATCH> --test <SCOPED_TEST_ID>
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -configuration Release -destination "generic/platform=iOS" -archivePath output/Ambitions.xcarchive CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY="" archive
```

Additional test-plan, screenshot, accessibility, device, privacy/legal,
signing, archive validation, App Store Connect, and TestFlight procedures are
required before any Release Green, TestFlight readiness, or App Store readiness
claim.

## Rollback Plan Template

For any future RC candidate, the release packet must include:

- RC commit SHA and tag, if any.
- Exact artifact paths for build logs, result bundles, screenshots, archive,
  export, and upload records.
- Known-risk delta since the previous candidate.
- Revert commit or branch reset plan.
- Data migration rollback/forward policy, if migration is included.
- App Store Connect/TestFlight rollback or phased-release stop procedure, if
  upload/distribution occurs.
- Owner approval for rollback responsibility.

This AMB-1821 packet does not exercise a rollback.

## Validation Run

Completed for this checklist packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `git diff --check` | 0 | Passed after packet creation. |
| `python3 -m json.tool docs/qa/evidence/2026-07-05-amb-1821-rc-checklist-non-claim/rc-checklist.json` | 0 | Passed after packet creation. |
| `python3 scripts/ambitions-release-non-claim-gate.py docs/qa/evidence/2026-07-05-amb-1821-rc-checklist-non-claim/manifest.md docs/qa/evidence/2026-07-05-amb-1821-rc-checklist-non-claim/rc-checklist.json` | 0 | Passed after packet creation; `release_facing_packets_checked=2`. |
| `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` | 0 | Passed after packet creation. |
| `python3 scripts/ambitions-unsupported-claim-scan.py docs/qa/evidence/2026-07-05-amb-1821-rc-checklist-non-claim/manifest.md docs/qa/evidence/2026-07-05-amb-1821-rc-checklist-non-claim/rc-checklist.json` | 0 | Passed after packet creation. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed after packet creation; `changed_paths=2`, `production_swift_files=1421`, `overHardLineCapFiles=0`. |

## Validation Not Run

- XcodeGen, xcodebuild package resolution, xcodebuild build, xcodebuild test,
  build-for-testing, focused tests, test plans, UI screenshots, app launch,
  manual simulator walkthrough, physical-device procedure, accessibility
  walkthrough, performance profiling, privacy/legal review, account/R2
  production proof, signed archive, App Store validation, TestFlight upload,
  archive export, and release approval were not run for AMB-1821 under the
  current user instruction authorizing issue completion without testing until
  advised otherwise.

## Non-Claims

- No Release Candidate readiness.
- No Release Green.
- No build success, test success, build-for-testing success, archive success,
  app launch proof, screenshot proof, accessibility conformance, device proof,
  privacy/legal approval, account readiness, R2 readiness, Source Atlas
  production readiness, TestFlight readiness, App Store readiness, upload
  readiness, or product completion.
- This packet creates a blocker checklist only. It does not satisfy the
  checklist.
- `AMB-1700` remains In Progress until the full release-candidate gate has
  executable/artifact proof, not just this checklist.
- `AMB-1705` remains Needs Repair.

## Proof-Claim Labels Used

- Release-proof claim: not verified; blocked by missing current RC evidence.
- Device-proof claim: not verified; blocked by `AMB-1701` / `AMB-1822` and no
  physical-device procedure.
- Privacy-proof claim: not verified; blocked by `AMB-1683`, `AMB-1685`, and no
  privacy/legal approval.
- Accessibility-proof claim: not verified; no accessibility walkthrough or
  artifact proof.
- Performance-proof claim: not verified; no profiling or performance evidence.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in Swift source; QA evidence only.
- Files moved or created: this manifest and a paired JSON checklist.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture/proof debt remains: yes. The packet exists specifically
  to keep release proof debt visible.
- Next repair train if debt remains: execute `AMB-1822`, `AMB-1691`, `AMB-1683`,
  system-surface proof owners, and the full `AMB-1700` release gate before
  release claims.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.

## Rollback

Revert this evidence folder. Move `AMB-1821` back to `Ready For Codex` or
`Needs Repair` if the checklist no longer blocks unsupported RC/TestFlight/App
Store claims.
