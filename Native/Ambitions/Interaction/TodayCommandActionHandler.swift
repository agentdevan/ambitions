import Foundation

struct TodayCommandActionHandler {
    typealias FeedbackAction = (TodayInlineAction, Date) async throws -> TodayActionResponse

    private let repositories: AppRepositories
    private let feedbackAction: FeedbackAction

    init(
        repositories: AppRepositories,
        feedbackAction: @escaping FeedbackAction
    ) {
        self.repositories = repositories
        self.feedbackAction = feedbackAction
    }

    func performAction(
        _ action: TodayInlineAction,
        command: AmbitionsCommand,
        now: Date
    ) async throws -> TodayActionResponse {
        let validation = effectiveValidation(command: command, action: action)

        let goalID = action.target.goalID
        let beforeFeedback = try await preFeedbackEvents(for: goalID)
        let beforeEvidence = try await preEvidenceRecords(goalID: goalID)
        let beforeCaptures = try await repositories.captures.listCaptures()

        if validation != .valid {
            let result = blockedCommandResult(for: validation, command: command)
            await persistCommandExecution(command: command, result: result, at: now)
            return blockedActionResponse(for: validation)
        }

        let response = try await feedbackAction(action, now)

        let afterFeedback = try await preFeedbackEvents(for: goalID)
        let afterEvidence = try await preEvidenceRecords(goalID: goalID)
        let afterCaptures = try await repositories.captures.listCaptures()
        let newCaptures = newCaptures(before: beforeCaptures, after: afterCaptures)

        let eventLedgerEntryIDs = await emitTodayCommandEvidence(
            for: action,
            command: command,
            now: now,
            goalID: goalID,
            beforeFeedback: beforeFeedback,
            afterFeedback: afterFeedback,
            beforeEvidence: beforeEvidence,
            afterEvidence: afterEvidence,
            beforeCaptures: beforeCaptures,
            afterCaptures: afterCaptures
        )
        let result = makeCommandExecutionResult(
            validation: validation,
            command: command,
            action: action,
            eventLedgerEntryIDs: eventLedgerEntryIDs,
            resultTarget: commandResultTarget(
                command: command,
                action: action,
                newCaptures: newCaptures
            )
        )
        await persistCommandExecution(command: command, result: result, at: now)

        return response
    }

    private func preFeedbackEvents(for goalID: String?) async throws -> [GoalFeedbackEvent] {
        guard let goalID else { return [] }
        return try await repositories.feedback.listEvents(goalID: goalID)
    }

    private func preEvidenceRecords(goalID: String?) async throws -> [ProgressEvidence] {
        try await repositories.evidence.listEvidence(goalID: goalID)
    }

    private func persistCommandExecution(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        at timestamp: Date
    ) async {
        let recordedAt = Self.iso.string(from: timestamp)
        let record = AmbitionsCommandExecutionRecord(
            command: command,
            result: result,
            recordedAt: recordedAt
        )
        try? await repositories.commandExecutionRecords?.append(record)
        await appendRuntimeEvent(command: command, result: result, recordedAt: recordedAt, commandRecordID: record.id)
    }

    private func appendRuntimeEvent(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        recordedAt: String,
        commandRecordID: String
    ) async {
        guard let runtimeEvents = repositories.runtimeEvents else { return }
        let event = RuntimeEvent.commandExecution(
            command: command,
            result: result,
            recordedAt: recordedAt,
            commandRecordID: commandRecordID
        )
        _ = try? await runtimeEvents.append(event)
    }

    private func effectiveValidation(
        command: AmbitionsCommand,
        action: TodayInlineAction
    ) -> AmbitionsCommandValidationState {
        let commandValidation = AmbitionsCommandValidator().validate(command)
        guard commandValidation == .valid else { return commandValidation }
        guard Self.requiresActionTarget(action.kind) else { return .valid }
        return action.target.goalID == nil || action.target.stepID == nil ? .needsMissingTarget : .valid
    }

    private static func requiresActionTarget(_ kind: TodayActionKind) -> Bool {
        switch kind {
        case .complete, .defer, .reschedule, .split, .askForHelp, .askWhyThisMatters, .quickLog:
            return true
        default:
            return false
        }
    }

    private func makeCommandExecutionResult(
        validation: AmbitionsCommandValidationState,
        command: AmbitionsCommand,
        action: TodayInlineAction,
        eventLedgerEntryIDs: [String],
        resultTarget: AmbitionsCommandTarget
    ) -> AmbitionsCommandExecutionResult {
        let status: AmbitionsCommandExecutionStatus = eventLedgerEntryIDs.isEmpty ? .noOp : .succeeded
        return AmbitionsCommandExecutionResult(
            status: status,
            summary: status == .succeeded ? "Today command completed." : "Today command changed nothing.",
            target: resultTarget,
            eventLedgerEntryIDs: eventLedgerEntryIDs,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "commandSource": command.source.rawValue,
                "todayAction": action.kind.rawValue,
                "hapticIntent": HapticPolicy.intent(for: action.kind).rawValue,
                "validation": validation.rawValue,
                "stageActionPipelineTaxonomy": StageActionTaxonomy.productRuntime.rawValue,
                "stageActionPipelineCommandValidation": StageActionPipelineRequirementState.satisfied.rawValue,
                "stageActionPipelineRuntimeMutation": status == .succeeded ? StageActionPipelineRequirementState.satisfied.rawValue : StageActionPipelineRequirementState.unavailable.rawValue,
                "stageActionPipelineVisibleMutation": status == .succeeded ? StageActionPipelineRequirementState.satisfied.rawValue : StageActionPipelineRequirementState.unavailable.rawValue,
                "stageActionPipelineProofReceipt": eventLedgerEntryIDs.isEmpty ? StageActionPipelineRequirementState.unavailable.rawValue : StageActionPipelineRequirementState.satisfied.rawValue,
                "stageActionPipelineAccessibilityAnnouncement": TodayInteractions.accessibilityAnnouncement(for: TodayInteractions.intent(for: action)),
                "stageActionPipelineFallbackUndo": StageActionPipelineRequirementState.satisfied.rawValue
            ]
        )
    }

    private func commandResultTarget(
        command: AmbitionsCommand,
        action: TodayInlineAction,
        newCaptures: [Capture]
    ) -> AmbitionsCommandTarget {
        guard command.kind == .quickCapture || action.kind == .quickLog,
              let capture = newCaptures.first else {
            return command.target
        }
        return AmbitionsCommandTarget(
            goalID: command.target.goalID ?? capture.linkedGoalID,
            captureID: capture.id,
            stepID: command.target.stepID,
            destination: command.target.destination
        )
    }

    private func blockedCommandResult(
        for validation: AmbitionsCommandValidationState,
        command: AmbitionsCommand
    ) -> AmbitionsCommandExecutionResult {
        let status: AmbitionsCommandExecutionStatus
        let summary: String
        switch validation {
        case .valid:
            status = .noOp
            summary = "Command is valid."
        case .invalid:
            status = .failed
            summary = "Command payload is invalid."
        case .needsConfirmation:
            status = .requiresConfirmation
            summary = "Command needs confirmation before it can execute."
        case .needsMissingTarget:
            status = .blocked
            summary = "Command is missing the target needed for safe execution."
        case .unsupportedInThisBuild:
            status = .unsupported
            summary = "Command is unsupported in this build."
        case .blockedByMissingFoundation:
            status = .blocked
            summary = "Command is blocked by missing foundation work."
        }

        return AmbitionsCommandExecutionResult(
            status: status,
            summary: summary,
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "validation": validation.rawValue,
                "stageActionPipelineTaxonomy": StageActionTaxonomy.productRuntime.rawValue,
                "stageActionPipelineCommandValidation": StageActionPipelineRequirementState.blocked.rawValue,
                "stageActionPipelineRuntimeMutation": StageActionPipelineRequirementState.blocked.rawValue,
                "stageActionPipelineVisibleMutation": StageActionPipelineRequirementState.blocked.rawValue,
                "stageActionPipelineProofReceipt": StageActionPipelineRequirementState.unavailable.rawValue,
                "stageActionPipelineAccessibilityAnnouncement": "Action not available.",
                "stageActionPipelineFallbackUndo": StageActionPipelineRequirementState.satisfied.rawValue
            ]
        )
    }

    private func blockedActionResponse(for validation: AmbitionsCommandValidationState) -> TodayActionResponse {
        let body: String
        switch validation {
        case .valid:
            body = "Command is valid."
        case .invalid:
            body = "This action needs a clearer command before Ambitions can change anything."
        case .needsConfirmation:
            body = "Review this action before Ambitions changes anything."
        case .needsMissingTarget:
            body = "This action needs a real Step or source object before Ambitions can change anything."
        case .unsupportedInThisBuild:
            body = "This action is not available in this build."
        case .blockedByMissingFoundation:
            body = "This action is waiting on foundation work before it can run."
        }
        return TodayActionResponse(
            message: TodayInlineMessage(
                title: "Action not available",
                body: body,
                state: .warning
            )
        )
    }

    private func emitTodayCommandEvidence(
        for action: TodayInlineAction,
        command: AmbitionsCommand,
        now: Date,
        goalID: String?,
        beforeFeedback: [GoalFeedbackEvent],
        afterFeedback: [GoalFeedbackEvent],
        beforeEvidence: [ProgressEvidence],
        afterEvidence: [ProgressEvidence],
        beforeCaptures: [Capture],
        afterCaptures: [Capture]
    ) async -> [String] {
        let beforeFeedbackIDs = Set(beforeFeedback.map(\.base.id))
        let beforeEvidenceIDs = Set(beforeEvidence.map(\.id))
        let newFeedback = afterFeedback.filter { beforeFeedbackIDs.contains($0.base.id) == false }
        let newEvidence = afterEvidence.filter { beforeEvidenceIDs.contains($0.id) == false }
        let newCaptures = newCaptures(before: beforeCaptures, after: afterCaptures)

        guard !newFeedback.isEmpty || !newEvidence.isEmpty || !newCaptures.isEmpty else {
            return []
        }
        guard let goalID else { return [] }

        var eventLedgerEntryIDs: [String] = []

        for event in newFeedback {
            let entry = EventLedgerEntry.fromFeedbackEvent(event, goalID: goalID, source: .today)
            do {
                try await repositories.eventLedger.append(entry)
                eventLedgerEntryIDs.append(entry.id)
            } catch {
                // Keep command behavior alive even if ledger emission fails.
            }
        }

        for evidence in newEvidence {
            let entry = EventLedgerEntry.fromProgressEvidence(evidence, source: .today)
            do {
                try await repositories.eventLedger.append(entry)
                eventLedgerEntryIDs.append(entry.id)
            } catch {
                // Keep command behavior alive even if ledger emission fails.
            }
        }

        for capture in newCaptures where action.kind == .quickLog {
            let entry = commandCaptureCreatedEntry(
                capture: capture,
                command: command,
                occurredAt: Self.iso.string(from: now)
            )
            do {
                try await repositories.eventLedger.append(entry)
                eventLedgerEntryIDs.append(entry.id)
            } catch {
                // Keep command behavior alive even if ledger emission fails.
            }
        }

        return eventLedgerEntryIDs
    }

    private func newCaptures(before: [Capture], after: [Capture]) -> [Capture] {
        let beforeCaptureIDs = Set(before.map(\.id))
        return after.filter { beforeCaptureIDs.contains($0.id) == false }
    }

    private func commandCaptureCreatedEntry(
        capture: Capture,
        command: AmbitionsCommand,
        occurredAt: String
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: "ledger.command.\(command.id)",
            kind: .captureCreated,
            occurredAt: occurredAt,
            source: eventLedgerSource(for: command.source),
            goalID: command.target.goalID,
            captureID: capture.id,
            title: "Capture created",
            summary: nil,
            semanticState: command.kind.rawValue,
            tone: .neutral,
            trust: EventLedgerTrustMetadata(isUserConfirmed: command.actor == .user),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: command.id,
                    kind: .externalCommand,
                    occurredAt: command.requestedAt,
                    summary: command.kind.rawValue
                ),
                EventLedgerEvidenceReference(
                    id: capture.id,
                    kind: .capture,
                    occurredAt: capture.createdAt,
                    summary: "quick_capture"
                )
            ],
            metadata: [
                "commandKind": command.kind.rawValue,
                "commandSource": command.source.rawValue,
                "sourceSurface": command.sourceSurface ?? ""
            ].filter { $0.value.isEmpty == false },
            payload: [
                "captureID": capture.id,
                "contextLens": command.payload.contextLens?.rawValue ?? "",
                "commitmentKind": command.payload.commitmentKind?.rawValue ?? ""
            ].filter { $0.value.isEmpty == false },
            privacy: .privateUserText
        )
    }

    private func eventLedgerSource(for source: AmbitionsCommandSource) -> EventLedgerSource {
        switch source {
        case .today:
            return .today
        case .goals, .goalDetail:
            return .goals
        case .capture:
            return .capture
        case .time:
            return .plan
        case .you:
            return .you
        case .reviews:
            return .you
        case .widget, .liveActivity, .appIntent, .notification, .deepLink, .system:
            return .system
        }
    }

    private static var iso: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}
