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

    var satisfiesArchitectureTree: Bool {
        surface == .time &&
            productObject == "LifeShape Field" &&
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
}
