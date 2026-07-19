import Foundation

struct StageEffectRun: Equatable {
    let effects: [StageEffect]
    let visibleMutations: [StageVisibleMutationEffect]
    let accessibilityPlans: [StageAccessibilityAnnouncementEffect]
    let proofArtifacts: [StageProofArtifactEffect]
    let visibleMutationIDs: [String]
    let accessibilityAnnouncements: [String]
    let proofArtifactIDs: [String]

    init(
        effects: [StageEffect],
        visibleMutations: [StageVisibleMutationEffect] = [],
        accessibilityPlans: [StageAccessibilityAnnouncementEffect] = [],
        proofArtifacts: [StageProofArtifactEffect] = []
    ) {
        self.effects = effects
        self.visibleMutations = visibleMutations
        self.accessibilityPlans = accessibilityPlans
        self.proofArtifacts = proofArtifacts
        visibleMutationIDs = visibleMutations.map(\.id)
        accessibilityAnnouncements = accessibilityPlans.map(\.message)
        proofArtifactIDs = proofArtifacts.map(\.id)
    }

    var provesTypedObjectEffects: Bool {
        visibleMutations.allSatisfy(\.isTyped) &&
            accessibilityPlans.allSatisfy(\.isTyped) &&
            proofArtifacts.allSatisfy(\.isTyped)
    }
}

struct StageEffectRunner {
    func run(_ effects: [StageEffect]) -> StageEffectRun {
        StageEffectRun(
            effects: effects,
            visibleMutations: effects.compactMap(\.visibleMutation),
            accessibilityPlans: effects.compactMap(\.accessibilityPlan),
            proofArtifacts: effects.compactMap(\.proofArtifact)
        )
    }
}

private extension StageEffect {
    var visibleMutation: StageVisibleMutationEffect? {
        guard case let .visibleStageMutation(effect) = self else { return nil }
        return effect
    }

    var accessibilityPlan: StageAccessibilityAnnouncementEffect? {
        guard case let .accessibilityAnnouncement(effect) = self else { return nil }
        return effect
    }

    var proofArtifact: StageProofArtifactEffect? {
        guard case let .proofArtifact(effect) = self else { return nil }
        return effect
    }
}
