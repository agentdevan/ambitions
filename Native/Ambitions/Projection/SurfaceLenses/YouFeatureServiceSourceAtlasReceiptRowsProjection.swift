import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeSourceAtlasReplayReceipts(snapshot: Snapshot) -> [SourceAtlasBridgeReceipt] {
        let generatedAt = snapshot.eventLedger.first?.occurredAt ?? "local.now"
        let goalIDs = snapshot.goals.map(\.id)
        let draftIDs = snapshot.drafts.map(\.id)
        let stepCount = snapshot.goals.compactMap(\.plan).flatMap(\.sections).flatMap(\.steps).count
        let hasEvidence = snapshot.evidence.isEmpty == false || snapshot.feedback.isEmpty == false
        let activeGoals = snapshot.goals.filter { $0.state == .active }
        let packCount = max(activeGoals.count, snapshot.drafts.count)

        return [
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasIntentMatched,
                recordedAt: generatedAt,
                summary: "Goal knowledge matched the current local source set.",
                details: [
                    "goal-count=\(snapshot.goals.count)",
                    "draft-count=\(snapshot.drafts.count)",
                    "evidence-count=\(snapshot.evidence.count)",
                    "feedback-count=\(snapshot.feedback.count)"
                ],
                relatedIDs: goalIDs + draftIDs
            ),
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasPackSelected,
                recordedAt: generatedAt,
                summary: "Local source packs stayed selected for planning.",
                details: [
                    "active-goals=\(activeGoals.count)",
                    "pack-count=\(packCount)",
                    "used-to-plan=\(activeGoals.isEmpty == false)"
                ],
                relatedIDs: goalIDs
            ),
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasPathComposed,
                recordedAt: generatedAt,
                summary: "A local path shape stayed available for goal knowledge.",
                details: [
                    "planned-goals=\(snapshot.goals.filter { $0.plan != nil }.count)",
                    "step-count=\(stepCount)"
                ],
                relatedIDs: goalIDs
            ),
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasStepCandidatesExpanded,
                recordedAt: generatedAt,
                summary: "Step candidates stayed expanded from local goal source.",
                details: [
                    "step-count=\(stepCount)",
                    "evidence-aware=\(hasEvidence)"
                ],
                relatedIDs: goalIDs
            ),
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasUserCorrectionApplied,
                recordedAt: generatedAt,
                summary: "Local corrections stayed visible to future goal knowledge.",
                details: [
                    "teaching-signals=\(snapshot.teachingSignals.count)",
                    "feedback-events=\(snapshot.feedback.count)"
                ],
                relatedIDs: goalIDs + draftIDs
            ),
            SourceAtlasBridgeReceipt(
                kind: .sourceAtlasReplayGenerated,
                recordedAt: generatedAt,
                summary: "Replay receipts stayed local and inspectable.",
                details: [
                    "event-ledger-count=\(snapshot.eventLedger.count)",
                    "life-context-bundles=\(snapshot.lifeContextBundles.count)"
                ],
                relatedIDs: goalIDs + draftIDs
            )
        ]
    }

    func makeSourceAtlasKnowledgeRow(
        id: String,
        icon: String,
        title: String,
        usedWhat: String,
        whyUsed: String,
        sourceName: String,
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        riskState: SourceAtlasRequirementRiskState,
        runtimeUseState: YouSourceAtlasKnowledgeRuntimeUseState,
        needsReview: Bool,
        correctionPath: String,
        reviewPath: String,
        iconState: AmbitionVisualState
    ) -> YouSourceAtlasKnowledgeRow {
        let reviewNeedLabel = needsReview ? "Needs Review" : "No Review Needed"
        let accessibilityLabel = title
        let accessibilityValue = "\(usedWhat). \(whyUsed). Source \(sourceName). Source state \(sourceAtlasSourceStateLabel(sourceState)). Freshness \(sourceAtlasFreshnessStateLabel(freshnessState)). Risk \(sourceAtlasRiskStateLabel(riskState)). \(runtimeUseState.label). \(reviewNeedLabel). Correction path \(correctionPath). Review path \(reviewPath)."
        let accessibilityHint = "Shows what Ambitions used, why it used it, and how to review or correct the source path."

        return YouSourceAtlasKnowledgeRow(
            id: id,
            icon: icon,
            title: title,
            usedWhat: usedWhat,
            whyUsed: whyUsed,
            sourceName: sourceName,
            sourceStateLabel: sourceAtlasSourceStateLabel(sourceState),
            freshnessStateLabel: sourceAtlasFreshnessStateLabel(freshnessState),
            riskStateLabel: sourceAtlasRiskStateLabel(riskState),
            runtimeUseState: runtimeUseState,
            reviewNeedLabel: reviewNeedLabel,
            correctionPath: correctionPath,
            reviewPath: reviewPath,
            state: iconState,
            accessibilityLabel: accessibilityLabel,
            accessibilityValue: accessibilityValue,
            accessibilityHint: accessibilityHint
        )
    }

    func sourceAtlasSourceStateLabel(_ state: SourceAtlasRequirementSourceState) -> String {
        switch state {
        case .unknown:
            return "Unknown"
        case .sourceNeeded:
            return "Context needed"
        case .stale:
            return "Stale"
        case .contradicted:
            return "Contradicted"
        case .revoked:
            return "Revoked"
        case .locallyProven:
            return "Locally proven"
        case .official:
            return "Official"
        case .officialCurrent:
            return "Official current"
        case .current:
            return "Current"
        }
    }

    func sourceAtlasFreshnessStateLabel(_ state: SourceAtlasRequirementFreshnessState) -> String {
        switch state {
        case .current:
            return "Current"
        case .stale:
            return "Stale"
        case .unknown:
            return "Unknown"
        }
    }

    func sourceAtlasRiskStateLabel(_ state: SourceAtlasRequirementRiskState) -> String {
        switch state {
        case .low:
            return "Low risk"
        case .medium:
            return "Medium risk"
        case .high:
            return "High risk"
        case .unknown:
            return "Unknown risk"
        }
    }

}
