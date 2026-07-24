import Foundation

extension AmbitionsCommandExecutor {
    func executeConfirmedCalendarWriteIntent(
        _ command: AmbitionsCommand,
        context _: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        guard let calendarWrite = command.calendarWriteCommandIntent else {
            return blockedResult(for: .needsMissingTarget, command: command)
        }
        switch calendarWrite.operationIdentityProvenance {
        case .currentRequired, .legacyExplicit:
            guard calendarWrite.operationID != nil else {
                return blockedCalendarIdentityResult(command)
            }
        case .legacyAbsent:
            guard calendarWrite.operationID == nil else {
                return blockedCalendarIdentityResult(command)
            }
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

        let destinationStepID = calendarWrite.destinationStepID?.rawValue
        let destinationStepTitle = calendarWrite.destinationStepTitle
        let originalBlockID = calendarWrite.originalBlockID?.rawValue
        let displacedDisposition = calendarWrite.displacedDisposition.rawValue
        let destinationStepPressure = calendarWrite.destinationStepPressure?.rawValue
        let originStepPressure = calendarWrite.originStepPressure?.rawValue
        let lifeshapeImpact = calendarWrite.lifeshapeImpact.rawValue

        let scheduleBlock = ScheduledAmbitionsBlock(
            id: intent.blockID,
            title: intent.title,
            start: intent.start,
            end: intent.end,
            contextLens: intent.contextLens,
            relatedGoalID: intent.relatedGoalID?.rawValue ?? command.target.goalID,
            relatedCaptureID: intent.relatedCaptureID?.rawValue ?? command.target.captureID,
            isUserConfirmed: true
        )

        return AmbitionsCommandExecutionResult(
            status: .noOp,
            summary: "Calendar mutation was prepared; an accepted runtime authority transaction is still required.",
            target: AmbitionsCommandTarget(
                goalID: command.target.goalID,
                captureID: command.target.captureID,
                timeID: intent.blockID,
                stepID: destinationStepID,
                destination: .time
            ),
            eventLedgerEntryIDs: [],
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "commandID": command.id,
                "calendarWriteIntent": "true",
                "preparationState": "authority_required",
                "userConfirmed": calendarWrite.userConfirmed ? "true" : "false",
                "calendarOperationIdentityProvenance": calendarWrite.operationIdentityProvenance.rawValue,
                "externalEffectOperationID": calendarWrite.operationID?.rawValue ?? "",
                "proposedScheduleBlockID": scheduleBlock.id,
                "approvedDurationMinutes": String(intent.approvedDurationMinutes),
                "originalBlockID": originalBlockID ?? "",
                "destinationStepID": destinationStepID ?? "",
                "destinationStepTitle": destinationStepTitle ?? "",
                "destinationStepPressure": destinationStepPressure ?? "",
                "originStepPressure": originStepPressure ?? "",
                "displacedDisposition": displacedDisposition,
                "lifeshapeImpact": lifeshapeImpact
            ].filter { $0.value.isEmpty == false }
                .merging(intent.metadata, uniquingKeysWith: { _, new in new })
        )
    }

    private func blockedCalendarIdentityResult(_ command: AmbitionsCommand) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Calendar intent has inconsistent operation identity provenance.",
            target: command.target,
            metadata: ["blockedBy": "invalid_calendar_operation_identity"]
        )
    }
}
