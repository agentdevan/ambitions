import Foundation

extension AmbitionsCommandExecutor {

    func scheduleMutationIntent(
        for command: AmbitionsCommand
    ) -> (blockID: String, title: String, start: Date, end: Date, contextLens: NowContextLens, relatedGoalID: String?, relatedCaptureID: String?, metadata: [String: String], approvedDurationMinutes: Int)? {
        let metadata = command.payload.metadata
        guard let start = parseDate(from: metadata["startAt"] ?? metadata["start"]) else {
            return nil
        }

        let approvedDurationMinutes: Int
        if let requestedDurationText = metadata["approvedDurationMinutes"], let requestedDuration = Int(requestedDurationText), requestedDuration > 0 {
            approvedDurationMinutes = requestedDuration
        } else if let requestedDurationText = metadata["durationMinutes"], let requestedDuration = Int(requestedDurationText), requestedDuration > 0 {
            approvedDurationMinutes = requestedDuration
        } else {
            return nil
        }

        let metadataEnd = parseDate(from: metadata["endAt"] ?? metadata["end"])
        let resolvedEnd = metadataEnd ?? start.addingTimeInterval(TimeInterval(approvedDurationMinutes * 60))
        let resolvedDurationMinutes: Int
        if let metadataEnd {
            resolvedDurationMinutes = max(Int(metadataEnd.timeIntervalSince(start) / 60), 1)
        } else {
            resolvedDurationMinutes = approvedDurationMinutes
        }
        guard resolvedDurationMinutes > 0, resolvedEnd > start else { return nil }

        return (
            blockID: metadata["scheduleBlockID"] ?? command.id,
            title: command.payload.primaryText ?? command.payload.title ?? "Schedule block",
            start: start,
            end: resolvedEnd,
            contextLens: parseContextLens(from: metadata["contextLens"]) ?? command.payload.contextLens ?? .all,
            relatedGoalID: metadata["relatedGoalID"] ?? command.target.goalID,
            relatedCaptureID: metadata["relatedCaptureID"] ?? command.target.captureID,
            metadata: metadata,
            approvedDurationMinutes: resolvedDurationMinutes
        )
    }


    func parseDate(from isoString: String?) -> Date? {
        guard let isoString else { return nil }
        return DomainTimestamp.date(from: isoString)
    }


    func parseContextLens(from raw: String?) -> NowContextLens? {
        guard let raw else { return nil }
        return NowContextLens(rawValue: raw)
    }


    func scheduleStoreURL() -> URL {
        if let scheduleStoreFileURL {
            return scheduleStoreFileURL
        }
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("ambitions")
            .appendingPathComponent("local-schedule-blocks.json")
    }


    func captureResult(command: AmbitionsCommand, capture: Capture, summary: String) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: summary,
            route: .captureInbox,
            target: AmbitionsCommandTarget(goalID: capture.linkedGoalID ?? command.target.goalID, captureID: capture.id, destination: .captureInbox),
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs + capture.recommendationExplanationIDs,
            metadata: [
                "captureID": capture.id,
                "captureKind": capture.kind.rawValue,
                "captureRoute": capture.route.rawValue
            ]
        )
    }


    func blockedResult(
        for validation: AmbitionsCommandValidationState,
        command: AmbitionsCommand
    ) -> AmbitionsCommandExecutionResult {
        let status: AmbitionsCommandExecutionStatus
        switch validation {
        case .valid:
            status = .noOp
        case .invalid:
            status = .failed
        case .needsConfirmation:
            status = .requiresConfirmation
        case .needsMissingTarget:
            status = .blocked
        case .unsupportedInThisBuild:
            status = .unsupported
        case .blockedByMissingFoundation:
            status = .blocked
        }

        return AmbitionsCommandExecutionResult(
            status: status,
            summary: summary(for: validation),
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: ["validation": validation.rawValue]
        )
    }


    func summary(for validation: AmbitionsCommandValidationState) -> String {
        switch validation {
        case .valid:
            return "Command is valid."
        case .invalid:
            return "Command payload is invalid."
        case .needsConfirmation:
            return "Command needs confirmation before it can execute."
        case .needsMissingTarget:
            return "Command is missing the target needed for safe execution."
        case .unsupportedInThisBuild:
            return "Command is unsupported in this build."
        case .blockedByMissingFoundation:
            return "Command is blocked by missing foundation work."
        }
    }


    func captureSourceType(for source: AmbitionsCommandSource) -> CaptureSourceType {
        switch source {
        case .today:
            return .todayQuickCapture
        case .appIntent:
            return .appIntent
        case .notification:
            return .notification
        default:
            return .todayQuickCapture
        }
    }

    func captureSourceType(for command: AmbitionsCommand) -> CaptureSourceType {
        if let rawValue = command.payload.metadata[ExternalCreationCommandMetadataKey.sourceType],
           let sourceType = CaptureSourceType(rawValue: rawValue) {
            return sourceType
        }
        return captureSourceType(for: command.source)
    }

    func externalCreationTriageMetadata(for command: AmbitionsCommand) -> CaptureTriageMetadata? {
        guard let landingRawValue = command.payload.metadata[ExternalCreationCommandMetadataKey.landing],
              let landing = ExternalCreationLanding(rawValue: landingRawValue)
        else {
            return nil
        }

        let destination: CaptureTriageDestination = landing == .createGoal ? .turnIntoGoal : .doSoon
        return CaptureTriageMetadata(
            destination: destination,
            hint: command.payload.metadata[ExternalCreationCommandMetadataKey.provenanceHint]
        )
    }


    func captureKind(for commitmentKind: NowCommitmentKind?) -> CaptureKind? {
        switch commitmentKind {
        case .oneTime:
            return .oneTimeCommitment
        case .goalSupporting:
            return .goalSupportingTask
        case .waiting:
            return .waitingItem
        case .optionalSomeday:
            return .optionalSomeday
        case .recurring, .scheduledBlock, nil:
            return nil
        }
    }


    func route(for destinationRoute: String?) -> CaptureRoute? {
        CaptureRoute.commandDestinationRoute(destinationRoute)
    }
}
