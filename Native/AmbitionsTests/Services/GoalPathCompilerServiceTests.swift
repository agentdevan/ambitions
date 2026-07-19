import XCTest
@testable import Ambitions

final class GoalPathCompilerServiceTests: XCTestCase {
    func testCompilerReturnsBlockedPathWhenUnderstandingIsNotSafeToCompile() {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: sampleUnderstanding(decision: .mustClarifyBeforeCompile)
        )

        XCTAssertEqual(compiled.overallPosture, .blocked)
        XCTAssertFalse(compiled.safeForStarterPlanning)
        XCTAssertTrue(compiled.candidates.allSatisfy { $0.posture == .blocked })
    }

    func testCompilerKeepsAlternateInterpretationsAsAdditionalCandidatesAndBranches() {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: sampleUnderstanding()
        )

        XCTAssertGreaterThanOrEqual(compiled.candidates.count, 2)
        XCTAssertTrue(compiled.candidates.contains(where: { !$0.isPrimary }))
        XCTAssertTrue(compiled.candidates.first(where: \.isPrimary)?.branches.isEmpty == false)
        XCTAssertTrue(compiled.candidates.allSatisfy(candidateHasResolvableStageDependencies))
    }

    func testCompilerPreservesDependencyAssumptionRiskAndAuditStructure() {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: sampleUnderstanding()
        )

        let primary = compiled.candidates.first(where: \.isPrimary)
        XCTAssertEqual(primary?.dependencies.first?.id, "dependency-1")
        XCTAssertEqual(primary?.assumptions.first?.id, "assumption-1")
        XCTAssertEqual(primary?.risks.first?.id, "risk-1")
        XCTAssertFalse(compiled.audit.entries.isEmpty)
        XCTAssertFalse(primary?.appliedPacks.isEmpty ?? true)
        XCTAssertFalse(compiled.audit.packEntries.isEmpty)
    }

    func testCompilerWorksWithoutKnowledgeContext() {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: sampleUnderstanding()
        )

        XCTAssertFalse(compiled.uncertainty.knowledgeContextAttached)
        XCTAssertFalse(compiled.uncertainty.knowledgeContextRequired)
    }

    func testCompilerUsesStrongerPostureOnlyWhenUncertaintyIsMateriallyLower() {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: sampleStrongerUnderstanding()
        )

        XCTAssertEqual(compiled.overallPosture, .stronger)
        XCTAssertTrue(compiled.safeForStarterPlanning)
        XCTAssertTrue(compiled.candidates.allSatisfy { $0.posture == .stronger })
        XCTAssertTrue(compiled.candidates.allSatisfy(candidateHasResolvableStageDependencies))
    }

    func testStageDependencyIDsExactlyMatchEmittedDependencyRecords() throws {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: sampleUnderstanding()
        )

        let primary = try XCTUnwrap(compiled.candidates.first(where: \.isPrimary))
        let emittedDependencyIDs = Set(primary.dependencies.map(\.id))

        XCTAssertEqual(
            Set(primary.stages.flatMap(\.dependencyIDs)),
            emittedDependencyIDs.intersection(primary.stages.flatMap(\.dependencyIDs))
        )
        XCTAssertTrue(candidateHasResolvableStageDependencies(primary))
    }

    func testMultiStageCompiledCandidateHasResolvableStageOrderingDependencies() throws {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: sampleUnderstanding()
        )

        let primary = try XCTUnwrap(compiled.candidates.first(where: \.isPrimary))
        let stageOrderingDependencies = primary.dependencies.filter { $0.kind == .stageOrdering }

        XCTAssertEqual(stageOrderingDependencies.count, max(primary.stages.count - 1, 0))
        XCTAssertTrue(primary.stages.dropFirst().allSatisfy { stage in
            stage.dependencyIDs.allSatisfy { dependencyID in
                stageOrderingDependencies.contains(where: { $0.id == dependencyID })
            }
        })
    }

    func testCompilerAddsPlaceholderResourceHooksWithoutChangingCorePosture() throws {
        let compiled = DefaultGoalPathCompilerService().compile(
            understanding: sampleUnderstanding()
        )

        let primary = try XCTUnwrap(compiled.candidates.first(where: \.isPrimary))
        XCTAssertEqual(compiled.overallPosture, .provisional)
        XCTAssertTrue(primary.resourceHooks.isEmpty == false)
        XCTAssertTrue(primary.resourceHooks.allSatisfy { $0.placeholderState == .resourceNeeded })
    }
}

extension GoalPathCompilerServiceTests {
    func sampleUnderstanding(
        decision: GoalClarificationDecision = .safeToProceedWithAssumptions
    ) -> GoalUnderstanding {
        GoalUnderstandingModelsTests().sampleUnderstandingForCompiler(decision: decision)
    }

    func sampleStrongerUnderstanding() -> GoalUnderstanding {
        let analysis = GoalClarificationAnalysis(
            candidateInterpretations: [
                GoalInterpretationCandidate(
                    id: "primary",
                    summary: "Treat this as a concrete project.",
                    modeHint: .project,
                    domainHints: [.career],
                    confidence: .high,
                    supportingSignals: ["Explicit project framing"]
                )
            ],
            ambiguities: [],
            missingContext: [],
            assumptions: [],
            questions: [],
            decision: .safeToProceedWithAssumptions,
            reasoning: GoalClarificationReasoningMetadata(
                signalNotes: ["Uncertainty is low enough for a stronger compile posture."],
                inference: [:],
                auditTags: ["batch24-test"]
            )
        )

        return GoalUnderstanding(
            schemaVersion: goalUnderstandingSchemaVersion,
            subject: GoalUnderstandingSubject(
                canonicalIntent: "Ship my portfolio",
                normalizedTitle: "Ship my portfolio",
                normalizedSummary: "Ship my portfolio",
                explicitness: .explicit
            ),
            primaryInterpretation: GoalUnderstandingInterpretation(
                id: "primary",
                summary: "Treat this as a concrete project.",
                modeHint: .project,
                domainHints: [.career],
                supportingSignals: ["Explicit project framing"],
                source: .derivedInference
            ),
            alternateInterpretations: [],
            domains: GoalUnderstandingDomainInterpretation(
                primary: .career,
                all: [LifeDomainAssignment(domain: .career, priority: 1)],
                isAmbiguous: false
            ),
            mode: GoalUnderstandingModeInterpretation(
                goalMode: .project,
                planningStrategyID: .milestonePlan,
                progressStrategyID: .timedExecution,
                remainsProvisional: false
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
                unresolvedAmbiguity: false
            ),
            successDefinition: GoalUnderstandingSuccessInterpretation(
                summary: "Ship a first useful version of the portfolio.",
                explicitness: .explicit,
                remainsProvisional: false
            ),
            readiness: GoalUnderstandingReadinessInterpretation(
                decision: .safeToProceedWithAssumptions,
                safeToCompile: true,
                hasBlockingIssues: false,
                blockingFields: []
            ),
            constraints: [],
            dependencies: [
                GoalUnderstandingDependencyHint(
                    id: "dependency-1",
                    summary: "Portfolio review should happen before publishing.",
                    kind: .timeline,
                    sourceClaimIDs: [],
                    sourceRecordIDs: []
                )
            ],
            risks: [],
            assumptions: [],
            clarification: GoalUnderstandingClarificationCarryForward(
                analysis: analysis,
                unresolvedQuestions: [],
                missingContext: [],
                contradictions: [],
                alternateInterpretationsActive: false
            ),
            confidence: GoalUnderstandingConfidenceMetadata(
                overall: .high,
                score: 0.86,
                uncertaintyTags: []
            ),
            audit: GoalUnderstandingAuditMetadata(
                evidence: [
                    GoalUnderstandingAuditEntry(
                        id: "audit-1",
                        origin: .rawInput,
                        summary: "Ship my portfolio",
                        claimID: nil,
                        sourceRecordID: nil,
                        providerID: nil
                    )
                ]
            )
        )
    }

    func candidateHasResolvableStageDependencies(_ candidate: GoalCompiledPathCandidate) -> Bool {
        let emittedDependencyIDs = Set(candidate.dependencies.map(\.id))
        return candidate.stages.allSatisfy { stage in
            stage.dependencyIDs.allSatisfy(emittedDependencyIDs.contains)
        }
    }
}
