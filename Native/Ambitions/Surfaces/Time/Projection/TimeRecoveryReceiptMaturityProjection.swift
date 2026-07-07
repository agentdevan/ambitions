import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeReflowReceiptPreview(
        reflow: TimeRealityReflowState,
        saveTheDay: TimeSaveTheDayState
    ) -> TimeReflowReceiptPreviewState {
        let primary = reflow.suggestions.first
        let confirmationRequired = primary?.boundary.confirmationLabel ?? "Safe local suggestion"
        let undoAvailability = primary?.boundary.undoLabel ?? "Undo unavailable"
        let noReflowApplied = reflow.reasonKind == .stillBelievable
            ? "No Time change would be applied."
            : "Receipt would show the suggested change before action."
        let wouldChange = [
            "Protect: \(saveTheDay.protectedItem)",
            "Adjust: \(saveTheDay.adjustment)",
            noReflowApplied
        ]
        let wouldNotChange = [
            "Calendar blocks are not written.",
            "Time is not silently rescheduled.",
            "Sync, export, widgets, and future systems are not touched."
        ]
        let destinationStepLabel = primary?.target?.goalID ?? "active destination step"
        let displacedStepLabel = reflow.reasonDetail.isEmpty
            ? "displaced step pressure profile is recalculated before any write."
            : reflow.reasonDetail
        let lifeshapeImpact = reflow.reasonKind == .stillBelievable
            ? "Life Calendar impact: no recovery shift needed now."
            : "Life Calendar impact: recoverable pressure for destination and displaced steps is recalculated."
        let momentumReflowContract: [String] = [
            "Original block link: \(saveTheDay.protectedItem) stays reviewable before any change.",
            "Approved duration: user-approved duration selection is required before reassignment.",
            "Displaced step pressure: \(displacedStepLabel).",
            "Destination step: \(destinationStepLabel) pressure is recalculated before review.",
            lifeshapeImpact
        ]

        return TimeReflowReceiptPreviewState(
            title: "Before anything changes",
            detail: "A Time change preview shows the tradeoff before action, not after a hidden change.",
            whatChanged: wouldChange,
            whatWouldNotChange: wouldNotChange,
            momentumReflowContract: momentumReflowContract,
            confirmationRequired: confirmationRequired,
            undoAvailability: undoAvailability,
            safeFailureFallback: "If you decline confirmation, Ambitions keeps Time as-is and leaves manual availability available.",
            visualState: primary?.visualState ?? reflow.visualState
        )
    }

    func makeRecoveryMaturity(
        weekDays: [TimeElasticWeekDayState],
        openCaptures: [Capture],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary],
        calendarAwareness: TimeCalendarAwarenessState,
        realityReflow: TimeRealityReflowState,
        saveTheDay: TimeSaveTheDayState,
        receiptPreview: TimeReflowReceiptPreviewState
    ) -> TimeRecoveryMaturityState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded || $0.level == .fragile }.count
        let waitingCount = openCaptures.filter { capture in
            capture.status == .waiting || capture.status == .delegated || capture.kind == .waitingItem || capture.triageStatus == .waiting
        }.count
        let commitmentCount = openCaptures.filter { capture in
            capture.kind == .oneTimeCommitment || capture.kind == .deadlineTask || capture.commitmentKind != nil
        }.count
        let socialWaitingCount = openCaptures.filter { capture in
            capture.waitingMetadata?.waitingOn?.isEmpty == false || capture.waitingMetadata?.blockedBy?.isEmpty == false || capture.status == .delegated
        }.count
        let fitLabel: String
        if overloadedDays > 0 {
            fitLabel = "Needs relief"
        } else if missingGoalSummaries.isEmpty == false || waitingCount > 0 || commitmentCount > 0 {
            fitLabel = "Needs a decision"
        } else if realityReflow.reasonKind == .stillBelievable {
            fitLabel = "Believable"
        } else {
            fitLabel = "Needs review"
        }

        let waitingDetail: String
        if waitingCount > 0 || commitmentCount > 0 {
            waitingDetail = "\(waitingCount) waiting item\(waitingCount == 1 ? "" : "s") and \(commitmentCount) commitment\(commitmentCount == 1 ? "" : "s") should stay visible instead of becoming quiet pressure."
        } else {
            waitingDetail = "No waiting item or one-time commitment is currently pushing on Time."
        }

        let socialDetail: String
        if socialWaitingCount > 0 {
            socialDetail = "\(socialWaitingCount) people-shaped dependency \(socialWaitingCount == 1 ? "is" : "are") visible, but Time keeps the language private and manual-first."
        } else {
            socialDetail = "No social-load assumption is inferred. You can name people-shaped pressure only when it helps you."
        }

        let signalState: AmbitionVisualState = overloadedDays > 0 || missingGoalSummaries.isEmpty == false || waitingCount > 0 || commitmentCount > 0 ? .warning : .success
        let signals = [
            TimeRecoveryMaturitySignalState(
                id: "fit",
                title: "Time fit",
                detail: overloadedDays > 0
                    ? "\(overloadedDays) day\(overloadedDays == 1 ? "" : "s") need relief before the week widens."
                    : saveTheDay.recoveryExplanation,
                statusLabel: fitLabel,
                boundaryLabel: "Suggests one smaller step",
                visualState: signalState
            ),
            TimeRecoveryMaturitySignalState(
                id: "waiting-commitments",
                title: "Waiting and commitments",
                detail: waitingDetail,
                statusLabel: waitingCount + commitmentCount == 0 ? "Quiet" : "Visible",
                boundaryLabel: "No silent routing",
                visualState: waitingCount + commitmentCount == 0 ? .default : .warning
            ),
            TimeRecoveryMaturitySignalState(
                id: "social-load",
                title: "Social load",
                detail: socialDetail,
                statusLabel: socialWaitingCount == 0 ? "Manual" : "Private",
                boundaryLabel: "No inference without you",
                visualState: socialWaitingCount == 0 ? .default : .selected
            ),
            TimeRecoveryMaturitySignalState(
                id: "receipt",
                title: "Receipt and undo",
                detail: receiptPreview.safeFailureFallback,
                statusLabel: receiptPreview.confirmationRequired,
                boundaryLabel: receiptPreview.undoAvailability,
                visualState: receiptPreview.visualState
            )
        ]

        return TimeRecoveryMaturityState(
            title: "Recovery maturity",
            detail: "Overloaded days become decisions with receipts, not silent reschedules.",
            timeFitLabel: fitLabel,
            confirmationBoundary: "Save the Day and Time changes require confirmation before wide changes.",
            calendarBoundary: calendarAwareness.status == .calendarAware
                ? "Calendar context can inform open windows, but Time still does not write calendar changes silently."
                : "Manual shaping works without calendar access.",
            socialBoundary: "People-shaped pressure stays private, optional, and manually named.",
            receiptBoundary: "A review preview names what would change, what would not change, and the undo boundary.",
            signals: signals
        )
    }

}
