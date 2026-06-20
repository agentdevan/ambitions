import Foundation

struct StageEffectRun: Equatable {
    let effects: [StageEffect]
    let visibleMutationIDs: [String]
    let accessibilityAnnouncements: [String]
    let proofArtifactIDs: [String]
}

struct StageEffectRunner {
    func run(_ effects: [StageEffect]) -> StageEffectRun {
        StageEffectRun(
            effects: effects,
            visibleMutationIDs: effects.compactMap(\.visibleMutationID),
            accessibilityAnnouncements: effects.compactMap(\.accessibilityAnnouncement),
            proofArtifactIDs: effects.compactMap(\.proofArtifactID)
        )
    }
}

private extension StageEffect {
    var visibleMutationID: String? {
        guard case let .visibleStageMutation(id) = self else { return nil }
        return id
    }

    var accessibilityAnnouncement: String? {
        guard case let .accessibilityAnnouncement(announcement) = self else { return nil }
        return announcement
    }

    var proofArtifactID: String? {
        guard case let .proofArtifact(id) = self else { return nil }
        return id
    }
}
