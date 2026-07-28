import SwiftUI

#if os(iOS)
import UIKit
#endif

struct TodayFlagshipReviewView: View {
    @State private var reviewFeedbackTrigger = false
    @State private var commitFeedbackTrigger = false
    @State private var commitTask: Task<Void, Never>?
    @State private var commitGeneration: UUID?

    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState
    let onCommitProposal: @MainActor () async -> Bool

    var body: some View {
        TodayVitalityReviewView(
            content: content,
            state: $state,
            onOpenConsequenceDetails: openConsequenceDetails,
            onCancel: cancelReview,
            onCommit: commitProposal
        )
        .interactiveDismissDisabled(
            state.isCommitInFlight || state.phase == .failedSettlement
        )
        .onAppear {
            reviewFeedbackTrigger.toggle()
        }
        .onDisappear(perform: cancelCommitTask)
        .sensoryFeedback(.selection, trigger: reviewFeedbackTrigger)
        .sensoryFeedback(
            .impact(weight: .light, intensity: 0.75),
            trigger: commitFeedbackTrigger
        )
        .sheet(isPresented: consequenceDetailsPresentation) {
            TodayVitalityConsequenceDetailsView(
                content: content,
                onDismiss: closeSupportingRoute
            )
        }
        .accessibilityIdentifier("tfcs-consequential-review")
    }

    private func openConsequenceDetails() {
        _ = state.openSupportingRoute(.consequenceDetails)
    }

    private func closeSupportingRoute() {
        _ = state.closeSupportingRoute()
    }

    private var consequenceDetailsPresentation: Binding<Bool> {
        Binding(
            get: { state.supportingRoute == .consequenceDetails },
            set: { isPresented in
                guard
                    isPresented == false,
                    state.supportingRoute == .consequenceDetails
                else {
                    return
                }
                closeSupportingRoute()
            }
        )
    }

    private func cancelReview() {
        if state.phase == .failedSettlement {
            _ = state.dismissFailedCommit()
        } else {
            _ = state.cancelReview()
        }
    }

    private func commitProposal() {
        let didBeginCommit: Bool
        if state.phase == .failedSettlement {
            didBeginCommit = state.retryFailedCommit()
        } else {
            didBeginCommit = state.beginCommit()
        }
        guard didBeginCommit else { return }

        commitTask?.cancel()
        let generation = UUID()
        commitGeneration = generation
        commitFeedbackTrigger.toggle()
        announceSaving()

        commitTask = Task { @MainActor in
            let succeeded = await onCommitProposal()
            guard Task.isCancelled == false, commitGeneration == generation else { return }
            _ = state.resolveCommit(succeeded: succeeded)
            commitTask = nil
            commitGeneration = nil
        }
    }

    private func cancelCommitTask() {
        commitGeneration = nil
        commitTask?.cancel()
        commitTask = nil
        if state.isCommitInFlight {
            _ = state.failCommit()
        }
    }

    @MainActor
    private func announceSaving() {
        #if os(iOS)
        UIAccessibility.post(
            notification: .announcement,
            argument: content.interfaceCopy.savingAnnouncement
        )
        #endif
    }

}
