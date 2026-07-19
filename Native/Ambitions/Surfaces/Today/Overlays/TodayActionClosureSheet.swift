import AmbitionsDesignSystem
import SwiftUI

// Today closure contract: actions preview the runtime mutation, preserve accessibility labels, and show proof/receipt consequences before confirmation.

struct TodayActionClosureSheet: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    let state: TodayActionClosureSheetState
    let onConfirm: (TodayActionClosureOutcomeState) -> Void

    @State private var selectedOutcome: TodayActionClosureOutcomeState?
    @State private var areMoreOutcomesExpanded = false
    @State private var isReceiptPreviewExpanded = false

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
                    selectedOutcomeSummary
                    softPriorStepPrompt
                    closureOutcomePicker

                    if state.moreOutcomes.isEmpty == false {
                        DisclosureGroup("More options", isExpanded: $areMoreOutcomesExpanded) {
                            closureOutcomeSection(title: nil, outcomes: state.moreOutcomes)
                                .padding(.top, theme.spacing.sm)
                        }
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    }

                    receiptDisclosure
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

    var confirmButton: some View {
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

    var closureContext: some View {
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

    var selectedOutcomeSummary: some View {
        let outcome = selectedOutcome ?? state.primaryOutcomes.first
        return ClosureRecoveryPrimitiveStage(
            role: outcome?.createsProof == true ? .receipt : .closure,
            eyebrow: "What changes",
            title: outcome?.title ?? "Choose outcome",
            subtitle: outcome?.consequenceLabel ?? "Choose an outcome to see what Today will change.",
            statusLabel: outcome?.undoPreviewLabel ?? "Changes stay reviewable",
            accessibilityIdentifier: "TodayActionClosureConsequencePreview"
        ) {
            Text(outcome?.recoveryPrompt ?? state.softPriorStepPrompt)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    var softPriorStepPrompt: some View {
        ClosureRecoveryPrimitiveLine(
            role: .recovery,
            title: "Recovery prompt",
            subtitle: state.softPriorStepPrompt,
            systemImage: "arrow.triangle.2.circlepath",
            accessibilityIdentifier: "TodayActionClosureRecoveryPrompt"
        )
        .accessibilityElement(children: .combine)
    }

    var closureOutcomePicker: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Choose outcome")
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 142), spacing: theme.spacing.xs, alignment: .topLeading)],
                alignment: .leading,
                spacing: theme.spacing.xs
            ) {
                ForEach(state.primaryOutcomes) { outcome in
                    closureOutcomeTile(outcome)
                }
            }
        }
        .accessibilityIdentifier("TodayActionClosureOutcomePicker")
    }

    func closureOutcomeTile(_ outcome: TodayActionClosureOutcomeState) -> some View {
        let isSelected = selectedOutcome?.id == outcome.id

        return Button {
            selectedOutcome = outcome
        } label: {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(isSelected ? theme.colors.success : theme.colors.textTertiary)

                Text(outcome.title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                    .fill(isSelected ? theme.colors.surfaceOverlay : theme.colors.surfacePrimary.opacity(0.74))
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                    .stroke(isSelected ? theme.colors.strokeStrong : theme.colors.strokeSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(outcome.title)
        .accessibilityValue("\(outcome.meaning) \(outcome.consequenceLabel)")
        .accessibilityHint("\(outcome.recoveryPrompt) \(outcome.receiptPreview)")
        .accessibilityIdentifier("TodayActionClosureOutcome.\(outcome.id)")
    }

    @ViewBuilder
    func closureOutcomeSection(title: String?, outcomes: [TodayActionClosureOutcomeState]) -> some View {
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

    var receiptDisclosure: some View {
        DisclosureGroup(isExpanded: $isReceiptPreviewExpanded) {
            receiptPreview
                .padding(.top, theme.spacing.sm)
        } label: {
            Text("Receipt and review")
                .accessibilityIdentifier("TodayActionClosureReceiptDisclosure")
        }
        .font(theme.typography.bodyEmphasized)
        .foregroundStyle(theme.colors.textPrimary)
    }

    var receiptPreview: some View {
        ClosureRecoveryPrimitiveStage(
            role: .receipt,
            eyebrow: "Local receipt",
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

    var receiptPreviewText: String {
        guard let selectedOutcome else {
            return "Choose an outcome to preview the receipt."
        }
        let peek = state.proofReceiptPeek(for: selectedOutcome)
        return "\(peek.title) · \(peek.subtitle)"
    }
}
