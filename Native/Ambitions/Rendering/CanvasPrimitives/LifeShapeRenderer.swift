import AmbitionsDesignSystem
import Foundation

enum LifeShapeRenderer {
    static func plan(
        stageName: String,
        currentDateSummary: String,
        capacitySummary: String,
        protectedWindowSummary: String,
        pressureSummary: String,
        horizonSummary: String,
        accessibilityOrder: [String]
    ) -> CanvasPrimitiveRenderPlan {
        let markInputs = [
            ("lifeshape-current-date", currentDateSummary),
            ("lifeshape-capacity", capacitySummary),
            ("lifeshape-protected-window", protectedWindowSummary),
            ("lifeshape-pressure", pressureSummary),
            ("lifeshape-horizon", horizonSummary),
        ]
        let marks = markInputs.enumerated().map { index, input in
            ProductMeaningCanvasMark(
                id: input.0,
                intensity: input.1.isEmpty ? 0.24 : 0.48 + Double(index) * 0.08
            )
        }
        let pressure = pressureSummary.localizedCaseInsensitiveContains("review") ? 0.68 : 0.50

        return CanvasPrimitiveRenderPlan(
            id: "lifeshape-field-render-plan",
            objectRole: .lifeShape,
            engineRole: .timePressure,
            marks: marks,
            visualState: .default,
            geometry: MorphGeometry.lifeShape(markCount: max(marks.count, accessibilityOrder.count), pressure: pressure),
            accessibilitySummary: "\(stageName). \(currentDateSummary). \(capacitySummary). \(protectedWindowSummary). \(pressureSummary). \(horizonSummary)",
            performanceBudget: RenderPerformanceProbe.budget(for: .lifeShape)
        )
    }
}
