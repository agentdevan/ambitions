import AmbitionsDesignSystem
import SwiftUI

struct HeroStepPanelSignalRow: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let action: TodayInlineAction
    let reason: String
    let sourceSummary: String
    let isPrivateProjection: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Recommended step")
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
                .accessibilityHidden(true)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    actionBadge
                    reasonCapsule
                }
            } else {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    actionBadge
                    reasonCapsule
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Recommended step")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("TodayHeroStepPanelSignalRow")
    }

    private var actionBadge: some View {
        let style = theme.stateStyle(for: action.state)
        return HStack(spacing: theme.spacing.xs) {
            Image(systemName: action.systemImage)
                .font(.caption.weight(.semibold))
                .accessibilityHidden(true)
            Text(action.title)
                .font(theme.typography.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, theme.spacing.xs)
        .background(Capsule().fill(style.fill))
        .overlay(Capsule().stroke(style.stroke, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Primary action")
        .accessibilityValue(action.title)
    }

    private var reasonCapsule: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            EvidenceLabel(
                "Why this?",
                detail: reason,
                source: sourceSummary,
                state: evidenceState,
                context: .today
            )

            ProofPulse(isActive: proofPulseIsActive, label: "Hero step proof preview")
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
    }

    private var evidenceState: LivingVisualState {
        if isPrivateProjection { return .sensitive }
        switch action.state {
        case .warning:
            return .pressured
        case .disabled, .loading:
            return .stale
        case .success:
            return .proof
        case .celebration:
            return .recovery
        case .selected, .pressed:
            return .active
        case .default:
            return .calm
        }
    }

    private var proofPulseIsActive: Bool {
        isPrivateProjection == false && action.state != .disabled && action.state != .loading
    }

    private var accessibilityValue: String {
        "Action: \(action.title). Why this? \(reason). Source: \(sourceSummary)."
    }
}
