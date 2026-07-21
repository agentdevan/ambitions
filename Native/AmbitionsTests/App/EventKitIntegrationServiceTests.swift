import XCTest
@testable import Ambitions

final class EventKitIntegrationServiceTests: XCTestCase {
    func testMalformedCommitEvidenceIsDeniedBeforeClaimOrEventKitSave() async throws {
        let store = RecordingEventKitStoreClient()
        let ledger = InMemorySideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: ledger))
        )
        let malformed = SideEffectLocalCommitEvidence(
            receiptID: "receipt",
            writeScope: .localSwiftDataSingleContext,
            committedAt: "2026-04-16T09:00:00Z",
            didCommitChanges: false,
            sideEffectPolicy: AppUnitOfWorkReceipt.noExternalSideEffects
        )

        do {
            _ = try await service.createReminder(
                for: fixtureSelection(),
                now: fixtureNow(),
                operationID: UUID().uuidString,
                localCommit: malformed
            )
            XCTFail("Expected malformed evidence to be denied.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .missingLocalCommitReceipt(scope: .reminders))
        }
        let saveCount = await store.currentSaveReminderCount()
        let authorizationRequestCount = await store.currentAuthorizationRequestCount()
        let records = try await ledger.fetchRecords(status: .blocked)
        XCTAssertEqual(saveCount, 0)
        XCTAssertEqual(authorizationRequestCount, 0)
        XCTAssertEqual(records.count, 1)
        XCTAssertNil(records.first?.claimToken)
        XCTAssertNil(records.first?.leaseID)
    }

    func testDeniedSameIDPreservesExistingLeasedAndSucceededRecords() async throws {
        for existingStatus in [SideEffectLedgerStatus.leased, .succeeded] {
            let store = RecordingEventKitStoreClient()
            await store.setAuthorization(state: .fullAccess, for: .reminders)
            let ledger = InMemorySideEffectLedgerRepository()
            let operationID = operationID("preserve-\(existingStatus.rawValue)")
            let requestID = "calendar.reminder.\(operationID.lowercased())"
            let existing = existingRecord(
                id: requestID,
                operationID: operationID.lowercased(),
                status: existingStatus
            )
            try await ledger.append(existing)
            let malformed = SideEffectLocalCommitEvidence(
                authorityCommandID: "authority.denied",
                operationID: operationID.lowercased(),
                receiptID: "malformed",
                writeScope: .localSwiftDataSingleContext,
                committedAt: "2026-04-16T09:00:00Z",
                didCommitChanges: false,
                sideEffectPolicy: AppUnitOfWorkReceipt.noExternalSideEffects
            )
            let service = EventKitIntegrationService(
                storeClient: store,
                eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: ledger))
            )
            do {
                _ = try await service.createReminder(
                    for: fixtureSelection(),
                    now: fixtureNow(),
                    operationID: operationID,
                    localCommit: malformed
                )
                XCTFail("Expected denied evidence to block EventKit.")
            } catch let error as CalendarRemindersError {
                XCTAssertEqual(error, .missingLocalCommitReceipt(scope: .reminders))
            }
            let persisted = try await ledger.fetchRecord(id: requestID)
            let saveCount = await store.currentSaveReminderCount()
            XCTAssertEqual(persisted, existing)
            XCTAssertEqual(saveCount, 0)
        }
    }

    func testAuthorityEvidenceForOperationACannotAuthorizeOperationB() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .reminders)
        let ledger = InMemorySideEffectLedgerRepository()
        let operationA = operationID("authority-a")
        let operationB = operationID("authority-b")
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: ledger))
        )
        do {
            _ = try await service.createReminder(
                for: fixtureSelection(),
                now: fixtureNow(),
                operationID: operationB,
                localCommit: runtimeLocalCommitEvidence("authority-a", operationID: operationA)
            )
            XCTFail("Expected mismatched operation lineage to be denied.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .missingLocalCommitReceipt(scope: .reminders))
        }
        let saveCount = await store.currentSaveReminderCount()
        let blocked = try await ledger.fetchRecords(status: .blocked)
        XCTAssertEqual(saveCount, 0)
        XCTAssertEqual(blocked.first?.operationID, operationB.lowercased())
        XCTAssertTrue(
            blocked.first?.blockedFacts.contains(
                "External side effect authority evidence does not match the requested command and operation."
            ) == true
        )
    }

    func testDeniedAuthorityEvidenceDoesNotPoisonValidSameOperationRetry() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .reminders)
        let ledger = InMemorySideEffectLedgerRepository()
        let operationID = operationID("authority-recovery")
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: ledger))
        )
        let malformed = SideEffectLocalCommitEvidence(
            authorityCommandID: "authority.denied",
            operationID: operationID,
            receiptID: "malformed",
            writeScope: .localSwiftDataSingleContext,
            committedAt: "2026-04-16T09:00:00Z",
            didCommitChanges: false,
            sideEffectPolicy: AppUnitOfWorkReceipt.noExternalSideEffects
        )

        do {
            _ = try await service.createReminder(
                for: fixtureSelection(),
                now: fixtureNow(),
                operationID: operationID,
                localCommit: malformed
            )
            XCTFail("Expected malformed authority evidence to fail closed.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .missingLocalCommitReceipt(scope: .reminders))
        }

        let created = try await service.createReminder(
            for: fixtureSelection(),
            now: fixtureNow(),
            operationID: operationID,
            localCommit: runtimeLocalCommitEvidence("authority-recovery", operationID: operationID)
        )
        let blocked = try await ledger.fetchRecords(status: .blocked)
        let succeeded = try await ledger.fetchRecords(status: .succeeded)
        let saveCount = await store.currentSaveReminderCount()
        XCTAssertEqual(created.identifier, "reminder-1")
        XCTAssertEqual(saveCount, 1)
        XCTAssertEqual(blocked.count, 1)
        XCTAssertEqual(succeeded.count, 1)
        XCTAssertTrue(blocked.first?.id.hasSuffix(".authority-denied") == true)
    }

    func testLegacyEvidenceWithoutAuthorityLineageFailsClosedDuringDecode() throws {
        let legacyJSON = """
        {
          "receiptID":"receipt",
          "writeScope":"local_swift_data_single_context",
          "committedAt":"2026-04-16T09:00:00Z",
          "didCommitChanges":true,
          "sideEffectPolicy":"no_external_side_effects"
        }
        """
        XCTAssertThrowsError(
            try JSONDecoder().decode(SideEffectLocalCommitEvidence.self, from: Data(legacyJSON.utf8))
        )
    }

    func testIndependentFileRepositoriesGrantExactlyOneDurableClaim() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let url = directory.appendingPathComponent("ledger.json")
        defer { try? FileManager.default.removeItem(at: directory) }
        let first = FileSideEffectLedgerRepository(fileURL: url)
        let second = FileSideEffectLedgerRepository(fileURL: url)
        let request = sideEffectRequest(id: "calendar.concurrent.file")
        let proposed = SideEffectLedgerRecord(
            id: request.id,
            effectKind: .calendar,
            status: .queued,
            boundary: .externalEffect,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            commandID: "authority-command",
            occurredAt: DomainTimestamp.string(from: fixtureNow()),
            localOnly: false,
            requiresConfirmation: false,
            externalEffect: true
        )

        async let firstResult = first.claim(proposed, token: "token-a")
        async let secondResult = second.claim(proposed, token: "token-b")
        let results = try await [firstResult, secondResult]

        XCTAssertEqual(results.filter(\.isNewClaim).count, 1)
        let persisted = try await FileSideEffectLedgerRepository(fileURL: url)
            .fetchRecord(id: request.id)
        XCTAssertEqual(persisted?.commandID, "authority-command")
        XCTAssertNotNil(persisted?.claimToken)
    }

    func testFileLedgerRestartPreservesLineageAndRejectsWrongFinalizeToken() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let url = directory.appendingPathComponent("ledger.json")
        defer { try? FileManager.default.removeItem(at: directory) }
        let proposed = SideEffectLedgerRecord(
            id: "calendar.restart",
            effectKind: .calendar,
            status: .queued,
            boundary: .externalEffect,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            commandID: "authority-command",
            occurredAt: DomainTimestamp.string(from: fixtureNow()),
            localOnly: false,
            requiresConfirmation: false,
            externalEffect: true
        )
        let first = FileSideEffectLedgerRepository(fileURL: url)
        _ = try await first.claim(proposed, token: "right-token")
        let restarted = FileSideEffectLedgerRepository(fileURL: url)
        let terminal = SideEffectLedgerRecord(
            id: proposed.id,
            effectKind: .calendar,
            status: .succeeded,
            boundary: .externalEffect,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            commandID: proposed.commandID,
            occurredAt: DomainTimestamp.string(from: fixtureNow()),
            localOnly: false,
            requiresConfirmation: false,
            externalEffect: true,
            receiptID: "event-1"
        )

        let wrongTokenFinalized = try await restarted.finalize(terminal, token: "wrong-token")
        let rightTokenFinalized = try await restarted.finalize(terminal, token: "right-token")
        XCTAssertFalse(wrongTokenFinalized)
        XCTAssertTrue(rightTokenFinalized)
        let persisted = try await restarted.fetchRecord(id: proposed.id)
        XCTAssertEqual(persisted?.commandID, "authority-command")
        XCTAssertNil(persisted?.claimToken)
        XCTAssertEqual(persisted?.status, .succeeded)
    }

    func testPendingOperationIdentitySurvivesRestartUntilDurableCompletion() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let url = directory.appendingPathComponent("pending.json")
        defer { try? FileManager.default.removeItem(at: directory) }
        let fingerprint = FilePendingEventKitOperationStore.fingerprint(
            kind: "reminder",
            goalID: "goal-1",
            stepID: "step-1"
        )
        let first = FilePendingEventKitOperationStore(fileURL: url)
        let initial = try await first.resolve(fingerprint: fingerprint, proposedOperationID: "ignored")
        let restarted = FilePendingEventKitOperationStore(fileURL: url)
        let replay = try await restarted.resolve(fingerprint: fingerprint, proposedOperationID: "also-ignored")
        XCTAssertEqual(replay, initial)

        try await restarted.complete(fingerprint: fingerprint, operationID: initial)
        let deliberateNext = try await FilePendingEventKitOperationStore(fileURL: url)
            .resolve(fingerprint: fingerprint, proposedOperationID: "ignored-again")
        XCTAssertNotEqual(deliberateNext, initial)
    }

    func testTwoOutboxesSharingLedgerGrantOnlyOneDurableClaim() async throws {
        let ledger = InMemorySideEffectLedgerRepository()
        let first = SideEffectOutbox(ledger: ledger)
        let second = SideEffectOutbox(ledger: ledger)
        let request = sideEffectRequest(id: "calendar.concurrent.operation")

        async let firstClaim = first.claim(request)
        async let secondClaim = second.claim(request)
        let claims = try await [firstClaim, secondClaim]

        XCTAssertEqual(claims.filter(\.isClaimOwner).count, 1)
        XCTAssertEqual(claims.filter(\.requiresReconciliation).count, 1)
    }

    func testInterruptedResultRecordingReconcilesExactMarkerWithoutSecondSave() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .reminders)
        let ledger = FailOnceFinalizeSideEffectLedger()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: ledger))
        )
        let operationID = "56A02B42-C5A5-43E8-B7B7-CBBE837CA792"

        do {
            _ = try await service.createReminder(
                for: fixtureSelection(),
                now: fixtureNow(),
                operationID: operationID,
                localCommit: runtimeLocalCommitEvidence("interrupted", operationID: operationID.lowercased())
            )
            XCTFail("Expected interrupted result recording to fail closed.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(
                error,
                .resultRecordingIndeterminate(scope: .reminders, externalIdentifier: "reminder-1")
            )
        }

        let recovered = try await service.createReminder(
            for: fixtureSelection(),
            now: fixtureNow().addingTimeInterval(60),
            operationID: operationID,
            localCommit: runtimeLocalCommitEvidence("interrupted", operationID: operationID.lowercased())
        )

        XCTAssertEqual(recovered.identifier, "reminder-1")
        let saveReminderCount = await store.currentSaveReminderCount()
        XCTAssertEqual(saveReminderCount, 1)
    }

    func testIndeterminateWriteOnlyCalendarClaimNeverRetriesExternalWrite() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .writeOnly, for: .calendarEvents)
        let ledger = InMemorySideEffectLedgerRepository()
        let interruptedOutbox = SideEffectOutbox(ledger: ledger)
        let operationID = "85575be5-c078-46a1-9129-39b239178c68"
        let commit = runtimeLocalCommitEvidence("write-only", operationID: operationID)
        _ = try await interruptedOutbox.claim(
            sideEffectRequest(
                id: "calendar.calendar-event.\(operationID)",
                operationID: operationID,
                localCommit: commit
            )
        )
        let restartedOutbox = SideEffectOutbox(ledger: ledger)
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: restartedOutbox)
        )

        do {
            _ = try await service.createCalendarEvent(
                for: fixtureSelection(),
                durationMinutes: 45,
                now: fixtureNow().addingTimeInterval(60),
                operationID: operationID,
                localCommit: commit
            )
            XCTFail("Expected reconciliation-required failure.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .reconciliationRequired(scope: .calendarEvents))
        }
        let saveEventCount = await store.currentSaveEventCount()
        XCTAssertEqual(saveEventCount, 0)
    }
    func testCreateReminderFailsWhenAuthorizationDenied() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .denied, for: .reminders)
        let sideEffectLedger = RecordingEventKitSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        let operationID = operationID("reminder-authorization-denied")
        do {
            _ = try await service.createReminder(
                for: fixtureSelection(),
                now: fixtureNow(),
                operationID: operationID,
                localCommit: runtimeLocalCommitEvidence(
                    "reminder-authorization-denied",
                    operationID: operationID
                )
            )
            XCTFail("Expected denied authorization to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .authorizationDenied(scope: .reminders))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let reminderSaveCount = await store.currentSaveReminderCount()
        let reminderPayload = await store.lastReminderPayload
        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(reminderSaveCount, 0)
        XCTAssertNil(reminderPayload)
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.actionKind, .writeCalendarBlock)
        XCTAssertEqual(record?.requiresConfirmation, true)
        assertResultRecord(
            record,
            status: .failedSafely,
            externalEffect: false,
            receiptID: nil,
            degradedFact: "Reminder write permission was denied before EventKit save."
        )
        XCTAssertTrue(record?.blockedFacts.contains("Reminder write permission was not available for this requested reminder.") == true)
    }

    func testCreateReminderRequestsAuthorizationAndSavesPayload() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .notDetermined, for: .reminders)
        await store.setAuthorizationResponse(state: .fullAccess, for: .reminders)
        let sideEffectLedger = RecordingEventKitSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        let operationID = operationID("reminder")
        let record = try await service.createReminder(
            for: fixtureSelection(),
            now: fixtureNow(),
            operationID: operationID,
            localCommit: runtimeLocalCommitEvidence("reminder", operationID: operationID)
        )
        let payload = await store.lastReminderPayload

        XCTAssertEqual(record.identifier, "reminder-1")
        XCTAssertEqual(record.title, "Draft conference abstract")
        XCTAssertEqual(payload?.title, "Draft conference abstract")
        XCTAssertEqual(payload?.dueDate, fixtureSuggestedDate())
        XCTAssertTrue(payload?.notes.contains("Created by Ambitions after an explicit reminder request.") == true)
        XCTAssertTrue(payload?.notes.contains("Ambitions step ID: step-1") == true)
        XCTAssertFalse(payload?.notes.contains("Ship CFP proposal") == true)
        XCTAssertFalse(payload?.notes.contains("First concrete draft") == true)

        let records = await sideEffectLedger.records
        XCTAssertEqual(records.count, 1)
        assertResultRecord(
            records.first,
            status: .succeeded,
            externalEffect: true,
            receiptID: "reminder-1",
            degradedFact: "Reminder write completed through EventKit side-effect owner."
        )
    }

    func testCreateReminderPersistsLocalReminderObjectWhenRepositoryIsAvailable() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .reminders)
        let reminderRepository = try await makeReminderRepository()
        let sideEffectLedger = RecordingEventKitSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger)),
            reminderRepository: reminderRepository
        )

        let operationID = operationID("reminder-persist")
        let record = try await service.createReminder(
            for: fixtureSelection(),
            now: fixtureNow(),
            operationID: operationID,
            localCommit: runtimeLocalCommitEvidence("reminder-persist", operationID: operationID)
        )
        let loadedReminder = try await reminderRepository.reminder(id: record.identifier)
        let loaded = try XCTUnwrap(loadedReminder)

        XCTAssertEqual(record.identifier, "reminder-1")
        XCTAssertEqual(loaded.title, "Draft conference abstract")
        XCTAssertEqual(loaded.sourceRecordID, "source.reminder.reminder-1")
        XCTAssertEqual(loaded.localReminderSourceRecordID, "SourceRecord.reminder.reminder-1")
        XCTAssertEqual(loaded.sourceSurfaceTitle, "Search Ambitions")
        XCTAssertTrue(loaded.localReminderYouInspectionSummary.contains("Search Ambitions"))
        XCTAssertEqual(loaded.receiptID, "Receipt.reminder.reminder-1.save")
        XCTAssertEqual(loaded.replayTraceID, "ReplayTrace.reminder.reminder-1.save")
        XCTAssertTrue(loaded.state.isActive)
        XCTAssertFalse(loaded.state.isTerminal)
        XCTAssertTrue(loaded.deliveryPolicy.usesLocalNotificationDelivery)
    }

    func testReminderMirrorFailureRetriesWithoutSecondEventKitSave() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .reminders)
        let ledger = InMemorySideEffectLedgerRepository()
        let mirror = FailOnceReminderRepository()
        let pending = MemoryPendingEventKitOperationStore()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: ledger)),
            reminderRepository: mirror,
            pendingOperationStore: pending
        )
        let operationID = operationID("mirror-recovery")
        let evidence = runtimeLocalCommitEvidence("mirror-recovery", operationID: operationID)
        do {
            _ = try await service.createReminder(
                for: fixtureSelection(),
                now: fixtureNow(),
                operationID: operationID,
                localCommit: evidence
            )
            XCTFail("Expected first local mirror materialization to fail.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(
                error,
                .mirrorMaterializationPending(scope: .reminders, externalIdentifier: "reminder-1")
            )
        }

        let terminalBeforeRetry = try await ledger.fetchRecords(status: .succeeded)
        let firstSaveCount = await store.currentSaveReminderCount()
        XCTAssertEqual(terminalBeforeRetry.first?.receiptID, "reminder-1")
        XCTAssertEqual(firstSaveCount, 1)

        let recovered = try await service.createReminder(
            for: fixtureSelection(),
            now: fixtureNow().addingTimeInterval(60),
            operationID: operationID,
            localCommit: evidence
        )
        let mirrored = try await mirror.reminder(id: recovered.identifier)
        let finalSaveCount = await store.currentSaveReminderCount()
        XCTAssertEqual(recovered.identifier, "reminder-1")
        XCTAssertNotNil(mirrored)
        XCTAssertEqual(finalSaveCount, 1)
    }

    func testCreateReminderRequiresLocalCommitReceiptBeforeSaving() async throws {
        let store = RecordingEventKitStoreClient()
        let sideEffectLedger = RecordingEventKitSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        do {
            _ = try await service.createReminder(
                for: fixtureSelection(),
                now: fixtureNow(),
                operationID: operationID("reminder-missing-commit"),
                localCommit: nil
            )
            XCTFail("Expected missing local commit receipt to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .missingLocalCommitReceipt(scope: .reminders))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let payload = await store.lastReminderPayload
        let authorizationRequestCount = await store.currentAuthorizationRequestCount()
        let record = await sideEffectLedger.lastRecord
        XCTAssertNil(payload)
        XCTAssertEqual(authorizationRequestCount, 0)
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.status, .blocked)
        XCTAssertEqual(record?.boundary, .externalEffect)
        XCTAssertEqual(record?.externalEffect, true)
        XCTAssertTrue(record?.blockedFacts.contains("External side effect cannot be attempted before a committed local mutation receipt.") == true)
    }

    func testCreateReminderSaveFailureRecordsFailedResultReceipt() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .reminders)
        await store.setReminderSaveFailure(.saveFailed("simulated reminder failure"))
        let sideEffectLedger = RecordingEventKitSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        do {
            let operationID = operationID("reminder-save-failure")
            _ = try await service.createReminder(
                for: fixtureSelection(),
                now: fixtureNow(),
                operationID: operationID,
                localCommit: runtimeLocalCommitEvidence("reminder-save-failure", operationID: operationID)
            )
            XCTFail("Expected reminder save failure to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .saveFailed("simulated reminder failure"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let record = await sideEffectLedger.lastRecord
        assertResultRecord(
            record,
            status: .failedSafely,
            externalEffect: true,
            receiptID: nil,
            degradedFact: "Reminder write could not be completed safely."
        )
    }

    func testDetectConflictsReturnsOverlappingEventsAndNearbyRoom() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let overlap = EventKitCalendarEventSnapshot(
            title: "Team standup",
            startDate: fixtureSuggestedDate().addingTimeInterval(-300),
            endDate: fixtureSuggestedDate().addingTimeInterval(1_200),
            isAllDay: false
        )
        let nonOverlap = EventKitCalendarEventSnapshot(
            title: "Evening run",
            startDate: fixtureSuggestedDate().addingTimeInterval(10_800),
            endDate: fixtureSuggestedDate().addingTimeInterval(11_400),
            isAllDay: false
        )
        await store.setEvents([overlap, nonOverlap])
        let service = EventKitIntegrationService(storeClient: store)

        let report = await service.detectConflicts(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())

        XCTAssertEqual(report?.conflicts.count, 1)
        XCTAssertEqual(report?.conflicts.first?.title, "Team standup")
        XCTAssertEqual(report?.pressure, .low)
        XCTAssertNotNil(report?.nearbyAvailableWindow)
    }

    func testDetectConflictsReturnsNilWithoutCalendarReadContext() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .writeOnly, for: .calendarEvents)
        await store.setEvents([
            EventKitCalendarEventSnapshot(
                title: "Team standup",
                startDate: fixtureSuggestedDate().addingTimeInterval(-300),
                endDate: fixtureSuggestedDate().addingTimeInterval(1_200),
                isAllDay: false
            )
        ])
        let service = EventKitIntegrationService(storeClient: store)

        let report = await service.detectConflicts(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())

        XCTAssertNil(report)
    }

    func testDetectConflictsDerivesHighPressureWhenDayIsPacked() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let start = fixtureSuggestedDate()
        await store.setEvents([
            EventKitCalendarEventSnapshot(title: "Block 1", startDate: start, endDate: start.addingTimeInterval(2 * 3_600), isAllDay: false),
            EventKitCalendarEventSnapshot(title: "Block 2", startDate: start.addingTimeInterval(2.25 * 3_600), endDate: start.addingTimeInterval(4.25 * 3_600), isAllDay: false),
            EventKitCalendarEventSnapshot(title: "Block 3", startDate: start.addingTimeInterval(4.5 * 3_600), endDate: start.addingTimeInterval(6.5 * 3_600), isAllDay: false)
        ])
        let service = EventKitIntegrationService(storeClient: store)

        let report = await service.detectConflicts(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())

        XCTAssertEqual(report?.pressure, .high)
    }

    func testFetchDerivedBusyWindowsNormalizesAllDayEventsForCalendarDayBoundariesAndDSTAwareness() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        guard let timezone = TimeZone(identifier: "America/New_York") else {
            return XCTFail("Missing New York timezone")
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone
        let allDayStart = calendar.date(
            from: DateComponents(year: 2026, month: 3, day: 8, hour: 10)
        ) ?? Date()
        let allDayEnd = calendar.date(
            from: DateComponents(year: 2026, month: 3, day: 11, hour: 10)
        ) ?? Date()
        await store.setEvents([
            EventKitCalendarEventSnapshot(
                title: "DST-sensitive planning window",
                startDate: allDayStart,
                endDate: allDayEnd,
                isAllDay: true
            )
        ])
        let service = EventKitIntegrationService(storeClient: store, calendar: calendar)
        let queryStart = calendar.startOfDay(for: allDayStart)
        let queryRange = DateInterval(
            start: queryStart,
            end: calendar.date(byAdding: .day, value: 6, to: queryStart) ?? queryStart
        )

        let windows = await service.fetchDerivedBusyWindows(for: queryRange)

        XCTAssertEqual(windows.count, 3)
        let startOfDay = queryStart
        let secondStart = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        let thirdStart = calendar.date(byAdding: .day, value: 2, to: startOfDay) ?? startOfDay
        let fourthStart = calendar.date(byAdding: .day, value: 3, to: startOfDay) ?? startOfDay
        XCTAssertEqual(windows[0].start, startOfDay)
        XCTAssertEqual(windows[1].start, secondStart)
        XCTAssertEqual(windows[2].start, thirdStart)
        XCTAssertEqual(windows.last?.end, fourthStart)
        XCTAssertEqual(windows[0].interval.duration, TimeInterval(23 * 60 * 60), accuracy: 0.001)
        XCTAssertTrue(windows.allSatisfy { $0.title == "Calendar all-day busy time" })
    }

    func testCreateCalendarEventFailsWhenStepHasNoSuggestedDate() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let sideEffectLedger = RecordingEventKitSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )
        let selection = NextStepSchedulingSelection(
            goalID: "goal-1",
            goalTitle: "Ship CFP proposal",
            stepID: "step-1",
            stepTitle: "Draft conference abstract",
            stepSummary: "First concrete draft.",
            suggestedDate: nil
        )

        let operationID = operationID("calendar-missing-date")
        do {
            _ = try await service.createCalendarEvent(
                for: selection,
                durationMinutes: 45,
                now: fixtureNow(),
                operationID: operationID,
                localCommit: runtimeLocalCommitEvidence("calendar-missing-date", operationID: operationID)
            )
            XCTFail("Expected missing date to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .missingEventStartDate)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.status, .failedSafely)
        XCTAssertEqual(record?.boundary, .localOnly)
        XCTAssertEqual(record?.actionKind, .writeCalendarBlock)
        XCTAssertTrue(record?.degradedFacts.contains("Calendar event write request lacked a concrete time.") == true)
        XCTAssertFalse(record?.blockedFacts.contains("Draft conference abstract") == true)
    }

    func testCreateCalendarEventFailsWhenAuthorizationDeniedAndDoesNotSave() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .denied, for: .calendarEvents)
        let sideEffectLedger = RecordingEventKitSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        let operationID = operationID("calendar-authorization-denied")
        do {
            _ = try await service.createCalendarEvent(
                for: fixtureSelection(),
                durationMinutes: 45,
                now: fixtureNow(),
                operationID: operationID,
                localCommit: runtimeLocalCommitEvidence(
                    "calendar-authorization-denied",
                    operationID: operationID
                )
            )
            XCTFail("Expected denied authorization to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .authorizationDenied(scope: .calendarEvents))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let saveCount = await store.currentSaveEventCount()
        XCTAssertEqual(saveCount, 0)

        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.actionKind, .writeCalendarBlock)
        XCTAssertEqual(record?.requiresConfirmation, true)
        assertResultRecord(
            record,
            status: .failedSafely,
            externalEffect: false,
            receiptID: nil,
            degradedFact: "Calendar write permission was denied before EventKit save."
        )
        XCTAssertTrue(record?.blockedFacts.contains("Calendar write permission was not available for this requested calendar event.") == true)
    }

    func testCreateCalendarEventRequiresLocalCommitReceiptBeforeSaving() async throws {
        let store = RecordingEventKitStoreClient()
        let sideEffectLedger = RecordingEventKitSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        do {
            _ = try await service.createCalendarEvent(
                for: fixtureSelection(),
                durationMinutes: 45,
                now: fixtureNow(),
                operationID: operationID("calendar-missing-commit"),
                localCommit: nil
            )
            XCTFail("Expected missing local commit receipt to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .missingLocalCommitReceipt(scope: .calendarEvents))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let saveCount = await store.currentSaveEventCount()
        let authorizationRequestCount = await store.currentAuthorizationRequestCount()
        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(saveCount, 0)
        XCTAssertEqual(authorizationRequestCount, 0)
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.status, .blocked)
        XCTAssertEqual(record?.boundary, .externalEffect)
        XCTAssertEqual(record?.externalEffect, true)
        XCTAssertTrue(record?.blockedFacts.contains("External side effect cannot be attempted before a committed local mutation receipt.") == true)
    }

    func testCreateCalendarEventSaveFailureRecordsFailedResultReceipt() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        await store.setEventSaveFailure(.saveFailed("simulated calendar failure"))
        let sideEffectLedger = RecordingEventKitSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        do {
            let operationID = operationID("calendar-save-failure")
            _ = try await service.createCalendarEvent(
                for: fixtureSelection(),
                durationMinutes: 45,
                now: fixtureNow(),
                operationID: operationID,
                localCommit: runtimeLocalCommitEvidence("calendar-save-failure", operationID: operationID)
            )
            XCTFail("Expected calendar event save failure to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .saveFailed("simulated calendar failure"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let record = await sideEffectLedger.lastRecord
        assertResultRecord(
            record,
            status: .failedSafely,
            externalEffect: true,
            receiptID: nil,
            degradedFact: "Calendar event write could not be completed safely."
        )
    }

    func testCreateCalendarEventSuccessRecordsCalendarSideEffect() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let sideEffectLedger = RecordingEventKitSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        let operationID = operationID("calendar-event")
        let record = try await service.createCalendarEvent(
            for: fixtureSelection(),
            durationMinutes: 45,
            now: fixtureNow(),
            operationID: operationID,
            localCommit: runtimeLocalCommitEvidence("calendar-event", operationID: operationID)
        )

        let records = await sideEffectLedger.records
        let succeededSideEffect = records.first

        XCTAssertEqual(record.identifier, "event-1")
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(succeededSideEffect?.effectKind, .calendar)
        XCTAssertEqual(succeededSideEffect?.actionKind, .writeCalendarBlock)
        XCTAssertEqual(succeededSideEffect?.sourceDomain, .time)
        XCTAssertEqual(succeededSideEffect?.requiresConfirmation, false)
        assertResultRecord(
            succeededSideEffect,
            status: .succeeded,
            externalEffect: true,
            receiptID: "event-1",
            degradedFact: "Calendar event write completed through EventKit side-effect owner."
        )
        XCTAssertTrue(succeededSideEffect?.reasons.contains(.externalSideEffect) == true)
        XCTAssertFalse(records.contains { $0.blockedFacts.contains("Draft conference abstract") })
    }

    func testRepeatedCalendarEventSuccessesRecordDistinctLedgerEntries() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let sideEffectLedger = RecordingEventKitSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        let firstOperationID = operationID("calendar-event-repeat-1")
        _ = try await service.createCalendarEvent(
            for: fixtureSelection(),
            durationMinutes: 45,
            now: fixtureNow(),
            operationID: firstOperationID,
            localCommit: runtimeLocalCommitEvidence("calendar-event-repeat-1", operationID: firstOperationID)
        )
        let secondOperationID = operationID("calendar-event-repeat-2")
        _ = try await service.createCalendarEvent(
            for: fixtureSelection(),
            durationMinutes: 45,
            now: fixtureNow(),
            operationID: secondOperationID,
            localCommit: runtimeLocalCommitEvidence("calendar-event-repeat-2", operationID: secondOperationID)
        )

        let records = await sideEffectLedger.records
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(Set(records.map(\.id)).count, 2)
        XCTAssertTrue(records.allSatisfy { $0.effectKind == .calendar })
        XCTAssertEqual(records.filter { $0.status == .succeeded }.count, 2)
        XCTAssertTrue(records.allSatisfy { $0.externalEffect })
        XCTAssertEqual(Set(records.compactMap(\.receiptID)), ["event-1", "event-2"])
    }
}

private extension EventKitIntegrationServiceTests {
    func sideEffectRequest(
        id: String,
        operationID: String? = nil,
        localCommit: SideEffectLocalCommitEvidence? = nil
    ) -> SideEffectOutboxRequest {
        let resolvedOperationID = operationID ?? self.operationID("concurrent")
        let resolvedCommit = localCommit ?? runtimeLocalCommitEvidence(
            "concurrent",
            operationID: resolvedOperationID
        )
        return SideEffectOutboxRequest(
            id: id,
            effectKind: .calendar,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            commandID: resolvedCommit.authorityCommandID,
            operationID: resolvedOperationID,
            requestedAt: fixtureNow(),
            externalEffect: true,
            requiresConfirmation: false,
            commitRequirement: .localCommitRequired,
            localCommit: resolvedCommit,
            requestedStatus: .queued,
            requestedBoundary: .externalEffect
        )
    }
    func makeReminderRepository() async throws -> SwiftDataReminderRepository {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return SwiftDataReminderRepository(store: store)
    }

    func assertResultRecord(
        _ record: SideEffectLedgerRecord?,
        status: SideEffectLedgerStatus,
        externalEffect: Bool,
        receiptID: String?,
        degradedFact: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(record?.status, status, file: file, line: line)
        XCTAssertEqual(record?.boundary, .externalEffect, file: file, line: line)
        XCTAssertEqual(record?.externalEffect, externalEffect, file: file, line: line)
        XCTAssertEqual(record?.localOnly, externalEffect == false, file: file, line: line)
        receiptID.map { XCTAssertEqual(record?.receiptID, $0, file: file, line: line) } ?? XCTAssertNotNil(record?.receiptID, file: file, line: line)
        XCTAssertTrue(record?.degradedFacts.contains(degradedFact) == true, file: file, line: line)
    }

    func fixtureNow() -> Date {
        Date(timeIntervalSince1970: 1_713_180_000)
    }

    func fixtureSuggestedDate() -> Date {
        fixtureNow().addingTimeInterval(3_600)
    }

    func fixtureSelection() -> NextStepSchedulingSelection {
        NextStepSchedulingSelection(
            goalID: "goal-1",
            goalTitle: "Ship CFP proposal",
            stepID: "step-1",
            stepTitle: "Draft conference abstract",
            stepSummary: "First concrete draft.",
            suggestedDate: fixtureSuggestedDate()
        )
    }

    func runtimeLocalCommitEvidence(_ suffix: String, operationID: String) -> SideEffectLocalCommitEvidence {
        SideEffectLocalCommitEvidence(
            authorityCommandID: "authority.command.\(suffix).\(operationID)",
            operationID: operationID,
            receiptID: "runtime.commit-receipt.\(suffix)",
            writeScope: .localSwiftDataSingleContext,
            committedAt: "2026-04-16T09:00:00Z",
            didCommitChanges: true,
            sideEffectPolicy: AppUnitOfWorkReceipt.noExternalSideEffects,
            runtimeTransactionID: "runtime.transaction.\(suffix)",
            runtimeEventID: "runtime.event.\(suffix)",
            runtimeReceiptID: "runtime.receipt.\(suffix)",
            rollbackPlanID: "runtime.rollback.\(suffix)"
        )
    }

    func operationID(_ suffix: String) -> String {
        let scalarTotal = suffix.unicodeScalars.reduce(0) { ($0 + Int($1.value)) % 0xFFFFFF }
        return String(format: "00000000-0000-4000-8000-%012x", scalarTotal)
    }

    func existingRecord(
        id: String,
        operationID: String,
        status: SideEffectLedgerStatus
    ) -> SideEffectLedgerRecord {
        SideEffectLedgerRecord(
            id: id,
            effectKind: .calendar,
            status: status,
            boundary: .externalEffect,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            commandID: "authority.existing",
            operationID: operationID,
            claimToken: status == .leased ? "existing-token" : nil,
            occurredAt: DomainTimestamp.string(from: fixtureNow()),
            localOnly: false,
            requiresConfirmation: false,
            externalEffect: true,
            receiptID: status == .succeeded ? "existing-reminder" : nil
        )
    }
}

private extension SideEffectClaim {
    var isClaimOwner: Bool {
        if case .claimed = self { return true }
        return false
    }

    var requiresReconciliation: Bool {
        if case .reconciliationRequired = self { return true }
        return false
    }
}

private extension SideEffectLedgerClaimResult {
    var isNewClaim: Bool {
        if case .claimed = self { return true }
        return false
    }
}

private actor FailOnceFinalizeSideEffectLedger: SideEffectLedgerRepository {
    private let base = InMemorySideEffectLedgerRepository()
    private var shouldFailFinalize = true

    func append(_ record: SideEffectLedgerRecord) async throws { try await base.append(record) }
    func fetchRecent(limit: Int) async throws -> [SideEffectLedgerRecord] { try await base.fetchRecent(limit: limit) }
    func fetchRecords(status: SideEffectLedgerStatus) async throws -> [SideEffectLedgerRecord] { try await base.fetchRecords(status: status) }
    func fetchRecord(id: String) async throws -> SideEffectLedgerRecord? { try await base.fetchRecord(id: id) }
    func claim(_ record: SideEffectLedgerRecord, token: String) async throws -> SideEffectLedgerClaimResult {
        try await base.claim(record, token: token)
    }
    func finalize(_ record: SideEffectLedgerRecord, token: String) async throws -> Bool {
        if shouldFailFinalize {
            shouldFailFinalize = false
            struct Interrupted: Error {}
            throw Interrupted()
        }
        return try await base.finalize(record, token: token)
    }
}
