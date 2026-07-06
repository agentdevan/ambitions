import AmbitionsDesignSystem
import SwiftUI

extension AmbitionsDayRailView {
    var meridianAtmosphere: some View {
        ZStack {
            LinearGradient(
                colors: [
                    theme.colors.canvas,
                    theme.colors.canvasElevated.opacity(0.94),
                    theme.colors.surfaceOverlay.opacity(0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [theme.colors.accentWarm.opacity(0.32), .clear],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 380
            )
            .blendMode(.screen)

            RadialGradient(
                colors: [theme.colors.accentPrimary.opacity(0.10), .clear],
                center: .center,
                startRadius: 48,
                endRadius: 330
            )
            .blendMode(.screen)

            meridianOrientationField
            horizonField
        }
        .ignoresSafeArea()
    }


    var viewportSafety: TodayViewportSafety {
        TodayViewportSafety.layout(dynamicTypeSize: dynamicTypeSize, showsNavigationChrome: false)
    }


    var usesExpandedViewport: Bool {
        viewportSafety.usesStackedAccessibilityRail
    }


    var meridianOrientationField: some View {
        Canvas { context, size in
            let sweeps: [(CGFloat, CGFloat, CGFloat)] = [
                (0.16, 0.34, 0.10),
                (0.31, 0.55, 0.08),
                (0.52, 0.76, 0.06)
            ]

            for sweep in sweeps {
                var path = Path()
                path.move(to: CGPoint(x: -size.width * 0.10, y: size.height * sweep.0))
                path.addCurve(
                    to: CGPoint(x: size.width * 1.08, y: size.height * sweep.1),
                    control1: CGPoint(x: size.width * 0.24, y: size.height * (sweep.0 - 0.05)),
                    control2: CGPoint(x: size.width * 0.70, y: size.height * (sweep.1 + 0.07))
                )
                context.stroke(
                    path,
                    with: .color(theme.colors.strokeSubtle.opacity(sweep.2)),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [6, 18])
                )
            }
        }
        .opacity(reduceMotion ? 0.42 : 0.74)
        .allowsHitTesting(false)
    }


    var horizonField: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        .clear,
                        theme.colors.accentWarm.opacity(0.12),
                        theme.colors.canvas.opacity(0.52)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 230)
            }

            Canvas { context, size in
                var farRidge = Path()
                farRidge.move(to: CGPoint(x: 0, y: size.height))
                farRidge.addLine(to: CGPoint(x: 0, y: size.height * 0.82))
                farRidge.addLine(to: CGPoint(x: size.width * 0.20, y: size.height * 0.77))
                farRidge.addLine(to: CGPoint(x: size.width * 0.40, y: size.height * 0.84))
                farRidge.addLine(to: CGPoint(x: size.width * 0.62, y: size.height * 0.75))
                farRidge.addLine(to: CGPoint(x: size.width * 0.82, y: size.height * 0.80))
                farRidge.addLine(to: CGPoint(x: size.width, y: size.height * 0.72))
                farRidge.addLine(to: CGPoint(x: size.width, y: size.height))
                farRidge.closeSubpath()
                context.fill(farRidge, with: .color(theme.colors.surfaceOverlay.opacity(0.30)))

                var nearRidge = Path()
                nearRidge.move(to: CGPoint(x: 0, y: size.height))
                nearRidge.addLine(to: CGPoint(x: 0, y: size.height * 0.90))
                nearRidge.addLine(to: CGPoint(x: size.width * 0.22, y: size.height * 0.84))
                nearRidge.addLine(to: CGPoint(x: size.width * 0.47, y: size.height * 0.92))
                nearRidge.addLine(to: CGPoint(x: size.width * 0.74, y: size.height * 0.82))
                nearRidge.addLine(to: CGPoint(x: size.width, y: size.height * 0.88))
                nearRidge.addLine(to: CGPoint(x: size.width, y: size.height))
                nearRidge.closeSubpath()
                context.fill(nearRidge, with: .color(theme.colors.canvasElevated.opacity(0.54)))
            }
            .frame(height: 260)
            .allowsHitTesting(false)
        }
        .allowsHitTesting(false)
    }


    var compactContextCrown: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Today")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.8)

                Text(dateContextLine)
                    .font(theme.typography.section.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: theme.spacing.md)

            onDeviceSignal(font: theme.typography.caption.weight(.semibold), dotSize: 8)
        }
        .accessibilityIdentifier("TodayRealityRailContextCrown")
    }


    var accessibilityContextCrown: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            Text(dateContextLine)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Spacer(minLength: theme.spacing.sm)

            onDeviceSignal(font: theme.typography.micro.weight(.semibold), dotSize: 7)
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .accessibilityIdentifier("TodayRealityRailAccessibilityContextCrown")
    }


    func onDeviceSignal(font: Font, dotSize: CGFloat) -> some View {
        HStack(spacing: theme.spacing.xs) {
            Circle()
                .fill(theme.colors.accentWarm.opacity(0.90))
                .frame(width: dotSize, height: dotSize)
                .accessibilityHidden(true)
            Text("On-device")
                .font(font)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(1)
        }
        .accessibilityLabel("On-device")
    }


    var timeSpine: some View {
        Group {
            if usesExpandedViewport {
                compactTimeSpine
            } else if clock.advancesAutomatically {
                TimelineView(.periodic(from: clock.now, by: 60)) { timeline in
                    liveTimeSpine(date: timeline.date)
                }
            } else {
                liveTimeSpine(date: clock.now)
            }
        }
        .padding(.top, theme.spacing.xs)
        .accessibilityIdentifier("TodayRealityRailLiveTimeSpine")
        .accessibilityHidden(true)
    }


    func liveTimeSpine(date: Date) -> some View {
        VStack(spacing: 0) {
            timeTick(timeLabel(offsetHours: -3, from: date), prominent: false)
            verticalSegment(height: 50)
            currentTimeNode(date: date)
            verticalSegment(height: 58)
            timeTick(timeLabel(offsetHours: 2, from: date), prominent: false)
            verticalSegment(height: 72)
            mappedRowNode(index: 0)
            verticalSegment(height: 56)
            timeTick(timeLabel(offsetHours: 5, from: date), prominent: false)
            verticalSegment(height: 46)
            mappedRowNode(index: 1)
            verticalSegment(height: 54)
            mappedRowNode(index: 2)
            verticalSegment(height: 34)
            timeTick(timeLabel(offsetHours: 8, from: date), prominent: false)
        }
    }


    func timeLabel(offsetHours: Int, from date: Date) -> String {
        let adjusted = clock.calendar.date(byAdding: .hour, value: offsetHours, to: date) ?? date
        return adjusted.formatted(.dateTime.hour())
    }


    var compactTimeSpine: some View {
        VStack(spacing: 0) {
            compactRailNode(color: theme.colors.textSecondary.opacity(0.62), size: 5)
            verticalSegment(height: 38)
            compactRailNode(color: theme.colors.accentWarm, size: 18, halo: true)
            verticalSegment(height: 52)
            compactRailNode(color: theme.colors.textSecondary.opacity(0.72), size: 14)
            verticalSegment(height: 44)
            compactRailNode(color: theme.colors.textSecondary.opacity(0.64), size: 13)
            verticalSegment(height: 42)
            compactRailNode(color: theme.colors.textSecondary.opacity(0.56), size: 13)
        }
        .frame(width: 28, alignment: .center)
    }


    func compactRailNode(color: Color, size: CGFloat, halo: Bool = false) -> some View {
        ZStack {
            if halo {
                Circle()
                    .fill(color.opacity(0.24))
                    .frame(width: size + 18, height: size + 18)
            }
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
        .frame(width: 28, height: max(28, size + 18))
    }


    func timeTick(_ label: String, prominent: Bool) -> some View {
        HStack(spacing: theme.spacing.xs) {
            Text(label)
                .font(theme.typography.caption)
                .foregroundStyle(prominent ? theme.colors.accentWarm : theme.colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(width: 42, alignment: .trailing)

            Circle()
                .fill(prominent ? theme.colors.accentWarm : theme.colors.textSecondary.opacity(0.60))
                .frame(width: prominent ? 8 : 5, height: prominent ? 8 : 5)
        }
    }


    func verticalSegment(height: CGFloat) -> some View {
        Rectangle()
            .fill(theme.colors.textSecondary.opacity(0.34))
            .frame(width: 1.25, height: height)
            .offset(x: 25)
    }


    func currentTimeNode(date: Date) -> some View {
        HStack(spacing: theme.spacing.xs) {
            VStack(alignment: .trailing, spacing: 1) {
                Text(date, format: .dateTime.hour().minute())
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.accentWarm)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }
            .frame(width: 64, alignment: .trailing)

            ZStack {
                Circle()
                    .fill(theme.colors.accentWarm.opacity(reduceMotion ? 0.18 : 0.22))
                    .frame(width: 42, height: 42)
                    .blur(radius: reduceMotion ? 0 : 2)
                Circle()
                    .fill(theme.colors.accentWarm)
                    .frame(width: 16, height: 16)
                Circle()
                    .stroke(theme.colors.accentWarm.opacity(0.78), lineWidth: 2)
                    .frame(width: 30, height: 30)
            }
        }
        .accessibilityIdentifier("TodayRealityRailLiveNow")
        .accessibilityLabel("Current time \(date.formatted(.dateTime.hour().minute()))")
    }
}
