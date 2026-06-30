import XCTest
@testable import Ambitions

final class PersonalizationFactorLedgerTests: XCTestCase {
    func testSameBucketDifferentRealityChangesLedgerAndRejectedCandidates() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let sharedGoalText = "Make varsity football by the deadline."

        let flexibleBundle = makeFootballBundle(
            id: "bundle.football.flexible",
            exactAgeYears: 17,
            locationLabel: "Metro region",
            transportationAccess: .car,
            travelRadiusMinutes: 40,
            travelRadiusMiles: 18,
            scheduleAnchors: ["after-school lift", "weekend training"],
            dependencyConstraints: [],
            energyPattern: .morning,
            recoveryConstraints: [],
            accessibilityNeeds: [],
            userNotes: "Independent access with stable training windows.",
            schoolOrWorkContext: "High school football and classes",
            opportunityContexts: [
                makeOpportunity(
                    id: "opportunity.flexible.gym",
                    facilities: [.gym, .field],
                    equipmentAccess: ["basic weights", "cones"],
                    localOrganizations: ["Regional football club"],
                    seasonalAvailability: "Fall season",
                    verificationStatus: .verified
                )
            ],
            historicalFacts: [
                makeHistoricalFact(
                    id: "fact.flexible.success",
                    category: .pastAchievement,
                    title: "Recent training success",
                    detail: "Consistent reps are working.",
                    freshness: .current,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.feasibility, .sequencing]
                )
            ]
        )

        let constrainedBundle = makeFootballBundle(
            id: "bundle.football.constrained",
            exactAgeYears: 17,
            locationLabel: "Metro region",
            transportationAccess: .parentGuardian,
            travelRadiusMinutes: 15,
            travelRadiusMiles: 6,
            scheduleAnchors: ["family ride only", "class schedule"],
            dependencyConstraints: ["Parent ride required to reach training."],
            energyPattern: .variable,
            recoveryConstraints: ["Protect recovery after a recent setback."],
            accessibilityNeeds: ["Need shorter, lower-impact sessions."],
            userNotes: "Needs explicit ride timing and a cautious re-entry path.",
            schoolOrWorkContext: "High school football and classes",
            opportunityContexts: [],
            historicalFacts: [
                makeHistoricalFact(
                    id: "fact.constrained.injury",
                    category: .injuryLimitation,
                    title: "Older injury context",
                    detail: "Recovery context stays conservative.",
                    freshness: .stale,
                    sensitivity: .sensitive,
                    runtimeUseAllowed: false,
                    usedFor: [.recovery, .safety]
                ),
                makeHistoricalFact(
                    id: "fact.constrained.failed-attempt",
                    category: .priorAttempt,
                    title: "Failed comeback attempt",
                    detail: "A previous attempt did not hold.",
                    freshness: .basedOnOlderContext,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.recovery, .sequencing]
                )
            ],
            sources: [
                makeSource(id: "source.constrained.primary", label: "Parent interview", timestamp: "2021-05-22T00:00:00Z", visibleExplanation: "Older context that now needs review.")
            ]
        )

        let flexibleOutput = kernel.evaluate(makeInput(bundle: flexibleBundle, goalText: sharedGoalText, recommendationID: "decision.flexible"))
        let constrainedOutput = kernel.evaluate(makeInput(bundle: constrainedBundle, goalText: sharedGoalText, recommendationID: "decision.constrained"))

        XCTAssertNotEqual(flexibleOutput.lifeContextEffect.cadence, constrainedOutput.lifeContextEffect.cadence)
        XCTAssertNotEqual(flexibleOutput.personalizationFactorLedger.explanationProjection.summary, constrainedOutput.personalizationFactorLedger.explanationProjection.summary)
        XCTAssertNotEqual(flexibleOutput.personalizationFactorLedger.rejectedCandidateIDs, constrainedOutput.personalizationFactorLedger.rejectedCandidateIDs)
        XCTAssertNotEqual(flexibleOutput.personalizationFactorLedger.replayProjection.stableFingerprint, constrainedOutput.personalizationFactorLedger.replayProjection.stableFingerprint)
        XCTAssertTrue(constrainedOutput.personalizationFactorLedger.rejectedCandidateIDs.contains("candidate.recent_drift"))
        XCTAssertTrue(constrainedOutput.personalizationFactorLedger.rejectedCandidateIDs.contains("candidate.safety_constraint"))
        XCTAssertTrue(constrainedOutput.personalizationFactorLedger.sensitiveFactorUsage.blockedFactorIDs.contains("factor.safety_constraint"))
    }

    func testRecommendationRejectionLearningSignalIsProjectedIntoLedger() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let bundle = makeAdultBundle(
            id: "bundle.runtime.learning",
            exactAgeYears: 24,
            userNotes: "Local runtime learning should stay inspectable.",
            historicalFacts: [
                makeHistoricalFact(
                    id: "fact.runtime.learning",
                    category: .priorAttempt,
                    title: "Rejected once",
                    detail: "The same recommendation was already rejected locally.",
                    freshness: .current,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.recovery, .sequencing]
                )
            ]
        )
        let correction = CorrectionFoldRecord.recommendation(
            id: "correction.runtime.learning",
            recommendationID: "decision.runtime.learning",
            from: .stillUseful,
            to: .rejectedWrongGoal,
            reason: "Wrong goal fit should stay downranked.",
            occurredAt: "2026-05-22T12:30:00Z",
            allowsFutureLearning: true
        )
        let influence = try XCTUnwrap(
            CorrectionFoldRecommendationLearningInfluence(
                correction: correction,
                similarRecommendationSignalKeys: ["goal_requirement", "goal_state"]
            )
        )
        let input = PrivateLifeRuntimeKernelDecisionInput(
            traceContext: PrivateLifeRuntimeKernelTraceContext(
                runtimeContext: makeRuntimeContext(),
                lifeContextProjection: bundle.projection(asOf: fixedNow),
                goalText: "Stay local and focused."
            ),
            decisionKey: "today.start-here",
            goalText: "Stay local and focused.",
            recommendationTrace: makeRecommendationTrace(
                id: "trace.runtime.learning",
                recommendationID: "decision.runtime.learning",
                rejectionLearningInfluences: [influence]
            )
        )

        let ledger = kernel.evaluate(input).personalizationFactorLedger

        XCTAssertEqual(ledger.personalRuntimeLearningSignals.count, 1)
        XCTAssertEqual(ledger.personalRuntimeLearningSignals.first?.id, "learning.correction.runtime.learning")
        XCTAssertEqual(ledger.personalRuntimeLearningSignals.first?.correctionRecordID, "correction.runtime.learning")
        XCTAssertEqual(ledger.personalRuntimeLearningSignals.first?.recommendationID, "decision.runtime.learning")
        XCTAssertEqual(ledger.personalRuntimeLearningSignals.first?.rejectionReason, .rejectedWrongGoal)
        XCTAssertEqual(ledger.personalRuntimeLearningSignals.first?.adjustment, .downrankWrongGoal)
        XCTAssertTrue(ledger.personalRuntimeLearningSignals.first?.personalRuntimeInspectableSummary.contains("goal fit is reviewed") ?? false)
        XCTAssertEqual(ledger.personalRuntimeLearningSignals.first?.personalRuntimeResetRoute, "you://personal-runtime/decision.runtime.learning/reset")
        XCTAssertEqual(ledger.personalRuntimeLearningSignals.first?.personalRuntimeDisableRoute, "you://personal-runtime/decision.runtime.learning/disable")
        XCTAssertEqual(ledger.personalRuntimeLearningSignals.first?.personalRuntimeDeleteRoute, "you://personal-runtime/decision.runtime.learning/delete")
        XCTAssertTrue(ledger.personalRuntimeLearningSignals.first?.isInspectableAndControllable ?? false)
        XCTAssertEqual(ledger.personalRuntimeLearningSignals.first?.personalRuntimeInspectionLabel, "Local and source-tied")
        XCTAssertTrue(ledger.learningSignalIDs.contains("learning.correction.runtime.learning"))
        XCTAssertTrue(ledger.visibleCopy.contains("you://personal-runtime/decision.runtime.learning/disable"))
        XCTAssertTrue(ledger.visibleCopy.contains(where: { $0.contains("goal fit is reviewed") }))
    }

    func testDifferentDemographicsSameRealityConvergesOnPlanShape() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let goalText = "Train consistently for a long season."

        let womanBundle = makeAdultBundle(
            id: "bundle.adult.woman",
            exactAgeYears: 22,
            sexOrEligibilityContext: "woman",
            userNotes: "Stable adult training context.",
            sourceTimestamp: "2026-05-22T00:00:00Z"
        )
        let manBundle = makeAdultBundle(
            id: "bundle.adult.man",
            exactAgeYears: 25,
            sexOrEligibilityContext: "man",
            userNotes: "Stable adult training context.",
            sourceTimestamp: "2026-05-22T00:00:00Z"
        )

        let womanOutput = kernel.evaluate(makeInput(bundle: womanBundle, goalText: goalText, recommendationID: "decision.woman"))
        let manOutput = kernel.evaluate(makeInput(bundle: manBundle, goalText: goalText, recommendationID: "decision.man"))

        XCTAssertNotEqual(womanOutput.decisionID, manOutput.decisionID)
        XCTAssertEqual(womanOutput.lifeContextEffect.cadence, manOutput.lifeContextEffect.cadence)
        XCTAssertEqual(womanOutput.lifeContextEffect.urgency, manOutput.lifeContextEffect.urgency)
        XCTAssertEqual(womanOutput.lifeContextEffect.milestone, manOutput.lifeContextEffect.milestone)
        XCTAssertEqual(womanOutput.lifeContextEffect.startHereExplanation, manOutput.lifeContextEffect.startHereExplanation)
        XCTAssertEqual(womanOutput.personalizationFactorLedger.explanationProjection.summary, manOutput.personalizationFactorLedger.explanationProjection.summary)
        XCTAssertEqual(womanOutput.personalizationFactorLedger.replayProjection.stableFingerprint, manOutput.personalizationFactorLedger.replayProjection.stableFingerprint)
        XCTAssertEqual(womanOutput.personalizationFactorLedger.factors.map(\.factorType), manOutput.personalizationFactorLedger.factors.map(\.factorType))
    }

    func testConstraintRemovalChangesOnlyLocalFactors() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let goalText = "Keep training local and consistent."

        let baseBundle = makeAdultBundle(
            id: "bundle.constraint.base",
            exactAgeYears: 24,
            userNotes: "Training stays local to the current facilities.",
            opportunityContexts: [
                makeOpportunity(
                    id: "opportunity.base.gym",
                    facilities: [.gym, .field],
                    equipmentAccess: ["dumbbells", "cones"],
                    localOrganizations: ["Neighborhood gym"],
                    seasonalAvailability: "Spring season",
                    verificationStatus: .verified
                )
            ],
            historicalFacts: [
                makeHistoricalFact(
                    id: "fact.base.success",
                    category: .pastAchievement,
                    title: "Recent success",
                    detail: "Short sessions have been working.",
                    freshness: .current,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.feasibility, .sequencing]
                )
            ]
        )
        let removedFacilityBundle = baseBundle.updated(opportunityContexts: [], updatedAt: "2026-05-22T12:30:00Z")

        let baseLedger = kernel.evaluate(makeInput(bundle: baseBundle, goalText: goalText, recommendationID: "decision.base")).personalizationFactorLedger
        let removedLedger = kernel.evaluate(makeInput(bundle: removedFacilityBundle, goalText: goalText, recommendationID: "decision.removed")).personalizationFactorLedger

        let baseFactorTypes = Set(baseLedger.factors.map(\.factorType))
        let removedFactorTypes = Set(removedLedger.factors.map(\.factorType))
        let sharedBase = baseFactorTypes.subtracting([.facilityAccess, .equipmentAccess, .seasonality])
        let sharedRemoved = removedFactorTypes.subtracting([.facilityAccess, .equipmentAccess, .seasonality])

        XCTAssertEqual(sharedBase, sharedRemoved)
        XCTAssertTrue(baseFactorTypes.contains(.facilityAccess))
        XCTAssertTrue(baseFactorTypes.contains(.equipmentAccess))
        XCTAssertTrue(baseFactorTypes.contains(.seasonality))
        XCTAssertFalse(removedFactorTypes.contains(.facilityAccess))
        XCTAssertFalse(removedFactorTypes.contains(.equipmentAccess))
        XCTAssertFalse(removedFactorTypes.contains(.seasonality))
    }

    func testSensitiveContextDisabledDropsSafetyFactorAndLeavesFallbackEvidence() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let goalText = "Return to training after recovery."

        let blockedBundle = makeAdultBundle(
            id: "bundle.sensitive.blocked",
            exactAgeYears: 27,
            userNotes: "Recovery context is blocked until explicitly allowed.",
            historicalFacts: [
                makeHistoricalFact(
                    id: "fact.sensitive.health",
                    category: .healthBaseline,
                    title: "Sensitive health note",
                    detail: "Private recovery detail.",
                    freshness: .current,
                    sensitivity: .sensitive,
                    runtimeUseAllowed: false,
                    usedFor: [.safety, .recovery]
                )
            ],
            recoveryConstraints: ["Return carefully after injury."]
        )
        let enabledBundle = makeAdultBundle(
            id: "bundle.sensitive.enabled",
            exactAgeYears: 27,
            userNotes: "Recovery context has been removed from runtime use.",
            historicalFacts: [],
            recoveryConstraints: ["Return carefully after injury."]
        )

        let blockedLedger = kernel.evaluate(makeInput(bundle: blockedBundle, goalText: goalText, recommendationID: "decision.blocked")).personalizationFactorLedger
        let enabledLedger = kernel.evaluate(makeInput(bundle: enabledBundle, goalText: goalText, recommendationID: "decision.enabled")).personalizationFactorLedger

        XCTAssertTrue(blockedLedger.factors.contains(where: { $0.factorType == PersonalizationFactorLedgerFactorType.safetyConstraint }))
        XCTAssertFalse(enabledLedger.factors.contains(where: { $0.factorType == PersonalizationFactorLedgerFactorType.safetyConstraint }))
        XCTAssertFalse(blockedLedger.factors.first(where: { $0.factorType == PersonalizationFactorLedgerFactorType.recoveryConstraint })?.allowedForRuntimeUse ?? true)
        XCTAssertTrue(blockedLedger.sensitiveFactorUsage.blockedFactorIDs.contains("factor.recovery_constraint"))
        XCTAssertTrue(blockedLedger.sensitiveFactorUsage.blockedFactorIDs.contains("factor.safety_constraint"))
        XCTAssertTrue(blockedLedger.factors.first(where: { $0.factorType == PersonalizationFactorLedgerFactorType.safetyConstraint })?.fallbackBehaviorIfRemoved.contains("non-sensitive context") ?? false)
        XCTAssertTrue(blockedLedger.rejectedCandidateIDs.contains("candidate.safety_constraint"))
        XCTAssertNotEqual(blockedLedger.replayProjection.stableFingerprint, enabledLedger.replayProjection.stableFingerprint)
    }

    func testStaleFreshnessLowersConfidenceAndMarksReviewNeeded() throws {
        let kernel = PrivateLifeRuntimeKernel()
        let goalText = "Resume training safely."

        let staleBundle = makeAdultBundle(
            id: "bundle.stale.context",
            exactAgeYears: 31,
            userNotes: "Context comes from older records that need review.",
            sourceTimestamp: "2021-05-22T00:00:00Z",
            historicalFacts: [
                makeHistoricalFact(
                    id: "fact.stale.success",
                    category: .pastAchievement,
                    title: "Older success",
                    detail: "This should still be reviewed.",
                    freshness: .basedOnOlderContext,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.feasibility, .sequencing]
                )
            ]
        )

        let ledger = kernel.evaluate(makeInput(bundle: staleBundle, goalText: goalText, recommendationID: "decision.stale")).personalizationFactorLedger

        XCTAssertEqual(ledger.confidenceBand, .reviewNeeded)
        XCTAssertTrue(ledger.factors.contains(where: { $0.factorType == .recentDrift && $0.freshness.state == .stale }))
        XCTAssertGreaterThan(ledger.freshnessProjection.staleFactorCount, 0)
        XCTAssertTrue(ledger.explanationProjection.summary.localizedCaseInsensitiveContains("confidence is review needed"))
        XCTAssertTrue(ledger.missingContextQuestions.isEmpty)
    }

    func testReplayIsDeterministicForSameRuntimeVersionAndContext() throws {
        let builder = PersonalizationFactorLedgerBuilder()
        let fixedGeneratedAt = try XCTUnwrap(DomainTimestamp.date(from: "2026-05-22T12:00:00Z"))
        let bundle = makeAdultBundle(
            id: "bundle.deterministic",
            exactAgeYears: 28,
            userNotes: "Stable deterministic runtime context.",
            opportunityContexts: [
                makeOpportunity(
                    id: "opportunity.deterministic",
                    facilities: [.gym],
                    equipmentAccess: ["bike", "dumbbells"],
                    localOrganizations: ["City gym"],
                    seasonalAvailability: "Year-round",
                    verificationStatus: .verified
                )
            ],
            historicalFacts: [
                makeHistoricalFact(
                    id: "fact.deterministic.success",
                    category: .pastAchievement,
                    title: "Deterministic success",
                    detail: "Repeatable context.",
                    freshness: .current,
                    sensitivity: .normal,
                    runtimeUseAllowed: true,
                    usedFor: [.feasibility, .sequencing]
                )
            ]
        )
        let projection = bundle.projection(asOf: fixedGeneratedAt)
        let trace = makeRecommendationTrace(
            id: "trace.deterministic",
            recommendationID: "decision.deterministic"
        )
        let input = PersonalizationFactorLedgerInput(
            goalID: "goal.deterministic",
            goalText: "Keep training consistent.",
            projection: projection,
            recommendationTrace: trace,
            generatedAt: fixedGeneratedAt,
            runtimeVersion: "private_life_runtime.factor_ledger.v1",
            userContextVersion: "life-context.deterministic"
        )

        let firstLedger = builder.build(input)
        let secondLedger = builder.build(input)

        XCTAssertEqual(firstLedger, secondLedger)
        XCTAssertEqual(firstLedger.replayProjection.stableFingerprint, secondLedger.replayProjection.stableFingerprint)
        XCTAssertEqual(firstLedger.factors.map(\.id), secondLedger.factors.map(\.id))
        XCTAssertEqual(firstLedger.rejectedCandidateIDs, secondLedger.rejectedCandidateIDs)
    }
}

private extension PersonalizationFactorLedgerTests {
    func makeInput(
        bundle: LifeContextBundle,
        goalText: String,
        recommendationID: String
    ) -> PrivateLifeRuntimeKernelDecisionInput {
        PrivateLifeRuntimeKernelDecisionInput(
            traceContext: PrivateLifeRuntimeKernelTraceContext(
                runtimeContext: makeRuntimeContext(),
                lifeContextProjection: bundle.projection(asOf: fixedNow),
                goalText: goalText
            ),
            decisionKey: "today.start-here",
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
        receiptBehavior: RecommendationTraceReceiptBehavior = .available(receiptIDs: ["receipt.local"], proofReferenceIDs: ["proof.local"]),
        rejectionLearningInfluences: [CorrectionFoldRecommendationLearningInfluence] = []
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
            receiptBehavior: receiptBehavior,
            rejectionLearningInfluences: rejectionLearningInfluences
        )
    }

    func makeFootballBundle(
        id: String,
        exactAgeYears: Int,
        locationLabel: String,
        transportationAccess: LifeContextTransportationAccess,
        travelRadiusMinutes: Int,
        travelRadiusMiles: Double,
        scheduleAnchors: [String],
        dependencyConstraints: [String],
        energyPattern: LifeContextEnergyPattern,
        recoveryConstraints: [String],
        accessibilityNeeds: [String],
        userNotes: String,
        schoolOrWorkContext: String,
        opportunityContexts: [OpportunityContext],
        historicalFacts: [HistoricalContextFact],
        sources: [LifeContextSource] = []
    ) -> LifeContextBundle {
        makeBundle(
            id: id,
            exactAgeYears: exactAgeYears,
            sexOrEligibilityContext: "football",
            timezone: "America/New_York",
            locale: "en_US",
            generalLocationLabel: locationLabel,
            locationPrecision: .cityRegion,
            lifeStage: .highSchool,
            schoolOrWorkContext: schoolOrWorkContext,
            travelRadiusMinutes: travelRadiusMinutes,
            travelRadiusMiles: travelRadiusMiles,
            transportationAccess: transportationAccess,
            scheduleAnchors: scheduleAnchors,
            dependencyConstraints: dependencyConstraints,
            budgetConstraintBand: .moderate,
            energyPattern: energyPattern,
            recoveryConstraints: recoveryConstraints,
            accessibilityNeeds: accessibilityNeeds,
            userNotes: userNotes,
            opportunityContexts: opportunityContexts,
            historicalFacts: historicalFacts,
            sources: sources.isEmpty ? [makeSource(id: "\(id).source", label: "Interview", timestamp: "2026-05-22T00:00:00Z", visibleExplanation: "Seeded from a local interview.")] : sources,
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "\(id).pathway",
                    pathwayType: .sport,
                    eligibilityRulesSummary: "Football pathway with local access realities.",
                    ageWindow: LifeContextAgeWindow(lowerBoundYears: 14, upperBoundYears: 18),
                    gradeWindow: "High school",
                    sexLeaguePathway: nil,
                    locationDependent: true,
                    source: makeSource(id: "\(id).pathway.source", label: "School handbook", timestamp: "2026-05-22T00:00:00Z", visibleExplanation: "School pathway rules are locally confirmed."),
                    freshness: .current,
                    userConfirmed: true
                )
            ]
        )
    }

    func makeAdultBundle(
        id: String,
        exactAgeYears: Int,
        sexOrEligibilityContext: String? = nil,
        userNotes: String,
        sourceTimestamp: String = "2026-05-22T00:00:00Z",
        opportunityContexts: [OpportunityContext] = [],
        historicalFacts: [HistoricalContextFact] = [],
        recoveryConstraints: [String] = [],
        budgetConstraintBand: LifeContextBudgetConstraintBand = .moderate
    ) -> LifeContextBundle {
        makeBundle(
            id: id,
            exactAgeYears: exactAgeYears,
            sexOrEligibilityContext: sexOrEligibilityContext,
            timezone: "America/New_York",
            locale: "en_US",
            generalLocationLabel: "Metro area",
            locationPrecision: .cityRegion,
            lifeStage: .adult,
            schoolOrWorkContext: "Adult work and training",
            travelRadiusMinutes: 30,
            travelRadiusMiles: 12,
            transportationAccess: .car,
            scheduleAnchors: ["morning block", "evening block"],
            dependencyConstraints: [],
            budgetConstraintBand: budgetConstraintBand,
            energyPattern: .morning,
            recoveryConstraints: recoveryConstraints,
            accessibilityNeeds: [],
            userNotes: userNotes,
            opportunityContexts: opportunityContexts,
            historicalFacts: historicalFacts,
            sources: [
                makeSource(id: "\(id).source", label: "Local interview", timestamp: sourceTimestamp, visibleExplanation: "Seeded from a local interview.")
            ],
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "\(id).pathway",
                    pathwayType: .career,
                    eligibilityRulesSummary: "Adult career path with shared training realities.",
                    locationDependent: false,
                    source: makeSource(id: "\(id).pathway.source", label: "Personal notes", timestamp: sourceTimestamp, visibleExplanation: "The pathway was confirmed locally."),
                    freshness: .current,
                    userConfirmed: true
                )
            ]
        )
    }

    func makeBundle(
        id: String,
        exactAgeYears: Int,
        sexOrEligibilityContext: String?,
        timezone: String,
        locale: String,
        generalLocationLabel: String,
        locationPrecision: LifeContextLocationPrecision,
        lifeStage: LifeContextLifeStage,
        schoolOrWorkContext: String?,
        travelRadiusMinutes: Int,
        travelRadiusMiles: Double,
        transportationAccess: LifeContextTransportationAccess,
        scheduleAnchors: [String],
        dependencyConstraints: [String],
        budgetConstraintBand: LifeContextBudgetConstraintBand,
        energyPattern: LifeContextEnergyPattern,
        recoveryConstraints: [String],
        accessibilityNeeds: [String],
        userNotes: String,
        opportunityContexts: [OpportunityContext],
        historicalFacts: [HistoricalContextFact],
        sources: [LifeContextSource],
        eligibilityPathways: [LifeContextEligibilityPathway]
    ) -> LifeContextBundle {
        LifeContextBundle(
            id: id,
            profile: LifeContextProfile(
                id: "\(id).profile",
                exactAgeYears: exactAgeYears,
                timezone: timezone,
                locale: locale,
                generalLocationLabel: generalLocationLabel,
                locationPrecision: locationPrecision,
                sexOrEligibilityContext: sexOrEligibilityContext,
                lifeStage: lifeStage,
                schoolOrWorkContext: schoolOrWorkContext,
                travelRadiusMinutes: travelRadiusMinutes,
                travelRadiusMiles: travelRadiusMiles,
                transportationAccess: transportationAccess,
                scheduleAnchors: scheduleAnchors,
                dependencyConstraints: dependencyConstraints,
                budgetConstraintBand: budgetConstraintBand,
                energyPattern: energyPattern,
                recoveryConstraints: recoveryConstraints,
                accessibilityNeeds: accessibilityNeeds,
                userNotes: userNotes
            ),
            eligibilityPathways: eligibilityPathways,
            opportunityContexts: opportunityContexts,
            historicalFacts: historicalFacts,
            sources: sources,
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z"
        )
    }

    func makeSource(
        id: String,
        label: String,
        timestamp: String,
        visibleExplanation: String
    ) -> LifeContextSource {
        LifeContextSource(
            id: id,
            label: label,
            kind: .userConfirmed,
            timestamp: timestamp,
            visibleExplanation: visibleExplanation
        )
    }

    func makeOpportunity(
        id: String,
        facilities: [LifeContextFacility],
        equipmentAccess: [String] = [],
        localOrganizations: [String] = [],
        seasonalAvailability: String? = nil,
        verificationStatus: LifeContextVerificationStatus = .verified
    ) -> OpportunityContext {
        OpportunityContext(
            id: id,
            facilities: facilities,
            equipmentAccess: equipmentAccess,
            localOrganizations: localOrganizations,
            seasonalAvailability: seasonalAvailability,
            verificationStatus: verificationStatus
        )
    }

    func makeHistoricalFact(
        id: String,
        category: HistoricalContextFactCategory,
        title: String,
        detail: String,
        freshness: HistoricalContextFactFreshness,
        sensitivity: HistoricalContextFactSensitivity,
        runtimeUseAllowed: Bool,
        usedFor: [HistoricalContextFactUse]
    ) -> HistoricalContextFact {
        HistoricalContextFact(
            id: id,
            category: category,
            title: title,
            detail: detail,
            confidence: 0.9,
            sourceType: .userToldAmbitions,
            freshness: freshness,
            sensitivity: sensitivity,
            runtimeUseAllowed: runtimeUseAllowed,
            usedFor: usedFor,
            createdAt: "2026-05-22T00:00:00Z",
            updatedAt: "2026-05-22T00:00:00Z",
            confirmedAt: "2026-05-22T00:00:00Z"
        )
    }

    var fixedNow: Date {
        try! XCTUnwrap(DomainTimestamp.date(from: "2026-05-22T12:00:00Z"))
    }
}
