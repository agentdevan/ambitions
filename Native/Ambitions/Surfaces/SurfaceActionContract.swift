import Foundation

struct SurfaceActionContract: Hashable, Sendable {
    let surface: AmbitionsSurface
    let primaryActionTitle: String
    let requiresRuntimeMutation: Bool
    let requiresVisibleMutation: Bool
    let requiresAccessibilityAnnouncement: Bool
    let requiresProofArtifact: Bool

    var isComplete: Bool {
        requiresRuntimeMutation &&
            requiresVisibleMutation &&
            requiresAccessibilityAnnouncement &&
            requiresProofArtifact
    }

    static func contract(for surface: AmbitionsSurface) -> SurfaceActionContract {
        switch surface {
        case .today:
            SurfaceActionContract(surface: surface, primaryActionTitle: "Start now", requiresRuntimeMutation: true, requiresVisibleMutation: true, requiresAccessibilityAnnouncement: true, requiresProofArtifact: true)
        case .goals:
            SurfaceActionContract(surface: surface, primaryActionTitle: "Create Goal", requiresRuntimeMutation: true, requiresVisibleMutation: true, requiresAccessibilityAnnouncement: true, requiresProofArtifact: true)
        case .time:
            SurfaceActionContract(surface: surface, primaryActionTitle: "Move it", requiresRuntimeMutation: true, requiresVisibleMutation: true, requiresAccessibilityAnnouncement: true, requiresProofArtifact: true)
        case .you:
            SurfaceActionContract(surface: surface, primaryActionTitle: "Review", requiresRuntimeMutation: true, requiresVisibleMutation: true, requiresAccessibilityAnnouncement: true, requiresProofArtifact: true)
        }
    }
}
