import AmbitionsDesignSystem
import SwiftUI

extension LifeShapeFieldView {
    var reflowTrustSeam: some View {
        Group {
            if let decision = reflowDecision,
               let option = selectedReflowOption,
               let receiptPreview = reflowReceiptPreview {
                QuietReflowPrimitiveStage(
                    role: .preview,
                    title: "Change preview",
                    subtitle: decision.subtitle,
                    statusLabel: reflowStatusTitle,
                    visualState: reflowStatusState,
                    accessibilityIdentifier: "time.life-shape-field.change-review-seam"
                ) {
                    QuietReflowBeforeAfterPrimitive(
                        title: option.beforeAfterPreview.title,
                        beforeLabel: option.beforeAfterPreview.beforeLabel,
                        afterLabel: option.beforeAfterPreview.afterLabel,
                        changeLabel: option.beforeAfterPreview.shapeChangeLabel,
                        receiptLabel: option.beforeAfterPreview.receiptPreviewLabel,
                        visualState: reflowStatusState
                    )

                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.lg) {
                        QuietReflowPrimitiveLine(
                            role: .source,
                            title: decision.sourceLabel,
                            systemImage: "checkmark.shield",
                            visualState: decision.visualState
                        )
                        QuietReflowPrimitiveLine(
                            role: .manualFallback,
                            title: calendarFallbackTitle,
                            systemImage: calendarFallbackIcon,
                            visualState: calendarFallbackState
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        QuietReflowPrimitiveLine(
                            role: .impact,
                            title: "Reason",
                            subtitle: decision.reasonLabel,
                            systemImage: "questionmark.circle",
                            visualState: decision.visualState
                        )
                        QuietReflowPrimitiveLine(
                            role: .noSilentChange,
                            title: "Control",
                            subtitle: option.boundaryLabel,
                            systemImage: "lock.shield",
                            visualState: .default
                        )
                        QuietReflowPrimitiveLine(
                            role: .receipt,
                            title: receiptPreview.confirmationRequired,
                            systemImage: "doc.text.magnifyingglass",
                            visualState: reflowStatusState
                        )
                    }

                    reflowActionRow(option)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Time change preview")
                .accessibilityValue(reflowAccessibilityValue(option: option, decision: decision, receiptPreview: receiptPreview))
            }
        }
    }
    func reflowActionRow(_ option: TimeReflowDecisionOptionState) -> some View {
        let actions = [
            TimeReflowDecisionActionKind.decline,
            TimeReflowDecisionActionKind.edit,
            TimeReflowDecisionActionKind.accept
        ]

        return Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: theme.spacing.xs) {
                    ForEach(actions, id: \.self) { action in
                        reflowActionButton(action, option: option)
                    }
                }
            } else {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(actions, id: \.self) { action in
                        reflowActionButton(action, option: option)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    func reflowActionButton(
        _ action: TimeReflowDecisionActionKind,
        option: TimeReflowDecisionOptionState
    ) -> some View {
        let accessibilityReduceMotion = reduceMotion
        return Button {
            withAnimation(accessibilityReduceMotion ? nil : .easeOut(duration: 0.18)) {
                confirmedReflowAction = action
                selectedReflowOptionID = option.id
            }
            onReflowDecision?(option, action)
        } label: {
            Label(reflowActionTitle(action), systemImage: action.icon)
                .font(theme.typography.micro)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacing.xxs)
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.stateStyle(for: reflowActionState(action)).foreground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.stateStyle(for: reflowActionState(action)).stroke.opacity(confirmedReflowAction == action ? 0.90 : 0.34))
                .frame(height: confirmedReflowAction == action ? 2 : 1)
        }
        .accessibilityIdentifier("time.life-shape-field.change-review.\(action.rawValue)")
    }

    func reflowActionTitle(_ action: TimeReflowDecisionActionKind) -> String {
        switch action {
        case .accept: "Apply"
        case .edit: "Adjust"
        case .decline: "Decline"
        }
    }

    func reflowActionState(_ action: TimeReflowDecisionActionKind) -> AmbitionVisualState {
        if confirmedReflowAction == action {
            return action == .decline ? .success : .selected
        }
        return switch action {
        case .accept: .selected
        case .edit: .default
        case .decline: .success
        }
    }

    var reflowStatusTitle: String {
        switch confirmedReflowAction {
        case .accept: "Review"
        case .edit: "Adjustment pending"
        case .decline: "Current shape kept"
        case nil: displayedRenderStateTitle
        }
    }

    var reflowStatusState: AmbitionVisualState {
        switch confirmedReflowAction {
        case .accept: .selected
        case .edit: .default
        case .decline: .success
        case nil: displayedRenderState.visualState
        }
    }

    var calendarFallbackTitle: String {
        guard let calendarAwareness else {
            return "User choice"
        }
        switch calendarAwareness.status {
        case .denied:
            return "Calendar denied"
        case .calendarAware:
            return "Calendar optional"
        case .baseline, .unavailable, .writeOnly:
            return "User choice"
        }
    }

    var calendarFallbackIcon: String {
        guard let calendarAwareness else { return "hand.draw" }
        return calendarAwareness.status == .calendarAware ? "calendar.badge.clock" : "hand.draw"
    }

    var calendarFallbackState: AmbitionVisualState {
        guard let calendarAwareness else { return .default }
        return calendarAwareness.status == .denied ? .warning : .default
    }

    func reflowAccessibilityValue(
        option: TimeReflowDecisionOptionState,
        decision: TimeReflowDecisionState,
        receiptPreview: TimeReflowReceiptPreviewState
        ) -> String {
        [
            "Life Calendar: \(reading.title)",
            "Capacity: \(reading.capacityStatement)",
            decision.subtitle,
            option.beforeAfterPreview.accessibilityValue,
	            "Primary action: Apply after review.",
            "Available actions: Decline, Adjust, Apply.",
            "Source: \(decision.sourceLabel)",
            "Reason: \(decision.reasonLabel)",
            "Control: \(option.boundaryLabel)",
            "Receipt: \(receiptPreview.confirmationRequired)"
        ].joined(separator: ". ")
    }

}
