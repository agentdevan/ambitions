import AmbitionsDesignSystem
import SwiftUI

struct TodayRejectionReasonSheet: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.dismiss) private var dismiss

    let state: TodayRejectionReasonSheetState
    let onSubmit: (TodayRejectionSubmission) -> Void

    @State private var selectedReason: StepCandidateRejectionReason?
    @State private var customReasonText: String = ""
    @FocusState private var customReasonFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    header
                    contextCard
                    reasonsCard
                    customReasonCard
                    skipCard
                    saveButton
                }
                .padding(theme.spacing.lg)
            }
            .background(TodayBackgroundView())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("TodayRejectionReasonDismiss")
                }
            }
        }
        .onAppear {
            selectedReason = selectedReason ?? state.options.first?.reason ?? StepCandidateRejectionReason(code: .custom)
        }
        .onChange(of: selectedReason?.code) { _, newCode in
            if newCode == .custom {
                customReasonFocused = true
            }
        }
        .accessibilityIdentifier("TodayRejectionReasonSheet")
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
        }
        .accessibilityElement(children: .combine)
    }

    private var contextCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Label(state.contextLabel, systemImage: "calendar")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            Text("This stays local and only affects future recommendation quality.")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.78))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("TodayRejectionReasonContext")
    }

    private var reasonsCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Why not this?")
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)

            ForEach(state.options) { option in
                reasonRow(option)
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("TodayRejectionReasonOptions")
    }

    private func reasonRow(_ option: TodayRejectionReasonOptionState) -> some View {
        Button {
            selectedReason = option.reason
            if option.reason.code == .custom {
                customReasonFocused = true
            }
        } label: {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: selectedReason?.code == option.reason.code ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(selectedReason?.code == option.reason.code ? theme.colors.accentWarm : theme.colors.textTertiary)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack(spacing: theme.spacing.xs) {
                        Text(option.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        if option.isSensitive {
                            AmbitionChip("Local only", role: .state, semanticState: .protected)
                        }
                    }

                    Text(option.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(selectedReason?.code == option.reason.code ? theme.colors.accentWarm.opacity(0.12) : theme.colors.surfaceSecondary.opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(selectedReason?.code == option.reason.code ? theme.colors.accentWarm : theme.colors.strokeSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(option.title)
        .accessibilityValue(selectedReason?.code == option.reason.code ? "Selected" : "Not selected")
        .accessibilityHint(option.detail)
        .accessibilityIdentifier("TodayRejectionReasonOption.\(option.id)")
    }

    private var customReasonCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Button {
                selectedReason = StepCandidateRejectionReason(code: .custom)
                customReasonFocused = true
            } label: {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Image(systemName: selectedReason?.code == .custom ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(selectedReason?.code == .custom ? theme.colors.accentWarm : theme.colors.textTertiary)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text("Custom reason")
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(state.customReasonPrompt)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: theme.spacing.sm)
                }
                .padding(theme.spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(selectedReason?.code == .custom ? theme.colors.accentWarm.opacity(0.12) : theme.colors.surfaceSecondary.opacity(0.72))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .stroke(selectedReason?.code == .custom ? theme.colors.accentWarm : theme.colors.strokeSubtle, lineWidth: 1)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("TodayRejectionReasonCustomRow")

            if selectedReason?.code == .custom {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    TextEditor(text: $customReasonText)
                        .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 140 : 104)
                        .padding(theme.spacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                .fill(theme.colors.surfaceOverlay)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                        )
                        .focused($customReasonFocused)
                        .accessibilityLabel("Custom reason")
                        .accessibilityHint("Add a local reason that stays on this device.")
                        .accessibilityIdentifier("TodayRejectionReasonCustomText")

                    if customReasonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Examples: too long, wrong location, emotionally not ready.")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
    }

    private var skipCard: some View {
        Button {
            onSubmit(TodayRejectionSubmission(reason: StepCandidateRejectionReason(code: .custom), skippedReason: true, customText: nil))
            dismiss()
        } label: {
            Label(state.skipTitle, systemImage: "forward")
                .font(theme.typography.bodyEmphasized)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
        }
        .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: .default))
        .accessibilityHint("Saves the rejection without a reason while keeping the receipt local.")
        .accessibilityIdentifier("TodayRejectionReasonSkip")
    }

    private var saveButton: some View {
        Button {
            let selected = selectedReason ?? StepCandidateRejectionReason(code: .custom)
            let customText = selected.code == .custom ? customReasonText : nil
            let skippedReason = selected.code == .custom && customText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false
            onSubmit(
                TodayRejectionSubmission(
                    reason: selected,
                    skippedReason: skippedReason,
                    customText: customText
                )
            )
            dismiss()
        } label: {
            Label(state.confirmTitle, systemImage: "checkmark")
                .font(theme.typography.bodyEmphasized)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
        }
        .buttonStyle(AmbitionButtonStyle(tier: .primary, state: selectedReason == nil ? .default : .selected))
        .accessibilityIdentifier("TodayRejectionReasonConfirm")
    }
}
