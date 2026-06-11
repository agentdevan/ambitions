#if canImport(SwiftUI)
import SwiftUI

public struct ProductMeaningCanvasEngineContract: Equatable, Sendable {
    public let primitiveID: String
    public let ownerSurfaces: [String]
    public let productObjects: [String]
    public let screenshotIdentifier: String
    public let reuseRequirement: String
    public let fallbackRequirement: String
    public let performanceNotes: [String]
    public let replacesStructures: [String]

    public static let current = ProductMeaningCanvasEngineContract(
        primitiveID: "canvas-engines-static-fallbacks",
        ownerSurfaces: ["Goals", "Time", "Motion"],
        productObjects: [
            "Constellation Atlas relationship contour",
            "LifeShape pressure contour",
            "Motion proof-thread contour"
        ],
        screenshotIdentifier: "ProductMeaningCanvasEngine",
        reuseRequirement: "Promote Canvas only where an existing contour carries source, relationship, pressure, proof, or receipt meaning.",
        fallbackRequirement: "Reduce Motion uses deterministic Shape strokes instead of Canvas rendering or animation-only meaning.",
        performanceNotes: [
            "No TimelineView loop is introduced by this engine.",
            "Each engine draws one reusable path or the bounded LifeShape semantic mark count.",
            "Canvas layers are non-interactive and accessibility-hidden because adjacent text owns the semantic meaning.",
            "Reduce Motion switches to static Shape strokes with the same path geometry."
        ],
        replacesStructures: [
            "Goals inline atlas relationship Canvas",
            "Time inline LifeShape pressure Canvas",
            "Motion inline proof-thread Canvas"
        ]
    )
}

public enum ProductMeaningCanvasRole: String, CaseIterable, Identifiable, Sendable {
    case goalsRelationship
    case timePressure
    case motionProofThread

    public var id: String { rawValue }

    public var productMeaning: String {
        switch self {
        case .goalsRelationship:
            "Direction Atlas relationship contour"
        case .timePressure:
            "LifeShape pressure contour"
        case .motionProofThread:
            "Motion proof-thread contour"
        }
    }

    public var fallbackSummary: String {
        switch self {
        case .goalsRelationship:
            "Static relationship curve preserves source, proof, receipt, and Today linkage."
        case .timePressure:
            "Static pressure strokes preserve capacity and protected-time shape."
        case .motionProofThread:
            "Static proof thread preserves Source, Proof, Receipt, and reason direction."
        }
    }

    public var defaultVisualState: AmbitionVisualState {
        switch self {
        case .goalsRelationship, .motionProofThread:
            .selected
        case .timePressure:
            .default
        }
    }
}

public struct ProductMeaningCanvasMark: Identifiable, Sendable, Hashable {
    public let id: String
    public let intensity: Double

    public init(id: String, intensity: Double) {
        self.id = id
        self.intensity = min(max(intensity, 0), 1)
    }
}

public struct ProductMeaningCanvasEngine: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private let role: ProductMeaningCanvasRole
    private let marks: [ProductMeaningCanvasMark]
    private let visualState: AmbitionVisualState?
    private let accessibilityIdentifier: String?

    public init(
        role: ProductMeaningCanvasRole,
        marks: [ProductMeaningCanvasMark] = [],
        visualState: AmbitionVisualState? = nil,
        accessibilityIdentifier: String? = nil
    ) {
        self.role = role
        self.marks = marks
        self.visualState = visualState
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public var body: some View {
        let resolvedState = visualState ?? role.defaultVisualState
        let style = theme.stateStyle(for: resolvedState)
        let accent = style.accent

        ZStack {
            LinearGradient(
                colors: gradientColors(accent: accent),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if reduceMotion {
                staticFallback(accent: accent)
            } else {
                canvasLayer(accent: accent)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .modifier(ProductMeaningCanvasIdentifierModifier(identifier: accessibilityIdentifier))
    }

    private var resolvedMarks: [ProductMeaningCanvasMark] {
        if marks.isEmpty {
            [ProductMeaningCanvasMark(id: "\(role.rawValue)-primary", intensity: 0.72)]
        } else {
            marks
        }
    }

    private func gradientColors(accent: Color) -> [Color] {
        switch role {
        case .goalsRelationship:
            [
                .clear,
                theme.colors.surfacePrimary.opacity(reduceTransparency ? 0.48 : 0.32),
                accent.opacity(colorSchemeContrast == .increased ? 0.20 : 0.12),
                .clear
            ]
        case .timePressure:
            [
                .clear,
                theme.colors.canvasElevated.opacity(reduceTransparency ? 0.68 : 0.42),
                accent.opacity(colorSchemeContrast == .increased ? 0.26 : 0.18),
                .clear
            ]
        case .motionProofThread:
            [
                .clear,
                theme.colors.surfacePrimary.opacity(reduceTransparency ? 0.72 : 0.30),
                accent.opacity(colorSchemeContrast == .increased ? 0.22 : 0.16),
                .clear
            ]
        }
    }

    private func canvasLayer(accent: Color) -> some View {
        Canvas { context, size in
            for (index, mark) in resolvedMarks.enumerated() {
                let path = productMeaningCanvasPath(for: role, mark: mark, index: index, size: size)
                context.stroke(
                    path,
                    with: .color(accent.opacity(strokeOpacity(for: mark, index: index))),
                    lineWidth: strokeWidth
                )
            }
        }
    }

    private func staticFallback(accent: Color) -> some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(resolvedMarks.enumerated()), id: \.element.id) { index, mark in
                    ProductMeaningCanvasFallbackStroke(role: role, mark: mark, index: index)
                        .stroke(
                            accent.opacity(strokeOpacity(for: mark, index: index)),
                            style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round)
                        )
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var strokeWidth: CGFloat {
        switch role {
        case .goalsRelationship:
            colorSchemeContrast == .increased ? 2.0 : 1.25
        case .timePressure:
            colorSchemeContrast == .increased ? 2.2 : 1.4
        case .motionProofThread:
            colorSchemeContrast == .increased ? 2.0 : 1.4
        }
    }

    private func strokeOpacity(for mark: ProductMeaningCanvasMark, index: Int) -> Double {
        switch role {
        case .goalsRelationship:
            colorSchemeContrast == .increased ? 0.28 : 0.16
        case .timePressure:
            0.08 + mark.intensity * (colorSchemeContrast == .increased ? 0.24 : 0.18)
        case .motionProofThread:
            colorSchemeContrast == .increased ? 0.30 : 0.18
        }
    }
}

private struct ProductMeaningCanvasFallbackStroke: Shape {
    let role: ProductMeaningCanvasRole
    let mark: ProductMeaningCanvasMark
    let index: Int

    func path(in rect: CGRect) -> Path {
        productMeaningCanvasPath(for: role, mark: mark, index: index, size: rect.size)
    }
}

private func productMeaningCanvasPath(
    for role: ProductMeaningCanvasRole,
    mark: ProductMeaningCanvasMark,
    index: Int,
    size: CGSize
) -> Path {
    switch role {
    case .goalsRelationship:
        Path { path in
            path.move(to: CGPoint(x: size.width * 0.12, y: size.height * 0.20))
            path.addCurve(
                to: CGPoint(x: size.width * 0.92, y: size.height * 0.82),
                control1: CGPoint(x: size.width * 0.38, y: size.height * 0.04),
                control2: CGPoint(x: size.width * 0.58, y: size.height * 0.96)
            )
        }
    case .timePressure:
        Path { path in
            let y = size.height * (0.15 + CGFloat(index % 6) * 0.12)
            let start = CGPoint(x: size.width * 0.08, y: y)
            let end = CGPoint(
                x: size.width * (0.38 + CGFloat(mark.intensity) * 0.50),
                y: y + CGFloat(index % 2 == 0 ? 12 : -10)
            )
            path.move(to: start)
            path.addQuadCurve(
                to: end,
                control: CGPoint(x: size.width * 0.42, y: y + CGFloat(index % 3 - 1) * 24)
            )
        }
    case .motionProofThread:
        Path { path in
            path.move(to: CGPoint(x: size.width * 0.10, y: size.height * 0.22))
            path.addCurve(
                to: CGPoint(x: size.width * 0.90, y: size.height * 0.78),
                control1: CGPoint(x: size.width * 0.36, y: size.height * 0.10),
                control2: CGPoint(x: size.width * 0.62, y: size.height * 0.92)
            )
        }
    }
}

private struct ProductMeaningCanvasIdentifierModifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}
#endif
