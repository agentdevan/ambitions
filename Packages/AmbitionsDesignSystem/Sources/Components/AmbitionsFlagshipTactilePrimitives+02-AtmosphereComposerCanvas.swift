#if canImport(SwiftUI)
import SwiftUI

public struct AtmosphereComposerCanvas: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    
    @Binding private var inputText: String
    let placeholder: String
    let onCommit: (String) -> Void
    
    @State private var particles: [ComposerParticle] = []
    @State private var thoughtBubbleScale: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero
    @FocusState private var isFieldFocused: Bool
    
    struct ComposerParticle: Identifiable {
        let id: UUID = UUID()
        var x: CGFloat
        var y: CGFloat
        var speedX: CGFloat
        var speedY: CGFloat
        var size: CGFloat
        var color: Color
    }
    
    public init(
        inputText: Binding<String>,
        placeholder: String = "Capture scattered life input...",
        onCommit: @escaping (String) -> Void
    ) {
        self._inputText = inputText
        self.placeholder = placeholder
        self.onCommit = onCommit
    }
    
    public var body: some View {
        QuietGlass(cornerRadius: theme.radius.lg) {
            VStack(spacing: theme.spacing.md) {
                // Interactive Tactical Particle Field
                ZStack {
                    if colorSchemeContrast != .increased {
                        // Deep celestial background recessed block
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .fill(theme.colors.canvas.opacity(0.45))
                            .blur(radius: 0.5)
                        
                        // Micro gridlines matching capacity dimensions
                        Path { path in
                            let count = 6
                            for i in 1..<count {
                                let xOffset = CGFloat(i) * (260 / CGFloat(count))
                                path.move(to: CGPoint(x: xOffset, y: 0))
                                path.addLine(to: CGPoint(x: xOffset, y: 150))
                            }
                        }
                        .stroke(theme.colors.strokeSubtle.opacity(0.12), lineWidth: 0.5)
                        
                        if reduceMotion {
                            // Static representation of captured thought particles
                            Canvas { context, size in
                                for p in particles {
                                    let rect = CGRect(x: p.x * size.width, y: p.y * size.height, width: p.size, height: p.size)
                                    context.fill(Path(ellipseIn: rect), with: .color(p.color.opacity(0.6)))
                                }
                            }
                        } else {
                            // Real-time timeline driven particle orbit representing input mass
                            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
                                Canvas { context, size in
                                    let time = timeline.date.timeIntervalSince1970
                                    for p in particles {
                                        // Floating thought cloud orbits responding to time frequency
                                        let orbitX = sin(time * 0.4 + Double(p.id.hashValue)) * 8.0
                                        let orbitY = cos(time * 0.3 + Double(p.id.hashValue)) * 8.0
                                        
                                        var px = p.x * size.width + orbitX
                                        var py = p.y * size.height + orbitY
                                        
                                        if px < 0 { px += size.width }
                                        if px > size.width { px -= size.width }
                                        if py < 0 { py += size.height }
                                        if py > size.height { py -= size.height }
                                        
                                        let rect = CGRect(x: px, y: py, width: p.size, height: p.size)
                                        
                                        // Twinkles corresponding to focus density
                                        context.opacity = 0.45 + 0.3 * sin(time * 1.5 + Double(p.id.hashValue))
                                        context.fill(Path(ellipseIn: rect), with: .color(p.color))
                                    }
                                }
                            }
                        }
                    }
                    
                    // Centered Floating Atmosphere Organic Bubble (Highly Tactile & Drag-capable)
                    VStack(spacing: theme.spacing.xxs) {
                        Image(systemName: "lasso.and.sparkles")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [theme.colors.accentSecondary, theme.colors.accentWarm],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: theme.colors.accentSecondary.opacity(colorSchemeContrast == .increased ? 0 : 0.45), radius: 8)
                            .scaleEffect(thoughtBubbleScale)
                        
                        Text(inputText.isEmpty ? "Composer Empty" : "\(inputText.count) thought fragments")
                            .font(theme.typography.micro.weight(.semibold))
                            .foregroundStyle(inputText.isEmpty ? theme.colors.textTertiary : theme.colors.accentWarm)
                            .tracking(1.0)
                        
                        if !inputText.isEmpty {
                            Text("Drag down to place in capacity")
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textTertiary)
                                .opacity(0.8)
                        }
                    }
                    .offset(dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                guard !inputText.isEmpty else { return }
                                if !reduceMotion {
                                    dragOffset = gesture.translation
                                    thoughtBubbleScale = max(0.85, 1.0 - (gesture.translation.height / 350.0))
                                }
                            }
                            .onEnded { gesture in
                                if gesture.translation.height > 80 {
                                    // Tactile placement trigger!
                                    onCommit(inputText)
                                    inputText = ""
                                    particles.removeAll()
                                }
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    dragOffset = .zero
                                    thoughtBubbleScale = 1.0
                                }
                            }
                    )
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .strokeBorder(theme.colors.strokeSubtle.opacity(0.35), lineWidth: 0.5)
                }
                
                // Text Input Area
                TextField(placeholder, text: $inputText, axis: .vertical)
                    .font(theme.typography.bodyPrimary)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1...4)
                    .focused($isFieldFocused)
                    .padding(theme.spacing.sm)
                    .background {
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .fill(theme.colors.canvasElevated.opacity(colorSchemeContrast == .increased ? 1.0 : 0.85))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .strokeBorder(isFieldFocused ? theme.colors.accentSecondary.opacity(0.8) : theme.colors.strokeSubtle.opacity(0.35), lineWidth: 1.0)
                    }
                    .onChange(of: inputText) { oldValue, newValue in
                        // Typing text triggers micro particles!
                        if newValue.count > oldValue.count {
                            spawnParticle()
                        }
                    }
                
                // Tactical Action Controls
                HStack {
                    // Quick Clear Button
                    Button(action: {
                        inputText = ""
                        particles.removeAll()
                    }) {
                        Label("CLEAR", systemImage: "trash")
                            .font(theme.typography.micro.weight(.bold))
                            .foregroundStyle(theme.colors.textSecondary)
                            .padding(.horizontal, theme.spacing.sm)
                            .padding(.vertical, theme.spacing.xs)
                            .background {
                                Capsule().fill(theme.colors.strokeSubtle.opacity(0.12))
                            }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Commit to Meridian Button
                    Button(action: {
                        guard !inputText.isEmpty else { return }
                        onCommit(inputText)
                        inputText = ""
                        particles.removeAll()
                    }) {
                        Text("PLACE IN MERIDIAN")
                            .font(theme.typography.micro.weight(.bold))
                            .foregroundStyle(theme.colors.textInverse)
                            .padding(.horizontal, theme.spacing.md)
                            .padding(.vertical, theme.spacing.xs)
                            .background {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [theme.colors.accentPrimary, theme.colors.accentSecondary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .luminousTrace(
                                isShimmering: !inputText.isEmpty,
                                role: .route,
                                intensity: .standard,
                                showsStaticOrigin: true,
                                relationshipSummary: "Route placement trace from composer input to Meridian placement. Static origin and button label remain visible without motion."
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(inputText.isEmpty)
                    .opacity(inputText.isEmpty ? 0.45 : 1.0)
                }
            }
            .padding(theme.spacing.lg)
        }
        .onAppear {
            generateBaselineParticles()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Atmosphere Capture Composer")
        .accessibilityValue(inputText.isEmpty ? "Empty" : "Contains: \(inputText)")
    }
    
    func generateBaselineParticles() {
        var base: [ComposerParticle] = []
        let colors = [theme.colors.accentPrimary, theme.colors.accentSecondary, theme.colors.accentWarm]
        for i in 0..<12 {
            base.append(ComposerParticle(
                x: CGFloat.random(in: 0.1...0.9),
                y: CGFloat.random(in: 0.1...0.9),
                speedX: CGFloat.random(in: -0.005...0.005),
                speedY: CGFloat.random(in: -0.005...0.005),
                size: CGFloat.random(in: 2.0...4.0),
                color: colors[i % colors.count].opacity(CGFloat.random(in: 0.3...0.7))
            ))
        }
        particles = base
    }
    
    func spawnParticle() {
        guard particles.count < 35 else { return }
        let colors = [theme.colors.accentPrimary, theme.colors.accentSecondary, theme.colors.accentWarm]
        withAnimation(.easeOut(duration: 0.4)) {
            particles.append(ComposerParticle(
                x: CGFloat.random(in: 0.4...0.6),
                y: CGFloat.random(in: 0.4...0.6),
                speedX: CGFloat.random(in: -0.01...0.01),
                speedY: CGFloat.random(in: -0.01...0.01),
                size: CGFloat.random(in: 3.5...5.5),
                color: colors.randomElement()!
            ))
        }
    }
}

// MARK: - 3. TrustSeamExplainer

/// A physical-feeling explainability card representing the custom **Trust Seam**
/// defined in `PRODUCT_DESIGN_TRUTH.md`. Provides transparent calculations of local
/// algorithm confidence, details clear data sources, and allows instant overrides.
#endif
