#if canImport(SwiftUI)
import Foundation
import SwiftUI

public enum RealityMeridianTimeBandZoneKind: String, CaseIterable, Sendable {
    case startHere
    case now
    case next
    case later
}

public struct RealityMeridianTimeBandZone: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let weight: Double
    public let kind: RealityMeridianTimeBandZoneKind

    public init(id: String, title: String, subtitle: String, weight: Double, kind: RealityMeridianTimeBandZoneKind) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.weight = max(0.05, weight)
        self.kind = kind
    }

    public static let canonicalToday: [RealityMeridianTimeBandZone] = [
        RealityMeridianTimeBandZone(id: "start-here", title: "Start here", subtitle: "Recommended", weight: 0.31, kind: .startHere),
        RealityMeridianTimeBandZone(id: "now", title: "Now", subtitle: "Active", weight: 0.23, kind: .now),
        RealityMeridianTimeBandZone(id: "next", title: "Next", subtitle: "Queued", weight: 0.23, kind: .next),
        RealityMeridianTimeBandZone(id: "later", title: "Later", subtitle: "Held", weight: 0.23, kind: .later)
    ]
}

public struct RealityMeridianTimeBand: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let date: Date?
    private let temporalWindow: RealityMeridianTemporalWindow
    private let zones: [RealityMeridianTimeBandZone]
    private let startDetail: String
    private let endDetail: String

    public init(
        date: Date? = nil,
        dayStartHour: Int = 6,
        dayEndHour: Int = 21,
        zones: [RealityMeridianTimeBandZone] = RealityMeridianTimeBandZone.canonicalToday,
        startDetail: String = "6:03 AM",
        endDetail: String = "8:32 PM"
    ) {
        self.date = date
        self.temporalWindow = RealityMeridianTemporalWindow(dayStartHour: dayStartHour, dayEndHour: dayEndHour)
        self.zones = zones
        self.startDetail = startDetail
        self.endDetail = endDetail
    }

    public var body: some View {
        if let date {
            band(for: date)
        } else {
            TimelineView(.periodic(from: .now, by: 60)) { context in
                band(for: context.date)
            }
        }
    }

    private func band(for date: Date) -> some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, CGFloat(1))
            let cursorX = CGFloat(temporalWindow.progress(for: date)) * width

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                timeScale

                ZStack(alignment: .leading) {
                    zoneBand(width: width)
                    tickField
                    currentCursor(date: date, x: cursorX, width: width)
                }
                .frame(height: bandHeight)

                HStack(alignment: .center) {
                    Label(startDetail, systemImage: "sun.max.fill")
                        .font(theme.typography.micro.monospacedDigit())
                        .foregroundStyle(theme.colors.textSecondary.opacity(0.82))
                        .lineLimit(1)
                    Spacer(minLength: theme.spacing.sm)
                    Label(endDetail, systemImage: "moon.stars.fill")
                        .font(theme.typography.micro.monospacedDigit())
                        .foregroundStyle(theme.colors.textSecondary.opacity(0.82))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .frame(width: proxy.size.width, alignment: .leading)
        }
        .frame(height: dynamicTypeSize.isAccessibilitySize ? 228 : 178)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(surfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: theme.colors.accentWarm.opacity(reduceMotion ? 0.0 : 0.10), radius: 20, x: 0, y: 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Reality Meridian time band")
        .accessibilityValue("Current time \(timeLabel(for: date)). Window \(hourLabel(temporalWindow.dayStartHour)) to \(hourLabel(temporalWindow.dayEndHour)).")
        .accessibilityIdentifier("RealityMeridianTimeBand")
    }

    private var bandHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 132 : 92
    }

    private var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.105),
                theme.colors.accentSecondary.opacity(0.075),
                Color.black.opacity(0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var timeScale: some View {
        HStack(spacing: 0) {
            ForEach([6, 9, 12, 15, 18, 21], id: \.self) { hour in
                Text(hourLabel(hour))
                    .font(theme.typography.micro.monospacedDigit())
                    .foregroundStyle(theme.colors.textTertiary.opacity(0.76))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }
        }
    }

    private func zoneBand(width: CGFloat) -> some View {
        let total = zones.reduce(0.0) { $0 + $1.weight }
        return HStack(spacing: 0) {
            ForEach(zones) { zone in
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(zone.title)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(zoneForeground(zone.kind))
                        .lineLimit(1)
                        .minimumScaleFactor(0.56)
                    Text(zone.subtitle)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary.opacity(0.82))
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                }
                .padding(.horizontal, zone.kind == .startHere ? theme.spacing.xs : theme.spacing.xxs)
                .frame(width: width * CGFloat(zone.weight / total), height: bandHeight, alignment: .center)
                .background(zoneGradient(zone.kind))
                .overlay(alignment: .trailing) {
                    Rectangle()
                        .fill(theme.colors.strokeSubtle.opacity(0.32))
                        .frame(width: 1)
                        .accessibilityHidden(true)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
    }

    private var tickField: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            HStack(spacing: 3) {
                ForEach(0..<76, id: \.self) { index in
                    Rectangle()
                        .fill(index.isMultiple(of: 8) ? theme.colors.textTertiary.opacity(0.30) : theme.colors.textTertiary.opacity(0.10))
                        .frame(width: 1, height: index.isMultiple(of: 8) ? 14 : 7)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, theme.spacing.xs)
            .padding(.bottom, theme.spacing.xxs)
        }
        .accessibilityHidden(true)
    }

    private func currentCursor(date: Date, x: CGFloat, width: CGFloat) -> some View {
        let clampedX = max(10, min(width - 42, x))

        return VStack(spacing: theme.spacing.xxxs) {
            Text(timeLabel(for: date))
                .font(theme.typography.micro.weight(.bold).monospacedDigit())
                .foregroundStyle(theme.colors.accentWarm)
                .fixedSize(horizontal: true, vertical: false)

            Rectangle()
                .fill(theme.colors.accentWarm)
                .frame(width: 2, height: bandHeight - 24)
                .shadow(color: theme.colors.accentWarm.opacity(0.48), radius: 8)
                .overlay(alignment: .center) {
                    ZStack {
                        Circle()
                            .fill(theme.colors.accentWarm.opacity(0.20))
                            .frame(width: 30, height: 30)
                        Circle()
                            .fill(theme.colors.accentWarm)
                            .frame(width: 11, height: 11)
                    }
                    .offset(y: 16)
                }
        }
        .offset(x: clampedX - 22, y: -12)
        .accessibilityHidden(true)
    }

    private func zoneForeground(_ kind: RealityMeridianTimeBandZoneKind) -> Color {
        switch kind {
        case .startHere:
            theme.semanticColors.trust
        case .now:
            theme.colors.accentSecondary
        case .next:
            theme.semanticColors.review
        case .later:
            theme.colors.accentWarm
        }
    }

    private func zoneGradient(_ kind: RealityMeridianTimeBandZoneKind) -> LinearGradient {
        let color = zoneForeground(kind)
        return LinearGradient(
            colors: [color.opacity(0.24), color.opacity(0.085), Color.white.opacity(0.030)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
#endif