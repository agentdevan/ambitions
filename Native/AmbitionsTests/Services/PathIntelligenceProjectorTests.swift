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

    func testM06DomainPackProjectionExplainsLimitsTimelineProofAndFallback() throws {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: financeUnderstanding()
        )

        let projection = DefaultPathIntelligenceProjector().project(compiledPath: compiled, resourceGraph: nil)
        let pack = try XCTUnwrap(projection.domainPacks.first(where: { $0.family == .finance }))

        XCTAssertEqual(pack.packName, "Finance Pack")
        XCTAssertEqual(pack.sourceKind, .domainPack)
        XCTAssertEqual(pack.freshnessLabel, .current)
        XCTAssertTrue(pack.timelineRangeLabel.localizedCaseInsensitiveContains("medium-to-long"))
        XCTAssertTrue(pack.domainLimitSummary.localizedCaseInsensitiveContains("professional financial advice"))
        XCTAssertTrue(pack.proofSummary.localizedCaseInsensitiveContains("proof"))
        XCTAssertTrue(pack.fallbackSummary.localizedCaseInsensitiveContains("smaller or paused"))
    }

    func testM06ForkComparisonIsExplainableAndDoesNotChooseSilently() throws {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: financeUnderstanding()
        )

        let projection = DefaultPathIntelligenceProjector().project(compiledPath: compiled, resourceGraph: nil)
        let comparison = try XCTUnwrap(projection.forkComparisons.first)
        let combinedCopy = ([comparison.forkTitle, comparison.tradeoffSummary, comparison.decisionPrompt] + comparison.comparisonBasis)
            .joined(separator: " ")

        XCTAssertEqual(comparison.owningSurface, .goalDetail)
        XCTAssertTrue(comparison.decisionPrompt.localizedCaseInsensitiveContains("choose, edit, or park"))
        XCTAssertTrue(comparison.comparisonBasis.contains(where: {
            $0.localizedCaseInsensitiveContains("Finance Pack")
        }))
        XCTAssertTrue(comparison.comparisonBasis.contains(where: {
            $0.localizedCaseInsensitiveContains("Fallback condition")
        }))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("best path"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("highest score"))
        XCTAssertFalse(combinedCopy.localizedCaseInsensitiveContains("will happen"))
    }
}

private extension PathIntelligenceProjectorTests {
    func financeUnderstanding() -> GoalUnderstanding {
        let base = GoalPathCompilerServiceTests().sampleStrongerUnderstanding()
        return GoalUnderstanding(
            schemaVersion: base.schemaVersion,
            subject: base.subject,
            primaryInterpretation: GoalUnderstandingInterpretation(
                id: base.primaryInterpretation.id,
                summary: base.primaryInterpretation.summary,
                modeHint: .project,
                domainHints: [.finance],
                supportingSignals: base.primaryInterpretation.supportingSignals,
                source: base.primaryInterpretation.source
            ),
            alternateInterpretations: [],
            domains: GoalUnderstandingDomainInterpretation(
                primary: .finance,
                all: [LifeDomainAssignment(domain: .finance, priority: 1)],
                isAmbiguous: false
            ),
            mode: GoalUnderstandingModeInterpretation(
                goalMode: .project,
                planningStrategyID: base.mode.planningStrategyID,
                progressStrategyID: base.mode.progressStrategyID,
                remainsProvisional: false
            ),
            ownership: base.ownership,
            timeline: base.timeline,
            successDefinition: base.successDefinition,
            readiness: base.readiness,
            constraints: base.constraints,
            dependencies: base.dependencies,
            risks: base.risks,
            assumptions: base.assumptions,
            clarification: base.clarification,
            confidence: base.confidence,
            audit: base.audit
        )
    }
}
