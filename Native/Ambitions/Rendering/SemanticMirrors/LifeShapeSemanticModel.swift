import Foundation

struct LifeShapeSemanticModel: Equatable, Sendable {
    let stageName: String
    let currentDateSummary: String
    let capacitySummary: String
    let protectedWindowSummary: String
    let pressureSummary: String
    let horizonSummary: String
    let accessibilityOrder: [String]

    init(
        stageName: String,
        currentDateSummary: String,
        capacitySummary: String,
        protectedWindowSummary: String,
        pressureSummary: String,
        horizonSummary: String,
        accessibilityFallbacks: [String]
    ) {
        self.stageName = stageName
        self.currentDateSummary = currentDateSummary
        self.capacitySummary = capacitySummary
        self.protectedWindowSummary = protectedWindowSummary
        self.pressureSummary = pressureSummary
        self.horizonSummary = horizonSummary
        self.accessibilityOrder = [
            stageName,
            "current date",
            "capacity",
            "protected windows",
            "pressure",
            "horizon",
            "source",
            "receipt",
        ] + Array(accessibilityFallbacks.prefix(2))
    }

    var provesTimeObjectSemantics: Bool {
        stageName == UserFacingLanguage.Object.lifeShapeField &&
            capacitySummary.isEmpty == false &&
            protectedWindowSummary.isEmpty == false &&
            pressureSummary.isEmpty == false &&
            horizonSummary.localizedCaseInsensitiveContains("week")
    }
}
