import AmbitionsDesignSystem
import SwiftUI

struct TodayActionClosureSheet: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: TodayActionClosureSheetState
    let onConfirm: (TodayActionClosureOutcomeState) -> Void

    @State private var selectedOutcome: TodayActionClosureOutcomeState?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text("Close the loop")
                            .font(theme.typography.title)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(state.objectTitle)
                            .font(theme.typography.titleCompact)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(state.prompt)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }

                    closureContext
                    closureDiamond
                    softPriorStepPrompt
                    closureOutcomeSection(title: "Likely outcomes", outcomes: state.primaryOutcomes)

                    if state.moreOutcomes.isEmpty == false {
                        DisclosureGroup("More options") {
                            closureOutcomeSection(title: nil, outcomes: state.moreOutcomes)
                                .padding(.top, theme.spacing.sm)
                        }
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    }

                    receiptPreview
                    confirmButton
                }
                .padding(theme.spacing.lg)
            }
            .background(TodayBackgroundView())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityIdentifier("TodayActionClosureDismiss")
                }
            }
        }
        .onAppear {
            selectedOutcome = selectedOutcome ?? state.primaryOutcomes.first
        }
        .accessibilityIdentifier("TodayActionClosureSheet")
    }

    private var confirmButton: some View {
        Button {
            if let selectedOutcome {
                onConfirm(selectedOutcome)
            }
        } label: {
            Label(state.confirmTitle, systemImage: "checkmark")
                .font(theme.typography.bodyEmphasized)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: selectedOutcome == nil ? .disabled : .success))
        .disabled(selectedOutcome == nil)
        .accessibilityIdentifier("TodayActionClosureConfirm")
    }

    private var closureContext: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Label(state.startHereReceiptLabel, systemImage: "doc.text.magnifyingglass")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
            Label(state.originalContext, systemImage: "calendar")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            Label(state.privacyLabel, systemImage: "lock")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("TodayActionClosureContext")
    }

    private var closureDiamond: some View {
        ClosureRecoveryPrimitiveStage(
            role: .closure,
            eyebrow: "Outcome map",
            title: state.diamond.title,
            subtitle: state.diamond.summary,
            accessibilityIdentifier: "TodayActionClosureDiamond"
        ) {
            if dynamicTypeSize.isAccessibilitySize {
                closureDiamondList
            } else {
                closureDiamondVisual
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(state.diamond.title)
        .accessibilityValue("\(state.diamond.summary) \(state.diamond.accessibilityValue). \(state.diamond.noSilentChangeLabel).")
    }

    private var closureDiamondVisual: some View {
        ZStack {
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .fill(theme.colors.accentWarm.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                        .stroke(theme.colors.accentWarm.opacity(0.52), lineWidth: 1)
                )
                .rotationEffect(reduceMotion ? .zero : .degrees(45))
                .frame(width: 118, height: 118)

            Text(state.diamond.centerLabel)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .multilineTextAlignment(.center)
                .frame(width: 72)

            closureDiamondFacet(state.diamond.facets[0])
                .offset(y: -74)
            closureDiamondFacet(state.diamond.facets[1])
                .offset(x: 106)
            closureDiamondFacet(state.diamond.facets[2])
                .offset(y: 74)
            closureDiamondFacet(state.diamond.facets[3])
                .offset(x: -106)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 192)
        .accessibilityHidden(true)
    }

    private var closureDiamondList: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            ForEach(state.diamond.facets) { facet in
                Label {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(facet.title)
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(facet.summary)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                } icon: {
                    Image(systemName: facet.systemImage)
                        .foregroundStyle(theme.colors.accentWarm)
                }
            }
            Text(state.diamond.noSilentChangeLabel)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
        }
    }

    private func closureDiamondFacet(_ facet: TodayActionClosureDiamondFacetState) -> some View {
        VStack(spacing: theme.spacing.xxxs) {
            Image(systemName: facet.systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.accentWarm)
            Text(facet.title)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
        }
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, theme.spacing.xxxs)
        .background(
            Capsule(style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.86))
        )
    }

    private var softPriorStepPrompt: some View {
        ClosureRecoveryPrimitiveLine(
            role: .recovery,
            title: "Recovery prompt",
            subtitle: state.softPriorStepPrompt,
            systemImage: "arrow.triangle.2.circlepath",
            accessibilityIdentifier: "TodayActionClosureRecoveryPrompt"
        )
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func closureOutcomeSection(title: String?, outcomes: [TodayActionClosureOutcomeState]) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            if let title {
                Text(title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
            }
            ForEach(outcomes) { outcome in
                Button {
                    selectedOutcome = outcome
                } label: {
                    ClosureRecoveryPrimitiveLine(
                        role: outcome.createsProof ? .receipt : .closure,
                        title: outcome.title,
                        subtitle: outcome.meaning,
                        systemImage: selectedOutcome?.id == outcome.id ? "checkmark.circle.fill" : "circle",
                        isEmphasized: selectedOutcome?.id == outcome.id,
                        accessibilityIdentifier: "TodayActionClosureOutcome.\(outcome.id)"
                    ) {
                        Text(outcome.consequenceLabel)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        Text(outcome.recoveryPrompt)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        if outcome.createsProof {
                            AmbitionChip("Proof", role: .state, semanticState: .success)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(outcome.title)
                .accessibilityValue("\(outcome.meaning) \(outcome.consequenceLabel)")
                .accessibilityHint("\(outcome.recoveryPrompt) \(outcome.receiptPreview)")
            }
        }
    }

    private var receiptPreview: some View {
        ClosureRecoveryPrimitiveStage(
            role: .receipt,
            eyebrow: "Review preview",
            title: state.receiptPreviewTitle,
            subtitle: receiptPreviewText,
            statusLabel: selectedOutcome.map { state.proofReceiptPeek(for: $0).noSilentChangesLabel } ?? "Changes stay reviewable",
            accessibilityIdentifier: "TodayActionClosureReceiptPreview"
        ) {
            Text(state.receiptPreviewTitle)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
            Text(state.recoveryReceiptLabel)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
        }
    }

    private var receiptPreviewText: String {
        guard let selectedOutcome else {
            return "Choose an outcome to preview the receipt."
        }
        let peek = state.proofReceiptPeek(for: selectedOutcome)
        return "\(peek.title) · \(peek.subtitle)"
    }
}
