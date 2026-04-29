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
        let incomingCapture = sampleCapture(id: "capture-incoming", updatedAt: "2026-04-19T14:00:00Z")
        let incomingTeaching = sampleTeachingSignal(goalID: incomingGoal.id, updatedAt: "2026-04-19T14:30:00Z")
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
            teachingSignals: [incomingTeaching],
            appState: incomingState
        )

        let report = try await service.importSnapshot(snapshot, mode: .replaceLocalStore)
        let loadedGoals = try await repositories.goals.listGoals()
        let loadedDrafts = try await repositories.drafts.listDrafts()
        let loadedEvidence = try await repositories.evidence.listEvidence(goalID: nil)
        let loadedFeedback = try await repositories.feedback.listEvents(goalID: nil)
        let loadedCaptures = try await repositories.captures.listCaptures()
        let loadedTeaching = try await repositories.teaching.listSignals(goalID: incomingGoal.id)
        let loadedState = try await repositories.appState.loadState()

        XCTAssertEqual(report.importedGoalCount, 1)
        XCTAssertTrue(report.conflicts.isEmpty)
        XCTAssertEqual(loadedGoals.map(\.id), [incomingGoal.id])
        XCTAssertEqual(loadedDrafts.map(\.id), [incomingDraft.id])
        XCTAssertEqual(loadedEvidence.map(\.id), [incomingEvidence.id])
        XCTAssertEqual(loadedFeedback.map(\.base.id), [incomingFeedback.base.id])
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

    func testNewPhoneDisasterDrillRestoresEncodedPackageIntoFreshStore() async throws {
        let sourceStore = try AmbitionsPersistenceStore(inMemory: true)
        let sourceRepositories = makeRepositories(store: sourceStore)
        let goal = try XCTUnwrap(sampleGoal(id: "goal-new-phone", revision: 2, updatedAt: "2026-04-18T10:00:00Z"))
        let evidence = sampleEvidence(id: "evidence-new-phone", goalID: goal.id, capturedAt: "2026-04-18T12:00:00Z")
        let feedback = sampleFeedback(stepID: "step-new-phone", occurredAt: "2026-04-18T13:00:00Z")
        let capture = sampleCapture(id: "capture-new-phone", updatedAt: "2026-04-18T14:00:00Z")
        let teaching = sampleTeachingSignal(goalID: goal.id, updatedAt: "2026-04-18T14:30:00Z")
        var state = AppStateSnapshot.default
        state.userDisplayName = "Restored New Phone"
        state.lastOpenedGoalID = goal.id

        try await sourceRepositories.goals.saveGoals([goal])
        try await sourceRepositories.evidence.saveEvidence([evidence])
        try await sourceRepositories.feedback.saveEvents([feedback], goalID: goal.id)
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
        let restoredCaptures = try await freshRepositories.captures.listCaptures()
        let restoredTeaching = try await freshRepositories.teaching.listSignals(goalID: goal.id)
        let restoredState = try await freshRepositories.appState.loadState()

        XCTAssertEqual(report.importedGoalCount, 1)
        XCTAssertEqual(report.importedEvidenceCount, 1)
        XCTAssertEqual(report.importedFeedbackCount, 1)
        XCTAssertEqual(report.importedCaptureCount, 1)
        XCTAssertEqual(report.importedTeachingSignalCount, 1)
        XCTAssertTrue(report.safetySummary.requiresExplicitConfirmation)
        XCTAssertEqual(restoredGoals.map(\.id), [goal.id])
        XCTAssertEqual(restoredEvidence.map(\.id), [evidence.id])
        XCTAssertEqual(restoredFeedback.map(\.base.id), [feedback.base.id])
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

    func testPortableSnapshotDecodesMissingTeachingSignalsAsEmpty() throws {
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
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func sampleTeachingSignal(goalID: String, updatedAt: String) -> GoalTeachingSignal {
        GoalTeachingSignal(
            id: "teaching-\(goalID)-\(updatedAt)",
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
