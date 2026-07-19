#if canImport(SwiftUI)
import SwiftUI

/// Shared section heading used above grouped modules.
public struct SectionHeader<Trailing: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let eyebrow: String?
    private let title: String
    private let subtitle: String?
    private let trailing: Trailing

    public init(
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                }

                Text(title)
                    .font(theme.typography.titleCompact)
                    .foregroundStyle(theme.colors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            Spacer(minLength: theme.spacing.sm)
            trailing
        }
    }
}

/// Compact, reusable pill for labels, filters, and lightweight status.
public struct TagPill: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let icon: String?
    private let state: AmbitionVisualState
    private let accent: Color?

    public init(
        _ title: String,
        icon: String? = nil,
        state: AmbitionVisualState = .default,
        accent: Color? = nil
    ) {
        self.title = title
        self.icon = icon
        self.state = state
        self.accent = accent
    }

    public var body: some View {
        let style = theme.stateStyle(for: state, accent: accent)

        HStack(spacing: theme.spacing.xxs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
            }

            Text(title)
                .font(theme.typography.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .accessibilityElement(children: .combine)
        .foregroundStyle(style.foreground)
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, theme.spacing.xxs)
        .background(Capsule(style: .continuous).fill(style.fill))
        .overlay(Capsule(style: .continuous).stroke(style.stroke, lineWidth: 1))
        .overlay {
            if state == .celebration || state == .selected {
                Capsule(style: .continuous)
                    .stroke(style.glow.opacity(theme.glow.ringOpacity), lineWidth: 1)
                    .blur(radius: 0.3)
            }
        }
        .opacity(style.opacity)
    }
}

/// Key metric tile for progress and health summaries.
public struct StatTile: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: String
    private let value: String
    private let detail: String?
    private let icon: String
    private let state: AmbitionVisualState
    private let accent: Color?

    public init(
        title: String,
        value: String,
        detail: String? = nil,
        icon: String,
        state: AmbitionVisualState = .default,
        accent: Color? = nil
    ) {
        self.title = title
        self.value = value
        self.detail = detail
        self.icon = icon
        self.state = state
        self.accent = accent
    }

    public var body: some View {
        let style = theme.stateStyle(for: state, accent: accent)

        WidgetCard(state: state, accent: accent) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(style.accent)
                    Spacer()
                    TagPill(labelText, state: state, accent: accent)
                }

                Text(value)
                    .font(theme.typography.numeric)
                    .foregroundStyle(theme.colors.textPrimary)
                    .minimumScaleFactor(0.7)
                    .contentTransition(reduceMotion ? .identity : .numericText())

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)

                    if let detail {
                        Text(detail)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)\(detail.map { ", \($0)" } ?? "")")
    }

    private var labelText: String {
        switch state {
        case .success: "Stable"
        case .warning: "Watch"
        case .celebration: "Lift"
        case .selected: "Focus"
        case .loading: "Loading"
        case .disabled: "Muted"
        case .pressed: "Active"
        case .default: "Live"
        }
    }
}

/// Horizontal rail for single-progress measures and confidence signals.
public struct ProgressRail: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: String
    private let progress: Double
    private let trailingValue: String?
    private let state: AmbitionVisualState
    private let accent: Color?

    public init(
        title: String,
        progress: Double,
        trailingValue: String? = nil,
        state: AmbitionVisualState = .default,
        accent: Color? = nil
    ) {
        self.title = title
        self.progress = progress
        self.trailingValue = trailingValue
        self.state = state
        self.accent = accent
    }

    public var body: some View {
        let clamped = min(max(progress, 0), 1)
        let style = theme.stateStyle(for: state, accent: accent)

        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)

                Spacer()

                if let trailingValue {
                    Text(trailingValue)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textPrimary)
                }
            }

            GeometryReader { proxy in
                let width = proxy.size.width
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(theme.colors.surfaceOverlay)

                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [style.accent, style.accent.opacity(0.55)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(width * clamped, 10))
                        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: clamped)
                }
            }
            .frame(height: 10)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(Int(clamped * 100)) percent\(trailingValue.map { ", \($0)" } ?? "")")
    }
}

/// Shell around future compact charts to keep chart chrome consistent.
public struct CompactChartShell<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String?
    private let content: Content

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    public var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: title, subtitle: subtitle)
                content
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                    .padding(theme.spacing.sm)
                    .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                    .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
            }
        }
    }
}

/// Stable empty-state treatment for data-sparse surfaces.
public struct EmptyStateCard: View {
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
        icon: String,
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
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: theme.icon.largeSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentWarm)
                    .padding(theme.icon.containerPadding)
                    .background(Circle().fill(theme.colors.surfaceOverlay))

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
                        .buttonStyle(AmbitionButtonStyle(tier: .tertiary, state: .selected))
                        .accessibilityIdentifier(actionAccessibilityIdentifier ?? "")
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

/// Neutral skeleton card for loading states without business-specific placeholders.
public struct LoadingSkeletonCard: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let lineCount: Int

    public init(lineCount: Int = 3) {
        self.lineCount = max(lineCount, 1)
    }

    public var body: some View {
        AppCard(state: .loading) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                skeletonLine(width: 0.44, height: 22)

                ForEach(0..<lineCount, id: \.self) { index in
                    skeletonLine(width: index == lineCount - 1 ? 0.58 : 1, height: 12)
                }
            }
            .redacted(reason: .placeholder)
            .shimmering(active: reduceMotion == false, base: theme.colors.skeletonBase, highlight: theme.colors.skeletonHighlight)
        }
    }

    private func skeletonLine(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
            .fill(theme.colors.skeletonBase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: height)
            .frame(width: width == 1 ? nil : 260 * width, alignment: .leading)
    }
}

private struct AmbitionShimmerModifier: ViewModifier {
    let active: Bool
    let base: Color
    let highlight: Color

    @State private var offset: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    LinearGradient(
                        colors: [base.opacity(0), highlight, base.opacity(0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .rotationEffect(.degrees(9))
                    .offset(x: offset * proxy.size.width * 1.8)
                    .blendMode(.plusLighter)
                    .mask(content)
                    .onAppear {
                        guard active else { return }
                        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                            offset = 1.2
                        }
                    }
                }
            }
    }
}

private extension View {
    func shimmering(active: Bool, base: Color, highlight: Color) -> some View {
        modifier(AmbitionShimmerModifier(active: active, base: base, highlight: highlight))
    }
}
#endif
