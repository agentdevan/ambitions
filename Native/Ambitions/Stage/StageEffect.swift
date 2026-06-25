import Foundation

enum StageEffect: Equatable {
    case visibleStageMutation(StageVisibleMutationEffect)
    case accessibilityAnnouncement(StageAccessibilityAnnouncementEffect)
    case proofArtifact(StageProofArtifactEffect)

    static func surfaceChanged(to surface: AmbitionsSurface) -> [StageEffect] {
        let objectID = "surface.\(surface.rawValue)"
        return [
            StageEffect.visibleObjectMutation(
                id: "\(objectID).selected",
                affectedObjectIDs: [objectID],
                consequence: "\(surface.title) selected"
            ),
            StageEffect.announcement(
                id: "\(objectID).selected.announcement",
                message: "\(surface.title) selected",
                affectedObjectIDs: [objectID]
            ),
            StageEffect.proofReference(
                id: "stage.surface.\(surface.rawValue)",
                affectedObjectIDs: [objectID],
                inspectionTarget: "\(objectID).history"
            )
        ]
    }

    static func overlayChanged(_ overlay: ShellOverlayState?) -> [StageEffect] {
        guard let overlay else {
            let objectID = "overlay.none"
            return [
                StageEffect.visibleObjectMutation(
                    id: "stage.overlay.dismissed.visible",
                    affectedObjectIDs: [objectID],
                    consequence: "Overlay dismissed"
                ),
                StageEffect.announcement(
                    id: "stage.overlay.dismissed.announcement",
                    message: "Overlay dismissed",
                    affectedObjectIDs: [objectID]
                ),
                StageEffect.proofReference(
                    id: "stage.overlay.dismissed",
                    affectedObjectIDs: [objectID],
                    inspectionTarget: "stage.overlay.history"
                )
            ]
        }

        let objectID = "overlay.\(overlay.kind.id)"
        return [
            StageEffect.visibleObjectMutation(
                id: "\(objectID).presented",
                affectedObjectIDs: [objectID],
                consequence: overlay.intent?.title ?? overlay.kind.id
            ),
            StageEffect.announcement(
                id: "\(objectID).presented.announcement",
                message: overlay.intent?.title ?? overlay.kind.id,
                affectedObjectIDs: [objectID]
            ),
            StageEffect.proofReference(
                id: "stage.overlay.\(overlay.kind.id)",
                affectedObjectIDs: [objectID],
                inspectionTarget: "\(objectID).history"
            )
        ]
    }

    static func visibleObjectMutation(
        id: String,
        affectedObjectIDs: [String],
        consequence: String
    ) -> StageEffect {
        .visibleStageMutation(
            StageVisibleMutationEffect(
                id: id,
                affectedObjectIDs: affectedObjectIDs,
                consequence: consequence
            )
        )
    }

    static func announcement(
        id: String,
        message: String,
        affectedObjectIDs: [String]
    ) -> StageEffect {
        .accessibilityAnnouncement(
            StageAccessibilityAnnouncementEffect(
                id: id,
                message: message,
                affectedObjectIDs: affectedObjectIDs
            )
        )
    }

    static func proofReference(
        id: String,
        affectedObjectIDs: [String],
        inspectionTarget: String
    ) -> StageEffect {
        .proofArtifact(
            StageProofArtifactEffect(
                id: id,
                affectedObjectIDs: affectedObjectIDs,
                inspectionTarget: inspectionTarget,
                localOnly: true
            )
        )
    }
}

struct StageVisibleMutationEffect: Equatable, Sendable {
    let id: String
    let affectedObjectIDs: [String]
    let consequence: String

    var isTyped: Bool {
        id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            affectedObjectIDs.isEmpty == false &&
            consequence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}

struct StageAccessibilityAnnouncementEffect: Equatable, Sendable {
    let id: String
    let message: String
    let affectedObjectIDs: [String]

    var isTyped: Bool {
        id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            affectedObjectIDs.isEmpty == false
    }
}

struct StageProofArtifactEffect: Equatable, Sendable {
    let id: String
    let affectedObjectIDs: [String]
    let inspectionTarget: String
    let localOnly: Bool

    var isTyped: Bool {
        id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            affectedObjectIDs.isEmpty == false &&
            inspectionTarget.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            localOnly
    }
}
