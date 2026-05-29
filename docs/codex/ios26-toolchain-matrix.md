# IOS26 Toolchain Matrix

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof, terminology-quarantine
> Dispositions: quarantine-or-rewrite-terminology, rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

- Batch: `IOS26-T01-B01`
- Run directory: `.codex/runs/IOS26-T01-B01/20260522T113527Z`
- Source commit at start: `3ed7d0dfcee02950183b9ad8757273d60dd07eb7`
- Branch: `main`
- Date: `2026-05-22`

## Scope

This proof artifact records the local toolchain state before any target bump.
It does not claim build, test, accessibility, privacy, or release readiness.

## Repo truth that stays unchanged

- `project.yml` still targets iOS `17.0`.
- `Package.swift` still uses `// swift-tools-version: 6.0` and `.iOS(.v17)`.

## Evidence matrix

| Probe | Result | Evidence | Notes |
| --- | --- | --- | --- |
| `xcodebuild -version` | Blocked | Shell execution rejected by outer policy: `approval required by policy, but AskForApproval is set to Never` | Do not infer the version from other probes. |
| `xcodebuild -showsdks` | Blocked | Shell execution rejected by outer policy: `approval required by policy, but AskForApproval is set to Never` | Raw `xcodebuild` shell access is not available in this session. |
| Xcode app version | Verified | `/Applications/Xcode.app/Contents/Info.plist` reports `CFBundleShortVersionString = 26.3` and `CFBundleVersion = 24587` | This is the installed Xcode app version, not a shell `xcodebuild` transcript. |
| iOS device SDK version | Verified | `xcrun --sdk iphoneos --show-sdk-version` returned `26.2` | Confirms the local iPhoneOS SDK version. |
| iOS simulator SDK version | Verified | `xcrun --sdk iphonesimulator --show-sdk-version` returned `26.2` | Confirms the local iPhoneSimulator SDK version. |
| iPhoneOS SDK path | Verified | `xcrun --sdk iphoneos --show-sdk-path` returned `.../iPhoneOS26.2.sdk` | The installed SDK path matches the version probe. |
| iPhoneSimulator SDK path | Verified | `xcrun --sdk iphonesimulator --show-sdk-path` returned `.../iPhoneSimulator26.2.sdk` | The installed SDK path matches the version probe. |
| Sim runtime | Verified | `xcrun simctl list runtimes` showed `iOS 26.3 (26.3.1 - 23D8133)` | Confirms an iOS 26 runtime is installed. |
| Usable simulator destination | Verified | `xcrun simctl list devices available` showed `iPhone 17 (Booted)` under `iOS 26.3` | This is a usable iOS 26 simulator destination. |
| XcodeGen | Verified | `xcodegen --version` returned `2.45.4` | Satisfies the XcodeGen version check. |
| Swift | Verified | `swift --version` returned `Apple Swift version 6.2.4` | Toolchain is newer than the package tools version. |
| Repo SwiftPM manifest | Verified | `swift package dump-package` on the repo manifest succeeded and reported `toolsVersion 6.0.0` with `platforms.ios = 17.0` | Confirms current repo manifest state without editing it. |
| SwiftPM `.iOS(.v26)` under tools 6.0 | needs review as expected | Temporary manifest with `// swift-tools-version: 6.0` needs review with `error: 'v26' is unavailable` and note `introduced in PackageDescription 6.2` | This is the key boundary result for the target bump. |
| SwiftPM `.iOS(.v26)` under tools 6.2 | Verified | Temporary manifest with `// swift-tools-version: 6.2` and `.iOS(.v26)` dumped successfully | Confirms the syntax is accepted when the tools version is raised. |

## Interpretation

- The local machine has Xcode 26.3, iOS 26.2 SDKs, and an iOS 26.3 simulator runtime.
- A booted `iPhone 17` simulator is available as a usable iOS 26 destination.
- The repo itself still targets iOS 17 and Swift tools 6.0, so no target bump has been made.
- `.iOS(.v26)` is not available under Swift tools 6.0 and becomes available under 6.2.

## Boundaries

- No target bump was attempted.
- No project/package/source files were edited.
- No build, test, accessibility, privacy, or release readiness was proven.
- Raw `xcodebuild` shell probes remain blocked in this session and must not be cited as executed.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
