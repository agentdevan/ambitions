import Foundation

struct RecoveryEngine: Sendable, Equatable {
    func recoveryState(from nowState: CanonicalNowState) -> RecoveryState {
        let proofIDs = Array(Set(
            nowState.eventLedgerEntryIDs +
            nowState.evidenceSummaries.map(\.id)
        )).filter { $0.isEmpty == false }.sorted()

        return RecoveryState(
            state: nowState.recoveryState,
            reason: recoveryReason(from: nowState),
            proofEventIDs: proofIDs,
            receiptID: proofIDs.first.map { "recovery.receipt.\($0)" },
            reentryStepID: nowState.bestNextAction?.reference?.stepID
        )
    }

    private func recoveryReason(from nowState: CanonicalNowState) -> String? {
        switch nowState.recoveryState {
        case .stable:
            return nil
        case .watch:
            return nowState.priorityPressure.summary
        case .needsRecovery, .recovering, .blocked:
            return nowState.blockersWaiting.summary
        }
    }
}
