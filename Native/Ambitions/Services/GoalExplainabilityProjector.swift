import AmbitionsDesignSystem
import Foundation

protocol GoalExplainabilityProjecting: Sendable {
    func makeState(
        metadata: GoalOrchestrationMetadata,
        applicableSignals: GoalTeachingApplicableSet?,
        primaryStepID: String?,
        whyNow: WhyNowExplanationMetadata?
    ) -> GoalExplainabilityState
}

struct DefaultGoalExplainabilityProjector: GoalExplainabilityProjecting {
    func makeState(
        metadata: GoalOrchestrationMetadata,
        applicableSignals: GoalTeachingApplicableSet?,
        primaryStepID: String?,
        whyNow: WhyNowExplanationMetadata?
    ) -> GoalExplainabilityState {
        let resources = metadata.resourceGraph.resources.sorted(by: Self.resourceOrdering)
        let resourceRows = resources.map { resource in
            sourceAuditRow(resource: resource, metadata: metadata)
        }
        let contradictionRows = metadata.contradictionReport.records.map(contradictionSummary)
        let correctionControls = (
            resourceCorrectionControls(resources: resources, metadata: metadata)
            + contradictionCorrectionControls(records: metadata.contradictionReport.records)
            + energyCorrectionControls(metadata: metadata, primaryStepID: primaryStepID)
        )
        .sorted { lhs, rhs in
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            return lhs.id < rhs.id
        }

        return GoalExplainabilityState(
            whisper: whisperState(
                whyNow: whyNow,
                freshness: metadata.resourceGraph.freshness,
                understandingConfidence: metadata.understanding.confidence.overall,
                contradictionRows: contradictionRows,
                resourceRows: resourceRows
            ),
            whyThis: whyThisState(metadata: metadata, primaryStepID: primaryStepID, whyNow: whyNow),
            sourceAudit: GoalSourceAuditSectionState(rows: resourceRows),
            freshness: freshnessState(metadata.resourceGraph.freshness),
            confidence: confidenceState(metadata: metadata),
            contradictions: contradictionRows,
            correctionControls: correctionControls,
            appliedTeachingBadges: appliedTeachingBadges(from: applicableSignals)
        )
    }

    static func resourceOrdering(lhs: GoalResourceEntity, rhs: GoalResourceEntity) -> Bool {
        if lhs.ranking.rank != rhs.ranking.rank {
            return lhs.ranking.rank < rhs.ranking.rank
        }
        return lhs.id < rhs.id
    }
}

private extension DefaultGoalExplainabilityProjector {
    func whisperState(
        whyNow: WhyNowExplanationMetadata?,
        freshness: GoalResourceGraphFreshnessMetadata,
        understandingConfidence: RecommendationConfidence,
        contradictionRows: [GoalContradictionSummaryState],
        resourceRows: [GoalSourceAuditRowState]
    ) -> GoalTrustWhisperState {
        let confidencePill = GoalTrustWhisperPillState(
            id: "trust-confidence",
            title: humanizedConfidence(understandingConfidence),
            icon: "checkmark.shield",
            state: confidenceVisualState(understandingConfidence)
        )
        let freshnessPill = GoalTrustWhisperPillState(
            id: "trust-freshness",
            title: freshnessLabel(freshness.overallPosture),
            icon: freshness.overallPosture == .currentEnough ? "clock.arrow.circlepath" : "clock.badge.exclamationmark",
            state: freshnessVisualState(freshness.overallPosture)
        )
        let sourcePill = GoalTrustWhisperPillState(
            id: "trust-source-posture",
            title: sourcePostureLabel(resourceRows),
            icon: "text.magnifyingglass",
            state: sourcePostureState(resourceRows)
        )
        let contradictionPill = contradictionRows.isEmpty
            ? GoalTrustWhisperPillState(
                id: "trust-contradictions",
                title: "No conflicts surfaced",
                icon: "checkmark.circle",
                state: .success
            )
            : GoalTrustWhisperPillState(
                id: "trust-contradictions",
                title: contradictionRows.count == 1 ? "1 conflict needs review" : "\(contradictionRows.count) conflicts need review",
                icon: "exclamationmark.bubble",
                state: contradictionRows.contains(where: { $0.state == .warning }) ? .warning : .selected
            )
        let subtitle = whyNow?.conciseReason ?? "The app is keeping the recommendation visible while deeper trust details stay on demand."

        return GoalTrustWhisperState(
            title: "Trust whisper",
            subtitle: subtitle,
            pillLine: [confidencePill.title, freshnessPill.title, sourcePill.title].joined(separator: " • "),
            pills: [confidencePill, freshnessPill, sourcePill, contradictionPill]
        )
    }

    func whyThisState(
        metadata: GoalOrchestrationMetadata,
        primaryStepID: String?,
        whyNow: WhyNowExplanationMetadata?
    ) -> GoalWhyThisState {
        _ = primaryStepID
        let primaryCandidate = metadata.compiledPath.candidates.first(where: \.isPrimary)
            ?? metadata.compiledPath.candidates.sorted { $0.id < $1.id }.first

        var lines = [
            "Interpretation: \(metadata.understanding.primaryInterpretation.summary)",
            "Path: \(primaryCandidate?.summary ?? humanized(metadata.compiledPath.overallPosture.rawValue))"
        ]
        if let whyNow {
            lines.append("Now: \(whyNow.conciseReason)")
        }
        let compactSummary = whyNow?.conciseReason
            ?? lines.first
            ?? "Interpretation: \(metadata.understanding.primaryInterpretation.summary)"

        return GoalWhyThisState(
            compactSummary: compactSummary,
            lines: lines
        )
    }

    func sourceAuditRow(
        resource: GoalResourceEntity,
        metadata: GoalOrchestrationMetadata
    ) -> GoalSourceAuditRowState {
        let hook = metadata.compiledPath.candidates
            .first(where: { $0.id == resource.candidateID })?
            .resourceHooks
            .first(where: { $0.id == resource.hookID })
        let source = metadata.resourceGraph.sources.first(where: { source in
            resource.sourceRecordIDs.contains(source.sourceRecordID)
        })
        let title = hook?.summary ?? humanized(resource.resourceRole.rawValue)
        let subtitle = source?.publisher
            ?? source?.locator
            ?? humanized(resource.missingResourceState.rawValue)
        let detailLabels = [
            "Provenance: \(humanized(source?.provenanceKind.rawValue ?? "unknown"))",
            "Trust: \(humanized(resource.trustLevel?.rawValue ?? "unknown"))",
            "Freshness: \(humanized(resource.freshnessState?.rawValue ?? "unknown"))"
        ] + resource.ranking.flags.map { "Flag: \(humanized($0.rawValue))" }

        return GoalSourceAuditRowState(
            id: "source-\(resource.id)",
            resourceID: resource.id,
            title: title,
            subtitle: subtitle,
            detailLabels: detailLabels,
            state: state(
                missingState: resource.missingResourceState,
                freshness: resource.freshnessState
            )
        )
    }

    func freshnessState(_ freshness: GoalResourceGraphFreshnessMetadata) -> GoalFreshnessState {
        let labels = freshness.resourceImpacts
            .flatMap(\.flags)
            .map { "Flag: \(humanized($0.rawValue))" }
        return GoalFreshnessState(
            posture: freshness.overallPosture,
            postureLabel: humanized(freshness.overallPosture.rawValue),
            severityLabel: humanized(freshness.maxSeverity.rawValue),
            detailLabels: labels.isEmpty ? ["Flag: none"] : labels
        )
    }

    func confidenceState(metadata: GoalOrchestrationMetadata) -> GoalConfidenceState {
        let primaryCandidate = metadata.compiledPath.candidates.first(where: \.isPrimary)
            ?? metadata.compiledPath.candidates.sorted { $0.id < $1.id }.first
        var labels = [
            "Understanding: \(humanized(metadata.understanding.confidence.overall.rawValue))",
            "Understanding score: \(formatted(metadata.understanding.confidence.score))"
        ]
        if let primaryCandidate {
            labels.append("Path: \(humanized(primaryCandidate.confidence.overall.rawValue))")
            labels.append("Path score: \(formatted(primaryCandidate.confidence.score))")
        }
        labels.append(contentsOf: metadata.understanding.confidence.uncertaintyTags.map { "Uncertainty: \($0)" })

        return GoalConfidenceState(
            understandingConfidence: metadata.understanding.confidence.overall,
            pathConfidence: primaryCandidate?.confidence.overall,
            detailLabels: labels
        )
    }

    func contradictionSummary(record: GoalContradictionRecord) -> GoalContradictionSummaryState {
        GoalContradictionSummaryState(
            id: record.id,
            code: record.code,
            title: humanized(record.code.rawValue),
            summary: record.summary,
            severityLabel: humanized(record.severity.rawValue),
            state: record.severity.visualState
        )
    }

    func humanizedConfidence(_ confidence: RecommendationConfidence) -> String {
        switch confidence {
        case .high:
            return "Strong fit"
        case .medium:
            return "Likely fit"
        case .low:
            return "Needs confirmation"
        }
    }

    func confidenceVisualState(_ confidence: RecommendationConfidence) -> AmbitionVisualState {
        switch confidence {
        case .high:
            return .success
        case .medium:
            return .selected
        case .low:
            return .warning
        }
    }

    func freshnessLabel(_ posture: GoalFreshnessPosture) -> String {
        switch posture {
        case .currentEnough:
            return "Updated recently"
        case .aging:
            return "Based on older context"
        case .stale:
            return "Waiting on newer input"
        case .expired:
            return "Expired source context"
        case .unknownFreshness:
            return "Freshness is still light"
        case .blockedMissingEvidence:
            return "Missing evidence is blocking trust"
        case .providerUnavailable:
            return "Provider context is unavailable"
        }
    }

    func freshnessVisualState(_ posture: GoalFreshnessPosture) -> AmbitionVisualState {
        switch posture {
        case .currentEnough:
            return .success
        case .aging, .unknownFreshness:
            return .selected
        case .stale, .expired, .blockedMissingEvidence, .providerUnavailable:
            return .warning
        }
    }

    func sourcePostureLabel(_ rows: [GoalSourceAuditRowState]) -> String {
        if rows.contains(where: { $0.state == .warning }) {
            return "Some source context needs review"
        }
        if rows.isEmpty {
            return "Source context is light"
        }
        return "Source context looks stable"
    }

    func sourcePostureState(_ rows: [GoalSourceAuditRowState]) -> AmbitionVisualState {
        if rows.contains(where: { $0.state == .warning }) {
            return .warning
        }
        return rows.isEmpty ? .default : .success
    }

    func resourceCorrectionControls(
        resources: [GoalResourceEntity],
        metadata: GoalOrchestrationMetadata
    ) -> [GoalCorrectionControlState] {
        resources.compactMap { resource in
            guard let hook = metadata.compiledPath.candidates
                .first(where: { $0.id == resource.candidateID })?
                .resourceHooks
                .first(where: { $0.id == resource.hookID }),
                  resourceHookIsAnchorable(summary: hook.summary, candidateID: resource.candidateID, metadata: metadata)
            else {
                return nil
            }

            return GoalCorrectionControlState(
                id: "resource-control-\(resource.id)",
                title: "Mark support not relevant",
                subtitle: hook.summary,
                kind: .markSupportNotRelevant,
                artifactKind: .resourceHook,
                teachingSignalKind: .requirementRelevanceCorrection,
                payload: .requirementRelevance(
                    GoalTeachingRequirementRelevanceCorrection(correctedDisposition: .notRelevant)
                ),
                target: GoalTeachingCaptureTarget(
                    artifactKind: .resourceHook,
                    candidateID: resource.candidateID,
                    stageID: resource.targetStageID,
                    requirementSummary: hook.summary
                ),
                state: .warning
            )
        }
    }

    func contradictionCorrectionControls(
        records: [GoalContradictionRecord]
    ) -> [GoalCorrectionControlState] {
        records.compactMap { record in
            guard record.artifactRefs.isEmpty == false,
                  contradictionIsAnchorable(record, records: records)
            else {
                return nil
            }
            let refs = record.normalizedArtifactRefs.map {
                GoalTeachingContradictionArtifactRef(
                    kind: $0.kind,
                    id: $0.id,
                    candidateID: $0.candidateID,
                    stageID: $0.stageID
                )
            }

            return GoalCorrectionControlState(
                id: "contradiction-dismiss-\(record.id)",
                title: "Dismiss contradiction",
                subtitle: record.summary,
                kind: .dismissContradiction,
                artifactKind: .contradictionShape,
                teachingSignalKind: .contradictionDispositionCorrection,
                payload: .contradictionDisposition(
                    GoalTeachingContradictionDispositionCorrection(correctedDisposition: .dismissed)
                ),
                target: GoalTeachingCaptureTarget(
                    artifactKind: .contradictionShape,
                    candidateID: record.candidateID,
                    stageID: record.stageID,
                    contradictionCode: record.code,
                    contradictionArtifactRefs: refs
                ),
                state: .warning
            )
        }
    }

    func energyCorrectionControls(
        metadata: GoalOrchestrationMetadata,
        primaryStepID: String?
    ) -> [GoalCorrectionControlState] {
        guard let primaryStepID else { return [] }
        let matches = metadata.energyModel.evaluations.filter { evaluation in
            evaluation.stepID == primaryStepID || (
                evaluation.targetKind == .planStep && evaluation.targetID == primaryStepID
            )
        }
        guard matches.count == 1, let evaluation = matches.first else {
            return []
        }

        return [
            GoalCorrectionControlState(
                id: "energy-lighten-\(evaluation.id)",
                title: "Needs lighter version",
                subtitle: humanized(evaluation.fitBand.rawValue),
                kind: .requestLighterVersion,
                artifactKind: .energyEvaluation,
                teachingSignalKind: .energyFitCorrection,
                payload: .energyFit(
                    GoalTeachingEnergyFitCorrection(correctedDisposition: .lighterVersionNeeded)
                ),
                target: GoalTeachingCaptureTarget(
                    artifactKind: .energyEvaluation,
                    candidateID: evaluation.candidateID,
                    stageID: evaluation.stageID,
                    stepID: evaluation.stepID,
                    energyTargetKind: evaluation.targetKind,
                    energyTargetID: evaluation.targetID
                ),
                state: .selected
            )
        ]
    }

    func appliedTeachingBadges(from applicableSignals: GoalTeachingApplicableSet?) -> [GoalAppliedTeachingBadgeState] {
        (applicableSignals?.signals ?? []).map { signal in
            GoalAppliedTeachingBadgeState(
                id: "badge-\(signal.id)",
                signalID: signal.id,
                title: badgeTitle(for: signal),
                subtitle: signal.userNote ?? humanized(signal.kind.rawValue),
                state: .selected
            )
        }
    }

    func badgeTitle(for signal: GoalTeachingSignal) -> String {
        switch signal.payload {
        case let .requirementRelevance(payload):
            return "Support \(humanized(payload.correctedDisposition.rawValue))"
        case let .contradictionDisposition(payload):
            return "Contradiction \(humanized(payload.correctedDisposition.rawValue))"
        case let .energyFit(payload):
            return "Energy \(humanized(payload.correctedDisposition.rawValue))"
        case .interpretation:
            return "Interpretation corrected"
        case .goalSubject:
            return "Goal subject corrected"
        case .classification:
            return "Classification corrected"
        }
    }

    func resourceHookIsAnchorable(
        summary: String,
        candidateID: String,
        metadata: GoalOrchestrationMetadata
    ) -> Bool {
        let matches = metadata.compiledPath.candidates.flatMap { candidate in
            candidate.resourceHooks.filter { hook in
                candidate.id == candidateID && normalize(hook.summary) == normalize(summary)
            }
        }
        return matches.count == 1
    }

    func contradictionIsAnchorable(
        _ record: GoalContradictionRecord,
        records: [GoalContradictionRecord]
    ) -> Bool {
        records.filter { candidate in
            candidate.code == record.code &&
            candidate.candidateID == record.candidateID &&
            candidate.stageID == record.stageID &&
            candidate.normalizedArtifactRefs == record.normalizedArtifactRefs
        }.count == 1
    }

    func state(
        missingState: GoalResourceMissingState,
        freshness: KnowledgeFreshnessState?
    ) -> AmbitionVisualState {
        if missingState != .none {
            return .warning
        }
        switch freshness {
        case .stale, .expired:
            return .warning
        case .fresh, .unknown:
            return .default
        case .none:
            return .default
        }
    }

    func humanized(_ value: String) -> String {
        value
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }

    func formatted(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

private extension GoalContradictionSeverity {
    var visualState: AmbitionVisualState {
        switch self {
        case .blocking, .important:
            return .warning
        case .informational:
            return .default
        }
    }
}
