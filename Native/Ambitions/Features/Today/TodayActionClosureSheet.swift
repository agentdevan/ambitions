import AmbitionsDesignSystem
import SwiftUI

struct TodayActionClosureSheet: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dismiss) private var dismiss

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
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        Image(systemName: selectedOutcome?.id == outcome.id ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(theme.colors.accentWarm)
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(outcome.title)
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(outcome.meaning)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        Spacer(minLength: theme.spacing.xs)
                        if outcome.createsProof {
                            AmbitionChip("Proof", role: .state, semanticState: .success)
                        }
                    }
                    .padding(theme.spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(theme.colors.surfaceOverlay)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .stroke(selectedOutcome?.id == outcome.id ? theme.colors.accentWarm : theme.colors.strokeSubtle, lineWidth: 1)
                )
                .accessibilityLabel(outcome.title)
                .accessibilityValue(outcome.meaning)
                .accessibilityHint(outcome.receiptPreview)
                .accessibilityIdentifier("TodayActionClosureOutcome.\(outcome.id)")
            }
        }
    }

    private var receiptPreview: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(state.receiptPreviewTitle)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
            Text(selectedOutcome?.receiptPreview ?? "Choose an outcome to preview the receipt.")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.74))
        )
        .accessibilityIdentifier("TodayActionClosureReceiptPreview")
    }
}
