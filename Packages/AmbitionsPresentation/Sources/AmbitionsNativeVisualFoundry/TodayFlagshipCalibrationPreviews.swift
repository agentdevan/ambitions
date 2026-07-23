import SwiftUI

private struct TodayFlagshipCalibrationPreviewHost: View {
    @State private var state: TodayFlagshipJourneyState

    let content: TodayFlagshipCalibrationContent
    let initialDockExpanded: Bool

    init(
        content: TodayFlagshipCalibrationContent = TodayFlagshipCalibrationFixture.preparingForBaby,
        phase: TodayFlagshipJourneyPhase,
        initialDockExpanded: Bool = false
    ) {
        self.content = content
        self.initialDockExpanded = initialDockExpanded
        _state = State(
            initialValue: TodayFlagshipJourneyState.preview(
                content: content,
                phase: phase
            )
        )
    }

    var body: some View {
        TodayFlagshipCalibrationView(
            content: content,
            state: $state,
            initialDockExpanded: initialDockExpanded,
            onCommitProposal: {
                try? await Task.sleep(for: .milliseconds(900))
                return true
            }
        )
    }
}

#Preview("TFCS-F01 · Today first viewport · Light") {
    TodayFlagshipCalibrationPreviewHost(phase: .todayInitial)
        .preferredColorScheme(.light)
}

#Preview("TFCS-F02 · Today first viewport · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .todayInitial)
        .preferredColorScheme(.dark)
}

#Preview("TFCS-F03 · Today scroll source · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .todayInitial)
        .preferredColorScheme(.dark)
}

#Preview("TFCS-F04 · Dock expanded · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        phase: .todayInitial,
        initialDockExpanded: true
    )
    .preferredColorScheme(.dark)
}

#Preview("TFCS-F05 · Adaptive Navigation Passage") {
    TodayFlagshipCalibrationPreviewHost(phase: .todayInitial)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility1)
}

#Preview("TFCS-F06 · Focused Step · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .focusedCurrent)
        .preferredColorScheme(.dark)
}

#Preview("TFCS-F07 · Consequential review · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
}

#Preview("TFCS-F08 · Successful settlement · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .settled)
        .preferredColorScheme(.dark)
}

#Preview("TFCS-F09 · Returned Today · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .todayReturned)
        .preferredColorScheme(.dark)
}

#Preview("TFCS-F10 · Interrupted recovery · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .recoveryReview)
        .preferredColorScheme(.dark)
}

#Preview("State · Saving") {
    TodayFlagshipCalibrationPreviewHost(phase: .savingAcceptedTruth)
        .preferredColorScheme(.dark)
}

#Preview("Stress · Dense Today") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.denseToday,
        phase: .todayInitial
    )
    .preferredColorScheme(.dark)
}

#Preview("Stress · Long content RTL") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.longContent,
        phase: .focusedCurrent
    )
    .preferredColorScheme(.dark)
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Stress · Increased contrast and no color") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
}
