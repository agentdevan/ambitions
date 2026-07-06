import Foundation

struct TimeStageScene: Equatable, Sendable {
    let surface: StageMutationTargetSurface
    let productObject: String
    let stageName: String
    let firstViewportStructure: String
    let sourceTrustLineOrder: [String]
    let currentDateSummary: String
    let capacitySummary: String
    let protectedWindowSummary: String
    let pressureSummary: String
    let horizonSummary: String
    let captureSupportSummary: String
    let accessibilityFallbacks: [String]
    let semanticMirror: LifeShapeSemanticModel

    var satisfiesArchitectureTree: Bool {
        surface == .time &&
            productObject == "Life Calendar" &&
            firstViewportStructure.localizedCaseInsensitiveContains("capacity") &&
            firstViewportStructure.localizedCaseInsensitiveContains("protected") &&
            firstViewportStructure.localizedCaseInsensitiveContains("pressure") &&
            sourceTrustLineOrder == ["current date", "now marker", "fixed points", "capacity", "protected windows", "pressure", "horizon", "Capture"] &&
            horizonSummary.localizedCaseInsensitiveContains("day") &&
            horizonSummary.localizedCaseInsensitiveContains("week") &&
            horizonSummary.localizedCaseInsensitiveContains("month") &&
            horizonSummary.localizedCaseInsensitiveContains("year") &&
            captureSupportSummary.localizedCaseInsensitiveContains("global composer")
    }

    init(
        surface: StageMutationTargetSurface,
        productObject: String,
        stageName: String,
        firstViewportStructure: String,
        sourceTrustLineOrder: [String],
        currentDateSummary: String,
        capacitySummary: String,
        protectedWindowSummary: String,
        pressureSummary: String,
        horizonSummary: String,
        captureSupportSummary: String,
        accessibilityFallbacks: [String],
        semanticMirror: LifeShapeSemanticModel? = nil
    ) {
        self.surface = surface
        self.productObject = productObject
        self.stageName = stageName
        self.firstViewportStructure = firstViewportStructure
        self.sourceTrustLineOrder = sourceTrustLineOrder
        self.currentDateSummary = currentDateSummary
        self.capacitySummary = capacitySummary
        self.protectedWindowSummary = protectedWindowSummary
        self.pressureSummary = pressureSummary
        self.horizonSummary = horizonSummary
        self.captureSupportSummary = captureSupportSummary
        self.accessibilityFallbacks = accessibilityFallbacks
        self.semanticMirror = semanticMirror ?? LifeShapeSemanticModel(
            stageName: stageName,
            currentDateSummary: currentDateSummary,
            capacitySummary: capacitySummary,
            protectedWindowSummary: protectedWindowSummary,
            pressureSummary: pressureSummary,
            horizonSummary: horizonSummary,
            accessibilityFallbacks: accessibilityFallbacks
        )
    }
}
