import XCTest
@testable import Ambitions

final class GoalTeachingSignalServiceTests: XCTestCase {
    func testCaptureAndApplicableReadbackReturnLatestSameGoalSignal() async throws {
        let repository = InMemoryGoalTeachingSignalRepository()
        let service = DefaultGoalTeachingSignalService(repository: repository)
        let goalID = "goal-capture"
        let metadata = try metadata(
            input: "Submit my conference talk proposal by 2026-05-15",
            goalID: goalID
        )
        let interpretation = metadata.understanding.primaryInterpretation

        let first = GoalTeachingCaptureRequest(
            goalID: goalID,
            capturedAt: "2026-04-20T09:00:00Z",
            kind: .interpretationCorrection,
            payload: .interpretation(
                GoalTeachingInterpretationCorrection(
                    preferredInterpretationSummary: interpretation.summary,
                    preferredModeHint: interpretation.modeHint,
                    preferredDomainHints: interpretation.domainHints
                )
            ),
            target: GoalTeachingCaptureTarget(
                artifactKind: .understandingInterpretation,
                interpretationSummary: interpretation.summary,
                interpretationModeHint: interpretation.modeHint,
                interpretationDomainHints: interpretation.domainHints
            ),
            userNote: "This is the right reading."
        )
        let second = GoalTeachingCaptureRequest(
            goalID: goalID,
            capturedAt: "2026-04-20T10:00:00Z",
            kind: .interpretationCorrection,
            payload: .interpretation(
                GoalTeachingInterpretationCorrection(
                    preferredInterpretationSummary: interpretation.summary,
                    preferredModeHint: interpretation.modeHint,
                    preferredDomainHints: interpretation.domainHints
                )
            ),
            target: GoalTeachingCaptureTarget(
                artifactKind: .understandingInterpretation,
                interpretationSummary: interpretation.summary,
                interpretationModeHint: interpretation.modeHint,
                interpretationDomainHints: interpretation.domainHints
            ),
            userNote: "Newest correction should win."
        )

        _ = try await service.capture(first, metadata: metadata)
        let latest = try await service.capture(second, metadata: metadata)
        let applicable = try await service.applicableSignals(goalID: goalID, metadata: metadata)
        let history = try await service.listSignals(goalID: goalID)

        XCTAssertEqual(history.count, 2)
        XCTAssertEqual(applicable.signals.count, 1)
        XCTAssertEqual(applicable.signals.first?.id, latest.id)
        XCTAssertEqual(applicable.supersededSignalIDs.count, 1)
    }

    func testRejectsCrossGoalCorrection() async throws {
        let repository = InMemoryGoalTeachingSignalRepository()
        let service = DefaultGoalTeachingSignalService(repository: repository)
        let metadata = try metadata(
            input: "Submit my conference talk proposal by 2026-05-15",
            goalID: "goal-capture"
        )

        let request = GoalTeachingCaptureRequest(
            goalID: "different-goal",
            capturedAt: GoalEngineFixtures.fixedNow,
            kind: .goalSubjectCorrection,
            payload: .goalSubject(
                GoalTeachingGoalSubjectCorrection(correctedCanonicalIntent: "Become an astronaut")
            ),
            target: GoalTeachingCaptureTarget(
                artifactKind: .goalSubjectField,
                canonicalField: .goalSubject
            ),
            userNote: nil
        )

        await XCTAssertThrowsErrorAsync(try await service.capture(request, metadata: metadata)) { error in
            XCTAssertEqual(error as? GoalTeachingSignalError, .goalMismatch)
        }
    }

    func testRejectsUnanchoredContradictionCorrection() async throws {
        let repository = InMemoryGoalTeachingSignalRepository()
        let service = DefaultGoalTeachingSignalService(repository: repository)
        let metadata = try metadata(
            input: "I want to launch my business this summer, but I don't want deadlines",
            goalID: "goal-contradiction"
        )

        let request = GoalTeachingCaptureRequest(
            goalID: try XCTUnwrap(metadata.context.goalID),
            capturedAt: GoalEngineFixtures.fixedNow,
            kind: .contradictionDispositionCorrection,
            payload: .contradictionDisposition(
                GoalTeachingContradictionDispositionCorrection(correctedDisposition: .dismissed)
            ),
            target: GoalTeachingCaptureTarget(
                artifactKind: .contradictionShape,
                contradictionCode: .inputTimingConflict,
                contradictionArtifactRefs: []
            ),
            userNote: "This contradiction is not real."
        )

        await XCTAssertThrowsErrorAsync(try await service.capture(request, metadata: metadata)) { error in
            XCTAssertEqual(error as? GoalTeachingSignalError, .unanchoredArtifact)
        }
    }

    func testRejectsAmbiguousRequirementScope() async throws {
        let repository = InMemoryGoalTeachingSignalRepository()
        let service = DefaultGoalTeachingSignalService(repository: repository)
        let metadata = try metadata(
            input: "Launch my business",
            goalID: "goal-ambiguous"
        )
        let sharedSummary = try XCTUnwrap(
            metadata.compiledPath.candidates
                .flatMap(\.requirementHints)
                .first?.summary
        )

        let request = GoalTeachingCaptureRequest(
            goalID: try XCTUnwrap(metadata.context.goalID),
            capturedAt: GoalEngineFixtures.fixedNow,
            kind: .requirementRelevanceCorrection,
            payload: .requirementRelevance(
                GoalTeachingRequirementRelevanceCorrection(correctedDisposition: .notRelevant)
            ),
            target: GoalTeachingCaptureTarget(
                artifactKind: .requirementHint,
                requirementSummary: sharedSummary
            ),
            userNote: "Too broad."
        )

        await XCTAssertThrowsErrorAsync(try await service.capture(request, metadata: metadata)) { error in
            XCTAssertEqual(error as? GoalTeachingSignalError, .ambiguousScope)
        }
    }

    func testRejectsNonexistentEnergyTarget() async throws {
        let repository = InMemoryGoalTeachingSignalRepository()
        let service = DefaultGoalTeachingSignalService(repository: repository)
        let metadata = try metadata(
            input: "Submit my conference talk proposal by 2026-05-15",
            goalID: "goal-energy"
        )

        let request = GoalTeachingCaptureRequest(
            goalID: try XCTUnwrap(metadata.context.goalID),
            capturedAt: GoalEngineFixtures.fixedNow,
            kind: .energyFitCorrection,
            payload: .energyFit(
                GoalTeachingEnergyFitCorrection(correctedDisposition: .lighterVersionNeeded)
            ),
            target: GoalTeachingCaptureTarget(
                artifactKind: .energyEvaluation,
                candidateID: "missing-candidate",
                stageID: "missing-stage",
                stepID: "missing-step",
                energyTargetKind: .planStep,
                energyTargetID: "missing-step"
            ),
            userNote: nil
        )

        await XCTAssertThrowsErrorAsync(try await service.capture(request, metadata: metadata)) { error in
            XCTAssertEqual(error as? GoalTeachingSignalError, .artifactNotFound)
        }
    }

    private func metadata(input: String, goalID: String) throws -> GoalOrchestrationMetadata {
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

    private func XCTAssertThrowsErrorAsync<T>(
        _ expression: @autoclosure () async throws -> T,
        _ errorHandler: (Error) -> Void
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error to be thrown.")
        } catch {
            errorHandler(error)
        }
    }
}
