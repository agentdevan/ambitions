import XCTest
@testable import Ambitions

final class MemoryLensServiceTests: XCTestCase {
    func testSearchReturnsGoalAndCaptureMatchesFromShippedRepositories() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        try await repositories.goals.saveGoals([goal])
        try await repositories.captures.saveCaptures([
            Capture(
                id: "capture-1",
                createdAt: "2026-04-20T10:00:00Z",
                updatedAt: "2026-04-20T10:00:00Z",
                rawText: "Review conference proposal notes",
                sourceType: nil,
                status: .actionable,
                linkedGoalID: nil
            )
        ])
        let service = DefaultMemoryLensService(repositories: repositories)

        let results = await service.search(query: goal.title, seedIntent: .openGoal)

        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.first?.kind, .goal)
        XCTAssertTrue(results.contains(where: { $0.kind == .goal && $0.title == goal.title }))
    }

    func testSearchPrioritizesWeekForOpenWeekIntent() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let service = DefaultMemoryLensService(repositories: repositories)

        let results = await service.search(query: "", seedIntent: .openWeek)

        XCTAssertEqual(results.first?.kind, .week)
        XCTAssertEqual(results.first?.destination, .tab(.time))
    }

    func testSearchSurfacesWhyNowLearningCorrectionAndHandoffRecall() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        let step = try XCTUnwrap(goal.plan?.sections.flatMap(\.steps).first)
        try await repositories.goals.saveGoals([goal])
        try await repositories.feedback.saveEvents([
            .askedForSmallerVersion(
                base: GoalFeedbackEventBase(
                    id: "feedback-small",
                    stepID: step.id,
                    occurredAt: "2026-04-22T10:00:00Z",
                    note: "Make this smaller next time."
                )
            )
        ], goalID: goal.id)
        try await repositories.teaching.saveSignals([
            GoalTeachingSignal(
                id: "teaching-energy",
                goalID: goal.id,
                createdAt: "2026-04-22T11:00:00Z",
                updatedAt: "2026-04-22T11:00:00Z",
                source: .explicitManualCorrection,
                kind: .energyFitCorrection,
                disposition: .active,
                anchor: GoalTeachingStableAnchor(
                    artifactKind: .energyEvaluation,
                    canonicalField: nil,
                    candidateID: nil,
                    stageID: nil,
                    stepID: step.id,
                    targetFingerprint: "energy::\(step.id)",
                    contradictionCode: nil,
                    contradictionArtifactRefs: []
                ),
                payload: .energyFit(.init(correctedDisposition: .lighterVersionNeeded)),
                applicationKey: "goal##energy##step",
                userNote: "Use a lighter version"
            )
        ])
        let service = DefaultMemoryLensService(repositories: repositories)

        let whyNow = await service.search(query: "why now", seedIntent: .memoryLens)
        let learning = await service.search(query: "recent learning", seedIntent: .memoryLens)
        let correction = await service.search(query: "recent correction", seedIntent: .memoryLens)
        let handoff = await service.search(query: "handoff", seedIntent: .memoryLens)

        XCTAssertTrue(whyNow.contains(where: { $0.kind == .whyNow && $0.facet == .whyNow && $0.destination == .goal(goal.id) }))
        XCTAssertTrue(learning.contains(where: { $0.kind == .learning && $0.facet == .recentLearning }))
        XCTAssertTrue(correction.contains(where: { $0.kind == .teaching && $0.facet == .recentCorrection }))
        XCTAssertTrue(handoff.contains(where: { $0.kind == .handoff && $0.facet == .handoff }))
    }

    func testSearchResultsCarrySourceConfidenceAndTrustDecayEvidence() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        let step = try XCTUnwrap(goal.plan?.sections.flatMap(\.steps).first)
        try await repositories.goals.saveGoals([goal])
        try await repositories.captures.saveCaptures([
            Capture(
                id: "capture-source",
                createdAt: "2026-04-20T10:00:00Z",
                updatedAt: "2026-04-20T10:00:00Z",
                rawText: "File the reimbursement receipt",
                sourceType: nil,
                status: .actionable,
                linkedGoalID: nil
            )
        ])
        try await repositories.feedback.saveEvents([
            .askedWhyThisMatters(
                base: GoalFeedbackEventBase(
                    id: "feedback-why",
                    stepID: step.id,
                    occurredAt: "2026-04-22T10:00:00Z",
                    note: "Why does this matter now?"
                )
            )
        ], goalID: goal.id)
        let service = DefaultMemoryLensService(repositories: repositories)

        let results = await service.search(query: "", seedIntent: .memoryLens)

        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { !$0.allowsMemoryClaim })
        XCTAssertTrue(results.contains {
            $0.kind == .goal &&
                $0.sourceEvidence == .currentPlan &&
                $0.confidenceBand == .direct &&
                $0.trustDecayState == .current
        })
        XCTAssertTrue(results.contains {
            $0.kind == .capture &&
                $0.sourceEvidence == .capturedThought &&
                $0.confidenceBand == .direct &&
                $0.trustDecayState == .current
        })
        XCTAssertTrue(results.contains {
            $0.kind == .whyNow &&
                $0.sourceEvidence == .currentPlan &&
                $0.confidenceBand == .inferred &&
                $0.trustDecayState == .current
        })
        XCTAssertTrue(results.contains {
            $0.kind == .learning &&
                $0.sourceEvidence == .currentPlan &&
                $0.confidenceBand == .inferred &&
                $0.trustDecayState == .aging
        })
    }

    func testSearchResultsClassifyLifeEventsDecisionsAndContextRecallMemory() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        let step = try XCTUnwrap(goal.plan?.sections.flatMap(\.steps).first)
        try await repositories.goals.saveGoals([goal])
        try await repositories.feedback.saveEvents([
            .delayed(
                base: GoalFeedbackEventBase(
                    id: "feedback-delay",
                    stepID: step.id,
                    occurredAt: "2026-04-22T10:00:00Z",
                    note: "Moved this to protect the week."
                ),
                timingAdjustment: .laterToday,
                date: nil
            )
        ], goalID: goal.id)
        try await repositories.teaching.saveSignals([
            GoalTeachingSignal(
                id: "teaching-context",
                goalID: goal.id,
                createdAt: "2026-04-22T11:00:00Z",
                updatedAt: "2026-04-22T11:00:00Z",
                source: .explicitManualCorrection,
                kind: .classificationCorrection,
                disposition: .active,
                anchor: GoalTeachingStableAnchor(
                    artifactKind: .classificationField,
                    canonicalField: .mode,
                    candidateID: nil,
                    stageID: nil,
                    stepID: step.id,
                    targetFingerprint: "classification::\(step.id)",
                    contradictionCode: nil,
                    contradictionArtifactRefs: []
                ),
                payload: .classification(.init(
                    field: .mode,
                    correctedValue: .mode(.learning)
                )),
                applicationKey: "goal##classification",
                userNote: "Treat this as ongoing context"
            )
        ])
        let service = DefaultMemoryLensService(repositories: repositories)

        let results = await service.search(query: "", seedIntent: .memoryLens)

        XCTAssertTrue(results.contains {
            $0.kind == .week &&
                $0.contextRecallClass == .lifeEvent &&
                !$0.requiresUserReviewBeforeDurableMemory
        })
        XCTAssertTrue(results.contains {
            $0.kind == .recentChange &&
                $0.contextRecallClass == .decision &&
                $0.requiresUserReviewBeforeDurableMemory
        })
        XCTAssertTrue(results.contains {
            $0.kind == .goal &&
                $0.contextRecallClass == .contextRecall &&
                !$0.requiresUserReviewBeforeDurableMemory
        })
        XCTAssertTrue(results.contains {
            $0.kind == .teaching &&
                $0.contextRecallClass == .correctionMemory &&
                $0.requiresUserReviewBeforeDurableMemory
        })
    }

    func testEB33SearchCanRecallBySourceGroundedRetrievalMetadata() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        let step = try XCTUnwrap(goal.plan?.sections.flatMap(\.steps).first)
        try await repositories.goals.saveGoals([goal])
        try await repositories.captures.saveCaptures([
            Capture(
                id: "capture-context",
                createdAt: "2026-04-20T10:00:00Z",
                updatedAt: "2026-04-20T10:00:00Z",
                rawText: "Renew the passport before the trip",
                sourceType: nil,
                status: .actionable,
                linkedGoalID: nil
            )
        ])
        try await repositories.teaching.saveSignals([
            GoalTeachingSignal(
                id: "teaching-recall",
                goalID: goal.id,
                createdAt: "2026-04-22T11:00:00Z",
                updatedAt: "2026-04-22T11:00:00Z",
                source: .explicitManualCorrection,
                kind: .energyFitCorrection,
                disposition: .active,
                anchor: GoalTeachingStableAnchor(
                    artifactKind: .energyEvaluation,
                    canonicalField: nil,
                    candidateID: nil,
                    stageID: nil,
                    stepID: step.id,
                    targetFingerprint: "energy::\(step.id)",
                    contradictionCode: nil,
                    contradictionArtifactRefs: []
                ),
                payload: .energyFit(.init(correctedDisposition: .lighterVersionNeeded)),
                applicationKey: "goal##energy##step",
                userNote: "Keep this lighter"
            )
        ])
        let service = DefaultMemoryLensService(repositories: repositories)

        let capturedContext = await service.search(query: "Inbox context", seedIntent: .memoryLens)
        let correctionTrail = await service.search(query: "Correction trail", seedIntent: .memoryLens)
        let safeRecall = await service.search(query: "safe context recall", seedIntent: .memoryLens)

        XCTAssertTrue(capturedContext.contains(where: {
            $0.kind == .capture &&
                $0.retrievalScope == .inboxContext &&
                $0.contextRetrievalSummary.contains("Captured thought")
        }))
        XCTAssertTrue(correctionTrail.contains(where: {
            $0.kind == .teaching &&
                $0.retrievalScope == .correctionTrail &&
                $0.requiresUserReviewBeforeDurableMemory
        }))
        XCTAssertTrue(safeRecall.contains(where: {
            $0.kind == .goal &&
                $0.contextRecallClass == .contextRecall &&
                !$0.requiresUserReviewBeforeDurableMemory
        }))
        XCTAssertTrue(correctionTrail.allSatisfy { !$0.allowsMemoryClaim })
    }

    func testAMB1059SearchResultsExposeTrustedHandoffOwnersWithoutStaleIADestinations() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        try await repositories.goals.saveGoals([goal])
        try await repositories.captures.saveCaptures([
            Capture(
                id: "capture-unplaced",
                createdAt: "2026-04-20T10:00:00Z",
                updatedAt: "2026-04-20T10:00:00Z",
                rawText: "Capture venue deposit reminder",
                sourceType: nil,
                status: .actionable,
                linkedGoalID: nil
            )
        ])
        let service = DefaultMemoryLensService(repositories: repositories)

        let results = await service.search(query: "", seedIntent: .memoryLens)

        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.staleIADestinationBlockers.isEmpty })
        XCTAssertTrue(results.allSatisfy { $0.trustedSearchHandoff(source: .shellUtility).isTrusted })
        XCTAssertTrue(results.contains { $0.kind == .goal && $0.trustedSearchHandoffOwner == .goals })
        XCTAssertTrue(results.contains { $0.kind == .week && $0.trustedSearchHandoffOwner == .time })
        XCTAssertTrue(results.contains { $0.kind == .capture && $0.trustedSearchHandoffOwner == .globalCapture })
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("capture"))
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("pulse"))
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("plan"))
    }
}

private extension MemoryLensServiceTests {
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

    func goalFromFixture(id: String) -> Goal? {
        guard let fixture = GoalEngineFixtures.fixture(id: id) else {
            return nil
        }

        switch fixture.result {
        case let .planned(result):
            return Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: result.plan.goalID,
                revision: 1,
                createdAt: GoalEngineFixtures.fixedNow,
                updatedAt: GoalEngineFixtures.fixedNow,
                state: .active,
                title: result.draft.title,
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
                id: result.plan.goalID,
                revision: 1,
                createdAt: GoalEngineFixtures.fixedNow,
                updatedAt: GoalEngineFixtures.fixedNow,
                state: .active,
                title: result.draft.title,
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
}
