import Foundation

struct GoalsStageScene: Equatable, Sendable {
    let surface: StageMutationTargetSurface
    let productObject: String
    let stageName: String
    let firstViewportStructure: String
    let sourceTrustLineOrder: [String]
    let todayRelationshipSummary: String
    let inspectionSummary: String
    let accessibilityFallbacks: [String]

    var satisfiesArchitectureTree: Bool {
        surface == .goals &&
            productObject.localizedCaseInsensitiveContains("Constellation Atlas") &&
            firstViewportStructure.localizedCaseInsensitiveContains("life-area") &&
            firstViewportStructure.localizedCaseInsensitiveContains("Today") &&
            sourceTrustLineOrder == ["life area", "source", "proof", "receipt", "Today link"] &&
            todayRelationshipSummary.localizedCaseInsensitiveContains("Today") &&
            inspectionSummary.localizedCaseInsensitiveContains("proof")
    }
}
