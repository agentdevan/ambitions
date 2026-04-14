#if canImport(SwiftUI)
import SwiftUI

/// Warm success treatment for completion and momentum moments.
public struct CelebrationBanner: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String
    private let icon: String

    public init(title: String, subtitle: String, icon: String = "sparkles") {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

    public var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            Image(systemName: icon)
                .font(.system(size: theme.icon.largeSize, weight: .bold))
                .foregroundStyle(theme.colors.accentWarm)
                .padding(theme.icon.containerPadding)
                .background(Circle().fill(theme.colors.textInverse.opacity(0.10)))

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)

                Text(subtitle)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(theme.spacing.lg)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.surfaces.celebrationGradient))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.celebration.opacity(0.28), lineWidth: 1))
        .shadow(color: theme.colors.celebration.opacity(0.12), radius: theme.glow.radius, x: 0, y: 8)
    }
}

/// Profile/header block with avatar, context, and a primary trailing slot.
public struct AvatarHeader<Trailing: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String?
    private let image: Image?
    private let initials: String
    private let trailing: Trailing

    public init(
        title: String,
        subtitle: String? = nil,
        image: Image? = nil,
        initials: String,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.initials = initials
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: theme.spacing.md) {
            avatar

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.titleCompact)
                    .foregroundStyle(theme.colors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            Spacer()
            trailing
        }
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [theme.colors.accentWarm, theme.colors.accentPrimary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 54, height: 54)

            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
                    .clipShape(Circle())
            } else {
                Text(initials)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textInverse)
            }
        }
        .overlay(Circle().stroke(theme.colors.strokeStrong, lineWidth: 1))
    }
}
#endif
