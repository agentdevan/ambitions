import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeBelievability(
        posture: TimeBelievabilityState,
        blockedCount: Int,
        clarificationCount: Int,
        openCaptureCount: Int,
        missingGoalCount: Int,
        activeGoalCount: Int
    ) -> TimeBelievabilityState {
        let supportLabel: String
        if blockedCount + clarificationCount > 0 {
            supportLabel = "Clarify \(blockedCount + clarificationCount) shaping gap\(blockedCount + clarificationCount == 1 ? "" : "s") before widening the week."
        } else if openCaptureCount > 0 {
            supportLabel = "Open captures are the loudest outside pressure on the current week."
        } else if missingGoalCount > 0 {
            supportLabel = "\(missingGoalCount) active goal\(missingGoalCount == 1 ? "" : "s") still need believable room."
        } else if activeGoalCount == 0 {
            supportLabel = "The week is intentionally quiet because nothing real is asking it to carry work."
        } else {
            supportLabel = "The current shape is believable because active goals already have visible room."
        }

        return TimeBelievabilityState(
            title: posture.title,
            detail: posture.detail,
            label: posture.label,
            supportLabel: supportLabel,
            visualState: posture.visualState
        )
    }

    func makePressureRecoveryReview(
        weekDays: [TimeElasticWeekDayState],
        capacityEnvelope: TimeCapacityEnvelopeState,
        recoveryEntry: TimeRecoveryEntryState,
        realityReflow: TimeRealityReflowState,
        saveTheDay: TimeSaveTheDayState,
        recoveryMaturity: TimeRecoveryMaturityState
    ) -> TimePressureRecoveryReviewState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded || $0.level == .fragile }.count
        let tightDays = weekDays.filter { $0.level == .tight }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let protectedConflicts = weekDays.flatMap(\.blocks).filter { block in
            (block.kind == .fixed || block.kind == .protected) && block.visualState == .warning
        }
        let pressureVisible = overloadedDays > 0 || tightDays > 0 || protectedConflicts.isEmpty == false
        let visualState: AmbitionVisualState = pressureVisible ? .warning : .selected
        let dayNoun = overloadedDays == 1 ? "day" : "days"
        let openNoun = openDays == 1 ? "day" : "days"
        let conflictNoun = protectedConflicts.count == 1 ? "item" : "items"

        return TimePressureRecoveryReviewState(
            title: "Pressure and recovery review",
            detail: pressureVisible
                ? "Pressure gets explained before the week changes, then recovery stays smaller than the strain."
                : "The week still has readable room, so recovery can stay protective instead of becoming extra arrangement.",
            pressureFieldLabel: overloadedDays > 0
                ? "Pressure field: \(overloadedDays) \(dayNoun) should be lightened before new work lands."
                : "Pressure field: keep the current week fit readable before widening it.",
            recoveryLoopLabel: pressureVisible
                ? "Recovery loop: explain pressure, choose the smaller step, then preview the receipt."
                : "Recovery loop: preserve room and keep Still Counts available.",
            weekPressureLabel: overloadedDays > 0
                ? "\(overloadedDays) \(dayNoun) need relief before adding work."
                : tightDays > 0
                    ? "\(tightDays) tight day\(tightDays == 1 ? "" : "s") should stay visible before anything shifts."
                    : "Pressure is readable and does not need a larger Time shape.",
            overloadedDayLabel: overloadedDays > 0
                ? "Overloaded day explanation: reduce one ask before adding another."
                : "Overloaded day explanation: no day is asking for relief right now.",
            recoverySpaceLabel: openDays > 0
                ? "Recovery space: \(openDays) open \(openNoun) can protect breathing room."
                : "Recovery space: make one smaller pocket before widening the week.",
            smallerStepAnchorLabel: overloadedDays > 0
                ? "Smaller step anchor: make the next ask lighter before protecting anything else."
                : "Smaller step anchor: keep one believable next step available.",
            protectedTimeConflictLabel: protectedConflicts.isEmpty
                ? "Protected time conflict: nothing protected is competing loudly."
                : "Protected time conflict: \(protectedConflicts.count) fixed or protected \(conflictNoun) need care before shifting anything.",
            lateStartAdjustmentLabel: "Late-start adjustment: \(saveTheDay.adjustment) Start with the smaller version.",
            recoveryDayReviewLabel: "Recovery-day review: Still counts; protect what remains and make the next ask lighter.",
            recoveryReceiptPreviewLabel: "Recovery review preview: records what was lightened, what stayed protected, and what still counts before any Time change.",
            capacityReviewLabel: "Capacity review: \(capacityEnvelope.label.lowercased()) is qualitative, with no percentage or certainty claim.",
            signals: [
                TimePressureRecoverySignalState(
                    id: "week-pressure",
                    title: "Week pressure",
                    detail: realityReflow.reasonDetail,
                    statusLabel: capacityEnvelope.label,
                    boundaryLabel: "Explain before changing",
                    visualState: visualState
                ),
                TimePressureRecoverySignalState(
                    id: "recovery-space",
                    title: "Recovery space",
                    detail: recoveryEntry.detail,
                    statusLabel: openDays > 0 ? "Available" : "Make room",
                    boundaryLabel: "Reduce the ask",
                    visualState: openDays > 0 ? .success : .warning
                ),
                TimePressureRecoverySignalState(
                    id: "protected-time",
                    title: "Protected time",
                    detail: protectedConflicts.first?.detail ?? "Nothing protected needs to be shifted automatically.",
                    statusLabel: protectedConflicts.isEmpty ? "Clear" : "Review",
                    boundaryLabel: "No silent rescheduling",
                    visualState: protectedConflicts.isEmpty ? .success : .warning
                ),
                TimePressureRecoverySignalState(
                    id: "recovery-boundary",
                    title: "Recovery boundary",
                    detail: recoveryMaturity.confirmationBoundary,
                    statusLabel: recoveryMaturity.timeFitLabel,
                    boundaryLabel: "Confirm first",
                    visualState: recoveryMaturity.timeFitLabel == "Needs relief" ? .warning : .selected
                )
            ],
            visualState: visualState
        )
    }

}
