import Foundation

struct ConstellationSemanticModel: Equatable, Sendable {
    let stageName: String
    let todayRelationshipSummary: String
    let inspectionSummary: String
    let accessibilityOrder: [String]
    let renderPlan: CanvasPrimitiveRenderPlan

    init(
        stageName: String,
        todayRelationshipSummary: String,
        inspectionSummary: String,
        accessibilityFallbacks: [String]
    ) {
        let accessibilityOrder = [
            stageName,
            "life areas",
            "goal threads",
            "Today link",
            "source",
            "proof",
            "receipt",
        ] + Array(accessibilityFallbacks.prefix(2))

        self.stageName = stageName
        self.todayRelationshipSummary = todayRelationshipSummary
        self.inspectionSummary = inspectionSummary
        self.accessibilityOrder = accessibilityOrder
        self.renderPlan = ConstellationRenderer.plan(
            stageName: stageName,
            todayRelationshipSummary: todayRelationshipSummary,
            inspectionSummary: inspectionSummary,
            accessibilityOrder: accessibilityOrder
        )
    }

    var provesInspectableRelationships: Bool {
        todayRelationshipSummary.localizedCaseInsensitiveContains("Today") &&
            inspectionSummary.localizedCaseInsensitiveContains("proof") &&
            accessibilityOrder.contains("receipt")
    }
}
