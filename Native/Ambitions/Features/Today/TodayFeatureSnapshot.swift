import Foundation

extension RepositoryBackedTodayService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let captures: [Capture]
        let eventLedger: [EventLedgerEntry]
        let appState: AppStateSnapshot
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let captures = repositories.captures.listCaptures()
        async let eventLedger = repositories.eventLedger.fetchRecent(limit: 20)
        async let appState = repositories.appState.loadState()
        let baseFeedback = try await repositories.feedback.listEvents(goalID: nil)
        let receiptHistoryRecords = try await receiptHistoryRecords()
        let rejectionFeedback = rejectionFeedbackEvents(from: receiptHistoryRecords)
        let accomplishmentFeedback = accomplishmentFeedbackEvents(from: receiptHistoryRecords)
        let feedback = Self.sortedFeedbackEvents(baseFeedback + rejectionFeedback + accomplishmentFeedback)

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures,
            eventLedger: eventLedger,
            appState: appState
        )
    }

    func recordRecommendationRejection(_ input: TodayRecommendationRejectionInput) async throws -> TodayActionResponse {
        let receipt = ActionReceipt.stepRejectedReceipt(
            id: "today.rejection.\(input.candidateID).\(input.recordedAt)",
            candidateID: input.candidateID,
            sourceStepID: input.sourceStepID,
            sourceCandidateID: input.sourceCandidateID,
            reason: input.reason,
            contextFingerprint: input.contextFingerprint,
            recordedAt: input.recordedAt,
            customReasonText: input.customText,
            skippedReason: input.skippedReason
        )
        let record = ActionReceiptHistoryRecord(
            receipt: receipt,
            privacyLevel: input.reason.code.isSensitive ? .sensitive : .safeToShow,
            localOnly: true
        )

        guard let historyRepository = repositories.actionReceiptHistory else {
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Not this saved locally",
                    body: "The current Today service does not have a receipt history repository wired, so the rejection could not be persisted here.",
                    state: .warning
                )
            )
        }

        try await historyRepository.save([record])
        return TodayActionResponse(
            message: TodayInlineMessage(
                title: input.skippedReason ? "Reason skipped" : "Reason saved",
                body: input.skippedReason
                    ? "Ambitions saved a local receipt and will learn less from the skipped reason."
                    : "Ambitions saved a local receipt and will use the reason to adjust future recommendations.",
                state: input.skippedReason ? .warning : .selected
            )
        )
    }
}

private extension RepositoryBackedTodayService {
    func receiptHistoryRecords() async throws -> [ActionReceiptHistoryRecord] {
        guard let historyRepository = repositories.actionReceiptHistory else {
            return []
        }

        return try await historyRepository.listRecords()
    }

    func rejectionFeedbackEvents(from records: [ActionReceiptHistoryRecord]) -> [GoalFeedbackEvent] {
        records.compactMap(rejectionFeedbackEvent(from:))
    }

    func accomplishmentFeedbackEvents(from records: [ActionReceiptHistoryRecord]) -> [GoalFeedbackEvent] {
        records.compactMap(accomplishmentFeedbackEvent(from:))
    }

    func rejectionFeedbackEvent(from record: ActionReceiptHistoryRecord) -> GoalFeedbackEvent? {
        guard record.receipt.sourceDomain == .today else { return nil }
        guard record.receipt.changedFacts.contains(where: { Self.isRecommendationRejectionKind($0.kind) }) else { return nil }
        let reason = record.receipt.changedFacts.first(where: { Self.isRecommendationRejectionKind($0.kind) && $0.fieldName == "rejectionReason" })?.newValueSummary
        let mappedReason = StepCandidateRejectionReasonCode(rawValue: reason ?? "") ?? .custom
        let skipReason = mappedSkipReason(from: mappedReason)
        let base = GoalFeedbackEventBase(
            id: "feedback.\(record.receipt.id)",
            stepID: record.receipt.changedFacts.first(where: { Self.isRecommendationRejectionKind($0.kind) && $0.fieldName == "rejectionReason" })?.object?.id ?? record.receipt.sourceObject?.id ?? record.receipt.id,
            occurredAt: record.receipt.occurredAt,
            note: record.receipt.title
        )
        return .skipped(base: base, reasonCode: skipReason)
    }

    func accomplishmentFeedbackEvent(from record: ActionReceiptHistoryRecord) -> GoalFeedbackEvent? {
        guard record.localOnly else { return nil }
        guard record.receipt.sourceDomain == .today else { return nil }
        guard record.receipt.resultState == .completed else { return nil }
        guard record.hasProofBridge else { return nil }
        guard let completionFact = record.receipt.changedFacts.first(where: { Self.isCompletionFactKind($0.kind) }) else { return nil }

        let stepID = completionFact.object?.id
            ?? record.receipt.sourceObject?.id
            ?? record.receipt.affectedObjects.first?.id
            ?? record.receipt.id

        let base = GoalFeedbackEventBase(
            id: "feedback.\(record.receipt.id)",
            stepID: stepID,
            occurredAt: record.receipt.occurredAt,
            note: record.receipt.summary
        )
        return .completed(base: base, actualDuration: nil, effortLevel: .medium, confidenceDelta: nil)
    }

    func mappedSkipReason(from rejectionReason: StepCandidateRejectionReasonCode) -> GoalStepSkipReasonCode {
        switch rejectionReason {
        case .tooLong, .notEnoughTime:
            return .notNow
        case .tooHard, .tooMuchEnergy:
            return .tooHard
        case .wrongLocation, .noEquipment, .noTransportation, .blockedBySomeoneElse:
            return .blockedExternal
        case .emotionallyNotReady, .unsafeInjuryConcern:
            return .notReady
        case .alreadyDidSimilar, .notUseful, .boringLowMotivation, .preferDifferentPath, .tooEasy, .custom:
            return .avoidance
        }
    }

    static func sortedFeedbackEvents(_ events: [GoalFeedbackEvent]) -> [GoalFeedbackEvent] {
        events.sorted {
            if $0.base.occurredAt != $1.base.occurredAt {
                return $0.base.occurredAt > $1.base.occurredAt
            }
            return $0.base.id > $1.base.id
        }
    }

    static func isRecommendationRejectionKind(_ kind: ActionReceiptChangedFactKind) -> Bool {
        switch kind {
        case .stepRejected, .rejectionReasonSaved, .rejectedCandidateSuppressed, .preferenceLearned, .candidateRejectedByConstraint:
            return true
        default:
            return false
        }
    }

    static func isCompletionFactKind(_ kind: ActionReceiptChangedFactKind) -> Bool {
        switch kind {
        case .completedAction, .completedTask:
            return true
        default:
            return false
        }
    }
}
