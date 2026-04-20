import XCTest
@testable import Ambitions

final class GoalPathCompilerModelsTests: XCTestCase {
    func testCompiledPathRoundTripsThroughCodable() throws {
        let compiledPath = sampleCompiledPath()

        let encoded = try JSONEncoder().encode(compiledPath)
        let decoded = try JSONDecoder().decode(GoalCompiledPath.self, from: encoded)

        XCTAssertEqual(decoded, compiledPath)
    }

    func testStarterPlanningSafetyStaysFalseWhenPostureIsBlocked() {
        let compiledPath = sampleCompiledPath(
            posture: .blocked,
            candidatePosture: .blocked,
            safeForStarterPlanning: false
        )

        XCTAssertEqual(compiledPath.overallPosture, .blocked)
        XCTAssertFalse(compiledPath.safeForStarterPlanning)
        XCTAssertFalse(compiledPath.candidates.contains(where: \.safeForStarterPlanning))
    }

    func testAssumptionsAndRisksPreserveLosslessShape() throws {
        let compiledPath = sampleCompiledPath()
        let assumption = try XCTUnwrap(compiledPath.candidates.first?.assumptions.first)
        let risk = try XCTUnwrap(compiledPath.candidates.first?.risks.first)

        XCTAssertEqual(assumption.id, "assumption-1")
        XCTAssertEqual(assumption.source, .derivedContract)
        XCTAssertEqual(assumption.relatedField, .goalShape)
        XCTAssertTrue(assumption.safeForCompilation)

        XCTAssertEqual(risk.id, "risk-1")
        XCTAssertEqual(risk.kind, .ambiguity)
        XCTAssertEqual(risk.severity, .important)
    }
}

private extension GoalPathCompilerModelsTests {
    func sampleCompiledPath(
        posture: GoalPathCompilePosture = .provisional,
        candidatePosture: GoalPathCompilePosture = .provisional,
        safeForStarterPlanning: Bool = true
    ) -> GoalCompiledPath {
        GoalCompiledPath(
            schemaVersion: goalPathCompilerSchemaVersion,
            sourceUnderstandingSchemaVersion: goalUnderstandingSchemaVersion,
            overallPosture: posture,
            safeForStarterPlanning: safeForStarterPlanning,
            candidates: [
                GoalCompiledPathCandidate(
                    id: "candidate-primary",
                    title: "Primary path",
                    summary: "Compile a conservative first path while ambiguity remains visible.",
                    isPrimary: true,
                    posture: candidatePosture,
                    safeForStarterPlanning: safeForStarterPlanning,
                    stages: [
                        GoalCompiledPathStage(
                            id: "stage-setup",
                            title: "Set up",
                            summary: "Frame the work before deeper commitment.",
                            orderIndex: 0,
                            kind: .setup,
                            dependencyIDs: [],
                            prerequisiteHints: ["Clarify the core outcome."],
                            readinessHints: ["A starter-safe assumption is available."],
                            uncertainBecause: [.activeAmbiguity]
                        )
                    ],
                    dependencies: [
                        GoalCompiledPathDependency(
                            id: "dependency-1",
                            summary: "Clarifying the goal shape improves downstream stability.",
                            kind: .readiness,
                            sourceClaimIDs: [],
                            sourceRecordIDs: [],
                            blocking: false,
                            relatedStageID: "stage-setup"
                        )
                    ],
                    branches: [
                        GoalCompiledPathBranch(
                            id: "branch-1",
                            branchType: .alternateInterpretation,
                            summary: "An exploratory reading remains available.",
                            condition: "Use this branch if the user confirms exploration over execution.",
                            targetCandidateID: "candidate-alternate",
                            targetStageID: nil,
                            posture: .provisional
                        )
                    ],
                    assumptions: [
                        GoalCompiledPathAssumption(
                            id: "assumption-1",
                            summary: "Use a conservative first pass.",
                            rationale: "Starter planning should stay narrow while ambiguity remains visible.",
                            confidence: .medium,
                            source: .derivedContract,
                            relatedField: .goalShape,
                            safeForCompilation: true
                        )
                    ],
                    risks: [
                        GoalCompiledPathRisk(
                            id: "risk-1",
                            summary: "Ambiguity around goal shape may change downstream path shape.",
                            kind: .ambiguity,
                            severity: .important
                        )
                    ],
                    blockingReasons: posture == .blocked ? [
                        GoalCompiledPathBlockingReason(
                            id: "blocking-1",
                            summary: "Clarification is still required before compile can proceed safely.",
                            field: .successDefinition
                        )
                    ] : [],
                    confidence: GoalCompiledPathConfidence(
                        overall: .medium,
                        score: 0.58,
                        uncertaintyTags: ["ambiguity_active"]
                    )
                )
            ],
            uncertainty: GoalCompiledPathUncertainty(
                ambiguityActive: true,
                missingContextFields: [.successDefinition],
                unresolvedQuestionIDs: ["question-1"],
                alternateInterpretationsActive: true,
                knowledgeContextAttached: false,
                knowledgeContextRequired: false
            ),
            audit: GoalCompiledPathAuditMetadata(
                entries: [
                    GoalCompiledPathAuditEntry(
                        id: "audit-1",
                        kind: .interpretationSelection,
                        sourceInterpretationID: "primary",
                        sourceDependencyID: nil,
                        sourceRiskID: nil,
                        sourceAssumptionID: nil,
                        claimID: nil,
                        sourceRecordID: nil,
                        summary: "Primary interpretation selected as the lead path candidate."
                    )
                ]
            )
        )
    }
}
