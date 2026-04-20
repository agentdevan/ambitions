import XCTest
@testable import Ambitions

final class GoalContradictionServiceTests: XCTestCase {
    func testBridgesExistingInputContradictionsWithoutReinterpretingThem() {
        let service = DefaultGoalContradictionService()
        let input = makeInput(
            clarification: makeClarification(
                contradictions: [
                    GoalInputContradiction(
                        code: .timingConflict,
                        reason: "The input asks for both flexible and strict timing.",
                        question: ClarificationQuestion(
                            id: "timing-conflict",
                            field: .timeHorizon,
                            prompt: "Should this stay flexible or date-driven?",
                            rationale: "Timing posture needs clarification.",
                            skipSafeDefault: "Clarify before producing a full plan."
                        )
                    )
                ]
            )
        )

        let report = service.analyze(input: input)

        XCTAssertEqual(report.records.count, 1)
        XCTAssertEqual(report.records.first?.code, .inputTimingConflict)
        XCTAssertEqual(report.records.first?.severity, .blocking)
    }

    func testEmitsRequiredResourceMissingSupportOnlyForBlockingArtifacts() {
        let service = DefaultGoalContradictionService()
        let input = makeInput(
            compiledPath: makeCompiledPath(
                requirementBlocking: true,
                resourceOptionality: .required
            ),
            resourceGraph: makeResourceGraph(
                missingState: .resourceNeeded,
                optionality: .required,
                freshnessPosture: .blockedMissingEvidence
            )
        )

        let report = service.analyze(input: input)

        XCTAssertTrue(report.records.contains(where: { $0.code == .requiredResourceMissingSupport }))
    }

    func testDoesNotEmitContradictionForOptionalResource() {
        let service = DefaultGoalContradictionService()
        let input = makeInput(
            compiledPath: makeCompiledPath(
                requirementBlocking: false,
                resourceOptionality: .optional
            ),
            resourceGraph: makeResourceGraph(
                missingState: .resourceNeeded,
                optionality: .optional,
                freshnessPosture: .blockedMissingEvidence
            )
        )

        let report = service.analyze(input: input)

        XCTAssertFalse(report.records.contains(where: { $0.code == .requiredResourceMissingSupport }))
    }

    func testDoesNotEmitStaleSupportContradictionWithoutBlockingRequirement() {
        let service = DefaultGoalContradictionService()
        let input = makeInput(
            compiledPath: makeCompiledPath(
                requirementBlocking: false,
                resourceOptionality: .required
            ),
            resourceGraph: makeResourceGraph(
                missingState: .none,
                optionality: .required,
                freshnessPosture: .stale
            )
        )

        let report = service.analyze(input: input)

        XCTAssertFalse(report.records.contains(where: { $0.code == .requiredResourceStaleSupport }))
    }

    func testEmitsStarterAssumptionVsBlockingRequirementContradiction() {
        let service = DefaultGoalContradictionService()
        let understanding = makeUnderstanding()
        let compiledPath = makeCompiledPath(requirementBlocking: true, resourceOptionality: .required)
        let input = makeInput(
            understanding: understanding,
            compiledPath: compiledPath,
            resourceGraph: makeResourceGraph(
                missingState: .resourceNeeded,
                optionality: .required,
                freshnessPosture: .blockedMissingEvidence
            )
        )

        let report = service.analyze(input: input)

        XCTAssertTrue(report.records.contains(where: { $0.code == .starterAssumptionVsBlockingRequirement }))
    }

    func testEmitsRequiredResourceProviderUnavailableWhenBlockingRequirementDependsOnUnavailableProvider() {
        let service = DefaultGoalContradictionService()
        let knowledgeContext = GoalUnderstandingKnowledgeContext(
            claims: [],
            sources: [
                KnowledgeSourceRecord(
                    id: "source-1",
                    providerID: "provider-1",
                    entityTitle: "Official checklist",
                    publisher: "Provider",
                    locator: nil,
                    provenanceKind: .official,
                    isOfficial: true
                )
            ],
            providerStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider-1",
                        type: .officialAPI,
                        displayName: "Provider"
                    ),
                    availability: .providerUnavailable,
                    detail: "Temporarily unavailable",
                    runtimeTrustPosture: .localOnly
                )
            ]
        )
        let input = makeInput(
            compiledPath: makeCompiledPath(
                requirementBlocking: true,
                resourceOptionality: .required
            ),
            resourceGraph: makeResourceGraph(
                missingState: .none,
                optionality: .required,
                freshnessPosture: .currentEnough,
                sourceRecordIDs: ["source-1"]
            ),
            knowledgeContext: knowledgeContext
        )

        let report = service.analyze(input: input)

        XCTAssertTrue(report.records.contains(where: { $0.code == GoalContradictionCode.requiredResourceProviderUnavailable }))
    }

    func testEmitsBlockedStepHasCompletionEvidenceWithStrongSameStepEvidence() {
        let service = DefaultGoalContradictionService()
        let plannedSteps = [makePlanStep(id: "step-1", state: .blocked, type: .actionUnit)]
        let input = makeInput(
            plannedSteps: plannedSteps,
            evidence: [
                makeEvidence(id: "e1", stepID: "step-1", kind: .stepCompleted),
                makeEvidence(id: "e2", stepID: "step-1", kind: .stepCompleted),
                makeEvidence(id: "e3", stepID: "step-1", kind: .habitMinimumVersion)
            ]
        )

        let report = service.analyze(input: input)

        XCTAssertTrue(report.records.contains(where: { $0.code == .blockedStepHasCompletionEvidence }))
    }

    func testSparseBehaviorDoesNotEmitBlockedStepContradiction() {
        let service = DefaultGoalContradictionService()
        let plannedSteps = [makePlanStep(id: "step-1", state: .blocked, type: .actionUnit)]
        let input = makeInput(
            plannedSteps: plannedSteps,
            evidence: [
                makeEvidence(id: "e1", stepID: "step-1", kind: .stepCompleted)
            ]
        )

        let report = service.analyze(input: input)

        XCTAssertFalse(report.records.contains(where: { $0.code == .blockedStepHasCompletionEvidence }))
    }

    func testEmitsPlannedStepMarkedNotRelevantWithStrongLocalFeedback() {
        let service = DefaultGoalContradictionService()
        let plannedSteps = [makePlanStep(id: "step-1", state: .planned, type: .actionUnit)]
        let input = makeInput(
            plannedSteps: plannedSteps,
            feedback: [
                .notRelevant(base: makeFeedbackBase(id: "f1", stepID: "step-1")),
                .notRelevant(base: makeFeedbackBase(id: "f2", stepID: "step-1")),
                .notRelevant(base: makeFeedbackBase(id: "f3", stepID: "step-1"))
            ]
        )

        let report = service.analyze(input: input)

        XCTAssertTrue(report.records.contains(where: { $0.code == .plannedStepMarkedNotRelevant }))
    }

    func testEmitsEnergyFitVsSameGoalBehaviorFrictionOnlyWithStrongLocalSignals() {
        let service = DefaultGoalContradictionService()
        let input = makeInput(
            energyModel: makeEnergyModel(score: 0.82, fitBand: .supportive, stepID: "step-1"),
            plannedSteps: [makePlanStep(id: "step-1", state: .planned, type: .actionUnit)],
            feedback: [
                .tooBig(base: makeFeedbackBase(id: "f1", stepID: "step-1")),
                .askedForSmallerVersion(base: makeFeedbackBase(id: "f2", stepID: "step-1")),
                .skipped(base: makeFeedbackBase(id: "f3", stepID: "step-1"), reasonCode: .tooHard)
            ]
        )

        let report = service.analyze(input: input)

        XCTAssertTrue(report.records.contains(where: { $0.code == .energyFitVsSameGoalBehaviorFriction }))
    }

    func testDeduplicatesEquivalentUnderlyingIssue() {
        let service = DefaultGoalContradictionService()
        let contradiction = GoalInputContradiction(
            code: .timingConflict,
            reason: "The input asks for both flexible and strict timing.",
            question: ClarificationQuestion(
                id: "timing-conflict",
                field: .timeHorizon,
                prompt: "Should this stay flexible or date-driven?",
                rationale: "Timing posture needs clarification.",
                skipSafeDefault: "Clarify before producing a full plan."
            )
        )
        let input = makeInput(
            clarification: makeClarification(contradictions: [contradiction, contradiction])
        )

        let report = service.analyze(input: input)

        XCTAssertEqual(report.records.filter { $0.code == .inputTimingConflict }.count, 1)
    }

    func testOutputOrderingRemainsStableWithShuffledInputs() {
        let service = DefaultGoalContradictionService()
        let first = service.analyze(input: makeOrderingInput())
        let second = service.analyze(input: makeOrderingInput(shuffled: true))

        XCTAssertEqual(first, second)
    }
}

private extension GoalContradictionServiceTests {
    func makeInput(
        classification: ClassificationResult = GoalEngineIntakeService().classify(
            rawInput: "Launch my business by 2026-08-31",
            referenceNow: GoalEngineFixtures.fixedNow
        ),
        clarification: GoalOrchestrationClarification? = nil,
        understanding: GoalUnderstanding? = nil,
        compiledPath: GoalCompiledPath? = nil,
        resourceGraph: GoalResourceGraph? = nil,
        energyModel: GoalEnergyModel? = nil,
        knowledgeContext: GoalUnderstandingKnowledgeContext? = nil,
        plannedSteps: [Step]? = nil,
        evidence: [ProgressEvidence] = [],
        feedback: [GoalFeedbackEvent] = []
    ) -> GoalContradictionAnalysisInput {
        GoalContradictionAnalysisInput(
            classification: classification,
            clarification: clarification ?? makeClarification(),
            understanding: understanding ?? makeUnderstanding(),
            compiledPath: compiledPath ?? makeCompiledPath(requirementBlocking: false, resourceOptionality: .optional),
            resourceGraph: resourceGraph ?? makeResourceGraph(missingState: .none, optionality: .optional, freshnessPosture: .currentEnough),
            energyModel: energyModel ?? makeEnergyModel(score: 0.62, fitBand: .sustainable, stepID: "step-1"),
            knowledgeContext: knowledgeContext,
            plannedSteps: plannedSteps ?? [makePlanStep(id: "step-1", state: .planned, type: .actionUnit)],
            evidence: evidence,
            feedback: feedback
        )
    }

    func makeClarification(
        contradictions: [GoalInputContradiction] = []
    ) -> GoalOrchestrationClarification {
        GoalOrchestrationClarification(
            readiness: contradictions.isEmpty ? .readyForPlanning : .needsClarification,
            questions: contradictions.map(\.question),
            missingFields: contradictions.map {
                MissingField(field: $0.question.field, reason: $0.reason, blocksPlanning: true)
            },
            contradictions: contradictions,
            analysis: GoalClarificationAnalysis(
                candidateInterpretations: [],
                ambiguities: [],
                missingContext: [],
                assumptions: [],
                questions: [],
                decision: contradictions.isEmpty ? .safeToProceedWithAssumptions : .mustClarifyBeforeCompile,
                reasoning: GoalClarificationReasoningMetadata(signalNotes: [], inference: [:], auditTags: [])
            )
        )
    }

    func makeUnderstanding() -> GoalUnderstanding {
        let analysis = GoalClarificationAnalysis(
            candidateInterpretations: [],
            ambiguities: [],
            missingContext: [],
            assumptions: [
                GoalClarificationAssumption(
                    id: "assumption-1",
                    summary: "Use a starter-safe assumption.",
                    rationale: "Starter planning remains narrow.",
                    confidence: .medium,
                    source: .derivedContract,
                    relatedField: .successDefinition,
                    safeForCompilation: true
                )
            ],
            questions: [],
            decision: .safeToProceedWithAssumptions,
            reasoning: GoalClarificationReasoningMetadata(signalNotes: [], inference: [:], auditTags: [])
        )

        return GoalUnderstanding(
            schemaVersion: goalUnderstandingSchemaVersion,
            subject: GoalUnderstandingSubject(
                canonicalIntent: "Launch my business by 2026-08-31",
                normalizedTitle: "Launch my business by 2026-08-31",
                normalizedSummary: nil,
                explicitness: .explicit
            ),
            primaryInterpretation: GoalUnderstandingInterpretation(
                id: "primary",
                summary: "Treat this as a concrete project.",
                modeHint: .project,
                domainHints: [.career],
                supportingSignals: ["Timed launch language"],
                source: .derivedInference
            ),
            alternateInterpretations: [],
            domains: GoalUnderstandingDomainInterpretation(
                primary: .career,
                all: [LifeDomainAssignment(domain: .career)],
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
                tempo: .deadlineBased,
                timing: GoalTiming(
                    tempo: .deadlineBased,
                    timingType: .dueAt,
                    startsOn: nil,
                    dueAt: "2026-08-31T12:00:00Z",
                    targetBy: nil,
                    windowStart: nil,
                    windowEnd: nil,
                    suggestedNextAt: nil,
                    repeatEveryDays: nil,
                    progressReviewCadenceDays: 7
                ),
                posture: .hardDeadline,
                unresolvedAmbiguity: false
            ),
            successDefinition: GoalUnderstandingSuccessInterpretation(
                summary: "Launch a useful first version.",
                explicitness: .inferred,
                remainsProvisional: false
            ),
            readiness: GoalUnderstandingReadinessInterpretation(
                decision: .safeToProceedWithAssumptions,
                safeToCompile: true,
                hasBlockingIssues: false,
                blockingFields: []
            ),
            constraints: [],
            dependencies: [],
            risks: [],
            assumptions: [
                GoalUnderstandingAssumption(
                    id: "assumption-1",
                    summary: "Use a starter-safe assumption.",
                    rationale: "Starter planning remains narrow.",
                    confidence: .medium,
                    source: .derivedContract,
                    relatedField: .successDefinition,
                    safeForCompilation: true
                )
            ],
            clarification: GoalUnderstandingClarificationCarryForward(
                analysis: analysis,
                unresolvedQuestions: [],
                missingContext: [],
                contradictions: [],
                alternateInterpretationsActive: false
            ),
            confidence: GoalUnderstandingConfidenceMetadata(
                overall: .medium,
                score: 0.6,
                uncertaintyTags: []
            ),
            audit: GoalUnderstandingAuditMetadata(evidence: [])
        )
    }

    func makeCompiledPath(
        requirementBlocking: Bool,
        resourceOptionality: GoalCompiledPathResourceOptionality
    ) -> GoalCompiledPath {
        let candidate = GoalCompiledPathCandidate(
            id: "candidate-1",
            title: "Primary candidate",
            summary: "Primary path",
            isPrimary: true,
            posture: requirementBlocking ? .blocked : .provisional,
            safeForStarterPlanning: true,
            stages: [
                GoalCompiledPathStage(
                    id: "stage-1",
                    title: "Prepare",
                    summary: "Get ready",
                    orderIndex: 0,
                    kind: .readiness,
                    dependencyIDs: [],
                    prerequisiteHints: [],
                    readinessHints: [],
                    uncertainBecause: []
                )
            ],
            dependencies: [],
            branches: [],
            assumptions: [
                GoalCompiledPathAssumption(
                    id: "assumption-1",
                    summary: "Assume starter-safe prep is enough.",
                    rationale: "Starter planning remains narrow.",
                    confidence: .medium,
                    source: .derivedContract,
                    relatedField: .successDefinition,
                    safeForCompilation: true
                )
            ],
            risks: [],
            appliedPacks: [],
            requirementHints: [
                GoalCompiledPathRequirementHint(
                    id: "requirement-1",
                    summary: "A required support artifact is needed.",
                    kind: .externalRequirement,
                    relatedField: .successDefinition,
                    relatedStageID: "stage-1",
                    blocking: requirementBlocking
                )
            ],
            readinessCriteria: [
                GoalCompiledPathReadinessCriterion(
                    id: "readiness-1",
                    summary: "Readiness requires a concrete support artifact.",
                    kind: .confirmation,
                    targetStageID: "stage-1",
                    token: "readiness-token-1",
                    blocking: requirementBlocking
                )
            ],
            resourceHooks: [
                GoalCompiledPathResourceHook(
                    id: "hook-1",
                    summary: "Supporting artifact",
                    kind: .requirementReference,
                    targetStageID: "stage-1",
                    relatedDomains: [.career],
                    sourceClaimIDs: [],
                    sourceRecordIDs: [],
                    optionality: resourceOptionality,
                    placeholderState: .resourceNeeded
                )
            ],
            blockingReasons: requirementBlocking ? [
                GoalCompiledPathBlockingReason(id: "blocking-1", summary: "Blocking requirement active.", field: .successDefinition)
            ] : [],
            confidence: GoalCompiledPathConfidence(overall: .medium, score: 0.6, uncertaintyTags: [])
        )

        return GoalCompiledPath(
            schemaVersion: goalPathCompilerSchemaVersion,
            sourceUnderstandingSchemaVersion: goalUnderstandingSchemaVersion,
            overallPosture: candidate.posture,
            safeForStarterPlanning: candidate.safeForStarterPlanning,
            candidates: [candidate],
            uncertainty: GoalCompiledPathUncertainty(
                ambiguityActive: false,
                missingContextFields: [],
                unresolvedQuestionIDs: [],
                alternateInterpretationsActive: false,
                knowledgeContextAttached: false,
                knowledgeContextRequired: false
            ),
            audit: GoalCompiledPathAuditMetadata(entries: [])
        )
    }

    func makeResourceGraph(
        missingState: GoalResourceMissingState,
        optionality: GoalCompiledPathResourceOptionality,
        freshnessPosture: GoalFreshnessPosture,
        sourceRecordIDs: [String] = []
    ) -> GoalResourceGraph {
        let ranking = GoalResourceRankingMetadata(
            rank: 1,
            totalScore: 0.5,
            sourceTrustScore: 0.5,
            sourceFreshnessScore: 0.5,
            domainRelevanceScore: 0.5,
            stageRelevanceScore: 0.5,
            readinessRelevanceScore: 0.5,
            optionalityScore: optionality == .required ? 1 : 0.3,
            tieBreakKey: "resource-1",
            flags: []
        )
        let resource = GoalResourceEntity(
            id: "resource-1",
            candidateID: "candidate-1",
            targetStageID: "stage-1",
            hookID: "hook-1",
            selectionGroupID: "group-1",
            hookKind: .requirementReference,
            resourceType: .reference,
            resourceRole: .requirementSupport,
            resolutionState: missingState == .none ? .concrete : .placeholderOnly,
            originRelation: .knowledgeDerived,
            optionality: optionality,
            relatedDomains: [.career],
            appliedPackIDs: [],
            claimIDs: [],
            sourceRecordIDs: sourceRecordIDs,
            trustLevel: .high,
            freshnessState: freshnessPosture == .stale ? .stale : .fresh,
            uncertaintyFlags: [],
            missingResourceState: missingState,
            ranking: ranking
        )
        let impact = GoalResourceFreshnessImpact(
            resourceID: "resource-1",
            posture: freshnessPosture,
            updateNeeded: freshnessPosture != .currentEnough,
            severity: freshnessPosture == .stale ? .recommended : (freshnessPosture == .blockedMissingEvidence ? .blocked : .none),
            flags: freshnessPosture == .stale ? [.sourceStale] : (freshnessPosture == .blockedMissingEvidence ? [.missingFreshnessEvidence, .noConcreteResource] : []),
            lineage: [],
            rankingImpactScore: 0,
            rankingFlagsAdded: []
        )

        return GoalResourceGraph(
            schemaVersion: goalResourceGraphSchemaVersion,
            sourceCompiledPathSchemaVersion: goalPathCompilerSchemaVersion,
            overallPosture: .provisional,
            candidateGraphs: [
                GoalResourceGraphCandidate(
                    candidateID: "candidate-1",
                    isPrimary: true,
                    posture: .provisional,
                    stageIDs: ["stage-1"],
                    resourceIDs: ["resource-1"]
                )
            ],
            resources: [resource],
            sources: [],
            audit: GoalResourceGraphAuditMetadata(entries: []),
            freshness: GoalResourceGraphFreshnessMetadata(
                evaluatedAt: GoalEngineFixtures.fixedNow,
                overallPosture: freshnessPosture,
                updateNeeded: freshnessPosture != .currentEnough,
                maxSeverity: freshnessPosture == .stale ? .recommended : (freshnessPosture == .blockedMissingEvidence ? .blocked : .none),
                resourceImpacts: [impact],
                candidateSummaries: [
                    GoalPathCandidateFreshnessSummary(
                        candidateID: "candidate-1",
                        affectedResourceIDs: ["resource-1"],
                        posture: freshnessPosture,
                        updateNeeded: freshnessPosture != .currentEnough,
                        severity: freshnessPosture == .stale ? .recommended : (freshnessPosture == .blockedMissingEvidence ? .blocked : .none)
                    )
                ],
                lineage: []
            )
        )
    }

    func makeEnergyModel(score: Double, fitBand: EnergyFitBand, stepID: String) -> GoalEnergyModel {
        GoalEnergyModel(
            schemaVersion: goalEnergyFitSchemaVersion,
            sourceCompiledPathSchemaVersion: goalPathCompilerSchemaVersion,
            capacityContext: .assumedNeutral(),
            overallBand: fitBand,
            candidateSummaries: [],
            evaluations: [
                GoalEnergyFitEvaluation(
                    id: "energy-\(stepID)",
                    targetKind: .planStep,
                    targetID: stepID,
                    candidateID: "candidate-1",
                    stageID: "stage-1",
                    stepID: stepID,
                    workShape: .execution,
                    effortDemand: .moderate,
                    focusDemand: .moderate,
                    recoveryCompatibility: .neutral,
                    pacingPosture: .steady,
                    fitBand: fitBand,
                    score: score,
                    reasons: [
                        GoalEnergyFitReason(
                            code: .canonicalMetadata,
                            targetKind: .planStep,
                            targetID: stepID,
                            relatedStageKind: nil,
                            relatedStepType: .actionUnit,
                            impact: .positive,
                            summary: "Canonical energy metadata prefers this step."
                        )
                    ]
                )
            ],
            audit: GoalEnergyModelAuditMetadata(entries: [])
        )
    }

    func makePlanStep(id: String, state: StepLifecycleState, type: StepType) -> Step {
        Step(
            id: id,
            sectionID: "section-1",
            title: "Step \(id)",
            summary: nil,
            type: type,
            state: state,
            owner: GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true),
            timing: GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: "2026-08-31T12:00:00Z", targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7),
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["Done"],
            actionability: StepActionability(action: "Do it", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start", contextRequirements: [])
        )
    }

    func makeEvidence(id: String, stepID: String, kind: ProgressEvidenceKind) -> ProgressEvidence {
        ProgressEvidence(
            id: id,
            goalID: "goal-1",
            stepID: stepID,
            evidenceKind: kind,
            source: .manual,
            capturedAt: GoalEngineFixtures.fixedNow,
            progressDelta: 0.2,
            confidenceDelta: 0.1,
            minutesInvested: 20,
            note: nil
        )
    }

    func makeFeedbackBase(id: String, stepID: String) -> GoalFeedbackEventBase {
        GoalFeedbackEventBase(id: id, stepID: stepID, occurredAt: GoalEngineFixtures.fixedNow, note: nil)
    }

    func makeOrderingInput(shuffled: Bool = false) -> GoalContradictionAnalysisInput {
        let contradiction = GoalInputContradiction(
            code: .goalSubjectGap,
            reason: "The goal subject remains missing.",
            question: ClarificationQuestion(
                id: "goal-subject-gap",
                field: .goalSubject,
                prompt: "What is the actual goal?",
                rationale: "Starter planning still needs a concrete subject.",
                skipSafeDefault: "Clarify first."
            )
        )
        let evidence = [
            makeEvidence(id: "e1", stepID: "step-1", kind: .stepCompleted),
            makeEvidence(id: "e2", stepID: "step-1", kind: .stepCompleted),
            makeEvidence(id: "e3", stepID: "step-1", kind: .habitMinimumVersion)
        ]
        let feedback: [GoalFeedbackEvent] = [
            .notRelevant(base: makeFeedbackBase(id: "f1", stepID: "step-1")),
            .notRelevant(base: makeFeedbackBase(id: "f2", stepID: "step-1")),
            .notRelevant(base: makeFeedbackBase(id: "f3", stepID: "step-1"))
        ]

        return makeInput(
            clarification: makeClarification(contradictions: shuffled ? [contradiction].reversed() : [contradiction]),
            plannedSteps: [makePlanStep(id: "step-1", state: .blocked, type: .actionUnit)],
            evidence: shuffled ? Array(evidence.reversed()) : evidence,
            feedback: shuffled ? Array(feedback.reversed()) : feedback
        )
    }
}
