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

    func testGeneratorCarriesSourceAtlasExpansionTraceThroughRankingMetadata() throws {
        let candidate = makeCandidate(
            sourceStepID: "source-atlas-step-a",
            title: "Practice proof",
            summary: "Gather proof before the path expands."
        )
        let sourceAtlasExpansionTrace = SourceAtlasStepExpansionTrace(
            sourceStepCandidateSeeds: [
                SourceAtlasStepCandidateSeedTrace(
                    id: "source-atlas.seed.1",
                    sourcePackID: "pack.varsity",
                    sourcePathID: "path.field.access",
                    sourcePathOverlayIDs: ["path.field.access"],
                    sourceNodeIDs: ["node.field.practice"],
                    sourceRequirementIDs: ["requirement.proof.video"],
                    sourceProofRequirementIDs: ["requirement.proof.video"],
                    sourceStarterItemIDs: ["starter.varsity"],
                    seedKind: "proof",
                    seedText: "Practice proof",
                    sourceRecordIDs: ["source.varsity.1"],
                    sourceClaimIDs: ["claim.varsity.1"],
                    freshnessWarnings: ["Freshness warning"],
                    sensitiveContextRedactions: ["[redacted]"]
                )
            ],
            expandedCandidates: [
                SourceAtlasStepExpansionCandidateTrace(
                    id: candidate.id,
                    sourceSeedID: "source-atlas.seed.1",
                    candidateID: candidate.id,
                    sourcePackID: "pack.varsity",
                    sourcePathID: "path.field.access",
                    sourcePathOverlayIDs: ["path.field.access"],
                    sourceNodeIDs: ["node.field.practice"],
                    sourceRequirementIDs: ["requirement.proof.video"],
                    sourceProofRequirementIDs: ["requirement.proof.video"],
                    sourceStarterItemIDs: ["starter.varsity"],
                    candidateKindRawValue: candidate.kind.rawValue,
                    candidateSourceRawValue: candidate.source.rawValue,
                    title: candidate.title,
                    summary: candidate.summary,
                    deadlineProtecting: true,
                    sourceRecordIDs: ["source.varsity.1"],
                    sourceClaimIDs: ["claim.varsity.1"]
                )
            ],
            rejectedSeeds: [],
            expansionRules: ["Selected path nodes become direct candidates."],
            personalizationFactorsUsed: ["goal_requirement"],
            freshnessWarnings: ["Freshness warning"],
            sensitiveContextRedactions: ["[redacted]"]
        )
        let context = try makeContext(
            goalText: "Draft the launch note and keep it local.",
            compilerOutput: makeCompilerOutput(
                goalText: "Draft the launch note and keep it local.",
                compiledSteps: [
                    makeCompiledStep(
                        id: "source-atlas-step-a",
                        title: "Practice proof",
                        summary: "Gather proof before the path expands.",
                        orderIndex: 0,
                        targetDate: "2026-05-30T10:00:00Z"
                    )
                ]
            ),
            sourceAtlasExpansionTrace: sourceAtlasExpansionTrace
        )
        let field = StepCandidateFieldGenerator().generate(context)

        XCTAssertEqual(field.sourceAtlasExpansionTrace, sourceAtlasExpansionTrace)
        XCTAssertEqual(field.rankingTrace.sourceAtlasExpansionTrace, sourceAtlasExpansionTrace)
        XCTAssertTrue(field.sourceProvenance.contains(CandidateSource.sourceAtlasPathComposition))
        XCTAssertTrue(field.sourceProvenance.contains(CandidateSource.sourceAtlasPack))
        XCTAssertTrue(field.sourceProvenance.contains(CandidateSource.sourceAtlasStepCandidateSeed))
        XCTAssertEqual(field.sourceAtlasExpansionTrace?.expandedCandidates.first?.candidateID, candidate.id)
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
        let approvalCandidate = try XCTUnwrap(field.candidates.first(where: { $0.approvalRequired }))

        XCTAssertNotEqual(selected.kind, .directBest)
        XCTAssertTrue(approvalCandidate.approvalRequired)
        XCTAssertTrue(approvalCandidate.impactSimulation.goalTimeline.planRisk.requiresDeadlineReview || approvalCandidate.impactSimulation.goalTimeline.planRisk.requiresScopeReview)
        XCTAssertTrue(approvalCandidate.impactSimulation.goalTimeline.delay.isDelayed || approvalCandidate.impactSimulation.goalTimeline.planRisk.deadlinePressureDelta == .requiresDeadlineReview || approvalCandidate.impactSimulation.goalTimeline.planRisk.deadlinePressureDelta == .requiresScopeReview)
        XCTAssertTrue(approvalCandidate.impactSimulation.goalTimeline.summary.contains("deadline") || approvalCandidate.impactSimulation.goalTimeline.summary.contains("scope"))
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

    func testSimulationGauntletCoversDeterministicScenarioMatrixAndWritesProofReport() throws {
        let result = try StepCandidateSimulationGauntletHarness().run()
        try result.writeReport()
        print("GAUNTLET_REPORT_URL: \(result.reportURL.path)")

        XCTAssertEqual(result.scenarioCount, 500)
        XCTAssertEqual(result.goalArchetypesCovered.count, 25)
        XCTAssertEqual(result.contextProfilesCovered.count, 10)
        XCTAssertEqual(result.scheduleRealitiesCovered.count, 10)
        XCTAssertEqual(result.rejectionReasonsCovered.count, 10)
        XCTAssertEqual(result.deadlinePressureLevelsCovered.count, 5)
        XCTAssertEqual(result.accessStatesCovered.count, 5)
        XCTAssertEqual(result.historicalStatesCovered.count, 5)
        XCTAssertEqual(result.replayDeterministicCount, result.scenarioCount)
        XCTAssertEqual(result.acceptedAlternativeReceiptCount, result.scenarioCount)
        XCTAssertEqual(result.privacyScanPassCount, result.scenarioCount)
        XCTAssertEqual(result.multiCandidateScenarioCount, result.scenarioCount)
        XCTAssertGreaterThan(result.impossibleScenarioCount, 0)
        XCTAssertTrue(result.failures.isEmpty, result.failureSummary)
        XCTAssertTrue(result.report.contains("STATUS: GREEN"))
        XCTAssertTrue(result.report.contains("Privacy scan: passed"))
        XCTAssertTrue(result.report.contains("iOS 26 API note"))
        XCTAssertFalse(result.report.contains("PRIVATE-"))
    }
}

private struct StepCandidateSimulationGauntletHarness {
    private let fixedNowString = "2026-05-22T18:13:20Z"
    private let fixedNowDate = DomainTimestamp.date(from: "2026-05-22T18:13:20Z")!
    private let generator = StepCandidateFieldGenerator()
    private let kernel = PrivateLifeRuntimeKernel()
    private let reportURL: URL = {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("build/reports/step-optionality/simulation-gauntlet.md")
    }()

    func run() throws -> StepCandidateSimulationGauntletResult {
        var failures: [GauntletFailure] = []
        var goalArchetypesCovered = Set<String>()
        var contextProfilesCovered = Set<String>()
        var scheduleRealitiesCovered = Set<String>()
        var rejectionReasonsCovered = Set<String>()
        var deadlinePressureLevelsCovered = Set<String>()
        var accessStatesCovered = Set<String>()
        var historicalStatesCovered = Set<String>()
        var pressureSurfaceCounts: [String: Int] = [:]
        var impossibleScenarioCount = 0
        var replayDeterministicCount = 0
        var acceptedAlternativeReceiptCount = 0
        var privacyScanPassCount = 0
        var totalCandidateCount = 0
        var multiCandidateScenarioCount = 0
        var scenarioCount = 0

        let goals = goalArchetypes
        let profiles = contextProfiles
        let schedules = scheduleRealities
        let rejectionReasons = rejectionReasonFixtures
        let accessStates = accessFixtures
        let historicalStates = historicalFixtures

        for (goalIndex, goal) in goals.enumerated() {
            for (profileIndex, profile) in profiles.enumerated() {
                for pass in 0..<2 {
                    let scenarioIndex = (goalIndex * profiles.count * 2) + (profileIndex * 2) + pass
                    let schedule = schedules[scenarioIndex % schedules.count]
                    let access = accessStates[scenarioIndex % accessStates.count]
                    let history = historicalStates[scenarioIndex % historicalStates.count]
                    let rejectionReason = rejectionReasons[scenarioIndex % rejectionReasons.count]

                    scenarioCount += 1
                    goalArchetypesCovered.insert(goal.id)
                    contextProfilesCovered.insert(profile.id)
                    scheduleRealitiesCovered.insert(schedule.id)
                    rejectionReasonsCovered.insert(rejectionReason.code.rawValue)
                    deadlinePressureLevelsCovered.insert(schedule.pressureLevel.rawValue)
                    accessStatesCovered.insert(access.id)
                    historicalStatesCovered.insert(history.id)

                    let scenarioID = "scenario.\(goal.id).\(profile.id).\(schedule.id).\(pass)"
                    let contextBundle = makeContextBundle(
                        goal: goal,
                        profile: profile,
                        access: access,
                        history: history,
                        schedule: schedule,
                        scenarioID: scenarioID
                    )
                    let projection = contextBundle.projection(asOf: fixedNowDate)
                    let recommendationTrace = makeRecommendationTrace(
                        scenarioID: scenarioID,
                        goal: goal,
                        profile: profile,
                        access: access,
                        history: history
                    )
                    let traceContext = PrivateLifeRuntimeKernelTraceContext(
                        runtimeContext: makeRuntimeContext(),
                        lifeContextProjection: projection,
                        goalText: goal.goalText
                    )
                    let input = PrivateLifeRuntimeKernelDecisionInput(
                        traceContext: traceContext,
                        decisionKey: "step.optional.\(scenarioID)",
                        goalText: goal.goalText,
                        recommendationTrace: recommendationTrace
                    )
                    let decisionOutput = kernel.evaluate(input)
                    let decisionRecord = try XCTUnwrap(kernel.makeDecisionRecord(input))
                    let replayTrace = kernel.makeReplayableDecisionTrace(input)
                    let factorLedger = decisionOutput.personalizationFactorLedger

                    let compilerOutput = makeCompilerOutput(
                        goal: goal,
                        schedule: schedule,
                        access: access,
                        scenarioID: scenarioID
                    )

                    let context = CandidateGenerationContext(
                        goalID: goal.id,
                        deadlineTargetDate: schedule.deadlineTargetDate,
                        compilerOutput: compilerOutput,
                        runtimeOutput: decisionOutput,
                        decisionRecord: decisionRecord,
                        replayTrace: replayTrace,
                        factorLedger: factorLedger,
                        lifeContextProjection: projection,
                        rejectionHistory: [],
                        generatedAt: fixedNowString,
                        candidateLimit: 24,
                        localOnly: true
                    )

                    let baseField = generator.generate(context)
                    let replayField = generator.generate(context)

                    totalCandidateCount += baseField.candidates.count
                    if baseField.candidates.count > 1 {
                        multiCandidateScenarioCount += 1
                    }

                    if baseField == replayField {
                        replayDeterministicCount += 1
                    } else {
                        failures.append(.init(
                            scenarioID: scenarioID,
                            message: "Replay was not deterministic for the same local input."
                        ))
                    }

                    if decisionRecord.receiptBehavior.state == .receiptAvailable {
                        acceptedAlternativeReceiptCount += 1
                    } else {
                        failures.append(.init(
                            scenarioID: scenarioID,
                            message: "Accepted alternative did not carry local receipt evidence."
                        ))
                    }

                    if baseField.candidates.count <= 1 {
                        failures.append(.init(
                            scenarioID: scenarioID,
                            message: "Generator returned fewer than two candidates."
                        ))
                    }

                    if baseField.rankingTrace.factorlessRanking {
                        failures.append(.init(
                            scenarioID: scenarioID,
                            message: "Factorless recommendation surfaced in a scenario with available evidence."
                        ))
                    }

                    let selectedCandidate = baseField.selectedCandidate
                    if let selectedCandidate {
                        if selectedCandidate.impactSimulation.candidateID != selectedCandidate.id {
                            failures.append(.init(
                                scenarioID: scenarioID,
                                message: "Impact simulation candidate ID did not match the final candidate ID."
                            ))
                        }
                        if selectedCandidate.impactSimulation.goalTimeline.planRisk.isImpossible &&
                            selectedCandidate.impactSimulation.goalTimeline.onTrack.isOnTrack
                        {
                            failures.append(.init(
                                scenarioID: scenarioID,
                                message: "Impossible timeline was shown as on track."
                            ))
                        }
                        if selectedCandidate.impactSimulation.goalTimeline.planRisk.isImpossible {
                            impossibleScenarioCount += 1
                        }
                    } else {
                        failures.append(.init(
                            scenarioID: scenarioID,
                            message: "Generator did not surface a selected candidate."
                        ))
                    }

                    if baseField.candidates.allSatisfy({ $0.impactSimulation.candidateID == $0.id }) == false {
                        failures.append(.init(
                            scenarioID: scenarioID,
                            message: "At least one candidate lost its impact-simulation identity binding."
                        ))
                    }

                    for candidate in baseField.candidates {
                        pressureSurfaceCounts[candidate.impactSimulation.deadlinePressureDelta.rawValue, default: 0] += 1
                    }

                    let selectedBeforeRejection = baseField.selectedCandidate
                    if let selectedBeforeRejection {
                        let rejectionRecord = StepCandidateRejectionRecord(
                            candidateID: selectedBeforeRejection.id,
                            sourceCandidateID: selectedBeforeRejection.sourceCandidateID,
                            sourceStepID: selectedBeforeRejection.sourceStepID,
                            contextFingerprint: context.contextFingerprint,
                            reason: StepCandidateRejectionReason(code: rejectionReason.code),
                            skippedReason: false,
                            recordedAt: fixedNowString
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
                            rejectionHistory: [rejectionRecord],
                            generatedAt: context.generatedAt,
                            candidateLimit: context.candidateLimit,
                            localOnly: context.localOnly
                        )
                        let rejectedField = generator.generate(rejectedContext)
                        let suppressionRecorded = rejectedField.rankingTrace.suppressedRejectedCandidateIDs.contains(selectedBeforeRejection.id)
                        let rankingChanged = rejectedField.selectedCandidateID != selectedBeforeRejection.id
                        if suppressionRecorded == false && rankingChanged == false {
                            failures.append(.init(
                                scenarioID: scenarioID,
                                message: "Rejection did not change ranking or record a suppression reason."
                            ))
                        }
                    }

                    if !baseField.candidates.contains(where: { candidate in
                        let planRisk = candidate.impactSimulation.goalTimeline.planRisk
                        return planRisk.threatensProtectedTime ||
                            planRisk.requiresDeadlineReview ||
                            planRisk.requiresScopeReview ||
                            planRisk.isImpossible ||
                            planRisk.deadlinePressureDelta == .delayed ||
                            planRisk.feasibilityBand == .atRisk ||
                            planRisk.feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity
                    }) {
                        failures.append(.init(
                            scenarioID: scenarioID,
                            message: "No candidate surfaced a material deadline impact."
                        ))
                    }

                    let encodedField = try JSONEncoder().encode(baseField)
                    let encodedString = String(decoding: encodedField, as: UTF8.self)
                    if encodedString.contains("PRIVATE-") || encodedString.contains("custom reason") {
                        failures.append(.init(
                            scenarioID: scenarioID,
                            message: "Sensitive text leaked into the encoded candidate field."
                        ))
                    } else {
                        privacyScanPassCount += 1
                    }
                }
            }
        }

        return StepCandidateSimulationGauntletResult(
            scenarioCount: scenarioCount,
            goalArchetypesCovered: goalArchetypesCovered,
            contextProfilesCovered: contextProfilesCovered,
            scheduleRealitiesCovered: scheduleRealitiesCovered,
            rejectionReasonsCovered: rejectionReasonsCovered,
            deadlinePressureLevelsCovered: deadlinePressureLevelsCovered,
            accessStatesCovered: accessStatesCovered,
            historicalStatesCovered: historicalStatesCovered,
            pressureSurfaceCounts: pressureSurfaceCounts,
            impossibleScenarioCount: impossibleScenarioCount,
            replayDeterministicCount: replayDeterministicCount,
            acceptedAlternativeReceiptCount: acceptedAlternativeReceiptCount,
            privacyScanPassCount: privacyScanPassCount,
            totalCandidateCount: totalCandidateCount,
            multiCandidateScenarioCount: multiCandidateScenarioCount,
            failures: failures,
            reportURL: reportURL,
            validationCommands: validationCommands
        )
    }

    private var validationCommands: [String] {
        [
            "make xcode-build-for-testing BATCH=IOS26-T04B-B05",
            "make xcode-focused-test BATCH=IOS26-T04B-B05 TEST=AmbitionsTests/StepCandidateFieldGeneratorTests/testSimulationGauntletCoversDeterministicScenarioMatrixAndWritesProofReport"
        ]
    }

    private func makeCompilerOutput(
        goal: GoalArchetypeFixture,
        schedule: ScheduleRealityFixture,
        access: AccessFixture,
        scenarioID: String
    ) -> GoalIntentDayCompilerOutput {
        let intent = GoalIntent(
            id: "goal.intent.\(goal.id)",
            rawStatement: goal.goalText,
            createdAt: fixedNowString,
            sourceSurface: .today,
            privacyClass: .localOnly,
            sourceState: .draft
        )

        return GoalIntentDayCompilerOutput(
            intent: intent,
            compiledAt: fixedNowString,
            status: .clear,
            clarification: GoalIntentClarification(
                status: .clear,
                readiness: .readyForPlanning,
                questions: [],
                missingFields: []
            ),
            capacityEnvelope: GoalIntentCapacityEnvelope(
                capacityLevel: schedule.capacityLevel,
                recoveryState: schedule.recoveryState,
                availableWindows: schedule.availableWindows
            ),
            compiledSteps: [
                CompiledStep(
                    id: "compiled-step.\(scenarioID)",
                    intentID: intent.id,
                    sourceCandidateID: "source-candidate.\(goal.id)",
                    title: goal.stepTitle,
                    summary: goal.stepSummary,
                    orderIndex: 0,
                    stepType: .actionUnit,
                    pace: .untimed,
                    targetDate: schedule.deadlineTargetDate,
                    repeatEveryDays: schedule.repeatEveryDays,
                    evidenceHint: goal.evidenceHint,
                    contextRequirements: goal.contextRequirements + access.contextRequirements,
                    isOptional: schedule.isOptional,
                    isRepeatable: true,
                    isExecutable: schedule.isExecutable
                )
            ],
            receipts: [
                CompiledStepReceipt(
                    id: "compiled-receipt.\(scenarioID)",
                    compiledStepID: "compiled-step.\(scenarioID)",
                    intentID: intent.id,
                    generatedAt: fixedNowString,
                    status: .clear,
                    summary: "Compiled locally for the step optionality gauntlet.",
                    reason: "Local deterministic proof fixture.",
                    sourceSurface: .today,
                    localOnly: true
                )
            ],
            localOnly: true
        )
    }

    private func makeContextBundle(
        goal: GoalArchetypeFixture,
        profile: ContextProfileFixture,
        access: AccessFixture,
        history: HistoryFixture,
        schedule: ScheduleRealityFixture,
        scenarioID: String
    ) -> LifeContextBundle {
        let source = LifeContextSource(
            id: "source.\(profile.id)",
            label: "Local profile source",
            kind: .userConfirmed,
            timestamp: fixedNowString,
            visibleExplanation: "Local profile source for deterministic simulation."
        )
        let opportunityContext = OpportunityContext(
            id: "opportunity.\(access.id)",
            facilities: access.facilities,
            equipmentAccess: access.equipmentAccess,
            coachingMentorAccess: access.coachingMentorAccess,
            localOrganizations: access.localOrganizations,
            eventExposureAccess: access.eventExposureAccess,
            remoteAccess: access.remoteAccess,
            travelRequirement: access.travelRequirement,
            costRequirement: access.costRequirement,
            seasonalAvailability: access.seasonalAvailability,
            verificationStatus: access.verificationStatus
        )
        let pathway = LifeContextEligibilityPathway(
            id: "pathway.\(profile.id)",
            pathwayType: profile.pathwayType,
            eligibilityRulesSummary: profile.eligibilitySummary,
            ageWindow: profile.ageWindow,
            gradeWindow: nil,
            sexLeaguePathway: nil,
            locationDependent: profile.locationDependent,
            source: source,
            freshness: profile.pathwayFreshness,
            userConfirmed: true
        )

        return LifeContextBundle(
            id: "bundle.\(scenarioID)",
            profile: LifeContextProfile(
                id: profile.id,
                exactAgeYears: profile.exactAgeYears,
                timezone: profile.timezone,
                locale: profile.locale,
                generalLocationLabel: profile.locationLabel,
                locationPrecision: profile.locationPrecision,
                lifeStage: profile.lifeStage,
                schoolOrWorkContext: profile.schoolOrWorkContext,
                travelRadiusMinutes: profile.travelRadiusMinutes,
                travelRadiusMiles: profile.travelRadiusMiles,
                transportationAccess: profile.transportationAccess,
                scheduleAnchors: profile.scheduleAnchors,
                dependencyConstraints: profile.dependencyConstraints,
                budgetConstraintBand: profile.budgetConstraintBand,
                energyPattern: profile.energyPattern,
                recoveryConstraints: profile.recoveryConstraints,
                accessibilityNeeds: profile.accessibilityNeeds,
                userNotes: profile.userNotes
            ),
            eligibilityPathways: [pathway],
            opportunityContexts: [opportunityContext],
            historicalFacts: history.facts,
            sources: [source],
            createdAt: fixedNowString,
            updatedAt: fixedNowString
        )
    }

    private func makeRecommendationTrace(
        scenarioID: String,
        goal: GoalArchetypeFixture,
        profile: ContextProfileFixture,
        access: AccessFixture,
        history: HistoryFixture
    ) -> RecommendationTrace {
        RecommendationTrace(
            id: "trace.\(scenarioID)",
            recommendationID: "recommendation.\(scenarioID)",
            source: RecommendationTraceSource(
                citedSourceIDs: [
                    "source.\(profile.id)",
                    "opportunity.\(access.id)",
                    "history.\(history.id)"
                ],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.goalState, .captureState],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "reason.\(scenarioID)",
                summary: goal.goalText,
                evidenceCategoryIDs: ["goal_state", "capture_state"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.\(scenarioID)"],
                summaries: ["Local deterministic uncertainty is kept visible."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correction.\(scenarioID)"],
                controlActionIDs: ["control.\(scenarioID)"],
                correctableFieldKeys: ["field.goal", "field.context"],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(
                receiptIDs: ["receipt.\(scenarioID)"],
                actionReceiptIDs: ["action-receipt.\(scenarioID)"],
                proofReferenceIDs: ["proof.\(scenarioID)"]
            )
        )
    }

    private func makeRuntimeContext() -> RuntimeContextSnapshot {
        RuntimeContextSnapshot(
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
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Local-only provider for simulation coverage.",
                    runtimeTrustPosture: .localOnly
                )
            ],
            memorySummary: RuntimeMemorySummary(
                memory: RuntimeMemorySnapshot(
                    goals: [],
                    drafts: [],
                    evidence: [],
                    feedback: [],
                    captures: [],
                    appState: .default
                )
            ),
            externalSurfaceSnapshot: nil
        )
    }

    private var goalArchetypes: [GoalArchetypeFixture] {
        [
            .init(id: "make-varsity-football", goalText: "make varsity football", stepTitle: "Run varsity football training block", stepSummary: "Build football-specific conditioning and practice discipline.", evidenceHint: "Football training remains locally sequenced.", contextRequirements: ["Field access and team practice time."]),
            .init(id: "play-college-basketball", goalText: "play college basketball", stepTitle: "Advance college basketball readiness", stepSummary: "Keep the basketball thread moving with skill and conditioning work.", evidenceHint: "Basketball prep uses the current local access.", contextRequirements: ["Court access and competition readiness."]),
            .init(id: "release-a-song", goalText: "release a song", stepTitle: "Push the song release thread forward", stepSummary: "Prepare the recording, edit, and release steps.", evidenceHint: "Creative release work stays local-first.", contextRequirements: ["Studio time and creative review."]),
            .init(id: "launch-an-app", goalText: "launch an app", stepTitle: "Move the app launch toward shipping", stepSummary: "Keep product, polish, and launch readiness in view.", evidenceHint: "Launch work should stay grounded in the current build.", contextRequirements: ["Build access and release checklist."]),
            .init(id: "pay-off-debt", goalText: "pay off debt", stepTitle: "Move debt payoff forward", stepSummary: "Review the next money step with steady local control.", evidenceHint: "Debt payoff stays tied to the current budget picture.", contextRequirements: ["Budget visibility and repayment review."]),
            .init(id: "lose-weight", goalText: "lose weight", stepTitle: "Keep the weight-loss thread moving", stepSummary: "Use a lighter sustainable step that respects recovery.", evidenceHint: "Weight loss is shaped by current energy and access.", contextRequirements: ["Nutrition and movement consistency."]),
            .init(id: "build-strength", goalText: "build strength", stepTitle: "Advance strength building", stepSummary: "Keep the training thread visible without overreaching.", evidenceHint: "Strength work respects recovery and load.", contextRequirements: ["Strength equipment and recovery time."]),
            .init(id: "learn-coding", goalText: "learn coding", stepTitle: "Do the next coding practice step", stepSummary: "Keep the coding thread moving with small local practice.", evidenceHint: "Learning stays anchored to the current lesson.", contextRequirements: ["Focus time and a practice environment."]),
            .init(id: "get-a-job", goalText: "get a job", stepTitle: "Advance the job search thread", stepSummary: "Keep the job search moving with a concrete local action.", evidenceHint: "Job search stays grounded in the current market prep.", contextRequirements: ["Application materials and interview practice."]),
            .init(id: "move-apartments", goalText: "move apartments", stepTitle: "Move the apartment transition forward", stepSummary: "Use the next move-related step without pretending it is simple.", evidenceHint: "Moving work respects local timing and access.", contextRequirements: ["Lease timing and moving logistics."]),
            .init(id: "start-mountain-biking", goalText: "start mountain biking", stepTitle: "Keep the mountain biking thread moving", stepSummary: "Build the riding habit from a local access-aware step.", evidenceHint: "Riding prep stays local to available trails.", contextRequirements: ["Trail access and safety gear."]),
            .init(id: "prepare-for-exam", goalText: "prepare for exam", stepTitle: "Study for the exam", stepSummary: "Keep the exam prep narrow and steady.", evidenceHint: "Exam prep stays tied to the current study window.", contextRequirements: ["Study time and review materials."]),
            .init(id: "build-portfolio", goalText: "build portfolio", stepTitle: "Add the next portfolio proof piece", stepSummary: "Keep the portfolio thread moving with a concrete proof item.", evidenceHint: "Portfolio work stays local to current proof.", contextRequirements: ["Artifact capture and review time."]),
            .init(id: "repair-relationship-habit", goalText: "repair relationship habit", stepTitle: "Do the relationship repair step", stepSummary: "Use the gentlest step that keeps the habit visible.", evidenceHint: "Relationship repair stays careful and local.", contextRequirements: ["Quiet time and respectful communication."]),
            .init(id: "clean-organize-home-system", goalText: "clean/organize home system", stepTitle: "Organize the home system", stepSummary: "Keep the home-system thread moving without overload.", evidenceHint: "Home organization stays bounded to current access.", contextRequirements: ["Home access and a tidy-up window."]),
            .init(id: "start-business", goalText: "start business", stepTitle: "Move the business launch forward", stepSummary: "Keep the startup thread moving with one concrete business step.", evidenceHint: "Startup work stays local to current constraints.", contextRequirements: ["Business planning and setup time."]),
            .init(id: "write-book", goalText: "write book", stepTitle: "Write the next book passage", stepSummary: "Keep the book thread moving with a local writing pass.", evidenceHint: "Writing stays tied to the current draft.", contextRequirements: ["Writing time and draft access."]),
            .init(id: "improve-sleep", goalText: "improve sleep", stepTitle: "Improve sleep with a stable next step", stepSummary: "Choose a recovery-safe step that protects the night.", evidenceHint: "Sleep improvement should keep recovery visible.", contextRequirements: ["Evening routine and sleep window."]),
            .init(id: "recover-from-burnout", goalText: "recover from burnout", stepTitle: "Take the next recovery-safe step", stepSummary: "Use the gentlest recovery path that does not overpromise.", evidenceHint: "Recovery should stay conservative and local.", contextRequirements: ["Recovery time and gentle pacing."]),
            .init(id: "train-for-race", goalText: "train for race", stepTitle: "Advance race training", stepSummary: "Keep the race-training thread moving with the current load.", evidenceHint: "Race training stays tied to current readiness.", contextRequirements: ["Training window and route access."]),
            .init(id: "save-money", goalText: "save money", stepTitle: "Advance the savings thread", stepSummary: "Use a concrete money step that keeps the savings plan visible.", evidenceHint: "Savings planning stays local to the current budget.", contextRequirements: ["Budget review and spending restraint."]),
            .init(id: "build-social-life", goalText: "build social life", stepTitle: "Keep the social thread moving", stepSummary: "Choose a socially grounded step with current access.", evidenceHint: "Social planning stays local and realistic.", contextRequirements: ["Social availability and connection time."]),
            .init(id: "learn-instrument", goalText: "learn instrument", stepTitle: "Practice the instrument", stepSummary: "Keep the instrument thread moving with a small practice pass.", evidenceHint: "Practice stays tied to current access.", contextRequirements: ["Instrument access and practice time."]),
            .init(id: "finish-certification", goalText: "finish certification", stepTitle: "Advance the certification thread", stepSummary: "Keep certification progress visible with a next step.", evidenceHint: "Certification work stays grounded in the current path.", contextRequirements: ["Study materials and certification progress."]),
            .init(id: "plan-trip", goalText: "plan trip", stepTitle: "Plan the trip step", stepSummary: "Keep the trip thread moving without pretending all details are solved.", evidenceHint: "Trip planning stays local to current constraints.", contextRequirements: ["Travel planning and itinerary access."])
        ]
    }

    private var contextProfiles: [ContextProfileFixture] {
        [
            .init(id: "profile-varsity-athlete", exactAgeYears: 17, timezone: "America/New_York", locale: "en_US", locationLabel: "School district", locationPrecision: .cityRegion, lifeStage: .highSchool, schoolOrWorkContext: "High school athlete", travelRadiusMinutes: 25, travelRadiusMiles: 10, transportationAccess: .parentGuardian, scheduleAnchors: ["Practice", "Class"], dependencyConstraints: ["Parent transport"], budgetConstraintBand: .tight, energyPattern: .evening, recoveryConstraints: ["Evening recovery block"], accessibilityNeeds: [], userNotes: "Varsity athlete profile.", pathwayType: .sport, pathwayFreshness: .current, ageWindow: .init(lowerBoundYears: 15, upperBoundYears: 19), locationDependent: true, eligibilitySummary: "Sport eligibility with current school access."),
            .init(id: "profile-college-student", exactAgeYears: 20, timezone: "America/Chicago", locale: "en_US", locationLabel: "Campus area", locationPrecision: .precisePermissioned, lifeStage: .college, schoolOrWorkContext: "Full-time student", travelRadiusMinutes: 35, travelRadiusMiles: 14, transportationAccess: .transit, scheduleAnchors: ["Lecture", "Lab"], dependencyConstraints: ["Class schedule"], budgetConstraintBand: .moderate, energyPattern: .morning, recoveryConstraints: ["Midday reset"], accessibilityNeeds: [], userNotes: "College student profile.", pathwayType: .academic, pathwayFreshness: .current, ageWindow: .init(lowerBoundYears: 18, upperBoundYears: 24), locationDependent: false, eligibilitySummary: "Academic eligibility with campus access."),
            .init(id: "profile-early-career", exactAgeYears: 27, timezone: "America/Los_Angeles", locale: "en_US", locationLabel: "Metro hub", locationPrecision: .cityRegion, lifeStage: .earlyCareer, schoolOrWorkContext: "Full-time job", travelRadiusMinutes: 30, travelRadiusMiles: 12, transportationAccess: .rideshare, scheduleAnchors: ["Work", "Commute"], dependencyConstraints: ["Office hours"], budgetConstraintBand: .moderate, energyPattern: .midday, recoveryConstraints: ["Lunch reset"], accessibilityNeeds: [], userNotes: "Early-career commuter.", pathwayType: .career, pathwayFreshness: .current, ageWindow: .init(lowerBoundYears: 22, upperBoundYears: 40), locationDependent: true, eligibilitySummary: "Career path with commuter access."),
            .init(id: "profile-caregiver", exactAgeYears: 41, timezone: "America/New_York", locale: "en_US", locationLabel: "Home base", locationPrecision: .timezone, lifeStage: .caregiver, schoolOrWorkContext: "Caregiving schedule", travelRadiusMinutes: 20, travelRadiusMiles: 6, transportationAccess: .limited, scheduleAnchors: ["School dropoff", "Care block"], dependencyConstraints: ["Care window"], budgetConstraintBand: .tight, energyPattern: .variable, recoveryConstraints: ["Low-spread recovery"], accessibilityNeeds: ["Shorter steps"], userNotes: "Caregiver with limited travel.", pathwayType: .health, pathwayFreshness: .mayNeedReview, ageWindow: .init(lowerBoundYears: 30, upperBoundYears: 55), locationDependent: false, eligibilitySummary: "Health path with care windows."),
            .init(id: "profile-founder", exactAgeYears: 32, timezone: "America/Denver", locale: "en_US", locationLabel: "Home office", locationPrecision: .userEnteredPlace, lifeStage: .adult, schoolOrWorkContext: "Founder", travelRadiusMinutes: 45, travelRadiusMiles: 20, transportationAccess: .car, scheduleAnchors: ["Deep work", "Client call"], dependencyConstraints: ["Call blocks"], budgetConstraintBand: .flexible, energyPattern: .variable, recoveryConstraints: ["Evening buffer"], accessibilityNeeds: [], userNotes: "Founder with flexible schedule.", pathwayType: .career, pathwayFreshness: .current, ageWindow: .init(lowerBoundYears: 25, upperBoundYears: 45), locationDependent: false, eligibilitySummary: "Career path with flexible local access."),
            .init(id: "profile-recovery", exactAgeYears: 35, timezone: "America/New_York", locale: "en_US", locationLabel: "Home only", locationPrecision: .none, lifeStage: .adult, schoolOrWorkContext: "Recovery-focused", travelRadiusMinutes: 10, travelRadiusMiles: 2, transportationAccess: .limited, scheduleAnchors: ["Rest", "Therapy"], dependencyConstraints: ["Low energy"], budgetConstraintBand: .tight, energyPattern: .evening, recoveryConstraints: ["Protected rest"], accessibilityNeeds: ["Low load"], userNotes: "Recovery profile.", pathwayType: .health, pathwayFreshness: .basedOnOlderContext, ageWindow: .init(lowerBoundYears: 20, upperBoundYears: 55), locationDependent: false, eligibilitySummary: "Health path with recovery constraints."),
            .init(id: "profile-remote-creator", exactAgeYears: 29, timezone: "America/Los_Angeles", locale: "en_US", locationLabel: "Remote setup", locationPrecision: .cityRegion, lifeStage: .adult, schoolOrWorkContext: "Remote creator", travelRadiusMinutes: 15, travelRadiusMiles: 4, transportationAccess: .walk, scheduleAnchors: ["Editing", "Upload"], dependencyConstraints: ["Quiet time"], budgetConstraintBand: .moderate, energyPattern: .evening, recoveryConstraints: ["Night buffer"], accessibilityNeeds: [], userNotes: "Remote creative profile.", pathwayType: .creative, pathwayFreshness: .current, ageWindow: .init(lowerBoundYears: 18, upperBoundYears: 60), locationDependent: false, eligibilitySummary: "Creative path with remote access."),
            .init(id: "profile-teen-competitor", exactAgeYears: 16, timezone: "America/Chicago", locale: "en_US", locationLabel: "School zone", locationPrecision: .cityRegion, lifeStage: .highSchool, schoolOrWorkContext: "Teen competitor", travelRadiusMinutes: 20, travelRadiusMiles: 8, transportationAccess: .parentGuardian, scheduleAnchors: ["School", "Training"], dependencyConstraints: ["Guardian transport"], budgetConstraintBand: .tight, energyPattern: .morning, recoveryConstraints: ["After-school rest"], accessibilityNeeds: [], userNotes: "Teen competitor profile.", pathwayType: .sport, pathwayFreshness: .current, ageWindow: .init(lowerBoundYears: 14, upperBoundYears: 18), locationDependent: true, eligibilitySummary: "Sport path with guardian logistics."),
            .init(id: "profile-midlife-learner", exactAgeYears: 44, timezone: "America/Phoenix", locale: "en_US", locationLabel: "Neighborhood", locationPrecision: .userEnteredPlace, lifeStage: .adult, schoolOrWorkContext: "Part-time learner", travelRadiusMinutes: 25, travelRadiusMiles: 9, transportationAccess: .bike, scheduleAnchors: ["Study", "Errands"], dependencyConstraints: ["Family support"], budgetConstraintBand: .moderate, energyPattern: .midday, recoveryConstraints: ["Midday reset"], accessibilityNeeds: [], userNotes: "Midlife learner profile.", pathwayType: .academic, pathwayFreshness: .mayNeedReview, ageWindow: .init(lowerBoundYears: 30, upperBoundYears: 60), locationDependent: false, eligibilitySummary: "Academic path with local flexibility."),
            .init(id: "profile-community-builder", exactAgeYears: 38, timezone: "America/New_York", locale: "en_US", locationLabel: "Community zone", locationPrecision: .cityRegion, lifeStage: .adult, schoolOrWorkContext: "Community organizer", travelRadiusMinutes: 40, travelRadiusMiles: 18, transportationAccess: .transit, scheduleAnchors: ["Meetup", "Planning"], dependencyConstraints: ["Event availability"], budgetConstraintBand: .flexible, energyPattern: .variable, recoveryConstraints: ["Buffer after events"], accessibilityNeeds: [], userNotes: "Community-builder profile.", pathwayType: .creative, pathwayFreshness: .current, ageWindow: .init(lowerBoundYears: 25, upperBoundYears: 55), locationDependent: true, eligibilitySummary: "Community path with transit access.")
        ]
    }

    private var scheduleRealities: [ScheduleRealityFixture] {
        [
            .init(id: "schedule-preserved-open", pressureLevel: .preserved, deadlineTargetDate: nil, availableWindows: .init(open: 2, protected: 0), capacityLevel: .moderate, recoveryState: .steady, isOptional: false, isExecutable: true, repeatEveryDays: 12),
            .init(id: "schedule-preserved-far", pressureLevel: .preserved, deadlineTargetDate: "2026-06-10T18:13:20Z", availableWindows: .init(open: 2, protected: 0), capacityLevel: .moderate, recoveryState: .steady, isOptional: false, isExecutable: true, repeatEveryDays: 14),
            .init(id: "schedule-compressed-urgent", pressureLevel: .compressed, deadlineTargetDate: "2026-05-24T18:13:20Z", availableWindows: .init(open: 1, protected: 0), capacityLevel: .high, recoveryState: .steady, isOptional: false, isExecutable: true, repeatEveryDays: 18),
            .init(id: "schedule-compressed-tight", pressureLevel: .compressed, deadlineTargetDate: "2026-05-25T18:13:20Z", availableWindows: .init(open: 1, protected: 0), capacityLevel: .moderate, recoveryState: .steady, isOptional: false, isExecutable: true, repeatEveryDays: 20),
            .init(id: "schedule-delayed-low-capacity", pressureLevel: .delayed, deadlineTargetDate: "2026-06-12T18:13:20Z", availableWindows: .init(open: 0, protected: 0), capacityLevel: .low, recoveryState: .steady, isOptional: false, isExecutable: true, repeatEveryDays: 30),
            .init(id: "schedule-delayed-empty-window", pressureLevel: .delayed, deadlineTargetDate: "2026-06-18T18:13:20Z", availableWindows: .init(open: 0, protected: 0), capacityLevel: .low, recoveryState: .stretch, isOptional: false, isExecutable: true, repeatEveryDays: 36),
            .init(id: "schedule-protected-conflict-1", pressureLevel: .threatensProtectedTime, deadlineTargetDate: "2026-05-31T18:13:20Z", availableWindows: .init(open: 0, protected: 1), capacityLevel: .moderate, recoveryState: .steady, isOptional: false, isExecutable: true, repeatEveryDays: 16),
            .init(id: "schedule-protected-conflict-2", pressureLevel: .threatensProtectedTime, deadlineTargetDate: "2026-06-02T18:13:20Z", availableWindows: .init(open: 0, protected: 2), capacityLevel: .moderate, recoveryState: .steady, isOptional: false, isExecutable: true, repeatEveryDays: 24),
            .init(id: "schedule-deadline-review-1", pressureLevel: .requiresDeadlineReview, deadlineTargetDate: "2026-05-23T18:13:20Z", availableWindows: .init(open: 1, protected: 0), capacityLevel: .moderate, recoveryState: .steady, isOptional: false, isExecutable: true, repeatEveryDays: 22),
            .init(id: "schedule-impossible-blocked", pressureLevel: .requiresDeadlineReview, deadlineTargetDate: "2026-05-23T18:13:20Z", availableWindows: .init(open: 0, protected: 1), capacityLevel: .low, recoveryState: .needsRecovery, isOptional: false, isExecutable: false, repeatEveryDays: 28)
        ]
    }

    private var rejectionReasonFixtures: [RejectionReasonFixture] {
        [
            .init(code: .tooLong),
            .init(code: .tooHard),
            .init(code: .tooMuchEnergy),
            .init(code: .wrongLocation),
            .init(code: .noEquipment),
            .init(code: .notEnoughTime),
            .init(code: .blockedBySomeoneElse),
            .init(code: .alreadyDidSimilar),
            .init(code: .notUseful),
            .init(code: .preferDifferentPath)
        ]
    }

    private var accessFixtures: [AccessFixture] {
        [
            .init(id: "access-home-only", facilities: [.home], equipmentAccess: [], coachingMentorAccess: nil, localOrganizations: [], eventExposureAccess: false, remoteAccess: false, travelRequirement: "Stay home", costRequirement: "No extra spend", seasonalAvailability: nil, verificationStatus: .verified, contextRequirements: ["Home access only"]),
            .init(id: "access-gym", facilities: [.gym, .makerSpace], equipmentAccess: ["Weights", "Mat"], coachingMentorAccess: "Coach", localOrganizations: ["Gym"], eventExposureAccess: false, remoteAccess: false, travelRequirement: "Short commute", costRequirement: "Membership", seasonalAvailability: nil, verificationStatus: .partiallyVerified, contextRequirements: ["Gym access and equipment"]),
            .init(id: "access-field", facilities: [.field, .park], equipmentAccess: ["Cleats"], coachingMentorAccess: "Team lead", localOrganizations: ["Club"], eventExposureAccess: true, remoteAccess: false, travelRequirement: "Field access", costRequirement: "Travel fee", seasonalAvailability: "Seasonal league", verificationStatus: .verified, contextRequirements: ["Field access and team timing"]),
            .init(id: "access-library-studio", facilities: [.library, .studio], equipmentAccess: ["Notebook", "Camera"], coachingMentorAccess: nil, localOrganizations: ["Library"], eventExposureAccess: false, remoteAccess: true, travelRequirement: "Transit ok", costRequirement: "Low cost", seasonalAvailability: nil, verificationStatus: .verified, contextRequirements: ["Quiet space and creative tools"]),
            .init(id: "access-trail-transit", facilities: [.trail, .park], equipmentAccess: ["Shoes"], coachingMentorAccess: nil, localOrganizations: ["Trail group"], eventExposureAccess: true, remoteAccess: false, travelRequirement: "Transit or bike", costRequirement: "Low cost", seasonalAvailability: "Dry season", verificationStatus: .partiallyVerified, contextRequirements: ["Trail access and weather window"])
        ]
    }

    private var historicalFixtures: [HistoryFixture] {
        [
            .init(id: "history-current-success", facts: [
                .init(id: "fact.current.success", category: .pastAchievement, title: "Current success", detail: "Recent success supports feasibility.", confidence: 0.95, sourceType: .userToldAmbitions, freshness: .current, sensitivity: .normal, runtimeUseAllowed: true, usedFor: [.feasibility, .opportunity], createdAt: fixedNowString, updatedAt: fixedNowString)
            ]),
            .init(id: "history-current-failure", facts: [
                .init(id: "fact.current.failure", category: .priorAttempt, title: "Current failure recovery", detail: "A recent failure keeps the plan conservative.", confidence: 0.91, sourceType: .correctedByUser, freshness: .current, sensitivity: .normal, runtimeUseAllowed: true, usedFor: [.recovery, .sequencing], createdAt: fixedNowString, updatedAt: fixedNowString)
            ]),
            .init(id: "history-older-context", facts: [
                .init(id: "fact.older.context", category: .educationHistory, title: "Older context", detail: "Older context is still relevant but should be refreshed.", confidence: 0.72, sourceType: .imported, freshness: .basedOnOlderContext, sensitivity: .normal, runtimeUseAllowed: true, usedFor: [.explanation, .eligibility], createdAt: fixedNowString, updatedAt: fixedNowString)
            ]),
            .init(id: "history-stale-recovery", facts: [
                .init(id: "fact.stale.recovery", category: .injuryLimitation, title: "Stale recovery limit", detail: "A stale injury note should make the runtime cautious.", confidence: 0.61, sourceType: .inferredFromLocalAction, freshness: .stale, sensitivity: .normal, runtimeUseAllowed: true, usedFor: [.recovery, .safety], createdAt: fixedNowString, updatedAt: fixedNowString)
            ]),
            .init(id: "history-excluded-context", facts: [
                .init(id: "fact.deleted.context", category: .relationshipDependency, title: "Deleted relationship detail", detail: "Deleted history stays excluded from runtime use.", confidence: 0.42, sourceType: .deleted, freshness: .stale, sensitivity: .normal, runtimeUseAllowed: false, usedFor: [.explanation], createdAt: fixedNowString, updatedAt: fixedNowString, deletedAt: fixedNowString),
                .init(id: "fact.paused.context", category: .workHistory, title: "Paused work detail", detail: "Paused history stays excluded from runtime use.", confidence: 0.44, sourceType: .paused, freshness: .stale, sensitivity: .normal, runtimeUseAllowed: false, usedFor: [.explanation], createdAt: fixedNowString, updatedAt: fixedNowString, pausedAt: fixedNowString)
            ])
        ]
    }

    private struct GoalArchetypeFixture {
        let id: String
        let goalText: String
        let stepTitle: String
        let stepSummary: String
        let evidenceHint: String
        let contextRequirements: [String]
    }

    private struct ContextProfileFixture {
        let id: String
        let exactAgeYears: Int
        let timezone: String
        let locale: String
        let locationLabel: String
        let locationPrecision: LifeContextLocationPrecision
        let lifeStage: LifeContextLifeStage
        let schoolOrWorkContext: String
        let travelRadiusMinutes: Int
        let travelRadiusMiles: Double
        let transportationAccess: LifeContextTransportationAccess
        let scheduleAnchors: [String]
        let dependencyConstraints: [String]
        let budgetConstraintBand: LifeContextBudgetConstraintBand
        let energyPattern: LifeContextEnergyPattern
        let recoveryConstraints: [String]
        let accessibilityNeeds: [String]
        let userNotes: String
        let pathwayType: LifeContextEligibilityPathwayType
        let pathwayFreshness: LifeContextFreshness
        let ageWindow: LifeContextAgeWindow
        let locationDependent: Bool
        let eligibilitySummary: String
    }

    private struct ScheduleRealityFixture {
        let id: String
        let pressureLevel: DeadlinePressureFixtureLevel
        let deadlineTargetDate: String?
        let availableWindows: [GoalIntentCapacityWindow]
        let capacityLevel: EnergyCapacityLevel
        let recoveryState: EnergyRecoveryState
        let isOptional: Bool
        let isExecutable: Bool
        let repeatEveryDays: Int?

        init(
            id: String,
            pressureLevel: DeadlinePressureFixtureLevel,
            deadlineTargetDate: String?,
            availableWindows: WindowFixture,
            capacityLevel: EnergyCapacityLevel,
            recoveryState: EnergyRecoveryState,
            isOptional: Bool,
            isExecutable: Bool,
            repeatEveryDays: Int?
        ) {
            self.id = id
            self.pressureLevel = pressureLevel
            self.deadlineTargetDate = deadlineTargetDate
            self.availableWindows = availableWindows.makeWindows(idPrefix: id)
            self.capacityLevel = capacityLevel
            self.recoveryState = recoveryState
            self.isOptional = isOptional
            self.isExecutable = isExecutable
            self.repeatEveryDays = repeatEveryDays
        }
    }

    private struct WindowFixture {
        let open: Int
        let protected: Int

        func makeWindows(idPrefix: String) -> [GoalIntentCapacityWindow] {
            let openWindows = (0..<open).map { index in
                GoalIntentCapacityWindow(
                    id: "\(idPrefix).open.\(index)",
                    title: "Open window \(index)",
                    summary: "An open window is available.",
                    availableMinutes: 30,
                    isProtected: false
                )
            }
            let protectedWindows = (0..<protected).map { index in
                GoalIntentCapacityWindow(
                    id: "\(idPrefix).protected.\(index)",
                    title: "Protected window \(index)",
                    summary: "Protected time is reserved.",
                    availableMinutes: 30,
                    isProtected: true
                )
            }
            return openWindows + protectedWindows
        }
    }

    private struct RejectionReasonFixture {
        let code: StepCandidateRejectionReasonCode
    }

    private struct AccessFixture {
        let id: String
        let facilities: [LifeContextFacility]
        let equipmentAccess: [String]
        let coachingMentorAccess: String?
        let localOrganizations: [String]
        let eventExposureAccess: Bool
        let remoteAccess: Bool
        let travelRequirement: String?
        let costRequirement: String?
        let seasonalAvailability: String?
        let verificationStatus: LifeContextVerificationStatus
        let contextRequirements: [String]
    }

    private struct HistoryFixture {
        let id: String
        let facts: [HistoricalContextFact]
    }

    private enum DeadlinePressureFixtureLevel: String, CaseIterable, Hashable {
        case preserved
        case compressed
        case delayed
        case threatensProtectedTime = "threatens_protected_time"
        case requiresDeadlineReview = "requires_deadline_review"
    }
}

private struct StepCandidateSimulationGauntletResult {
    let scenarioCount: Int
    let goalArchetypesCovered: Set<String>
    let contextProfilesCovered: Set<String>
    let scheduleRealitiesCovered: Set<String>
    let rejectionReasonsCovered: Set<String>
    let deadlinePressureLevelsCovered: Set<String>
    let accessStatesCovered: Set<String>
    let historicalStatesCovered: Set<String>
    let pressureSurfaceCounts: [String: Int]
    let impossibleScenarioCount: Int
    let replayDeterministicCount: Int
    let acceptedAlternativeReceiptCount: Int
    let privacyScanPassCount: Int
    let totalCandidateCount: Int
    let multiCandidateScenarioCount: Int
    let failures: [GauntletFailure]
    let reportURL: URL
    let validationCommands: [String]

    var failureSummary: String {
        failures.isEmpty ? "No failures recorded." : failures.prefix(10).map { "\($0.scenarioID): \($0.message)" }.joined(separator: "\n")
    }

    var greenCheckCount: Int {
        max(0, scenarioCount - redCheckCount - yellowCheckCount)
    }

    var yellowCheckCount: Int {
        0
    }

    var redCheckCount: Int {
        failures.count
    }

    var report: String {
        let status = failures.isEmpty ? "GREEN" : "RED"
        let sortedPressures = pressureSurfaceCounts.keys.sorted().map { "\($0): \(pressureSurfaceCounts[$0] ?? 0)" }.joined(separator: ", ")
        let topFailures = failures.isEmpty ? ["none"] : failures.prefix(5).map { "- \($0.scenarioID): \($0.message)" }
        let validationCommandsBlock = validationCommands.map { "- `\($0)`" }.joined(separator: "\n")
        let privacyScanStatus = privacyScanPassCount == scenarioCount ? "passed" : "failed"

        return """
        STATUS: \(status)
        # Step Candidate Simulation Gauntlet Proof

        Batch: `IOS26-T04B-B05`
        Date: `2026-05-23`

        ## Red/Yellow/Green Summary
        - Green checks: \(greenCheckCount)
        - Yellow checks: \(yellowCheckCount)
        - Red checks: \(redCheckCount)

        ## Coverage
        - Goal archetypes: \(goalArchetypesCovered.count)/25
        - Context profiles: \(contextProfilesCovered.count)/10
        - Schedule realities: \(scheduleRealitiesCovered.count)/10
        - Rejection reasons: \(rejectionReasonsCovered.count)/10
        - Deadline pressure levels: \(deadlinePressureLevelsCovered.count)/5
        - Access/facility states: \(accessStatesCovered.count)/5
        - Historical context states: \(historicalStatesCovered.count)/5

        ## Verification
        - Scenario checks: \(scenarioCount)
        - Total candidates generated: \(totalCandidateCount)
        - Multi-candidate scenarios: \(multiCandidateScenarioCount)
        - Replay deterministic scenarios: \(replayDeterministicCount)/\(scenarioCount)
        - Accepted alternative receipt checks: \(acceptedAlternativeReceiptCount)/\(scenarioCount)
        - Impossible scenarios surfaced honestly: \(impossibleScenarioCount)
        - Privacy scan: \(privacyScanStatus) (\(privacyScanPassCount)/\(scenarioCount))
        - iOS 26 API note: no iOS 26-only APIs were introduced; the harness uses Foundation, XCTest, and local model constructors only.

        ## Deadline Pressure Surface
        \(sortedPressures.isEmpty ? "- none" : sortedPressures)

        ## Top Failing Scenarios
        \(topFailures.joined(separator: "\n"))

        ## Validation Commands
        \(validationCommandsBlock)

        ## Proof Boundaries
        - Deterministic local simulation only.
        - No app UI, architecture, dependency, analytics, or cloud changes.
        - No sensitive context is emitted in the report or encoded candidate payloads.
        - Unrelated dirty proof JSON files in `docs/proof/amb-fe-be/moat-scenario-proof-98/` were not modified by this batch.
        """
    }

    func writeReport() throws {
        try FileManager.default.createDirectory(at: reportURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try report.write(to: reportURL, atomically: true, encoding: .utf8)
    }
}

private struct GauntletFailure: Hashable {
    let scenarioID: String
    let message: String
}

private extension StepCandidateFieldGeneratorTests {
    func makeContext(
        goalText: String,
        compilerOutput: GoalIntentDayCompilerOutput,
        secretTraceSummary: String? = nil,
        rejectionHistory: [StepCandidateRejectionRecord] = [],
        sourceAtlasExpansionTrace: SourceAtlasStepExpansionTrace? = nil
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
            sourceAtlasExpansionTrace: sourceAtlasExpansionTrace,
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

    func makeCandidate(
        sourceStepID: String,
        title: String,
        summary: String
    ) -> StepCandidate {
        StepCandidate(
            sourceStepID: sourceStepID,
            sourceCandidateID: "\(sourceStepID).source",
            source: .goalIntentCompiler,
            kind: .directBest,
            title: title,
            summary: summary,
            accessibilitySummary: "Direct best - \(title)",
            estimatedMinutes: 12,
            estimatedEnergyCost: 0.4,
            accessRequirements: ["local access"],
            equipmentRequirements: [],
            facilityRequirements: [],
            goalContribution: 1,
            deadlineContribution: 0.9,
            futurePressureImpact: 0.8,
            opportunityCost: 0.3,
            approvalRequired: false,
            validity: .preferred,
            tradeoffs: [
                CandidateTradeoff(
                    id: "\(sourceStepID).benefit",
                    label: "Benefit",
                    benefit: "Clear path",
                    cost: "Higher effort than a fallback"
                )
            ],
            rejectionRisk: CandidateRejectionRisk(
                id: "\(sourceStepID).risk",
                level: .low,
                summary: "Low rejection risk for a direct path.",
                factorIDs: ["factor.goal_requirement"],
                requiresReview: false
            ),
            evidenceFactorIDs: ["factor.goal_requirement"],
            semanticAnchor: summary
        )
    }
}
