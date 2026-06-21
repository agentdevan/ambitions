import AmbitionsDesignSystem
import Foundation

enum MeridianRenderer {
    static func plan(
        mode: DayRailMode,
        contextSummary: String,
        hasHeroStep: Bool,
        sourceUnavailable: Bool,
        semanticElementCount: Int
    ) -> CanvasPrimitiveRenderPlan {
        let intensity = switch mode {
        case .normal:
            0.58
        case .recovery, .protected:
            0.70
        case .overloaded:
            0.86
        case .empty, .noSchedule:
            0.34
        }

        let marks = [
            ProductMeaningCanvasMark(id: "meridian-current", intensity: intensity),
            ProductMeaningCanvasMark(id: hasHeroStep ? "meridian-start-here" : "meridian-empty", intensity: hasHeroStep ? 0.74 : 0.28),
            ProductMeaningCanvasMark(id: sourceUnavailable ? "meridian-source-review" : "meridian-source-present", intensity: sourceUnavailable ? 0.92 : 0.46),
        ]

        return CanvasPrimitiveRenderPlan(
            id: "reality-meridian-render-plan",
            objectRole: .meridian,
            engineRole: .timePressure,
            marks: marks,
            visualState: sourceUnavailable ? .warning : .selected,
            geometry: MorphGeometry.meridian(mode: mode, semanticElementCount: semanticElementCount),
            accessibilitySummary: contextSummary,
            performanceBudget: RenderPerformanceProbe.budget(for: .meridian)
        )
    }
}
