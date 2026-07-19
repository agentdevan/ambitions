import AmbitionsDesignSystem
import Foundation

struct TimeReflowDecisionProjector: Sendable {}

extension TimeReflowDecisionProjector {
    func project(
        reflow: TimeRealityReflowState,
        recoveryEntry: TimeRecoveryEntryState,
        saveTheDay: TimeSaveTheDayState,
        receiptPreview: TimeReflowReceiptPreviewState
    ) -> TimeReflowDecisionState {
        let sourceLabel = "Based on Time"
        let trustLabel = "Changes stay reviewable"
        let options = preferredOptions(
            from: reflow.suggestions,
            reasonLabel: reflow.reasonDetail,
            receiptPreview: receiptPreview,
            sourceLabel: sourceLabel,
            trustLabel: trustLabel
        )

        return TimeReflowDecisionState(
            title: "Review Time changes",
            subtitle: reflow.reasonKind == .stillBelievable
                ? "Time still holds together. Keep the path visible unless you choose to adjust it."
                : "Choose one path before anything changes.",
            sourceLabel: sourceLabel,
            trustLabel: trustLabel,
            reasonLabel: reflow.reasonDetail,
            recoveryLabel: recoveryEntry.boundary,
            receiptLabel: "\(receiptPreview.confirmationRequired). \(saveTheDay.boundary)",
            options: options,
            visualState: reflow.visualState
        )
    }

}
