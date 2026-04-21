import AmbitionsDesignSystem
import SwiftUI

enum AppShellHeaderPosture: String, Sendable {
    case execution
    case direction
    case shaping
    case reflection
    case utility

    var title: String {
        switch self {
        case .execution: "Execution"
        case .direction: "Direction"
        case .shaping: "Shaping"
        case .reflection: "Reflection"
        case .utility: "Utility"
        }
    }

    var systemImage: String {
        switch self {
        case .execution: "bolt.fill"
        case .direction: "target"
        case .shaping: "calendar.badge.clock"
        case .reflection: "chart.line.uptrend.xyaxis"
        case .utility: "slider.horizontal.3"
        }
    }
}

struct AppShellHeaderButton {
    let title: String
    let systemImage: String
    let accessibilityIdentifier: String
    let action: () -> Void
}

struct AppShellScaffold<Content: View>: View {
    let title: String
    let subtitle: String?
    let posture: AppShellHeaderPosture
    let backButtonAccessibilityIdentifier: String?
    let onBack: (() -> Void)?
    let trailingButtons: [AppShellHeaderButton]
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        posture: AppShellHeaderPosture,
        backButtonAccessibilityIdentifier: String? = nil,
        onBack: (() -> Void)? = nil,
        trailingButtons: [AppShellHeaderButton] = [],
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.posture = posture
        self.backButtonAccessibilityIdentifier = backButtonAccessibilityIdentifier
        self.onBack = onBack
        self.trailingButtons = trailingButtons
        self.content = content()
    }

    var body: some View {
        content
            .safeAreaInset(edge: .top, spacing: 0) {
                AppShellHeaderRail(
                    title: title,
                    subtitle: subtitle,
                    posture: posture,
                    backButtonAccessibilityIdentifier: backButtonAccessibilityIdentifier,
                    onBack: onBack,
                    trailingButtons: trailingButtons
                )
            }
            .toolbar(.hidden, for: .navigationBar)
    }
}

private struct AppShellHeaderRail: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String?
    let posture: AppShellHeaderPosture
    let backButtonAccessibilityIdentifier: String?
    let onBack: (() -> Void)?
    let trailingButtons: [AppShellHeaderButton]

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: theme.spacing.md) {
                HStack(alignment: .center, spacing: theme.spacing.sm) {
                    if let onBack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                                .foregroundStyle(theme.colors.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(theme.colors.surfaceOverlay)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(backButtonAccessibilityIdentifier ?? "shell.header.back-button")
                    }

                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                            .accessibilityIdentifier("shell.header.title")

                        HStack(spacing: theme.spacing.xs) {
                            TagPill(posture.title, icon: posture.systemImage, state: .default)
                            if let subtitle {
                                Text(subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .lineLimit(1)
                                    .accessibilityIdentifier("shell.header.subtitle")
                            }
                        }
                    }
                }

                Spacer(minLength: theme.spacing.sm)

                HStack(spacing: theme.spacing.xs) {
                    ForEach(Array(trailingButtons.enumerated()), id: \.offset) { entry in
                        let button = entry.element
                        Button(action: button.action) {
                            Label(button.title, systemImage: button.systemImage)
                                .labelStyle(.iconOnly)
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                        .accessibilityIdentifier(button.accessibilityIdentifier)
                        .accessibilityLabel(button.title)
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.top, theme.spacing.sm)
            .padding(.bottom, theme.spacing.sm)
            .background(theme.colors.canvasElevated.opacity(0.96))

            Rectangle()
                .fill(theme.colors.strokeSubtle)
                .frame(height: 1)
        }
        .background(theme.colors.canvasElevated.opacity(0.96))
    }
}

struct AppShellOverlayPlaceholderView: View {
    let route: ShellOverlayRoute
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            FeatureScaffoldView(
                eyebrow: "Shell",
                title: route.title,
                subtitle: route.subtitle
            ) {
                AppCard {
                    Text(route.message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle(route.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: onDismiss)
                        .accessibilityIdentifier("shell.overlay.dismiss-button")
                }
            }
        }
    }
}

struct AppShellPlaceholderRouteView: View {
    let title: String
    let subtitle: String
    let message: String

    var body: some View {
        FeatureScaffoldView(eyebrow: "Owned route", title: title, subtitle: subtitle) {
            AppCard {
                Text(message)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityIdentifier("shell.placeholder.\(title.lowercased().replacingOccurrences(of: " ", with: "-"))")
    }
}

private extension ShellOverlayRoute {
    var title: String {
        switch self {
        case .quietCommandSheet: "Command"
        case .memoryLens: "Memory Lens"
        case .globalCreateEntry: "Create"
        }
    }

    var subtitle: String {
        switch self {
        case .quietCommandSheet:
            return "Batch 40 owns command entry as a shell overlay, without shipping the full Batch 42 interaction model."
        case .memoryLens:
            return "Batch 40 reserves Memory Lens as a shell overlay without activating its later-core recall system."
        case .globalCreateEntry:
            return "Batch 40 establishes shell-owned creation entry without shipping the full compose system."
        }
    }

    var message: String {
        switch self {
        case .quietCommandSheet:
            return "This placeholder proves shell ownership, presentation routing, and external-entry compatibility. Real command categorization, search, and action depth stay deferred to Batch 42."
        case .memoryLens:
            return "This placeholder keeps Memory Lens out of the tab model while preserving the shell-owned overlay seam needed for later coherence work."
        case .globalCreateEntry:
            return "This placeholder keeps create and capture entry owned by the shell without turning Batch 40 into a compose-system implementation batch."
        }
    }
}
