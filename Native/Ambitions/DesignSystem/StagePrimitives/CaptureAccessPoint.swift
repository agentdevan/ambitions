import Foundation

struct CaptureAccessPoint: Equatable, Sendable {
    let title: String
    let systemImage: String
    let accessibilityLabel: String
    let accessibilityHint: String

    static let toolbar = CaptureAccessPoint(
        title: "Capture",
        systemImage: "square.and.pencil",
        accessibilityLabel: "Capture",
        accessibilityHint: "Opens the Capture composer for this surface/context."
    )

    static let activeComposer = CaptureAccessPoint(
        title: "Capture",
        systemImage: "square.and.pencil",
        accessibilityLabel: "Capture composer",
        accessibilityHint: "Capture is active for this surface."
    )

    func accessibilityIdentifier(for surface: AmbitionsSurface) -> String {
        "shell.\(surface.canonicalTopLevelTab.rawValue).capture-button"
    }
}
