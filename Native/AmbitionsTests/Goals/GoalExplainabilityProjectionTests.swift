import XCTest
@testable import Ambitions

final class GoalExplainabilityProjectionTests: XCTestCase {
    func testProjectorReflectsCanonicalOrderingAndStatesWithoutReinterpretation() throws {
        let metadata = try metadata(
            input: "Submit my conference talk proposal by 2026-05-15",
            goalID: "goal-explainability"
        )

        let state = DefaultGoalExplainabilityProjector().makeState(
            metadata: metadata,
            applicableSignals: nil,
            primaryStepID: nil,
            whyNow: nil
        )

        let expectedResourceIDs = metadata.resourceGraph.resources
            .sorted(by: DefaultGoalExplainabilityProjector.resourceOrdering)
            .map(\.id)
        XCTAssertFalse(state.whisper.title.isEmpty)
        XCTAssertFalse(state.whisper.pills.isEmpty)
        XCTAssertEqual(state.sourceAudit.rows.map(\.resourceID), expectedResourceIDs)
        XCTAssertEqual(state.freshness.posture, metadata.resourceGraph.freshness.overallPosture)
        XCTAssertEqual(state.confidence.understandingConfidence, metadata.understanding.confidence.overall)
        XCTAssertEqual(state.confidence.pathConfidence, metadata.compiledPath.candidates.first?.confidence.overall)
        XCTAssertEqual(state.contradictions.map(\.code), metadata.contradictionReport.records.map(\.code))
    }

    func testProjectorShowsAppliedTeachingBadgesOnlyFromCanonicalApplicableSignals() async throws {
        let metadata = try metadata(
            input: "Launch my business",
            goalID: "goal-applied-teaching"
        )
        let repository = InMemoryGoalTeachingSignalRepository()
        let service = DefaultGoalTeachingSignalService(repository: repository)
        let resource = try XCTUnwrap(metadata.resourceGraph.resources.first)
        let hook = try XCTUnwrap(
            metadata.compiledPath.candidates
                .first(where: { $0.id == resource.candidateID })?
                .resourceHooks
                .first(where: { $0.id == resource.hookID })
        )

        _ = try await service.capture(
            GoalTeachingCaptureRequest(
                goalID: try XCTUnwrap(metadata.context.goalID),
                capturedAt: GoalEngineFixtures.fixedNow,
                kind: .requirementRelevanceCorrection,
                payload: .requirementRelevance(
                    GoalTeachingRequirementRelevanceCorrection(correctedDisposition: .notRelevant)
                ),
                target: GoalTeachingCaptureTarget(
                    artifactKind: .resourceHook,
                    candidateID: resource.candidateID,
                    stageID: resource.targetStageID,
                    requirementSummary: hook.summary
                ),
                userNote: "This support is not relevant."
            ),
            metadata: metadata
        )
        let applicable = try await service.applicableSignals(
            goalID: try XCTUnwrap(metadata.context.goalID),
            metadata: metadata
        )

        let state = DefaultGoalExplainabilityProjector().makeState(
            metadata: metadata,
            applicableSignals: applicable,
            primaryStepID: nil,
            whyNow: nil
        )

        XCTAssertEqual(state.appliedTeachingBadges.count, applicable.signals.count)
        XCTAssertEqual(state.appliedTeachingBadges.first?.signalID, applicable.signals.first?.id)
    }

    func testProjectorDoesNotExposeCorrectionControlForUnanchorableContradiction() throws {
        let metadata = try metadata(
            input: "I want to launch my business this summer, but I don't want deadlines",
            goalID: "goal-unanchorable"
        )
        let contradiction = GoalContradictionRecord(
            id: "contradiction-unanchored",
            code: .inputTimingConflict,
            category: .goalInput,
            severity: .blocking,
            confidence: .medium,
            summary: "The contradiction exists but is not safely anchored.",
            candidateID: nil,
            stageID: nil,
            artifactRefs: []
        )
        let rewritten = GoalOrchestrationMetadata(
            input: metadata.input,
            context: metadata.context,
            inference: metadata.inference,
            clarification: metadata.clarification,
            planner: metadata.planner,
            reasoning: metadata.reasoning,
            understanding: metadata.understanding,
            compiledPath: metadata.compiledPath,
            resourceGraph: metadata.resourceGraph,
            energyModel: metadata.energyModel,
            contradictionReport: GoalContradictionReport(
                schemaVersion: metadata.contradictionReport.schemaVersion,
                records: [contradiction]
            )
        )

        let state = DefaultGoalExplainabilityProjector().makeState(
            metadata: rewritten,
            applicableSignals: nil,
            primaryStepID: nil,
            whyNow: nil
        )

        XCTAssertTrue(state.correctionControls.allSatisfy { $0.artifactKind != .contradictionShape })
    }
}

private extension GoalExplainabilityProjectionTests {
    func metadata(input: String, goalID: String) throws -> GoalOrchestrationMetadata {
        let result = GoalEngineOrchestrator().compileGoal(
            input,
            context: GoalEngineOrchestrationContext(
                goalID: goalID,
                referenceNow: GoalEngineFixtures.fixedNow
            )
        )

        switch result {
        case let .planned(planned):
            return planned.metadata
        case let .starterPlanned(starter):
            return starter.metadata
        case let .clarificationRequired(required):
            return required.metadata
        case let .blocked(blocked):
            return blocked.metadata
        }
    }
}
