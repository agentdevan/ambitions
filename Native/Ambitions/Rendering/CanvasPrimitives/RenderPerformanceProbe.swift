import AmbitionsDesignSystem
import Foundation

enum CanvasPrimitiveObjectRole: String, CaseIterable, Sendable {
    case meridian
    case constellation
    case lifeShape
    case motionCurrent
}

struct CanvasPrimitiveRenderPlan: Equatable, Sendable {
    let id: String
    let objectRole: CanvasPrimitiveObjectRole
    let engineRole: ProductMeaningCanvasRole
    let marks: [ProductMeaningCanvasMark]
    let visualState: AmbitionVisualState
    let geometry: MorphGeometry
    let accessibilitySummary: String
    let performanceBudget: RenderPerformanceBudget

    var performanceReport: RenderPerformanceReport {
        RenderPerformanceProbe.evaluate(self)
    }
}

struct RenderPerformanceBudget: Equatable, Sendable {
    let maxMarks: Int
    let maxEstimatedMilliseconds: Double
    let permitsTimelineLoop: Bool
    let requiresSemanticMirror: Bool
}

struct RenderPerformanceReport: Equatable, Sendable {
    let markCount: Int
    let estimatedMilliseconds: Double
    let semanticMirrorPresent: Bool
    let isWithinBudget: Bool
}

enum RenderPerformanceProbe {
    static func budget(for role: CanvasPrimitiveObjectRole) -> RenderPerformanceBudget {
        switch role {
        case .meridian:
            RenderPerformanceBudget(
                maxMarks: 3,
                maxEstimatedMilliseconds: 0.45,
                permitsTimelineLoop: false,
                requiresSemanticMirror: true
            )
        case .constellation:
            RenderPerformanceBudget(
                maxMarks: 6,
                maxEstimatedMilliseconds: 0.70,
                permitsTimelineLoop: false,
                requiresSemanticMirror: true
            )
        case .lifeShape:
            RenderPerformanceBudget(
                maxMarks: 12,
                maxEstimatedMilliseconds: 1.10,
                permitsTimelineLoop: false,
                requiresSemanticMirror: true
            )
        case .motionCurrent:
            RenderPerformanceBudget(
                maxMarks: 8,
                maxEstimatedMilliseconds: 0.90,
                permitsTimelineLoop: false,
                requiresSemanticMirror: true
            )
        }
    }

    static func evaluate(_ plan: CanvasPrimitiveRenderPlan) -> RenderPerformanceReport {
        let estimatedMilliseconds = 0.18 + Double(plan.marks.count) * 0.07 + plan.geometry.expansion * 0.12
        let semanticMirrorPresent = plan.accessibilitySummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        let isWithinBudget = plan.marks.count <= plan.performanceBudget.maxMarks &&
            estimatedMilliseconds <= plan.performanceBudget.maxEstimatedMilliseconds &&
            plan.performanceBudget.permitsTimelineLoop == false &&
            (plan.performanceBudget.requiresSemanticMirror == false || semanticMirrorPresent)

        return RenderPerformanceReport(
            markCount: plan.marks.count,
            estimatedMilliseconds: estimatedMilliseconds,
            semanticMirrorPresent: semanticMirrorPresent,
            isWithinBudget: isWithinBudget
        )
    }
}
