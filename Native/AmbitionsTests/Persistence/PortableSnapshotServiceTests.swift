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
        var state = AppStateSnapshot.default
        state.userDisplayName = "Portable User"
        state.lastOpenedGoalID = goal.id

        try await repositories.goals.saveGoals([goal])
        try await repositories.drafts.saveDrafts([draft])
        try await repositories.evidence.saveEvidence([evidence])
        try await repositories.feedback.saveEvents([feedback], goalID: goal.id)
        try await repositories.captures.saveCaptures([capture])
        try await repositories.appState.saveState(state)

        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )

        let snapshot = try await service.exportSnapshot()

        XCTAssertEqual(snapshot.metadata.schemaVersion, .v1)
        XCTAssertEqual(snapshot.metadata.trustPosture, .localOnly)
        XCTAssertEqual(snapshot.metadata.source, "native.local.repositories")
        XCTAssertEqual(snapshot.goals.map(\.id), [goal.id])
        XCTAssertEqual(snapshot.drafts.map(\.id), [draft.id])
        XCTAssertEqual(snapshot.evidence.map(\.id), [evidence.id])
        XCTAssertEqual(snapshot.feedback.map(\.base.id), [feedback.base.id])
        XCTAssertEqual(snapshot.captures.map(\.id), [capture.id])
        XCTAssertEqual(snapshot.appState.userDisplayName, "Portable User")
    }

    func testReplaceLocalStoreClearsExistingDataAndRestoresSnapshot() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let existingGoal = try XCTUnwrap(sampleGoal(id: "goal-existing", revision: 1, updatedAt: "2026-04-17T10:00:00Z"))
        let incomingGoal = try XCTUnwrap(sampleGoal(id: "goal-incoming", revision: 4, updatedAt: "2026-04-19T10:00:00Z"))
        let incomingDraft = sampleDraft(id: "draft-incoming", plannedGoalID: incomingGoal.id, updatedAt: "2026-04-19T11:00:00Z")
        let incomingEvidence = sampleEvidence(id: "evidence-incoming", goalID: incomingGoal.id, capturedAt: "2026-04-19T12:00:00Z")
        let incomingFeedback = sampleFeedback(stepID: "step-incoming", occurredAt: "2026-04-19T13:00:00Z")
        let incomingCapture = sampleCapture(id: "capture-incoming", updatedAt: "2026-04-19T14:00:00Z")
        var incomingState = AppStateSnapshot.default
        incomingState.userDisplayName = "Restored User"
        incomingState.lastOpenedGoalID = incomingGoal.id

        try await repositories.goals.saveGoals([existingGoal])

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
            captures: [incomingCapture],
            appState: incomingState
        )

        let report = try await service.importSnapshot(snapshot, mode: .replaceLocalStore)
        let loadedGoals = try await repositories.goals.listGoals()
        let loadedDrafts = try await repositories.drafts.listDrafts()
        let loadedEvidence = try await repositories.evidence.listEvidence(goalID: nil)
        let loadedFeedback = try await repositories.feedback.listEvents(goalID: nil)
        let loadedCaptures = try await repositories.captures.listCaptures()
        let loadedState = try await repositories.appState.loadState()

        XCTAssertEqual(report.importedGoalCount, 1)
        XCTAssertTrue(report.conflicts.isEmpty)
        XCTAssertEqual(loadedGoals.map(\.id), [incomingGoal.id])
        XCTAssertEqual(loadedDrafts.map(\.id), [incomingDraft.id])
        XCTAssertEqual(loadedEvidence.map(\.id), [incomingEvidence.id])
        XCTAssertEqual(loadedFeedback.map(\.base.id), [incomingFeedback.base.id])
        XCTAssertEqual(loadedCaptures.map(\.id), [incomingCapture.id])
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
            appState: AppStateSnapshot.default
        )

        let report = try await service.importSnapshot(snapshot, mode: .mergeWithConflictReport)
        let loadedDrafts = try await repositories.drafts.listDrafts()
        let loadedGoal = try await repositories.goals.goal(id: localGoal.id)
        let loadedCapture = try await repositories.captures.capture(id: localCapture.id)

        XCTAssertEqual(report.importedDraftCount, 1)
        XCTAssertEqual(report.conflicts.count, 2)
        XCTAssertTrue(report.conflicts.allSatisfy { $0.recommendation == .requiresUserDecision })
        XCTAssertEqual(loadedDrafts.map(\.id), [incomingDraft.id])
        XCTAssertEqual(loadedGoal?.title, localGoal.title)
        XCTAssertEqual(loadedCapture?.rawText, localCapture.rawText)
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
            appState: .default
        )

        await XCTAssertThrowsErrorAsync(try await service.importSnapshot(snapshot, mode: .replaceLocalStore)) { error in
            XCTAssertEqual(error as? PortableSnapshotError, .unsupportedSchemaVersion("portable_app_snapshot.v999"))
        }
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
            appState: SwiftDataAppStateRepository(store: store)
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
                plan: result.plan
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
                plan: result.plan
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

    func sampleCapture(id: String, updatedAt: String, rawText: String = "Portable capture") -> Capture {
        Capture(
            id: id,
            createdAt: "2026-04-18T09:00:00Z",
            updatedAt: updatedAt,
            rawText: rawText,
            sourceType: .todayQuickCapture,
            status: .actionable,
            linkedGoalID: nil
        )
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
