import AmbitionsDesignSystem
import SwiftUI

struct TodayPrimaryActionButton: View {
    let action: TodayInlineAction
    let handler: (TodayInlineAction) -> Void

    var body: some View {
        Button {
            handler(action)
        } label: {
            Label(action.title, systemImage: action.systemImage)
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: action.state))
        .accessibilityLabel(action.title)
        .accessibilityIdentifier(accessibilityIdentifier)
        .modifier(TodayActionAccessibilityHint(action: action))
    }

    var accessibilityIdentifier: String {
        let targetID = action.target.goalID ?? action.target.draftID ?? "none"
        return "today.hero.primary-action.\(action.kind.rawValue).\(targetID)"
    }
}

struct TodayActionChip: View {
    let action: TodayInlineAction
    let handler: (TodayInlineAction) -> Void

    var body: some View {
        Button {
            handler(action)
        } label: {
            Label(action.title, systemImage: action.systemImage)
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .padding(.vertical, 10)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: action.state))
        .accessibilityIdentifier(accessibilityIdentifier)
        .modifier(TodayActionAccessibilityHint(action: action))
    }

    var accessibilityIdentifier: String {
        action.accessibilityIdentifier
    }
}

struct TodayActionAccessibilityHint: ViewModifier {
    let action: TodayInlineAction

    func body(content: Content) -> some View {
        switch action.kind {
        case .startStepSession:
            content.accessibilityHint("Starts a bounded Step session for this one step.")
        case .pauseStepSession:
            content.accessibilityHint("Pauses the session without changing proof or plan.")
        case .stopStepSession:
            content.accessibilityHint("Returns to Today without changing proof or plan.")
        case .closeActionClosure:
            content.accessibilityHint("Opens closure options and review preview for this step.")
        case .askWhyThisMatters:
            content.accessibilityHint("Explains why this step is worth doing now.")
        case .protectLater:
            content.accessibilityHint("Hands this off to the canonical planning surface.")
        default:
            content
        }
    }
}
