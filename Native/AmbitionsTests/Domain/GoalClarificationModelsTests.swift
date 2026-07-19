import XCTest
@testable import Ambitions

final class GoalClarificationModelsTests: XCTestCase {
    func testClarificationAnalysisRoundTripsThroughCodable() throws {
        let analysis = sampleAnalysis(decision: .safeToProceedWithAssumptions)

        let encoded = try JSONEncoder().encode(analysis)
        let decoded = try JSONDecoder().decode(GoalClarificationAnalysis.self, from: encoded)

        XCTAssertEqual(decoded, analysis)
    }

    func testCompatibilityProjectionPreservesMultipleInterpretations() {
        let analysis = sampleAnalysis(decision: .safeToProceedWithAssumptions)

        XCTAssertEqual(analysis.candidateInterpretations.count, 2)
        XCTAssertEqual(analysis.compatibilityReadiness, .canPlanWithDefaults)
        XCTAssertEqual(analysis.compatibilityQuestions.map(\.field), [.goalShape])
        XCTAssertEqual(analysis.compatibilityMissingFields.map(\.field), [.goalShape])
        XCTAssertEqual(analysis.compatibilityPlanAssumptions.map(\.relatedField), [.goalShape])
    }

    func testBlockingDecisionProjectsToNeedsClarification() {
        let analysis = sampleAnalysis(decision: .mustClarifyBeforeCompile)

        XCTAssertEqual(analysis.compatibilityReadiness, .needsClarification)
        XCTAssertTrue(analysis.compatibilityPlanAssumptions.isEmpty)
    }
}

private extension GoalClarificationModelsTests {
    func sampleAnalysis(decision: GoalClarificationDecision) -> GoalClarificationAnalysis {
        GoalClarificationAnalysis(
            candidateInterpretations: [
                GoalInterpretationCandidate(
                    id: "project",
                    summary: "Treat this as a concrete project.",
                    modeHint: .project,
                    domainHints: [.career],
                    confidence: .medium,
                    supportingSignals: ["Launch language"]
                ),
                GoalInterpretationCandidate(
                    id: "exploration",
                    summary: "Treat this as exploratory work.",
                    modeHint: .exploration,
                    domainHints: [.career],
                    confidence: .medium,
                    supportingSignals: ["Generic business language"]
                )
            ],
            ambiguities: [
                GoalAmbiguitySignal(
                    id: "ambiguity-scope",
                    type: .scope,
                    summary: "Project or exploration is still ambiguous.",
                    detail: "Both readings remain plausible.",
                    severity: decision == .mustClarifyBeforeCompile ? .blocking : .important,
                    relatedField: .goalShape,
                    candidateIDs: ["project", "exploration"]
                )
            ],
            missingContext: [
                GoalMissingContextItem(
                    id: "missing-goal-shape",
                    field: .goalShape,
                    label: "Goal shape",
                    reason: "The goal shape is still broad.",
                    severity: decision == .mustClarifyBeforeCompile ? .blocking : .important,
                    blocksCompilation: decision == .mustClarifyBeforeCompile
                )
            ],
            assumptions: [
                GoalClarificationAssumption(
                    id: "assumption-goal-shape",
                    summary: "Assume the first pass should stay conservative.",
                    rationale: "Starter planning stays narrow while ambiguity remains explicit.",
                    confidence: .medium,
                    source: .derivedContract,
                    relatedField: .goalShape,
                    safeForCompilation: true
                )
            ],
            questions: [
                GoalClarificationQuestionContract(
                    id: "question-goal-shape",
                    prompt: "Should this be exploration or a concrete project?",
                    rationale: "The plan shape changes depending on the answer.",
                    targetField: .goalShape,
                    addressesAmbiguityTypes: [.scope],
                    severity: decision == .mustClarifyBeforeCompile ? .blocking : .important,
                    blocking: decision == .mustClarifyBeforeCompile,
                    skipSafeDefault: "Keep the starter plan provisional."
                )
            ],
            decision: decision,
            reasoning: GoalClarificationReasoningMetadata(
                signalNotes: ["Multiple interpretations preserved structurally."],
                inference: [:],
                auditTags: ["batch22"]
            )
        )
    }
}
