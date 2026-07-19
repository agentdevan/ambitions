import AmbitionsDesignSystem
import SwiftUI

// Mutation/proof contract: these Today-scoped flows do not mutate Time placement or create proof. They show contextual availability or honest unavailable state and close without claiming protection, scheduling, or closure success.
struct TodayWindowProtectionFlowState: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let message: String
    let stepTitle: String?
    let windowSummary: String?
    let target: TodayActionTarget
    let isAvailable: Bool

    static func available(stepTitle: String, windowSummary: String, target: TodayActionTarget) -> TodayWindowProtectionFlowState {
        TodayWindowProtectionFlowState(
            id: "today.window-protection.\(target.goalID ?? "none").\(target.stepID ?? "none")",
            title: "Protect this window",
            message: "Today can keep this current fit visible here. Full Time placement remains unavailable until the focused Time fit train lands.",
            stepTitle: stepTitle,
            windowSummary: windowSummary,
            target: target,
            isAvailable: true
        )
    }

    static func unavailable(title: String, message: String, target: TodayActionTarget) -> TodayWindowProtectionFlowState {
        TodayWindowProtectionFlowState(
            id: "today.window-protection.unavailable.\(target.goalID ?? "none").\(target.stepID ?? "none")",
            title: title,
            message: message,
            stepTitle: nil,
            windowSummary: nil,
            target: target,
            isAvailable: false
        )
    }
}

struct TodayTimeShapeFlowState: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let message: String
    let stepTitle: String?
    let windowSummary: String?
    let target: TodayActionTarget
    let isAvailable: Bool

    static func contextual(stepTitle: String, windowSummary: String, target: TodayActionTarget) -> TodayTimeShapeFlowState {
        TodayTimeShapeFlowState(
            id: "today.time-shape.\(target.goalID ?? "none").\(target.stepID ?? "none")",
            title: "Shape Time",
            message: "Today can review this step against the current window. Full Time placement is not mutated from Today in this train.",
            stepTitle: stepTitle,
            windowSummary: windowSummary,
            target: target,
            isAvailable: true
        )
    }

    static func unavailable(title: String, message: String, target: TodayActionTarget) -> TodayTimeShapeFlowState {
        TodayTimeShapeFlowState(
            id: "today.time-shape.unavailable.\(target.goalID ?? "none").\(target.stepID ?? "none")",
            title: title,
            message: message,
            stepTitle: nil,
            windowSummary: nil,
            target: target,
            isAvailable: false
        )
    }
}

struct TodayWindowProtectionFlow: View {
    @Environment(\.ambitionTheme) var theme

    let state: TodayWindowProtectionFlowState
    let onDone: () -> Void

    var body: some View {
        TodayFocusedFlowScaffold(
            systemImage: state.isAvailable ? "shield.lefthalf.filled" : "shield.slash",
            title: state.title,
            message: state.message,
            stepTitle: state.stepTitle,
            windowSummary: state.windowSummary,
            actionTitle: "Done",
            onDone: onDone
        )
        .accessibilityIdentifier("TodayWindowProtectionFlow")
    }
}

struct TodayTimeShapeFlow: View {
    @Environment(\.ambitionTheme) var theme

    let state: TodayTimeShapeFlowState
    let onDone: () -> Void

    var body: some View {
        TodayFocusedFlowScaffold(
            systemImage: state.isAvailable ? "calendar.badge.clock" : "calendar.badge.exclamationmark",
            title: state.title,
            message: state.message,
            stepTitle: state.stepTitle,
            windowSummary: state.windowSummary,
            actionTitle: "Done",
            onDone: onDone
        )
        .accessibilityIdentifier("TodayTimeShapeFlow")
    }
}

private struct TodayFocusedFlowScaffold: View {
    @Environment(\.ambitionTheme) var theme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    let systemImage: String
    let title: String
    let message: String
    let stepTitle: String?
    let windowSummary: String?
    let actionTitle: String
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: theme.spacing.lg) {
                        Image(systemName: systemImage)
                            .font(theme.typography.title)
                            .foregroundStyle(theme.colors.accentWarm)
                            .accessibilityHidden(true)

                        Text(title)
                            .font(theme.typography.title.weight(.semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(message)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        if let stepTitle {
                            TodayFocusedFlowFact(label: "Step", value: stepTitle)
                        }

                        if let windowSummary {
                            TodayFocusedFlowFact(label: "Window", value: windowSummary)
                        }
                    }
                    .padding(theme.spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(actionTitle, action: onDone)
                    .buttonStyle(.borderedProminent)
                    .controlSize(dynamicTypeSize.isAccessibilitySize ? .large : .regular)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(theme.spacing.lg)
            }
            .background(theme.colors.canvas)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct TodayFocusedFlowFact: View {
    @Environment(\.ambitionTheme) var theme

    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text(label)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
                .textCase(.uppercase)
            Text(value)
                .font(theme.typography.body.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
    }
}
