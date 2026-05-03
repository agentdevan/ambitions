# CS06 Technical-State Preservation Ledger

Status: CS06A technical preservation ledger. Technical states listed here must remain stable unless CS06B proves compatibility and CS06C explicitly performs a narrow, reversible retirement.

## Must-Preserve Technical States

| Technical state | Files observed | Why preservation is required | Required CS06B proof |
|---|---|---|---|
| `AmbitionsCommandExecutionStatus.failed` | `Native/Ambitions/Domain/AmbitionsCommandModels.swift`, `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`, `Native/AmbitionsTests/Services/AmbitionsCommandExecutorTests.swift` | Command failure is a real execution state, not user blame. Tests assert invalid commands return `.failed`. | Focused command executor tests for invalid and thrown execution paths |
| Event ledger emission metadata value `failed` | `Native/Ambitions/Services/AmbitionsCommandExecutor.swift` | Ledger append can fail while the capture command succeeds; metadata distinguishes partial technical failure. | Test or inventory proving metadata compatibility |
| `ExternalActionOutcome.failed` | `Native/Ambitions/Services/ExternalActionCommandService.swift`, runtime services | External action failure is distinct from unsupported/missing target. | Focused external action tests |
| `RuntimeActionResult(outcome: .failed)` | `Native/Ambitions/Runtime/AmbitionsRuntimeServices.swift` | Runtime fallback/action outcome contract. | Runtime/external action compatibility test |
| `AsyncViewState.failed(String)` | `Native/Ambitions/UI/AsyncViewState.swift` and feature view models/screens | Shared load/error state across surfaces. | Focused view-model tests for any touched feature |
| `AppBootstrapper.Phase.failed(String)` | `Native/Ambitions/App/AppBootstrapper.swift`, `Native/Ambitions/UI/LaunchGateView.swift` | Launch failure state must remain representable. | Launch/bootstrap proof if touched |
| `ActionReceiptResultState.failedSafely` | `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`, receipt tests | Raw value `failed_safely` can be persisted/exported/imported and represents safe non-execution. | Action closure receipt model tests and import/export compatibility proof if changed |
| `ActionReceiptSafetyState.safeFailure` | `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`, safe automation policy models/tests | Raw value `safe_failure` protects user trust by saying no unsafe changes occurred. | Safe automation and receipt tests |
| `ActionReceiptChangedFactKind.failedSafely` | `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`, safe automation policy models | Receipt fact taxonomy tied to safe failure semantics. | Receipt changed-fact tests |
| `SmartAttachmentConfidenceBand.unavailableFailed` | `Native/Ambitions/Domain/SmartAttachmentModels.swift`, Smart Attachment tests | Raw value remains compatibility surface while label displays `Unavailable`. | Smart Attachment model/service tests |
| `SmartAttachmentResultState.failedSafely` | `Native/Ambitions/Domain/SmartAttachmentModels.swift`, Smart Attachment service/tests | Safe fallback receipt state. | Smart Attachment result/receipt tests |
| `safeFailureMessage` | `Native/Ambitions/Persistence/PortableSnapshotContracts.swift` | Import/export safe failure contract. | Portable snapshot import/export tests if touched |
| Test-only `Failure` / `TestCaptureError.failure` | `Native/AmbitionsTests/**` | Deliberate test fixtures for error paths. | Keep unless replacing with stronger focused proof |
| Validation script "failed/failure" language | `scripts/**`, `.codex/validation/**` | Tooling needs pass/fail semantics. | Tooling migration proof if ever changed |

## Preservation Rule

CS06B must prove these states remain stable before any CS06C action. CS06A does not authorize a raw-value migration, status-model rewrite, receipt taxonomy rewrite, external action rewrite, or async-state rename.
