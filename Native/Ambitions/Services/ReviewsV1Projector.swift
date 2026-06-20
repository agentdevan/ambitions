import AmbitionsDesignSystem
import Foundation

protocol ReviewsV1Projecting: Sendable {
    func project(_ input: ReviewsV1ProjectionInput) -> ReviewsV1Projection
}

struct ReviewsV1Projector: ReviewsV1Projecting {
    func project(_ input: ReviewsV1ProjectionInput) -> ReviewsV1Projection {
        let events = input.eventLedgerEntries.sorted { lhs, rhs in
            if lhs.occurredAt != rhs.occurredAt { return lhs.occurredAt > rhs.occurredAt }
            return lhs.id < rhs.id
        }
        let receiptProjection = ActionReceiptProjection(receipts: input.receipts)
        let receipts = receiptProjection.receipts
        let recoveryItems = recoverySignals(from: input.resilienceAssessments, events: events)
        let protectedItems = protectedSignals(from: input.resilienceAssessments, events: events)
        let reviewItems = reviewNeededSignals(from: input.resilienceAssessments, events: events, explanations: input.recommendationExplanations)
        let meaningfulEvents = eventSignals(from: events)
        let receiptHighlights = receiptSignals(from: receipts)
        let proof = proofHighlights(from: input.proofEvidence)
        let corrections = correctionPrompts(from: input.teachingSignals, events: events, explanations: input.recommendationExplanations)
        let carryForward = carryForwardItems(
            recoveryItems: recoveryItems,
            protectedItems: protectedItems,
            reviewItems: reviewItems,
            proof: proof,
            corrections: corrections,
            meaningfulEvents: meaningfulEvents
        )
        let recoveryCount = recoveryItems.count + protectedItems.count + reviewItems.count
        let progressLines = progressReceiptLines(
            receiptHighlights: receiptHighlights,
            meaningfulEvents: meaningfulEvents,
            recoveryItems: recoveryItems + protectedItems + reviewItems,
            proof: proof,
            corrections: corrections,
            carryForward: carryForward
        )
        let cadences = cadenceSummaries(
            input: input,
            signalCount: meaningfulEvents.count + receiptHighlights.count + recoveryCount + proof.count + corrections.count,
            recoveryCount: recoveryCount
        )
        let planningHandoffs = planningHandoffItems(carryForward: carryForward, reviewItems: reviewItems, proof: proof)
        let unavailable = unavailableNotes(calendarStatusLabel: input.calendarStatusLabel)

        return ReviewsV1Projection(
            id: "reviews.v1.\(input.generatedAt)",
            generatedAt: input.generatedAt,
            period: periodSummary(
                input: input,
                meaningfulCount: meaningfulEvents.count,
                receiptCount: receiptHighlights.count,
                recoveryCount: recoveryCount,
                correctionCount: corrections.count
            ),
            cadences: cadences,
            recovery: RecoveryReviewSummary(
                title: "Recovery Review",
                subtitle: "What changed, what stayed protected, and what still needs your decision.",
                statusLabel: recoveryItems.isEmpty && protectedItems.isEmpty && reviewItems.isEmpty ? "Nothing to review yet" : "Ready to review",
                whatRecovered: recoveryItems,
                whatWasProtected: protectedItems,
                needsReview: reviewItems,
                boundaryNotes: recoveryBoundaryNotes(calendarStatusLabel: input.calendarStatusLabel),
                emptyStateTitle: "No recovery activity yet",
                emptyStateDetail: "When a plan is reflowed, protected, deferred, or kept suggestion-only, the review will summarize it here."
            ),
            lifeOSReceipt: LifeOSReceiptSummary(
                title: "Life OS Receipt",
                subtitle: "A human summary of meaningful actions, receipts, and local evidence.",
                statusLabel: receiptHighlights.isEmpty && meaningfulEvents.isEmpty ? "No receipt yet" : "Based on recent actions",
                receiptHighlights: receiptHighlights,
                meaningfulEvents: meaningfulEvents,
                emptyStateTitle: "No receipt yet",
                emptyStateDetail: "Meaningful actions will appear here after Ambitions has a local event or Action Closure receipt to explain."
            ),
            progressLines: progressLines,
            proofHighlights: proof,
            correctionPrompts: corrections,
            carryForward: carryForward,
            planningHandoffs: planningHandoffs,
            unavailableNotes: unavailable,
            eventLedgerEntryIDs: events.map(\.id),
            receiptIDs: receipts.map(\.id),
            localOnly: true,
            schemaVersion: reviewsV1SchemaVersion
        )
    }
}


extension EventLedgerKind {
    var reviewLabel: String {
        switch self {
        case .actionCompleted, .goalCompleted:
            return "Completed"
        case .actionDelayed:
            return "Deferred"
        case .actionSkipped:
            return "Skipped"
        case .actionMoved, .planRescheduled:
            return "Rescheduled"
        case .actionSplit:
            return "Split"
        case .planRecovered, .recoveryAccepted, .recoveryDueToPriorityConflict:
            return "Recovered"
        case .recoveryDeclined:
            return "Not applied"
        case .itemDisplacedByHigherPriority:
            return "Kept in view"
        case .captureCreated, .captureTriaged, .captureAttachedToGoal, .captureArchived,
             .commitmentCaptured, .commitmentRouted:
            return "Routed"
        case .goalUpdated, .goalPaused, .goalScopeItemAdded, .goalScopeItemRemoved,
             .deliverableAdded, .deliverableRemoved, .planUpdated:
            return "Changed"
        case .userCorrectionAdded:
            return "Corrected"
        case .reviewCompleted:
            return "Reviewed"
        default:
            return "Recorded"
        }
    }

    var reviewIcon: String {
        switch self {
        case .actionCompleted, .goalCompleted:
            return "checkmark.circle"
        case .actionDelayed, .actionMoved, .planRescheduled:
            return "clock.arrow.circlepath"
        case .actionSkipped:
            return "forward.end"
        case .actionSplit:
            return "square.split.2x1"
        case .planRecovered, .recoveryAccepted, .recoveryDeclined, .recoveryDueToPriorityConflict:
            return "lifepreserver"
        case .itemDisplacedByHigherPriority:
            return "lock.shield"
        case .captureCreated, .captureTriaged, .captureAttachedToGoal, .captureArchived,
             .commitmentCaptured, .commitmentRouted:
            return "tray.full"
        case .userCorrectionAdded:
            return "checkmark.bubble"
        case .reviewCompleted:
            return "rectangle.stack.badge.play"
        default:
            return "doc.text"
        }
    }

    var reviewDetail: String {
        switch self {
        case .actionCompleted:
            return "An action was completed and can support proof."
        case .actionDelayed, .actionMoved, .actionSkipped:
            return "An action changed shape or timing."
        case .planRecovered, .recoveryAccepted, .recoveryDueToPriorityConflict:
            return "A recovery path was recorded."
        case .userCorrectionAdded:
            return "A correction was recorded locally."
        default:
            return "A meaningful local event was recorded."
        }
    }
}

extension EventLedgerTone {
    var reviewState: AmbitionVisualState {
        switch self {
        case .positive:
            return .success
        case .recovering, .correction:
            return .selected
        case .caution:
            return .warning
        case .neutral:
            return .default
        }
    }
}

extension ProgressEvidenceKind {
    var reviewTitle: String {
        switch self {
        case .stepCompleted:
            return "Step completed"
        case .ritualCompletion:
            return "Recurring work completed"
        case .ritualMinimumVersion:
            return "Minimum version completed"
        case .ritualQuickLog:
            return "Quick log recorded"
        case .sessionLogged:
            return "Session logged"
        case .reflectionLogged:
            return "Reflection recorded"
        case .delegatedUpdate:
            return "Delegated update recorded"
        case .observationLogged:
            return "Observation recorded"
        case .milestoneReached:
            return "Milestone reached"
        }
    }

    var reviewDetail: String {
        switch self {
        case .stepCompleted, .ritualCompletion, .milestoneReached:
            return "This is proof of real progress you can use."
        case .ritualMinimumVersion, .ritualQuickLog, .sessionLogged:
            return "This proof can help keep the next step believable."
        case .reflectionLogged, .delegatedUpdate, .observationLogged:
            return "This proof adds context for future review."
        }
    }
}

extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
