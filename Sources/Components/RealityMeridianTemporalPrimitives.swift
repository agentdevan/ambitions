#if canImport(SwiftUI)
import SwiftUI

public struct RealityMeridianCurrentTimeCursor: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: String
    private let date: Date?
    private let showsPulse: Bool

    public init(
        title: String = "Now",
        date: Date? = nil,
        showsPulse: Bool = true
    ) {
        self.title = title
        self.date = date
        self.showsPulse = showsPulse
    }

    public var body: some View {
        if let date {
            cursor(for: date)
        } else {
            TimelineView(.periodic(from: .now, by: 60)) { context in
                cursor(for: context.date)
            }
        }
    }

    private func cursor(for date: Date) -> some View {
        HStack(alignment: .center, spacing: theme.spacing.xs) {
            ZStack {
                Circle()
                    .fill(theme.colors.accentWarm.opacity(0.20))
                    .frame(width: showsPulse && reduceMotion == false ? 28 : 22, height: showsPulse && reduceMotion == false ? 28 : 22)
                    .blur(radius: showsPulse && reduceMotion == false ? 2 : 0)
                    .accessibilityHidden(true)

                Circle()
                    .fill(theme.colors.accentWarm)
                    .frame(width: 9, height: 9)
                    .shadow(color: theme.colors.accentWarm.opacity(0.36), radius: 8)
                    .accessibilityHidden(true)
            }
            .frame(width: 30, height: 30)

            Rectangle()
                .fill(theme.colors.accentWarm.opacity(0.58))
                .frame(height: 1)
                .accessibilityHidden(true)

            VStack(alignment: .trailing, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                Text(timeLabel(for: date))
                    .font(theme.typography.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(theme.colors.textPrimary)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Current time")
        .accessibilityValue(timeLabel(for: date))
        .accessibilityIdentifier("reality-meridian-current-time-cursor")
    }

    private func timeLabel(for date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}

public struct RealityMeridianScheduledNode: View {
    @Environment(\.ambitionTheme) private var theme

    private let timeLabel: String
    private let title: String
    private let isActive: Bool

    public init(timeLabel: String, title: String, isActive: Bool = false) {
        self.timeLabel = timeLabel
        self.title = title
        self.isActive = isActive
    }

    public var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.xs) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(theme.colors.strokeSubtle)
                    .frame(width: 1, height: 8)
                    .accessibilityHidden(true)
                Circle()
                    .fill(isActive ? theme.colors.accentWarm : theme.colors.surfaceOverlay)
                    .overlay(Circle().stroke(theme.colors.accentWarm.opacity(isActive ? 0.84 : 0.48), lineWidth: 1.4))
                    .frame(width: isActive ? 14 : 11, height: isActive ? 14 : 11)
                    .accessibilityHidden(true)
                Rectangle()
                    .fill(theme.colors.strokeSubtle)
                    .frame(width: 1, height: 8)
                    .accessibilityHidden(true)
            }
            .frame(width: 30)

            Text(timeLabel)
                .font(theme.typography.micro.monospacedDigit())
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: 56, alignment: .leading)

            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: theme.spacing.xs)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Scheduled node")
        .accessibilityValue("\(timeLabel). \(title)")
        .accessibilityIdentifier("reality-meridian-scheduled-node")
    }
}
#endif
