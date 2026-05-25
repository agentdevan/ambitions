# Reminder Trigger Models And Repositories

## Status
Yellow

## Files changed
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
- `ReminderRepository` and `SwiftDataReminderRepository` are wired through the app repository container.
- `ReminderRecord` persists the trigger model, source graph, attachment, receipt, replay trace, and deletion markers in SwiftData.
- Export/delete behavior is modeled through `ReminderRepositoryExport`, `deleteReminder(id:at:)`, and `deleteReminders(attachedTo:)`.
- You inspection remains bounded by `ReminderYouInspectionBoundary` and `localReminderYouInspectionSummary`.

## Tests run
- Not run yet in this batch because Xcode/XCTest/simulator lanes are paused by operator instruction.
- Source and repository tests were updated to match the current reminder API shape.

## Validation not run
- `AMBITIONS_SKIP_XCODE_TESTING=1` blocked `xcodebuild`, focused XCTest, simulator, device, archive, accessibility, and performance validation.
- No release, TestFlight, App Store, or device proof is claimed.

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
- Release-ready, App Store-ready, TestFlight-ready, device-verified, fully accessible, performance validated, privacy approved, legally approved.
- Reminder replacement is complete.
- Any claim that Xcode/XCTest/simulator validation passed in this batch.

## Yellow/Red items
- Yellow: operator-held Xcode pause keeps compile/test proof unverified.
- Yellow: this report is evidence of the source seam only, not release proof.
- Red: none observed in the bounded reminder seam.

## End-user job
Reminders durable object job.

## Replacement app floor
Reminder trigger models and repository pass.

## P0 contract status
Source-present and repository-wired; proof remains partial until Xcode/XCTest lanes return.

## Implementation behavior
The reminder graph now carries trigger metadata, local source records, receipt/replay IDs, attachment data, export/import support, and attachment-based deletion in SwiftData.

## Next batch
`IOS26-T04G-B02` - local notification scheduling abstraction.
