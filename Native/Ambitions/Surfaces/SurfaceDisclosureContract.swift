import Foundation

struct SurfaceDisclosureContract: Hashable, Sendable {
    let surface: AmbitionsSurface
    let rootDisclosureLimit: Int
    let detailLayers: [String]
    let trustDetailsAreInspectable: Bool

    var satisfiesRootLaw: Bool {
        rootDisclosureLimit <= 1 && trustDetailsAreInspectable
    }

    static func contract(for surface: AmbitionsSurface) -> SurfaceDisclosureContract {
        SurfaceDisclosureContract(
            surface: surface,
            rootDisclosureLimit: 1,
            detailLayers: ["Proof", "Source", "Privacy", "History", "Receipts"],
            trustDetailsAreInspectable: true
        )
    }
}
