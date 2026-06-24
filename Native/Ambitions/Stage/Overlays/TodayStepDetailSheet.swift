import AmbitionsDesignSystem
import SwiftUI

struct TodayStepDetailSheet: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    let detail: DayRailStepDetailState
    let onAction: (TodayInlineAction) -> Void

    init(detail: DayRailStepDetailState, onAction: @escaping (TodayInlineAction) -> Void = { _ in }) {
        self.detail = detail
        self.onAction = onAction
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    header
                    labels
                    whyThis
                    proofReceiptAccess
                    privacyState
                    actions
                }
                .padding(theme.spacing.lg)
            }
            .background(TodayBackgroundView())
            .navigationTitle("Open step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityIdentifier("TodayStepDetailDismiss")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Open step")
        .accessibilityIdentifier("TodayStepDetail")
    }

    var header: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(detail.timingBucket)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)

            Text(detail.title)
                .font(theme.typography.titleCompact)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("TodayStepDetailTitle")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(detail.isPrivateProjection ? "Private step" : detail.title)
    }

    var labels: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            detailLabel(title: "Duration", value: detail.durationLabel, identifier: "TodayStepDetailDurationLabel")
            detailLabel(title: "Duration source", value: detail.durationSourceLabel, identifier: nil)
            detailLabel(title: "Source", value: detail.sourceLabel, identifier: "TodayStepDetailSourceLabel")
            detailLabel(title: "Context", value: detail.contextLabel, identifier: "TodayStepDetailContextLabel")
            detailLabel(title: "Goal", value: detail.goalLinkLabel, identifier: "TodayStepDetailGoalLinkLabel")
        }
    }

    func detailLabel(title: String, value: String, identifier: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: 112, alignment: .leading)
            Text(value)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: theme.spacing.xs)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        .accessibilityIdentifier(identifier ?? "")
    }

    var whyThis: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Recommended because")
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)

            ForEach(Array(detail.whyBullets.enumerated()), id: \.offset) { _, bullet in
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Circle()
                        .fill(theme.colors.accentWarm.opacity(0.82))
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)
                        .accessibilityHidden(true)
                    Text(bullet)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Open step")
        .accessibilityValue(detail.whyBullets.joined(separator: ". "))
        .accessibilityIdentifier("TodayStepDetailWhyThis")
    }

    var proofReceiptAccess: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(theme.typography.titleCompact)
                    .foregroundStyle(theme.semanticAccent(for: .trust))
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(theme.semanticStyle(for: .trust).fill))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Proof and receipt")
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(detail.proofReceiptLabel)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(detail.receiptBoundaryLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.74))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.semanticStyle(for: .trust).stroke.opacity(0.72), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Proof and receipt")
        .accessibilityValue("\(detail.proofReceiptLabel) \(detail.receiptBoundaryLabel)")
        .accessibilityIdentifier("TodayStepDetailProofReceiptAccess")
    }

    @ViewBuilder
    var privacyState: some View {
        if let privacyLabel = detail.privacyStateLabel {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "lock.shield")
                    .foregroundStyle(theme.semanticAccent(for: .protected))
                    .accessibilityHidden(true)
                Text(privacyLabel)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer(minLength: theme.spacing.sm)
            }
            .padding(theme.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.semanticStyle(for: .protected).fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.semanticStyle(for: .protected).stroke, lineWidth: 1)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Private state")
            .accessibilityValue(privacyLabel)
            .accessibilityIdentifier("TodayStepDetailPrivateState")
        }
    }

    var actions: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Button {
                dismiss()
                onAction(detail.primaryAction)
            } label: {
                Label(detail.primaryAction.title, systemImage: detail.primaryAction.systemImage)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .disabled(detail.primaryAction.target.goalID == nil && detail.primaryAction.target.stepID == nil && detail.primaryAction.target.draftID == nil)
            .accessibilityValue(detail.stepSessionLabel)
            .accessibilityHint("Starts a bounded Step session for this step.")
            .accessibilityIdentifier("TodayStepDetailPrimaryAction")

            Button {
                dismiss()
                onAction(detail.closureAction)
            } label: {
                Label(detail.closureAction.title, systemImage: detail.closureAction.systemImage)
                    .font(theme.typography.bodyEmphasized)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .accessibilityHint("Opens closure choices for this step without changing anything silently.")
            .accessibilityIdentifier("TodayStepDetailClosureAction")

            HStack(spacing: theme.spacing.sm) {
                ForEach(detail.secondaryActions) { action in
                    Button {
                        dismiss()
                        onAction(action)
                    } label: {
                        Label(action.title, systemImage: action.systemImage)
                            .font(theme.typography.caption)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, theme.spacing.sm)
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                    .accessibilityLabel(action.title)
                    .accessibilityIdentifier(action.accessibilityIdentifier)
                    .modifier(TodayActionAccessibilityHint(action: action))
                }
            }
        }
    }
}
