import Foundation

enum TimeAccessibility {
    static func rootSummary(for scene: TimeStageScene) -> String {
        [
            scene.stageName,
            scene.currentDateSummary,
            scene.capacitySummary,
            scene.protectedWindowSummary,
            scene.pressureSummary,
            scene.horizonSummary
        ].filter { $0.isEmpty == false }.joined(separator: ". ")
    }

    static func rootSummary(for state: TimeSurfaceState) -> String {
        [
            "Time",
            "Life Calendar",
            state.timeframeLabel,
            state.hero.dominantTruth,
            state.hero.roomSummary,
            state.hero.pressureSummary,
            state.primaryAction.title
        ].filter { $0.isEmpty == false }.joined(separator: ". ")
    }
}
