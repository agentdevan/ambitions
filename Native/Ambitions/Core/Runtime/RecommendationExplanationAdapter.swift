import Foundation

protocol RecommendationExplanationAdapting: Sendable {
    func makeGoalWhyThisExplanation(
        goalID: String,
        state: GoalExplainabilityState,
        primaryStepID: String?,
        lastUpdatedAt: String
    ) -> RecommendationExplanation

    func makeEvidence(from entry: EventLedgerEntry) -> RecommendationExplanationEvidence
}

struct DefaultRecommendationExplanationAdapter: RecommendationExplanationAdapting {
    func makeGoalWhyThisExplanation(
        goalID: String,
        state: GoalExplainabilityState,
        primaryStepID: String?,
        lastUpdatedAt: String
    ) -> RecommendationExplanation {
        var evidence = state.whyThis.lines.enumerated().map { index, line in
            RecommendationExplanationEvidence(
                id: "goal-why-this-line-\(index)",
                category: category(forWhyThisLine: line),
                title: title(forWhyThisLine: line),
                summary: line,
                sourceID: primaryStepID,
                confidence: state.confidence.pathConfidence ?? state.confidence.understandingConfidence
            )
        }

        evidence.append(
            RecommendationExplanationEvidence(
                id: "goal-confidence-understanding",
                category: .goalState,
                title: "Goal understanding confidence",
                summary: state.confidence.detailLabels.first,
                sourceID: goalID,
                confidence: state.confidence.understandingConfidence
            )
        )

        let uncertainty = state.confidence.detailLabels
            .filter { $0.lowercased().hasPrefix("uncertainty:") }
            .enumerated()
            .map { index, label in
                RecommendationExplanationUncertainty(
                    id: "goal-uncertainty-\(index)",
                    summary: label,
                    severity: .medium
                )
            }

        let correctionActions = state.correctionControls.map { control in
            RecommendationExplanationCorrectionAction(
                id: "goal-correction-\(control.id)",
                kind: correctionKind(for: control.kind),
                title: control.title,
                targetFieldKey: control.artifactKind.rawValue,
                metadata: [
                    "legacyControlKind": control.kind.rawValue,
                    "teachingSignalKind": control.teachingSignalKind.rawValue
                ]
            )
        }

        return RecommendationExplanation(
            id: "goal.why_this.\(goalID)",
            type: .whyThis,
            title: "Why this matters",
            summary: state.whyThis.compactSummary,
            recommendationTitle: state.whyThis.compactSummary,
            recommendationSummary: state.whyThis.lines.joined(separator: "\n"),
            confidence: state.confidence.pathConfidence ?? state.confidence.understandingConfidence,
            evidence: evidence,
            assumptions: [],
            uncertainty: uncertainty,
            userCorrectableFields: correctionActions.compactMap(\.targetFieldKey),
            correctionActions: correctionActions,
            lastUpdatedAt: lastUpdatedAt,
            source: .goalDetail,
            relations: RecommendationExplanationRelations(goalIDs: [goalID]),
            privacy: .standard,
            localOnly: true,
            metadata: ["projection": "goal_explainability_v1"]
        )
    }

    func makeEvidence(from entry: EventLedgerEntry) -> RecommendationExplanationEvidence {
        RecommendationExplanationEvidence.fromEventLedgerEntry(entry)
    }
}

private extension DefaultRecommendationExplanationAdapter {
    func category(forWhyThisLine line: String) -> RecommendationExplanationEvidenceCategory {
        let normalized = line.lowercased()
        if normalized.hasPrefix("interpretation:") {
            return .userInput
        }
        if normalized.hasPrefix("path:") {
            return .path
        }
        if normalized.hasPrefix("now:") {
            return .memoryEvent
        }
        return .goalState
    }

    func title(forWhyThisLine line: String) -> String {
        if let separatorIndex = line.firstIndex(of: ":") {
            return String(line[..<separatorIndex])
        }
        return "Goal explanation evidence"
    }

    func correctionKind(
        for legacyKind: GoalExplainabilityCorrectionControlKind
    ) -> RecommendationExplanationCorrectionActionKind {
        switch legacyKind {
        case .markSupportNotRelevant:
            return .markOptionalSomeday
        case .confirmContradiction, .dismissContradiction:
            return .changeRoute
        case .requestLighterVersion:
            return .changeImportance
        }
    }
}
