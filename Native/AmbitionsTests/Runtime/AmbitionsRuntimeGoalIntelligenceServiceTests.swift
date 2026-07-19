import XCTest
@testable import Ambitions

final class AmbitionsRuntimeGoalIntelligenceServiceTests: XCTestCase {
    func testLoadContextMatchesDirectProjectionAndApplicableSignals() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let draftID = try XCTUnwrap(created.target.draftID)
        let storedGoal = try await repositories.goals.goal(id: goalID)
        let storedDraft = try await repositories.drafts.draft(id: draftID)
        let goal = try XCTUnwrap(storedGoal)
        let draft = try XCTUnwrap(storedDraft)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)

        let directTeaching = DefaultGoalTeachingSignalService(repository: repositories.teaching)
        let directWhyNow = LearningAnticipationService().learnedStepInsight(
            goal: goal,
            step: step,
            snapshot: LearningAnticipationService().buildSnapshot(
                goals: [goal],
                evidence: [],
                feedback: [],
                now: fixedNow
            ),
            now: fixedNow
        ).whyNow
        let directSignals = try await directTeaching.applicableSignals(
            goalID: goalID,
            metadata: try XCTUnwrap(draft.metadata)
        )
        let directExplainability = DefaultGoalExplainabilityProjector().makeState(
            metadata: try XCTUnwrap(draft.metadata),
            applicableSignals: directSignals,
            primaryStepID: step.id,
            whyNow: directWhyNow
        )

        let runtimeService = RepositoryBackedRuntimeGoalIntelligenceService(repositories: repositories)
        let runtimeContext = try await runtimeService.loadContext(
            RuntimeGoalIntelligenceRequest(
                target: created.target,
                primaryStepID: step.id,
                includeWhyNow: true
            ),
            now: fixedNow
        )

        XCTAssertEqual(runtimeContext?.goalID, goalID)
        XCTAssertEqual(runtimeContext?.draftID, draftID)
        XCTAssertEqual(runtimeContext?.whyNow, directWhyNow)
        XCTAssertEqual(runtimeContext?.applicableSignals, directSignals)
        XCTAssertEqual(runtimeContext?.quarantine, .clear)
        assertExplainabilityParity(runtimeContext?.explainability, directExplainability)
    }

    func testCaptureCorrectionMatchesCanonicalTeachingSignalShape() async throws {
        let runtimeRepositories = try await makeRepositories()
        let directRepositories = try await makeRepositories()
        let runtimeSetup = try await createGoalContext(repositories: runtimeRepositories, title: "Launch my business")
        let directSetup = try await createGoalContext(repositories: directRepositories, title: "Launch my business")
        let runtimeContext = try XCTUnwrap(runtimeSetup.context)
        let directContext = try XCTUnwrap(directSetup.context)
        let control = try XCTUnwrap(
            runtimeContext.explainability.correctionControls.first(where: { $0.artifactKind == .resourceHook })
        )

        let runtimeService = RepositoryBackedRuntimeGoalIntelligenceService(repositories: runtimeRepositories)
        let runtimeSignal = try await runtimeService.captureCorrection(
            target: runtimeSetup.target,
            control: control,
            now: fixedNow
        )
        let directSignal = try await DefaultGoalTeachingSignalService(repository: directRepositories.teaching).capture(
            GoalTeachingCaptureRequest(
                goalID: try XCTUnwrap(directContext.goalID),
                capturedAt: DomainTimestamp.string(from: fixedNow),
                kind: control.teachingSignalKind,
                payload: control.payload,
                target: control.target,
                userNote: control.subtitle
            ),
            metadata: directContext.metadata
        )

        XCTAssertEqual(runtimeSignal.kind, directSignal.kind)
        XCTAssertEqual(runtimeSignal.anchor, directSignal.anchor)
        XCTAssertEqual(runtimeSignal.payload, directSignal.payload)
        XCTAssertEqual(
            normalizedApplicationKey(runtimeSignal.applicationKey),
            normalizedApplicationKey(directSignal.applicationKey)
        )
    }

    func testBatchLoadContextMatchesSingleTargetProjectionAndOrdering() async throws {
        let repositories = try await makeRepositories()
        let first = try await createGoalContext(
            repositories: repositories,
            title: "Submit my conference talk proposal by 2026-05-15"
        )
        let second = try await createGoalContext(
            repositories: repositories,
            title: "Launch my business by 2026-08-01"
        )
        let requests = [
            RuntimeGoalIntelligenceRequest(
                target: first.target,
                primaryStepID: first.context?.primaryStepID,
                includeWhyNow: true
            ),
            RuntimeGoalIntelligenceRequest(
                target: GoalRouteTarget(goalID: "missing-goal"),
                primaryStepID: nil,
                includeWhyNow: true
            ),
            RuntimeGoalIntelligenceRequest(
                target: second.target,
                primaryStepID: second.context?.primaryStepID,
                includeWhyNow: true
            )
        ]
        let service = RepositoryBackedRuntimeGoalIntelligenceService(repositories: repositories)

        let batch = try await service.loadContexts(requests, now: fixedNow)

        XCTAssertEqual(batch.count, requests.count)
        let firstSingle = try await service.loadContext(requests[0], now: fixedNow)
        let secondSingle = try await service.loadContext(requests[2], now: fixedNow)
        assertRuntimeContextParity(batch[0], firstSingle)
        XCTAssertNil(batch[1])
        assertRuntimeContextParity(batch[2], secondSingle)
    }

    func testRuntimeIntelligenceQuarantineMarksUnsafeContextForReview() async throws {
        let setup = try await createGoalContext(
            repositories: try await makeRepositories(),
            title: "Submit my conference talk proposal by 2026-05-15"
        )
        let base = try XCTUnwrap(setup.context?.explainability)
        let unsafe = GoalExplainabilityState(
            whisper: base.whisper,
            whyThis: base.whyThis,
            sourceAudit: GoalSourceAuditSectionState(rows: []),
            freshness: GoalFreshnessState(
                posture: .stale,
                postureLabel: "Needs review",
                severityLabel: "Stale",
                detailLabels: ["Source needs review"]
            ),
            confidence: GoalConfidenceState(
                understandingConfidence: .low,
                pathConfidence: .low,
                detailLabels: ["Unclear source support"]
            ),
            contradictions: [
                GoalContradictionSummaryState(
                    id: "contradiction-source",
                    code: .requiredKnowledgeClaimConflict,
                    title: "Source conflict",
                    summary: "Required knowledge is not settled.",
                    severityLabel: "Review",
                    state: .warning
                )
            ],
            correctionControls: [],
            appliedTeachingBadges: base.appliedTeachingBadges
        )

        let assessment = RuntimeIntelligenceQuarantinePolicy().assess(explainability: unsafe)

        XCTAssertTrue(assessment.isQuarantined)
        XCTAssertFalse(assessment.canDriveRecommendation)
        XCTAssertEqual(
            assessment.issues,
            [
                .missingSourceAudit,
                .staleOrUnavailableFreshness,
                .lowConfidence,
                .unresolvedContradiction,
                .missingCorrectionControl
            ]
        )
    }
}

private extension AmbitionsRuntimeGoalIntelligenceServiceTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
    }

    func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func createGoalContext(
        repositories: AppRepositories,
        title: String
    ) async throws -> (target: GoalRouteTarget, context: RuntimeGoalIntelligenceContext?) {
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: title),
            now: fixedNow
        )
        let primaryStepID: String?
        if let goalID = created.target.goalID,
           let goal = try await repositories.goals.goal(id: goalID) {
            primaryStepID = goal.plan?.sections.first?.steps.first?.id
        } else {
            primaryStepID = nil
        }
        let context = try await RepositoryBackedRuntimeGoalIntelligenceService(repositories: repositories).loadContext(
            RuntimeGoalIntelligenceRequest(
                target: created.target,
                primaryStepID: primaryStepID,
                includeWhyNow: true
            ),
            now: fixedNow
        )
        return (created.target, context)
    }

    func assertExplainabilityParity(
        _ lhs: GoalExplainabilityState?,
        _ rhs: GoalExplainabilityState?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(lhs?.whyThis.compactSummary, rhs?.whyThis.compactSummary, file: file, line: line)
        XCTAssertEqual(lhs?.whyThis.lines, rhs?.whyThis.lines, file: file, line: line)
        XCTAssertEqual(
            lhs?.sourceAudit.rows.map(\.resourceID),
            rhs?.sourceAudit.rows.map(\.resourceID),
            file: file,
            line: line
        )
        XCTAssertEqual(
            lhs?.sourceAudit.rows.map(\.detailLabels),
            rhs?.sourceAudit.rows.map(\.detailLabels),
            file: file,
            line: line
        )
        XCTAssertEqual(lhs?.freshness.posture, rhs?.freshness.posture, file: file, line: line)
        XCTAssertEqual(lhs?.freshness.detailLabels, rhs?.freshness.detailLabels, file: file, line: line)
        XCTAssertEqual(
            lhs?.confidence.understandingConfidence,
            rhs?.confidence.understandingConfidence,
            file: file,
            line: line
        )
        XCTAssertEqual(lhs?.confidence.pathConfidence, rhs?.confidence.pathConfidence, file: file, line: line)
        XCTAssertEqual(lhs?.confidence.detailLabels, rhs?.confidence.detailLabels, file: file, line: line)
        XCTAssertEqual(
            lhs?.contradictions.map(\.code),
            rhs?.contradictions.map(\.code),
            file: file,
            line: line
        )
        XCTAssertEqual(
            lhs?.correctionControls.map(\.id),
            rhs?.correctionControls.map(\.id),
            file: file,
            line: line
        )
        XCTAssertEqual(
            lhs?.correctionControls.map(\.artifactKind),
            rhs?.correctionControls.map(\.artifactKind),
            file: file,
            line: line
        )
        XCTAssertEqual(
            lhs?.appliedTeachingBadges.map(\.signalID),
            rhs?.appliedTeachingBadges.map(\.signalID),
            file: file,
            line: line
        )
    }

    func normalizedApplicationKey(_ value: String) -> String {
        let components = value.components(separatedBy: "##")
        guard components.count > 1 else { return value }
        return components.dropFirst().joined(separator: "##")
    }

    func assertRuntimeContextParity(
        _ lhs: RuntimeGoalIntelligenceContext?,
        _ rhs: RuntimeGoalIntelligenceContext?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(lhs?.goalID, rhs?.goalID, file: file, line: line)
        XCTAssertEqual(lhs?.draftID, rhs?.draftID, file: file, line: line)
        XCTAssertEqual(lhs?.primaryStepID, rhs?.primaryStepID, file: file, line: line)
        XCTAssertEqual(lhs?.whyNow, rhs?.whyNow, file: file, line: line)
        XCTAssertEqual(lhs?.applicableSignals, rhs?.applicableSignals, file: file, line: line)
        XCTAssertEqual(lhs?.quarantine, rhs?.quarantine, file: file, line: line)
        assertExplainabilityParity(lhs?.explainability, rhs?.explainability, file: file, line: line)
    }
}
