import Foundation

struct ConstellationSemanticModel: Equatable {
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
            "step chain",
            "Today link",
            "Review",
        ] + Array(accessibilityFallbacks.prefix(2))

        self.stageName = stageName
        self.todayRelationshipSummary = todayRelationshipSummary
        self.inspectionSummary = inspectionSummary
        self.accessibilityOrder = accessibilityOrder
        renderPlan = ConstellationRenderer.plan(
            stageName: stageName,
            todayRelationshipSummary: todayRelationshipSummary,
            inspectionSummary: inspectionSummary,
            accessibilityOrder: accessibilityOrder
        )
    }

    var provesInspectableRelationships: Bool {
        todayRelationshipSummary.localizedCaseInsensitiveContains("Today") &&
            inspectionSummary.localizedCaseInsensitiveContains("reason") &&
            accessibilityOrder.contains("goal threads") &&
            accessibilityOrder.contains("Today link")
    }
}
