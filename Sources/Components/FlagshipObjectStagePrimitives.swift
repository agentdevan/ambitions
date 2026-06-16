#if canImport(SwiftUI)
import SwiftUI

/// Full-bleed signature-object composition for top-level Ambitions surfaces.
///
/// This is the release-recovery alternative to leading every surface with a card.
/// The owning screen supplies the product object: Reality Meridian, Constellation
/// Atlas, Atmosphere Composer, LifeShape Field, Motion Current, or User System Profile.
public struct FlagshipObjectStage<Header: View, Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let accessibilityIdentifier: String
    private let header: Header
    private let content: Content

    public init(
        accessibilityIdentifier: String,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.header = header()
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            header
            content
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.md)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

/// Native grouped settings composition for You detail surfaces.
///
/// Uses a quiet material grouping pattern instead of stacked policy cards.
public struct FlagshipSettingsGroup<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let footer: String?
    private let content: Content

    public init(
        _ title: String,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.6)
                .padding(.horizontal, theme.spacing.xs)

            VStack(spacing: 0) {
                content
            }
            .background(theme.colors.surfaceOverlay.opacity(0.38))
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))

            if let footer {
                Text(footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, theme.spacing.xs)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

/// Compact disclosure for source/proof/privacy detail after the primary object
/// has already made the user-facing state obvious.
public struct FlagshipInspectionDisclosure<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var isExpanded = false

    private let title: String
    private let summary: String?
    private let content: Content

    public init(
        title: String = "Why this",
        summary: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.summary = summary
        self.content = content()
    }

    public var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                content
            }
            .padding(.top, theme.spacing.sm)
        } label: {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                if let summary {
                    Text(summary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .font(theme.typography.caption)
        .foregroundStyle(theme.colors.textSecondary)
        .accessibilityIdentifier("flagship.inspection-disclosure")
    }
}

/// Display-only recommended-step token. Interactions are owned by the surface
/// rendering it so Today can keep action routing explicit and testable.
public struct FlagshipStepToken: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let detail: String
    private let actionTitle: String

    public init(title: String, detail: String, actionTitle: String) {
        self.title = title
        self.detail = detail
        self.actionTitle = actionTitle
    }

    public var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(title)
                    .font(theme.typography.section.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: theme.spacing.md)
            Text(actionTitle)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.accentWarm)
        }
        .padding(.vertical, theme.spacing.md)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.32))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.24))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(actionTitle)
    }
}
#endif
