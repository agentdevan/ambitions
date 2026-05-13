# Swift 6 Modernization Foundation 01 Report
<!-- markdownlint-disable MD013 -->

Status: Accepted Yellow  
Date: 2026-05-13  
Mainline merge: `cb15fd8e0b96e65f0bbd15ea797a9fda7a17a045`  
Automatic Actions workflow removal: `334696428a372f97b288915f328ecae2638ca916`

## Summary

This work moved Ambitions to a Swift 6 modernization foundation and added repo-enforced guardrails for the highest-value pre-TestFlight modernization work.

It is Accepted Yellow, not Green, because these changes were made through the connected GitHub repository interface. This path can update files and merge the PR, but it cannot run XcodeGen, xcodebuild, simulator tests, or device validation. Swift 6 compile repair and strict concurrency repair are therefore wired and gated, but not truthfully complete until the local final gate runs and captures compiler output.

Automatic GitHub Actions execution was intentionally removed after merge to avoid billed Actions usage. Validation is now local/manual through `scripts/ambitions-swift6-final-gate.sh` unless a future user request explicitly restores a workflow.

## User-requested modernization scope status

| Requested item | Main status | Proof boundary |
| --- | --- | --- |
| Swift 6 compile repair | Foundation and local build gate installed | Actual compiler repair requires XcodeGen/xcodebuild output from local validation. |
| Strict concurrency repair | `SWIFT_STRICT_CONCURRENCY: complete` installed and architecture gates added | Any actual Sendable/actor fixes must be driven by compiler output. |
| Architecture scanner CI/final-gate integration | Local final-gate implemented; automatic CI removed for cost control | Scanner, scanner tests, and local final-gate script remain. Automatic GitHub Actions was removed. |
| Module boundary split guided by Swift 6 compiler errors | Guardrails implemented, full split not performed | Blind file movement was avoided; scanner blocks known Domain/Feature/DesignSystem/WidgetUI boundary leaks. |
| SwiftData migration hardening | Implemented | Added execution-readiness proof evaluator for migration plans. |
| Swift Testing for deterministic domain/kernel/persistence tests | Implemented seed | Added Swift Testing coverage for storage migration execution readiness. |
| App Intents / App Shortcuts maturity | Implemented seed | Added system-control App Intent and shortcut exposure for Start Now, Still Counts, and Add Proof. |
| WidgetKit controls for highest-value actions | Contract layer implemented | Added shared system-control contracts and widget-extension source inclusion; actual `ControlWidget` UI implementation remains compiler-verified follow-up. |

## Files changed by Swift 6 modernization

- `project.yml`
- `Package.swift`
- `scripts/ambitions-swift6-modernization-scan.py`
- `scripts/ambitions-swift6-final-gate.sh`
- `tools/tests/test_ambitions_swift6_modernization_scan.py`
- `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md`
- `docs/architecture/AMB_SWIFT6_MODERNIZATION_REPORT.md`
- `docs/audits/swift6-modernization-foundation-01-report.md`
- `Native/Ambitions/Persistence/StorageMigrationExecutionReadiness.swift`
- `Native/AmbitionsTests/Persistence/StorageMigrationExecutionReadinessTestingTests.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceControlContracts.swift`
- `Native/Ambitions/AppIntents/AmbitionsSystemControlIntent.swift`
- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceControlContractsTests.swift`

## Files intentionally removed after merge

- `.github/workflows/swift6-modernization.yml`

Reason: avoid automatic GitHub Actions usage and cost exposure. Local validation remains available.

## Implemented changes

### 1. Swift 6 project and package posture

`project.yml` now declares:

```yaml
SWIFT_VERSION: 6.0
SWIFT_STRICT_CONCURRENCY: complete
```

`Package.swift` now declares:

```swift
// swift-tools-version: 6.0
```

The iOS deployment target remains `17.0`. No deployment-target increase was made without product/API proof.

### 2. Architecture standard document

Added:

```text
docs/architecture/AMB_SWIFT6_MODERNIZATION_REPORT.md
```

The active standard is:

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

### 3. Architecture scanner and module-boundary gates

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
- Hummingbird dependency leakage
- Domain importing SwiftUI or SwiftData
- Features importing SwiftData
- Design-system package importing SwiftData
- Widget UI package importing SwiftData

Strict mode:

```bash
python3 scripts/ambitions-swift6-modernization-scan.py . --strict
AMBITIONS_SWIFT6_SCAN_STRICT=1 python3 scripts/ambitions-swift6-modernization-scan.py .
```

### 4. Scanner tests

Added and expanded:

```text
tools/tests/test_ambitions_swift6_modernization_scan.py
```

Coverage includes:

- clean Swift 6 fixture pass
- Swift 5.10 settings failure
- Combine-owned `ObservableObject` failure
- module-boundary leaks failure
- explicit allow-marker escape hatch behavior

### 5. Local final gate

Added:

```text
scripts/ambitions-swift6-final-gate.sh
```

The local final gate runs:

- scanner self-test
- scanner unit tests
- strict repo scan
- XcodeGen generation
- Swift 6 app build
- focused deterministic tests

Focused tests currently targeted by the local final gate:

```text
AmbitionsTests/StorageMigrationPlanScaffoldTests
AmbitionsTests/StorageMigrationExecutionReadinessTestingTests
AmbitionsTests/AppIntentRoutingTests
AmbitionsTests/ExternalActionCommandServiceTests
AmbitionsTests/ExternalSurfaceControlContractsTests
```

### 6. SwiftData migration hardening

Added:

```text
Native/Ambitions/Persistence/StorageMigrationExecutionReadiness.swift
```

This introduces:

- `StorageMigrationProofKind`
- `StorageMigrationProof`
- `StorageMigrationExecutionReadinessIssue`
- `StorageMigrationExecutionReadiness`
- `StorageMigrationExecutionReadinessEvaluator`

The evaluator prevents migration execution from being considered Green until each mutation entry has proof for required gates such as storage invariant check, pre-migration backup, staged dry run, restore rollback plan, user review, and release-claim blocker acknowledgement.

### 7. Swift Testing seed coverage

Added:

```text
Native/AmbitionsTests/Persistence/StorageMigrationExecutionReadinessTestingTests.swift
```

This is the first Swift Testing seed in the modernization branch for deterministic persistence/migration behavior. It does not replace XCTest wholesale.

### 8. App Intents and App Shortcuts maturity

Added:

```text
Native/Ambitions/AppIntents/AmbitionsSystemControlIntent.swift
```

Updated:

```text
Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift
```

This adds a system-control App Intent and exposes high-value shortcuts for:

- Start Now
- Still Counts
- Add Proof

Mutation-capable controls route to in-app confirmation and receipt-producing flows instead of silently mutating state from system surfaces.

### 9. WidgetKit/system-control contract layer

Added:

```text
Native/Ambitions/ExternalSnapshots/ExternalSurfaceControlContracts.swift
Native/AmbitionsTests/App/ExternalSurfaceControlContractsTests.swift
```

The contract layer defines the highest-value system controls:

- Start now
- Capture
- Still counts
- Add proof
- Open current step

It also encodes privacy summaries, execution modes, receipt requirements, availability requirements, canonical payloads, and deep-link fallbacks. The file is included in the widget extension target source list through `project.yml`.

## Required validation before Green

Run from repo root:

```bash
python3 scripts/ambitions-swift6-modernization-scan.py --self-test
python3 tools/tests/test_ambitions_swift6_modernization_scan.py
python3 scripts/ambitions-swift6-modernization-scan.py . --strict
scripts/ambitions-swift6-final-gate.sh
```

The final gate will run XcodeGen, build, and focused deterministic tests when macOS/Xcode/simulator tooling is available.

## Validation performed in ChatGPT session

Performed:

- GitHub repository branch creation.
- Direct file writes through the connected GitHub repository interface.
- PR creation and Accepted Yellow mainline merge.
- Automatic workflow removal from `main` after user cost-control request.
- Documentation, scanner, local final gate, SwiftData migration hardening, Swift Testing seed, App Intent/control contract additions.
- Branch/PR state verification.

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

A full module split is not complete. The scanner-enforced boundary gates should guide the next split after compiler output rather than blind file movement.

Actual WidgetKit `ControlWidget` rendering is not complete. The shared control contract and App Intent surface are installed first to prevent duplicate routing logic and keep system controls privacy-safe; the concrete `ControlWidget` UI should be added only with compiler-verified API usage.

## Mainline gate

Do not claim Green until this passes:

```bash
scripts/ambitions-swift6-final-gate.sh
```

Accepted Yellow is allowed only if all remaining compiler/test blockers are documented with exact command output and no release-readiness claims.

## Rollback

Rollback options:

1. Revert `cb15fd8e0b96e65f0bbd15ea797a9fda7a17a045`, or
2. Restore `project.yml` to `SWIFT_VERSION: 5.10`, remove `SWIFT_STRICT_CONCURRENCY: complete`, restore `Package.swift` to `swift-tools-version: 5.10`, and remove the added scanner/final-gate/doc/control/migration/test files.

## Next required repair loop

Run:

```bash
scripts/ambitions-swift6-final-gate.sh
```

Then repair the first actual compiler/test failures, starting with Swift 6 strict-concurrency issues. Do not perform additional speculative rewrites before the compiler produces the failure list.
