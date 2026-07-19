import AmbitionsDesignSystem
import Foundation

struct TimeTreatyState: Sendable {
    let title: String
    let summary: String
    let protectedWork: String
    let flexibleWork: String
    let notTodayWork: String
    let recoveryAllowance: String
    let calendarBoundary: String
    let primaryActionTitle: String
    let primaryActionSubtitle: String
    let visualState: AmbitionVisualState
}

struct TimeCapacityEnvelopeState: Sendable {
    let title: String
    let detail: String
    let label: String
    let availableCapacity: String
    let pressure: String
    let protectedFocus: String
    let recoveryMargin: String
    let visualState: AmbitionVisualState
}

struct TimePressureRecoverySignalState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let statusLabel: String
    let boundaryLabel: String
    let visualState: AmbitionVisualState
}

struct TimePressureRecoveryReviewState: Sendable {
    let title: String
    let detail: String
    let pressureFieldLabel: String
    let recoveryLoopLabel: String
    let weekPressureLabel: String
    let overloadedDayLabel: String
    let recoverySpaceLabel: String
    let smallerStepAnchorLabel: String
    let protectedTimeConflictLabel: String
    let lateStartAdjustmentLabel: String
    let recoveryDayReviewLabel: String
    let recoveryReceiptPreviewLabel: String
    let capacityReviewLabel: String
    let signals: [TimePressureRecoverySignalState]
    let visualState: AmbitionVisualState

    static let baseline = TimePressureRecoveryReviewState(
        title: "Pressure and recovery review",
        detail: "Pressure gets explained before the week changes.",
        pressureFieldLabel: "Pressure field: no relief needed.",
        recoveryLoopLabel: "Recovery loop: keep breathing room visible.",
        weekPressureLabel: "Pressure is readable.",
        overloadedDayLabel: "Overloaded day explanation: no day is asking for relief right now.",
        recoverySpaceLabel: "Recovery space: keep breathing room visible.",
        smallerStepAnchorLabel: "Smaller step anchor: keep the next ask believable.",
        protectedTimeConflictLabel: "Protected time conflict: nothing protected is competing loudly.",
        lateStartAdjustmentLabel: "Late-start adjustment: start with the smaller version.",
        recoveryDayReviewLabel: "Recovery-day review: Still counts.",
        recoveryReceiptPreviewLabel: "Recovery review preview: nothing changes without review.",
        capacityReviewLabel: "Capacity review: qualitative only.",
        signals: [],
        visualState: .default
    )

    var accessibilityValue: String {
        [
            detail,
            pressureFieldLabel,
            recoveryLoopLabel,
            weekPressureLabel,
            overloadedDayLabel,
            recoverySpaceLabel,
            smallerStepAnchorLabel,
            protectedTimeConflictLabel,
            lateStartAdjustmentLabel,
            recoveryDayReviewLabel,
            recoveryReceiptPreviewLabel,
            capacityReviewLabel,
            signals.map { "\($0.title): \($0.detail)" }.joined(separator: ". ")
        ].joined(separator: ". ")
    }
}

