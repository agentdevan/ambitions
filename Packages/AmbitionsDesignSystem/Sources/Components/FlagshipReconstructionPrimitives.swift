
#if canImport(SwiftUI)
import SwiftUI

public struct FullBleedFocusedSurface<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    private let title: String
    private let subtitle: String?
    private let content: Content

    public init(_ title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.title)
                    .foregroundStyle(theme.colors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.bodySecondary)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.lg)
        .background(theme.colors.canvas)
        .accessibilityElement(children: .contain)
    }
}

public struct NativeModePill: View {
    @Environment(\.ambitionTheme) private var theme
    private let title: String
    private let isSelected: Bool

    public init(_ title: String, isSelected: Bool = false) {
        self.title = title
        self.isSelected = isSelected
    }

    public var body: some View {
        Text(title)
            .font(theme.typography.micro.weight(.semibold))
            .foregroundStyle(isSelected ? theme.colors.canvas : theme.colors.textSecondary)
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, theme.spacing.xxs)
            .background(Capsule(style: .continuous).fill(isSelected ? theme.colors.accentWarm : theme.colors.surfaceOverlay))
            .overlay(Capsule(style: .continuous).stroke(theme.colors.strokeSubtle.opacity(isSelected ? 0.0 : 0.72), lineWidth: 1))
    }
}

public struct QuietEmptyStateLine: View {
    @Environment(\.ambitionTheme) private var theme
    private let title: String
    private let message: String
    private let systemImage: String

    public init(_ title: String, message: String, systemImage: String = "sparkle.magnifyingglass") {
        self.title = title
        self.message = message
        self.systemImage = systemImage
    }

    public var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: theme.icon.mediumSize, weight: .semibold))
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(message)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, theme.spacing.xs)
        .accessibilityElement(children: .combine)
    }
}

public struct ThreadedStepRow: View {
    @Environment(\.ambitionTheme) private var theme
    private let title: String
    private let detail: String
    private let systemImage: String

    public init(_ title: String, detail: String, systemImage: String = "circle.dotted") {
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
    }

    public var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: systemImage)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.accentPrimary)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(detail)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
#endif
