import Foundation

struct ReduceTransparencyPolicy: Equatable, Sendable {
    enum SurfaceMaterial: String, Equatable, Sendable {
        case glass
        case solid
        case outlined
    }

    let normalMaterial: SurfaceMaterial
    let reducedMaterial: SurfaceMaterial
    let preservesDepthMeaningWithText: Bool
    let keepsTrustSeamVisible: Bool

    func material(reduceTransparency: Bool) -> SurfaceMaterial {
        reduceTransparency ? reducedMaterial : normalMaterial
    }

    static let legibleSurface = ReduceTransparencyPolicy(
        normalMaterial: .glass,
        reducedMaterial: .solid,
        preservesDepthMeaningWithText: true,
        keepsTrustSeamVisible: true
    )
}
