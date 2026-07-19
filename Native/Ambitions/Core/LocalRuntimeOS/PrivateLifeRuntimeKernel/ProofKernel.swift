import Foundation

struct ProofKernel: Sendable, Equatable {
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

    func lifeContextSignature(
        goalText: String?,
        projection: LifeContextRuntimeProjection?
    ) -> String {
        let goalTextSignature = normalized(goalText) ?? "goal:none"
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

    private func normalized(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }

    private static func whisperSignature(_ whisper: GoalTrustWhisperState) -> String {
        [
            whisper.title,
            whisper.subtitle,
            whisper.pillLine,
            whisper.pills.map { pill in
                [
                    pill.id,
                    pill.title,
                    pill.icon,
                    pill.state.rawValue
                ]
                .joined(separator: ":")
            }
            .sorted()
            .joined(separator: ",")
        ]
        .joined(separator: "|")
    }

    private static func whyThisSignature(_ whyThis: GoalWhyThisState) -> String {
        [
            whyThis.compactSummary,
            whyThis.lines.joined(separator: ",")
        ]
        .joined(separator: "|")
    }

    private static func freshnessSignature(_ freshness: GoalFreshnessState) -> String {
        [
            freshness.posture.rawValue,
            freshness.postureLabel,
            freshness.severityLabel,
            freshness.detailLabels.joined(separator: ",")
        ]
        .joined(separator: "|")
    }

    private static func confidenceSignature(_ confidence: GoalConfidenceState) -> String {
        [
            confidence.understandingConfidence.rawValue,
            confidence.pathConfidence?.rawValue ?? "none",
            confidence.detailLabels.joined(separator: ",")
        ]
        .joined(separator: "|")
    }

    private static func sourceAuditSignature(_ sourceAudit: GoalSourceAuditSectionState) -> String {
        sourceAudit.rows
            .map(Self.sourceAuditRowSignature)
            .sorted()
            .joined(separator: ",")
    }

    private static func sourceAuditRowSignature(_ row: GoalSourceAuditRowState) -> String {
        [
            row.id,
            row.resourceID,
            row.title,
            row.subtitle,
            row.detailLabels.joined(separator: ","),
            row.state.rawValue
        ]
        .joined(separator: ":")
    }

    private static func contradictionSignature(_ contradictions: [GoalContradictionSummaryState]) -> String {
        contradictions
            .map(Self.contradictionEntrySignature)
            .sorted()
            .joined(separator: ",")
    }

    private static func contradictionEntrySignature(_ contradiction: GoalContradictionSummaryState) -> String {
        [
            contradiction.id,
            contradiction.code.rawValue,
            contradiction.title,
            contradiction.summary,
            contradiction.severityLabel,
            contradiction.state.rawValue
        ]
        .joined(separator: ":")
    }

    private static func correctionControlSignature(_ controls: [GoalCorrectionControlState]) -> String {
        controls
            .map(Self.correctionControlEntrySignature)
            .sorted()
            .joined(separator: ",")
    }

    private static func correctionControlEntrySignature(_ control: GoalCorrectionControlState) -> String {
        [
            control.id,
            control.title,
            control.subtitle,
            control.kind.rawValue,
            control.artifactKind.rawValue,
            control.teachingSignalKind.rawValue,
            control.state.rawValue
        ]
        .joined(separator: ":")
    }

    private static func appliedTeachingBadgeSignature(_ badges: [GoalAppliedTeachingBadgeState]) -> String {
        badges
            .map(Self.appliedTeachingBadgeEntrySignature)
            .sorted()
            .joined(separator: ",")
    }

    private static func appliedTeachingBadgeEntrySignature(_ badge: GoalAppliedTeachingBadgeState) -> String {
        [
            badge.id,
            badge.signalID,
            badge.title,
            badge.subtitle,
            badge.state.rawValue
        ]
        .joined(separator: ":")
    }
}
