#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionAsyncState: Sendable, Equatable {
    case loading(lines: Int = 3)
    case empty(title: String, message: String, icon: String, actionTitle: String? = nil)
    case error(title: String, message: String, icon: String = "exclamationmark.triangle", actionTitle: String? = nil)
}

public struct AsyncStateCard: View {
    private let state: AmbitionAsyncState
    private let actionAccessibilityIdentifier: String?
    private let action: (() -> Void)?

    public init(
        _ state: AmbitionAsyncState,
        actionAccessibilityIdentifier: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.state = state
        self.actionAccessibilityIdentifier = actionAccessibilityIdentifier
        self.action = action
    }

    public var body: some View {
        switch state {
        case let .loading(lines):
            LoadingSkeletonCard(lineCount: lines)
        case let .empty(title, message, icon, actionTitle):
            EmptyStateCard(
                title: title,
                message: message,
                icon: icon,
                actionTitle: actionTitle,
                actionAccessibilityIdentifier: actionAccessibilityIdentifier,
                action: action
            )
        case let .error(title, message, icon, actionTitle):
            ErrorStateCard(
                title: title,
                message: message,
                icon: icon,
                actionTitle: actionTitle,
                actionAccessibilityIdentifier: actionAccessibilityIdentifier,
                action: action
            )
        }
    }
}

public struct ErrorStateCard: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let message: String
    private let icon: String
    private let actionTitle: String?
    private let actionAccessibilityIdentifier: String?
    private let action: (() -> Void)?

    public init(
        title: String,
        message: String,
        icon: String = "exclamationmark.triangle",
        actionTitle: String? = nil,
        actionAccessibilityIdentifier: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.actionTitle = actionTitle
        self.actionAccessibilityIdentifier = actionAccessibilityIdentifier
        self.action = action
    }

    public var body: some View {
        AppCard(state: .warning, accent: theme.colors.warning) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: icon)
                        .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.warning)
                    StatusChip("May need attention", icon: "exclamationmark.triangle.fill", state: .warning)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(title)
                        .font(theme.typography.titleCompact)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(message)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: .warning, accent: theme.colors.warning))
                        .accessibilityIdentifier(actionAccessibilityIdentifier ?? "")
                }
            }
        }
    }
}
#endif
