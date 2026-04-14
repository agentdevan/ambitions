#if canImport(SwiftUI)
import AmbitionsDesignSystem
import SwiftUI

struct WidgetTitleBlock: View {
    let eyebrow: String?
    let title: String
    let subtitle: String?
    let badge: String?
    let badgeState: AmbitionVisualState

    init(
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil,
        badge: String? = nil,
        badgeState: AmbitionVisualState = .default
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.badgeState = badgeState
    }

    var body: some View {
        SectionHeader(eyebrow: eyebrow, title: title, subtitle: subtitle) {
            if let badge {
                TagPill(badge, state: badgeState)
            }
        }
    }
}

struct WidgetActionBar: View {
    @Environment(\.ambitionTheme) private var theme

    let identity: WidgetIdentity
    let actions: [WidgetInlineActionDescriptor]
    let handler: WidgetActionHandler?

    var body: some View {
        if actions.isEmpty == false {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: theme.spacing.xs)], spacing: theme.spacing.xs) {
                ForEach(actions) { action in
                    Button {
                        handler?(WidgetAction(identity: identity, kind: action.kind))
                    } label: {
                        Label(action.title, systemImage: action.icon)
                            .font(theme.typography.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, theme.spacing.xs)
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: action.state))
                }
            }
        }
    }
}

struct WidgetMetricGrid: View {
    let stats: [WidgetStat]

    var body: some View {
        let columns = [
            GridItem(.flexible(minimum: 140), spacing: 16),
            GridItem(.flexible(minimum: 140), spacing: 16)
        ]

        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(stats) { stat in
                StatTile(
                    title: stat.title,
                    value: stat.value,
                    detail: stat.detail,
                    icon: stat.icon,
                    state: stat.state
                )
            }
        }
    }
}

struct WidgetProgressList: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [WidgetProgressItem]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack(spacing: theme.spacing.xs) {
                        Text(item.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)

                        if let statusLabel = item.statusLabel {
                            TagPill(statusLabel, state: item.state)
                        }
                    }

                    if let detail = item.detail {
                        Text(detail)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }

                    ProgressRail(
                        title: item.title,
                        progress: item.progress,
                        trailingValue: item.trailingValue,
                        state: item.state
                    )
                }
            }
        }
    }
}

struct WidgetFallbackStateView: View {
    let title: String
    let message: String
    let icon: String
    let actionTitle: String?
    let action: (() -> Void)?

    var body: some View {
        EmptyStateCard(
            title: title,
            message: message,
            icon: icon,
            actionTitle: actionTitle,
            action: action
        )
    }
}

struct WidgetLoadingStateView: View {
    let lineCount: Int

    init(lineCount: Int = 4) {
        self.lineCount = lineCount
    }

    var body: some View {
        LoadingSkeletonCard(lineCount: lineCount)
    }
}

struct WidgetBarChart: View {
    @Environment(\.ambitionTheme) private var theme

    let points: [WidgetTrendPoint]

    var body: some View {
        HStack(alignment: .bottom, spacing: theme.spacing.xs) {
            ForEach(points) { point in
                VStack(spacing: theme.spacing.xxs) {
                    RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [theme.colors.accentWarm.opacity(0.95), theme.colors.accentPrimary.opacity(0.75)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: max(24, point.value * 110))

                    Text(point.label)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .bottom)
    }
}

struct WidgetListRow: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String?
    let icon: String
    let badge: String?
    let tap: (() -> Void)?

    var body: some View {
        Group {
            if let tap {
                ListChevronRow(
                    title: title,
                    subtitle: subtitle,
                    leading: {
                        Image(systemName: icon)
                            .foregroundStyle(theme.colors.accentWarm)
                    },
                    trailing: {
                        if let badge {
                            TagPill(badge)
                        }
                    },
                    action: tap
                )
            } else {
                HStack(spacing: theme.spacing.md) {
                    Image(systemName: icon)
                        .foregroundStyle(theme.colors.accentWarm)

                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)

                        if let subtitle {
                            Text(subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }

                    Spacer()

                    if let badge {
                        TagPill(badge)
                    }
                }
                .padding(theme.spacing.md)
                .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
            }
        }
    }
}
#endif
