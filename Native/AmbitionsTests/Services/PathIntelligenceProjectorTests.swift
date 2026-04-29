import XCTest
@testable import Ambitions

final class PathIntelligenceProjectorTests: XCTestCase {
    func testM05ProjectionKeepsPathFamiliesQualitativeAndSourceBounded() throws {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: GoalPathCompilerServiceTests().sampleUnderstanding()
        )
        let resourceGraph = DefaultGoalResourceGraphService().build(
            compiledPath: compiled,
            knowledgeContext: nil
        )

        let projection = DefaultPathIntelligenceProjector().project(
            compiledPath: compiled,
            resourceGraph: resourceGraph
        )

        XCTAssertEqual(projection.schemaVersion, pathIntelligenceSchemaVersion)
        XCTAssertEqual(projection.sourceCompiledPathSchemaVersion, compiled.schemaVersion)
        XCTAssertTrue(projection.families.contains(where: { $0.family == .career }))
        XCTAssertTrue(projection.families.allSatisfy { $0.sourceKind == .domainPack || $0.sourceKind == .userOwnedGoal })
        XCTAssertTrue(projection.sourceBoundaries.contains(where: { $0.sourceKind == .externalKnowledge }))
        XCTAssertEqual(
            projection.sourceBoundaries.first(where: { $0.sourceKind == .externalKnowledge })?.freshnessLabel,
            .basedOnOlderContext
        )
        XCTAssertTrue(projection.sourceBoundaries.contains(where: {
            $0.sourceKind == .domainPack && $0.summary.localizedCaseInsensitiveContains("not professional advice")
        }))
    }

    func testM05ProjectionExposesStagesAssumptionsProofFallbacksAndDailyConnection() throws {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: GoalPathCompilerServiceTests().sampleUnderstanding()
        )

        let projection = DefaultPathIntelligenceProjector().project(compiledPath: compiled, resourceGraph: nil)

        XCTAssertEqual(projection.stages.map(\.kind), [
            .setup,
            .readiness,
            .firstProof,
            .advancement,
            .reviewFinish
        ])
        XCTAssertFalse(projection.assumptions.isEmpty)
        XCTAssertTrue(projection.assumptions.allSatisfy {
            $0.correctionPrompt.localizedCaseInsensitiveContains("update this assumption")
        })
        XCTAssertTrue(projection.proofRequirements.contains(where: { $0.proofKind == .milestoneEvidence }))
        XCTAssertTrue(projection.fallbackPaths.contains(where: { $0.posture == .provisional }))
        XCTAssertEqual(projection.dailyConnection.owningSurface, .today)
        XCTAssertTrue(projection.dailyConnection.nextStepTitle.localizedCaseInsensitiveContains("start with"))
        XCTAssertNotNil(projection.dailyConnection.proofHint)
    }

    func testM05FutureSelfScenariosAreExplorationNotPrediction() throws {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: GoalPathCompilerServiceTests().sampleUnderstanding()
        )

        let projection = DefaultPathIntelligenceProjector().project(compiledPath: compiled, resourceGraph: nil)
        let humanFacingCopy = projection.futureSelfScenarios
            .flatMap { [$0.title, $0.summary, $0.notPredictionLabel] }
            .joined(separator: " ")

        XCTAssertTrue(projection.futureSelfScenarios.contains(where: { $0.kind == .continueCurrentPath }))
        XCTAssertTrue(projection.futureSelfScenarios.contains(where: { $0.kind == .smallerFirstMove }))
        XCTAssertTrue(projection.futureSelfScenarios.contains(where: { $0.kind == .fallbackPath }))
        XCTAssertTrue(projection.futureSelfScenarios.allSatisfy { $0.notPredictionLabel == "Scenario, not prediction" })
        XCTAssertFalse(humanFacingCopy.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(humanFacingCopy.localizedCaseInsensitiveContains("model confidence"))
        XCTAssertFalse(humanFacingCopy.localizedCaseInsensitiveContains("will happen"))
        XCTAssertFalse(humanFacingCopy.localizedCaseInsensitiveContains("confidence score"))
    }

    func testM05BlockedPathRoutesToPlanBeforeTodayProtection() {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: GoalPathCompilerServiceTests().sampleUnderstanding(decision: .mustClarifyBeforeCompile)
        )

        let projection = DefaultPathIntelligenceProjector().project(compiledPath: compiled, resourceGraph: nil)

        XCTAssertEqual(projection.overallPosture, .blocked)
        XCTAssertEqual(projection.dailyConnection.owningSurface, .plan)
        XCTAssertTrue(projection.futureSelfScenarios.contains(where: { $0.kind == .waitingReview }))
        XCTAssertTrue(projection.fallbackPaths.contains(where: { $0.posture == .blocked }))
    }
}
