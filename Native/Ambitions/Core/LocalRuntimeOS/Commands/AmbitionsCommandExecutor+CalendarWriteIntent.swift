import Foundation

extension AmbitionsCommandExecutor {
    func executeConfirmedCalendarWriteIntent(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        guard command.payload.metadata["calendarWriteIntent"] == "true" else {
            return blockedResult(for: .needsMissingTarget, command: command)
        }

        let intent = scheduleMutationIntent(for: command)
        guard let intent else {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Calendar write intent is confirmed but missing or invalid schedule intent metadata.",
                target: command.target,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
                metadata: [
                    "blockedBy": "calendar_write_metadata_missing",
                    "calendarWriteIntent": "true"
                ]
            )
        }

        let destinationStepID = command.target.stepID ?? command.payload.metadata["destinationStepID"]
        let destinationStepTitle = command.payload.metadata["destinationStepTitle"]
        let originalBlockID = command.payload.metadata["originalBlockID"] ?? command.target.timeID
        let displacedDisposition = command.payload.metadata["displacedDisposition"] ?? "not_displaced"
        let destinationStepPressure = command.payload.metadata["destinationStepPressure"]
        let originStepPressure = command.payload.metadata["originStepPressure"]
        let lifeshapeImpact = command.payload.metadata["lifeshapeImpact"] ?? "recalculated_before_commit"

        let scheduleBlock = ScheduledAmbitionsBlock(
            id: intent.blockID,
            title: intent.title,
            start: intent.start,
            end: intent.end,
            contextLens: intent.contextLens,
            relatedGoalID: intent.relatedGoalID ?? command.target.goalID,
            relatedCaptureID: intent.relatedCaptureID ?? command.target.captureID,
            isUserConfirmed: true
        )

        let sourceRecordID = scheduleBlock.localScheduleSourceRecordID
        do {
            let scheduleRepository = FileLocalScheduleBlockRepository(fileURL: scheduleStoreURL())
            _ = try await scheduleRepository.upsertBlock(scheduleBlock)
        } catch {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Calendar write intent could not be written locally.",
                target: command.target,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
                metadata: [
                    "blockedBy": "calendar_write_store_error",
                    "calendarWriteIntent": "true",
                    "error": String(describing: error)
                ]
            )
        }

        var eventLedgerEntryIDs: [String] = []
        let scheduleReceiptID = scheduleBlock.localScheduleReceiptID(action: "save")
        let replayTraceID = scheduleBlock.localScheduleReplayTraceID(action: "save")
        if context.allowsEventLedgerEmission, let eventLedger {
            let event = EventLedgerEntry(
                id: "ledger.schedule.mutation.\(command.id)",
                kind: .planScheduled,
                occurredAt: DomainTimestamp.string(from: context.now),
                source: .plan,
                goalID: command.target.goalID,
                captureID: command.target.captureID,
                planID: command.target.timeID,
                title: "Schedule mutation recorded",
                summary: "Time mutation was confirmed and persisted locally.",
                semanticState: command.kind.rawValue,
                tone: .neutral,
                trust: EventLedgerTrustMetadata(
                    isUserConfirmed: true,
                    requiresReview: false
                ),
                evidenceReferences: [
                    EventLedgerEvidenceReference(
                        id: scheduleBlock.id,
                        kind: .plan,
                        occurredAt: DomainTimestamp.string(from: context.now),
                        summary: "schedule block mutation"
                    )
                ],
                metadata: [
                    "sourceRecordID": sourceRecordID,
                    "receiptID": scheduleReceiptID,
                    "replayTraceID": replayTraceID
                ].merging(intent.metadata, uniquingKeysWith: { _, new in new }),
                payload: [
                    "receipt": scheduleReceiptID,
                    "replayTrace": replayTraceID,
                    "destinationStepID": destinationStepID ?? "",
                    "originalBlockID": originalBlockID ?? "",
                    "displacedDisposition": displacedDisposition,
                    "start": DomainTimestamp.string(from: intent.start),
                    "end": DomainTimestamp.string(from: intent.end),
                    "lifeshapeImpact": lifeshapeImpact
                ].filter { $0.value.isEmpty == false }
            )
            do {
                try await eventLedger.append(event)
                eventLedgerEntryIDs = [event.id]
            } catch {
                // Preserve local safety contract: no mutation without local receipt,
                // but event projection is best-effort when storage is unavailable.
            }
        }

        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Schedule mutation was written locally after confirmation.",
            target: AmbitionsCommandTarget(
                goalID: command.target.goalID,
                captureID: command.target.captureID,
                timeID: intent.blockID,
                stepID: destinationStepID,
                destination: .time
            ),
            eventLedgerEntryIDs: eventLedgerEntryIDs,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "commandID": command.id,
                "calendarWriteIntent": "true",
                "approvalState": "confirmed",
                "userConfirmed": command.payload.metadata["userConfirmed"] ?? "true",
                "sourceRecordID": sourceRecordID,
                "receiptID": scheduleReceiptID,
                "replayTraceID": replayTraceID,
                "approvedDurationMinutes": String(intent.approvedDurationMinutes),
                "originalBlockID": originalBlockID ?? "",
                "destinationStepID": destinationStepID ?? "",
                "destinationStepTitle": destinationStepTitle ?? "",
                "destinationStepPressure": destinationStepPressure ?? "",
                "originStepPressure": originStepPressure ?? "",
                "displacedDisposition": displacedDisposition,
                "lifeshapeImpact": lifeshapeImpact
            ].merging(intent.metadata, uniquingKeysWith: { _, new in new })
        )
    }
}
