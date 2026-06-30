import XCTest
@testable import Ambitions

final class LifeContextRuntimeEffectProofTests: XCTestCase {
    func testLifeContextProjectionChangesRuntimeOutputAcrossScenariosAThroughE() throws {
        let kernel = PrivateLifeRuntimeKernel()

        let portfolioGoalText = "Launch my first portfolio."
        let portfolio14 = makeInput(
            bundle: LifeContextFixtureProfiles.teenPortfolioLaunchWithGuardianTransport(),
            goalText: portfolioGoalText,
            decisionKey: "today.start-here",
            recommendationID: "decision.portfolio.14"
        )
        let portfolio16 = makeInput(
            bundle: LifeContextFixtureProfiles.teenPortfolioLaunchWithSchoolAccess(),
            goalText: portfolioGoalText,
            decisionKey: "today.start-here",
            recommendationID: "decision.portfolio.16"
        )
        let portfolio14Output = kernel.evaluate(portfolio14)
        let portfolio16Output = kernel.evaluate(portfolio16)
        let portfolio14Trace = kernel.makeReplayableDecisionTrace(portfolio14)
        let portfolio16Trace = kernel.makeReplayableDecisionTrace(portfolio16)

        XCTAssertNotEqual(portfolio14Output.decisionID, portfolio16Output.decisionID)
        XCTAssertEqual(portfolio14Output.lifeContextEffect.startHereTitle, portfolioGoalText)
        XCTAssertEqual(portfolio16Output.lifeContextEffect.startHereTitle, portfolioGoalText)
        XCTAssertEqual(portfolio14Output.lifeContextEffect.cadence, "school-week cadence")
        XCTAssertEqual(portfolio16Output.lifeContextEffect.cadence, "compressed portfolio cadence")
        XCTAssertEqual(portfolio14Output.lifeContextEffect.milestone, "lock one guardian-transport build block")
        XCTAssertEqual(portfolio16Output.lifeContextEffect.milestone, "tighten portfolio readiness around school access")
        XCTAssertTrue(portfolio14Output.lifeContextEffect.startHereExplanation.contains("timeline is still early"))
        XCTAssertTrue(portfolio16Output.lifeContextEffect.startHereExplanation.contains("timeline is compressed"))
        XCTAssertEqual(portfolio14Trace.lifeContext.readiness, "ready")
        XCTAssertEqual(portfolio16Trace.lifeContext.readiness, "ready")
        XCTAssertEqual(portfolio14Trace.lifeContext.ageYears, 14)
        XCTAssertEqual(portfolio16Trace.lifeContext.ageYears, 16)

        let applicationGoalText = "Apply to a serious creative program."
        let creatorCohort = makeInput(
            bundle: LifeContextFixtureProfiles.creatorCohortApplicationPathway(),
            goalText: applicationGoalText,
            decisionKey: "today.start-here",
            recommendationID: "decision.creator.cohort"
        )
        let makerResidency = makeInput(
            bundle: LifeContextFixtureProfiles.makerResidencyApplicationPathway(),
            goalText: applicationGoalText,
            decisionKey: "today.start-here",
            recommendationID: "decision.maker.residency"
        )
        let creatorCohortOutput = kernel.evaluate(creatorCohort)
        let makerResidencyOutput = kernel.evaluate(makerResidency)
        let creatorCohortTrace = kernel.makeReplayableDecisionTrace(creatorCohort)
        let makerResidencyTrace = kernel.makeReplayableDecisionTrace(makerResidency)

        XCTAssertNotEqual(creatorCohortOutput.decisionID, makerResidencyOutput.decisionID)
        XCTAssertTrue(creatorCohortOutput.lifeContextEffect.pathwayLabels.contains("Creator cohort pathway"))
        XCTAssertTrue(makerResidencyOutput.lifeContextEffect.pathwayLabels.contains("Maker residency pathway"))
        XCTAssertTrue(creatorCohortOutput.lifeContextEffect.startHereExplanation.contains("Creator cohort pathway"))
        XCTAssertTrue(makerResidencyOutput.lifeContextEffect.startHereExplanation.contains("Maker residency pathway"))
        XCTAssertEqual(creatorCohortTrace.lifeContext.readiness, "ready")
        XCTAssertEqual(makerResidencyTrace.lifeContext.readiness, "ready")

        let workshopGoalText = "Launch a weekend workshop."
        let makerSpaceAccess = makeInput(
            bundle: LifeContextFixtureProfiles.adultWorkshopLaunchWithMakerAccess(),
            goalText: workshopGoalText,
            decisionKey: "today.start-here",
            recommendationID: "decision.workshop.maker_space"
        )
        let homeStudioAccess = makeInput(
            bundle: LifeContextFixtureProfiles.cityWorkshopLaunchWithoutEquipment(),
            goalText: workshopGoalText,
            decisionKey: "today.start-here",
            recommendationID: "decision.workshop.home_studio"
        )
        let makerSpaceAccessOutput = kernel.evaluate(makerSpaceAccess)
        let homeStudioAccessOutput = kernel.evaluate(homeStudioAccess)
        let makerSpaceAccessTrace = kernel.makeReplayableDecisionTrace(makerSpaceAccess)
        let homeStudioAccessTrace = kernel.makeReplayableDecisionTrace(homeStudioAccess)

        XCTAssertNotEqual(makerSpaceAccessOutput.decisionID, homeStudioAccessOutput.decisionID)
        XCTAssertEqual(makerSpaceAccessOutput.lifeContextEffect.cadence, "weekly maker-space cadence")
        XCTAssertEqual(homeStudioAccessOutput.lifeContextEffect.cadence, "local access cadence")
        XCTAssertEqual(makerSpaceAccessOutput.lifeContextEffect.milestone, "reach the first maker-space build")
        XCTAssertEqual(homeStudioAccessOutput.lifeContextEffect.milestone, "confirm equipment and local practice")
        XCTAssertTrue(makerSpaceAccessOutput.lifeContextEffect.startHereExplanation.contains("maker-space access shapes the first step"))
        XCTAssertTrue(homeStudioAccessOutput.lifeContextEffect.startHereExplanation.contains("equipment and local practice matter before maker-space access"))
        XCTAssertEqual(makerSpaceAccessTrace.lifeContext.readiness, "ready")
        XCTAssertEqual(homeStudioAccessTrace.lifeContext.readiness, "ready")
        XCTAssertTrue(homeStudioAccessTrace.lifeContext.sourceFreshnessStates.isEmpty == false)

        let recoveryGoalText = "Return to training after an injury."
        let recoveryBundle = makeRecoveryReviewBundle()
        let recoveryInput = makeInput(
            bundle: recoveryBundle,
            goalText: recoveryGoalText,
            decisionKey: "today.start-here",
            recommendationID: "decision.recovery.review"
        )
        let recoveryOutput = kernel.evaluate(recoveryInput)
        let recoveryTrace = kernel.makeReplayableDecisionTrace(recoveryInput)
        let recoveryTraceEncoded = try encodedJSONString(recoveryTrace)

        XCTAssertEqual(recoveryOutput.lifeContextEffect.readiness, .review)
        XCTAssertEqual(recoveryTrace.lifeContext.readiness, "review")
        XCTAssertEqual(recoveryOutput.lifeContextEffect.cadence, "rebuild from active context")
        XCTAssertEqual(recoveryOutput.lifeContextEffect.milestone, "confirm the recovery-safe re-entry milestone")
        XCTAssertTrue(recoveryOutput.lifeContextEffect.startHereExplanation.contains("older injury or blocked-attempt context keeps the plan conservative"))
        XCTAssertTrue(recoveryTrace.lifeContext.sourceFreshnessStates.contains { $0.contains("based_on_older_context") || $0.contains("stale") })
        XCTAssertFalse(recoveryTraceEncoded.contains("PATIENT-DETAIL-MARKER"))

        let pausedBundle = recoveryBundle.markHistoricalFactPaused(id: "fact.recovery.attempt", at: "2026-05-22T13:00:00Z")
        let deletedBundle = recoveryBundle.markHistoricalFactDeleted(id: "fact.recovery.attempt", at: "2026-05-22T13:00:00Z")
        let pausedInput = makeInput(
            bundle: pausedBundle,
            goalText: recoveryGoalText,
            decisionKey: "today.start-here",
            recommendationID: "decision.recovery.paused"
        )
        let deletedInput = makeInput(
            bundle: deletedBundle,
            goalText: recoveryGoalText,
            decisionKey: "today.start-here",
            recommendationID: "decision.recovery.deleted"
        )
        let pausedOutput = kernel.evaluate(pausedInput)
        let deletedOutput = kernel.evaluate(deletedInput)
        let pausedTrace = kernel.makeReplayableDecisionTrace(pausedInput)
        let deletedTrace = kernel.makeReplayableDecisionTrace(deletedInput)
        let pausedTraceEncoded = try encodedJSONString(pausedTrace)
        let deletedTraceEncoded = try encodedJSONString(deletedTrace)

        XCTAssertNotEqual(recoveryOutput.decisionID, pausedOutput.decisionID)
        XCTAssertNotEqual(recoveryOutput.decisionID, deletedOutput.decisionID)
        XCTAssertEqual(pausedOutput.lifeContextEffect.readiness, .review)
        XCTAssertEqual(deletedOutput.lifeContextEffect.readiness, .review)
        XCTAssertEqual(pausedTrace.lifeContext.excludedHistoryFactIDs, ["fact.recovery.attempt"])
        XCTAssertEqual(pausedTrace.lifeContext.excludedHistoryReasons, ["paused"])
        XCTAssertEqual(deletedTrace.lifeContext.excludedHistoryFactIDs, ["fact.recovery.attempt"])
        XCTAssertEqual(deletedTrace.lifeContext.excludedHistoryReasons, ["deleted"])
        XCTAssertFalse(pausedTrace.lifeContext.historyFactIDs.contains("fact.recovery.attempt"))
        XCTAssertFalse(deletedTrace.lifeContext.historyFactIDs.contains("fact.recovery.attempt"))
        XCTAssertTrue(pausedOutput.lifeContextEffect.startHereExplanation.contains("paused or deleted context stays out of the runtime path"))
        XCTAssertTrue(deletedOutput.lifeContextEffect.startHereExplanation.contains("paused or deleted context stays out of the runtime path"))
        XCTAssertTrue(pausedTrace.lifeContext.startHereExplanation.contains("paused or deleted context stays out of the runtime path"))
        XCTAssertTrue(deletedTrace.lifeContext.startHereExplanation.contains("paused or deleted context stays out of the runtime path"))
        XCTAssertTrue(pausedTrace.lifeContext.readiness == "review")
        XCTAssertTrue(deletedTrace.lifeContext.readiness == "review")
        XCTAssertFalse(pausedTraceEncoded.contains("PATIENT-DETAIL-MARKER"))
        XCTAssertFalse(deletedTraceEncoded.contains("PATIENT-DETAIL-MARKER"))
    }

    func testMissingLifeContextProjectionDegradesToClarificationWithoutCrashing() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let input = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: PrivateLifeRuntimeKernelTraceContext(
                runtimeContext: makeRuntimeContext(),
                goalText: "Launch my first portfolio."
            ),
            decisionKey: "today.start-here",
            goalText: "Launch my first portfolio.",
            recommendationTrace: makeRecommendationTrace(
                id: "trace.missing.life-context",
                recommendationID: "decision.missing.life-context"
            )
        )

        let output = kernel.evaluate(input)
        let trace = kernel.makeReplayableDecisionTrace(input)

        XCTAssertEqual(output.lifeContextEffect.readiness, .clarification)
        XCTAssertEqual(output.lifeContextEffect.cadence, "review before cadence")
        XCTAssertEqual(output.lifeContextEffect.milestone, "capture the missing context")
        XCTAssertTrue(output.lifeContextEffect.startHereExplanation.contains("clarification"))
        XCTAssertEqual(trace.lifeContext.readiness, "clarification")
        XCTAssertTrue(trace.lifeContext.missingContextQuestionIDs.isEmpty)
    }
}

private extension LifeContextRuntimeEffectProofTests {
    func makeInput(
        bundle: LifeContextBundle,
        goalText: String,
        decisionKey: String,
        recommendationID: String
    ) -> PrivateLifeRuntimeKernelDecisionInput {
        PrivateLifeRuntimeKernelDecisionInput(
            traceContext: PrivateLifeRuntimeKernelTraceContext(
                runtimeContext: makeRuntimeContext(),
                lifeContextProjection: bundle.projection(asOf: fixedNow),
                goalText: goalText
            ),
            decisionKey: decisionKey,
            goalText: goalText,
            recommendationTrace: makeRecommendationTrace(
                id: "trace.\(recommendationID)",
                recommendationID: recommendationID
            )
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
        let syncStatus = SyncCapabilityStatus(
            backendKind: .localOnly,
            trustPosture: .localOnly,
            availability: .unavailable,
            detail: "Ambitions is running in explicit local-only mode."
        )
        let knowledgeStatus = KnowledgeProviderStatus(
            provider: KnowledgeProviderDescriptor(
                id: "local-only",
                type: .systemFallback,
                displayName: "Local-only fallback"
            ),
            availability: .localOnlyMode,
            detail: "Knowledge retrieval is unavailable while Ambitions remains local-only.",
            runtimeTrustPosture: .localOnly
        )

        return RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: syncStatus,
            knowledgeProviderStatuses: [knowledgeStatus],
            memorySummary: RuntimeMemorySummary(memory: memory),
            externalSurfaceSnapshot: nil
        )
    }

    func makeRecommendationTrace(
        id: String,
        recommendationID: String,
        receiptBehavior: RecommendationTraceReceiptBehavior = .available(receiptIDs: ["receipt.local"], proofReferenceIDs: ["proof.local"])
    ) -> RecommendationTrace {
        RecommendationTrace(
            id: id,
            recommendationID: recommendationID,
            source: RecommendationTraceSource(
                citedSourceIDs: ["source.local"],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.goalState],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "why-now.local",
                summary: "Local runtime data supports this decision.",
                evidenceCategoryIDs: [RecommendationExplanationEvidenceCategory.goalState.rawValue]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.local"],
                summaries: ["The recommendation remains revisable if the context changes."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["control.local"],
                controlActionIDs: ["open_step"],
                correctableFieldKeys: ["goalID"],
                hasRequiredControl: true
            ),
            receiptBehavior: receiptBehavior
        )
    }

    var fixedNow: Date {
        try! XCTUnwrap(DomainTimestamp.date(from: "2026-05-22T12:00:00Z"))
    }

    func makeRecoveryReviewBundle() -> LifeContextBundle {
        let source = LifeContextSource(
            id: "source.recovery.review",
            label: "Recovery interview",
            kind: .userConfirmed,
            timestamp: "2024-01-01T00:00:00Z",
            visibleExplanation: "The recovery history came from a prior interview."
        )

        return LifeContextBundle(
            id: "bundle.recovery.review",
            profile: LifeContextProfile(
                id: "profile.recovery.review",
                exactAgeYears: 28,
                timezone: "America/New_York",
                locale: "en_US",
                generalLocationLabel: "Home base",
                locationPrecision: .cityRegion,
                lifeStage: .adult,
                schoolOrWorkContext: "Training around work",
                travelRadiusMinutes: 45,
                travelRadiusMiles: 20,
                transportationAccess: .car,
                scheduleAnchors: ["morning work block", "evening recovery"],
                dependencyConstraints: ["Needs a slower re-entry because of prior setbacks."],
                budgetConstraintBand: .moderate,
                energyPattern: .morning,
                recoveryConstraints: ["Return carefully after injury."],
                accessibilityNeeds: [],
                userNotes: "Recovery-safe re-entry needs review."
            ),
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "pathway.recovery.review",
                    pathwayType: .health,
                    eligibilityRulesSummary: "Recover gradually before resuming normal training.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 18, upperBoundYears: nil),
                    locationDependent: false,
                    source: source,
                    freshness: .current,
                    userConfirmed: true
                )
            ],
            historicalFacts: [
                HistoricalContextFact(
                    id: "fact.recovery.injury",
                    category: .injuryLimitation,
                    title: "Knee recovery limitation",
                    detail: "PATIENT-DETAIL-MARKER should not leak into replay.",
                    dateRange: LifeContextDateRange(start: "2024-04-01", end: "2024-10-01"),
                    confidence: 0.95,
                    sourceType: .userToldAmbitions,
                    freshness: .basedOnOlderContext,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.recovery, .safety],
                    createdAt: "2024-01-01T00:00:00Z",
                    updatedAt: "2024-01-01T00:00:00Z",
                    confirmedAt: "2024-01-01T00:00:00Z"
                ),
                HistoricalContextFact(
                    id: "fact.recovery.attempt",
                    category: .priorAttempt,
                    title: "Blocked comeback attempt",
                    detail: "PATIENT-DETAIL-MARKER should stay hidden from replay.",
                    dateRange: LifeContextDateRange(start: "2024-02-01", end: "2024-05-01"),
                    confidence: 0.8,
                    sourceType: .userToldAmbitions,
                    freshness: .basedOnOlderContext,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.recovery, .sequencing],
                    createdAt: "2024-01-01T00:00:00Z",
                    updatedAt: "2024-01-01T00:00:00Z",
                    confirmedAt: "2024-01-01T00:00:00Z"
                )
            ],
            sources: [source],
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-01T00:00:00Z"
        )
    }

    func encodedJSONString(_ trace: ReplayableDecisionTrace) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(trace)
        return String(decoding: data, as: UTF8.self)
    }
}
