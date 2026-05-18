# Release Evidence Packet

Status: evidence posture, not release approval.

This packet records what validation evidence the repo can currently claim and what it cannot claim.

Phase 12 firewall note, 2026-05-10: this packet proves only the current raw
evidence it cites. Docs-only plans, batch reports, train completion, tool maps,
and repo inventory do not prove release status, validation on real hardware,
public accessibility conformance, performance, legal/privacy signoff, hosted
CI, TestFlight, App Store submission, backend/provider activation, or
implementation completeness.

## Current validation posture

Ambitions uses local VM/Mac validation as the source of truth.

There is no active hosted CI workflow in this repo.

## Current evidence sources

| Evidence source | Location / command | Current claim |
| --- | --- | --- |
| Project generation | `xcodegen generate` | Local project generation path exists. |
| Local simulator build | `./scripts/build-local.sh` or equivalent `xcodebuild` command | Local unsigned simulator build path exists. |
| Unit tests | `xcodebuild ... -only-testing:AmbitionsTests test` | Unit test target exists; pass/fail must come from current local logs. |
| UI tests | `xcodebuild ... -only-testing:AmbitionsUITests test` | UI test target exists; pass/fail must come from current local logs. |
| Archive sanity | unsigned `xcodebuild archive` from `docs/native-build-and-release.md` | Unsigned archive sanity path exists; pass/fail must come from current local logs. |
| Manual platform validation | local simulator/device notes | Not proven by repo docs alone. |

## Recent Local Proof Packet

PFC32 closeout, 2026-05-18:

- Branch: `main`
- Commit: `a8b48c130ca8fdc2e79dc82e2daf445e56b80b69`
- Command: `./scripts/build-local.sh`
- Result: exit `0`, `Build Succeeded`
- Log: `output/logs/build-local-20260518-004033.log`
- Scope: local simulator build proof only; no device, signing, TestFlight, App Store, accessibility, privacy, or human-approval claim

PFC33 source-support alignment, 2026-05-18:

- `ReleaseExternalTruthReadinessPacket` now uses canonical top-level IA wording with `Time` instead of `Plan` in release-support copy.
- `ExternalSurfaceVerificationChecklist` now requires the Live Activities fallback route to remain `Time`.
- This alignment updates release-support evidence language only; it does not prove device, accessibility, or release readiness.

PFC33 Phase 04 repair-pass validation, 2026-05-18:

- Branch: `main`
- Commit: `21afcba6f75eebd8fe1acfc959c65bb249bc9da2`
- Command: `./scripts/build-local.sh`
- Result: exit `0`, `Build Succeeded`
- Log: `output/logs/build-local-20260518-013309.log`
- Focused XcodeBuildMCP test reruns for `ReleaseExternalTruthReadinessPacketTests` and `ExternalSurfaceVerificationChecklistTests` timed out in `build-for-testing` before producing a new Phase 04 result bundle.
- GPT-5.5 final-gate XcodeBuildMCP rerun with the same focused test slice and isolated derived data path `output/DerivedData-pfc33-final-gate` also timed out at the 120s wrapper ceiling while the underlying `xcodebuild` remained in `build-for-testing`; the hung process was stopped after observation and no new result bundle was produced.
- Scope: local simulator build proof only; no current focused-test pass, device, signing, TestFlight, App Store, accessibility, privacy, performance, or human-approval claim.

PFC34 privacy/legal reconciliation, 2026-05-18:

- Branch: `main`
- Commit: `3925f2eb9740c44a465ad0367b13e5deea9e1d64`
- Commands:
  - `git status --short`
  - `git diff --check`
  - `make prompt-audit`
  - `make batch-self-check`
  - `plutil -p Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
  - `bash scripts/codex-forbidden-claim-scan.sh docs/audits/pfc34-batch-closeout-report.md docs/status/release-evidence-packet.md 2>/dev/null || true`
  - targeted `rg` scans over `Native`, `Sources`, `AppUI`, `Package.swift`, and `project.yml`
- Result:
  - `git status --short`: `0`, with the two PFC34 docs changes plus the pre-existing `?? .codex/state/global-train.lock`
  - `git diff --check`: `0`
  - `make prompt-audit`: `0`, yellow classification for prompt/support/template files and no active runnable prompt missing metadata
  - `make batch-self-check`: `0`, runner self-check passed
  - `plutil -p Native/Ambitions/Resources/PrivacyInfo.xcprivacy`: `0`, manifest still reports no tracking, no collected data, and no accessed APIs
  - `scripts/codex-forbidden-claim-scan.sh`: `0`, no blocking forbidden-claim hits
  - targeted scans: `0`, no privacy-manifest mismatch or scope violation requiring source-support edits
- Scope: docs/proof reconciliation only; no build, test, device, accessibility, privacy/legal approval, or release-readiness claim

PFC35 security/threat-model reconciliation, 2026-05-18:

- Branch: `main`
- Starting commit: `826b3a1edcb97002ee091388563ddeb0ada32416`
- Phase 03 commit reviewed for repair: `e7e4fe569c95d030f600cfcd30c81a9d92913dd1`
- Commands:
  - `git status --short`
  - `git diff --check`
  - `make prompt-audit`
  - `make batch-self-check`
  - `bash scripts/codex-forbidden-claim-scan.sh docs/audits/pfc35-batch-closeout-report.md docs/status/release-evidence-packet.md 2>/dev/null || true`
  - `bash scripts/cqs-privacy-security-claim-scan.sh docs/audits/pfc35-batch-closeout-report.md 2>/dev/null || true`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies`
- Result:
  - `git status --short`: `0`, with the pre-existing `?? .codex/state/global-train.lock`
  - `git diff --check`: `0`
  - `make prompt-audit`: `0`, `YELLOW: prompt-like support/eval/template files classified; no active runnable prompt missing metadata`
  - `make batch-self-check`: `0`, runner self-check passed
  - `scripts/codex-forbidden-claim-scan.sh`: `0`, no blocking hits
  - `scripts/cqs-privacy-security-claim-scan.sh`: `0`, no hits
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies`: blocked by the session policy wrapper (`approval required by policy, but AskForApproval is set to Never`); no package-resolution proof was produced
- Scope: docs-only proof reconciliation; no build/test/device/accessibility/privacy/legal/release-readiness claim

PFC35 Phase 04 repair-pass validation, 2026-05-18:

- Branch: `main`
- Reviewed commit: `e7e4fe569c95d030f600cfcd30c81a9d92913dd1`
- Result:
  - No source, architecture, claim-language, or scope repair required.
  - `git diff --check`: `0`
  - `make prompt-audit`: `0`, `YELLOW: prompt-like support/eval/template files classified; no active runnable prompt missing metadata`
  - `make batch-self-check`: `0`, runner self-check passed
  - `scripts/codex-forbidden-claim-scan.sh`: `0`, no blocking hits
  - `scripts/cqs-privacy-security-claim-scan.sh`: `0`, no hits
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies`: still blocked before shell execution by the policy wrapper (`approval required by policy, but AskForApproval is set to Never`); no package-resolution proof was produced
- Scope: report/evidence update only; no build/test/device/accessibility/privacy/legal/release-readiness claim

PFC36 performance and observability reconciliation, 2026-05-18:

- Branch: `main`
- Starting commit: `9547af82121a1ec48a9cf62f27de58e484fdd648`
- Commands:
  - `git status --short`
  - `git diff --check`
  - `make prompt-audit`
  - `make batch-self-check`
  - `xcodegen generate`
  - `xcodebuildmcp test_sim` focused on `AmbitionsTests/ReleasePerformanceResponsivenessReportTests`
  - `xcodebuildmcp test_sim` focused on `AmbitionsTests/AmbitionsOSPerformanceEnergyModelsTests`
  - `bash scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift Native/AmbitionsTests/App/ReleasePerformanceResponsivenessReportTests.swift docs/status/release-evidence-packet.md docs/audits/pfc36-batch-closeout-report.md 2>/dev/null || true`
- Result:
  - `git status --short`: `0`, with the four edited batch files plus the pre-existing `?? .codex/state/global-train.lock`
  - `git diff --check`: `0`
  - `make prompt-audit`: `0`, `YELLOW: prompt-like support/eval/template files classified; no active runnable prompt missing metadata`
  - `make batch-self-check`: `0`, runner self-check passed
  - `xcodegen generate`: `0`
  - `ReleasePerformanceResponsivenessReportTests` MCP call timed out at `120s`; underlying result bundle: `Passed`, `6` tests, `0` recorded failures, iPhone 17 simulator, `iOS Simulator 26.3.1`; bundle `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-05-18T07-08-00-828Z_pid38566_98ab36cb.xcresult`
  - `AmbitionsOSPerformanceEnergyModelsTests` MCP call timed out at `120s`; underlying result bundle: `Passed`, `10` total tests recorded in the bundle, `0` recorded failures, iPhone 17 simulator, `iOS Simulator 26.3.1`; bundle `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-05-18T07-13-28-056Z_pid38566_c9620e57.xcresult`
  - Direct shell `xcodebuild ... -only-testing:AmbitionsTests/AmbitionsOSPerformanceEnergyModelsTests test CODE_SIGNING_ALLOWED=NO`: blocked before shell execution by the outer command policy (`approval required by policy, but AskForApproval is set to Never`); MCP-backed bundle proof above is the current test evidence
  - `scripts/codex-forbidden-claim-scan.sh`: `0`, context-only `top-level Plan drift` guard in source; no blocking hits
- Scope: performance/observability source-support reconciliation only; no device, signing, TestFlight, App Store, accessibility, privacy/legal, or release-readiness claim

PFC37 release-engineering evidence reconciliation, 2026-05-18:

- Branch: `main`
- Commit: `fb2f9ee9b20766fe1ba58d3a33bf61e89cf86913`
- Environment:
  - macOS `15.7.6` (`24G707`)
  - Xcode `26.3` (`17C529`) at `/Applications/Xcode.app/Contents/Developer`
  - XcodeGen `2.45.4`
- Commands:
  - `git status --short`
  - `git diff --check`
  - `make prompt-audit`
  - `make batch-self-check`
  - `xcodegen generate`
  - `./scripts/build-local.sh`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies`
  - `xcode-select -p`
  - `plutil -p /Applications/Xcode.app/Contents/version.plist`
  - `xcodegen version`
- Verified proof:
  - `git status --short`: pre-existing `?? .codex/state/global-train.lock` remained present and unstaged
  - `git diff --check`: `0`
  - `make prompt-audit`: `0`, yellow classification for support/eval/template files and no active runnable prompt missing metadata
  - `make batch-self-check`: `0`, runner self-check passed
  - `xcodegen generate`: `0`
  - `./scripts/build-local.sh`: `0`, produced `Build Succeeded`
  - `xcode-select -p`: `0`
  - `plutil -p /Applications/Xcode.app/Contents/version.plist`: `0`
  - `xcodegen version`: `0`
  - Build log: `output/logs/build-local-20260518-033909.log`
- Failed proof:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -resolvePackageDependencies`: blocked before shell execution by the session policy wrapper (`approval required by policy, but AskForApproval is set to Never`); no exit code produced
- Skipped proof:
  - Unit tests
  - UI tests
  - Unsigned archive sanity
  - Physical-device proof
  - Accessibility proof
  - Privacy/legal proof
  - Signing proof
- Human follow-up:
  - If separate package-resolution proof is required, rerun the `xcodebuild -resolvePackageDependencies` command in a session that permits it.
- EFC applicability:
  - Invoked
  - Docs/evidence reconciliation only; no source, UI, or user-facing behavior repair required
- Claims not made:
  - release readiness
  - TestFlight readiness
  - App Store readiness
  - signed archive readiness
  - physical-device validation
  - public accessibility conformance
  - privacy/legal approval
  - hosted CI proof
  - production readiness
  - global queue completion

## Required local proof packet

A serious local validation run should save or summarize:

1. commit SHA and branch
2. macOS version
3. Xcode version
4. XcodeGen version
5. `xcodegen generate` result
6. dependency resolution result
7. simulator build result
8. unit test result
9. UI test result
10. unsigned archive sanity result when relevant
11. explicit non-claim notes for device, signing, TestFlight, App Store, accessibility, privacy/legal, and human approval

## Current non-claims

This repo does not currently prove:

- hosted CI success
- signed archive correctness
- provisioning profile correctness
- export options correctness
- TestFlight upload readiness
- App Store Connect validation
- App Store distribution readiness
- physical-device install behavior
- physical-device runtime behavior
- widget behavior on device
- Live Activity behavior on device
- notification behavior on device
- share extension behavior on device
- App Intent / Shortcut behavior on device
- public accessibility conformance
- legal/privacy compliance signoff
- human release approval

## Hosted CI policy

Hosted CI was intentionally removed from the active repo posture because Ambitions is staying on local VM/Mac validation.

Do not add GitHub Actions, Xcode Cloud, Codemagic, Bitrise, or another hosted validation provider unless a future patch explicitly records:

- provider
- expected cost model
- free quota or billing risk
- triggers
- artifact retention
- owner approval
- release-claim limits

## Release-claim rule

A claim may appear in product, README, App Store, TestFlight, investor, or public copy only when the matching evidence exists in the current proof packet.

Allowed current wording:

- under active native iOS development
- local-first / on-device-first posture
- local VM/Mac validation
- simulator build path exists
- unit/UI test targets exist
- release readiness not yet claimed

Forbidden current wording:

- claims that App Store submission can proceed
- claims that TestFlight distribution can proceed
- claims that production launch can proceed
- device validation proven
- full accessibility proof proven
- legal/privacy approval proven
- hosted CI evidence proven
- claims that signed release distribution can proceed

## Update rule

Update this packet whenever:

- validation posture changes
- hosted CI is added or removed
- signing/release proof is added
- device validation is completed
- public accessibility/legal/privacy evidence changes
- root README release language changes
