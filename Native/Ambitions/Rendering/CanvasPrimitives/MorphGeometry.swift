import CoreGraphics
import Foundation

struct MorphGeometry: Equatable, Sendable {
    let leadingAnchor: MorphGeometryPoint
    let trailingAnchor: MorphGeometryPoint
    let controlAnchor: MorphGeometryPoint
    let expansion: Double
    let curvature: Double

    static func meridian(mode: DayRailMode, semanticElementCount: Int) -> MorphGeometry {
        let pressure = switch mode {
        case .normal:
            0.42
        case .recovery, .protected:
            0.56
        case .overloaded:
            0.72
        case .empty, .noSchedule:
            0.30
        }

        return MorphGeometry(
            leadingAnchor: MorphGeometryPoint(x: 0.12, y: 0.18),
            trailingAnchor: MorphGeometryPoint(x: 0.88, y: 0.78),
            controlAnchor: MorphGeometryPoint(x: 0.48, y: min(0.82, 0.26 + Double(semanticElementCount) * 0.045)),
            expansion: pressure,
            curvature: 0.34 + pressure * 0.38
        )
    }

    static func constellation(relationshipCount: Int, hasProof: Bool) -> MorphGeometry {
        let density = min(1, Double(max(relationshipCount, 1)) / 8)
        return MorphGeometry(
            leadingAnchor: MorphGeometryPoint(x: 0.10, y: hasProof ? 0.22 : 0.28),
            trailingAnchor: MorphGeometryPoint(x: 0.92, y: 0.82),
            controlAnchor: MorphGeometryPoint(x: 0.52, y: 0.12 + density * 0.26),
            expansion: 0.46 + density * 0.36,
            curvature: hasProof ? 0.72 : 0.54
        )
    }

    static func lifeShape(markCount: Int, pressure: Double) -> MorphGeometry {
        let density = min(1, Double(max(markCount, 1)) / 12)
        let normalizedPressure = pressure.clamped(to: 0...1)
        return MorphGeometry(
            leadingAnchor: MorphGeometryPoint(x: 0.08, y: 0.16 + normalizedPressure * 0.14),
            trailingAnchor: MorphGeometryPoint(x: 0.88, y: 0.28 + density * 0.52),
            controlAnchor: MorphGeometryPoint(x: 0.42, y: 0.20 + normalizedPressure * 0.44),
            expansion: max(density, normalizedPressure),
            curvature: 0.48 + normalizedPressure * 0.34
        )
    }

    func point(in size: CGSize, at progress: Double) -> CGPoint {
        let t = progress.clamped(to: 0...1)
        let inverse = 1 - t
        let x = inverse * inverse * leadingAnchor.x + 2 * inverse * t * controlAnchor.x + t * t * trailingAnchor.x
        let y = inverse * inverse * leadingAnchor.y + 2 * inverse * t * controlAnchor.y + t * t * trailingAnchor.y
        return CGPoint(x: size.width * x, y: size.height * y)
    }
}

struct MorphGeometryPoint: Equatable, Sendable {
    let x: Double
    let y: Double

    init(x: Double, y: Double) {
        self.x = x.clamped(to: 0...1)
        self.y = y.clamped(to: 0...1)
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
