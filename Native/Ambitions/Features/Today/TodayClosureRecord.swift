
import Foundation

typealias TodayClosureRecord = ClosureMutationRecord

extension AmbitionsDayRailViewState {
    /// Batch 21 source anchor: closure must become a Today state mutation.
    /// The existing services still own the durable response; this method gives
    /// the surface a deterministic extension point for removing, keeping, or
    /// annotating the Start Here object after a closure event.
    func applyingClosure(_ record: TodayClosureRecord) -> AmbitionsDayRailViewState {
        applyingClosure(TodayClosureStageMutation(record: record, stepTitle: heroStep?.title ?? closureSlot.title, receiptSaved: true))
    }

    func applyingClosure(_ mutation: TodayClosureStageMutation) -> AmbitionsDayRailViewState {
        let updatedClosureSlot = DayRailClosureSlotState(
            title: mutation.policy.closureTitle,
            subtitle: mutation.policy.closureSubtitle,
            reservedForActionClosureSheet: true
        )
        let updatedProofSlot = DayRailProofSlotState(
            title: mutation.policy.proofTitle,
            subtitle: mutation.policy.proofSubtitle,
            noSilentChanges: true,
            reservedForReceiptPeek: false
        )
        let updatedMode = mutation.policy.stageModeHint.dayRailMode(current: mode)
        let updatedPressureLabel = mutation.policy.pressureLabel ?? continuity.pressureLabel
        let updatedContinuity = DayRailContinuityState.make(
            heroStep: heroStep,
            rows: rows,
            closureSlot: updatedClosureSlot,
            proofSlot: updatedProofSlot,
            mode: updatedMode,
            pressureLabel: updatedPressureLabel
        )

        return AmbitionsDayRailViewState(
            id: "\(id).closure.\(mutation.record.outcome.rawValue)",
            mode: updatedMode,
            dateTitle: dateTitle,
            contextSummary: contextSummary,
            heroStep: heroStep,
            rows: rows,
            primaryAction: primaryAction,
            rowTapDetailTargetPlaceholder: rowTapDetailTargetPlaceholder,
            durationSource: durationSource,
            contextLabels: contextLabels,
            privacyProjection: privacyProjection,
            continuity: updatedContinuity,
            closureSlot: updatedClosureSlot,
            proofSlot: updatedProofSlot
        )
    }
}

private extension ClosureStageModeHint {
    func dayRailMode(current: DayRailMode) -> DayRailMode {
        switch self {
        case .preserve:
            return current
        case .protected:
            return .protected
        case .recovery:
            return .recovery
        }
    }
}

extension TodayExecutionViewState {
    func applyingClosure(_ mutation: TodayClosureStageMutation) -> TodayExecutionViewState {
        replacingDayRail(dayRail.applyingClosure(mutation))
    }
}

extension TodayExperience {
    func applyingClosure(_ mutation: TodayClosureStageMutation) -> TodayExperience {
        TodayExperience(
            mode: mode,
            hero: hero,
            support: support,
            execution: execution.applyingClosure(mutation)
        )
    }
}
