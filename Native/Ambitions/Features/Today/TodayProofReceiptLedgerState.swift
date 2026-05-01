import Foundation

struct TodayProofReceiptPeekState: Equatable {
    let title: String
    let subtitle: String
    let proofLabel: String
    let privacyLabel: String
    let noSilentChangesLabel: String
}

extension TodayActionClosureSheetState {
    func proofReceiptPeek(for outcome: TodayActionClosureOutcomeState, occurredAt: String = "2026-05-01T12:00:00Z") -> TodayProofReceiptPeekState {
        let entry = ActionReceiptProofLedgerEntry(
            receipt: actionReceipt(for: outcome, occurredAt: occurredAt),
            proofRelevance: outcome.createsProof ? .countsAsProof : nil
        )

        return TodayProofReceiptPeekState(
            title: entry.peekTitle,
            subtitle: entry.peekSubtitle,
            proofLabel: entry.receiptRecord.proofLabel,
            privacyLabel: entry.privacyLabel,
            noSilentChangesLabel: entry.noSilentChangesLabel
        )
    }

    private func actionReceipt(for outcome: TodayActionClosureOutcomeState, occurredAt: String) -> ActionReceipt {
        let object = LifeGraphObjectReference(
            kind: .step,
            id: target.stepID ?? target.goalID ?? target.draftID ?? "today-step",
            label: objectTitle,
            sourceDomain: .today
        )
        return ActionReceipt(
            id: "receipt.today.\(id).\(outcome.id)",
            resultState: outcome.closureState.actionReceiptResultState,
            title: outcome.closureState.receiptTitle(stepTitle: objectTitle),
            summary: outcome.closureState.receiptSummary(stepTitle: objectTitle),
            sourceDomain: .today,
            occurredAt: occurredAt,
            affectedObjects: [object],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact.today.\(id).\(outcome.id)",
                    kind: outcome.closureState.changedFactKind,
                    object: object,
                    fieldName: "closureState",
                    newValueSummary: outcome.closureState.displayLabel,
                    summary: outcome.closureState.changedFactSummary(stepTitle: objectTitle)
                )
            ],
            why: ActionReceiptWhyExplanation(body: "User confirmed the closure outcome in Today."),
            nextAction: outcome.closureState.nextAction,
            correctionAvailability: .available,
            undoAvailability: outcome.closureState.undoAvailability,
            safetyState: outcome.closureState == .needsReview ? .confirmationRequired : .normal
        )
    }
}
