import SwiftUI

struct TodayFlagshipFocusedStepView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState

    var body: some View {
        Group {
            if state.phase == .focusedCurrent {
                TodayVitalityFocusedStepView(
                    content: content,
                    acceptedTruth: state.acceptedTruth,
                    shouldFocusIdentity: state.focusAnchor == .focusedIdentity,
                    onSelectStillCounts: {
                        _ = state.selectStillCounts()
                    }
                )
            } else if state.phase == .recoveredContinuation {
                TodayVitalityFocusedStepView(
                    content: content,
                    acceptedTruth: state.acceptedTruth,
                    shouldFocusIdentity: state.focusAnchor == .focusedIdentity,
                    recoveredProgress: state.phase == .recoveredContinuation
                        ? state.lastSavedProgress
                        : nil,
                    shouldFocusRecoveredProgress: state.focusAnchor == .recoveredProgress,
                    onSelectStillCounts: {
                        _ = state.selectStillCounts()
                    }
                )
            } else if state.phase == .interrupted || state.phase == .recoveryReview {
                TodayVitalityInterruptedStepView(
                    content: content,
                    acceptedTruth: state.acceptedTruth,
                    shouldFocusInterruption: state.focusAnchor == .interruption,
                    onOpenRecovery: {
                        _ = state.openRecoveryReview()
                    }
                )
            } else if state.phase == .settled {
                TodayVitalitySettlementView(
                    content: content,
                    acceptedTruth: state.acceptedTruth,
                    shouldFocusTruth: state.focusAnchor == .settledTruth,
                    historyDisclosure: historyDisclosure,
                    onReturnToToday: {
                        _ = state.returnToToday()
                    }
                )
            }
        }
        .background(palette.semanticPlane.ignoresSafeArea())
        .foregroundStyle(palette.primaryInk)
        .navigationTitle("")
        .todayFlagshipInlineNavigationTitle()
        .todayFlagshipBackButtonHidden(state.phase == .settled)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("tfcs-focused-step")
    }

    private var historyDisclosure: Binding<Bool> {
        Binding(
            get: { state.isHistoryExpanded },
            set: { isExpanded in
                if isExpanded {
                    _ = state.openHistory()
                } else {
                    _ = state.closeHistory()
                }
            }
        )
    }

    private var palette: TodayFlagshipPalette {
        TodayFlagshipPalette(
            colorScheme: colorScheme,
            contrast: colorSchemeContrast
        )
    }
}
