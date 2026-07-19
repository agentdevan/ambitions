import XCTest
@testable import Ambitions

final class GoalClarificationServiceTests: XCTestCase {
    func testVagueBusinessGoalPreservesMultipleInterpretationsAndSafeStarterDecision() {
        let service = DefaultGoalClarificationService()
        let intake = GoalEngineIntakeService()
        let classification = intake.classify(rawInput: "Launch my business", referenceNow: GoalEngineFixtures.fixedNow)

        let analysis = service.analyze(
            classification: classification,
            context: GoalEngineOrchestrationContextSnapshot(
                goalID: nil,
                actorName: nil,
                preferredPlanningStrictness: .starterFriendly,
                goalOwnerRole: nil,
                supportScope: nil,
                deadlineHints: [],
                existingGoalReferences: [],
                sourceScreen: nil,
                sourceFlow: nil,
                clarifiedFields: [:],
                referenceNow: GoalEngineFixtures.fixedNow
            )
        )

        XCTAssertEqual(analysis.decision, .safeToProceedWithAssumptions)
        XCTAssertGreaterThan(analysis.candidateInterpretations.count, 1)
        XCTAssertTrue(analysis.ambiguities.contains(where: { $0.type == .scope || $0.type == .domain }))
        XCTAssertFalse(analysis.compatibilityPlanAssumptions.isEmpty)
    }

    func testDontKnowWhereToStartRequiresClarificationBeforeCompile() {
        let service = DefaultGoalClarificationService()
        let intake = GoalEngineIntakeService()
        let classification = intake.classify(rawInput: "I don't know where to start", referenceNow: GoalEngineFixtures.fixedNow)

        let analysis = service.analyze(
            classification: classification,
            context: GoalEngineOrchestrationContextSnapshot(
                goalID: nil,
                actorName: nil,
                preferredPlanningStrictness: .balanced,
                goalOwnerRole: nil,
                supportScope: nil,
                deadlineHints: [],
                existingGoalReferences: [],
                sourceScreen: nil,
                sourceFlow: nil,
                clarifiedFields: [:],
                referenceNow: GoalEngineFixtures.fixedNow
            )
        )

        XCTAssertEqual(analysis.decision, .mustClarifyBeforeCompile)
        XCTAssertTrue(analysis.missingContext.contains(where: { $0.field == .goalSubject && $0.blocksCompilation }))
        XCTAssertTrue(analysis.questions.contains(where: { $0.targetField == .goalSubject && $0.blocking }))
    }
}
