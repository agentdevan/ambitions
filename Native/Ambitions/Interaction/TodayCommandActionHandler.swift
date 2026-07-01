import Foundation

struct TodayCommandActionHandler {
    typealias FeedbackAction = (TodayInlineAction, Date) async throws -> TodayActionResponse

    let repositories: AppRepositories
    private let feedbackAction: FeedbackAction
    private let compiler: CommandCompiler
    private let receiptFactory: CommandReceiptFactory
    private let runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore
    private let runtimeValidator: RuntimeValidator

    init(
        repositories: AppRepositories,
        compiler: CommandCompiler = CommandCompiler(),
        receiptFactory: CommandReceiptFactory = CommandReceiptFactory(),
        runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore = RuntimeIdempotencyStore(),
        runtimeValidator: RuntimeValidator = RuntimeValidator(commandValidator: AmbitionsCommandValidator()),
        feedbackAction: @escaping FeedbackAction
    ) {
        self.repositories = repositories
        self.compiler = compiler
        self.receiptFactory = receiptFactory
        self.runtimeTransactionIdempotencyStore = runtimeTransactionIdempotencyStore
        self.runtimeValidator = runtimeValidator
        self.feedbackAction = feedbackAction
    }

    func performAction(
        _ action: TodayInlineAction,
        command: AmbitionsCommand,
        now: Date
    ) async throws -> TodayActionResponse {
        let replayAdapter = RuntimeEventCommandReplayAdapter(
            runtimeEvents: repositories.runtimeEvents,
            commandExecutionRecords: repositories.commandExecutionRecords
        )
        switch await replayAdapter.lookup(command) {
        case .runtimeEvent:
            return TodayActionResponse(message: nil)
        case .commandRecordWithoutRuntimeEvent(let record):
            let result = replayAdapter.commandRecordWithoutRuntimeEventResult(for: command, record: record)
            await persistCommandExecution(command: command, result: result, at: now)
            return blockedActionResponse(for: .blockedByMissingFoundation)
        case .lookupUnavailable:
            let result = replayAdapter.lookupUnavailableResult(for: command)
            await persistCommandExecution(command: command, result: result, at: now)
            return blockedActionResponse(for: .blockedByMissingFoundation)
        case .noRecord:
            break
        }

        let validation = effectiveValidation(command: command, action: action)
        let context = CommandExecutionContext(
            now: now,
            actor: command.actor,
            sourceSurface: command.sourceSurface
        )
        let compilation = compiler.compile(command, context: context, validation: validation)
        let journalReceipt: CommandJournalAppendReceipt
        do {
            journalReceipt = try await repositories.commandJournal.append(compilation.envelope)
        } catch {
            let result = commandJournalFailureResult(command: command, compilation: compilation, error: error)
            await persistCommandExecution(command: command, result: result, at: now, compilation: compilation)
            return blockedActionResponse(for: .blockedByMissingFoundation)
        }

        let goalID = action.target.goalID
        let beforeFeedback = try await preFeedbackEvents(for: goalID)
        let beforeEvidence = try await preEvidenceRecords(goalID: goalID)
        let beforeCaptures = try await repositories.captures.listCaptures()

        if validation != .valid {
            let result = blockedCommandResult(for: validation, command: command)
                .mergingMetadata(compilation.resultMetadata)
                .mergingMetadata(journalReceipt.resultMetadata)
            await persistCommandExecution(
                command: command,
                result: result,
                at: now,
                compilation: compilation,
                journalReceipt: journalReceipt
            )
            return blockedActionResponse(for: validation)
        }

        guard compilation.authorization.isAuthorized else {
            let result = compiler.authorizer.blockedResult(
                command: command,
                authorization: compilation.authorization
            )
            .mergingMetadata(compilation.resultMetadata)
            .mergingMetadata(journalReceipt.resultMetadata)
            await persistCommandExecution(
                command: command,
                result: result,
                at: now,
                compilation: compilation,
                journalReceipt: journalReceipt
            )
            return blockedActionResponse(for: .blockedByMissingFoundation)
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
        await persistCommandExecution(
            command: command,
            result: result
                .mergingMetadata(compilation.resultMetadata)
                .mergingMetadata(journalReceipt.resultMetadata),
            at: now,
            compilation: compilation,
            journalReceipt: journalReceipt
        )

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
        at timestamp: Date,
        compilation: CommandCompilation? = nil,
        journalReceipt: CommandJournalAppendReceipt? = nil
    ) async {
        let recordedAt = Self.iso.string(from: timestamp)
        let commandRecordID = "command.execution.\(command.id)"
        let transactionResult = await RuntimeTransactionCommitPolicy.resultByCommittingRuntimeTransaction(
            command: command,
            result: result,
            recordedAt: recordedAt,
            commandRecordID: commandRecordID,
            timestamp: timestamp,
            runtimeEvents: repositories.runtimeEvents,
            projectionStore: repositories.projectionStore,
            searchIndex: repositories.searchIndex,
            runtimeTransactionIdempotencyStore: runtimeTransactionIdempotencyStore,
            runtimeValidator: runtimeValidator,
            commandJournal: repositories.commandJournal,
            journalReceipt: journalReceipt
        )
        let commandReceipt = receiptFactory.makeReceipt(
            command: command,
            result: transactionResult,
            compilation: compilation,
            journalReceipt: journalReceipt,
            issuedAt: recordedAt
        )
        let enrichedResult = transactionResult.mergingMetadata(commandReceipt.resultMetadata)
        let record = AmbitionsCommandExecutionRecord(
            id: commandRecordID,
            command: command,
            result: enrichedResult,
            recordedAt: recordedAt
        )
        try? await repositories.commandExecutionRecords?.append(record)
    }

    private func commandJournalFailureResult(
        command: AmbitionsCommand,
        compilation: CommandCompilation,
        error: Error
    ) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Command journal append failed before mutation, so Ambitions skipped execution to preserve replay safety.",
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "blockedBy": "command_journal_append_failed",
                "commandJournalError": String(describing: error)
            ]
        )
        .mergingMetadata(compilation.resultMetadata)
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

    func newCaptures(before: [Capture], after: [Capture]) -> [Capture] {
        let beforeCaptureIDs = Set(before.map(\.id))
        return after.filter { beforeCaptureIDs.contains($0.id) == false }
    }

    static var iso: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}
