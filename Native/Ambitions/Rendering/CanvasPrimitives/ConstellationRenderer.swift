import AmbitionsDesignSystem
import Foundation

enum ConstellationRenderer {
    static func plan(
        stageName: String,
        todayRelationshipSummary: String,
        inspectionSummary: String,
        accessibilityOrder: [String]
    ) -> CanvasPrimitiveRenderPlan {
        let hasProof = inspectionSummary.localizedCaseInsensitiveContains("proof")
        let relationshipCount = max(1, accessibilityOrder.count - 1)
        let marks = [
            ProductMeaningCanvasMark(id: "constellation-today-link", intensity: todayRelationshipSummary.isEmpty ? 0.36 : 0.72),
            ProductMeaningCanvasMark(id: "constellation-proof", intensity: hasProof ? 0.82 : 0.42),
            ProductMeaningCanvasMark(id: "constellation-receipt", intensity: accessibilityOrder.contains("receipt") ? 0.76 : 0.34),
        ]

        return CanvasPrimitiveRenderPlan(
            id: "constellation-atlas-render-plan",
            objectRole: .constellation,
            engineRole: .goalsRelationship,
            marks: marks,
            visualState: .selected,
            geometry: MorphGeometry.constellation(relationshipCount: relationshipCount, hasProof: hasProof),
            accessibilitySummary: "\(stageName). \(todayRelationshipSummary). \(inspectionSummary)",
            performanceBudget: RenderPerformanceProbe.budget(for: .constellation)
        )
    }
}
