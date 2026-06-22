import SwiftUI

struct TimeObjectView: View {
    let timeState: TimeSurfaceState
    let clock: any AmbitionsClock
    let onReflowDecision: ((TimeReflowDecisionOptionState, TimeReflowDecisionActionKind) -> Void)?
    let onSearch: (() -> Void)?
    let onCapture: (() -> Void)?
    let visibleMutation: UserVisibleMutation?
    let onMutationAction: ((TimeFieldMutationAction, LifeShapeSemanticMark?) -> Void)?
    let onUndoMutation: (() -> Void)?

    init(
        timeState: TimeSurfaceState,
        clock: any AmbitionsClock,
        onReflowDecision: ((TimeReflowDecisionOptionState, TimeReflowDecisionActionKind) -> Void)? = nil,
        onSearch: (() -> Void)? = nil,
        onCapture: (() -> Void)? = nil,
        visibleMutation: UserVisibleMutation? = nil,
        onMutationAction: ((TimeFieldMutationAction, LifeShapeSemanticMark?) -> Void)? = nil,
        onUndoMutation: (() -> Void)? = nil
    ) {
        self.timeState = timeState
        self.clock = clock
        self.onReflowDecision = onReflowDecision
        self.onSearch = onSearch
        self.onCapture = onCapture
        self.visibleMutation = visibleMutation
        self.onMutationAction = onMutationAction
        self.onUndoMutation = onUndoMutation
    }

    var body: some View {
        let scene = TimeLens.makeStageScene(for: timeState, clock: clock)
        LifeShapeFieldView(
            suite: timeState.lifeSuite,
            reflowDecision: timeState.reflowDecision,
            reflowReceiptPreview: timeState.reflowReceiptPreview,
            calendarAwareness: timeState.calendarAwareness,
            onReflowDecision: onReflowDecision,
            onSearch: onSearch,
            onCapture: onCapture,
            visibleMutation: visibleMutation,
            onMutationAction: onMutationAction,
            onUndoMutation: onUndoMutation
        )
        .accessibilityHint(scene.satisfiesArchitectureTree
            ? "Current date, now, fixed points, open capacity, protected windows, pressure, horizons, and Capture support stay available."
            : "Time shape stays available for review.")
    }
}
