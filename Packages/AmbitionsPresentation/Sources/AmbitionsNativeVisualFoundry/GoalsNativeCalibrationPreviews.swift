import SwiftUI

private struct GoalsNativeCalibrationPreviewHost: View {
    @State private var state: GoalsNativeCalibrationJourneyState

    init(lensExpanded: Bool = false) {
        _state = State(
            initialValue: GoalsNativeCalibrationJourneyState(
                content: GoalsNativeCalibrationFixture.preparingForBaby,
                lensExpanded: lensExpanded
            )
        )
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

#Preview("GNC-F03 · Selected Home and Goal") {
    GoalsNativeCalibrationPreviewHost()
        .preferredColorScheme(.dark)
}

#Preview("GNC-F04 · Linked Goal Lens") {
    GoalsNativeCalibrationPreviewHost(lensExpanded: true)
        .preferredColorScheme(.dark)
}
