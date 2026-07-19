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
    let runtimeCommandClient: RuntimeCommandClient?

    init(repositories: AppRepositories, runtimeCommandClient: RuntimeCommandClient? = nil) {
        actionReceiptHistory = repositories.actionReceiptHistory
        self.runtimeCommandClient = runtimeCommandClient
    }

    init(
        actionReceiptHistory: any ActionReceiptHistoryRepository,
        runtimeCommandClient: RuntimeCommandClient
    ) {
        self.actionReceiptHistory = actionReceiptHistory
        self.runtimeCommandClient = runtimeCommandClient
    }

    func recordRecommendationRejection(_ input: TodayRecommendationRejectionInput) async throws -> TodayActionResponse {
        guard actionReceiptHistory != nil, let runtimeCommandClient else {
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Not this saved locally",
                    body: "The current Today runtime does not have receipt history wired, so the rejection could not be persisted here.",
                    state: .warning
                )
            )
        }

        let recordedAt = PersistedTemporalValue.date(from: input.recordedAt)
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
        let event = TodayReceiptDomainEvent(
            kind: .recommendationRejection,
            receipt: record.receipt,
            privacyLevel: record.privacyLevel,
            localOnly: record.localOnly,
            proofRelevance: record.proofRelevance,
            requiresConfirmationBeforeBroaderUse: record.requiresConfirmationBeforeBroaderUse
        )
        let command = rejectionCommand(for: input, eventPayload: try event.encodedCommandPayload())
        let response = await runtimeCommandClient.execute(
            command,
            CommandExecutionContext(now: recordedAt, actor: .user, sourceSurface: "today")
        )

        guard await hasCommittedTodayProjection(response, client: runtimeCommandClient) else {
            return TodayActionResponse(message: TodayInlineMessage(
                title: response.metadata["todayReceiptMaterialization"] == "needs_recovery"
                    ? "Reason saved; history needs recovery"
                    : "Reason not saved",
                body: "The durable Today receipt or matching read model was unavailable, so no success state was shown.",
                state: .warning
            ))
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
        guard actionReceiptHistory != nil, let runtimeCommandClient else {
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Closure receipt not saved",
                    body: "The current Today runtime does not have receipt history wired, so this closure stayed as a local preview.",
                    state: .warning
                )
            )
        }

        let occurredAt = DomainTimestamp.string(from: now)
        let record = closure.actionReceiptHistoryRecord(for: outcome, occurredAt: occurredAt)
        let peek = closure.proofReceiptPeek(for: outcome, occurredAt: occurredAt)
        let event = TodayReceiptDomainEvent(
            kind: .closure,
            receipt: record.receipt,
            privacyLevel: record.privacyLevel,
            localOnly: record.localOnly,
            proofRelevance: record.proofRelevance,
            requiresConfirmationBeforeBroaderUse: record.requiresConfirmationBeforeBroaderUse
        )
        let command = closureCommand(
            for: closure,
            outcome: outcome,
            occurredAt: occurredAt,
            eventPayload: try event.encodedCommandPayload()
        )
        let result = await runtimeCommandClient.execute(
            command,
            CommandExecutionContext(now: now, actor: .user, sourceSurface: "today")
        )
        guard await hasCommittedTodayProjection(result, client: runtimeCommandClient) else {
            return TodayActionResponse(message: TodayInlineMessage(
                title: result.metadata["todayReceiptMaterialization"] == "needs_recovery"
                    ? "Closure saved; history needs recovery"
                    : "Closure receipt not saved",
                body: "The durable Today receipt or matching read model was unavailable, so no success state was shown.",
                state: .warning
            ))
        }
        return TodayActionResponse(
            message: TodayInlineMessage(
                title: peek.title,
                body: "\(peek.subtitle). \(peek.privacyLabel). \(record.sourceRecordLabel). \(record.replayTraceLabel). You inspection can find this through local receipt history.",
                state: outcome.createsProof ? .success : .selected
            )
        )
    }

    private func rejectionCommand(for input: TodayRecommendationRejectionInput, eventPayload: String) -> AmbitionsCommand {
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
                    TodayReceiptDomainEvent.mutationMarkerKey: "true",
                    TodayReceiptDomainEvent.commandMetadataKey: eventPayload,
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
        occurredAt: String,
        eventPayload: String
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
                    TodayReceiptDomainEvent.mutationMarkerKey: "true",
                    TodayReceiptDomainEvent.commandMetadataKey: eventPayload,
                ]
            ),
            createdAt: occurredAt,
            actor: .user,
            sourceSurface: "today",
            relations: AmbitionsCommandRelations(goalIDs: [closure.target.goalID].compactMap { $0 }),
            privacy: .standard
        )
    }

    private func hasCommittedTodayProjection(
        _ result: AmbitionsCommandExecutionResult,
        client: RuntimeCommandClient
    ) async -> Bool {
        guard result.status == .succeeded,
              result.metadata["todayReceiptMaterialization"] == "saved_post_authority",
              result.metadata["runtimeReceiptID"]?.isEmpty == false,
              let projection = try? await client.projection(.today) else { return false }
        let ids = result.metadata["runtimeMaterializedProjectionCursorIDs"]?.split(separator: ",").map(String.init) ?? []
        let sequences = result.metadata["runtimeMaterializedProjectionCursorSequences"]?.split(separator: ",").compactMap { Int64($0) } ?? []
        let checksums = result.metadata["runtimeMaterializedProjectionCursorChecksums"]?.split(separator: ",").map(String.init) ?? []
        guard ids.count == sequences.count, ids.count == checksums.count,
              let index = ids.firstIndex(of: ProjectionID.today.rawValue) else { return false }
        return projection.projectionID == ProjectionID.today.rawValue &&
            projection.eventSequence == sequences[index] &&
            projection.cursorChecksum == checksums[index]
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
