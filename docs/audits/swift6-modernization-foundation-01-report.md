# Swift 6 Modernization Foundation 01 Report
<!-- markdownlint-disable MD013 -->

Status: Accepted Yellow  
Date: 2026-05-13  
Branch: `ambitions/swift6-modernization-foundation-01`  
Base: `main` at `23dae46663b720fe4f082acdec481ceb0555c562`

## Summary

This batch migrated Ambitions' repo-level Swift posture from Swift 5.10 to Swift 6 and installed the first architecture guardrails required to keep the native app aligned with the modern Ambitions standard.

The migration is intentionally Accepted Yellow, not Green, because this remote GitHub edit path cannot run XcodeGen, Xcode build, iOS simulator tests, or device validation. The branch contains the actual repo changes and the exact validation commands that must be run locally or in CI before merge.

## Files changed

- `project.yml`
- `Package.swift`
- `scripts/ambitions-swift6-modernization-scan.py`
- `tools/tests/test_ambitions_swift6_modernization_scan.py`
- `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md`
- `docs/architecture/AMB_SWIFT6_MODERNIZATION_REPORT.md`
- `docs/audits/swift6-modernization-foundation-01-report.md`

## Implemented changes

### 1. Swift 6 project setting

`project.yml` now declares:

```yaml
SWIFT_VERSION: 6.0
SWIFT_STRICT_CONCURRENCY: complete
```

This makes Swift 6 language mode and complete strict concurrency the target posture for generated Xcode projects.

### 2. Swift 6 package tools version

`Package.swift` now declares:

```swift
// swift-tools-version: 6.0
```

This aligns the design-system/widget package layer with the Swift 6 migration foundation.

### 3. Architecture standard document

Added:

```text
docs/architecture/AMB_SWIFT6_MODERNIZATION_REPORT.md
```

The document defines the active Ambitions native architecture as:

```text
Swift 6 + SwiftUI + Observation + structured concurrency + strict concurrency + actor-isolated local-first SwiftData + Swift Testing for new deterministic tests + App Intents / WidgetKit / ActivityKit external surfaces + protocol-based feature services + deterministic command routing + local-first Private Life Runtime / Intelligence Kernel.
```

It explicitly rejects:

- VIPER
- Combine-first MVVM
- Hummingbird inside native app targets
- external/cloud LLMs as core infrastructure
- broad unchecked Sendable escapes
- unproven release/readiness claims

### 4. Swift 6 modernization scanner

Added:

```text
scripts/ambitions-swift6-modernization-scan.py
```

The scanner verifies Swift 6 settings and detects regressions:

- `import Combine`
- `ObservableObject`
- `@Published`
- `AnyCancellable`
- `@unchecked Sendable`
- VIPER naming
- Hummingbird dependency leakage into native settings/package files

Default mode is advisory. Strict mode is available through:

```bash
python3 scripts/ambitions-swift6-modernization-scan.py . --strict
AMBITIONS_SWIFT6_SCAN_STRICT=1 python3 scripts/ambitions-swift6-modernization-scan.py .
```

### 5. Scanner tests

Added:

```text
tools/tests/test_ambitions_swift6_modernization_scan.py
```

The test file covers:

- clean Swift 6 fixture pass
- Swift 5.10 settings failure
- Combine-owned `ObservableObject` failure
- explicit allow-marker escape hatch behavior

### 6. CQS script map registration

Updated:

```text
docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md
```

The script map now includes the Swift 6 modernization scanner and strict-mode usage.

## Required validation before Green

Run from repo root after checking out the branch:

```bash
python3 scripts/ambitions-swift6-modernization-scan.py --self-test
python3 tools/tests/test_ambitions_swift6_modernization_scan.py
python3 scripts/ambitions-swift6-modernization-scan.py . --strict
xcodegen generate
xcodebuild build -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17'
xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17'
```

If `iPhone 17` is not available locally, use an available current iPhone simulator and record the exact destination.

## Validation performed in this session

Performed:

- GitHub repository branch creation.
- Direct file writes to branch through the connected GitHub repository interface.
- Repo content inspection before and during migration.
- Documentation and guardrail creation.

Not performed:

- `xcodegen generate`
- `xcodebuild build`
- `xcodebuild test`
- Python scanner execution against the full repo
- Python scanner test execution
- simulator proof
- device proof
- accessibility proof
- performance proof
- privacy/legal proof
- release/TestFlight/App Store proof

## Known risk

Swift 6 with complete strict concurrency may expose compiler errors in existing production or test code. That is expected and is the point of the migration. Do not silence those errors with broad `@unchecked Sendable`, broad `@MainActor`, or unstructured concurrency. Repair with explicit actor boundaries, Sendable value models, or module/service seam corrections.

## Merge gate

Do not merge until at least these pass or the PR is explicitly accepted as Yellow with blockers documented:

```bash
python3 scripts/ambitions-swift6-modernization-scan.py --self-test
python3 tools/tests/test_ambitions_swift6_modernization_scan.py
python3 scripts/ambitions-swift6-modernization-scan.py . --strict
xcodegen generate
xcodebuild build -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17'
```

Full Green additionally requires focused/full test proof.

## Rollback

Rollback is clean:

1. Close the PR without merge, or
2. Revert the branch commits, or
3. Restore `project.yml` to `SWIFT_VERSION: 5.10` and remove `SWIFT_STRICT_CONCURRENCY: complete`, restore `Package.swift` to `swift-tools-version: 5.10`, and remove the new scanner/test/doc files.

## Next recommended batch

`AMB-SWIFT6-STRICT-CONCURRENCY-REPAIR-02`

Objective:

- Run XcodeGen and Xcode build locally/CI.
- Capture all Swift 6 strict concurrency compiler failures.
- Repair only real isolation/Sendable issues.
- Avoid broad suppressions.
- Produce Green/Yellow proof with exact compiler output and remaining blocker list.
