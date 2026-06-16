#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionCardStyle: Sendable {
    case app
    case widget
    case hero
    case band
}

public struct AmbitionSurfaceModifier: ViewModifier {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let style: AmbitionCardStyle
    private let state: AmbitionVisualState
    private let accent: Color?

    public init(style: AmbitionCardStyle, state: AmbitionVisualState = .default, accent: Color? = nil) {
        self.style = style
        self.state = state
        self.accent = accent
    }

    public func body(content: Content) -> some View {
        let resolved = theme.stateStyle(for: state, accent: accent)
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Group {
            switch style {
            case .app, .widget, .hero:
                QuietGlass(cornerRadius: cornerRadius) {
                    content
                        .padding(contentPadding)
                }
                .luminousTrace(isShimmering: state == .selected || state == .celebration, accentColor: accent)
            case .band:
                GraphiteRecess(cornerRadius: cornerRadius) {
                    content
                        .padding(contentPadding)
                }
            }
        }
        .shadow(color: shadow.color.opacity(state == .selected ? 1.05 : 1), radius: shadow.radius, x: shadow.x, y: shadow.y)
        .overlay {
            if (state == .selected || state == .celebration) && style != .band {
                shape
                    .fill(resolved.glow.opacity(theme.glow.opacity))
                    .blur(radius: theme.glow.radius)
                    .allowsHitTesting(false)
            }
        }
        .scaleEffect(resolved.scale)
        .opacity(resolved.opacity)
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: style == .hero), value: state)
    }

    private var cornerRadius: CGFloat {
        switch style {
        case .app: theme.radius.lg
        case .widget: theme.radius.md
        case .hero: theme.radius.xl
        case .band: theme.radius.band
        }
    }

    private var contentPadding: CGFloat {
        switch style {
        case .app: theme.spacing.lg
        case .widget: theme.spacing.sm
        case .hero: theme.spacing.xl
        case .band: theme.spacing.md
        }
    }

    private var shadow: AmbitionTheme.Shadow {
        switch style {
        case .app: theme.elevation.resting
        case .widget: theme.elevation.resting
        case .hero: theme.elevation.hero
        case .band: theme.depth.raised
        }
    }

    private var background: LinearGradient {
        switch style {
        case .app:
            theme.surfaces.elevatedGradient
        case .widget:
            theme.surfaces.widgetGradient
        case .hero:
            theme.surfaces.heroGradient
        case .band:
            theme.surfaces.bandGradient
        }
    }
}

public extension View {
    /// Applies shared Ambitions card chrome to arbitrary content.
    func ambitionSurface(
        _ style: AmbitionCardStyle,
        state: AmbitionVisualState = .default,
        accent: Color? = nil
    ) -> some View {
        modifier(AmbitionSurfaceModifier(style: style, state: state, accent: accent))
    }

    func ambitionPanelAccessibility() -> some View {
        accessibilityElement(children: .contain)
    }

    func ambitionPanelAccessibility(
        label: String,
        value: String? = nil,
        hint: String? = nil
    ) -> some View {
        accessibilityElement(children: .contain)
            .accessibilityLabel(label)
            .accessibilityValue(value ?? "")
            .accessibilityHint(hint ?? "")
    }

    func ambitionMinimumTapTarget(_ size: CGFloat = 44) -> some View {
        frame(minWidth: size, minHeight: size)
            .contentShape(Rectangle())
    }
}

/// General-purpose content container for primary in-app modules.
///
/// Release recovery note: top-level first viewports should prefer `ObjectStage`
/// or a surface-specific signature primitive. `AppCard` remains appropriate for
/// secondary modules, settings detail, and contained inspection surfaces.
public struct AppCard<Content: View>: View {
    private let state: AmbitionVisualState
    private let accent: Color?
    private let content: Content

    public init(
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accent = accent
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .ambitionSurface(.app, state: state, accent: accent)
    }
}

/// Smaller container for glanceable modules or future widget-style sections.
public struct WidgetCard<Content: View>: View {
    private let state: AmbitionVisualState
    private let accent: Color?
    private let content: Content

    public init(
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accent = accent
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .ambitionSurface(.widget, state: state, accent: accent)
    }
}

/// High-emphasis surface for top-level moments such as weekly summaries.
public struct HeroCard<Content: View>: View {
    private let state: AmbitionVisualState
    private let accent: Color?
    private let content: Content

    public init(
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accent = accent
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .ambitionSurface(.hero, state: state, accent: accent)
    }
}

/// Lighter structural band used for carried context, not heavy module chrome.
public struct ContextBand<Content: View>: View {
    private let state: AmbitionVisualState
    private let accent: Color?
    private let content: Content

    public init(
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accent = accent
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .ambitionSurface(.band, state: state, accent: accent)
    }
}

/// Full-bleed signature-object composition for a top-level Ambitions surface.
///
/// `ObjectStage` intentionally avoids the default rounded-card shell. It gives
/// Today, Goals, Time, Motion, Capture, and You a shared native structure while
/// allowing each surface to render its own product object.
public struct ObjectStage<Header: View, Content: View>: View {
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

/// Native grouped setting surface for You and other configuration details.
public struct NativeSettingsGroup<Content: View>: View {
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

/// Compact disclosure for inspection-only source/proof/privacy detail.
public struct InspectionDisclosure<Content: View>: View {
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
        .accessibilityIdentifier("inspection.disclosure")
    }
}

/// Compact primary-step token used by Today and any surface that needs to open a
/// concrete recommended step without rendering another generic card.
public struct StepToken: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let detail: String
    private let actionTitle: String
    private let action: () -> Void

    public init(
        title: String,
        detail: String,
        actionTitle: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.detail = detail
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
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
        }
        .buttonStyle(.plain)
        .ambitionMinimumTapTarget()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(actionTitle)
    }
}
#endif
