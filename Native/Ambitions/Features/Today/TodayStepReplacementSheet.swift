import AmbitionsDesignSystem
import SwiftUI

struct TodayStepReplacementOptionState: Identifiable, Equatable {
    let candidate: StepCandidate
    let label: String
    let title: String
    let summary: String
    let deadlineImpactLabel: String
    let timelineImpactLabel: String
    let receiptPreviewLabel: String
    let approvalHint: String
    let heroStep: DayRailHeroStepState

    var id: String { candidate.id }

    var state: AmbitionVisualState {
        switch candidate.validity {
        case .preferred:
            return .success
        case .review:
            return .selected
        case .fallback:
            return .warning
        case .blocked, .rejected:
            return .warning
        }
    }

    var visibleCopy: String {
        [
            label,
            title,
            summary,
            deadlineImpactLabel,
            "Timeline",
            timelineImpactLabel,
            receiptPreviewLabel,
            approvalHint,
            heroStep.visibleCopy
        ].joined(separator: " ")
    }
}

struct TodayStepReplacementSheetState: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let contextLabel: String
    let originalRecommendation: DayRailStepDetailState
    let originalHero: DayRailHeroStepState
    let alternatives: [TodayStepReplacementOptionState]
    let defaultAlternativeID: String
    let receiptPreviewTitle: String
    let impactSectionTitle: String
    let impactSectionSubtitle: String
    let approvalTitle: String
    let whyNotThisTitle: String
    let confirmTitle: String
    let sourceStepID: String
    let sourceCandidateID: String?
    let contextFingerprint: String
    let recordedAt: String
    let noSilentChangesLabel: String

    init(
        title: String,
        subtitle: String,
        contextLabel: String,
        originalRecommendation: DayRailStepDetailState,
        originalHero: DayRailHeroStepState,
        alternatives: [TodayStepReplacementOptionState],
        defaultAlternativeID: String,
        receiptPreviewTitle: String = "Receipt preview",
        impactSectionTitle: String = "Show impact",
        impactSectionSubtitle: String = "Ride momentum without moving silently. Move original Step only after you approve the receipt.",
        approvalTitle: String = "Approve replacement",
        whyNotThisTitle: String = "Why not this?",
        confirmTitle: String = "Approve",
        sourceStepID: String,
        sourceCandidateID: String?,
        contextFingerprint: String,
        recordedAt: String,
        noSilentChangesLabel: String = "No silent changes"
    ) {
        self.id = "today.step-replacement.\(sourceStepID)"
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Show another" : title
        self.subtitle = subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Pick a calm local replacement, then approve it explicitly." : subtitle
        self.contextLabel = contextLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Today" : contextLabel
        self.originalRecommendation = originalRecommendation
        self.originalHero = originalHero
        self.alternatives = Array(alternatives.prefix(5))
        self.defaultAlternativeID = defaultAlternativeID
        self.receiptPreviewTitle = receiptPreviewTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Receipt preview" : receiptPreviewTitle
        self.impactSectionTitle = impactSectionTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Show impact" : impactSectionTitle
        self.impactSectionSubtitle = impactSectionSubtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Ride momentum without moving silently. Move original Step only after you approve the receipt." : impactSectionSubtitle
        self.approvalTitle = approvalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Approve replacement" : approvalTitle
        self.whyNotThisTitle = whyNotThisTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Why not this?" : whyNotThisTitle
        self.confirmTitle = confirmTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Approve" : confirmTitle
        self.sourceStepID = sourceStepID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCandidateID = sourceCandidateID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceCandidateID = trimmedCandidateID?.isEmpty == true ? nil : trimmedCandidateID
        self.contextFingerprint = contextFingerprint.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recordedAt = recordedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.noSilentChangesLabel = noSilentChangesLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No silent changes" : noSilentChangesLabel
    }

    static func make(
        from hero: DayRailHeroStepState,
        privacy: DayRailPrivacyProjectionState,
        contextLabel: String,
        recordedAt: String = DomainTimestamp.string(from: .now)
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

    private static func makeAlternatives(
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

    private static func makeOption(
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
            receiptPreviewLabel: "Receipt preview: \(blueprint.label) · \(deadlineImpactLabel(for: impactSimulation))",
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

    private static func deadlineImpactLabel(for simulation: StepImpactSimulation) -> String {
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

    private static func timelineImpactLabel(for simulation: StepImpactSimulation) -> String {
        simulation.goalTimeline.summary
    }

    private static func privacyVisibleTitle(_ title: String, privacy: DayRailPrivacyProjectionState) -> String {
        privacy.visibleTitle(title)
    }

    private static func privacyVisibleSubtitle(_ subtitle: String, privacy: DayRailPrivacyProjectionState) -> String {
        privacy.visibleSubtitle(subtitle)
    }

    private static func durationMinutes(from label: String) -> Int? {
        let digits = label.compactMap(\.wholeNumberValue)
        guard digits.isEmpty == false else { return nil }
        return Int(digits.reduce(into: "") { $0.append(String($1)) })
    }

    private static func heroStep(
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

    private struct ReplacementBlueprint {
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

extension DayRailHeroStepState {
    var visibleCopy: String {
        (
            [
                title,
                subtitle,
                duration.label,
                fitLabel,
                whySummary,
                sourceQualityLabel,
                becauseLine,
                contextEdge.title,
                contextEdge.summary,
                timeFitProof.title,
                timeFitProof.summary,
                timeFitProof.detail,
                goalThread.title,
                goalThread.summary,
                goalThread.detail,
                receiptItem.title,
                receiptItem.summary,
                receiptItem.sourceLabel,
                receiptItem.privacyLabel,
                primaryAction.title,
                secondaryAction?.title
            ].compactMap { $0 }
        ).joined(separator: " ")
    }
}

extension AmbitionsDayRailViewState {
    func replacingHeroStep(
        _ heroStep: DayRailHeroStepState,
        contextSummary: String,
        pressureLabel: String
    ) -> AmbitionsDayRailViewState {
        AmbitionsDayRailViewState(
            id: id,
            mode: mode,
            dateTitle: dateTitle,
            contextSummary: contextSummary,
            heroStep: heroStep,
            rows: rows,
            primaryAction: heroStep.primaryAction,
            rowTapDetailTargetPlaceholder: rowTapDetailTargetPlaceholder,
            durationSource: durationSource,
            contextLabels: contextLabels,
            privacyProjection: privacyProjection,
            continuity: DayRailContinuityState.make(
                heroStep: heroStep,
                rows: rows,
                closureSlot: closureSlot,
                proofSlot: proofSlot,
                mode: mode,
                pressureLabel: pressureLabel
            ),
            closureSlot: closureSlot,
            proofSlot: proofSlot
        )
    }
}

struct TodayStepReplacementSheet: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: TodayStepReplacementSheetState
    let onWhyNotThis: () -> Void
    let onApprove: (TodayStepReplacementOptionState) -> Void

    @State private var selectedAlternativeID: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    header
                    originalRecommendationCard
                    alternativesSection
                    impactSection
                    receiptSection
                    actionRow
                }
                .padding(theme.spacing.lg)
            }
            .background(TodayBackgroundView())
            .navigationTitle(state.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityIdentifier("TodayStepReplacementDismiss")
                }
            }
        }
        .onAppear {
            selectedAlternativeID = selectedAlternativeID ?? state.defaultAlternativeID
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("TodayStepReplacementSheet")
    }

    private var selectedAlternative: TodayStepReplacementOptionState? {
        guard let selectedAlternativeID else { return state.selectedAlternative }
        return state.alternatives.first(where: { $0.id == selectedAlternativeID }) ?? state.selectedAlternative
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(state.title)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
            Text(state.subtitle)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Label(state.contextLabel, systemImage: "calendar")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
        }
        .accessibilityElement(children: .combine)
    }

    private var originalRecommendationCard: some View {
        QuietReflowPrimitiveStage(
            role: .source,
            eyebrow: "Original recommendation",
            title: state.originalRecommendation.title,
            subtitle: state.originalRecommendation.goalLinkLabel,
            statusLabel: state.originalRecommendation.durationLabel,
            systemImage: "scope",
            accessibilityIdentifier: "TodayStepReplacementOriginalRecommendation"
        ) {
            Text(state.originalRecommendation.whyBullets.first ?? state.originalRecommendation.proofReceiptLabel)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            QuietReflowPrimitiveLine(
                role: .source,
                title: state.originalRecommendation.sourceLabel,
                subtitle: state.originalRecommendation.durationLabel,
                systemImage: "checkmark.shield"
            )

            QuietReflowPrimitiveLine(
                role: .receipt,
                title: state.originalRecommendation.proofReceiptLabel,
                systemImage: "doc.text.magnifyingglass"
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Original recommendation")
        .accessibilityValue(state.originalRecommendation.visibleCopy)
    }

    private var alternativesSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Focused alternatives")
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
            Text("Three to five local replacements stay visible. Timeline impact appears before approval.")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                ForEach(state.alternatives) { option in
                    replacementOption(option)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("TodayStepReplacementAlternatives")
    }

    private func replacementOption(_ option: TodayStepReplacementOptionState) -> some View {
        let isSelected = selectedAlternative?.id == option.id
        return Button {
            selectedAlternativeID = option.id
        } label: {
            replacementOptionLabel(option, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(option.label)
        .accessibilityValue("\(option.title). \(option.deadlineImpactLabel). \(option.timelineImpactLabel). \(option.receiptPreviewLabel)")
        .accessibilityHint(option.approvalHint)
        .accessibilityIdentifier("TodayStepReplacementAlternative.\(option.id)")
    }

    private func replacementOptionLabel(_ option: TodayStepReplacementOptionState, isSelected: Bool) -> some View {
        QuietReflowPrimitiveStage(
            role: .option,
            title: option.label,
            subtitle: option.summary,
            statusLabel: isSelected ? "Selected" : option.candidate.validity.accessibilityLabel,
            systemImage: isSelected ? "checkmark.circle.fill" : replacementOptionSystemImage(for: option),
            visualState: option.state,
            isSelected: isSelected
        ) {
            Text(option.title)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            replacementOptionImpactChips(option)

            QuietReflowPrimitiveLine(
                role: .impact,
                title: option.timelineImpactLabel,
                systemImage: "timeline.selection",
                visualState: option.state
            )

            QuietReflowPrimitiveLine(
                role: .receipt,
                title: option.receiptPreviewLabel,
                systemImage: "doc.text.magnifyingglass"
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func replacementOptionSystemImage(for option: TodayStepReplacementOptionState) -> String {
        switch option.candidate.kind {
        case .directBest:
            return "scope"
        case .lighter, .shorter, .lowerEnergy, .recoverySafe:
            return "arrow.down.right.and.arrow.up.left"
        case .locationCompatible, .noEquipment:
            return "mappin.and.ellipse"
        case .adminSetup, .maintenance:
            return "wrench.and.screwdriver"
        case .learningResearch:
            return "book"
        case .proofGathering:
            return "doc.text.magnifyingglass"
        case .prerequisite:
            return "link"
        case .catchUp:
            return "clock.arrow.circlepath"
        case .substitution, .parallelPath:
            return "arrow.triangle.branch"
        case .fallback:
            return "hand.draw"
        }
    }

    private func replacementOptionImpactChips(_ option: TodayStepReplacementOptionState) -> some View {
        HStack(spacing: theme.spacing.xs) {
            AmbitionChip(
                option.deadlineImpactLabel,
                role: .state,
                semanticState: option.deadlineImpactLabel == "Adds pressure" ? .caution : .focus
            )
            AmbitionChip(option.candidate.kind.semanticLabel, role: .state, semanticState: semanticState(for: option))
        }
        .accessibilityHidden(true)
    }

    private func semanticState(for option: TodayStepReplacementOptionState) -> AmbitionSemanticState {
        switch option.state {
        case .success:
            return .success
        case .warning:
            return .caution
        case .selected:
            return .review
        case .disabled:
            return .waiting
        case .pressed, .loading:
            return .waiting
        case .celebration:
            return .success
        case .default:
            return .focus
        }
    }

    private var impactSection: some View {
        QuietReflowPrimitiveStage(
            role: .impact,
            title: state.impactSectionTitle,
            subtitle: state.impactSectionSubtitle,
            accessibilityIdentifier: "TodayStepReplacementImpact"
        ) {
            if let selectedAlternative {
                QuietReflowPrimitiveLine(
                    role: .impact,
                    title: selectedAlternative.deadlineImpactLabel,
                    subtitle: selectedAlternative.timelineImpactLabel,
                    systemImage: selectedAlternative.deadlineImpactLabel == "Adds pressure" ? "exclamationmark.triangle.fill" : "clock",
                    visualState: selectedAlternative.state
                )
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var receiptSection: some View {
        QuietReflowPrimitiveStage(
            role: .receipt,
            title: state.receiptPreviewTitle,
            subtitle: state.noSilentChangesLabel,
            accessibilityIdentifier: "TodayStepReplacementReceiptPreview"
        ) {
            if let selectedAlternative {
                QuietReflowPrimitiveLine(
                    role: .receipt,
                    title: state.approvalReceiptPreview(for: selectedAlternative),
                    systemImage: "doc.text.magnifyingglass"
                )
            }
            QuietReflowPrimitiveLine(
                role: .noSilentChange,
                title: state.noSilentChangesLabel,
                systemImage: "lock.shield"
            )
        }
        .accessibilityElement(children: .combine)
    }

    private var actionRow: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Button {
                onWhyNotThis()
            } label: {
                Label(state.whyNotThisTitle, systemImage: "hand.thumbsdown")
                    .font(theme.typography.bodyEmphasized)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .accessibilityHint("Opens the rejection sheet without changing the recommendation.")
            .accessibilityIdentifier("TodayStepReplacementWhyNotThis")

            Button {
                guard let selectedAlternative else { return }
                onApprove(selectedAlternative)
            } label: {
                Label(state.confirmTitle, systemImage: "checkmark")
                    .font(theme.typography.bodyEmphasized)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: selectedAlternative == nil ? .disabled : .success))
            .disabled(selectedAlternative == nil)
            .accessibilityHint("Saves a calm local receipt and updates Today only after approval.")
            .accessibilityIdentifier("TodayStepReplacementApprove")
        }
    }
}

#if DEBUG
#Preview("Today Step Replacement Sheet") {
    TodayStepReplacementSheet(
        state: PreviewTodayScenarios.stepReplacementSheet,
        onWhyNotThis: {},
        onApprove: { _ in }
    )
    .ambitionTheme(.dark)
}
#endif
