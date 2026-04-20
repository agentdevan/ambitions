import SwiftData
import XCTest
@testable import Ambitions

final class PersistenceRepositoryTests: XCTestCase {
    func testGoalRepositoryRoundTripsGoalPlanAndSteps() async throws {
        let repositories = try await makeRepositories()
        let fixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "clear-timed-self-goal"))
        let goal = try XCTUnwrap(goalFromFixture(fixture))

        try await repositories.goals.saveGoals([goal])
        let loaded = try await repositories.goals.goal(id: goal.id)
        let loadedSteps = try await repositories.goals.listSteps(goalID: goal.id)

        XCTAssertEqual(loaded?.title, goal.title)
        XCTAssertEqual(loaded?.plan?.sections.count, goal.plan?.sections.count)
        XCTAssertEqual(loadedSteps.count, goal.plan?.sections.flatMap(\.steps).count)
    }

    func testGoalRepositoryRoundTripsLifeGraphFromSnapshotStorage() async throws {
        let repositories = try await makeRepositories()
        let fixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "clear-timed-self-goal"))
        var goal = try XCTUnwrap(goalFromFixture(fixture))
        goal = Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision,
            createdAt: goal.createdAt,
            updatedAt: goal.updatedAt,
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: goal.relationshipKind,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: goal.plan,
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .career)],
                roles: [LifeRole(kind: .primary, title: "Founder")],
                path: LifePathDescriptor(kind: .careerTrack, title: "Company path"),
                stages: [LifePathStage(id: "foundation", title: "Foundation", orderIndex: 0)],
                prerequisites: [LifePathPrerequisite(id: "launch-needs-foundation", title: "Launch depends on foundation", kind: .stage, stageID: "launch", requiredStageID: "foundation")],
                milestones: [LifeGraphMilestone(id: "m1", title: "Launch v1", summary: nil, targetDate: "2026-12-01", stageID: "foundation", dependencyIDs: [])]
            )
        )

        try await repositories.goals.saveGoals([goal])
        let loaded = try await repositories.goals.goal(id: goal.id)

        XCTAssertEqual(loaded?.lifeGraph?.domains.map(\.domain), [.career])
        XCTAssertEqual(loaded?.lifeGraph?.roles.map(\.title), ["Founder"])
        XCTAssertEqual(loaded?.lifeGraph?.path?.title, "Company path")
        XCTAssertEqual(loaded?.lifeGraph?.stages.map(\.id), ["foundation"])
        XCTAssertEqual(loaded?.lifeGraph?.prerequisites.map(\.id), ["launch-needs-foundation"])
        XCTAssertEqual(loaded?.lifeGraph?.milestones.map(\.id), ["m1"])
    }

    func testGoalRepositoryRoundTripsAdditiveSharedLifeMetadataFromSnapshotStorage() async throws {
        let repositories = try await makeRepositories()
        let fixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "clear-timed-self-goal"))
        var goal = try XCTUnwrap(goalFromFixture(fixture))
        goal = Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision,
            createdAt: goal.createdAt,
            updatedAt: goal.updatedAt,
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: .support,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: goal.plan,
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

        try await repositories.goals.saveGoals([goal])
        let loaded = try await repositories.goals.goal(id: goal.id)

        XCTAssertEqual(loaded?.lifeGraph?.sharedLife?.participants.map(\.displayName), ["Alex"])
        XCTAssertEqual(loaded?.lifeGraph?.sharedLife?.responsibilities.map(\.title), ["Groceries"])
    }

    func testDraftRepositoryPreservesStarterAndBlockedState() async throws {
        let repositories = try await makeRepositories()
        let starterFixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "exploratory-vague-goal"))
        let blockedFixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "blocked-requiring-clarification"))

        let storedDrafts = [storedDraft(id: "starter", fixture: starterFixture), storedDraft(id: "blocked", fixture: blockedFixture)].compactMap { $0 }
        try await repositories.drafts.saveDrafts(storedDrafts)

        let loaded = try await repositories.drafts.listDrafts()
        XCTAssertEqual(loaded.count, storedDrafts.count)
        XCTAssertTrue(loaded.contains(where: { $0.latestResultKind == .starterPlanned && !$0.assumptions.isEmpty }))
        XCTAssertTrue(loaded.contains(where: { $0.latestResultKind == .clarificationRequired && $0.clarification != nil }))
        XCTAssertTrue(loaded.allSatisfy { $0.metadata?.understanding != nil })
    }

    func testDraftRepositoryRoundTripsUnderstandingInsideEncodedMetadata() async throws {
        let repositories = try await makeRepositories()
        let fixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "exploratory-vague-goal"))
        guard let draft = storedDraft(id: "starter-understanding", fixture: fixture) else {
            return XCTFail("Expected stored draft fixture.")
        }

        try await repositories.drafts.saveDrafts([draft])
        let loaded = try await repositories.drafts.draft(id: "starter-understanding")

        XCTAssertEqual(loaded?.metadata?.understanding, draft.metadata?.understanding)
        XCTAssertEqual(loaded?.metadata?.understanding.primaryInterpretation.id, draft.metadata?.understanding.primaryInterpretation.id)
        XCTAssertEqual(loaded?.metadata?.compiledPath, draft.metadata?.compiledPath)
        XCTAssertEqual(loaded?.metadata?.resourceGraph, draft.metadata?.resourceGraph)
        XCTAssertEqual(loaded?.metadata?.resourceGraph.freshness, draft.metadata?.resourceGraph.freshness)
        XCTAssertEqual(loaded?.metadata?.energyModel, draft.metadata?.energyModel)
    }

    func testEvidenceAndFeedbackRepositoriesPersistAdaptiveHistory() async throws {
        let repositories = try await makeRepositories()
        let feedbackFixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "achievement-avoidance"))
        let goalID = feedbackFixture.input.currentResult.plan.goalID
        let evidence = ProgressEvidence(
            id: "evidence-1",
            goalID: goalID,
            stepID: feedbackFixture.input.selectedStep.id,
            evidenceKind: .sessionLogged,
            source: .manual,
            capturedAt: GoalEngineFixtures.fixedNow,
            progressDelta: 0.15,
            confidenceDelta: -0.05,
            minutesInvested: 20,
            note: "Repository round-trip"
        )

        try await repositories.evidence.saveEvidence([evidence])
        try await repositories.feedback.saveEvents(feedbackFixture.input.feedbackHistory, goalID: goalID)
        let loadedEvidence = try await repositories.evidence.listEvidence(goalID: goalID)
        let loadedFeedback = try await repositories.feedback.listEvents(goalID: goalID)

        XCTAssertEqual(loadedEvidence.first?.id, evidence.id)
        XCTAssertEqual(loadedFeedback.count, feedbackFixture.input.feedbackHistory.count)
    }

    func testAppStateRepositoryPersistsPreferencesAndBootstrapFields() async throws {
        let repositories = try await makeRepositories()
        var state = try await repositories.appState.loadState()
        state.preferredTab = .goals
        state.userDisplayName = "Storage Test"
        state.appearancePreference = .dark
        state.hasCompletedBootstrap = true
        state.lastBootstrapSource = .live
        state.lastBootstrapAt = GoalEngineFixtures.fixedNow

        try await repositories.appState.saveState(state)
        let loaded = try await repositories.appState.loadState()

        XCTAssertEqual(loaded.preferredTab, .goals)
        XCTAssertEqual(loaded.userDisplayName, "Storage Test")
        XCTAssertEqual(loaded.appearancePreference, .dark)
        XCTAssertEqual(loaded.lastBootstrapSource, .live)
    }

    func testCaptureRepositoryPersistsAndSortsByUpdatedAt() async throws {
        let repositories = try await makeRepositories()
        let first = Capture(
            id: "capture-first",
            createdAt: "2026-04-15T10:00:00Z",
            updatedAt: "2026-04-15T10:00:00Z",
            rawText: "First capture",
            sourceType: .todayQuickCapture,
            status: .goalBound,
            linkedGoalID: "goal-1",
            triage: CaptureTriageMetadata(destination: .attachToGoal, hint: "Keep near the goal.")
        )
        let second = Capture(
            id: "capture-second",
            createdAt: "2026-04-15T11:00:00Z",
            updatedAt: "2026-04-15T11:00:00Z",
            rawText: "Second capture",
            sourceType: nil,
            status: .seed,
            linkedGoalID: nil,
            triage: CaptureTriageMetadata(destination: .saveAsSeed),
            revisitAfter: "2026-04-22T09:00:00Z"
        )

        try await repositories.captures.saveCaptures([first, second])
        let loaded = try await repositories.captures.listCaptures()

        XCTAssertEqual(loaded.map(\.id), ["capture-second", "capture-first"])
        XCTAssertEqual(loaded.first?.status, .seed)
        XCTAssertEqual(loaded.first?.triage?.destination, .saveAsSeed)
        XCTAssertEqual(loaded.first?.revisitAfter, "2026-04-22T09:00:00Z")
        XCTAssertEqual(loaded.last?.sourceType, .todayQuickCapture)
        XCTAssertEqual(loaded.last?.status, .goalBound)
        XCTAssertEqual(loaded.last?.triage?.hint, "Keep near the goal.")
    }

    func testCaptureRepositoryRoundTripsAllStableSourceTypes() async throws {
        let repositories = try await makeRepositories()
        let captures = [
            Capture(id: "capture-notification", createdAt: "2026-04-15T09:55:00Z", updatedAt: "2026-04-15T09:55:00Z", rawText: "Notification capture", sourceType: .notification, status: .actionable, linkedGoalID: nil),
            Capture(id: "capture-text", createdAt: "2026-04-15T10:00:00Z", updatedAt: "2026-04-15T10:00:00Z", rawText: "Shared text", sourceType: .shareExtensionText, status: .actionable, linkedGoalID: nil),
            Capture(id: "capture-url", createdAt: "2026-04-15T10:05:00Z", updatedAt: "2026-04-15T10:05:00Z", rawText: "https://example.com", sourceType: .shareExtensionURL, status: .actionable, linkedGoalID: nil),
            Capture(id: "capture-intent", createdAt: "2026-04-15T10:10:00Z", updatedAt: "2026-04-15T10:10:00Z", rawText: "Intent capture", sourceType: .appIntent, status: .actionable, linkedGoalID: nil)
        ]

        try await repositories.captures.saveCaptures(captures)
        let loadedCaptures = try await repositories.captures.listCaptures()
        let loadedByID = Dictionary(uniqueKeysWithValues: loadedCaptures.map { ($0.id, $0) })

        XCTAssertEqual(loadedByID["capture-notification"]?.sourceType, .notification)
        XCTAssertEqual(loadedByID["capture-text"]?.sourceType, .shareExtensionText)
        XCTAssertEqual(loadedByID["capture-url"]?.sourceType, .shareExtensionURL)
        XCTAssertEqual(loadedByID["capture-intent"]?.sourceType, .appIntent)
    }

    func testCaptureRepositoryRoundTripsCanonicalStates() async throws {
        let repositories = try await makeRepositories()
        let captures = CaptureStatus.allCasesForTests.enumerated().map { index, status in
            Capture(
                id: "capture-\(status.rawValue)",
                createdAt: "2026-04-15T10:0\(index):00Z",
                updatedAt: "2026-04-15T10:0\(index):00Z",
                rawText: "Capture \(status.rawValue)",
                sourceType: .todayQuickCapture,
                status: status,
                linkedGoalID: status == .goalBound ? "goal-bound" : nil
            )
        }

        try await repositories.captures.saveCaptures(captures)
        let loadedStatuses = Set(try await repositories.captures.listCaptures().map(\.status))

        XCTAssertEqual(loadedStatuses, Set(CaptureStatus.allCasesForTests))
    }

    func testCaptureRepositoryMapsLegacyStatusRawValuesInOnePersistenceFallback() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)

        try await store.write { context in
            context.insert(
                CaptureRecord(
                    id: "legacy-pending",
                    createdAt: "2026-04-15T10:00:00Z",
                    updatedAt: "2026-04-15T10:00:00Z",
                    rawText: "Legacy pending",
                    sourceTypeRaw: CaptureSourceType.todayQuickCapture.rawValue,
                    statusRaw: "pending",
                    linkedGoalID: nil,
                    snapshotData: Data("{}".utf8)
                )
            )
            context.insert(
                CaptureRecord(
                    id: "legacy-processed",
                    createdAt: "2026-04-15T11:00:00Z",
                    updatedAt: "2026-04-15T11:00:00Z",
                    rawText: "Legacy processed",
                    sourceTypeRaw: nil,
                    statusRaw: "processed",
                    linkedGoalID: "goal-legacy",
                    snapshotData: Data("{}".utf8)
                )
            )
        }

        let loadedByID = Dictionary(uniqueKeysWithValues: try await repositories.captures.listCaptures().map { ($0.id, $0) })

        XCTAssertEqual(loadedByID["legacy-pending"]?.status, .actionable)
        XCTAssertEqual(loadedByID["legacy-processed"]?.status, .goalBound)
        XCTAssertEqual(loadedByID["legacy-processed"]?.linkedGoalID, "goal-legacy")
    }
}

private extension PersistenceRepositoryTests {
    func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return makeRepositories(store: store)
    }

    func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func goalFromFixture(_ fixture: GoalEngineFixture) -> Goal? {
        switch fixture.result {
        case let .planned(result):
            return Goal(schemaVersion: goalEngineSchemaVersion, id: result.plan.goalID, revision: 1, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, state: .active, title: result.draft.title, summary: result.draft.summary, mode: result.draft.mode, relationshipKind: result.draft.relationshipKind, actor: result.draft.actor, parentGoalID: result.draft.parentGoalID, childGoalIDs: [], supportGoalIDs: [], tags: result.draft.tags, timing: result.draft.timing, planningStrategy: result.draft.planningStrategy, progressStrategy: result.draft.progressStrategy, plan: result.plan)
        case let .starterPlanned(result):
            return Goal(schemaVersion: goalEngineSchemaVersion, id: result.plan.goalID, revision: 1, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, state: .active, title: result.draft.title, summary: result.draft.summary, mode: result.draft.mode, relationshipKind: result.draft.relationshipKind, actor: result.draft.actor, parentGoalID: result.draft.parentGoalID, childGoalIDs: [], supportGoalIDs: [], tags: result.draft.tags, timing: result.draft.timing, planningStrategy: result.draft.planningStrategy, progressStrategy: result.draft.progressStrategy, plan: result.plan)
        case .clarificationRequired, .blocked:
            return nil
        }
    }

    func storedDraft(id: String, fixture: GoalEngineFixture) -> PersistedGoalDraft? {
        switch fixture.result {
        case let .starterPlanned(result):
            return PersistedGoalDraft(id: id, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, draft: result.draft, classification: nil, clarification: result.clarification, stagedPlan: result.plan, assumptions: result.assumptions, blockers: [], metadata: result.metadata, plannedGoalID: result.plan.goalID, latestResultKind: .starterPlanned)
        case let .clarificationRequired(result):
            return PersistedGoalDraft(id: id, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, draft: result.draft, classification: nil, clarification: result.clarification, stagedPlan: nil, assumptions: result.metadata.reasoning.assumptions, blockers: [], metadata: result.metadata, plannedGoalID: nil, latestResultKind: .clarificationRequired)
        default:
            return nil
        }
    }
}

private extension CaptureStatus {
    static let allCasesForTests: [CaptureStatus] = [.seed, .actionable, .goalBound, .scheduled, .delegated, .archived]
}
