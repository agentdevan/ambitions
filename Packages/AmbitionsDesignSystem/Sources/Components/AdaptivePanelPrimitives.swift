#if canImport(SwiftUI)
import SwiftUI

public enum PanelEmphasis: String, CaseIterable, Sendable, Identifiable {
    case orientation
    case action
    case receipt
    case proof
    case source
    case recovery
    case setup
    case pressure
    case quiet

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .orientation: "Orientation"
        case .action: "Action"
        case .receipt: "Receipt"
        case .proof: "Proof"
        case .source: "Source"
        case .recovery: "Recovery"
        case .setup: "Setup"
        case .pressure: "Pressure"
        case .quiet: "Quiet"
        }
    }

    public var icon: String {
        switch self {
        case .orientation: "scope"
        case .action: "arrow.right.circle.fill"
        case .receipt: "doc.text.fill"
        case .proof: "checkmark.seal.fill"
        case .source: "link.badge.plus"
        case .recovery: "arrow.uturn.backward.circle.fill"
        case .setup: "slider.horizontal.3"
        case .pressure: "gauge.with.dots.needle.50percent"
        case .quiet: "moon"
        }
    }

    public var semanticState: AmbitionSemanticState {
        switch self {
        case .orientation: .focus
        case .action: .confidenceMedium
        case .receipt: .review
        case .proof: .confidenceHigh
        case .source: .trust
        case .recovery: .recovery
        case .setup: .protected
        case .pressure: .caution
        case .quiet: .neutral
        }
    }

    public var accessibilityText: String {
        "\(title), \(semanticState.accessibilityText)"
    }
}

public enum AmbitionsActionRole: String, CaseIterable, Sendable, Identifiable {
    case primary
    case secondary
    case quiet
    case recovery
    case destructive

    public var id: String { rawValue }

    public var tier: AmbitionButtonTier {
        switch self {
        case .primary: .primary
        case .secondary: .secondary
        case .quiet: .tertiary
        case .recovery: .recovery
        case .destructive: .destructive
        }
    }

    public var defaultIcon: String {
        switch self {
        case .primary: "arrow.right.circle.fill"
        case .secondary: "arrow.right.circle"
        case .quiet: "ellipsis.circle"
        case .recovery: "arrow.uturn.backward.circle"
        case .destructive: "exclamationmark.triangle"
        }
    }
}

public struct AdaptivePanelConfiguration: Sendable {
    public let emphasis: PanelEmphasis
    public let title: String
    public let subtitle: String?
    public let status: String?
    public let isLoading: Bool
    public let isDisabled: Bool
    public let isPrivacySensitive: Bool
    public let accessibilityLabel: String?
    public let accessibilityHint: String?

    public init(
        emphasis: PanelEmphasis,
        title: String,
        subtitle: String? = nil,
        status: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        isPrivacySensitive: Bool = false,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil
    ) {
        self.emphasis = emphasis
        self.title = title
        self.subtitle = subtitle
        self.status = status
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.isPrivacySensitive = isPrivacySensitive
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
    }

    public var state: AmbitionVisualState {
        if isDisabled { return .disabled }
        if isLoading { return .loading }
        switch emphasis {
        case .proof: return .success
        case .pressure: return .warning
        case .action, .orientation, .receipt, .source, .recovery, .setup:
            return .selected
        case .quiet: return .default
        }
    }

    public var defaultAccessibilityLabel: String {
        [
            emphasis.title,
            title,
            status,
            isPrivacySensitive ? "private" : nil,
            isLoading ? "loading" : nil,
            isDisabled ? "disabled" : nil
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }
}

public struct AdaptivePanel<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let configuration: AdaptivePanelConfiguration
    private let content: Content

    public init(
        _ configuration: AdaptivePanelConfiguration,
        @ViewBuilder content: () -> Content
    ) {
        self.configuration = configuration
        self.content = content()
    }

    public var body: some View {
        let semanticStyle = theme.semanticStyle(for: configuration.emphasis.semanticState)

        VStack(alignment: .leading, spacing: panelSpacing) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: configuration.emphasis.icon)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(semanticStyle.accent)
                    .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
                    .background(Circle().fill(semanticStyle.fill))
                    .overlay(Circle().stroke(semanticStyle.stroke, lineWidth: 1))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    HStack(spacing: theme.spacing.xs) {
                        Text(configuration.emphasis.title.uppercased())
                            .font(theme.typography.micro)
                            .foregroundStyle(semanticStyle.accent)

                        if let status = configuration.status {
                            AmbitionChip(status, role: .state, semanticState: configuration.emphasis.semanticState)
                        }
                    }

                    Text(configuration.title)
                        .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.titleCompact : theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle = configuration.subtitle {
                        Text(subtitle)
                            .font(theme.typography.bodySecondary)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            if configuration.isLoading {
                LoadingSkeletonCard(lineCount: dynamicTypeSize.isAccessibilitySize ? 2 : 3)
            } else {
                content
            }
        }
        .ambitionSurface(.app, state: configuration.state, accent: semanticStyle.accent)
        .opacity(configuration.isDisabled ? 0.68 : 1)
        .transition(reduceMotion ? .opacity : .ambitionPanel)
        .ambitionPanelAccessibility(
            label: configuration.accessibilityLabel ?? configuration.defaultAccessibilityLabel,
            value: configuration.emphasis.accessibilityText,
            hint: configuration.accessibilityHint
        )
    }

    private var panelSpacing: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? theme.spacing.lg : theme.spacing.md
    }
}

public extension AdaptivePanel where Content == EmptyView {
    init(_ configuration: AdaptivePanelConfiguration) {
        self.init(configuration) { EmptyView() }
    }
}

public struct AmbitionsActionButton: View {
    private let title: String
    private let icon: String?
    private let role: AmbitionsActionRole
    private let state: AmbitionVisualState
    private let isLoading: Bool
    private let action: @MainActor () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        role: AmbitionsActionRole = .primary,
        state: AmbitionVisualState = .default,
        isLoading: Bool = false,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.role = role
        self.state = state
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Label {
                Text(isLoading ? "\(title)..." : title)
            } icon: {
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: icon ?? role.defaultIcon)
                }
            }
            .frame(maxWidth: role == .quiet ? nil : .infinity)
        }
        .buttonStyle(AmbitionButtonStyle(tier: role.tier, state: isLoading ? .loading : state))
        .disabled(isLoading)
        .ambitionMinimumTapTarget()
        .accessibilityLabel(title)
        .accessibilityValue(isLoading ? "Loading" : "")
    }
}

public struct QuietActionButton: View {
    private let title: String
    private let icon: String?
    private let action: @MainActor () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        AmbitionsActionButton(title, icon: icon, role: .quiet, action: action)
    }
}

public struct AmbitionsInAppModule<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String?
    private let emphasis: PanelEmphasis
    private let content: Content

    public init(
        title: String,
        subtitle: String? = nil,
        emphasis: PanelEmphasis = .orientation,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.emphasis = emphasis
        self.content = content()
    }

    public var body: some View {
        AdaptivePanel(
            .init(
                emphasis: emphasis,
                title: title,
                subtitle: subtitle,
                status: emphasis.title,
                accessibilityHint: "Reviews this Ambitions module."
            )
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                content
            }
        }
    }
}
#endif
