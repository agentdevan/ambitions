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
    
    private let value: Double // Range 0.0 to 1.0
    private let title: String
    private let subtitle: String
    
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

    private var gaugeDial: some View {
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

    private var dialTicks: some View {
        CircleDialTicks()
            .stroke(theme.colors.strokeSubtle.opacity(0.35), lineWidth: 1)
            .padding(theme.spacing.sm)
    }

    private var trackBackground: some View {
        Circle()
            .trim(from: 0.12, to: 0.88)
            .stroke(theme.colors.strokeSubtle.opacity(0.18), style: StrokeStyle(lineWidth: 12, lineCap: .round))
            .rotationEffect(.degrees(90))
            .padding(theme.spacing.sm + 6)
    }

    private var activeTrack: some View {
        Circle()
            .trim(from: 0.12, to: 0.12 + 0.76 * animatedValue)
            .stroke(
                LDITokens.sageMomentumGradient(in: theme),
                style: StrokeStyle(lineWidth: 12, lineCap: .round)
            )
            .rotationEffect(.degrees(90))
            .padding(theme.spacing.sm + 6)
    }

    private var needle: some View {
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

    private var valueDisplay: some View {
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

private struct CircleDialTicks: Shape {
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
    
    private let realityLevel: CGFloat // 0.0 to 1.0
    private let topContent: TopContent
    private let bottomContent: BottomContent
    
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
public struct LifeShapeField: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    
    public struct VectorNode: Identifiable {
        public let id: Int
        public let label: String
        public var x: Double
        public var y: Double
        public var speedX: Double
        public var speedY: Double
    }
    
    @State private var nodes: [VectorNode] = [
        VectorNode(id: 0, label: "Core Health", x: 0.25, y: 0.35, speedX: 0.002, speedY: 0.003),
        VectorNode(id: 1, label: "Daily Focus", x: 0.72, y: 0.22, speedX: -0.003, speedY: 0.002),
        VectorNode(id: 2, label: "Career Shape", x: 0.50, y: 0.75, speedX: 0.001, speedY: -0.002),
        VectorNode(id: 3, label: "Mental Rest", x: 0.15, y: 0.65, speedX: -0.002, speedY: -0.001),
        VectorNode(id: 4, label: "Wealth Flow", x: 0.82, y: 0.60, speedX: 0.002, speedY: 0.001)
    ]
    
    @State private var selectedNodeId: Int? = 1
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                Text("LIFESHAPE FIELD")
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.accentSecondary)
                    .tracking(1.5)
                
                Spacer()
                
                Text(selectedNodeId != nil ? nodes[selectedNodeId!].label : "Select coordinate")
                    .font(theme.typography.caption.weight(.bold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background {
                        Capsule()
                            .fill(theme.colors.accentSecondary.opacity(0.12))
                    }
            }
            
            GeometryReader { geo in
                ZStack {
                    // Deep field background
                    RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                        .fill(theme.colors.canvasElevated)
                        .overlay {
                            // Technical Grid Lines
                            Path { path in
                                let step = geo.size.width / 8
                                for i in 1..<8 {
                                    let offset = CGFloat(i) * step
                                    path.move(to: CGPoint(x: offset, y: 0))
                                    path.addLine(to: CGPoint(x: offset, y: geo.size.height))
                                    path.move(to: CGPoint(x: 0, y: offset))
                                    path.addLine(to: CGPoint(x: geo.size.width, y: offset))
                                }
                            }
                            .stroke(theme.colors.strokeSubtle.opacity(LDITokens.gridLineOpacity), lineWidth: 0.5)
                        }
                    
                    if reduceMotion {
                        staticCanvas(size: geo.size)
                    } else {
                        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timelineContext in
                            animatedCanvas(size: geo.size, date: timelineContext.date.timeIntervalSince1970)
                        }
                    }
                    
                    // Touch hit areas for nodes
                    ForEach(nodes) { node in
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 44, height: 44)
                            .position(x: node.x * geo.size.width, y: node.y * geo.size.height)
                            .contentShape(Circle())
                            .onTapGesture {
                                selectedNodeId = node.id
                            }
                    }
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                    .strokeBorder(theme.colors.strokeSubtle.opacity(0.24), lineWidth: 1.0)
            }
        }
        .padding(theme.spacing.lg)
        .background {
            QuietGlass(cornerRadius: theme.radius.lg) { EmptyView() }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("LifeShape Interactive Spatial Grid")
        .accessibilityValue("Selected vector: \(selectedNodeId != nil ? nodes[selectedNodeId!].label : "none")")
    }
    
    private func staticCanvas(size: CGSize) -> some View {
        Canvas { context, sz in
            // Draw connection paths
            var path = Path()
            if nodes.count > 1 {
                path.move(to: CGPoint(x: nodes[0].x * sz.width, y: nodes[0].y * sz.height))
                for i in 1..<nodes.count {
                    path.addLine(to: CGPoint(x: nodes[i].x * sz.width, y: nodes[i].y * sz.height))
                }
                path.addLine(to: CGPoint(x: nodes[0].x * sz.width, y: nodes[0].y * sz.height))
            }
            context.stroke(path, with: .color(theme.colors.accentSecondary.opacity(0.25)), lineWidth: 1.0)
            
            // Draw coordinate circles
            for node in nodes {
                let center = CGPoint(x: node.x * sz.width, y: node.y * sz.height)
                let rect = CGRect(x: center.x - 6, y: center.y - 6, width: 12, height: 12)
                context.fill(Path(ellipseIn: rect), with: .color(node.id == selectedNodeId ? theme.colors.accentWarm : theme.colors.accentSecondary))
            }
        }
    }
    
    private func animatedCanvas(size: CGSize, date: Double) -> some View {
        Canvas { context, sz in
            // Render connection vector traces
            if nodes.count > 1 {
                for i in 0..<nodes.count {
                    for j in (i + 1)..<nodes.count {
                        // delicate vectors linking close neighbors
                        let p1 = CGPoint(x: nodes[i].x * sz.width, y: nodes[i].y * sz.height)
                        let p2 = CGPoint(x: nodes[j].x * sz.width, y: nodes[j].y * sz.height)
                        let dist = hypot(p1.x - p2.x, p1.y - p2.y)
                        
                        if dist < sz.width * 0.5 {
                            context.opacity = Double(1.0 - (dist / (sz.width * 0.5))) * 0.35
                            context.stroke(Path { p in
                                p.move(to: p1)
                                p.addLine(to: p2)
                            }, with: .color(theme.colors.accentSecondary), lineWidth: 0.5)
                        }
                    }
                }
            }
            
            // Render coordinate nodes
            for node in nodes {
                // gravity drift offset simulation
                let pulse = sin(date * 2.0 + Double(node.id)) * 2.0
                let center = CGPoint(
                    x: node.x * sz.width + sin(date * 0.4 + Double(node.id)) * 4.0,
                    y: node.y * sz.height + cos(date * 0.3 + Double(node.id)) * 4.0
                )
                
                let isSelected = node.id == selectedNodeId
                let sizeVal = (isSelected ? 14.0 : 8.0) + CGFloat(pulse * 0.4)
                let rect = CGRect(x: center.x - sizeVal/2, y: center.y - sizeVal/2, width: sizeVal, height: sizeVal)
                
                if isSelected && colorSchemeContrast != .increased {
                    // Outer glow tracer
                    context.opacity = 0.3
                    context.fill(Path(ellipseIn: rect.insetBy(dx: -4, dy: -4)), with: .color(theme.colors.accentWarm))
                }
                
                context.opacity = 1.0
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(isSelected ? theme.colors.accentWarm : theme.colors.accentSecondary)
                )
            }
        }
    }
}

// MARK: - 4. FocusDensitySphere

/// A majestic three-dimensional simulated frosted sphere utilizing complex gradient masks,
/// representing active focus allocation density inside the You settings-style screen.
public struct FocusDensitySphere: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    
    private let levels: [Double] // allocation ratio for: sage (0), blueGray (1), warmGold (2)
    
    @State private var rotationPhase: Double = 0.0
    
    public init(levels: [Double] = [0.45, 0.30, 0.25]) {
        self.levels = levels
    }
    
    public var body: some View {
        QuietGlass(cornerRadius: theme.radius.lg) {
            HStack(spacing: theme.spacing.lg) {
                // Premium 3D-simulated sphere canvas
                ZStack {
                    if colorSchemeContrast == .increased {
                        // High Legibility Circle Flat Representation
                        Circle()
                            .fill(theme.colors.canvasElevated)
                            .overlay {
                                Circle()
                                    .strokeBorder(theme.colors.strokeStrong, lineWidth: 2)
                            }
                    } else {
                        // Luxury volumetric sphere shading layers
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        theme.colors.accentSecondary.opacity(0.85),
                                        theme.colors.accentPrimary.opacity(0.4),
                                        theme.colors.canvas.opacity(0.9)
                                    ],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 75
                                )
                            )
                            .shadow(color: theme.colors.accentSecondary.opacity(0.35), radius: 10, x: 0, y: 4)
                        
                        // Internal organic flow overlay reflecting time values
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        theme.colors.accentWarm.opacity(0.65),
                                        .clear,
                                        theme.colors.accentSecondary.opacity(0.45)
                                    ],
                                    startPoint: .topTrailing,
                                    endPoint: .bottomLeading
                                )
                            )
                            .blendMode(.colorDodge)
                            .rotationEffect(.degrees(rotationPhase))
                        
                        // Volume lighting overlay shine
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.white.opacity(0.45), .clear],
                                    center: .init(x: 0.32, y: 0.32),
                                    startRadius: 0,
                                    endRadius: 36
                                )
                            )
                    }
                }
                .frame(width: 100, height: 100)
                
                // Focus Allocation legend
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text("FOCUS DENSITY")
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.accentSecondary)
                        .tracking(1.0)
                    
                    allocationRow(label: "Directional Growth", ratio: levels.indices.contains(0) ? levels[0] : 0.0, color: theme.colors.accentSecondary)
                    allocationRow(label: "Routine Settle", ratio: levels.indices.contains(1) ? levels[1] : 0.0, color: theme.colors.accentPrimary)
                    allocationRow(label: "Creative / Buffer", ratio: levels.indices.contains(2) ? levels[2] : 0.0, color: theme.colors.accentWarm)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(theme.spacing.lg)
        }
        .onAppear {
            if !reduceMotion {
                withAnimation(Animation.linear(duration: 12.0).repeatForever(autoreverses: false)) {
                    rotationPhase = 360.0
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Focus Density allocation sphere chart")
    }
    
    private func allocationRow(label: String, ratio: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                
                Text(label)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textPrimary)
                
                Spacer()
                
                Text(String(format: "%.0f%%", ratio * 100))
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
            }
            
            // Capsule bar
            GeometryReader { geo in
                Capsule()
                    .fill(theme.colors.strokeSubtle.opacity(0.2))
                    .frame(height: 4)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(color)
                            .frame(width: geo.size.width * CGFloat(ratio), height: 4)
                    }
            }
            .frame(height: 4)
        }
    }
}
#endif
