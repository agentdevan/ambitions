# CS06 Failed-Taxonomy Compatibility Contract Ledger

Status: CS06A docs/protocol ledger. No app code, tests, enum cases, raw values, persistence behavior, accessibility identifiers, command behavior, async UI behavior, safe-automation behavior, or historical docs were changed by this ledger.

## Contract Summary

CS06 does not mean "delete failed." It means Ambitions must preserve precise technical failure semantics while preventing user-facing recovery language from becoming blaming, shame-oriented, or inconsistent with Action Closure canon.

| Seam | Current role | Classification | Safe action now | Unsafe action | Required proof before retirement | Owner |
|---|---|---|---|---|---|---|
| `AmbitionsCommandExecutionStatus.failed` in `Native/Ambitions/Domain/AmbitionsCommandModels.swift` | Technical command execution status; used for invalid commands and thrown execution errors | must preserve technical state | Preserve enum case and raw value | Rename/delete/mutate without migration | Focused command executor tests proving invalid/thrown commands still produce compatible results | CS06B/CS06C |
| `.failed` returns in `AmbitionsCommandExecutor` | Technical result state for command execution errors and invalid validation | must preserve technical state | Preserve behavior and metadata | Convert to user-facing euphemism or merge with blocked/no-op | Focused tests for invalid command, thrown capture route/archive/attach/deadline/plan representation failures | CS06B |
| `metadata["eventLedgerEmission"] = "failed"` | Technical metadata for ledger append failure while capture still succeeds | must preserve technical state | Preserve metadata until compatibility proof exists | Rename metadata value without historical/consumer proof | Tests or inventory proving no consumer expects `failed` metadata | CS06B/CS06C |
| `ExternalActionOutcome.failed` | External action command failure outcome | must preserve technical state | Preserve outcome | Remove or collapse into unsupported/missing target | External action command proof | CS06B |
| `RuntimeActionResult(outcome: .failed)` | Runtime action failure outcome | must preserve technical state | Preserve outcome | Rename without runtime contract proof | Runtime action proof and compatibility inventory | CS06B/CS06C |
| `AsyncViewState.failed(String)` | Shared async load/error state across feature view models | must preserve technical state | Preserve state | Rename broadly or alter loading semantics | Focused async/view-model tests proving failures still surface and recovery copy remains humane | CS06B |
| `AppBootstrapper.Phase.failed(String)` | Launch/bootstrap technical failure state | must preserve technical state | Preserve state | Rename/alter launch failure behavior | Launch/bootstrap test or manual proof | CS06B/CS06C |
| Feature view model `.failed` states | Technical UI state for load/save/submit failures | must preserve technical state | Preserve state | Broad rename across Today/Goals/Capture/Plan/You/Habits/Insights | Focused tests for touched feature only | CS06B/CS06C |
| `ActionReceiptResultState.failedSafely` raw value `failed_safely` | Safe-automation/action receipt semantic: nothing unsafe changed | must preserve technical state | Preserve raw value, display mapping, tests | Rename raw value or remove safe-failure semantics | Receipt model tests and migration proof | CS06B/CS06C |
| `ActionReceiptSafetyState.safeFailure` raw value `safe_failure` | Receipt safety classification for safe non-execution/fallback | must preserve technical state | Preserve raw value | Rename/delete without persistence/import/export proof | Action receipt and persistence/import/export proof | CS06B/CS06C |
| `SmartAttachmentConfidenceBand.unavailableFailed` raw value `unavailable_failed` | Smart Attachment compatibility raw value with user-facing label `Unavailable` | must preserve technical state | Preserve raw value and user-facing label | Rename raw value without migration | Smart Attachment model/service tests and payload migration proof | CS06B/CS06C |
| `SmartAttachmentResultState.failedSafely` raw value `failed_safely` | Smart Attachment safe fallback receipt state | must preserve technical state | Preserve raw value | Rename/delete without receipt proof | Smart Attachment service/model tests | CS06B/CS06C |
| `safeFailureMessage` in portable snapshot contracts | Import/export safe fallback contract | must preserve technical state | Preserve field | Rename/remove without import/export migration proof | CS08-style import/export proof plus CS06B | CS06B/CS06C |
| User-facing "failed/failure" copy in feature screens or docs canon | Potentially visible wording that may be too negative | user-facing rename candidate | Inventory only | Rename in CS06A or alter behavior | Copy/accessibility proof plus focused UI/view-model tests | CS06C |
| Accessibility labels/hints containing failed/failure language | Assistive compatibility surface if present | unknown/defer unless exact surface is proven | Inventory only | Rename identifiers or labels without UI test/accessibility proof | Accessibility identifier/label proof | CS06B/CS06C |
| Tests asserting failure behavior | Product/technical contract tests | must preserve technical state | Preserve expected technical states | Weaken tests to avoid failed/failure terms | Focused proof that expectation is stale and replacement is stronger | CS06B/CS06C |
| Historical audit reports/logs containing failure counts | Historical truth | must preserve technical state | Preserve | Rewrite as if prior failures did not occur | Historical-doc truth review | CS06A |
| Codex validation protocols/checklists using failed/failure | Tooling semantics for pass/fail interpretation | must preserve technical state | Preserve | Rename into vague language | Tooling protocol migration proof | Future repair if ever needed |

## CS06A Decision

No seam is safe to retire in CS06A. Technical states, raw values, receipt semantics, command outcomes, accessibility surfaces, tests, and historical truth must be preserved until CS06B proves compatibility and CS06C names a narrow retirement target.
