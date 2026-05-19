#if canImport(SwiftUI)
import Foundation
import SwiftUI

public struct RealityMeridianTemporalWindow: Equatable, Sendable {
    public let dayStartHour: Int
    public let dayEndHour: Int

    public init(dayStartHour: Int = 6, dayEndHour: Int = 22) {
        let clampedStart = min(23, max(0, dayStartHour))
        let clampedEnd = min(24, max(clampedStart + 1, dayEndHour))
        self.dayStartHour = clampedStart
        self.dayEndHour = clampedEnd
    }

    public var startMinutes: Int { dayStartHour * 60 }
    public var endMinutes: Int { dayEndHour * 60 }
    public var durationMinutes: Int { max(1, endMinutes - startMinutes) }

    public func progress(hour: Int, minute: Int) -> Double {
        let clampedHour = min(23, max(0, hour))
        let clampedMinute = min(59, max(0, minute))
        let currentMinutes = clampedHour * 60 + clampedMinute
        let raw = Double(currentMinutes - startMinutes) / Double(durationMinutes)
        return min(1, max(0, raw))
    }

    public func progress(for date: Date, calendar: Calendar = .current) -> Double {
        progress(
            hour: calendar.component(.hour, from: date),
            minute: calendar.component(.minute, from: date)
        )
    }
}

public enum RealityMeridianCurrentTimeCursorPresentation: String, Sendable {
    case standalone
    case railOverlay

    var minimumHeight: CGFloat {
        switch self {
        case .standalone: 168
        case .railOverlay: 128
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .standalone: 0
        case .railOverlay: 0
        }
    }

    var surfaceOpacity: Double {
        switch self {
        case .standalone: 1.0
        case .railOverlay: 0.18
        }
    }

    var strokeOpacity: Double {
        switch self {
        case .standalone: 1.0
        case .railOverlay: 0.32
        }
    }

    var spineOpacity: Double {
        switch self {
        case .standalone: 0.74
        case .railOverlay: 0.42
        }
    }
}

public struct RealityMeridianCurrentTimeCursor: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: String
    private let date: Date?
    private let showsPulse: Bool
    private let temporalWindow: RealityMeridianTemporalWindow
    private let presentation: RealityMeridianCurrentTimeCursorPresentation

    public init(
        title: String = "Current time",
        date: Date? = nil,
        showsPulse: Bool = true,
        dayStartHour: Int = 6,
        dayEndHour: Int = 22,
        presentation: RealityMeridianCurrentTimeCursorPresentation = .standalone
    ) {
        self.title = title
        self.date = date
        self.showsPulse = showsPulse
        self.temporalWindow = RealityMeridianTemporalWindow(dayStartHour: dayStartHour, dayEndHour: dayEndHour)
        self.presentation = presentation
    }

    public var body: some View {
        if let date {
            proportionalSpine(for: date)
        } else {
            TimelineView(.periodic(from: .now, by: 60)) { context in
                proportionalSpine(for: context.date)
            }
        }
    }

    private func proportionalSpine(for date: Date) -> some View {
        GeometryReader { proxy in
            let availableHeight = max(proxy.size.height, presentation.minimumHeight)
            let cursorY = cursorOffset(for: date, height: availableHeight)

            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading) {
                    Text(hourLabel(temporalWindow.dayStartHour))
                        .font(theme.typography.micro.monospacedDigit())
                        .foregroundStyle(theme.colors.textTertiary)
                    Spacer(minLength: 0)
                    Text(hourLabel(temporalWindow.dayEndHour))
                        .font(theme.typography.micro.monospacedDigit())
                        .foregroundStyle(theme.colors.textTertiary)
                }
                .frame(width: 54, height: availableHeight, alignment: .leading)

                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(presentation.spineOpacity))
                    .frame(width: 1, height: availableHeight)
                    .padding(.leading, 70)
                    .accessibilityHidden(true)

                HStack(spacing: theme.spacing.xs) {
                    Text(timeLabel(for: date))
                        .font(theme.typography.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(theme.colors.textPrimary)
                        .frame(width: 62, alignment: .trailing)

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

                    Text(title)
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
                .offset(y: max(CGFloat(0), min(availableHeight - CGFloat(30), cursorY - CGFloat(15))))
            }
            .frame(width: proxy.size.width, height: availableHeight, alignment: .topLeading)
        }
        .frame(minHeight: presentation.minimumHeight)
        .padding(.horizontal, theme.spacing.sm + presentation.horizontalPadding)
        .padding(.vertical, theme.spacing.xs)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.shell.controlBackground.opacity(presentation.surfaceOpacity)))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.shell.divider.opacity(presentation.strokeOpacity), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Current time on Reality Meridian")
        .accessibilityValue("\(timeLabel(for: date)). Window \(hourLabel(temporalWindow.dayStartHour)) to \(hourLabel(temporalWindow.dayEndHour)).")
        .accessibilityIdentifier("reality-meridian-current-time-cursor")
    }

    private func cursorOffset(for date: Date, height: CGFloat) -> CGFloat {
        CGFloat(temporalWindow.progress(for: date)) * height
    }

    private func timeLabel(for date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    private func hourLabel(_ hour: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        let date = Calendar.current.date(from: components) ?? Date(timeIntervalSince1970: TimeInterval(hour * 3_600))
        return date.formatted(date: .omitted, time: .shortened)
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

public extension RealityMeridianTemporalWindow {
    public var fe04Role: FE04PrimitiveRole {
        .lifeShape
    }
}

public extension RealityMeridianCurrentTimeCursor {
    public var fe04Role: FE04PrimitiveRole {
        .currentTimeGlow
    }
}

public extension RealityMeridianScheduledNode {
    public var fe04Role: FE04PrimitiveRole {
        .meridianNode
    }
}
#endif
