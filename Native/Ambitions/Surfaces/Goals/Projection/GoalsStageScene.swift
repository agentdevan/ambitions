import Foundation

struct GoalsStageScene: Equatable {
    let surface: StageMutationTargetSurface
    let productObject: String
    let stageName: String
    let firstViewportStructure: String
    let sourceTrustLineOrder: [String]
    let todayRelationshipSummary: String
    let inspectionSummary: String
    let accessibilityFallbacks: [String]
    let semanticMirror: ConstellationSemanticModel

    var satisfiesArchitectureTree: Bool {
        surface == .goals &&
            productObject.localizedCaseInsensitiveContains("Life Area Atlas") &&
            firstViewportStructure.localizedCaseInsensitiveContains("life-area") &&
            firstViewportStructure.localizedCaseInsensitiveContains("Today") &&
            sourceTrustLineOrder == ["life area", "goal thread", "step chain", "Today link"] &&
            todayRelationshipSummary.localizedCaseInsensitiveContains("Today") &&
            inspectionSummary.localizedCaseInsensitiveContains("reason")
    }

    init(
        surface: StageMutationTargetSurface,
        productObject: String,
        stageName: String,
        firstViewportStructure: String,
        sourceTrustLineOrder: [String],
        todayRelationshipSummary: String,
        inspectionSummary: String,
        accessibilityFallbacks: [String],
        semanticMirror: ConstellationSemanticModel? = nil
    ) {
        self.surface = surface
        self.productObject = productObject
        self.stageName = stageName
        self.firstViewportStructure = firstViewportStructure
        self.sourceTrustLineOrder = sourceTrustLineOrder
        self.todayRelationshipSummary = todayRelationshipSummary
        self.inspectionSummary = inspectionSummary
        self.accessibilityFallbacks = accessibilityFallbacks
        self.semanticMirror = semanticMirror ?? ConstellationSemanticModel(
            stageName: stageName,
            todayRelationshipSummary: todayRelationshipSummary,
            inspectionSummary: inspectionSummary,
            accessibilityFallbacks: accessibilityFallbacks
        )
    }
}
