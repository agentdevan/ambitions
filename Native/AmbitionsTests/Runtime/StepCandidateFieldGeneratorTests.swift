import XCTest
@testable import Ambitions

final class StepCandidateFieldGeneratorTests: XCTestCase {
    func testGeneratorProducesMultipleRealCandidatesForTheSameGoal() throws {
        let context = try makeContext(
            goalText: "Draft the launch note and keep it local.",
            compilerOutput: makeCompilerOutput(
                goalText: "Draft the launch note and keep it local.",
                compiledSteps: [
                    makeCompiledStep(
                        id: "compiled-step-a",
                        title: "Draft launch note",
                        summary: "Write the draft launch note.",
                        orderIndex: 0,
                        targetDate: "2026-05-30T10:00:00Z"
                    )
                ]
            )
        )
        let field = StepCandidateFieldGenerator().generate(context)

        XCTAssertGreaterThan(field.candidates.count, 1)
        XCTAssertTrue(field.candidates.contains(where: { $0.kind == .directBest }))
        XCTAssertTrue(field.candidates.contains(where: { $0.kind == .lighter }))
        XCTAssertTrue(field.candidates.contains(where: { $0.kind == .shorter }))
        XCTAssertTrue(field.candidates.contains(where: { $0.kind == .lowerEnergy }))
        XCTAssertEqual(Set(field.candidateIDs).count, field.candidates.count)
        XCTAssertEqual(field.selectedCandidate?.id, field.rankingTrace.selectedCandidateID)
        XCTAssertFalse(field.rankingTrace.factorlessRanking)
    }

    func testGeneratorRejectsDuplicateCopyVariantsByStableSemanticSignature() throws {
        let context = try makeContext(
            goalText: "Draft the launch note and keep it local.",
            compilerOutput: makeCompilerOutput(
                goalText: "Draft the launch note and keep it local.",
                compiledSteps: [
                    makeCompiledStep(
                        id: "compiled-step-a",
                        title: "Draft launch note",
                        summary: "Write the draft launch note.",
                        orderIndex: 0,
                        targetDate: "2026-05-30T10:00:00Z"
                    ),
                    makeCompiledStep(
                        id: "compiled-step-b",
                        title: "Draft launch note now",
                        summary: "Write the draft launch note.",
                        orderIndex: 1,
                        targetDate: "2026-05-30T10:00:00Z"
                    )
                ]
            )
        )
        let field = StepCandidateFieldGenerator().generate(context)

        XCTAssertFalse(field.rankingTrace.duplicateRejectedCandidateIDs.isEmpty)
        XCTAssertEqual(field.candidates.map(\.normalizedSemanticSignature).count, Set(field.candidates.map(\.normalizedSemanticSignature)).count)
        XCTAssertLessThan(field.candidates.count, 2 * (StepCandidateKind.allCases.count - 1))
    }

    func testGeneratorIsDeterministicAndUsesFactorLedgerEvidence() throws {
        let context = try makeContext(
            goalText: "Draft the launch note and keep it local.",
            compilerOutput: makeCompilerOutput(
                goalText: "Draft the launch note and keep it local.",
                compiledSteps: [
                    makeCompiledStep(
                        id: "compiled-step-a",
                        title: "Draft launch note",
                        summary: "Write the draft launch note.",
                        orderIndex: 0,
                        targetDate: "2026-05-30T10:00:00Z"
                    )
                ]
            )
        )
        let generator = StepCandidateFieldGenerator()
        let first = generator.generate(context)
        let second = generator.generate(context)

        XCTAssertEqual(first, second)
        XCTAssertFalse(first.rankingTrace.factorEvidenceIDs.isEmpty)
        XCTAssertGreaterThan(first.selectedCandidate?.score.factorEvidenceScore ?? 0, 0)
        XCTAssertNotNil(first.rankingTrace.replayReferenceID)
        XCTAssertFalse(first.rankingTrace.replayFingerprint?.isEmpty ?? true)
    }

    func testGeneratorFallsBackGracefullyWhenContextIsMissing() throws {
        let context = CandidateGenerationContext(
            goalID: "goal.missing",
            generatedAt: "2026-05-22T18:13:20Z",
            candidateLimit: 8,
            localOnly: true
        )
        let field = StepCandidateFieldGenerator().generate(context)

        XCTAssertEqual(field.candidates.count, 1)
        XCTAssertEqual(field.selectedCandidate?.kind, .fallback)
        XCTAssertEqual(field.selectedCandidate?.validity, .fallback)
        XCTAssertTrue(field.rankingTrace.factorlessRanking)
        XCTAssertTrue(field.rankingTrace.semanticSummary.localizedCaseInsensitiveContains("fallback"))
    }

    func testGeneratorReconstructsFromReplayAndDoesNotLeakRawSensitiveContext() throws {
        let secret = "PRIVATE-RAW-TEXT-LEAK-MARKER"
        let goalText = "Draft the launch note and keep it local."
        let context = try makeContext(
            goalText: goalText,
            compilerOutput: makeCompilerOutput(
                goalText: goalText,
                compiledSteps: [
                    makeCompiledStep(
                        id: "compiled-step-a",
                        title: "Draft launch note",
                        summary: "Write the draft launch note.",
                        orderIndex: 0,
                        targetDate: "2026-05-30T10:00:00Z"
                    )
                ]
            ),
            secretTraceSummary: secret
        )

        let field = StepCandidateFieldGenerator().generate(context)
        let encoded = try JSONEncoder().encode(field)
        let encodedString = String(decoding: encoded, as: UTF8.self)

        XCTAssertEqual(field.rankingTrace.replayReferenceID, context.replayTrace?.id)
        XCTAssertEqual(field.rankingTrace.replayFingerprint, context.replayTrace?.personalizationFactorLedger.replayProjection.stableFingerprint)
        XCTAssertFalse(encodedString.contains(secret))
        XCTAssertFalse(field.rankingTrace.semanticSummary.contains(secret))
        XCTAssertFalse(field.selectedCandidate?.impactSimulation.summary.contains(secret) ?? false)
    }

    func testGeneratorSuppressesRejectedCandidateAndRebalancesRanking() throws {
        let context = try makeContext(
            goalText: "Draft the launch note and keep it local.",
            compilerOutput: makeCompilerOutput(
                goalText: "Draft the launch note and keep it local.",
                compiledSteps: [
                    makeCompiledStep(
                        id: "compiled-step-a",
                        title: "Draft launch note",
                        summary: "Write the draft launch note.",
                        orderIndex: 0,
                        targetDate: "2026-05-30T10:00:00Z"
                    )
                ]
            )
        )
        let baseline = StepCandidateFieldGenerator().generate(context)
        let rejectedCandidateID = try XCTUnwrap(baseline.selectedCandidate?.id)
        let rejectedRecord = StepCandidateRejectionRecord(
            candidateID: rejectedCandidateID,
            sourceCandidateID: baseline.selectedCandidate?.sourceCandidateID,
            sourceStepID: try XCTUnwrap(baseline.selectedCandidate?.sourceStepID),
            contextFingerprint: context.contextFingerprint,
            reason: StepCandidateRejectionReason(code: .tooLong),
            skippedReason: false,
            recordedAt: "2026-05-22T18:13:20Z"
        )
        let rebasedContext = CandidateGenerationContext(
            goalID: context.goalID,
            deadlineTargetDate: context.deadlineTargetDate,
            compilerOutput: context.compilerOutput,
            runtimeOutput: context.runtimeOutput,
            decisionRecord: context.decisionRecord,
            replayTrace: context.replayTrace,
            factorLedger: context.factorLedger,
            lifeContextProjection: context.lifeContextProjection,
            rejectionHistory: [rejectedRecord],
            generatedAt: context.generatedAt,
            candidateLimit: context.candidateLimit,
            localOnly: context.localOnly
        )
        let rebased = StepCandidateFieldGenerator().generate(rebasedContext)

        XCTAssertFalse(rebased.candidateIDs.contains(rejectedCandidateID))
        XCTAssertTrue(rebased.rankingTrace.suppressedRejectedCandidateIDs.contains(rejectedCandidateID))
        XCTAssertNotEqual(rebased.selectedCandidate?.id, baseline.selectedCandidate?.id)
        XCTAssertGreaterThan(rebased.selectedCandidate?.score.rejectionFitScore ?? 0, 0)
        XCTAssertEqual(rebased, StepCandidateFieldGenerator().generate(rebasedContext))
    }

    func testGeneratorKeepsSensitiveCustomRejectionTextOutOfTraces() throws {
        let secret = "PRIVATE-CUSTOM-REASON-LEAK-MARKER"
        let context = try makeContext(
            goalText: "Draft the launch note and keep it local.",
            compilerOutput: makeCompilerOutput(
                goalText: "Draft the launch note and keep it local.",
                compiledSteps: [
                    makeCompiledStep(
                        id: "compiled-step-a",
                        title: "Draft launch note",
                        summary: "Write the draft launch note.",
                        orderIndex: 0,
                        targetDate: "2026-05-30T10:00:00Z"
                    )
                ]
            ),
            rejectionHistory: [
                StepCandidateRejectionRecord(
                    candidateID: "step-candidate.leak-test",
                    sourceCandidateID: "step-candidate.leak-test-source",
                    sourceStepID: "compiled-step-a",
                    contextFingerprint: "step-candidate-context.leak-test",
                    reason: StepCandidateRejectionReason(code: .custom, customText: secret),
                    skippedReason: true,
                    recordedAt: "2026-05-22T18:13:20Z"
                )
            ]
        )

        let field = StepCandidateFieldGenerator().generate(context)
        let encoded = try JSONEncoder().encode(field)
        let encodedString = String(decoding: encoded, as: UTF8.self)

        XCTAssertFalse(encodedString.contains(secret))
        XCTAssertFalse(field.rankingTrace.semanticSummary.contains(secret))
        XCTAssertFalse(field.rankingTrace.rejectedCandidateIDs.contains(where: { $0.contains("leak-test") }))
    }

    func testLighterAlternativeIncreasesFuturePressureAndCompressesTimeline() throws {
        let context = try makeContext(
            goalText: "Draft the launch note and keep it local.",
            compilerOutput: makeCompilerOutput(
                goalText: "Draft the launch note and keep it local.",
                compiledSteps: [
                    makeCompiledStep(
                        id: "compiled-step-a",
                        title: "Draft launch note",
                        summary: "Write the draft launch note.",
                        orderIndex: 0,
                        targetDate: "2026-05-30T10:00:00Z"
                    )
                ]
            )
        )
        let field = StepCandidateFieldGenerator().generate(context)
        let directBest = try XCTUnwrap(field.candidates.first(where: { $0.kind == .directBest }))
        let lighter = try XCTUnwrap(field.candidates.first(where: { $0.kind == .lighter }))

        XCTAssertEqual(lighter.impactSimulation.candidateID, lighter.id)
        XCTAssertLessThan(lighter.impactSimulation.goalTimeline.futurePressureImpact, directBest.impactSimulation.goalTimeline.futurePressureImpact)
        XCTAssertEqual(lighter.impactSimulation.deadlinePressureDelta, .compressed)
        XCTAssertEqual(lighter.impactSimulation.goalTimeline.compression.summary, "This makes the deadline tighter.")
        XCTAssertTrue(lighter.impactSimulation.summary.contains("lighter"))
    }

    func testCriticalSkipTriggersDeadlineReview() throws {
        let context = try makeContext(
            goalText: "Draft the launch note and keep it local.",
            compilerOutput: makeCompilerOutput(
                goalText: "Draft the launch note and keep it local.",
                compiledSteps: [
                    makeCompiledStep(
                        id: "compiled-step-a",
                        title: "Draft launch note",
                        summary: "Write the draft launch note.",
                        orderIndex: 0,
                        targetDate: "2026-05-23T18:30:00Z"
                    )
                ]
            )
        )
        let baseline = StepCandidateFieldGenerator().generate(context)
        let rejectedCandidateID = try XCTUnwrap(baseline.selectedCandidate?.id)
        let rejectedRecord = StepCandidateRejectionRecord(
            candidateID: rejectedCandidateID,
            sourceCandidateID: baseline.selectedCandidate?.sourceCandidateID,
            sourceStepID: try XCTUnwrap(baseline.selectedCandidate?.sourceStepID),
            contextFingerprint: context.contextFingerprint,
            reason: StepCandidateRejectionReason(code: .notEnoughTime),
            skippedReason: false,
            recordedAt: "2026-05-22T18:13:20Z"
        )
        let rejectedContext = CandidateGenerationContext(
            goalID: context.goalID,
            deadlineTargetDate: context.deadlineTargetDate,
            compilerOutput: context.compilerOutput,
            runtimeOutput: context.runtimeOutput,
            decisionRecord: context.decisionRecord,
            replayTrace: context.replayTrace,
            factorLedger: context.factorLedger,
            lifeContextProjection: context.lifeContextProjection,
            rejectionHistory: [rejectedRecord],
            generatedAt: context.generatedAt,
            candidateLimit: context.candidateLimit,
            localOnly: context.localOnly
        )
        let field = StepCandidateFieldGenerator().generate(rejectedContext)
        let selected = try XCTUnwrap(field.selectedCandidate)

        XCTAssertNotEqual(selected.kind, .directBest)
        XCTAssertTrue(selected.impactSimulation.goalTimeline.planRisk.requiresDeadlineReview)
        XCTAssertTrue(selected.impactSimulation.goalTimeline.delay.isDelayed || selected.impactSimulation.goalTimeline.planRisk.deadlinePressureDelta == .requiresDeadlineReview)
        XCTAssertTrue(selected.impactSimulation.goalTimeline.summary.contains("deadline"))
    }

    func testEquivalentAlternativesPreserveTimeline() throws {
        let context = try makeContext(
            goalText: "Draft the launch note and keep it local.",
            compilerOutput: makeCompilerOutput(
                goalText: "Draft the launch note and keep it local.",
                compiledSteps: [
                    makeCompiledStep(
                        id: "compiled-step-a",
                        title: "Draft launch note",
                        summary: "Write the draft launch note.",
                        orderIndex: 0,
                        targetDate: "2026-05-30T10:00:00Z"
                    )
                ]
            )
        )
        let field = StepCandidateFieldGenerator().generate(context)
        let directBest = try XCTUnwrap(field.candidates.first(where: { $0.kind == .directBest }))
        let parallelPath = try XCTUnwrap(field.candidates.first(where: { $0.kind == .parallelPath }))

        XCTAssertEqual(directBest.impactSimulation.goalTimeline.planRisk.feasibilityBand, parallelPath.impactSimulation.goalTimeline.planRisk.feasibilityBand)
        XCTAssertEqual(directBest.impactSimulation.deadlinePressureDelta, .preserved)
        XCTAssertEqual(parallelPath.impactSimulation.deadlinePressureDelta, .preserved)
    }

    func testImpossibleTimelineIsSurfacedHonestly() throws {
        let context = try makeContext(
            goalText: "Draft the launch note and keep it local.",
            compilerOutput: makeCompilerOutput(
                goalText: "Draft the launch note and keep it local.",
                compiledSteps: [
                    makeCompiledStep(
                        id: "compiled-step-a",
                        title: "Draft launch note",
                        summary: "Write the draft launch note.",
                        orderIndex: 0,
                        targetDate: "2026-05-23T18:30:00Z",
                        isExecutable: false
                    )
                ],
                capacityEnvelope: makeCapacityEnvelope(openWindowCount: 0, protectedWindowCount: 1)
            )
        )
        let field = StepCandidateFieldGenerator().generate(context)

        XCTAssertTrue(field.candidates.allSatisfy { $0.impactSimulation.goalTimeline.planRisk.isImpossible })
        XCTAssertTrue(field.candidates.allSatisfy { $0.impactSimulation.goalTimeline.planRisk.feasibilityBand == .impossibleUnderCurrentConstraints })
        XCTAssertTrue(field.candidates.allSatisfy { $0.impactSimulation.goalTimeline.onTrack.isOnTrack == false })
    }

    func testProtectedTimeThreatIsSurfaced() throws {
        let context = try makeContext(
            goalText: "Draft the launch note and keep it local.",
            compilerOutput: makeCompilerOutput(
                goalText: "Draft the launch note and keep it local.",
                compiledSteps: [
                    makeCompiledStep(
                        id: "compiled-step-a",
                        title: "Draft launch note",
                        summary: "Write the draft launch note.",
                        orderIndex: 0,
                        targetDate: "2026-05-30T10:00:00Z"
                    )
                ],
                capacityEnvelope: makeCapacityEnvelope(openWindowCount: 0, protectedWindowCount: 1)
            )
        )
        let field = StepCandidateFieldGenerator().generate(context)
        let selected = try XCTUnwrap(field.selectedCandidate)

        XCTAssertTrue(selected.impactSimulation.goalTimeline.planRisk.threatensProtectedTime)
        XCTAssertEqual(selected.impactSimulation.deadlinePressureDelta, .threatensProtectedTime)
        XCTAssertTrue(selected.impactSimulation.goalTimeline.planRisk.summary.contains("protected time"))
    }
}

private extension StepCandidateFieldGeneratorTests {
    func makeContext(
        goalText: String,
        compilerOutput: GoalIntentDayCompilerOutput,
        secretTraceSummary: String? = nil,
        rejectionHistory: [StepCandidateRejectionRecord] = []
    ) throws -> CandidateGenerationContext {
        let fixedNow = try XCTUnwrap(DomainTimestamp.date(from: "2026-05-22T18:13:20Z"))
        let bundle = makeLifeContextBundle()
        let projection = bundle.projection(asOf: fixedNow)
        let recommendationTrace = makeRecommendationTrace(secretTraceSummary: secretTraceSummary)
        let kernel = PrivateLifeRuntimeKernel()
        let input = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: PrivateLifeRuntimeKernelTraceContext(
                runtimeContext: makeRuntimeContext(),
                lifeContextProjection: projection,
                goalText: goalText
            ),
            decisionKey: "today.start-here",
            goalText: goalText,
            recommendationTrace: recommendationTrace
        )
        let runtimeOutput = kernel.evaluate(input)
        let replayTrace = kernel.makeReplayableDecisionTrace(input)

        return CandidateGenerationContext(
            goalID: compilerOutput.intent.id,
            deadlineTargetDate: compilerOutput.compiledSteps.compactMap(\.targetDate).first,
            compilerOutput: compilerOutput,
            runtimeOutput: runtimeOutput,
            decisionRecord: kernel.makeDecisionRecord(input),
            replayTrace: replayTrace,
            factorLedger: runtimeOutput.personalizationFactorLedger,
            lifeContextProjection: projection,
            rejectionHistory: rejectionHistory,
            generatedAt: "2026-05-22T18:13:20Z",
            candidateLimit: 24,
            localOnly: true
        )
    }

    func makeCompilerOutput(goalText: String, compiledSteps: [CompiledStep]) -> GoalIntentDayCompilerOutput {
        makeCompilerOutput(goalText: goalText, compiledSteps: compiledSteps, capacityEnvelope: makeCapacityEnvelope(openWindowCount: 1, protectedWindowCount: 0))
    }

    func makeCompilerOutput(
        goalText: String,
        compiledSteps: [CompiledStep],
        capacityEnvelope: GoalIntentCapacityEnvelope
    ) -> GoalIntentDayCompilerOutput {
        let intent = GoalIntent(
            id: "goal.intent.launch",
            rawStatement: goalText,
            createdAt: "2026-05-22T18:13:20Z",
            sourceSurface: .today,
            privacyClass: .localOnly,
            sourceState: .draft
        )

        return GoalIntentDayCompilerOutput(
            intent: intent,
            compiledAt: "2026-05-22T18:13:20Z",
            status: .clear,
            assumptions: [],
            clarification: GoalIntentClarification(
                status: .clear,
                readiness: .readyForPlanning,
                questions: [],
                missingFields: []
            ),
            blockedReasons: [],
            capacityEnvelope: capacityEnvelope,
            compiledSteps: compiledSteps,
            receipts: [],
            localOnly: true
        )
    }

    func makeCapacityEnvelope(
        openWindowCount: Int,
        protectedWindowCount: Int,
        capacityLevel: EnergyCapacityLevel = .moderate,
        recoveryState: EnergyRecoveryState = .steady
    ) -> GoalIntentCapacityEnvelope {
        let openWindows = (0..<openWindowCount).map { index in
            GoalIntentCapacityWindow(
                id: "window.open.\(index)",
                title: "Open window \(index)",
                summary: "An open window is available.",
                availableMinutes: 30,
                isProtected: false
            )
        }
        let protectedWindows = (0..<protectedWindowCount).map { index in
            GoalIntentCapacityWindow(
                id: "window.protected.\(index)",
                title: "Protected window \(index)",
                summary: "Protected time is reserved.",
                availableMinutes: 30,
                isProtected: true
            )
        }
        return GoalIntentCapacityEnvelope(
            capacityLevel: capacityLevel,
            recoveryState: recoveryState,
            availableWindows: openWindows + protectedWindows
        )
    }

    func makeCompiledStep(
        id: String,
        title: String,
        summary: String,
        orderIndex: Int,
        targetDate: String,
        isExecutable: Bool = true
    ) -> CompiledStep {
        CompiledStep(
            id: id,
            intentID: "goal.intent.launch",
            title: title,
            summary: summary,
            orderIndex: orderIndex,
            stepType: .actionUnit,
            pace: .untimed,
            targetDate: targetDate,
            evidenceHint: "Draft the launch note.",
            contextRequirements: ["Keep it local."],
            isOptional: false,
            isExecutable: isExecutable
        )
    }

    func makeLifeContextBundle() -> LifeContextBundle {
        let profile = LifeContextProfile(
            id: "profile.launch",
            exactAgeYears: 29,
            timezone: "America/New_York",
            locale: "en_US",
            generalLocationLabel: "Metro area",
            locationPrecision: .cityRegion,
            lifeStage: .adult,
            schoolOrWorkContext: "Launch work",
            travelRadiusMinutes: 30,
            travelRadiusMiles: 12,
            transportationAccess: .car,
            scheduleAnchors: ["morning block"],
            dependencyConstraints: [],
            budgetConstraintBand: .flexible,
            energyPattern: .morning,
            recoveryConstraints: ["Keep the first pass gentle."],
            accessibilityNeeds: [],
            userNotes: "Stable local-first launch context."
        )

        return LifeContextBundle(
            id: "bundle.launch",
            profile: profile,
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "path.launch",
                    pathwayType: .career,
                    eligibilityRulesSummary: "Local launch work can progress today.",
                    locationDependent: false,
                    source: LifeContextSource(
                        id: "source.launch",
                        label: "Interview",
                        kind: .userConfirmed,
                        timestamp: "2026-05-22T18:13:20Z",
                        visibleExplanation: "Seeded locally."
                    ),
                    freshness: .current,
                    userConfirmed: true
                )
            ],
            opportunityContexts: [
                OpportunityContext(
                    id: "opportunity.launch",
                    facilities: [.home, .library],
                    equipmentAccess: ["laptop"],
                    localOrganizations: ["Local studio"],
                    verificationStatus: .verified
                )
            ],
            historicalFacts: [
                HistoricalContextFact(
                    id: "fact.launch.success",
                    category: .pastAchievement,
                    title: "Recent successful draft",
                    detail: "Short drafts have worked before.",
                    confidence: 0.9,
                    sourceType: .userToldAmbitions,
                    freshness: .current,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.feasibility, .sequencing],
                    createdAt: "2026-05-22T18:13:20Z",
                    updatedAt: "2026-05-22T18:13:20Z"
                )
            ],
            sources: [
                LifeContextSource(
                    id: "source.launch.2",
                    label: "Local interview",
                    kind: .userConfirmed,
                    timestamp: "2026-05-22T18:13:20Z",
                    visibleExplanation: "Current local context."
                )
            ],
            createdAt: "2026-05-22T18:13:20Z",
            updatedAt: "2026-05-22T18:13:20Z"
        )
    }

    func makeRuntimeContext() -> RuntimeContextSnapshot {
        let memory = RuntimeMemorySnapshot(
            goals: [],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            appState: AppStateSnapshot.default
        )
        return RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Ambitions is running in explicit local-only mode."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "local-only",
                        type: .systemFallback,
                        displayName: "Local-only fallback"
                    ),
                    availability: .localOnlyMode,
                    detail: "Knowledge retrieval is unavailable while Ambitions remains local-only.",
                    runtimeTrustPosture: .localOnly
                )
            ],
            memorySummary: RuntimeMemorySummary(memory: memory),
            externalSurfaceSnapshot: nil
        )
    }

    func makeRecommendationTrace(secretTraceSummary: String? = nil) -> RecommendationTrace {
        RecommendationTrace(
            id: "trace.launch",
            recommendationID: "decision.launch",
            source: RecommendationTraceSource(
                citedSourceIDs: ["source.launch"],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.goalState, .captureState],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "why-now.launch",
                summary: secretTraceSummary ?? "Local runtime data supports this decision.",
                evidenceCategoryIDs: [RecommendationExplanationEvidenceCategory.goalState.rawValue]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.launch"],
                summaries: [secretTraceSummary ?? "The recommendation remains revisable."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["control.launch"],
                controlActionIDs: ["open_step"],
                correctableFieldKeys: ["goalID"],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(
                receiptIDs: ["receipt.launch"],
                proofReferenceIDs: ["proof.launch"]
            )
        )
    }
}
