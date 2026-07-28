import AmbitionsDesignSystem
import SwiftUI

struct DegradedStateSurface: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: DegradedStatePresentation
    let primaryAccessibilityIdentifier: String?
    let secondaryAccessibilityIdentifier: String?
    let onPrimaryAction: (() -> Void)?
    let onSecondaryAction: (() -> Void)?

    init(
        state: DegradedStatePresentation,
        primaryAccessibilityIdentifier: String? = nil,
        secondaryAccessibilityIdentifier: String? = nil,
        onPrimaryAction: (() -> Void)? = nil,
        onSecondaryAction: (() -> Void)? = nil
    ) {
        self.state = state
        self.primaryAccessibilityIdentifier = primaryAccessibilityIdentifier
        self.secondaryAccessibilityIdentifier = secondaryAccessibilityIdentifier
        self.onPrimaryAction = onPrimaryAction
        self.onSecondaryAction = onSecondaryAction
    }

    var body: some View {
        AppCard(state: state.tone) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: state.icon)
                        .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.textSecondary)
                        .accessibilityHidden(true)
                    AmbitionsStatusSymbol(state.statusRole, style: .badge)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(state.title)
                        .font(theme.typography.titleCompact)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(state.explanation)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                actionControls
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier(state.id)
    }

    @ViewBuilder
    private var actionControls: some View {
        if hasActions {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    primaryActionButton
                    secondaryActionButton
                }
            } else {
                HStack(spacing: theme.spacing.sm) {
                    primaryActionButton
                    secondaryActionButton
                }
            }
        }
    }

    private var hasActions: Bool {
        onPrimaryAction != nil || (state.secondaryAction != nil && onSecondaryAction != nil)
    }

    @ViewBuilder
    private var primaryActionButton: some View {
        if let onPrimaryAction {
            Button {
                onPrimaryAction()
            } label: {
                Label(state.primaryAction.title, systemImage: state.primaryAction.systemImage)
            }
            .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: state.tone))
            .accessibilityIdentifier(primaryAccessibilityIdentifier ?? "\(state.id).primary")
        }
    }

    @ViewBuilder
    private var secondaryActionButton: some View {
        if let secondary = state.secondaryAction, let onSecondaryAction {
            Button {
                onSecondaryAction()
            } label: {
                Label(secondary.title, systemImage: secondary.systemImage)
            }
            .buttonStyle(AmbitionButtonStyle(tier: .tertiary, state: .default))
            .accessibilityIdentifier(secondaryAccessibilityIdentifier ?? "\(state.id).secondary")
        }
    }
}
