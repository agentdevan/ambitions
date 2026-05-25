# Reminder Trigger Models And Repositories

## Status
Yellow

## Files changed
- `build/reports/reminder-operations/reminder-trigger-models.md`
- `build/reports/reminder-operations/IOS26-T04G-B01.md`
- `build/reports/core-replacement-contracts/TRAIN_04E_CLOSEOUT.md`
- `build/reports/parallel-implementation-guard/IOS26-T04G-B01-pre.md`
- `build/reports/parallel-implementation-guard/IOS26-T04G-B01-post.md`
- `docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json`
- `prompts/batches/IOS26-T04G-B01-reminder-trigger-models-and-repositories.md`
- `scripts/ambitions-parallel-implementation-guard.py`
- `Native/Ambitions/Domain/ReminderModels.swift`
- `Native/Ambitions/Persistence/PersistenceContracts.swift`
- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/StorageSchemaVersionLedger.swift`
- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`
- `Native/AmbitionsTests/Domain/IOS26RemindersP0ContractHarnessTests.swift`
- `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift`

## User jobs covered
- Replace reminder durable-object behavior with a local reminder trigger graph.
- Keep reminder source, receipt, replay, and You-boundary inspection local and inspectable.
- Support reminder export/import/delete behavior without introducing a parallel reminder system.

## Replacement P0 gates
- `ReminderTrigger`, `ReminderDeliveryPolicy`, `ReminderSource`, `ReminderState`, and attachment support are source-present in the reminder domain.
- `ReminderRepository` and `SwiftDataReminderRepository` are source-present at the repository seam.
- `ReminderRecord` persists the trigger model, source graph, attachment, receipt, replay trace, and deletion markers in SwiftData.
- Export/delete behavior is modeled through `ReminderRepositoryExport`, `deleteReminder(id:at:)`, and `deleteReminders(attachedTo:)`.
- You inspection remains bounded by `ReminderYouInspectionBoundary` and `localReminderYouInspectionSummary`.

## Tests run
- `python3 scripts/ios26-prompt-freeze-check.py --batch IOS26-T04G-B01 --prompt prompts/batches/IOS26-T04G-B01-reminder-trigger-models-and-repositories.md` -> Green
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04G-B01` -> Green
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04G-B01` -> Green
- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04G-B01` -> Green
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch IOS26-T04G-B01 --prompt prompts/batches/IOS26-T04G-B01-reminder-trigger-models-and-repositories.md --batch-type source-changing --allow-yellow` -> Yellow accepted
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04G-B01 --prompt prompts/batches/IOS26-T04G-B01-reminder-trigger-models-and-repositories.md --changed-from b901f8f0e7e4b90297cbf493fbd9104c7aa2fce8 --batch-type source-changing --allow-yellow` -> Yellow accepted
- `python3 scripts/ios26-flagship-proof-packet-check.py --batch IOS26-T04G-B01 --require-existing` -> Green
- `mcp__ambitionsRepo__.detect_forbidden_claims` on the T04G prompt/report and TRAIN_04E closeout proof paths -> no findings
- `git diff --check` -> Green

## Validation not run
- `AMBITIONS_SKIP_XCODE_TESTING=1` blocked `xcodebuild`, focused XCTest, simulator, device, archive, accessibility, and performance validation.
- No release, TestFlight, App Store, or device proof is claimed.
- The Xcode-skipped lane remains the reason no compile/test proof is present for this batch.

## Accessibility status
- Not verified by current proof.
- No VoiceOver, Dynamic Type, Reduce Motion, or contrast proof is claimed for this batch.

## Privacy/local-first status
- Local-first reminder persistence is preserved.
- No cloud LLM, hosted user-data backend, or external analytics dependency was introduced.
- No privacy approval is claimed.

## Performance status
- Not measured by this batch.
- No launch, persistence, or hot-path performance validation is claimed.

## Claims allowed
- Reminder trigger models, repository contracts, and SwiftData wiring are source-present in the current worktree.
- Reminder source, receipt, replay, and You inspection boundary concepts are represented in code.
- Reminder export/import/delete behavior is modeled and covered by source-level tests.
- The batch remains bounded to the reminder seam.

## Claims forbidden
- Not claimed: release readiness, App Store submission readiness, TestFlight readiness, device verification, accessibility completion, performance validation, privacy approval, or legal approval.
- Reminder replacement is complete.
- Any claim that Xcode/XCTest/simulator validation passed in this batch.

## Yellow/Red items
- Yellow: operator-held Xcode pause keeps compile/test proof unverified.
- Yellow: this report is evidence of the source seam only, not release proof.
- Yellow: `proof_receipt_replay` remains an accepted Yellow lock boundary.
- Yellow: `persistence_external_surfaces` remains an accepted Yellow lock boundary for persistence/export-delete-reset/external-surface paths; no broad persistence, external-surface, release, migration, or runtime-complete claim is made.
- Red: none in the non-Xcode validation lanes rerun in this repair pass.

## End-user job
Reminders durable object job.

## Replacement app floor
Reminder trigger models and repository pass.

## P0 contract status
Source-present at the repository seam; proof remains partial until Xcode/XCTest lanes return.

## Implementation behavior
The reminder graph now carries trigger metadata, local source records, receipt/replay IDs, attachment data, export/import support, and attachment-based deletion in SwiftData.

## Next batch
`IOS26-T04G-B02` - local notification scheduling abstraction.
