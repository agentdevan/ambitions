# IOS26-T01-B01 Toolchain Confirmation Report

Status: Yellow

## Batch metadata

- Batch: `IOS26-T01-B01`
- Train: `IOS26 Train 01, toolchain confirmation`
- Phase: `02 - GPT-5.4-mini bounded patch`
- Run directory: `.codex/runs/IOS26-T01-B01/20260522T113527Z`
- Starting commit: `3ed7d0dfcee02950183b9ad8757273d60dd07eb7`
- Branch: `main`
- Date: `2026-05-22`

## Files changed

- `docs/codex/ios26-toolchain-matrix.md`
- `build/reports/ios26-migration/toolchain.md`

## Truth files inspected

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

## Source areas inspected

- `project.yml`
- `Package.swift`
- `scripts/`
- `scripts/AGENTS.md`
- `scripts/ambitions-xcode-version-check.sh`
- `scripts/ambitions-xcode-validate.sh`
- `docs/codex/ios26-toolchain-matrix.md`
- `build/reports/ios26-baseline/*`
- `build/reports/ios26-migration/toolchain.md`
- current run directory metadata

## Commands run

- `git status --short`
- `xcrun simctl list runtimes`
- `xcrun simctl list devices available`
- `xcodegen --version`
- `swift --version`
- `swift package dump-package`
- `xcode-select -p`
- `plutil -p /Applications/Xcode.app/Contents/Info.plist | rg -n "CFBundleShortVersionString|CFBundleVersion"`
- `xcrun --sdk iphoneos --show-sdk-version`
- `xcrun --sdk iphonesimulator --show-sdk-version`
- `xcrun --sdk iphoneos --show-sdk-path`
- `xcrun --sdk iphonesimulator --show-sdk-path`
- temporary-manifest SwiftPM syntax checks for `// swift-tools-version: 6.0` and `// swift-tools-version: 6.2`
- XcodeBuildMCP `session_show_defaults`
- XcodeBuildMCP `list_sims`

## Commands not run

- `xcodebuild -version`
- `xcodebuild -showsdks`

## Environment

- Xcode app version: `26.3` (`CFBundleVersion 24587`)
- iOS device SDK: `26.2`
- iOS simulator SDK: `26.2`
- iOS runtime: `iOS 26.3 (26.3.1 - 23D8133)`
- Available simulator destination: `iPhone 17` on `iOS 26.3`, already booted
- XcodeGen: `2.45.4`
- Swift: `Apple Swift version 6.2.4`
- Repo SwiftPM manifest: `toolsVersion 6.0.0`, `platforms.ios = 17.0`

## Evidence

- `xcodebuild` shell probes were blocked by the outer policy in this session, so the report does not claim a raw `xcodebuild` transcript.
- `xcrun --sdk iphoneos --show-sdk-version` returned `26.2`.
- `xcrun --sdk iphonesimulator --show-sdk-version` returned `26.2`.
- `xcrun simctl list runtimes` showed an installed iOS 26.3 runtime.
- `xcrun simctl list devices available` showed a booted `iPhone 17` on iOS 26.3.
- The temporary manifest with `// swift-tools-version: 6.0` and `.iOS(.v26)` failed with `error: 'v26' is unavailable` and the note that `v26` was introduced in PackageDescription 6.2.
- The temporary manifest with `// swift-tools-version: 6.2` and `.iOS(.v26)` dumped successfully.

## Passes

- Xcode app version is 26.x.
- iOS 26 device and simulator SDKs are installed.
- An iOS 26 simulator runtime is installed.
- A usable `iPhone 17` simulator destination exists.
- XcodeGen is installed.
- Swift is installed and current enough to validate SwiftPM syntax behavior.
- SwiftPM `.iOS(.v26)` is confirmed to require PackageDescription 6.2, not 6.0.

## Failures

- Raw `xcodebuild -version` was not executable in this session because the shell rejected it under the current approval policy.
- Raw `xcodebuild -showsdks` was not executable in this session because the shell rejected it under the current approval policy.
- The repo is not yet bumped to iOS 26; `project.yml` still targets iOS `17.0`.
- `Package.swift` still uses Swift tools `6.0` and `.iOS(.v17)`.

## Skipped

- No target settings were edited.
- No source files were edited.
- No build, test, accessibility, privacy, or release claims were made.

## Unproven

- Raw `xcodebuild` version output.
- Raw `xcodebuild -showsdks` output.
- Build success.
- Test success.
- Accessibility proof.
- Privacy approval.
- Release readiness.

## Accessibility status

- Not verified.

## Privacy/local-first status

- Preserved. No cloud AI/LLM, analytics, hosted backend, or privacy weakening was introduced.

## iOS 26 API verification status

- Partially confirmed.
- Confirmed: Xcode 26.3 app, iOS 26.2 SDKs, iOS 26.3 runtime, and a usable iPhone 17 simulator destination exist.
- Confirmed: SwiftPM `.iOS(.v26)` requires PackageDescription 6.2.
- Not confirmed here: a raw `xcodebuild` transcript.

## Claims allowed

- The local toolchain is close enough to prepare an iOS 26 target bump.
- The repo manifest still targets iOS 17, so no bump has happened yet.

## Claims forbidden

- Do not claim build, test, accessibility, privacy, or release readiness.
- Do not claim the target bump is complete.
- Do not claim raw `xcodebuild` evidence was captured.

## Release blockers

- The repo still targets iOS 17.0.
- The package manifest still targets Swift tools 6.0 and `.iOS(.v17)`.
- Raw `xcodebuild` shell evidence was blocked in this session.

## Post-batch gates

- Next eligible work is a target-bump batch only after the owner accepts the proof boundaries recorded here.
- Re-run build/test validation after the target bump, not before.

## Rollback

- If these proof artifacts need to be removed, delete only:
  - `docs/codex/ios26-toolchain-matrix.md`
  - `build/reports/ios26-migration/toolchain.md`

## Next eligible batch

- The target-bump batch that consumes this proof, if the owner approves moving forward.
