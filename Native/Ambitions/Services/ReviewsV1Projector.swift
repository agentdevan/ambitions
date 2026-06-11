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

private extension ReviewsV1Projector {
    func cadenceSummaries(
        input: ReviewsV1ProjectionInput,
        signalCount: Int,
        recoveryCount: Int
    ) -> [ReviewCadenceSummary] {
        [
            ReviewCadenceSummary(
                id: "review.cadence.weekly",
                cadence: .weekly,
                title: "Weekly Review",
                detail: signalCount == 0 ? "Weekly review appears after local actions, proof, receipts, or corrections exist." : "Turns recent local activity into keep, change, carry, and drop decisions.",
                statusLabel: signalCount == 0 ? "Waiting for local activity" : "Ready from local evidence",
                contextLabel: "You and Plan",
                state: signalCount == 0 ? .default : .selected
            ),
            ReviewCadenceSummary(
                id: "review.cadence.monthly",
                cadence: .monthly,
                title: "Monthly Review",
                detail: "Summarizes direction and proof as a calm review.",
                statusLabel: input.proofEvidence.isEmpty ? "Needs proof over time" : "Proof-aware summary",
                contextLabel: "You and Goals",
                state: input.proofEvidence.isEmpty ? .default : .success
            ),
            ReviewCadenceSummary(
                id: "review.cadence.recovery",
                cadence: .recovery,
                title: "Recovery Review",
                detail: recoveryCount == 0 ? "Shows up when a day or week changes shape." : "Names what recovered, what stayed protected, and what still needs a decision.",
                statusLabel: recoveryCount == 0 ? "Available when needed" : "Needs your review",
                contextLabel: "You, Plan, and Today",
                state: recoveryCount == 0 ? .default : .warning
            )
        ]
    }

    func periodSummary(
        input: ReviewsV1ProjectionInput,
        meaningfulCount: Int,
        receiptCount: Int,
        recoveryCount: Int,
        correctionCount: Int
    ) -> ReviewPeriodSummary {
        let signalCount = meaningfulCount + receiptCount + recoveryCount + correctionCount + input.proofEvidence.count
        let title: String
        let dominantTruth: String
        let state: AmbitionVisualState

        if signalCount == 0 {
            title = "Nothing to review yet"
            dominantTruth = "After more local activity, Reviews will summarize what happened in plain language."
            state = .default
        } else if recoveryCount > 0 {
            title = "Ready to review"
            dominantTruth = "Recent recovery and receipt signals are ready for a calm review."
            state = .selected
        } else {
            title = "Recent movement is visible"
            dominantTruth = "Ambitions has local evidence it can summarize into what happened and what should carry forward."
            state = .success
        }

        return ReviewPeriodSummary(
            title: title,
            subtitle: "Reviews turns execution history into trust, learning, and next-step clarity.",
            timeframeLabel: input.timeframeLabel,
            dominantTruth: dominantTruth,
            trustWhisper: "Stored locally. Suggested, not applied. No live sync, account system, calendar write, or accessibility verification claim is made here.",
            state: state
        )
    }

    func recoverySignals(from assessments: [ExecutionResilienceAssessment], events: [EventLedgerEntry]) -> [ReviewSignalItem] {
        let assessmentItems = assessments.flatMap { assessment in
            assessment.recoveryOptions.prefix(2).map { option in
                ReviewSignalItem(
                    id: "review.recovery.option.\(option.id)",
                    kind: .recovery,
                    title: option.title,
                    detail: option.summary,
                    valueLabel: option.requiresUserConfirmation ? "Suggested, not applied" : "Ready",
                    icon: option.strategy == .protectDeadlineWork ? "lock.shield" : "arrow.triangle.branch",
                    state: option.requiresUserConfirmation ? .warning : .selected
                )
            }
        }

        let eventItems = events.filter { [.planRecovered, .recoveryAccepted, .recoveryDeclined, .recoveryDueToPriorityConflict].contains($0.kind) }
            .prefix(3)
            .map { event in
                ReviewSignalItem(
                    id: "review.recovery.event.\(event.id)",
                    kind: .recovery,
                    title: event.title,
                    detail: event.summary ?? "Recovery context was recorded locally.",
                    valueLabel: event.kind == .recoveryDeclined ? "Not applied" : "Recovered",
                    icon: "lifepreserver",
                    state: event.kind == .recoveryDeclined ? .default : .success
                )
            }

        return unique(Array(assessmentItems.prefix(3)) + Array(eventItems))
    }

    func protectedSignals(from assessments: [ExecutionResilienceAssessment], events: [EventLedgerEntry]) -> [ReviewSignalItem] {
        let protected = assessments.flatMap(\.protectedHighPriorityWork).prefix(3).map { item in
            ReviewSignalItem(
                id: "review.protected.\(item.id)",
                kind: .recovery,
                title: item.title,
                detail: item.summary,
                valueLabel: "Safe from silent changes",
                icon: "lock.shield",
                state: .selected
            )
        }

        let displaced = events.filter { [.itemDisplacedByHigherPriority, .actionMoved, .actionDelayed].contains($0.kind) }
            .prefix(2)
            .map { event in
                ReviewSignalItem(
                    id: "review.moved.\(event.id)",
                    kind: .event,
                    title: event.title,
                    detail: event.summary ?? "A local action changed position or priority.",
                    valueLabel: event.kind == .itemDisplacedByHigherPriority ? "Rescheduled to protect priority" : "Rescheduled or deferred",
                    icon: "clock.arrow.circlepath",
                    state: .default
                )
            }

        return unique(Array(protected) + Array(displaced))
    }

    func reviewNeededSignals(
        from assessments: [ExecutionResilienceAssessment],
        events: [EventLedgerEntry],
        explanations: [RecommendationExplanation]
    ) -> [ReviewSignalItem] {
        var items: [ReviewSignalItem] = assessments.filter { [.needsRecovery, .atRisk, .blocked, .recovering].contains($0.status) }
            .prefix(3)
            .map { assessment in
                ReviewSignalItem(
                    id: "review.needs.\(assessment.id)",
                    kind: .recovery,
                    title: assessment.recommendedRecoveryOption?.title ?? "Needs a decision",
                    detail: assessment.recommendedRecoveryOption?.summary ?? "A recovery state needs review before Ambitions changes anything.",
                    valueLabel: "Needs your decision",
                    icon: "hand.tap",
                    state: .warning
                )
            }

        items += explanations.filter { $0.assumptions.isEmpty == false || $0.correctionActions.isEmpty == false }
            .prefix(2)
            .map { explanation in
                ReviewSignalItem(
                    id: "review.assumption.\(explanation.id)",
                    kind: .correction,
                    title: explanation.title,
                    detail: explanation.summary,
                    valueLabel: "Can be corrected",
                    icon: "checkmark.bubble",
                    state: .default
                )
            }

        items += events.filter { $0.trust.requiresReview }
            .prefix(2)
            .map { event in
                ReviewSignalItem(
                    id: "review.trust.\(event.id)",
                    kind: .event,
                    title: event.title,
                    detail: event.summary ?? "This local event asked for review.",
                    valueLabel: "Ready for your review",
                    icon: "exclamationmark.bubble",
                    state: .warning
                )
            }

        return unique(items)
    }

    func receiptSignals(from receipts: [ActionReceipt]) -> [ReviewSignalItem] {
        receipts.prefix(4).map { receipt in
            ReviewSignalItem(
                id: "review.receipt.\(receipt.id)",
                kind: .receipt,
                title: receipt.title,
                detail: receipt.summary,
                valueLabel: receiptLabel(for: receipt),
                icon: receiptIcon(for: receipt.resultState),
                state: receiptState(for: receipt)
            )
        }
    }

    func eventSignals(from events: [EventLedgerEntry]) -> [ReviewSignalItem] {
        events.filter(isMeaningfulForLifeReceipt)
            .prefix(5)
            .map { event in
                ReviewSignalItem(
                    id: "review.event.\(event.id)",
                    kind: .event,
                    title: event.title,
                    detail: event.summary ?? event.kind.reviewDetail,
                    valueLabel: event.kind.reviewLabel,
                    icon: event.kind.reviewIcon,
                    state: event.tone.reviewState
                )
            }
    }

    func proofHighlights(from evidence: [ProgressEvidence]) -> [ReviewProofHighlight] {
        evidence.sorted { lhs, rhs in
            if lhs.capturedAt != rhs.capturedAt { return lhs.capturedAt > rhs.capturedAt }
            return lhs.id < rhs.id
        }
        .prefix(3)
        .map { proof in
            ReviewProofHighlight(
                id: "review.proof.\(proof.id)",
                title: proof.note?.nilIfBlank ?? proof.evidenceKind.reviewTitle,
                detail: proof.evidenceKind.reviewDetail,
                valueLabel: "Proof recorded",
                state: .success
            )
        }
    }

    func correctionPrompts(
        from teachingSignals: [GoalTeachingSignal],
        events: [EventLedgerEntry],
        explanations: [RecommendationExplanation]
    ) -> [ReviewCorrectionPrompt] {
        var prompts = teachingSignals.filter { $0.disposition == .active }
            .prefix(3)
            .map { signal in
                ReviewCorrectionPrompt(
                    id: "review.correction.signal.\(signal.id)",
                    title: "Correction available",
                    detail: signal.userNote?.nilIfBlank ?? "A local teaching signal can shape future recommendations.",
                    actionLabel: "Supported where shown",
                    state: .selected
                )
            }

        prompts += events.filter { $0.kind == .userCorrectionAdded }
            .prefix(2)
            .map { event in
                ReviewCorrectionPrompt(
                    id: "review.correction.event.\(event.id)",
                    title: event.title,
                    detail: event.summary ?? "A correction was recorded locally.",
                    actionLabel: "Can be reviewed",
                    state: .success
                )
            }

        prompts += explanations.filter { $0.correctionActions.isEmpty == false }
            .prefix(2)
            .map { explanation in
                ReviewCorrectionPrompt(
                    id: "review.correction.explanation.\(explanation.id)",
                    title: "Assumption may need attention",
                    detail: explanation.summary,
                    actionLabel: "You can correct this",
                    state: .warning
                )
            }

        return unique(prompts)
    }

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

private extension EventLedgerKind {
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

private extension EventLedgerTone {
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

private extension ProgressEvidenceKind {
    var reviewTitle: String {
        switch self {
        case .stepCompleted:
            return "Step completed"
        case .habitCompletion:
            return "Recurring work completed"
        case .habitMinimumVersion:
            return "Minimum version completed"
        case .habitQuickLog:
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
        case .stepCompleted, .habitCompletion, .milestoneReached:
            return "This is proof of real progress you can use."
        case .habitMinimumVersion, .habitQuickLog, .sessionLogged:
            return "This proof can help keep the next step believable."
        case .reflectionLogged, .delegatedUpdate, .observationLogged:
            return "This proof adds context for future review."
        }
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
