import AmbitionsDesignSystem
import SwiftUI

extension TodayStepReplacementSheetState {

    static func makeOption(
        blueprint: ReplacementBlueprint,
        privacy: DayRailPrivacyProjectionState,
        sourceHero: DayRailHeroStepState,
        sourceLabels: [DayRailSourceLabelState],
        sourceStepID: String,
        sourceCandidateID: String?,
        recordedAt: String,
        position: Int
    ) -> TodayStepReplacementOptionState {
        let candidateID = CandidateSource.stableIdentifier(
            prefix: "today-step-replacement",
            components: [
                sourceStepID,
                sourceCandidateID ?? "no-source-candidate",
                blueprint.kind.rawValue,
                blueprint.label,
                blueprint.title,
                "\(position)"
            ]
        )
        let sourceStepIsOptional = blueprint.kind == .fallback ? false : true
        let impactSimulation = StepImpactSimulation.make(
            goalID: sourceHero.primaryAction.target.goalID,
            kind: blueprint.kind,
            sourceStepID: sourceStepID,
            sourceCandidateID: sourceCandidateID,
            candidateID: candidateID,
            generatedAt: recordedAt,
            deadlineTargetDate: nil,
            estimatedMinutes: blueprint.minutes,
            goalContribution: blueprint.goalContribution,
            deadlineContribution: blueprint.deadlineContribution,
            futurePressureImpact: blueprint.futurePressureImpact,
            opportunityCost: blueprint.opportunityCost,
            openCapacityWindowCount: 1,
            protectedCapacityWindowCount: 1,
            sourceStepIsOptional: sourceStepIsOptional,
            sourceStepIsExecutable: true,
            rejectionHistoryCount: 0,
            approvalRequired: blueprint.approvalRequired,
            validity: blueprint.validity
        )
        let candidate = StepCandidate(
            sourceStepID: sourceStepID,
            sourceCandidateID: sourceCandidateID,
            source: .fallback,
            kind: blueprint.kind,
            title: blueprint.title,
            summary: blueprint.summary,
            accessibilitySummary: "\(blueprint.label). \(impactSimulation.summary)",
            estimatedMinutes: blueprint.minutes,
            estimatedEnergyCost: blueprint.energy,
            accessRequirements: blueprint.accessRequirements,
            equipmentRequirements: blueprint.equipmentRequirements,
            facilityRequirements: blueprint.facilityRequirements,
            goalContribution: blueprint.goalContribution,
            deadlineContribution: blueprint.deadlineContribution,
            futurePressureImpact: blueprint.futurePressureImpact,
            opportunityCost: blueprint.opportunityCost,
            approvalRequired: blueprint.approvalRequired,
            validity: blueprint.validity,
            tradeoffs: [
                CandidateTradeoff(
                    id: "tradeoff.\(candidateID).timeline",
                    label: "Timeline",
                    benefit: blueprint.kind == .fallback ? "Pause before overcommitting." : "Keeps the work believable.",
                    cost: blueprint.kind == .fallback ? "The ask is not yet ready to approve." : "You still need to choose the honest version."
                )
            ],
            rejectionRisk: CandidateRejectionRisk(
                id: "risk.\(candidateID)",
                level: blueprint.kind == .fallback ? .high : .moderate,
                summary: blueprint.kind == .fallback ? "This path needs another look." : "This is a local alternative worth reviewing.",
                factorIDs: [],
                requiresReview: blueprint.approvalRequired
            ),
            semanticAnchor: candidateID,
            generatedAt: recordedAt,
            openCapacityWindowCount: 1,
            protectedCapacityWindowCount: 1,
            sourceStepIsOptional: sourceStepIsOptional,
            sourceStepIsExecutable: true,
            rejectionHistoryCount: 0,
            impactSimulation: impactSimulation
        )
        return TodayStepReplacementOptionState(
            candidate: candidate,
            label: blueprint.label,
            title: privacyVisibleTitle(blueprint.title, privacy: privacy),
            summary: privacyVisibleSubtitle(blueprint.summary, privacy: privacy),
            deadlineImpactLabel: deadlineImpactLabel(for: impactSimulation),
            timelineImpactLabel: timelineImpactLabel(for: impactSimulation),
            receiptPreviewLabel: "Review preview: \(blueprint.label) · \(deadlineImpactLabel(for: impactSimulation))",
            approvalHint: "Approve this local replacement before Today updates.",
            heroStep: heroStep(
                for: candidate,
                impactSimulation: impactSimulation,
                privacy: privacy,
                sourceLabels: sourceLabels,
                sourceHero: sourceHero
            )
        )
    }


    static func deadlineImpactLabel(for simulation: StepImpactSimulation) -> String {
        if simulation.threatensProtectedTime || simulation.goalTimeline.compression.isCompressed {
            return "Adds pressure"
        }
        if simulation.requiresDeadlineReview || simulation.requiresScopeReview {
            if simulation.kindRawValue == StepCandidateKind.shorter.rawValue, simulation.requiresDeadlineReview == false {
                return "Keeps deadline"
            }
            return "Needs review"
        }
        return "Keeps deadline"
    }


    static func timelineImpactLabel(for simulation: StepImpactSimulation) -> String {
        simulation.goalTimeline.summary
    }


    static func privacyVisibleTitle(_ title: String, privacy: DayRailPrivacyProjectionState) -> String {
        privacy.visibleTitle(title)
    }


    static func privacyVisibleSubtitle(_ subtitle: String, privacy: DayRailPrivacyProjectionState) -> String {
        privacy.visibleSubtitle(subtitle)
    }


    static func durationMinutes(from label: String) -> Int? {
        let digits = label.compactMap(\.wholeNumberValue)
        guard digits.isEmpty == false else { return nil }
        return Int(digits.reduce(into: "") { $0.append(String($1)) })
    }


    static func heroStep(
        for candidate: StepCandidate,
        impactSimulation: StepImpactSimulation,
        privacy: DayRailPrivacyProjectionState,
        sourceLabels: [DayRailSourceLabelState],
        sourceHero: DayRailHeroStepState
    ) -> DayRailHeroStepState {
        let title = privacy.visibleTitle(candidate.title)
        let summary = privacy.visibleSubtitle(candidate.summary)
        let localSourceLabel = privacy.isSensitiveProjection ? privacy.sourceLabel : "Stored on this device"
        let duration = DayRailDurationState(minutes: candidate.estimatedMinutes, source: .suggested, label: "\(candidate.estimatedMinutes) min suggested")
        return DayRailHeroStepState(
            id: "\(candidate.id).hero",
            title: title,
            subtitle: summary,
            duration: duration,
            fitLabel: candidate.kind.semanticLabel,
            whySummary: impactSimulation.summary,
            sourceQualityLabel: candidate.validity.accessibilityLabel,
            becauseLine: impactSimulation.goalTimeline.summary,
            contextEdge: StartHereContextEdgeState(
                title: "Context edge",
                summary: deadlineImpactLabel(for: impactSimulation),
                sourceLabel: localSourceLabel
            ),
            timeFitProof: StartHereTimeFitProofState(
                title: "Time fit",
                summary: impactSimulation.goalTimeline.onTrack.summary,
                detail: deadlineImpactLabel(for: impactSimulation)
            ),
            goalThread: StartHereGoalThreadState(
                title: "Goal thread",
                summary: candidate.kind.semanticLabel,
                detail: impactSimulation.goalTimeline.summary
            ),
            receiptItem: DayRailHeroStepState.receiptItem(
                id: "today.step-replacement.receipt.\(candidate.id)",
                title: title,
                sourceLabel: localSourceLabel,
                freshness: .localOnly,
                privacyLabel: privacy.sourceLabel,
                becauseLine: impactSimulation.goalTimeline.summary
            ),
            primaryAction: sourceHero.primaryAction,
            secondaryAction: sourceHero.secondaryAction,
            detailTarget: sourceHero.detailTarget,
            sourceLabels: sourceLabels
        )
    }


    struct ReplacementBlueprint {
        let kind: StepCandidateKind
        let label: String
        let title: String
        let summary: String
        let minutes: Int
        let energy: Double
        let goalContribution: Double
        let deadlineContribution: Double
        let futurePressureImpact: Double
        let opportunityCost: Double
        let approvalRequired: Bool
        let validity: CandidateValidity
        let accessRequirements: [String]
        let equipmentRequirements: [String]
        let facilityRequirements: [String]
    }
}
