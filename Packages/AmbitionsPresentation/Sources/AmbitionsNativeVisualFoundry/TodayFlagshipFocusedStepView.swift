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
                    onOpenGoalDetail: openGoalDetail,
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
                    onOpenGoalDetail: openGoalDetail,
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
                    onOpenHistory: openHistory,
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
        .sheet(isPresented: goalDetailPresentation) {
            TodayVitalityGoalDetailView(
                content: content,
                onDismiss: closeSupportingRoute
            )
        }
        .sheet(isPresented: historyEntryPresentation) {
            TodayVitalityHistoryEntryView(
                content: content,
                initiallyShowsFilters: state.supportingRoute == .historyFilters,
                onDismiss: closeSupportingRoute
            )
        }
    }

    private func openGoalDetail() {
        _ = state.openSupportingRoute(.goalDetail)
    }

    private func closeSupportingRoute() {
        _ = state.closeSupportingRoute()
    }

    private func openHistory() {
        _ = state.openSupportingRoute(.historyEntry)
    }

    private var goalDetailPresentation: Binding<Bool> {
        Binding(
            get: { state.supportingRoute == .goalDetail },
            set: { isPresented in
                guard isPresented == false, state.supportingRoute == .goalDetail else {
                    return
                }
                closeSupportingRoute()
            }
        )
    }

    private var historyEntryPresentation: Binding<Bool> {
        Binding(
            get: {
                state.supportingRoute == .historyEntry
                    || state.supportingRoute == .historyFilters
            },
            set: { isPresented in
                guard
                    isPresented == false,
                    state.supportingRoute == .historyEntry
                        || state.supportingRoute == .historyFilters
                else {
                    return
                }
                closeSupportingRoute()
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
