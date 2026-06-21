import Foundation

struct ConstellationSemanticModel: Equatable, Sendable {
    let stageName: String
    let todayRelationshipSummary: String
    let inspectionSummary: String
    let accessibilityOrder: [String]

    init(
        stageName: String,
        todayRelationshipSummary: String,
        inspectionSummary: String,
        accessibilityFallbacks: [String]
    ) {
        self.stageName = stageName
        self.todayRelationshipSummary = todayRelationshipSummary
        self.inspectionSummary = inspectionSummary
        self.accessibilityOrder = [
            stageName,
            "life areas",
            "goal threads",
            "Today link",
            "source",
            "proof",
            "receipt",
        ] + Array(accessibilityFallbacks.prefix(2))
    }

    var provesInspectableRelationships: Bool {
        todayRelationshipSummary.localizedCaseInsensitiveContains("Today") &&
            inspectionSummary.localizedCaseInsensitiveContains("proof") &&
            accessibilityOrder.contains("receipt")
    }
}
