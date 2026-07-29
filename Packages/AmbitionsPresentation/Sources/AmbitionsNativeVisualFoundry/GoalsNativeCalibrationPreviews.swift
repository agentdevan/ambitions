import SwiftUI

private enum GoalsNativeCalibrationPreviewDepth {
    case root
    case home
    case focused
    case path
}

private struct GoalsNativeCalibrationPreviewHost: View {
    @State private var state: GoalsNativeCalibrationJourneyState

    init(depth: GoalsNativeCalibrationPreviewDepth = .root) {
        var initialState = GoalsNativeCalibrationJourneyState(
            content: GoalsNativeCalibrationFixture.preparingForBaby,
            lensExpanded: false
        )
        if depth != .root {
            _ = initialState.openLifeArea(id: "life-area.home")
        }
        if depth == .focused || depth == .path {
            _ = initialState.openSelectedGoal()
        }
        if depth == .path {
            _ = initialState.openGoalPath()
        }
        _state = State(initialValue: initialState)
    }

    var body: some View {
        GoalsNativeCalibrationView(
            content: GoalsNativeCalibrationFixture.preparingForBaby,
            state: $state
        )
    }
}

#Preview("GNC-F01 · Goals Root · Light") {
    GoalsNativeCalibrationPreviewHost()
        .preferredColorScheme(.light)
}

#Preview("GNC-F02 · Goals Root · Dark") {
    GoalsNativeCalibrationPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("GPC-S01 · Home Life Area") {
    GoalsNativeCalibrationPreviewHost(depth: .home)
        .preferredColorScheme(.dark)
}

#Preview("GPC-S02 · Focused Goal") {
    GoalsNativeCalibrationPreviewHost(depth: .focused)
        .preferredColorScheme(.dark)
}

#Preview("GNC-F07 · Goal Path") {
    GoalsNativeCalibrationPreviewHost(depth: .path)
        .preferredColorScheme(.dark)
}

#Preview("GPC-S03 · Accessibility Focused Goal") {
    GoalsNativeCalibrationPreviewHost(depth: .focused)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility2)
}
