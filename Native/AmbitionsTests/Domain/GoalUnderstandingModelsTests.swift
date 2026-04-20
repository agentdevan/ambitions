import XCTest
@testable import Ambitions

final class GoalUnderstandingModelsTests: XCTestCase {
    func testGoalUnderstandingRoundTripsThroughCodable() throws {
        let understanding = sampleUnderstanding()

        let encoded = try JSONEncoder().encode(understanding)
        let decoded = try JSONDecoder().decode(GoalUnderstanding.self, from: encoded)

        XCTAssertEqual(decoded, understanding)
    }

    func testReadinessIsDerivedFromClarificationDecision() {
        let understanding = sampleUnderstanding(decision: .mustClarifyBeforeCompile)

        XCTAssertEqual(understanding.readiness.decision, .mustClarifyBeforeCompile)
        XCTAssertFalse(understanding.readiness.safeToCompile)
        XCTAssertTrue(understanding.readiness.hasBlockingIssues)
    }

    func testAlternateInterpretationsRemainVisibleWhenAmbiguityIsActive() {
        let understanding = sampleUnderstanding()

        XCTAssertEqual(understanding.primaryInterpretation.id, "primary")
        XCTAssertEqual(understanding.alternateInterpretations.map(\.id), ["alternate"])
        XCTAssertTrue(understanding.clarification.alternateInterpretationsActive)
        XCTAssertTrue(understanding.domains.isAmbiguous)
    }
}

private extension GoalUnderstandingModelsTests {
    func sampleUnderstanding(
        decision: GoalClarificationDecision = .safeToProceedWithAssumptions
    ) -> GoalUnderstanding {
        let analysis = GoalClarificationAnalysis(
            candidateInterpretations: [
                GoalInterpretationCandidate(
                    id: "primary",
                    summary: "Treat this as a concrete project.",
                    modeHint: .project,
                    domainHints: [.career],
                    confidence: .medium,
                    supportingSignals: ["Launch language"]
                ),
                GoalInterpretationCandidate(
                    id: "alternate",
                    summary: "Treat this as exploratory work first.",
                    modeHint: .exploration,
                    domainHints: [.career, .personalGrowth],
                    confidence: .medium,
                    supportingSignals: ["Goal is still broad"]
                )
            ],
            ambiguities: [
                GoalAmbiguitySignal(
                    id: "ambiguity-1",
                    type: .scope,
                    summary: "Project shape remains broad.",
                    detail: "Multiple structural readings are still plausible.",
                    severity: decision == .mustClarifyBeforeCompile ? .blocking : .important,
                    relatedField: .goalShape,
                    candidateIDs: ["primary", "alternate"]
                )
            ],
            missingContext: [
                GoalMissingContextItem(
                    id: "missing-success",
                    field: .successDefinition,
                    label: "Success definition",
                    reason: "The win condition is still broad.",
                    severity: decision == .mustClarifyBeforeCompile ? .blocking : .important,
                    blocksCompilation: decision == .mustClarifyBeforeCompile
                )
            ],
            assumptions: [
                GoalClarificationAssumption(
                    id: "assumption-1",
                    summary: "Use a conservative first pass.",
                    rationale: "Starter planning should stay narrow while ambiguity remains visible.",
                    confidence: .medium,
                    source: .derivedContract,
                    relatedField: .goalShape,
                    safeForCompilation: decision == .safeToProceedWithAssumptions
                )
            ],
            questions: [
                GoalClarificationQuestionContract(
                    id: "question-1",
                    prompt: "Should this be treated as exploration or a concrete project?",
                    rationale: "The structural reading changes the downstream plan shape.",
                    targetField: .goalShape,
                    addressesAmbiguityTypes: [.scope],
                    severity: decision == .mustClarifyBeforeCompile ? .blocking : .important,
                    blocking: decision == .mustClarifyBeforeCompile,
                    skipSafeDefault: "Keep the starter plan provisional."
                )
            ],
            decision: decision,
            reasoning: GoalClarificationReasoningMetadata(
                signalNotes: ["Multiple structural readings remain active."],
                inference: [:],
                auditTags: ["batch23-test"]
            )
        )

        return GoalUnderstanding(
            schemaVersion: "goal_understanding.native.v1",
            subject: GoalUnderstandingSubject(
                canonicalIntent: "Launch my business",
                normalizedTitle: "Launch my business",
                normalizedSummary: "Launch my business",
                explicitness: .explicit
            ),
            primaryInterpretation: GoalUnderstandingInterpretation(
                id: "primary",
                summary: "Treat this as a concrete project.",
                modeHint: .project,
                domainHints: [.career],
                supportingSignals: ["Launch language"],
                source: .derivedInference
            ),
            alternateInterpretations: [
                GoalUnderstandingInterpretation(
                    id: "alternate",
                    summary: "Treat this as exploratory work first.",
                    modeHint: .exploration,
                    domainHints: [.career, .personalGrowth],
                    supportingSignals: ["Goal is still broad"],
                    source: .derivedInference
                )
            ],
            domains: GoalUnderstandingDomainInterpretation(
                primary: .career,
                all: [
                    LifeDomainAssignment(domain: .career, priority: 0.9),
                    LifeDomainAssignment(domain: .personalGrowth, priority: 0.4)
                ],
                isAmbiguous: true
            ),
            mode: GoalUnderstandingModeInterpretation(
                goalMode: .project,
                planningStrategyID: .milestonePlan,
                progressStrategyID: .timedExecution,
                remainsProvisional: decision != .safeToProceedWithAssumptions
            ),
            ownership: GoalUnderstandingOwnershipInterpretation(
                executionOwnership: .self,
                userRole: .executor,
                supportScope: nil,
                actorDisplayName: "You",
                actorRoleLabel: "Primary owner"
            ),
            timeline: GoalUnderstandingTimelineInterpretation(
                tempo: .targetWindow,
                timing: GoalTiming(
                    tempo: .targetWindow,
                    timingType: .targetBy,
                    startsOn: nil,
                    dueAt: nil,
                    targetBy: "2026-08-31",
                    windowStart: nil,
                    windowEnd: nil,
                    suggestedNextAt: nil,
                    repeatEveryDays: nil,
                    progressReviewCadenceDays: 7
                ),
                posture: .flexibleWindow,
                unresolvedAmbiguity: true
            ),
            successDefinition: GoalUnderstandingSuccessInterpretation(
                summary: "Launch a first useful business version.",
                explicitness: .inferred,
                remainsProvisional: true
            ),
            readiness: GoalUnderstandingReadinessInterpretation(
                decision: decision,
                safeToCompile: decision == .safeToProceedWithAssumptions,
                hasBlockingIssues: decision == .mustClarifyBeforeCompile,
                blockingFields: decision == .mustClarifyBeforeCompile ? [.successDefinition] : []
            ),
            constraints: [
                GoalUnderstandingConstraintHint(
                    id: "constraint-1",
                    summary: "Success definition is still broad.",
                    kind: .successDefinition,
                    relatedField: .successDefinition,
                    blocking: decision == .mustClarifyBeforeCompile,
                    source: .clarification
                )
            ],
            dependencies: [
                GoalUnderstandingDependencyHint(
                    id: "dependency-1",
                    summary: "A narrower success condition would stabilize compile readiness.",
                    kind: .readiness,
                    sourceClaimIDs: [],
                    sourceRecordIDs: []
                )
            ],
            risks: [
                GoalUnderstandingRiskFlag(
                    id: "risk-1",
                    summary: "Ambiguity around goal shape may change downstream path shape.",
                    kind: .ambiguity,
                    severity: .important
                )
            ],
            assumptions: [
                GoalUnderstandingAssumption(
                    id: "assumption-1",
                    summary: "Use a conservative first pass.",
                    rationale: "Starter planning should stay narrow while ambiguity remains visible.",
                    confidence: .medium,
                    source: .derivedContract,
                    relatedField: .goalShape,
                    safeForCompilation: decision == .safeToProceedWithAssumptions
                )
            ],
            clarification: GoalUnderstandingClarificationCarryForward(
                analysis: analysis,
                unresolvedQuestions: analysis.questions,
                missingContext: analysis.missingContext,
                contradictions: [],
                alternateInterpretationsActive: true
            ),
            confidence: GoalUnderstandingConfidenceMetadata(
                overall: .medium,
                score: 0.58,
                uncertaintyTags: ["ambiguity_active", "success_definition_broad"]
            ),
            audit: GoalUnderstandingAuditMetadata(
                evidence: [
                    GoalUnderstandingAuditEntry(
                        id: "audit-raw",
                        origin: .rawInput,
                        summary: "Launch my business",
                        claimID: nil,
                        sourceRecordID: nil,
                        providerID: nil
                    ),
                    GoalUnderstandingAuditEntry(
                        id: "audit-derived",
                        origin: .derivedInference,
                        summary: "Project interpretation selected as primary.",
                        claimID: nil,
                        sourceRecordID: nil,
                        providerID: nil
                    )
                ]
            )
        )
    }
}

extension GoalUnderstandingModelsTests {
    func sampleUnderstandingForCompiler(
        decision: GoalClarificationDecision = .safeToProceedWithAssumptions
    ) -> GoalUnderstanding {
        sampleUnderstanding(decision: decision)
    }
}
