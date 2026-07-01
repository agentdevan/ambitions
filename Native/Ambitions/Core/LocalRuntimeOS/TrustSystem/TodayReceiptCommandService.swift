import Foundation

protocol TodayReceiptCommanding: Sendable {
    func recordRecommendationRejection(_ input: TodayRecommendationRejectionInput) async throws -> TodayActionResponse
    func recordActionClosure(
        _ closure: TodayActionClosureSheetState,
        outcome: TodayActionClosureOutcomeState,
        now: Date
    ) async throws -> TodayActionResponse
}

struct TodayReceiptCommandService: TodayReceiptCommanding {
    let actionReceiptHistory: (any ActionReceiptHistoryRepository)?
    let committer: RuntimeCommandMutationCommitter

    init(repositories: AppRepositories) {
        actionReceiptHistory = repositories.actionReceiptHistory
        committer = RuntimeCommandMutationCommitter(
            commandJournal: repositories.commandJournal,
            commandExecutionRecords: repositories.commandExecutionRecords,
            runtimeEvents: repositories.runtimeEvents,
            projectionStore: repositories.projectionStore,
            searchIndex: repositories.searchIndex
        )
    }

    func recordRecommendationRejection(_ input: TodayRecommendationRejectionInput) async throws -> TodayActionResponse {
        guard let actionReceiptHistory else {
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Not this saved locally",
                    body: "The current Today runtime does not have receipt history wired, so the rejection could not be persisted here.",
                    state: .warning
                )
            )
        }

        let recordedAt = PersistedTemporalValue.date(from: input.recordedAt)
        let command = rejectionCommand(for: input)
        let response = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: recordedAt, actor: .user, sourceSurface: "today")
        ) {
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
            try await actionReceiptHistory.save([record])
            return AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: input.skippedReason ? "Recommendation rejection recorded without a reason." : "Recommendation rejection recorded.",
                route: .today,
                target: command.target,
                recommendationExplanationIDs: [input.contextFingerprint],
                metadata: [
                    "receiptID": record.id,
                    "rejectionReason": input.reason.storageLabel,
                    "skippedReason": input.skippedReason ? "true" : "false",
                    "sourceCandidateID": input.sourceCandidateID ?? "",
                    "sourceStepID": input.sourceStepID,
                ]
            )
        }

        return TodayActionResponse(
            message: TodayInlineMessage(
                title: input.skippedReason ? "Reason skipped" : "Reason saved",
                body: input.skippedReason
                    ? "Ambitions saved a local command receipt and will learn less from the skipped reason."
                    : "Ambitions saved a local command receipt and will use the reason to adjust future recommendations.",
                state: response.status == .succeeded ? (input.skippedReason ? .warning : .selected) : .warning
            )
        )
    }

    func recordActionClosure(
        _ closure: TodayActionClosureSheetState,
        outcome: TodayActionClosureOutcomeState,
        now: Date
    ) async throws -> TodayActionResponse {
        guard let actionReceiptHistory else {
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Closure receipt not saved",
                    body: "The current Today runtime does not have receipt history wired, so this closure stayed as a local preview.",
                    state: .warning
                )
            )
        }

        let occurredAt = DomainTimestamp.string(from: now)
        let command = closureCommand(for: closure, outcome: outcome, occurredAt: occurredAt)
        let record = closure.actionReceiptHistoryRecord(for: outcome, occurredAt: occurredAt)
        let peek = closure.proofReceiptPeek(for: outcome, occurredAt: occurredAt)
        let result: AmbitionsCommandExecutionResult = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now, actor: .user, sourceSurface: "today")
        ) {
            try await actionReceiptHistory.save([record])
            return AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Today closure receipt recorded.",
                route: .today,
                target: command.target,
                metadata: [
                    "receiptID": record.id,
                    "closureState": outcome.closureState.rawValue,
                    "objectTitle": closure.objectTitle,
                    "proofRelevance": record.proofRelevance.rawValue,
                ]
            )
        }

        let stageRecord = TodayClosureRecord(
            stepID: closure.target.stepID,
            goalID: closure.target.goalID,
            outcome: outcome.closureState,
            occurredAt: now
        )
        let stageMutation = TodayClosureStageMutation(
            record: stageRecord,
            stepTitle: closure.objectTitle,
            receiptSaved: result.status == .succeeded
        )
        return TodayActionResponse(
            message: TodayInlineMessage(
                title: peek.title,
                body: "\(peek.subtitle). \(peek.privacyLabel). \(record.sourceRecordLabel). \(record.replayTraceLabel). You inspection can find this through local receipt history.",
                state: outcome.createsProof ? .success : .selected
            ),
            stageMutation: stageMutation
        )
    }

    private func rejectionCommand(for input: TodayRecommendationRejectionInput) -> AmbitionsCommand {
        AmbitionsCommand(
            id: "today.rejection.command.\(input.candidateID).\(Self.commandIDComponent(input.recordedAt))",
            kind: .dismissRecommendation,
            source: .today,
            target: AmbitionsCommandTarget(
                stepID: input.sourceStepID,
                recommendationID: input.sourceCandidateID ?? input.candidateID,
                explanationID: input.contextFingerprint,
                destination: .today
            ),
            payload: AmbitionsCommandPayload(
                title: "Not this",
                notes: input.customText,
                metadata: [
                    "candidateID": input.candidateID,
                    "sourceCandidateID": input.sourceCandidateID ?? "",
                    "sourceStepID": input.sourceStepID,
                    "contextFingerprint": input.contextFingerprint,
                    "rejectionReason": input.reason.storageLabel,
                    "skippedReason": input.skippedReason ? "true" : "false",
                ]
            ),
            createdAt: input.recordedAt,
            actor: .user,
            sourceSurface: "today",
            relations: AmbitionsCommandRelations(recommendationExplanationIDs: [input.contextFingerprint]),
            privacy: input.reason.code.isSensitive ? .privateUserText : .standard
        )
    }

    private func closureCommand(
        for closure: TodayActionClosureSheetState,
        outcome: TodayActionClosureOutcomeState,
        occurredAt: String
    ) -> AmbitionsCommand {
        AmbitionsCommand(
            id: "today.closure.command.\(closure.id).\(outcome.id).\(Self.commandIDComponent(occurredAt))",
            kind: .completeAction,
            source: .today,
            target: AmbitionsCommandTarget(
                goalID: closure.target.goalID,
                stepID: closure.target.stepID,
                destination: .today
            ),
            payload: AmbitionsCommandPayload(
                title: closure.objectTitle,
                notes: closure.originalContext,
                metadata: [
                    "closureState": outcome.closureState.rawValue,
                    "closureOutcomeID": outcome.id,
                    "closureSheetID": closure.id,
                ]
            ),
            createdAt: occurredAt,
            actor: .user,
            sourceSurface: "today",
            relations: AmbitionsCommandRelations(goalIDs: [closure.target.goalID].compactMap { $0 }),
            privacy: .standard
        )
    }

    private static func commandIDComponent(_ value: String) -> String {
        value
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
