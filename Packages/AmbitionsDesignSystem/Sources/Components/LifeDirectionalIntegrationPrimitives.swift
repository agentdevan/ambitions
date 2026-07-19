#if canImport(SwiftUI)
import SwiftUI

// MARK: - Tokens & Constants for Life-Directional Integration (LDI)

/// Premium visual tokens for Life-Directional Integration, ensuring
/// deep, grounded ambient spaces, physical vectors, and luxury micro-ticks.
public struct LDITokens {
    public static let meridianCurveControlY: CGFloat = 0.45
    public static let gridLineOpacity: Double = 0.08
    public static let tickMarkHeight: CGFloat = 8.0
    public static let vectorActiveLineWidth: CGFloat = 2.0
    
    // Harmonious curated vector gradients
    public static func sageMomentumGradient(in theme: AmbitionTheme) -> LinearGradient {
        LinearGradient(
            colors: [
                theme.colors.accentPrimary,
                theme.colors.accentSecondary,
                theme.colors.success
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    public static func goldRealityGradient(in theme: AmbitionTheme) -> LinearGradient {
        LinearGradient(
            colors: [
                theme.colors.accentWarm,
                theme.colors.warning,
                theme.colors.celebration
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - 1. TemporalMomentumGauge

/// A gorgeous circular premium progress indicator rendering real-time grounded progress
/// momentum with microscopic ticking lines, glowing radial arc tracers, and a floating needle.
public struct TemporalMomentumGauge: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    
    let value: Double // Range 0.0 to 1.0
    let title: String
    let subtitle: String
    
    @State private var animatedValue: Double = 0.0
    
    public init(value: Double, title: String, subtitle: String) {
        self.value = max(0, min(value, 1))
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        QuietGlass(cornerRadius: theme.radius.lg) {
            VStack(spacing: theme.spacing.sm) {
                gaugeDial
                
                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, theme.spacing.md)
            }
            .padding(theme.spacing.lg)
        }
        .onAppear {
            if reduceMotion {
                animatedValue = value
            } else {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.82)) {
                    animatedValue = value
                }
            }
        }
        .onChange(of: value) { _, newValue in
            if reduceMotion {
                animatedValue = newValue
            } else {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                    animatedValue = newValue
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) Momentum Gauge")
        .accessibilityValue(String(format: "%.0f percent progress", value * 100))
    }

    var gaugeDial: some View {
        ZStack {
            dialTicks
            trackBackground
            if colorSchemeContrast != .increased {
                activeTrack
                    .blur(radius: 2.5)
                    .opacity(0.7)
            }
            activeTrack
            needle
            valueDisplay
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxHeight: 210)
    }

    var dialTicks: some View {
        CircleDialTicks()
            .stroke(theme.colors.strokeSubtle.opacity(0.35), lineWidth: 1)
            .padding(theme.spacing.sm)
    }

    var trackBackground: some View {
        Circle()
            .trim(from: 0.12, to: 0.88)
            .stroke(theme.colors.strokeSubtle.opacity(0.18), style: StrokeStyle(lineWidth: 12, lineCap: .round))
            .rotationEffect(.degrees(90))
            .padding(theme.spacing.sm + 6)
    }

    var activeTrack: some View {
        Circle()
            .trim(from: 0.12, to: 0.12 + 0.76 * animatedValue)
            .stroke(
                LDITokens.sageMomentumGradient(in: theme),
                style: StrokeStyle(lineWidth: 12, lineCap: .round)
            )
            .rotationEffect(.degrees(90))
            .padding(theme.spacing.sm + 6)
    }

    var needle: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2 - theme.spacing.sm - 12
            let angleDegrees = 133.2 + (0.76 * animatedValue * 360.0)

            ZStack {
                Path { path in
                    path.move(to: center)
                    let endX = center.x + radius * cos(angleDegrees * .pi / 180)
                    let endY = center.y + radius * sin(angleDegrees * .pi / 180)
                    path.addLine(to: CGPoint(x: endX, y: endY))
                }
                .stroke(theme.colors.accentWarm, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .shadow(color: theme.colors.accentWarm.opacity(0.4), radius: 3)

                Circle()
                    .fill(theme.colors.canvasElevated)
                    .frame(width: 24, height: 24)
                    .position(center)
                    .shadow(radius: 2)

                Circle()
                    .fill(theme.colors.accentWarm)
                    .frame(width: 8, height: 8)
                    .position(center)
            }
        }
    }

    var valueDisplay: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.0f%%", animatedValue * 100))
                .font(.system(size: 32, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(theme.colors.textPrimary)

            Text(title)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.accentSecondary)
                .tracking(1.5)
        }
        .offset(y: 8)
    }
}

struct CircleDialTicks: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        let startAngle = 133.2 * Double.pi / 180.0
        let sweep = 273.6 * Double.pi / 180.0
        let tickCount = 48
        
        for i in 0...tickCount {
            let angle = startAngle + (Double(i) / Double(tickCount)) * sweep
            
            // Outer tick boundary
            let outerX = center.x + radius * CGFloat(cos(angle))
            let outerY = center.y + radius * CGFloat(sin(angle))
            
            // Inner tick boundary
            let tickLen: CGFloat = (i % 6 == 0) ? 10.0 : 5.0
            let innerX = center.x + (radius - tickLen) * CGFloat(cos(angle))
            let innerY = center.y + (radius - tickLen) * CGFloat(sin(angle))
            
            path.move(to: CGPoint(x: outerX, y: outerY))
            path.addLine(to: CGPoint(x: innerX, y: innerY))
        }
        
        return path
    }
}

// MARK: - 2. RealityMeridianHorizon

/// A stunning curvilinear horizon line depicting the threshold between actual
/// daily capacity (Reality Meridian, bottom) and planned aspirations (Aspirational, top).
public struct RealityMeridianHorizon<TopContent: View, BottomContent: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    
    let realityLevel: CGFloat // 0.0 to 1.0
    let topContent: TopContent
    let bottomContent: BottomContent
    
    public init(
        realityLevel: CGFloat = 0.5,
        @ViewBuilder topContent: () -> TopContent,
        @ViewBuilder bottomContent: () -> BottomContent
    ) {
        self.realityLevel = max(0, min(realityLevel, 1))
        self.topContent = topContent()
        self.bottomContent = bottomContent()
    }
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let splitY = h * (1.0 - realityLevel)
            
            ZStack(alignment: .topLeading) {
                // Aspirational space (Top)
                QuietGlass(cornerRadius: theme.radius.lg) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        topContent
                    }
                    .padding(theme.spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: splitY)
                
                // Reality recess (Bottom)
                GraphiteRecess(cornerRadius: theme.radius.lg) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        bottomContent
                    }
                    .padding(theme.spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .offset(y: splitY)
                .frame(height: h - splitY)
                
                // Meridian Wave Horizon curve line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: splitY))
                    path.addQuadCurve(
                        to: CGPoint(x: w, y: splitY),
                        control: CGPoint(x: w * 0.5, y: splitY - 14)
                    )
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            theme.colors.accentSecondary,
                            theme.colors.accentWarm,
                            theme.colors.accentSecondary
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2.0
                )
                .shadow(color: theme.colors.accentWarm.opacity(colorSchemeContrast == .increased ? 0.0 : 0.4), radius: 3)
            }
        }
        .frame(minHeight: 300)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Reality Meridian split view")
    }
}

// MARK: - 3. LifeShapeField

/// A spatial grid where active goals are rendered as moving, connected celestial coordinates
/// connected by delicate lines, fully interactive via touches.
#endif
