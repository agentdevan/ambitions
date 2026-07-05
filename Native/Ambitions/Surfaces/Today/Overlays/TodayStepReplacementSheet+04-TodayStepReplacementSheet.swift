import AmbitionsDesignSystem
import SwiftUI

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

    var selectedAlternative: TodayStepReplacementOptionState? {
        guard let selectedAlternativeID else { return state.selectedAlternative }
        return state.alternatives.first(where: { $0.id == selectedAlternativeID }) ?? state.selectedAlternative
    }

    var header: some View {
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

    var originalRecommendationCard: some View {
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

    var alternativesSection: some View {
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

    func replacementOption(_ option: TodayStepReplacementOptionState) -> some View {
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

    func replacementOptionLabel(_ option: TodayStepReplacementOptionState, isSelected: Bool) -> some View {
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

    func replacementOptionSystemImage(for option: TodayStepReplacementOptionState) -> String {
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

    func replacementOptionImpactChips(_ option: TodayStepReplacementOptionState) -> some View {
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

    func semanticState(for option: TodayStepReplacementOptionState) -> AmbitionSemanticState {
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

    var impactSection: some View {
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

    var receiptSection: some View {
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

    var actionRow: some View {
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
