import Foundation

struct TodayProofReceiptPeekState: Equatable, Sendable {
    let title: String
    let subtitle: String
    let proofLabel: String
    let privacyLabel: String
    let noSilentChangesLabel: String
}

extension TodayActionClosureSheetState {
    func proofReceiptPeek(for outcome: TodayActionClosureOutcomeState, occurredAt: String = "2026-05-01T12:00:00Z") -> TodayProofReceiptPeekState {
        let record = actionReceiptHistoryRecord(for: outcome, occurredAt: occurredAt)
        let entry = ActionReceiptProofLedgerEntry(
            receipt: record.receipt,
            proofRelevance: record.proofRelevance,
            runtimeLineage: record.runtimeLineage
        )

        return TodayProofReceiptPeekState(
            title: entry.peekTitle,
            subtitle: entry.peekSubtitle,
            proofLabel: entry.receiptRecord.proofLabel,
            privacyLabel: entry.privacyLabel,
            noSilentChangesLabel: "Changes stay reviewable"
        )
    }

    func actionReceiptHistoryRecord(for outcome: TodayActionClosureOutcomeState, occurredAt: String) -> ActionReceiptHistoryRecord {
        ActionReceiptHistoryRecord(
            receipt: actionReceipt(for: outcome, occurredAt: occurredAt),
            privacyLevel: .safeToShow,
            localOnly: true,
            proofRelevance: outcome.createsProof ? .countsAsProof : nil,
            requiresConfirmationBeforeBroaderUse: outcome.createsProof ? false : nil
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
            id: "receipt.today.\(id).\(outcome.id).\(Self.receiptIDComponent(occurredAt))",
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
            why: ActionReceiptWhyExplanation(
                body: "User confirmed the closure outcome in Today; SourceRecord, Receipt, ReplayTrace, reason, and You inspection stay local through receipt history."
            ),
            nextAction: outcome.closureState.nextAction,
            correctionAvailability: .available,
            undoAvailability: outcome.closureState.undoAvailability,
            safetyState: outcome.closureState == .needsReview ? .confirmationRequired : .normal
        )
    }

    private static func receiptIDComponent(_ occurredAt: String) -> String {
        occurredAt
            .lowercased()
            .map { character in
                character.isLetter || character.isNumber ? character : "-"
            }
            .reduce(into: "") { result, character in
                if character == "-", result.last == "-" {
                    return
                }
                result.append(character)
            }
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}
