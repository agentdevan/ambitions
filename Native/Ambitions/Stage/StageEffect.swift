import Foundation

enum StageEffect: Equatable {
    case visibleStageMutation(String)
    case accessibilityAnnouncement(String)
    case proofArtifact(String)

    static func surfaceChanged(to surface: AmbitionsSurface) -> [StageEffect] {
        [
            .visibleStageMutation("surface:\(surface.rawValue)"),
            .accessibilityAnnouncement("\(surface.title) selected"),
            .proofArtifact("stage.surface.\(surface.rawValue)")
        ]
    }

    static func overlayChanged(_ overlay: ShellOverlayState?) -> [StageEffect] {
        guard let overlay else {
            return [
                .visibleStageMutation("overlay:none"),
                .accessibilityAnnouncement("Overlay dismissed"),
                .proofArtifact("stage.overlay.dismissed")
            ]
        }

        return [
            .visibleStageMutation("overlay:\(overlay.kind.id)"),
            .accessibilityAnnouncement(overlay.intent?.title ?? overlay.kind.id),
            .proofArtifact("stage.overlay.\(overlay.kind.id)")
        ]
    }
}
