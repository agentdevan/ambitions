import SwiftUI

private struct TodayFlagshipCalibrationPreviewHost: View {
    @State private var state: TodayFlagshipJourneyState

    let content: TodayFlagshipCalibrationContent
    let initialDockExpanded: Bool

    init(
        content: TodayFlagshipCalibrationContent = TodayFlagshipCalibrationFixture.preparingForBaby,
        phase: TodayFlagshipJourneyPhase,
        initialDockExpanded: Bool = false,
        fullDayOrigin: TodayFlagshipFullDayOrigin? = nil,
        supportingRoute: TodayFlagshipSupportingRoute? = nil
    ) {
        self.content = content
        self.initialDockExpanded = initialDockExpanded
        var initialState = TodayFlagshipJourneyState.preview(
            content: content,
            phase: phase
        )
        if fullDayOrigin != nil {
            _ = initialState.openFullDay()
        }
        if let supportingRoute {
            _ = initialState.openSupportingRoute(supportingRoute)
        }
        _state = State(
            initialValue: initialState
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

#Preview("R13 Root · Compact iPhone · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .todayInitial)
        .preferredColorScheme(.dark)
}

#Preview("R13 Root · Pro Max · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .todayInitial)
        .preferredColorScheme(.dark)
}

#Preview("R13 Root · Accessibility 5 · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .todayInitial)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility5)
}

#Preview("R13 Root · RTL stress evaluation") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.arabicSaudiEvaluation,
        phase: .todayInitial
    )
    .preferredColorScheme(.dark)
    .environment(\.locale, Locale(identifier: "ar-SA"))
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("R13 Root · Long English") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.longContent,
        phase: .todayInitial
    )
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

#Preview("R13 Focused Step · Typical · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .focusedCurrent)
        .preferredColorScheme(.dark)
}

#Preview("B02 Focused Step · Dense context · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.denseToday,
        phase: .focusedCurrent
    )
    .preferredColorScheme(.dark)
}

#Preview("R13 Focused Step · Accessibility 5 · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .focusedCurrent)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility5)
}

#Preview("B02 Focused Step · RTL evaluation") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.arabicSaudiEvaluation,
        phase: .focusedCurrent
    )
    .preferredColorScheme(.dark)
    .environment(\.locale, Locale(identifier: "ar-SA"))
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("R13 Focused Step · Long English") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.longContent,
        phase: .focusedCurrent
    )
    .preferredColorScheme(.dark)
}

#Preview("TFCS-F07 · Consequential review · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
}

#Preview("B02 Review · Typical · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
}

#Preview("B02 Review · Accessibility 5 · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility5)
}

#Preview("B02 Review · Differentiate Without Color") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
        .environment(\._accessibilityDifferentiateWithoutColor, true)
}

#Preview("B02 Review · Reduce Motion") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
        .environment(\._accessibilityReduceMotion, true)
}

#Preview("B02 Review · Reduce Transparency") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
        .environment(\._accessibilityReduceTransparency, true)
}

#Preview("B02 Review · RTL evaluation") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.arabicSaudiEvaluation,
        phase: .reviewingProposal
    )
    .preferredColorScheme(.dark)
    .environment(\.locale, Locale(identifier: "ar-SA"))
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("B02 Saving · Accepted truth retained") {
    TodayFlagshipCalibrationPreviewHost(phase: .savingAcceptedTruth)
        .preferredColorScheme(.dark)
}

#Preview("R13 Review · Typical · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
}

#Preview("R13 Review · Accessibility 5 · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility5)
}

#Preview("R13 Review · Differentiate Without Color") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
        .environment(\._accessibilityDifferentiateWithoutColor, true)
}

#Preview("R13 Review · Reduce Motion") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
        .environment(\._accessibilityReduceMotion, true)
}

#Preview("R13 Saving · Accepted truth retained") {
    TodayFlagshipCalibrationPreviewHost(phase: .savingAcceptedTruth)
        .preferredColorScheme(.dark)
}

#Preview("R13 Review · Failed settlement") {
    TodayFlagshipCalibrationPreviewHost(phase: .failedSettlement)
        .preferredColorScheme(.dark)
}

#Preview("TFCS-F08 · Successful settlement · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .settled)
        .preferredColorScheme(.dark)
}

#Preview("B02 Settlement · RTL evaluation") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.arabicSaudiEvaluation,
        phase: .settled
    )
    .preferredColorScheme(.dark)
    .environment(\.locale, Locale(identifier: "ar-SA"))
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("TFCS-F09 · Returned Today · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .todayReturned)
        .preferredColorScheme(.dark)
}

#Preview("TFCS-F10 · Interrupted recovery · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .recoveryReview)
        .preferredColorScheme(.dark)
}

#Preview("B02 Recovery · Interrupted sheet · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .recoveryReview)
        .preferredColorScheme(.dark)
}

#Preview("B02 Recovery · Interrupted Step · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .interrupted)
        .preferredColorScheme(.dark)
}

#Preview("B02 Recovery · Continued saved progress · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .recoveredContinuation)
        .preferredColorScheme(.dark)
}

#Preview("B02 Recovery · RTL evaluation") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.arabicSaudiEvaluation,
        phase: .recoveryReview
    )
    .preferredColorScheme(.dark)
    .environment(\.locale, Locale(identifier: "ar-SA"))
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("R13 Recovery · Interrupted Step · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .interrupted)
        .preferredColorScheme(.dark)
}

#Preview("R13 Recovery · Sheet · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .recoveryReview)
        .preferredColorScheme(.dark)
}

#Preview("R13 Recovery · Continued · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .recoveredContinuation)
        .preferredColorScheme(.dark)
}

#Preview("R13 Recovery · Accessibility 5 · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .recoveryReview)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility5)
}

#Preview("R13 Recovery · Long English · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.longContent,
        phase: .recoveryReview
    )
    .preferredColorScheme(.dark)
}

#Preview("R13 Recovery · Reduce Motion · Dark") {
    TodayFlagshipCalibrationPreviewHost(phase: .recoveryReview)
        .preferredColorScheme(.dark)
        .environment(\._accessibilityReduceMotion, true)
}

#Preview("R13 Today · Quiet") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.quietToday,
        phase: .todayInitial
    )
    .preferredColorScheme(.dark)
}

#Preview("R13 Today · Very dense") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.veryDenseToday,
        phase: .todayInitial
    )
    .preferredColorScheme(.dark)
}

#Preview("B02 Today · Offline local truth") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.offlineLocalTruth,
        phase: .todayInitial
    )
    .preferredColorScheme(.dark)
}

#Preview("B02 Today · Stale external context") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.staleExternalContext,
        phase: .todayInitial
    )
    .preferredColorScheme(.dark)
}

#Preview("B02 Today · Conflict transfer") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.conflictTransfer,
        phase: .todayInitial
    )
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
        content: TodayFlagshipCalibrationFixture.preparingForBaby.arabicSaudiEvaluation,
        phase: .focusedCurrent
    )
    .preferredColorScheme(.dark)
    .environment(\.locale, Locale(identifier: "ar-SA"))
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Stress · Increased contrast and no color") {
    TodayFlagshipCalibrationPreviewHost(phase: .reviewingProposal)
        .preferredColorScheme(.dark)
}

#Preview("R13 Full Day · Typical · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        phase: .todayInitial,
        fullDayOrigin: .todayInitial
    )
    .preferredColorScheme(.dark)
}

#Preview("R13 Full Day · Returned · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        phase: .todayReturned,
        fullDayOrigin: .todayReturned
    )
    .preferredColorScheme(.dark)
}

#Preview("R13 Full Day · Dense · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.denseToday,
        phase: .todayInitial,
        fullDayOrigin: .todayInitial
    )
    .preferredColorScheme(.dark)
}

#Preview("B02 Full Day · RTL evaluation") {
    TodayFlagshipCalibrationPreviewHost(
        content: TodayFlagshipCalibrationFixture.preparingForBaby.arabicSaudiEvaluation,
        phase: .todayInitial,
        fullDayOrigin: .todayInitial
    )
    .preferredColorScheme(.dark)
    .environment(\.locale, Locale(identifier: "ar-SA"))
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("R13 Full Day · Compact · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        phase: .todayInitial,
        fullDayOrigin: .todayInitial
    )
    .preferredColorScheme(.dark)
}

#Preview("R13 Full Day · Accessibility 5 · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        phase: .todayInitial,
        fullDayOrigin: .todayInitial
    )
    .preferredColorScheme(.dark)
    .dynamicTypeSize(.accessibility5)
}

#Preview("R13 Goal Detail · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        phase: .focusedCurrent,
        supportingRoute: .goalDetail
    )
    .preferredColorScheme(.dark)
}

#Preview("R13 Consequence Details · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        phase: .reviewingProposal,
        supportingRoute: .consequenceDetails
    )
    .preferredColorScheme(.dark)
}

#Preview("R13 History Entry · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        phase: .settled,
        supportingRoute: .historyEntry
    )
    .preferredColorScheme(.dark)
}

#Preview("R13 History Filters · Dark") {
    TodayFlagshipCalibrationPreviewHost(
        phase: .settled,
        supportingRoute: .historyFilters
    )
    .preferredColorScheme(.dark)
}

#Preview("R13 Time Transfer · Host evaluation · route unavailable") {
    TodayFlagshipTimeTransferEvaluationView(
        content: TodayFlagshipCalibrationFixture.preparingForBaby,
        onCancel: {}
    )
    .preferredColorScheme(.dark)
}
