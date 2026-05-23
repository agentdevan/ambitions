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
    }
}

private extension StepCandidateFieldGeneratorTests {
    func makeContext(
        goalText: String,
        compilerOutput: GoalIntentDayCompilerOutput,
        secretTraceSummary: String? = nil
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
            generatedAt: "2026-05-22T18:13:20Z",
            candidateLimit: 24,
            localOnly: true
        )
    }

    func makeCompilerOutput(goalText: String, compiledSteps: [CompiledStep]) -> GoalIntentDayCompilerOutput {
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
            capacityEnvelope: GoalIntentCapacityEnvelope(
                capacityLevel: .moderate,
                recoveryState: .steady,
                availableWindows: [
                    GoalIntentCapacityWindow(
                        id: "window.open",
                        title: "Open window",
                        summary: "A review-safe window is available.",
                        availableMinutes: 30,
                        isProtected: false
                    )
                ]
            ),
            compiledSteps: compiledSteps,
            receipts: [],
            localOnly: true
        )
    }

    func makeCompiledStep(
        id: String,
        title: String,
        summary: String,
        orderIndex: Int,
        targetDate: String
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
            isExecutable: true
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
