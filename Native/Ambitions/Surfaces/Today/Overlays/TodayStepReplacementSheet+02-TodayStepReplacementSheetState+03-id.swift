import AmbitionsDesignSystem
import SwiftUI

// Accessibility companion: TodayStepReplacementSheet owns proof, receipt, and VoiceOver review semantics for this state factory.

extension TodayStepReplacementSheetState {
    static func make(
        from hero: DayRailHeroStepState,
        privacy: DayRailPrivacyProjectionState,
        contextLabel: String,
        recordedAt: String = DomainTimestamp.string(from: SystemClock().now)
    ) -> TodayStepReplacementSheetState {
        let originalRecommendation = hero.stepDetail(privacy: privacy, contextLabel: contextLabel)
        let sourceStepID = hero.primaryAction.target.stepID ?? hero.detailTarget.stepID ?? hero.id
        let sourceCandidateID: String? = hero.primaryAction.target.stepID ?? hero.id
        let originalTitle = privacy.detailTitle(hero.title)
        let originalSummary = privacy.visibleSubtitle(hero.subtitle)
        let alternatives = makeAlternatives(
            sourceHero: hero,
            privacy: privacy,
            sourceStepID: sourceStepID,
            sourceCandidateID: sourceCandidateID,
            recordedAt: recordedAt
        )
        let defaultAlternativeID = alternatives.first?.id ?? ""
        return TodayStepReplacementSheetState(
            title: "Show another",
            subtitle: "The current recommendation stays inspectable. Choose a replacement, review its impact, then approve it explicitly.",
            contextLabel: contextLabel,
            originalRecommendation: originalRecommendation,
            originalHero: hero,
            alternatives: alternatives,
            defaultAlternativeID: defaultAlternativeID,
            receiptPreviewTitle: "Move original Step",
            impactSectionTitle: "Show impact",
            impactSectionSubtitle: "Ride momentum without moving silently. Move original Step only after you approve the receipt.",
            sourceStepID: sourceStepID,
            sourceCandidateID: sourceCandidateID,
            contextFingerprint: CandidateSource.stableIdentifier(
                prefix: "today-step-replacement-context",
                components: [
                    sourceStepID,
                    sourceCandidateID ?? "no-source-candidate",
                    originalTitle,
                    originalSummary,
                    contextLabel,
                    recordedAt
                ]
            ),
            recordedAt: recordedAt
        )
    }


    var selectedAlternative: TodayStepReplacementOptionState? {
        alternatives.first(where: { $0.id == defaultAlternativeID }) ?? alternatives.first
    }


    var visibleCopy: String {
        (
            [
                title,
                subtitle,
                contextLabel,
                receiptPreviewTitle,
                impactSectionTitle,
                impactSectionSubtitle,
                approvalTitle,
                whyNotThisTitle,
                confirmTitle,
                noSilentChangesLabel,
                "Original recommendation",
                originalRecommendation.visibleCopy,
                originalHero.visibleCopy
            ] + alternatives.map(\.visibleCopy)
        ).joined(separator: " ")
    }


    func approvalReceiptPreview(for option: TodayStepReplacementOptionState) -> String {
        let receipt = ActionReceipt.alternateStepGeneratedReceipt(
            id: "today.step-replacement.generated.\(option.id).\(recordedAt)",
            candidateID: option.id,
            sourceStepID: sourceStepID,
            sourceCandidateID: sourceCandidateID,
            alternativeCount: alternatives.count,
            timelineImpactSummary: option.timelineImpactLabel,
            recordedAt: recordedAt
        )
        return "\(receipt.title) · \(receipt.summary)"
    }


    func approvalReceiptMessage(for option: TodayStepReplacementOptionState) -> TodayInlineMessage {
        let receipt = ActionReceipt.alternateStepApprovedReceipt(
            id: "today.step-replacement.approved.\(option.id).\(recordedAt)",
            candidateID: option.id,
            sourceStepID: sourceStepID,
            sourceCandidateID: sourceCandidateID,
            approvedStepID: option.id,
            approvedStepTitle: option.title,
            timelineImpactSummary: option.timelineImpactLabel,
            recordedAt: recordedAt
        )
        return TodayInlineMessage(
            title: receipt.title,
            body: "\(receipt.summary) \(option.timelineImpactLabel). \(option.receiptPreviewLabel).",
            state: .selected
        )
    }


    func approvedRail(from rail: AmbitionsDayRailViewState, selectedOption: TodayStepReplacementOptionState) -> AmbitionsDayRailViewState {
        let updatedHero = selectedOption.heroStep
        return rail.replacingHeroStep(
            updatedHero,
            contextSummary: rail.contextSummary,
            pressureLabel: rail.continuity.pressureLabel
        )
    }


    static func makeAlternatives(
        sourceHero: DayRailHeroStepState,
        privacy: DayRailPrivacyProjectionState,
        sourceStepID: String,
        sourceCandidateID: String?,
        recordedAt: String
    ) -> [TodayStepReplacementOptionState] {
        let baseTitle = privacy.visibleTitle(sourceHero.title)
        let baseSummary = privacy.visibleSubtitle(sourceHero.subtitle)
        let baseMinutes = durationMinutes(from: sourceHero.duration.label) ?? 25
        let baseSourceLabel = sourceHero.sourceLabels.first?.label ?? privacy.sourceLabel
        let sourceLabels = sourceHero.sourceLabels.isEmpty
            ? [DayRailSourceLabelState(id: "source.today.replacement", label: baseSourceLabel, source: .standard)]
            : sourceHero.sourceLabels

        let blueprints: [ReplacementBlueprint] = [
            ReplacementBlueprint(
                kind: .directBest,
                label: "Keep goal on track",
                title: baseTitle,
                summary: baseSummary,
                minutes: max(10, baseMinutes),
                energy: 0.28,
                goalContribution: 0.92,
                deadlineContribution: 0.88,
                futurePressureImpact: 0.24,
                opportunityCost: 0.12,
                approvalRequired: true,
                validity: .preferred,
                accessRequirements: [],
                equipmentRequirements: [],
                facilityRequirements: []
            ),
            ReplacementBlueprint(
                kind: .lighter,
                label: "Make original Step lighter",
                title: "Lighter version of \(baseTitle.lowercased())",
                summary: "Keep the same goal and cut the load down.",
                minutes: max(10, baseMinutes - 10),
                energy: 0.18,
                goalContribution: 0.79,
                deadlineContribution: 0.80,
                futurePressureImpact: 0.16,
                opportunityCost: 0.24,
                approvalRequired: true,
                validity: .review,
                accessRequirements: [],
                equipmentRequirements: [],
                facilityRequirements: []
            ),
            ReplacementBlueprint(
                kind: .shorter,
                label: "Continue this Step",
                title: "First \(min(15, baseMinutes)) minutes of \(baseTitle.lowercased())",
                summary: "A smaller pass that still moves the work forward.",
                minutes: min(15, baseMinutes),
                energy: 0.14,
                goalContribution: 0.74,
                deadlineContribution: 0.86,
                futurePressureImpact: 0.78,
                opportunityCost: 0.30,
                approvalRequired: true,
                validity: .review,
                accessRequirements: [],
                equipmentRequirements: [],
                facilityRequirements: []
            ),
            ReplacementBlueprint(
                kind: .noEquipment,
                label: "Use this time elsewhere",
                title: "No-setup version of \(baseTitle.lowercased())",
                summary: "Use only what is already ready.",
                minutes: min(baseMinutes, 20),
                energy: 0.20,
                goalContribution: 0.77,
                deadlineContribution: 0.83,
                futurePressureImpact: 0.18,
                opportunityCost: 0.26,
                approvalRequired: true,
                validity: .review,
                accessRequirements: [],
                equipmentRequirements: [],
                facilityRequirements: []
            ),
            ReplacementBlueprint(
                kind: .fallback,
                label: "Ride momentum",
                title: "Review the ask before \(baseTitle.lowercased())",
                summary: "This path needs another look before it becomes the winner.",
                minutes: baseMinutes,
                energy: 0.52,
                goalContribution: 0.55,
                deadlineContribution: 0.38,
                futurePressureImpact: 0.80,
                opportunityCost: 0.44,
                approvalRequired: true,
                validity: .fallback,
                accessRequirements: [],
                equipmentRequirements: ["More context"],
                facilityRequirements: []
            )
        ]

        return blueprints.prefix(5).enumerated().map { index, blueprint in
            makeOption(
                blueprint: blueprint,
                privacy: privacy,
                sourceHero: sourceHero,
                sourceLabels: sourceLabels,
                sourceStepID: sourceStepID,
                sourceCandidateID: sourceCandidateID,
                recordedAt: recordedAt,
                position: index
            )
        }
    }
}
import AmbitionsTimeFoundation
