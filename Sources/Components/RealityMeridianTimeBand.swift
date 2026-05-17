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
        RealityMeridianTimeBandZone(id: "start-here", title: "Start Here", subtitle: "Begin", weight: 0.27, kind: .startHere),
        RealityMeridianTimeBandZone(id: "now", title: "Now", subtitle: "Act", weight: 0.24, kind: .now),
        RealityMeridianTimeBandZone(id: "next", title: "Next", subtitle: "Prepare", weight: 0.25, kind: .next),
        RealityMeridianTimeBandZone(id: "later", title: "Later", subtitle: "Hold", weight: 0.24, kind: .later)
    ]
}

public struct RealityMeridianTimeBand: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                timeScale

                ZStack(alignment: .leading) {
                    zoneBand(width: width)
                    tickField
                    currentCursor(date: date, x: cursorX)
                }
                .frame(height: 112)

                HStack(alignment: .center) {
                    Label(startDetail, systemImage: "sun.max.fill")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                    Spacer(minLength: theme.spacing.sm)
                    Label(endDetail, systemImage: "moon.stars.fill")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .padding(theme.spacing.md)
            .frame(width: proxy.size.width, alignment: .leading)
        }
        .frame(minHeight: 206)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.shell.elevatedMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.shell.divider.opacity(0.92), lineWidth: 1)
        )
        .shadow(color: theme.colors.accentWarm.opacity(reduceMotion ? 0.0 : 0.12), radius: 22, x: 0, y: 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Reality Meridian time band")
        .accessibilityValue("Current time \(timeLabel(for: date)). Window \(hourLabel(temporalWindow.dayStartHour)) to \(hourLabel(temporalWindow.dayEndHour)).")
        .accessibilityIdentifier("RealityMeridianTimeBand")
    }

    private var timeScale: some View {
        HStack {
            ForEach([6, 9, 12, 15, 18, 21], id: \.self) { hour in
                Text(hourLabel(hour))
                    .font(theme.typography.caption.monospacedDigit())
                    .foregroundStyle(theme.colors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func zoneBand(width: CGFloat) -> some View {
        let total = zones.reduce(0.0) { $0 + $1.weight }
        return HStack(spacing: 0) {
            ForEach(zones) { zone in
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(zone.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(zoneForeground(zone.kind))
                    Text(zone.subtitle)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                }
                .padding(.horizontal, theme.spacing.md)
                .frame(width: width * CGFloat(zone.weight / total), height: 84, alignment: .center)
                .background(zoneGradient(zone.kind))
                .overlay(alignment: .trailing) {
                    Rectangle()
                        .fill(theme.colors.strokeSubtle.opacity(0.38))
                        .frame(width: 1)
                        .accessibilityHidden(true)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
    }

    private var tickField: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                ForEach(0..<88, id: \.self) { index in
                    Rectangle()
                        .fill(index.isMultiple(of: 8) ? theme.colors.textTertiary.opacity(0.38) : theme.colors.textTertiary.opacity(0.14))
                        .frame(width: 1, height: index.isMultiple(of: 8) ? 17 : 8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.bottom, theme.spacing.sm)
        }
        .accessibilityHidden(true)
    }

    private func currentCursor(date: Date, x: CGFloat) -> some View {
        VStack(spacing: theme.spacing.xxxs) {
            Text(timeLabel(for: date))
                .font(theme.typography.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(theme.semanticColors.recovery)
                .fixedSize(horizontal: true, vertical: false)

            Rectangle()
                .fill(theme.semanticColors.recovery)
                .frame(width: 2, height: 86)
                .shadow(color: theme.semanticColors.recovery.opacity(0.60), radius: 10)
                .overlay(alignment: .center) {
                    ZStack {
                        Circle()
                            .fill(theme.semanticColors.recovery.opacity(0.20))
                            .frame(width: 36, height: 36)
                        Circle()
                            .fill(theme.semanticColors.recovery)
                            .frame(width: 14, height: 14)
                    }
                    .offset(y: 22)
                }

            Text("Right where you are.")
                .font(theme.typography.micro)
                .foregroundStyle(theme.semanticColors.recovery)
                .fixedSize(horizontal: true, vertical: false)
        }
        .offset(x: max(0, x - 52), y: -20)
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
            colors: [color.opacity(0.34), color.opacity(0.10), theme.colors.surfaceOverlay.opacity(0.08)],
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
