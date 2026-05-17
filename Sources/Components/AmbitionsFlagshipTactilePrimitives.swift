#if canImport(SwiftUI)
import SwiftUI

// MARK: - 1. ContextCrownHeader

/// An ultra-thin, highly polished persistent navigation crown representing
/// the current focus path, active lens state, and local on-device sync pulse.
/// Adheres strictly to the "one-primary-object" layout guidelines in `PRODUCT_DESIGN_TRUTH.md`.
public struct ContextCrownHeader: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let title: String
    private let contextPhrase: String
    private let syncState: AmbitionTrustBadgeState
    
    @State private var isSyncAnimating: Bool = false
    @State private var ambientGlowPhase: Double = 0.0
    
    public init(
        title: String,
        contextPhrase: String,
        syncState: AmbitionTrustBadgeState = .localOnly
    ) {
        self.title = title
        self.contextPhrase = contextPhrase
        self.syncState = syncState
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // Focus Scope Indicator
                HStack(spacing: theme.spacing.xxs) {
                    Circle()
                        .fill(theme.colors.accentSecondary)
                        .frame(width: 6, height: 6)
                        .shadow(color: theme.colors.accentSecondary.opacity(0.4), radius: 2)
                    
                    Text(title.uppercased())
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .tracking(2.0)
                }
                
                // Micro Compass Divider Ticks mimicking physical instrument markings
                HStack(spacing: 3) {
                    ForEach(0..<5) { index in
                        Rectangle()
                            .fill(theme.colors.strokeSubtle.opacity(index == 2 ? 0.70 : 0.28))
                            .frame(width: 1, height: index == 2 ? 10 : 5)
                    }
                }
                .padding(.horizontal, theme.spacing.xs)
                
                // Context Sub-phrase
                Text(contextPhrase)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                
                Spacer()
                
                // On-Device Integrity Badge with elegant resting breathe pulse
                HStack(spacing: theme.spacing.xxs) {
                    Circle()
                        .fill(theme.colors.accentPrimary)
                        .frame(width: 5, height: 5)
                        .opacity(colorSchemeContrast == .increased ? 1.0 : (0.45 + 0.55 * sin(ambientGlowPhase)))
                        .shadow(color: theme.colors.accentPrimary.opacity(0.6), radius: 2)
                    
                    Image(systemName: syncState.systemImage)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(theme.colors.accentPrimary)
                        .rotationEffect(.degrees(isSyncAnimating ? 360 : 0))
                    
                    Text("LOCAL SYSTEM")
                        .font(theme.typography.micro.weight(.bold))
                        .foregroundStyle(theme.colors.accentPrimary)
                        .tracking(1.0)
                }
                .padding(.horizontal, theme.spacing.xs)
                .padding(.vertical, theme.spacing.xxxs)
                .background {
                    Capsule()
                        .fill(theme.colors.accentPrimary.opacity(0.10))
                }
                .overlay {
                    Capsule()
                        .strokeBorder(theme.colors.accentPrimary.opacity(0.24), lineWidth: 0.5)
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.xs)
            .background {
                if colorSchemeContrast == .increased {
                    theme.colors.canvas
                } else {
                    theme.shell.headerMaterial
                        .opacity(0.92)
                }
            }
            
            // Subtly shimmering bottom hairline stroke
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            theme.colors.strokeSubtle.opacity(0.02),
                            theme.colors.accentSecondary.opacity(0.35),
                            theme.colors.strokeSubtle.opacity(0.02)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
        .onAppear {
            if !reduceMotion {
                withAnimation(Animation.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    ambientGlowPhase = .pi
                }
                if syncState == .synced {
                    withAnimation(Animation.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                        isSyncAnimating = true
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Context Crown: \(title)")
        .accessibilityValue("\(contextPhrase). On-device status is active.")
    }
}

// MARK: - 2. AtmosphereComposerCanvas

/// A majestic, tactile thought capture canvas that converts typed text inputs
/// into floating, connected coordinate particles, simulating an organic "thought cloud"
/// which moves gracefully inside a refractive glass capsule.
public struct AtmosphereComposerCanvas: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    
    @Binding private var inputText: String
    private let placeholder: String
    private let onCommit: (String) -> Void
    
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
                            .luminousTrace(isShimmering: !inputText.isEmpty)
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
    
    private func generateBaselineParticles() {
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
    
    private func spawnParticle() {
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
public struct TrustSeamExplainer: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    
    private let title: String
    private let reason: String
    private let confidence: Double // 0.0 to 1.0
    private let source: String
    private let onOverride: () -> Void
    private let onAccept: () -> Void
    
    @State private var isDetailsExpanded: Bool = false
    
    public init(
        title: String,
        reason: String,
        confidence: Double,
        source: String,
        onOverride: @escaping () -> Void,
        onAccept: @escaping () -> Void
    ) {
        self.title = title
        self.reason = reason
        self.confidence = confidence
        self.source = source
        self.onOverride = onOverride
        self.onAccept = onAccept
    }
    
    public var body: some View {
        QuietGlass(cornerRadius: theme.radius.lg) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                // Section Header
                HStack(alignment: .center) {
                    HStack(spacing: theme.spacing.xxs) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(theme.semanticColors.trust)
                        
                        Text("TRUST SEAM")
                            .font(theme.typography.micro.weight(.bold))
                            .foregroundStyle(theme.semanticColors.trust)
                            .tracking(1.5)
                    }
                    
                    Spacer()
                    
                    // Source Stamp
                    Text(source.uppercased())
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                        .padding(.horizontal, theme.spacing.xxs)
                        .padding(.vertical, theme.spacing.xxxs)
                        .background {
                            Capsule().fill(theme.colors.strokeSubtle.opacity(0.12))
                        }
                }
                
                // Explanatory Core
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    
                    Text(reason)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Transparency Dial (Confidence Metric)
                HStack(spacing: theme.spacing.md) {
                    // Mini Gauge indicator
                    ZStack {
                        Circle()
                            .stroke(theme.colors.strokeSubtle.opacity(0.2), lineWidth: 4)
                            .frame(width: 38, height: 38)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(confidence))
                            .stroke(
                                confidenceColor,
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 38, height: 38)
                            .rotationEffect(.degrees(-90))
                        
                        Text(String(format: "%.0f%%", confidence * 100))
                            .font(theme.typography.micro.weight(.bold))
                            .foregroundStyle(theme.colors.textPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Local Alignment Fit")
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                        
                        Text("Determined entirely from local on-device habits.")
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                }
                .padding(theme.spacing.sm)
                .background {
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(theme.colors.canvasElevated.opacity(colorSchemeContrast == .increased ? 1.0 : 0.65))
                }
                
                // Expandable explanation fold-out
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isDetailsExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("WHY THIS RECOMMENDATION?")
                                .font(theme.typography.micro.weight(.bold))
                                .foregroundStyle(theme.colors.accentSecondary)
                            
                            Spacer()
                            
                            Image(systemName: isDetailsExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(theme.colors.accentSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    if isDetailsExpanded {
                        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                            Text("1. Historical patterns: You typically close health commitments in the morning.")
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textSecondary)
                            
                            Text("2. Capacity check: Active time blocks show 35 minutes of free headroom.")
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textSecondary)
                            
                            Text("3. Non-shaming reflow: Designed to preserve momentum without forcing strict clock deadlines.")
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 4)
                
                Divider()
                    .background(theme.colors.strokeSubtle)
                
                // Command Override Actions
                HStack(spacing: theme.spacing.sm) {
                    Button(action: onOverride) {
                        Text("ADJUST PROFILE")
                            .font(theme.typography.micro.weight(.bold))
                            .foregroundStyle(theme.colors.textSecondary)
                            .padding(.vertical, theme.spacing.xs)
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                                    .stroke(theme.colors.strokeStrong, lineWidth: 1.0)
                            }
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onAccept) {
                        Text("TRUST DECISION")
                            .font(theme.typography.micro.weight(.bold))
                            .foregroundStyle(theme.colors.textInverse)
                            .padding(.vertical, theme.spacing.xs)
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                                    .fill(theme.semanticColors.trust)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(theme.spacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Trust Seam explanation card")
        .accessibilityValue("Why this recommended action exists: \(reason). Local alignment fit is \(Int(confidence * 100)) percent.")
    }
    
    private var confidenceColor: Color {
        if confidence >= 0.8 {
            return theme.semanticColors.confidenceHigh
        } else if confidence >= 0.5 {
            return theme.semanticColors.confidenceMedium
        } else {
            return theme.semanticColors.confidenceLow
        }
    }
}
#endif
