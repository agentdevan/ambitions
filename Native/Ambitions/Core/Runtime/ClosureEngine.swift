import Foundation

enum ClosureStageModeHint: String, Sendable, Equatable {
    case preserve
    case protected
    case recovery
}

struct ClosureMutationRecord: Equatable, Hashable, Sendable {
    let id: String
    let stepID: String?
    let goalID: String?
    let outcome: ClosureState
    let occurredAt: Date

    init(stepID: String?, goalID: String?, outcome: ClosureState, occurredAt: Date = SystemClock().now) {
        self.stepID = stepID
        self.goalID = goalID
        self.outcome = outcome
        self.occurredAt = occurredAt
        self.id = [goalID, stepID, outcome.rawValue, String(Int(occurredAt.timeIntervalSince1970))]
            .compactMap { $0 }
            .joined(separator: ".")
    }
}

struct ClosureConsequence: Equatable, Sendable {
    let closureTitle: String
    let closureSubtitle: String
    let proofTitle: String
    let proofSubtitle: String
    let pressureLabel: String?
    let stageModeHint: ClosureStageModeHint
    let visibleChange: String
    let accessibilityAnnouncement: String
    let hapticIntent: String
    let undoLabel: String
    let proofArtifactLabel: String
    let safeFallback: String
}

struct ClosureEngine: Sendable {
    func consequence(for outcome: ClosureState, stepTitle: String, receiptSaved: Bool) -> ClosureConsequence {
        let title = stepTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "This step" : stepTitle
        let receiptLine = receiptSaved ? "Receipt saved locally." : "Receipt preview only."

        switch outcome {
        case .completed:
            return make(
                closureTitle: "Done",
                closureSubtitle: "\(title) is closed and proof is saved.",
                proofTitle: "Proof saved",
                proofSubtitle: "The completion receipt is attached to this step.",
                outcome: outcome,
                receiptLine: receiptLine,
                mode: .preserve
            )
        case .stillCounts:
            return make(
                closureTitle: "Still counts",
                closureSubtitle: "Progress is saved without pretending the original ask happened.",
                proofTitle: "Proof saved",
                proofSubtitle: "The result counts as proof for \(title).",
                outcome: outcome,
                receiptLine: receiptLine,
                mode: .preserve
            )
        case .moved:
            return make(
                closureTitle: "Move it",
                closureSubtitle: "\(title) stays active for Time review.",
                proofTitle: "Receipt saved",
                proofSubtitle: "The move decision is saved without silently rearranging the day.",
                pressureLabel: "Review time",
                outcome: outcome,
                receiptLine: receiptLine,
                mode: .protected
            )
        case .notNeeded, .skippedIntentionally:
            return make(
                closureTitle: "Not needed",
                closureSubtitle: "The decision is saved and can be reviewed later.",
                proofTitle: "Receipt saved",
                proofSubtitle: "\(title) is removed from pressure without becoming a failure.",
                pressureLabel: "Decision saved",
                outcome: outcome,
                receiptLine: receiptLine,
                mode: .preserve
            )
        case .blocked:
            return make(
                closureTitle: "Blocked",
                closureSubtitle: "Recovery stays visible before the day changes.",
                proofTitle: "Receipt saved",
                proofSubtitle: "The blocker is attached to \(title) for recovery review.",
                pressureLabel: "Recovery needed",
                outcome: outcome,
                receiptLine: receiptLine,
                mode: .recovery
            )
        case .waiting:
            return make(
                closureTitle: "Waiting",
                closureSubtitle: "The dependency stays visible without changing the plan silently.",
                proofTitle: "Receipt saved",
                proofSubtitle: "Waiting is saved as the current honest state.",
                pressureLabel: "Waiting",
                outcome: outcome,
                receiptLine: receiptLine,
                mode: .protected
            )
        case .needsRecovery:
            return make(
                closureTitle: "Needs recovery",
                closureSubtitle: "A smaller path should be chosen before trying again.",
                proofTitle: "Receipt saved",
                proofSubtitle: "Recovery is saved for \(title).",
                pressureLabel: "Recovery needed",
                outcome: outcome,
                receiptLine: receiptLine,
                mode: .recovery
            )
        case .needsReview, .awaitingClosure:
            return make(
                closureTitle: "Review",
                closureSubtitle: "\(title) stays open until the next detail is clear.",
                proofTitle: "Review saved",
                proofSubtitle: "The decision remains inspectable without changing the step.",
                pressureLabel: "Review",
                outcome: outcome,
                receiptLine: receiptLine,
                mode: .protected
            )
        case .now, .next, .later:
            return make(
                closureTitle: outcome.displayLabel,
                closureSubtitle: "Timing is saved for review before anything else changes.",
                proofTitle: "Receipt saved",
                proofSubtitle: "\(title) keeps its timing decision visible.",
                pressureLabel: outcome.displayLabel,
                outcome: outcome,
                receiptLine: receiptLine,
                mode: .protected
            )
        }
    }

    private func make(
        closureTitle: String,
        closureSubtitle: String,
        proofTitle: String,
        proofSubtitle: String,
        pressureLabel: String? = nil,
        outcome: ClosureState,
        receiptLine: String,
        mode: ClosureStageModeHint
    ) -> ClosureConsequence {
        ClosureConsequence(
            closureTitle: closureTitle,
            closureSubtitle: closureSubtitle,
            proofTitle: proofTitle,
            proofSubtitle: proofSubtitle,
            pressureLabel: pressureLabel,
            stageModeHint: mode,
            visibleChange: "\(closureTitle): \(closureSubtitle)",
            accessibilityAnnouncement: "\(closureTitle). \(closureSubtitle) \(receiptLine)",
            hapticIntent: outcome == .completed || outcome == .stillCounts ? "completion" : "selection",
            undoLabel: outcome.undoAvailability.isAvailable ? "Undo available" : "Review available",
            proofArtifactLabel: proofTitle,
            safeFallback: "Keep the step visible and show the saved receipt status if stage mutation fails."
        )
    }
}
