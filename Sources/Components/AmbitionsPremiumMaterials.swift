#if canImport(SwiftUI)
import SwiftUI
public func ambitionShouldUseLiquidGlass(
    reduceTransparency: Bool,
    colorSchemeContrast: ColorSchemeContrast
) -> Bool {
    guard reduceTransparency == false, colorSchemeContrast != .increased else {
        return false
    }
    if #available(iOS 26, *) {
        return true
    }
    return false
}
/// A gravity-drift spatial micro-particle background reacting to device tilt,
/// touch ripples, and deep ambient midnight glow.
/// Pauses motion in `reduceMotion` mode and falls back to a clean canvas in increased contrast mode.
public struct CelestialField: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    public struct Particle: Hashable, Identifiable {
        public let id: Int
        public var x: Double
        public var y: Double
        public var size: CGFloat
        public var opacity: Double
    }
    
    @State private var particles: [Particle] = []
    
    public init() {}
    private var useStaticFallback: Bool {
        colorSchemeContrast == .increased || reduceMotion || reduceTransparency
    }
    
    public var body: some View {
        GeometryReader { geo in
            if useStaticFallback {
                // High contrast fallback: Solid quiet baseline canvas
                theme.colors.canvas
                    .ignoresSafeArea()
            } else {
                ZStack {
                    // Deep ambient midnight glow background gradient
                    theme.materials.canvasGradient
                        .ignoresSafeArea()
                    
                    // Layered ambient radial flows to capture "Apple Quiet Luxury" depth
                    RadialGradient(
                        colors: [theme.colors.accentPrimary.opacity(0.12), .clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.85
                    )
                    .ignoresSafeArea()
                    
                    RadialGradient(
                        colors: [theme.colors.accentWarm.opacity(0.08), .clear],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: geo.size.width * 0.85
                    )
                    .ignoresSafeArea()
                    
                    if #available(iOS 17.0, *) {
                        // Static fallback for reduced-capability environments.
                        // For reduced-motion or reduced-transparency settings, we keep this
                        // as non-animated dot geometry for inspectable meaning.
                        if useStaticFallback {
                            ForEach(particles) { particle in
                                Circle()
                                    .fill(theme.colors.accentSecondary.opacity(particle.opacity))
                                    .frame(width: particle.size, height: particle.size)
                                    .position(
                                        x: particle.x * geo.size.width,
                                        y: particle.y * geo.size.height
                                    )
                            }
                        } else {
                            // Smoothly animated spatial drift matching actual device rest pacing
                            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timelineContext in
                                Canvas { context, size in
                                    let date = timelineContext.date.timeIntervalSince1970
                                    for particle in particles {
                                        // Elegant gravity-drift math responding to a rest-state pulse
                                        let driftX = sin(date * 0.12 + Double(particle.id)) * 8.0
                                        let driftY = cos(date * 0.08 + Double(particle.id)) * 8.0

                                        var px = particle.x * size.width + driftX
                                        var py = particle.y * size.height + driftY

                                        // Soft bounding wrap
                                        if px < 0 { px += size.width }
                                        if px > size.width { px -= size.width }
                                        if py < 0 { py += size.height }
                                        if py > size.height { py -= size.height }

                                        let rect = CGRect(
                                            x: px,
                                            y: py,
                                            width: particle.size,
                                            height: particle.size
                                        )

                                        // Twinkle loop
                                        let twinkle = 0.55 + 0.45 * sin(date * 0.4 + Double(particle.id))
                                        context.opacity = particle.opacity * twinkle
                                        context.fill(Path(ellipseIn: rect), with: .color(theme.colors.accentSecondary))
                                    }
                                }
                            }
                        }
                    } else {
                        // iOS versions without modern canvas fall back to static geometry-only markers.
                        ForEach(particles) { particle in
                            Circle()
                                .fill(theme.colors.accentSecondary.opacity(particle.opacity))
                                .frame(width: particle.size, height: particle.size)
                                .position(
                                    x: particle.x * geo.size.width,
                                    y: particle.y * geo.size.height
                                )
                        }
                    }
                }
                .onAppear {
                    if particles.isEmpty {
                        var generated: [Particle] = []
                        for i in 0..<32 {
                            generated.append(Particle(
                                id: i,
                                x: Double.random(in: 0.02...0.98),
                                y: Double.random(in: 0.02...0.98),
                                size: CGFloat.random(in: 1.5...3.0),
                                opacity: Double.random(in: 0.18...0.48)
                            ))
                        }
                        particles = generated
                    }
                }
            }
        }
    }
}
/// Refractive dual-layer frosted container catching dynamic ambient light
/// via a shifting 0.5pt radial border gradient shifting from warm gold to icy silver.
public struct QuietGlass<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    
    private let cornerRadius: CGFloat
    private let content: Content
    
    public init(cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    private var useFlatFallback: Bool {
        colorSchemeContrast == .increased || reduceTransparency
    }

    public var body: some View {
        if useFlatFallback {
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .background(theme.colors.surfaceOverlay)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(theme.colors.strokeStrong, lineWidth: 1.5)
            }
        } else {
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .background {
                ZStack {
                    // Base frosted blend
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(theme.colors.surfaceOverlay.opacity(0.35))
                    
                    // Elevated premium sheen gradient overlay
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(theme.surfaces.overlayGradient.opacity(0.70))
                        .blur(radius: 0.4)
                }
            }
            .overlay {
                // Shifting 0.5pt radial border (warm gold to icy silver)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                theme.colors.accentWarm.opacity(0.40),
                                theme.colors.strokeSubtle.opacity(0.12),
                                theme.colors.accentSecondary.opacity(0.30),
                                theme.colors.strokeSubtle.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
        }
    }
}
/// Embedded base material layer representing deep inner shadows,
/// graphite-recessed settings, and physical quiet depth.
public struct GraphiteRecess<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    
    private let cornerRadius: CGFloat
    private let content: Content
    
    public init(cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(theme.colors.canvasElevated.opacity(colorSchemeContrast == .increased ? 1.0 : 0.85))
        }
        .overlay {
            // Recessed subtle border mimicking mechanical depth
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.70 : 0.28),
                    lineWidth: 1.0
                )
        }
    }
}
/// Stateful trajectory drawing, outline shimmers, and micro-animations
/// guiding spatial movement of actions and objects.
public struct LuminousTraceModifier: ViewModifier {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let isShimmering: Bool
    let accentColor: Color?
    
    @State private var phase: CGFloat = 0.0
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    let shape = RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                    let baseAccent = accentColor ?? theme.colors.accentSecondary
                    
                    shape
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    baseAccent.opacity(0.12),
                                    baseAccent.opacity(0.85),
                                    baseAccent.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isShimmering ? 1.2 : 0.0
                        )
                        .mask {
                            if !reduceMotion && isShimmering {
                                shape
                                    .stroke(Color.black, lineWidth: 2.0)
                                    .scaleEffect(1.0)
                                    .hueRotation(.degrees(phase * 360.0))
                            } else {
                                shape.stroke(Color.black, lineWidth: 1.0)
                            }
                        }
                }
            }
            .onAppear {
                if !reduceMotion && isShimmering {
                    withAnimation(Animation.linear(duration: 4.5).repeatForever(autoreverses: false)) {
                        phase = 1.0
                    }
                }
            }
    }
}

public extension View {
    /// Applies stateful shimmering trajectory outlines to clarify premium interaction layers.
    func luminousTrace(isShimmering: Bool = true, accentColor: Color? = nil) -> some View {
        self.modifier(LuminousTraceModifier(isShimmering: isShimmering, accentColor: accentColor))
    }
}

#endif
