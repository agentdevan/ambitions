import Foundation
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

struct TodayBackgroundView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let clock: any AmbitionsClock

    init(clock: any AmbitionsClock = SystemClock()) {
        self.clock = clock
    }

    var body: some View {
        Group {
            if clock.advancesAutomatically {
                TimelineView(.periodic(from: clock.now, by: reduceMotion ? 300 : 60)) { context in
                    sky(date: context.date)
                }
            } else {
                sky(date: clock.now)
            }
        }
    }

    private func sky(date: Date) -> some View {
        let palette = TodaySkyPalette(date: date, calendar: clock.calendar)

        return ZStack {
            LinearGradient(
                colors: [palette.topColor, palette.midColor, palette.bottomColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [palette.glowColor.opacity(palette.glowOpacity), .clear],
                center: UnitPoint(x: palette.glowX, y: palette.glowY),
                startRadius: 20,
                endRadius: 360
            )
            .ignoresSafeArea()
            .blendMode(.screen)

            TodayStarField(opacity: palette.starOpacity, date: date)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.34),
                    Color.black.opacity(0.56),
                    Color.black.opacity(0.76),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

private struct TodayStarField: View {
    let opacity: Double
    let date: Date

    var body: some View {
        GeometryReader { _ in
            Canvas { context, size in
                let twinkle = CGFloat((sin(date.timeIntervalSinceReferenceDate / 180) + 1) * 0.5)
                for index in 0 ..< 24 {
                    var path = Path()
                    let point = pointForStar(index: index, in: size)
                    let radius = CGFloat((index % 3) + 1)
                    path.addEllipse(in: CGRect(x: point.x, y: point.y, width: radius, height: radius))
                    context.fill(path, with: .color(.white.opacity(opacity * Double(0.45 + 0.35 * twinkle))))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func pointForStar(index: Int, in size: CGSize) -> CGPoint {
        let x = CGFloat((index * 37) % 100) / 100 * size.width
        let y = CGFloat((index * 19) % 55) / 100 * size.height
        return CGPoint(x: x, y: y)
    }
}

private struct TodaySkyPalette {
    let topColor: Color
    let midColor: Color
    let bottomColor: Color
    let glowColor: Color
    let glowOpacity: Double
    let glowX: CGFloat
    let glowY: CGFloat
    let starOpacity: Double

    init(date: Date, calendar: Calendar) {
        let seconds = calendar.dateComponents([.hour, .minute, .second], from: date)
        let hour = Double(seconds.hour ?? 0)
        let minute = Double(seconds.minute ?? 0)
        let second = Double(seconds.second ?? 0)
        let totalSeconds: Double = hour * 3600 + minute * 60 + second
        let dayProgress = totalSeconds / 86400
        let solar = max(0, sin((dayProgress - 0.25) * .pi))
        let visualSolar = solar * 0.28
        let dawnGlow = Foundation.exp(-Foundation.pow((dayProgress - 0.23) / 0.06, 2))
        let duskGlow = Foundation.exp(-Foundation.pow((dayProgress - 0.76) / 0.07, 2))
        let warmth = min(1, dawnGlow + duskGlow)
        let night = max(0, 1 - solar * 1.35)
        starOpacity = min(0.28, max(0.07, night * 0.26))

        topColor = Self.lerp(
            from: Color(red: 0.018, green: 0.026, blue: 0.045),
            to: Color(red: 0.066, green: 0.090, blue: 0.132),
            amount: visualSolar
        )
        midColor = Self.lerp(
            from: Color(red: 0.028, green: 0.033, blue: 0.052),
            to: Color(red: 0.078, green: 0.106, blue: 0.150),
            amount: visualSolar
        )
        bottomColor = Self.lerp(
            from: Color(red: 0.016, green: 0.018, blue: 0.030),
            to: Color(red: 0.120, green: 0.072, blue: 0.046),
            amount: warmth * 0.26 + visualSolar * 0.10
        )
        glowColor = warmth > 0.08 ? Color(red: 1.00, green: 0.66, blue: 0.38) : Color(red: 0.42, green: 0.50, blue: 0.76)
        glowOpacity = 0.10 + warmth * 0.14 + visualSolar * 0.04
        glowX = dawnGlow > duskGlow ? 0.18 : 0.82
        glowY = CGFloat(0.12 + (1 - solar) * 0.18)
    }

    private static func lerp(from: Color, to: Color, amount: Double) -> Color {
        let amount = max(0, min(1, amount))
        return Color(
            red: from.components.red + (to.components.red - from.components.red) * amount,
            green: from.components.green + (to.components.green - from.components.green) * amount,
            blue: from.components.blue + (to.components.blue - from.components.blue) * amount,
            opacity: from.components.opacity + (to.components.opacity - from.components.opacity) * amount
        )
    }
}

private extension Color {
    struct Components {
        let red: Double
        let green: Double
        let blue: Double
        let opacity: Double
    }

    var components: Components {
        #if canImport(UIKit)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return Components(red: red, green: green, blue: blue, opacity: alpha)
        #else
            return Components(red: 0, green: 0, blue: 0, opacity: 1)
        #endif
    }
}
