import XCTest
@testable import Ambitions

final class PortableSnapshotServiceTests: XCTestCase {
    func testExportSnapshotIncludesCurrentNativeRepositories() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(sampleGoal(id: "goal-export", revision: 2, updatedAt: "2026-04-18T10:00:00Z"))
        let draft = sampleDraft(id: "draft-export", plannedGoalID: goal.id, updatedAt: "2026-04-18T11:00:00Z")
        let evidence = sampleEvidence(id: "evidence-export", goalID: goal.id, capturedAt: "2026-04-18T12:00:00Z")
        let feedback = sampleFeedback(stepID: "step-export", occurredAt: "2026-04-18T13:00:00Z")
        let capture = sampleCapture(id: "capture-export", updatedAt: "2026-04-18T14:00:00Z")
        let teaching = sampleTeachingSignal(goalID: goal.id, updatedAt: "2026-04-18T14:30:00Z")
        var state = AppStateSnapshot.default
        state.userDisplayName = "Portable User"
        state.lastOpenedGoalID = goal.id

        try await repositories.goals.saveGoals([goal])
        try await repositories.drafts.saveDrafts([draft])
        try await repositories.evidence.saveEvidence([evidence])
        try await repositories.feedback.saveEvents([feedback], goalID: goal.id)
        try await repositories.captures.saveCaptures([capture])
        try await repositories.teaching.saveSignals([teaching])
        try await repositories.appState.saveState(state)

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )

        let snapshot = try await service.exportSnapshot()

        XCTAssertEqual(snapshot.metadata.schemaVersion, .v1)
        XCTAssertEqual(snapshot.metadata.trustPosture, .localOnly)
        XCTAssertEqual(snapshot.metadata.source, "native.local.repositories")
        XCTAssertEqual(snapshot.manifest.userSummary, "This package can move selected local Ambitions data without requiring an account or cloud sync.")
        XCTAssertEqual(snapshot.manifest.summary(for: .goalsAndPlans)?.itemCount, 2)
        XCTAssertEqual(snapshot.manifest.summary(for: .proof)?.itemCount, 1)
        XCTAssertEqual(snapshot.manifest.summary(for: .receipts)?.itemCount, 1)
        XCTAssertEqual(snapshot.manifest.summary(for: .memory)?.itemCount, 1)
        XCTAssertTrue(snapshot.manifest.privacyRules.contains("Preview surfaces must use redacted receipt/proof summaries for private or sensitive details."))
        XCTAssertTrue(snapshot.manifest.exclusions.contains { $0.id == "excluded.cloud-sync-account" })
        XCTAssertEqual(snapshot.goals.map(\.id), [goal.id])
        XCTAssertEqual(snapshot.drafts.map(\.id), [draft.id])
        XCTAssertEqual(snapshot.evidence.map(\.id), [evidence.id])
        XCTAssertEqual(snapshot.feedback.map(\.base.id), [feedback.base.id])
        XCTAssertEqual(snapshot.captures.map(\.id), [capture.id])
        XCTAssertEqual(snapshot.teachingSignals.map(\.id), [teaching.id])
        XCTAssertEqual(snapshot.appState.userDisplayName, "Portable User")
    }

    func testExportSnapshotIncludesCanonicalActionReceiptHistoryAndRevisionTombstones() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(sampleGoal(id: "goal-export-history", revision: 2, updatedAt: "2026-04-18T10:00:00Z"))
        let feedback = sampleFeedback(stepID: try XCTUnwrap(firstStepID(in: goal)), occurredAt: "2026-04-18T13:00:00Z")
        let actionReceipt = sampleActionReceiptHistoryRecord(
            id: "receipt-export-history",
            goalID: goal.id,
            stepID: try XCTUnwrap(firstStepID(in: goal)),
            occurredAt: "2026-04-18T13:30:00Z"
        )
        let tombstone = sampleRevisionTombstone(
            id: "tombstone-export-history",
            entityID: goal.id,
            revisionMarker: "rev-2",
            recordedAt: "2026-04-18T14:00:00Z",
            privacyClass: .privateProof,
            sourceRecordID: "SourceRecord.goal.export",
            receiptID: "Receipt.goal.export",
            replayTraceID: "ReplayTrace.goal.export"
        )

        try await repositories.goals.saveGoals([goal])
        try await repositories.feedback.saveEvents([feedback], goalID: goal.id)
        if let historyRepository = repositories.actionReceiptHistory {
            try await historyRepository.save([actionReceipt])
        }
        if let tombstoneRepository = repositories.entityRevisionTombstones {
            try await tombstoneRepository.append(tombstone)
        }

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )

        let snapshot = try await service.exportSnapshot()

        XCTAssertEqual(snapshot.manifest.summary(for: .receipts)?.itemCount, 3)
        XCTAssertEqual(snapshot.feedback.map(\.base.id), [feedback.base.id])
        XCTAssertEqual(snapshot.actionReceiptHistory.map(\.receipt.id), [actionReceipt.id])
        XCTAssertEqual(snapshot.entityRevisionTombstones.map(\.id), [tombstone.id])
        XCTAssertEqual(snapshot.entityRevisionTombstones.first?.sourceRecordID, nil)
        XCTAssertEqual(snapshot.entityRevisionTombstones.first?.receiptID, nil)
        XCTAssertEqual(snapshot.entityRevisionTombstones.first?.replayTraceID, nil)
        XCTAssertEqual(snapshot.entityRevisionLineageViews.map(\.id), [tombstone.lineageID])
        XCTAssertEqual(snapshot.entityRevisionLineageViews.first?.entityID, nil)
        XCTAssertEqual(snapshot.entityRevisionLineageViews.first?.sourceRecordID, nil)
        XCTAssertTrue(snapshot.entityRevisionLineageViews.first?.isFinalized == true)
        XCTAssertEqual(snapshot.actionReceiptHistory.first?.privacyLevel, .safeToShow)
        XCTAssertEqual(snapshot.entityRevisionTombstones.first?.reason, .replaced)
    }

    func testExportSnapshotSupportsUserSelectedCategoriesWithoutClaimingSync() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(sampleGoal(id: "goal-selected", revision: 1, updatedAt: "2026-04-18T10:00:00Z"))
        let evidence = sampleEvidence(id: "evidence-selected", goalID: goal.id, capturedAt: "2026-04-18T12:00:00Z")
        let capture = sampleCapture(id: "capture-selected", updatedAt: "2026-04-18T14:00:00Z")
        var state = AppStateSnapshot.default
        state.userDisplayName = "Selective User"

        try await repositories.goals.saveGoals([goal])
        try await repositories.evidence.saveEvidence([evidence])
        try await repositories.captures.saveCaptures([capture])
        try await repositories.appState.saveState(state)

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )

        let snapshot = try await service.exportSnapshot(
            selection: PortableExportSelection(categories: [.goalsAndPlans, .settings])
        )

        XCTAssertEqual(snapshot.goals.map(\.id), [goal.id])
        XCTAssertTrue(snapshot.evidence.isEmpty)
        XCTAssertTrue(snapshot.captures.isEmpty)
        XCTAssertEqual(snapshot.appState.userDisplayName, "Selective User")
        XCTAssertEqual(snapshot.manifest.summary(for: .proof)?.isIncluded, false)
        XCTAssertEqual(snapshot.manifest.summary(for: .captures)?.isIncluded, false)
        XCTAssertTrue(snapshot.manifest.exclusions.contains { $0.id == "excluded.proof" })
        XCTAssertTrue(snapshot.manifest.exclusions.contains { $0.id == "excluded.raw-calendar-events" })
    }

    func testReplaceLocalStoreClearsExistingDataAndRestoresSnapshot() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let existingGoal = try XCTUnwrap(sampleGoal(id: "goal-existing", revision: 1, updatedAt: "2026-04-17T10:00:00Z"))
        let incomingGoal = try XCTUnwrap(sampleGoal(id: "goal-incoming", revision: 4, updatedAt: "2026-04-19T10:00:00Z"))
        let incomingDraft = sampleDraft(id: "draft-incoming", plannedGoalID: incomingGoal.id, updatedAt: "2026-04-19T11:00:00Z")
        let incomingEvidence = sampleEvidence(id: "evidence-incoming", goalID: incomingGoal.id, capturedAt: "2026-04-19T12:00:00Z")
        let incomingFeedback = sampleFeedback(stepID: "step-incoming", occurredAt: "2026-04-19T13:00:00Z")
        let incomingActionReceipt = sampleActionReceiptHistoryRecord(
            id: "receipt-incoming",
            goalID: incomingGoal.id,
            stepID: "step-incoming",
            occurredAt: "2026-04-19T13:30:00Z"
        )
        let incomingCapture = sampleCapture(id: "capture-incoming", updatedAt: "2026-04-19T14:00:00Z")
        let incomingTeaching = sampleTeachingSignal(goalID: incomingGoal.id, updatedAt: "2026-04-19T14:30:00Z")
        let existingActionReceipt = sampleActionReceiptHistoryRecord(
            id: "receipt-existing",
            goalID: existingGoal.id,
            stepID: try XCTUnwrap(firstStepID(in: existingGoal)),
            occurredAt: "2026-04-17T13:30:00Z"
        )
        let existingTombstone = sampleRevisionTombstone(
            id: "tombstone-existing",
            entityID: existingGoal.id,
            revisionMarker: "rev-1",
            recordedAt: "2026-04-17T14:00:00Z"
        )
        let incomingTombstone = sampleRevisionTombstone(
            id: "tombstone-incoming",
            entityID: incomingGoal.id,
            revisionMarker: "rev-4",
            recordedAt: "2026-04-19T14:15:00Z"
        )
        var incomingState = AppStateSnapshot.default
        incomingState.userDisplayName = "Restored User"
        incomingState.lastOpenedGoalID = incomingGoal.id

        try await repositories.goals.saveGoals([existingGoal])
        if let historyRepository = repositories.actionReceiptHistory {
            try await historyRepository.save([existingActionReceipt])
        }
        if let tombstoneRepository = repositories.entityRevisionTombstones {
            try await tombstoneRepository.append(existingTombstone)
        }

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )
        let snapshot = PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: .v1,
                exportedAt: "2026-04-19T15:00:00Z",
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: [incomingGoal],
            drafts: [incomingDraft],
            evidence: [incomingEvidence],
            feedback: [incomingFeedback],
            actionReceiptHistory: [PortableStoredActionReceiptHistoryRecord(incomingActionReceipt)],
            entityRevisionTombstones: [incomingTombstone],
            captures: [incomingCapture],
            teachingSignals: [incomingTeaching],
            appState: incomingState
        )

        let report = try await service.importSnapshot(snapshot, mode: .replaceLocalStore)
        let loadedGoals = try await repositories.goals.listGoals()
        let loadedDrafts = try await repositories.drafts.listDrafts()
        let loadedEvidence = try await repositories.evidence.listEvidence(goalID: nil)
        let loadedFeedback = try await repositories.feedback.listEvents(goalID: nil)
        let loadedActionReceipts: [ActionReceiptHistoryRecord]
        if let historyRepository = repositories.actionReceiptHistory {
            loadedActionReceipts = try await historyRepository.listRecords()
        } else {
            loadedActionReceipts = []
        }
        let loadedTombstones: [EntityRevisionTombstone]
        if let tombstoneRepository = repositories.entityRevisionTombstones {
            loadedTombstones = try await tombstoneRepository.fetchRecent(limit: 10)
        } else {
            loadedTombstones = []
        }
        let loadedCaptures = try await repositories.captures.listCaptures()
        let loadedTeaching = try await repositories.teaching.listSignals(goalID: incomingGoal.id)
        let loadedState = try await repositories.appState.loadState()

        XCTAssertEqual(report.importedGoalCount, 1)
        XCTAssertEqual(report.importedActionReceiptHistoryCount, 1)
        XCTAssertEqual(report.importedEntityRevisionTombstoneCount, 1)
        XCTAssertTrue(report.conflicts.isEmpty)
        XCTAssertEqual(loadedGoals.map(\.id), [incomingGoal.id])
        XCTAssertEqual(loadedDrafts.map(\.id), [incomingDraft.id])
        XCTAssertEqual(loadedEvidence.map(\.id), [incomingEvidence.id])
        XCTAssertEqual(loadedFeedback.map(\.base.id), [incomingFeedback.base.id])
        XCTAssertEqual(loadedActionReceipts.map(\.id), [incomingActionReceipt.id])
        XCTAssertEqual(loadedTombstones.map(\.id), [incomingTombstone.id])
        XCTAssertEqual(loadedCaptures.map(\.id), [incomingCapture.id])
        XCTAssertEqual(loadedTeaching.map(\.id), [incomingTeaching.id])
        XCTAssertEqual(loadedState.userDisplayName, "Restored User")
    }

    func testMergeWithConflictReportAddsNonConflictingItemsAndReportsAmbiguousConflicts() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let localGoal = try XCTUnwrap(sampleGoal(id: "goal-shared", revision: 3, updatedAt: "2026-04-19T10:00:00Z"))
        let localCapture = sampleCapture(id: "capture-shared", updatedAt: "2026-04-19T10:00:00Z")
        let incomingGoal = try XCTUnwrap(sampleGoal(id: "goal-shared", revision: 3, updatedAt: "2026-04-19T10:00:00Z", title: "Incoming Conflict"))
        let incomingDraft = sampleDraft(id: "draft-new", plannedGoalID: incomingGoal.id, updatedAt: "2026-04-19T11:00:00Z")

        try await repositories.goals.saveGoals([localGoal])
        try await repositories.captures.saveCaptures([localCapture])

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )
        let snapshot = PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: .v1,
                exportedAt: "2026-04-19T15:00:00Z",
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: [incomingGoal],
            drafts: [incomingDraft],
            evidence: [],
            feedback: [],
            captures: [sampleCapture(id: "capture-shared", updatedAt: "2026-04-19T10:00:00Z", rawText: "Incoming capture conflict")],
            teachingSignals: [sampleTeachingSignal(goalID: "goal-new", updatedAt: "2026-04-19T10:30:00Z")],
            appState: AppStateSnapshot.default
        )

        let report = try await service.importSnapshot(snapshot, mode: .mergeWithConflictReport)
        let loadedDrafts = try await repositories.drafts.listDrafts()
        let loadedGoal = try await repositories.goals.goal(id: localGoal.id)
        let loadedCapture = try await repositories.captures.capture(id: localCapture.id)
        let loadedTeaching = try await repositories.teaching.listSignals(goalID: "goal-new")

        XCTAssertEqual(report.importedDraftCount, 1)
        XCTAssertEqual(report.conflicts.count, 2)
        XCTAssertTrue(report.conflicts.allSatisfy { $0.recommendation == .requiresUserDecision })
        XCTAssertEqual(loadedDrafts.map(\.id), [incomingDraft.id])
        XCTAssertEqual(loadedGoal?.title, localGoal.title)
        XCTAssertEqual(loadedCapture?.rawText, localCapture.rawText)
        XCTAssertEqual(loadedTeaching.count, 1)
    }

    func testImportSnapshotRejectsUnsupportedSchemaVersion() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )
        let snapshot = PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: PortableSnapshotSchemaVersion(rawValue: "portable_app_snapshot.v999"),
                exportedAt: "2026-04-19T15:00:00Z",
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: [],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            teachingSignals: [],
            appState: .default
        )

        await XCTAssertThrowsErrorAsync(try await service.importSnapshot(snapshot, mode: .replaceLocalStore)) { error in
            XCTAssertEqual(error as? PortableSnapshotError, .unsupportedSchemaVersion("portable_app_snapshot.v999"))
        }
    }

    func testImportSnapshotReportsManifestWarningsWithoutSilentlyDroppingLocalData() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let localGoal = try XCTUnwrap(sampleGoal(id: "goal-local", revision: 1, updatedAt: "2026-04-18T10:00:00Z", title: "Local Goal"))
        let incomingGoal = try XCTUnwrap(sampleGoal(id: "goal-incoming-warning", revision: 1, updatedAt: "2026-04-19T10:00:00Z", title: "Incoming Goal"))
        try await repositories.goals.saveGoals([localGoal])

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )
        let staleManifest = PortableExportManifest.make(
            selection: .all,
            goals: [],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            teachingSignals: [],
            appState: .default
        )
        let snapshot = PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: .v1,
                exportedAt: "2026-04-19T15:00:00Z",
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: [incomingGoal],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            teachingSignals: [],
            appState: .default,
            manifest: staleManifest
        )

        let report = try await service.importSnapshot(snapshot, mode: .mergeWithConflictReport)
        let loadedGoals = try await repositories.goals.listGoals()

        XCTAssertEqual(report.importedGoalCount, 1)
        XCTAssertEqual(report.warnings.map(\.id), ["manifest.count.goals_and_plans"])
        XCTAssertEqual(report.safetySummary.warningMessages, ["Goals and plans count does not match the package contents. Review this package before import."])
        XCTAssertEqual(Set(loadedGoals.map(\.id)), [localGoal.id, incomingGoal.id])
    }

    func testImportSnapshotReportsPartialPackageReferencesWithoutDroppingRecords() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let localGoal = try XCTUnwrap(sampleGoal(id: "goal-local-partial", revision: 1, updatedAt: "2026-04-18T10:00:00Z"))
        let incomingDraft = sampleDraft(id: "draft-partial", plannedGoalID: "goal-missing", updatedAt: "2026-04-19T11:00:00Z")
        let incomingEvidence = sampleEvidence(id: "evidence-partial", goalID: "goal-missing", capturedAt: "2026-04-19T12:00:00Z")
        let incomingFeedback = sampleFeedback(stepID: "step-missing", occurredAt: "2026-04-19T13:00:00Z")
        let incomingCapture = sampleCapture(id: "capture-partial", updatedAt: "2026-04-19T14:00:00Z", linkedGoalID: "goal-missing")
        let incomingTeaching = sampleTeachingSignal(goalID: "goal-missing", updatedAt: "2026-04-19T14:30:00Z")
        var incomingState = AppStateSnapshot.default
        incomingState.lastOpenedGoalID = "goal-missing"

        try await repositories.goals.saveGoals([localGoal])

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )
        let snapshot = PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: .v1,
                exportedAt: "2026-04-19T15:00:00Z",
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: [],
            drafts: [incomingDraft],
            evidence: [incomingEvidence],
            feedback: [incomingFeedback],
            captures: [incomingCapture],
            teachingSignals: [incomingTeaching],
            appState: incomingState
        )

        let report = try await service.importSnapshot(snapshot, mode: .mergeWithConflictReport)
        let loadedGoals = try await repositories.goals.listGoals()
        let loadedDrafts = try await repositories.drafts.listDrafts()
        let loadedEvidence = try await repositories.evidence.listEvidence(goalID: nil)
        let loadedFeedback = try await repositories.feedback.listEvents(goalID: nil)
        let loadedCaptures = try await repositories.captures.listCaptures()
        let loadedTeaching = try await repositories.teaching.listSignals(goalID: nil)

        XCTAssertEqual(Set(report.warnings.map(\.id)), [
            "reference.draft.draft-partial.planned_goal",
            "reference.evidence.evidence-partial.goal",
            "reference.feedback.feedback-step-missing.step",
            "reference.capture.capture-partial.goal",
            "reference.memory.teaching-goal-missing-2026-04-19T14:30:00Z.goal",
            "reference.app_state.last_opened_goal"
        ])
        XCTAssertEqual(loadedGoals.map(\.id), [localGoal.id])
        XCTAssertEqual(loadedDrafts.map(\.id), [incomingDraft.id])
        XCTAssertEqual(loadedEvidence.map(\.id), [incomingEvidence.id])
        XCTAssertEqual(loadedFeedback.map(\.base.id), [incomingFeedback.base.id])
        XCTAssertEqual(loadedCaptures.map(\.id), [incomingCapture.id])
        XCTAssertEqual(loadedTeaching.map(\.id), [incomingTeaching.id])
    }

    func testMergeImportKeepsNewerLocalDataAcrossKeyPortableRecords() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let localGoal = try XCTUnwrap(sampleGoal(id: "goal-no-lost-data", revision: 3, updatedAt: "2026-04-20T10:00:00Z", title: "Newer local goal"))
        let incomingGoal = try XCTUnwrap(sampleGoal(id: "goal-no-lost-data", revision: 2, updatedAt: "2026-04-19T10:00:00Z", title: "Older incoming goal"))
        let stepID = try XCTUnwrap(firstStepID(in: localGoal))
        let localEvidence = sampleEvidence(id: "evidence-no-lost-data", goalID: localGoal.id, capturedAt: "2026-04-20T12:00:00Z")
        let incomingEvidence = sampleEvidence(id: "evidence-no-lost-data", goalID: incomingGoal.id, capturedAt: "2026-04-19T12:00:00Z")
        let localFeedback = sampleFeedback(stepID: stepID, occurredAt: "2026-04-20T13:00:00Z")
        let incomingFeedback = sampleFeedback(stepID: stepID, occurredAt: "2026-04-19T13:00:00Z")
        let localCapture = sampleCapture(id: "capture-no-lost-data", updatedAt: "2026-04-20T14:00:00Z", rawText: "Newer local capture")
        let incomingCapture = sampleCapture(id: "capture-no-lost-data", updatedAt: "2026-04-19T14:00:00Z", rawText: "Older incoming capture")
        let localTeaching = sampleTeachingSignal(id: "teaching-no-lost-data", goalID: localGoal.id, updatedAt: "2026-04-20T14:30:00Z")
        let incomingTeaching = sampleTeachingSignal(id: "teaching-no-lost-data", goalID: localGoal.id, updatedAt: "2026-04-19T14:30:00Z")
        let localActionReceipt = sampleActionReceiptHistoryRecord(
            id: "receipt-no-lost-data-local",
            goalID: localGoal.id,
            stepID: stepID,
            occurredAt: "2026-04-20T15:00:00Z"
        )
        let incomingActionReceipt = sampleActionReceiptHistoryRecord(
            id: "receipt-no-lost-data-incoming",
            goalID: incomingGoal.id,
            stepID: stepID,
            occurredAt: "2026-04-19T15:00:00Z"
        )
        let localTombstone = sampleRevisionTombstone(
            id: "tombstone-no-lost-data-local",
            entityID: localGoal.id,
            revisionMarker: "rev-local",
            recordedAt: "2026-04-20T15:30:00Z"
        )
        let incomingTombstone = sampleRevisionTombstone(
            id: "tombstone-no-lost-data-incoming",
            entityID: incomingGoal.id,
            revisionMarker: "rev-incoming",
            recordedAt: "2026-04-19T15:30:00Z"
        )

        try await repositories.goals.saveGoals([localGoal])
        try await repositories.evidence.saveEvidence([localEvidence])
        try await repositories.feedback.saveEvents([localFeedback], goalID: localGoal.id)
        if let historyRepository = repositories.actionReceiptHistory {
            try await historyRepository.save([localActionReceipt])
        }
        if let tombstoneRepository = repositories.entityRevisionTombstones {
            try await tombstoneRepository.append(localTombstone)
        }
        try await repositories.captures.saveCaptures([localCapture])
        try await repositories.teaching.saveSignals([localTeaching])

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )
        let snapshot = PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: .v1,
                exportedAt: "2026-04-19T15:00:00Z",
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: [incomingGoal],
            drafts: [],
            evidence: [incomingEvidence],
            feedback: [incomingFeedback],
            actionReceiptHistory: [PortableStoredActionReceiptHistoryRecord(incomingActionReceipt)],
            entityRevisionTombstones: [incomingTombstone],
            captures: [incomingCapture],
            teachingSignals: [incomingTeaching],
            appState: .default
        )

        let report = try await service.importSnapshot(snapshot, mode: .mergeWithConflictReport)
        let restoredGoal = try await repositories.goals.goal(id: localGoal.id)
        let restoredEvidence = try await repositories.evidence.listEvidence(goalID: nil)
        let restoredFeedback = try await repositories.feedback.listEvents(goalID: localGoal.id)
        let restoredActionReceipts: [ActionReceiptHistoryRecord]
        if let historyRepository = repositories.actionReceiptHistory {
            restoredActionReceipts = try await historyRepository.listRecords()
        } else {
            restoredActionReceipts = []
        }
        let restoredTombstones: [EntityRevisionTombstone]
        if let tombstoneRepository = repositories.entityRevisionTombstones {
            restoredTombstones = try await tombstoneRepository.fetchRecent(limit: 10)
        } else {
            restoredTombstones = []
        }
        let restoredCapture = try await repositories.captures.capture(id: localCapture.id)
        let restoredTeaching = try await repositories.teaching.listSignals(goalID: localGoal.id)

        XCTAssertEqual(report.conflicts.map(\.recommendation), Array(repeating: .keepLocal, count: 5))
        XCTAssertEqual(report.importedGoalCount, 0)
        XCTAssertEqual(report.importedEvidenceCount, 0)
        XCTAssertEqual(report.importedFeedbackCount, 0)
        XCTAssertEqual(report.importedActionReceiptHistoryCount, 1)
        XCTAssertEqual(report.importedEntityRevisionTombstoneCount, 1)
        XCTAssertEqual(report.importedCaptureCount, 0)
        XCTAssertEqual(report.importedTeachingSignalCount, 0)
        XCTAssertEqual(restoredGoal?.title, "Newer local goal")
        XCTAssertEqual(restoredEvidence.map(\.capturedAt), [localEvidence.capturedAt])
        XCTAssertEqual(restoredFeedback.map(\.base.occurredAt), [localFeedback.base.occurredAt])
        XCTAssertEqual(Set(restoredActionReceipts.map(\.id)), Set([localActionReceipt.id, incomingActionReceipt.id]))
        XCTAssertEqual(Set(restoredTombstones.map(\.id)), Set([localTombstone.id, incomingTombstone.id]))
        XCTAssertEqual(restoredCapture?.rawText, "Newer local capture")
        XCTAssertEqual(restoredTeaching.map(\.updatedAt), [localTeaching.updatedAt])
    }

    func testDryRunReplaceReportsIncomingPackageWithoutResettingLocalStore() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let localGoal = try XCTUnwrap(sampleGoal(id: "goal-dry-run-local", revision: 1, updatedAt: "2026-04-18T10:00:00Z"))
        let incomingGoal = try XCTUnwrap(sampleGoal(id: "goal-dry-run-incoming", revision: 2, updatedAt: "2026-04-19T10:00:00Z"))
        let incomingCapture = sampleCapture(id: "capture-dry-run-incoming", updatedAt: "2026-04-19T14:00:00Z")
        var incomingState = AppStateSnapshot.default
        incomingState.userDisplayName = "Dry Run Incoming"

        try await repositories.goals.saveGoals([localGoal])

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )
        let snapshot = PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: .v1,
                exportedAt: "2026-04-19T15:00:00Z",
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: [incomingGoal],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [incomingCapture],
            teachingSignals: [],
            appState: incomingState
        )

        let report = try await service.dryRunImportSnapshot(snapshot, mode: .replaceLocalStore)
        let loadedGoals = try await repositories.goals.listGoals()
        let loadedCaptures = try await repositories.captures.listCaptures()
        let loadedState = try await repositories.appState.loadState()

        XCTAssertTrue(report.wouldResetLocalStore)
        XCTAssertEqual(report.wouldImportGoalCount, 1)
        XCTAssertEqual(report.wouldImportCaptureCount, 1)
        XCTAssertEqual(report.wouldImportAppStateCount, 1)
        XCTAssertFalse(report.durableMutationAllowed)
        XCTAssertTrue(report.safetySummary.requiresExplicitConfirmation)
        XCTAssertEqual(loadedGoals.map(\.id), [localGoal.id])
        XCTAssertTrue(loadedCaptures.isEmpty)
        XCTAssertEqual(loadedState.userDisplayName, "")
    }

    func testDryRunMergeReportsAcceptedItemsAndConflictsWithoutSaving() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let localGoal = try XCTUnwrap(sampleGoal(id: "goal-dry-run-shared", revision: 3, updatedAt: "2026-04-19T10:00:00Z"))
        let incomingGoal = try XCTUnwrap(sampleGoal(id: "goal-dry-run-shared", revision: 3, updatedAt: "2026-04-19T10:00:00Z", title: "Incoming dry-run conflict"))
        let incomingDraft = sampleDraft(id: "draft-dry-run-new", plannedGoalID: incomingGoal.id, updatedAt: "2026-04-19T11:00:00Z")
        let incomingCapture = sampleCapture(id: "capture-dry-run-new", updatedAt: "2026-04-19T14:00:00Z")

        try await repositories.goals.saveGoals([localGoal])

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )
        let snapshot = PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: .v1,
                exportedAt: "2026-04-19T15:00:00Z",
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: [incomingGoal],
            drafts: [incomingDraft],
            evidence: [],
            feedback: [],
            captures: [incomingCapture],
            teachingSignals: [],
            appState: .default
        )

        let report = try await service.dryRunImportSnapshot(snapshot, mode: .mergeWithConflictReport)
        let loadedDrafts = try await repositories.drafts.listDrafts()
        let loadedCaptures = try await repositories.captures.listCaptures()
        let loadedGoal = try await repositories.goals.goal(id: localGoal.id)

        XCTAssertFalse(report.wouldResetLocalStore)
        XCTAssertEqual(report.wouldImportDraftCount, 1)
        XCTAssertEqual(report.wouldImportCaptureCount, 1)
        XCTAssertEqual(report.wouldImportGoalCount, 0)
        XCTAssertEqual(report.wouldImportAppStateCount, 1)
        XCTAssertEqual(report.conflicts.map(\.recommendation), [.requiresUserDecision])
        XCTAssertFalse(report.durableMutationAllowed)
        XCTAssertEqual(report.safetySummary.wouldImportItemCount, 3)
        XCTAssertTrue(loadedDrafts.isEmpty)
        XCTAssertTrue(loadedCaptures.isEmpty)
        XCTAssertEqual(loadedGoal?.title, localGoal.title)
    }

    func testManualMergePlanTurnsDryRunConflictsIntoReviewActionsWithoutSaving() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let localGoal = try XCTUnwrap(sampleGoal(id: "goal-manual-merge", revision: 3, updatedAt: "2026-04-19T10:00:00Z"))
        let incomingGoal = try XCTUnwrap(sampleGoal(id: "goal-manual-merge", revision: 3, updatedAt: "2026-04-19T10:00:00Z", title: "Incoming manual merge conflict"))
        let incomingDraft = sampleDraft(id: "draft-manual-merge-new", plannedGoalID: incomingGoal.id, updatedAt: "2026-04-19T11:00:00Z")

        try await repositories.goals.saveGoals([localGoal])

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )
        let snapshot = PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: .v1,
                exportedAt: "2026-04-19T15:00:00Z",
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: [incomingGoal],
            drafts: [incomingDraft],
            evidence: [],
            feedback: [],
            captures: [],
            teachingSignals: [],
            appState: .default
        )

        let plan = try await service.manualMergePlan(for: snapshot)
        let loadedDrafts = try await repositories.drafts.listDrafts()
        let loadedGoal = try await repositories.goals.goal(id: localGoal.id)

        XCTAssertEqual(plan.mode, .mergeWithConflictReport)
        XCTAssertEqual(plan.safeImportItemCount, 2)
        XCTAssertEqual(plan.reviewItemCount, 1)
        XCTAssertFalse(plan.durableMutationAllowed)
        XCTAssertTrue(plan.userDecisionRequired)
        XCTAssertEqual(plan.items.map(\.action), [.needsReview])
        XCTAssertEqual(plan.items.first?.entityID, localGoal.id)
        XCTAssertTrue(loadedDrafts.isEmpty)
        XCTAssertEqual(loadedGoal?.title, localGoal.title)
    }

    func testNewPhoneDisasterDrillRestoresEncodedPackageIntoFreshStore() async throws {
        let sourceStore = try AmbitionsPersistenceStore(inMemory: true)
        let sourceRepositories = makeRepositories(store: sourceStore)
        let goal = try XCTUnwrap(sampleGoal(id: "goal-new-phone", revision: 2, updatedAt: "2026-04-18T10:00:00Z"))
        let evidence = sampleEvidence(id: "evidence-new-phone", goalID: goal.id, capturedAt: "2026-04-18T12:00:00Z")
        let feedback = sampleFeedback(stepID: try XCTUnwrap(firstStepID(in: goal)), occurredAt: "2026-04-18T13:00:00Z")
        let capture = sampleCapture(id: "capture-new-phone", updatedAt: "2026-04-18T14:00:00Z")
        let teaching = sampleTeachingSignal(goalID: goal.id, updatedAt: "2026-04-18T14:30:00Z")
        let actionReceipt = sampleActionReceiptHistoryRecord(
            id: "receipt-new-phone",
            goalID: goal.id,
            stepID: try XCTUnwrap(firstStepID(in: goal)),
            occurredAt: "2026-04-18T13:30:00Z"
        )
        let tombstone = sampleRevisionTombstone(
            id: "tombstone-new-phone",
            entityID: goal.id,
            revisionMarker: "rev-2",
            recordedAt: "2026-04-18T13:45:00Z"
        )
        var state = AppStateSnapshot.default
        state.userDisplayName = "Restored New Phone"
        state.lastOpenedGoalID = goal.id

        try await sourceRepositories.goals.saveGoals([goal])
        try await sourceRepositories.evidence.saveEvidence([evidence])
        try await sourceRepositories.feedback.saveEvents([feedback], goalID: goal.id)
        if let historyRepository = sourceRepositories.actionReceiptHistory {
            try await historyRepository.save([actionReceipt])
        }
        if let tombstoneRepository = sourceRepositories.entityRevisionTombstones {
            try await tombstoneRepository.append(tombstone)
        }
        try await sourceRepositories.captures.saveCaptures([capture])
        try await sourceRepositories.teaching.saveSignals([teaching])
        try await sourceRepositories.appState.saveState(state)

        let sourceService = PortableSnapshotService(
            repositories: sourceRepositories,
            resetStore: { try await sourceStore.resetAllData() }
        )
        let exported = try await sourceService.exportSnapshot()
        let packageData = try PersistenceCoding.encoder.encode(exported)
        let decodedPackage = try PersistenceCoding.decoder.decode(PortableAppSnapshot.self, from: packageData)

        let freshStore = try AmbitionsPersistenceStore(inMemory: true)
        let freshRepositories = makeRepositories(store: freshStore)
        let freshService = PortableSnapshotService(
            repositories: freshRepositories,
            resetStore: { try await freshStore.resetAllData() }
        )

        let report = try await freshService.importSnapshot(decodedPackage, mode: .replaceLocalStore)
        let restoredGoals = try await freshRepositories.goals.listGoals()
        let restoredEvidence = try await freshRepositories.evidence.listEvidence(goalID: nil)
        let restoredFeedback = try await freshRepositories.feedback.listEvents(goalID: nil)
        let restoredActionReceipts: [ActionReceiptHistoryRecord]
        if let historyRepository = freshRepositories.actionReceiptHistory {
            restoredActionReceipts = try await historyRepository.listRecords()
        } else {
            restoredActionReceipts = []
        }
        let restoredTombstones: [EntityRevisionTombstone]
        if let tombstoneRepository = freshRepositories.entityRevisionTombstones {
            restoredTombstones = try await tombstoneRepository.fetchRecent(limit: 10)
        } else {
            restoredTombstones = []
        }
        let restoredCaptures = try await freshRepositories.captures.listCaptures()
        let restoredTeaching = try await freshRepositories.teaching.listSignals(goalID: goal.id)
        let restoredState = try await freshRepositories.appState.loadState()

        XCTAssertEqual(report.importedGoalCount, 1)
        XCTAssertEqual(report.importedEvidenceCount, 1)
        XCTAssertEqual(report.importedFeedbackCount, 1)
        XCTAssertEqual(report.importedActionReceiptHistoryCount, 1)
        XCTAssertEqual(report.importedEntityRevisionTombstoneCount, 1)
        XCTAssertEqual(report.importedCaptureCount, 1)
        XCTAssertEqual(report.importedTeachingSignalCount, 1)
        XCTAssertTrue(report.safetySummary.requiresExplicitConfirmation)
        XCTAssertEqual(restoredGoals.map(\.id), [goal.id])
        XCTAssertEqual(restoredEvidence.map(\.id), [evidence.id])
        XCTAssertEqual(restoredFeedback.map(\.base.id), [feedback.base.id])
        XCTAssertEqual(restoredActionReceipts.map(\.id), [actionReceipt.id])
        XCTAssertEqual(restoredTombstones.map(\.id), [tombstone.id])
        XCTAssertEqual(restoredCaptures.map(\.id), [capture.id])
        XCTAssertEqual(restoredTeaching.map(\.id), [teaching.id])
        XCTAssertEqual(restoredState.userDisplayName, "Restored New Phone")
    }

    func testPortableSnapshotRoundTripsAdditiveSharedLifeMetadata() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(sampleGoal(id: "goal-shared-life", revision: 2, updatedAt: "2026-04-18T10:00:00Z"))
        try await repositories.goals.saveGoals([goal])

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )

        let snapshot = try await service.exportSnapshot()
        XCTAssertEqual(snapshot.goals.first?.lifeGraph?.sharedLife?.participants.map(\.displayName), ["Alex"])

        let report = try await service.importSnapshot(snapshot, mode: .replaceLocalStore)
        let restored = try await repositories.goals.goal(id: goal.id)

        XCTAssertEqual(report.importedGoalCount, 1)
        XCTAssertEqual(restored?.lifeGraph?.sharedLife?.responsibilities.map(\.title), ["Groceries"])
    }

    func testPortableSnapshotDecodesMissingTeachingSignalsAsEmptyAndGeneratesManifest() throws {
        let data = Data(
            """
            {
              "metadata": {
                "schemaVersion": "portable_app_snapshot.v1",
                "exportedAt": "2026-04-19T15:00:00Z",
                "source": "native.local.repositories",
                "trustPosture": "local_only"
              },
              "goals": [],
              "drafts": [],
              "evidence": [],
              "feedback": [],
              "captures": [],
              "appState": {
                "id": "app_state.default",
                "preferredTab": "today",
                "userDisplayName": "",
                "appearancePreference": "system",
                "reviewCadenceDays": 7,
                "localOnlyModeEnabled": true,
                "hasCompletedBootstrap": false,
                "goalPriorityOrder": []
              }
            }
            """.utf8
        )

        let snapshot = try PersistenceCoding.decoder.decode(PortableAppSnapshot.self, from: data)

        XCTAssertTrue(snapshot.teachingSignals.isEmpty)
        XCTAssertEqual(snapshot.manifest.summary(for: .goalsAndPlans)?.itemCount, 0)
        XCTAssertEqual(snapshot.manifest.userSummary, "This package can move selected local Ambitions data without requiring an account or cloud sync.")
    }

    func testLegacyPackageWithoutManifestCanMergeWithoutDeletingLocalData() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let localGoal = try XCTUnwrap(sampleGoal(id: "goal-legacy-local", revision: 1, updatedAt: "2026-04-18T10:00:00Z"))
        try await repositories.goals.saveGoals([localGoal])
        let data = Data(
            """
            {
              "metadata": {
                "schemaVersion": "portable_app_snapshot.v1",
                "exportedAt": "2026-04-19T15:00:00Z",
                "source": "native.local.repositories",
                "trustPosture": "local_only"
              },
              "goals": [],
              "drafts": [],
              "evidence": [],
              "feedback": [],
              "captures": [],
              "appState": {
                "id": "app_state.default",
                "preferredTab": "today",
                "userDisplayName": "",
                "appearancePreference": "system",
                "reviewCadenceDays": 7,
                "localOnlyModeEnabled": true,
                "hasCompletedBootstrap": false,
                "goalPriorityOrder": []
              }
            }
            """.utf8
        )
        let snapshot = try PersistenceCoding.decoder.decode(PortableAppSnapshot.self, from: data)
        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )

        let report = try await service.importSnapshot(snapshot, mode: .mergeWithConflictReport)
        let loadedGoals = try await repositories.goals.listGoals()

        XCTAssertTrue(report.warnings.isEmpty)
        XCTAssertEqual(report.importedGoalCount, 0)
        XCTAssertEqual(loadedGoals.map(\.id), [localGoal.id])
    }

    func testMalformedPortablePackageDecodeFailureLeavesLocalDataUntouched() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let localGoal = try XCTUnwrap(sampleGoal(id: "goal-malformed-local", revision: 1, updatedAt: "2026-04-18T10:00:00Z"))
        try await repositories.goals.saveGoals([localGoal])
        let malformedData = Data(#"{ "metadata": { "schemaVersion": "portable_app_snapshot.v1" }, "goals": ["#.utf8)

        XCTAssertThrowsError(try PersistenceCoding.decoder.decode(PortableAppSnapshot.self, from: malformedData))
        let loadedGoals = try await repositories.goals.listGoals()
        XCTAssertEqual(loadedGoals.map(\.id), [localGoal.id])
    }
}

private extension PortableSnapshotServiceTests {
    func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            actionReceiptHistory: SwiftDataActionReceiptHistoryRepository(store: store),
            entityRevisionTombstones: SwiftDataEntityRevisionTombstoneRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func sampleTeachingSignal(id: String? = nil, goalID: String, updatedAt: String) -> GoalTeachingSignal {
        GoalTeachingSignal(
            id: id ?? "teaching-\(goalID)-\(updatedAt)",
            goalID: goalID,
            createdAt: updatedAt,
            updatedAt: updatedAt,
            source: .explicitManualCorrection,
            kind: .goalSubjectCorrection,
            disposition: .active,
            anchor: GoalTeachingStableAnchor(
                artifactKind: .goalSubjectField,
                canonicalField: .goalSubject,
                candidateID: nil,
                stageID: nil,
                stepID: nil,
                targetFingerprint: "goal_subject",
                contradictionCode: nil,
                contradictionArtifactRefs: []
            ),
            payload: .goalSubject(
                GoalTeachingGoalSubjectCorrection(correctedCanonicalIntent: "Become an astronaut")
            ),
            applicationKey: "goal-subject::\(goalID)",
            userNote: nil
        )
    }

    func sampleGoal(id: String, revision: Int, updatedAt: String, title: String = "Portable Goal") -> Goal? {
        guard let fixture = GoalEngineFixtures.fixture(id: "clear-timed-self-goal") else {
            return nil
        }

        switch fixture.result {
        case let .planned(result):
            return Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: id,
                revision: revision,
                createdAt: "2026-04-18T09:00:00Z",
                updatedAt: updatedAt,
                state: .active,
                title: title,
                summary: result.draft.summary,
                mode: result.draft.mode,
                relationshipKind: result.draft.relationshipKind,
                actor: result.draft.actor,
                parentGoalID: result.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: result.draft.tags,
                timing: result.draft.timing,
                planningStrategy: result.draft.planningStrategy,
                progressStrategy: result.draft.progressStrategy,
                plan: result.plan,
                lifeGraph: LifeGraphContext(
                    domains: [LifeDomainAssignment(domain: .home)],
                    roles: [LifeRole(kind: .supporting, title: "Partner support")],
                    path: nil,
                    stages: [],
                    prerequisites: [],
                    milestones: [],
                    sharedLife: SharedLifeContext(
                        participants: [SharedLifeParticipant(id: "partner", displayName: "Alex", relationshipKind: .partner, roleLabel: "Partner")],
                        responsibilities: [SharedResponsibility(id: "groceries", title: "Groceries", kind: .household, participantID: "partner")]
                    )
                )
            )
        case let .starterPlanned(result):
            return Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: id,
                revision: revision,
                createdAt: "2026-04-18T09:00:00Z",
                updatedAt: updatedAt,
                state: .active,
                title: title,
                summary: result.draft.summary,
                mode: result.draft.mode,
                relationshipKind: result.draft.relationshipKind,
                actor: result.draft.actor,
                parentGoalID: result.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: result.draft.tags,
                timing: result.draft.timing,
                planningStrategy: result.draft.planningStrategy,
                progressStrategy: result.draft.progressStrategy,
                plan: result.plan,
                lifeGraph: LifeGraphContext(
                    domains: [LifeDomainAssignment(domain: .home)],
                    roles: [LifeRole(kind: .supporting, title: "Partner support")],
                    path: nil,
                    stages: [],
                    prerequisites: [],
                    milestones: [],
                    sharedLife: SharedLifeContext(
                        participants: [SharedLifeParticipant(id: "partner", displayName: "Alex", relationshipKind: .partner, roleLabel: "Partner")],
                        responsibilities: [SharedResponsibility(id: "groceries", title: "Groceries", kind: .household, participantID: "partner")]
                    )
                )
            )
        case .clarificationRequired, .blocked:
            return nil
        }
    }

    func sampleDraft(id: String, plannedGoalID: String?, updatedAt: String) -> PersistedGoalDraft {
        PersistedGoalDraft(
            id: id,
            createdAt: "2026-04-18T09:30:00Z",
            updatedAt: updatedAt,
            draft: GoalDraft(
                schemaVersion: goalEngineSchemaVersion,
                source: .manual,
                title: "Portable Draft",
                summary: "Draft summary",
                mode: .project,
                relationshipKind: .independent,
                actor: GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: nil, isPrimary: true),
                parentGoalID: nil,
                tags: [],
                timing: GoalTiming(tempo: .untimed, timingType: .logWhenDone, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7),
                planningStrategy: PlanningStrategy(
                    strategyKind: .sequential,
                    allowParallelSteps: true,
                    maxActiveSteps: 3,
                    preferredSectionOrder: [.overview, .activeSteps, .upcoming],
                    defaultStepType: .actionUnit,
                    autoGenerateReviewSection: false,
                    preferShortSteps: false,
                    revisitCadenceDays: 7
                ),
                progressStrategy: ProgressStrategy(
                    metricKind: .stepCompletion,
                    rollupMethod: .weightedRatio,
                    targetStepCount: 3,
                    targetEvidenceCount: nil,
                    targetMinutes: nil,
                    supportsUntimedProgress: true,
                    countsChildGoals: false,
                    countsSupportGoals: false
                )
            ),
            classification: nil,
            clarification: nil,
            stagedPlan: nil,
            assumptions: [],
            blockers: [],
            metadata: nil,
            plannedGoalID: plannedGoalID,
            latestResultKind: .planned
        )
    }

    func sampleEvidence(id: String, goalID: String, capturedAt: String) -> ProgressEvidence {
        ProgressEvidence(
            id: id,
            goalID: goalID,
            stepID: "step-\(id)",
            evidenceKind: .sessionLogged,
            source: .manual,
            capturedAt: capturedAt,
            progressDelta: 0.2,
            confidenceDelta: 0.1,
            minutesInvested: 25,
            note: "Portable snapshot evidence"
        )
    }

    func sampleFeedback(stepID: String, occurredAt: String) -> GoalFeedbackEvent {
        .completed(
            base: GoalFeedbackEventBase(
                id: "feedback-\(stepID)",
                stepID: stepID,
                occurredAt: occurredAt,
                note: "Portable feedback"
            ),
            actualDuration: 20,
            effortLevel: .medium,
            confidenceDelta: 0.1
        )
    }

    func sampleActionReceiptHistoryRecord(
        id: String,
        goalID: String,
        stepID: String,
        occurredAt: String
    ) -> ActionReceiptHistoryRecord {
        let goal = LifeGraphObjectReference(kind: .goal, id: goalID, label: "Portable Goal", sourceDomain: .goals)
        let step = LifeGraphObjectReference(kind: .step, id: stepID, parentContextID: goalID, label: "Portable Step", sourceDomain: .time)
        let receipt = ActionReceipt(
            id: id,
            resultState: .completed,
            title: "Portable receipt",
            summary: "Portable receipt summary.",
            sourceDomain: .time,
            occurredAt: occurredAt,
            affectedObjects: [goal, step],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).changed",
                    kind: .completedTask,
                    object: step,
                    summary: "Portable step completed."
                )
            ],
            correctionAvailability: .unavailable,
            undoAvailability: .availableLocal
        )
        return ActionReceiptHistoryRecord(
            receipt: receipt,
            privacyLevel: .safeToShow,
            localOnly: true
        )
    }

    func sampleRevisionTombstone(
        id: String,
        entityID: String,
        revisionMarker: String,
        recordedAt: String,
        privacyClass: AmbitionPrivacyClass = .privateUserText,
        sourceRecordID: String? = nil,
        receiptID: String? = nil,
        replayTraceID: String? = nil
    ) -> EntityRevisionTombstone {
        EntityRevisionTombstone(
            id: id,
            entityKind: .goal,
            entityID: entityID,
            revisionMarker: revisionMarker,
            reason: .replaced,
            recordedAt: recordedAt,
            privacyClass: privacyClass,
            sourceRecordID: sourceRecordID,
            receiptID: receiptID,
            replayTraceID: replayTraceID
        )
    }

    func sampleCapture(id: String, updatedAt: String, rawText: String = "Portable capture", linkedGoalID: String? = nil) -> Capture {
        Capture(
            id: id,
            createdAt: "2026-04-18T09:00:00Z",
            updatedAt: updatedAt,
            rawText: rawText,
            sourceType: .todayQuickCapture,
            status: .actionable,
            linkedGoalID: linkedGoalID
        )
    }

    func firstStepID(in goal: Goal) -> String? {
        goal.plan?.sections.first?.steps.first?.id
    }
}

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ errorHandler: (Error) -> Void
) async {
    do {
        _ = try await expression()
        XCTFail("Expected expression to throw")
    } catch {
        errorHandler(error)
    }
}
