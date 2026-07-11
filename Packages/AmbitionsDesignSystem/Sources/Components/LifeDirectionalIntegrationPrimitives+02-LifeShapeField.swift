#if canImport(SwiftUI)
import SwiftUI

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
    
    func staticCanvas(size: CGSize) -> some View {
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
    
    func animatedCanvas(size: CGSize, date: Double) -> some View {
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
    
    let levels: [Double] // allocation ratio for: sage (0), blueGray (1), warmGold (2)
    
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
    
    func allocationRow(label: String, ratio: Double, color: Color) -> some View {
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
