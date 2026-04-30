#if canImport(SwiftUI)
import SwiftUI

public struct CompactContextHeader: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentWarm)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(theme.colors.surfaceOverlay))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }

            Spacer(minLength: theme.spacing.sm)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(theme.typography.caption)
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                    .accessibilityIdentifier("compact-context-header.action")
            }
        }
        .accessibilityElement(children: .combine)
    }
}

public struct HeroStepPanel<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let eyebrow: String
    private let title: String
    private let subtitle: String
    private let semanticState: AmbitionSemanticState
    private let primaryActionTitle: String?
    private let primaryAction: (() -> Void)?
    private let content: Content

    public init(
        eyebrow: String = "Start here",
        title: String,
        subtitle: String,
        semanticState: AmbitionSemanticState = .focus,
        primaryActionTitle: String? = nil,
        primaryAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.semanticState = semanticState
        self.primaryActionTitle = primaryActionTitle
        self.primaryAction = primaryAction
        self.content = content()
    }

    public var body: some View {
        HeroDecisionPanel(
            AmbitionRichPanelConfiguration(
                kind: .heroDecision,
                eyebrow: eyebrow,
                title: title,
                subtitle: subtitle,
                icon: "scope",
                semanticState: semanticState,
                confidenceLabel: nil,
                accessibilityLabel: "\(eyebrow). \(title)",
                accessibilityHint: "Shows the recommended step and why it fits now.",
                accessibilityValue: subtitle
            )
        ) {
            EmptyView()
        } contentSlot: {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                content
                if let primaryActionTitle, let primaryAction {
                    Button(primaryActionTitle, action: primaryAction)
                        .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                        .accessibilityIdentifier("hero-step-panel.primary-action")
                }
            }
        }
    }
}

public struct TimeContextBadge: View {
    private let title: String
    private let sourceLabel: String?
    private let state: AmbitionVisualState

    public init(_ title: String, sourceLabel: String? = nil, state: AmbitionVisualState = .default) {
        self.title = title
        self.sourceLabel = sourceLabel
        self.state = state
    }

    public var body: some View {
        TagPill(sourceLabel.map { "\(title) · \($0)" } ?? title, icon: "clock", state: state)
            .accessibilityIdentifier("time-context-badge")
    }
}

public typealias ContextLensChip = TimeContextBadge
public typealias EvidenceSourceChip = TimeContextBadge
public typealias ScheduleSourceLabel = TimeContextBadge

public struct DurationBadge: View {
    private let label: String

    public init(_ label: String) {
        self.label = label
    }

    public var body: some View {
        TagPill(label, icon: "timer", state: .default)
            .accessibilityIdentifier("duration-badge")
    }
}

public typealias DurationSourceLabel = DurationBadge

public typealias RigidityChip = StatusChip
public typealias ReadinessChip = StatusChip
public typealias ContextRequirementChip = StatusChip

public struct ReceiptTrail<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String?
    private let content: Content

    public init(
        title: String = "Receipt Trail",
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    public var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(eyebrow: "Receipts", title: title, subtitle: subtitle)
                content
            }
        }
        .accessibilityIdentifier("receipt-trail")
    }
}

public struct ClosureCheckInPanel<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String
    private let content: Content

    public init(
        title: String = "Needs a quick check",
        subtitle: String,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    public var body: some View {
        AppCard(state: .warning) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(eyebrow: "Close the loop", title: title, subtitle: subtitle)
                content
            }
        }
        .accessibilityIdentifier("closure-check-in-panel")
    }
}
#endif
