import Foundation

extension PrivateLifeRuntimeKernel {
    func evaluate(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionOutput {
        let record = makeDecisionRecord(input)
        let personalizationFactorLedger = record?.personalizationFactorLedger ?? makePersonalizationFactorLedger(
            for: input,
            decisionRecord: nil,
            decisionOutput: nil
        )
        let lifeContextEffect = record?.lifeContextEffect ?? makeLifeContextEffect(
            goalText: input.goalText ?? input.traceContext.goalText,
            projection: input.traceContext.lifeContextProjection
        )
        let lifeContextSignature = record?.lifeContextSignature ?? lifeContextSignature(
            goalText: input.goalText ?? input.traceContext.goalText,
            projection: input.traceContext.lifeContextProjection
        )

        return PrivateLifeRuntimeKernelDecisionOutput(
            decisionID: decisionIdentifier(for: input, traceShape: record?.traceShape),
            boundary: boundary,
            canDriveRecommendation: record?.canDriveRecommendation ?? false,
            hasRecommendationTrace: record != nil,
            traceShape: record?.traceShape,
            recordID: record?.id,
            personalizationFactorLedger: personalizationFactorLedger,
            lifeContextEffect: lifeContextEffect,
            lifeContextSignature: lifeContextSignature
        )
    }


    func makeDecisionRecord(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionRecord? {
        guard let recommendationTrace = input.recommendationTrace else {
            return nil
        }

        let canDriveRecommendation = canDriveRecommendation(
            traceContext: input.traceContext,
            recommendationTrace: recommendationTrace
        )
        let traceShape = traceShape(for: recommendationTrace)
        let personalizationFactorLedger = makePersonalizationFactorLedger(for: input)
        let lifeContextEffect = makeLifeContextEffect(
            goalText: input.goalText ?? input.traceContext.goalText,
            projection: input.traceContext.lifeContextProjection
        )
        let lifeContextSignature = lifeContextSignature(
            goalText: input.goalText ?? input.traceContext.goalText,
            projection: input.traceContext.lifeContextProjection
        )

        return PrivateLifeRuntimeKernelDecisionRecord(
            id: decisionIdentifier(for: input, traceShape: traceShape),
            decisionKey: input.decisionKey,
            goalText: input.goalText ?? input.traceContext.goalText,
            traceContext: input.traceContext,
            recommendationTrace: recommendationTrace,
            personalizationFactorLedger: personalizationFactorLedger,
            boundary: boundary,
            canDriveRecommendation: canDriveRecommendation,
            traceShape: traceShape,
            lifeContextEffect: lifeContextEffect,
            lifeContextSignature: lifeContextSignature
        )
    }


    func canDriveRecommendation(
        traceContext: PrivateLifeRuntimeKernelTraceContext,
        recommendationTrace: RecommendationTrace
    ) -> Bool {
        boundary.isLocalOnly &&
            traceContext.runtimeContext.capabilities.privateLifeRuntimeBoundary.isLocalOnly &&
            traceContext.runtimeContext.capabilities.hasRemoteIntelligenceBackend == false &&
            (traceContext.goalIntelligenceContext?.quarantine.canDriveRecommendation ?? true) &&
            recommendationTrace.isComplete &&
            recommendationTrace.canDriveRecommendationBehavior
    }


    func decisionIdentifier(
        for input: PrivateLifeRuntimeKernelDecisionInput,
        traceShape: String?
    ) -> String {
        let contextSignature = traceContextSignature(input.traceContext)
        let traceSignature = traceShape ?? "missing-trace"
        return [
            "plr",
            "decision",
            boundary.isLocalOnly ? "local-only" : "mixed",
            input.decisionKey.isEmpty ? "anonymous" : input.decisionKey,
            contextSignature,
            traceSignature
        ]
        .joined(separator: ".")
    }


    func traceContextSignature(_ traceContext: PrivateLifeRuntimeKernelTraceContext) -> String {
        let runtimeContext = traceContext.runtimeContext
        let knowledgeSignature = runtimeContext.knowledgeProviderStatuses
            .map { status in
                [
                    status.provider.id,
                    status.availability.rawValue,
                    status.runtimeTrustPosture.rawValue
                ]
                .joined(separator: ":")
            }
            .sorted()
            .joined(separator: ",")
        let goalIntelligenceSignature = goalIntelligenceSignature(traceContext.goalIntelligenceContext)
        let lifeContextSignature = lifeContextSignature(
            goalText: traceContext.goalText,
            projection: traceContext.lifeContextProjection
        )

        return [
            runtimeContext.clientContext.kind.rawValue,
            runtimeContext.capabilities.syncBackendKind.rawValue,
            runtimeContext.capabilities.privateLifeRuntimeBoundary.isLocalOnly ? "local" : "mixed",
            runtimeContext.capabilities.hasRemoteIntelligenceBackend ? "remote" : "local",
            runtimeContext.syncStatus.backendKind.rawValue,
            runtimeContext.syncStatus.availability.rawValue,
            "g\(runtimeContext.memorySummary.goalCount)",
            "d\(runtimeContext.memorySummary.draftCount)",
            "e\(runtimeContext.memorySummary.evidenceCount)",
            "f\(runtimeContext.memorySummary.feedbackCount)",
            "c\(runtimeContext.memorySummary.captureCount)",
            knowledgeSignature,
            goalIntelligenceSignature,
            lifeContextSignature
        ]
        .joined(separator: "|")
    }


    func goalIntelligenceSignature(_ context: RuntimeGoalIntelligenceContext?) -> String {
        guard let context else {
            return "goal-intelligence:none"
        }

        let sourceAuditSignature = Self.sourceAuditSignature(context.explainability.sourceAudit)
        let contradictionSignature = Self.contradictionSignature(context.explainability.contradictions)
        let controlSignature = Self.correctionControlSignature(context.explainability.correctionControls)
        let badgeSignature = Self.appliedTeachingBadgeSignature(context.explainability.appliedTeachingBadges)
        let explanationSignature = [
            Self.whisperSignature(context.explainability.whisper),
            Self.whyThisSignature(context.explainability.whyThis),
            sourceAuditSignature,
            Self.freshnessSignature(context.explainability.freshness),
            Self.confidenceSignature(context.explainability.confidence),
            contradictionSignature,
            controlSignature,
            badgeSignature
        ]
        .joined(separator: "|")

        let applicableSignalsSignature: String
        if let applicableSignals = context.applicableSignals {
            applicableSignalsSignature = [
                applicableSignals.goalID,
                applicableSignals.signals.map(\.id).sorted().joined(separator: ","),
                applicableSignals.supersededSignalIDs.sorted().joined(separator: ",")
            ]
            .joined(separator: "|")
        } else {
            applicableSignalsSignature = "none"
        }

        let whyNowSignature = context.whyNow.map { whyNow in
            [
                whyNow.conciseReason,
                whyNow.reasons.joined(separator: ",")
            ]
            .joined(separator: "|")
        } ?? "none"

        let quarantineSignature = [
            context.quarantine.issues.map(\.rawValue).sorted().joined(separator: ","),
            context.quarantine.canDriveRecommendation ? "drive" : "review",
            context.quarantine.disclosureSummary
        ]
        .joined(separator: "|")

        return [
            context.goalID ?? "no-goal",
            context.draftID ?? "no-draft",
            context.primaryStepID ?? "no-step",
            applicableSignalsSignature,
            explanationSignature,
            whyNowSignature,
            quarantineSignature
        ]
        .joined(separator: "|")
    }


    func makeLifeContextEffect(
        goalText: String?,
        projection: LifeContextRuntimeProjection?
    ) -> PrivateLifeRuntimeLifeContextEffect {
        let readiness = lifeContextReadiness(for: projection)
        let normalizedGoalTextValue = normalizeGoalText(goalText)
        let startHereTitle = normalizedGoalTextValue ?? "Start here"
        let explanation = lifeContextExplanation(
            goalText: startHereTitle,
            readiness: readiness,
            projection: projection
        )

        return PrivateLifeRuntimeLifeContextEffect(
            readiness: readiness,
            goalText: normalizedGoalTextValue,
            startHereTitle: startHereTitle,
            startHereExplanation: explanation,
            cadence: lifeContextCadence(for: projection, readiness: readiness),
            urgency: lifeContextUrgency(for: projection, readiness: readiness),
            milestone: lifeContextMilestone(for: projection, readiness: readiness),
            pathwayLabels: projection?.eligibilityModel.compactMap { pathway in
                normalizeGoalText(pathway.sexLeaguePathway) ?? normalizeGoalText(pathway.eligibilityRulesSummary)
            } ?? [],
            sourceFreshnessStates: projection?.sourceFreshnessSummary.map { "\($0.sourceID):\($0.freshness.rawValue)" } ?? [],
            historyFactIDs: projection?.historySummary.map(\.id) ?? [],
            excludedHistoryFactIDs: projection?.excludedHistorySummary.map(\.factID) ?? [],
            excludedHistoryReasons: projection?.excludedHistorySummary.map { $0.reason.rawValue } ?? [],
            missingContextQuestionIDs: projection?.missingContextQuestions.map(\.id) ?? [],
            opportunityAnchorIDs: projection?.availableOpportunityAnchors.map(\.id) ?? []
        )
    }


    func lifeContextSignature(
        goalText: String?,
        projection: LifeContextRuntimeProjection?
    ) -> String {
        let goalTextSignature = normalizeGoalText(goalText) ?? "goal:none"
        guard let projection else {
            return [
                goalTextSignature,
                "life-context:none"
            ]
            .joined(separator: "|")
        }

        let anchorSignature = projection.availableOpportunityAnchors.map { anchor in
            [
                anchor.id,
                anchor.title,
                anchor.verificationStatus.rawValue
            ]
            .joined(separator: ":")
        }
        .sorted()
        .joined(separator: ",")
        let hardConstraintSignature = projection.hardConstraints.map { "\($0.id):\($0.isHardConstraint ? "hard" : "soft")" }.joined(separator: ",")
        let softConstraintSignature = projection.softConstraints.map { "\($0.id):\($0.isHardConstraint ? "hard" : "soft")" }.joined(separator: ",")
        let eligibilitySignature = projection.eligibilityModel.map { pathway in
            [
                pathway.id,
                pathway.pathwayType.rawValue,
                pathway.freshness.rawValue,
                pathway.locationDependent ? "location" : "no-location",
                pathway.userConfirmed ? "confirmed" : "review",
                pathway.sexLeaguePathway ?? "no-sex-label"
            ]
            .joined(separator: ":")
        }
        .sorted()
        .joined(separator: ",")
        let historySignature = projection.historySummary.map { "\($0.id):\($0.freshness.rawValue)" }.joined(separator: ",")
        let exclusionSignature = projection.excludedHistorySummary.map { "\($0.factID):\($0.reason.rawValue)" }.joined(separator: ",")
        let freshnessSignature = projection.sourceFreshnessSummary.map { "\($0.sourceID):\($0.freshness.rawValue)" }.joined(separator: ",")
        let warningSignature = projection.sensitiveUseWarnings.map(\.factID).joined(separator: ",")
        let missingSignature = projection.missingContextQuestions.map(\.id).joined(separator: ",")

        return [
            goalTextSignature,
            "age:\(projection.ageYears.map(String.init) ?? "unknown")",
            "stage:\(projection.lifeStage.rawValue)",
            "travel:\(projection.travelModel.radiusMinutes.map(String.init) ?? "none")",
            "transport:\(projection.travelModel.transportationAccess.rawValue)",
            "anchors:\(anchorSignature)",
            "hard:\(hardConstraintSignature)",
            "soft:\(softConstraintSignature)",
            "pathways:\(eligibilitySignature)",
            "history:\(historySignature)",
            "freshness:\(freshnessSignature)",
            "warnings:\(warningSignature)",
            "missing:\(missingSignature)",
            "excluded:\(exclusionSignature)"
        ]
        .joined(separator: "|")
    }


    func lifeContextReadiness(for projection: LifeContextRuntimeProjection?) -> PrivateLifeRuntimeLifeContextReadiness {
        guard let projection else {
            return .clarification
        }
        if projection.missingContextQuestions.isEmpty == false {
            return .clarification
        }
        if projection.excludedHistorySummary.isEmpty == false {
            return .review
        }
        if projection.sourceFreshnessSummary.contains(where: { $0.freshness != .current }) {
            return .review
        }
        if projection.historySummary.contains(where: { $0.freshness != .current }) {
            return .review
        }
        if projection.sensitiveUseWarnings.isEmpty == false {
            return .review
        }
        return .ready
    }
}
