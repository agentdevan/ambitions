import SwiftUI

struct TimeObjectView: View {
    let timeState: TimeSurfaceState
    let onReflowDecision: ((TimeReflowDecisionOptionState, TimeReflowDecisionActionKind) -> Void)?

    var body: some View {
        let scene = TimeLens.makeStageScene(for: timeState)
        LifeShapeFieldView(
            suite: timeState.lifeSuite,
            reflowDecision: timeState.reflowDecision,
            reflowReceiptPreview: timeState.reflowReceiptPreview,
            calendarAwareness: timeState.calendarAwareness,
            onReflowDecision: onReflowDecision
        )
        .accessibilityHint(scene.satisfiesArchitectureTree
            ? "Current date, now, fixed points, open capacity, protected windows, pressure, horizons, and Capture support stay available."
            : "Time shape stays available for review.")
    }
}
