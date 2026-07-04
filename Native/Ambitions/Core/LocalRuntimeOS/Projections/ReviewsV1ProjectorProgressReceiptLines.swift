import AmbitionsDesignSystem
import Foundation

extension ReviewsV1Projector {

    func progressReceiptLines(
        receiptHighlights: [ReviewSignalItem],
        meaningfulEvents: [ReviewSignalItem],
        recoveryItems: [ReviewSignalItem],
        proof: [ReviewProofHighlight],
        corrections: [ReviewCorrectionPrompt],
        carryForward: [ReviewCarryForwardItem]
    ) -> [LifeOSReceiptProgressLine] {
        var lines: [LifeOSReceiptProgressLine] = []

        if let event = meaningfulEvents.first {
            lines.append(LifeOSReceiptProgressLine(
                id: "review.progress.changed",
                title: "What changed",
                detail: event.detail,
                sourceLabel: event.valueLabel,
                privacyLabel: "Local event",
                state: event.state
            ))
        } else if let receipt = receiptHighlights.first {
            lines.append(LifeOSReceiptProgressLine(
                id: "review.progress.changed",
                title: "What changed",
                detail: receipt.detail,
                sourceLabel: receipt.valueLabel,
                privacyLabel: "Receipt summary",
                state: receipt.state
            ))
        }

        if let proof = proof.first {
            lines.append(LifeOSReceiptProgressLine(
                id: "review.progress.proof",
                title: "Proof",
                detail: proof.detail,
                sourceLabel: proof.valueLabel,
                privacyLabel: "Sensitive detail hidden",
                state: proof.state
            ))
        }

        if let recovery = recoveryItems.first {
            lines.append(LifeOSReceiptProgressLine(
                id: "review.progress.recovery",
                title: "Recovery",
                detail: recovery.detail,
                sourceLabel: recovery.valueLabel,
                privacyLabel: "Suggested, not applied",
                state: recovery.state
            ))
        }

        if let correction = corrections.first {
            lines.append(LifeOSReceiptProgressLine(
                id: "review.progress.correction",
                title: "Correction",
                detail: correction.detail,
                sourceLabel: correction.actionLabel,
                privacyLabel: "User-directed",
                state: correction.state
            ))
        }

        if let carry = carryForward.first, carry.id != "review.carry.empty" {
            lines.append(LifeOSReceiptProgressLine(
                id: "review.progress.carry-forward",
                title: "Carry forward",
                detail: carry.detail,
                sourceLabel: carry.actionLabel,
                privacyLabel: "Needs confirmation",
                state: carry.state
            ))
        }

        return Array(lines.prefix(5))
    }


    func carryForwardItems(
        recoveryItems: [ReviewSignalItem],
        protectedItems: [ReviewSignalItem],
        reviewItems: [ReviewSignalItem],
        proof: [ReviewProofHighlight],
        corrections: [ReviewCorrectionPrompt],
        meaningfulEvents: [ReviewSignalItem]
    ) -> [ReviewCarryForwardItem] {
        var items: [ReviewCarryForwardItem] = []

        if let review = reviewItems.first {
            items.append(ReviewCarryForwardItem(
                id: "review.carry.review",
                title: "Review one decision",
                detail: review.detail,
                actionLabel: review.valueLabel,
                state: .warning
            ))
        } else if let protected = protectedItems.first {
            items.append(ReviewCarryForwardItem(
                id: "review.carry.protect",
                title: "Keep one thing protected",
                detail: protected.detail,
                actionLabel: "Carried forward",
                state: .selected
            ))
        }

        if let recovery = recoveryItems.first {
            items.append(ReviewCarryForwardItem(
                id: "review.carry.recovery",
                title: "Carry the recovery path forward",
                detail: recovery.detail,
                actionLabel: "Suggested, not applied",
                state: recovery.state
            ))
        } else if let event = meaningfulEvents.first {
            items.append(ReviewCarryForwardItem(
                id: "review.carry.event",
                title: "Carry forward what changed",
                detail: event.detail,
                actionLabel: "Based on recent actions",
                state: event.state
            ))
        }

        if let correction = corrections.first {
            items.append(ReviewCarryForwardItem(
                id: "review.carry.correction",
                title: "Correct what needs attention",
                detail: correction.detail,
                actionLabel: correction.actionLabel,
                state: correction.state
            ))
        } else if let proof = proof.first {
            items.append(ReviewCarryForwardItem(
                id: "review.carry.proof",
                title: "Use proof as the next anchor",
                detail: proof.detail,
                actionLabel: proof.valueLabel,
                state: proof.state
            ))
        }

        if items.isEmpty {
            items.append(ReviewCarryForwardItem(
                id: "review.carry.empty",
                title: "Nothing to carry forward yet",
                detail: "After more activity, this will name the calmest next review action.",
                actionLabel: "Available after more activity",
                state: .default
            ))
        }

        return Array(items.prefix(3))
    }


    func planningHandoffItems(
        carryForward: [ReviewCarryForwardItem],
        reviewItems: [ReviewSignalItem],
        proof: [ReviewProofHighlight]
    ) -> [ReviewPlanningHandoff] {
        var handoffs: [ReviewPlanningHandoff] = []

        if let review = reviewItems.first {
            handoffs.append(ReviewPlanningHandoff(
                id: "review.handoff.decision",
                title: "Decide before changing the plan",
                detail: review.detail,
                destinationLabel: "Open Time",
                safetyLabel: "Requires confirmation",
                state: .warning
            ))
        }

        if let carry = carryForward.first {
            handoffs.append(ReviewPlanningHandoff(
                id: "review.handoff.carry-forward",
                title: carry.title,
                detail: carry.detail,
                destinationLabel: "Carry into Plan",
                safetyLabel: "Suggested, not applied",
                state: carry.state
            ))
        }

        if reviewItems.isEmpty, let proof = proof.first {
            handoffs.append(ReviewPlanningHandoff(
                id: "review.handoff.proof",
                title: "Use proof for the next plan",
                detail: proof.detail,
                destinationLabel: "Open Goal",
                safetyLabel: "No automatic change",
                state: proof.state
            ))
        }

        if handoffs.isEmpty {
            handoffs.append(ReviewPlanningHandoff(
                id: "review.handoff.empty",
                title: "No planning handoff yet",
                detail: "After more review evidence, this will name what can move into Plan or Goal Detail.",
                destinationLabel: "Available later",
                safetyLabel: "No change made",
                state: .default
            ))
        }

        return Array(handoffs.prefix(3))
    }


    func unavailableNotes(calendarStatusLabel: String?) -> [ReviewSignalItem] {
        [
            ReviewSignalItem(
                id: "review.unavailable.sync",
                kind: .trustNote,
                title: "Sync and external storage",
                detail: "Reviews is local-first in this build. Apple-first sync and cloud/account claims remain future planned.",
                valueLabel: "Future planned",
                icon: "lock.shield",
                state: .default
            ),
            ReviewSignalItem(
                id: "review.unavailable.accessibility",
                kind: .trustNote,
                title: "Accessibility verification",
                detail: "Internal accessibility infrastructure exists, but this review does not claim verified accessibility.",
                valueLabel: "Unverified",
                icon: "figure",
                state: .warning
            ),
            ReviewSignalItem(
                id: "review.unavailable.calendar",
                kind: .trustNote,
                title: "Calendar changes",
                detail: "No calendar changes were made by this review. User choice remains available.",
                valueLabel: calendarStatusLabel ?? "User choice available",
                icon: "calendar.badge.clock",
                state: .default
            )
        ]
    }


    func recoveryBoundaryNotes(calendarStatusLabel: String?) -> [String] {
        [
            "No calendar changes were made.",
            "Broad reflow stays suggested, not applied.",
            calendarStatusLabel == "Denied" ? "User choice available." : "User choice available."
        ]
    }


    func isMeaningfulForLifeReceipt(_ event: EventLedgerEntry) -> Bool {
        switch event.kind {
        case .actionCompleted, .actionDelayed, .actionSkipped, .actionMoved, .actionSplit,
             .planRecovered, .planRescheduled, .planUpdated, .itemDisplacedByHigherPriority,
             .captureCreated, .captureTriaged, .captureAttachedToGoal, .captureArchived,
             .commitmentCaptured, .commitmentRouted, .goalUpdated, .goalCompleted, .goalPaused,
             .goalScopeItemAdded, .goalScopeItemRemoved, .deliverableAdded, .deliverableRemoved,
             .recoveryAccepted, .recoveryDeclined, .recoveryDueToPriorityConflict,
             .userCorrectionAdded, .reviewCompleted:
            return true
        case .goalCreated, .goalArchived, .planCreated, .planScheduled, .planUnscheduled,
             .priorityChanged, .urgencyChanged, .deadlineChanged, .itemScheduled,
             .recommendationShown, .recommendationAccepted, .recommendationDismissed,
             .calendarContextObserved, .contextLensChanged, .contextInferred,
             .syncConflictDetected, .accessibilityAuditRecorded, .exportCreated, .importCompleted:
            return false
        }
    }


    func receiptLabel(for receipt: ActionReceipt) -> String {
        switch receipt.resultState {
        case .needsConfirmation:
            return "Needs confirmation"
        case .failedSafely:
            return "No change made"
        case .draftedPrepared, .exportedPrepared:
            return "Prepared only"
        case .noOp:
            return "No change"
        case .completed:
            return "Completed"
        case .moved:
            return "Rescheduled"
        case .changed, .scheduled, .created, .attached, .detached, .undoAvailable, .undoUnavailable, .correctionAvailable:
            return receipt.correctionAvailability.isAvailable ? "Can be corrected" : "Receipt"
        }
    }


    func receiptIcon(for state: ActionReceiptResultState) -> String {
        switch state {
        case .completed:
            return "checkmark.circle"
        case .needsConfirmation:
            return "hand.tap"
        case .failedSafely:
            return "exclamationmark.shield"
        case .moved:
            return "clock.arrow.circlepath"
        case .draftedPrepared, .exportedPrepared:
            return "doc.badge.clock"
        case .created, .changed, .scheduled, .attached, .detached, .noOp, .undoAvailable, .undoUnavailable, .correctionAvailable:
            return "doc.text.magnifyingglass"
        }
    }


    func receiptState(for receipt: ActionReceipt) -> AmbitionVisualState {
        switch receipt.resultState {
        case .completed, .created, .attached:
            return .success
        case .needsConfirmation, .failedSafely:
            return .warning
        case .changed, .scheduled, .moved, .detached, .exportedPrepared, .draftedPrepared, .noOp, .undoAvailable, .undoUnavailable, .correctionAvailable:
            return .default
        }
    }


    func unique(_ items: [ReviewSignalItem]) -> [ReviewSignalItem] {
        var seen = Set<String>()
        return items.filter { seen.insert($0.id).inserted }
    }


    func unique(_ items: [ReviewCorrectionPrompt]) -> [ReviewCorrectionPrompt] {
        var seen = Set<String>()
        return items.filter { seen.insert($0.id).inserted }
    }
}
