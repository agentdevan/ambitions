import Foundation

protocol RuntimeFeatureCommandFamily: Sendable {
    static var feature: RuntimePreparationFeature { get }
    static func accepts(_ payload: RuntimeCommandPayload) -> Bool
}

enum CaptureRuntimeCommandFamily: RuntimeFeatureCommandFamily {
    static let feature = RuntimePreparationFeature.capture
    static func accepts(_ payload: RuntimeCommandPayload) -> Bool {
        if case .capture = payload { return true }
        return false
    }
}

enum GoalStepRuntimeCommandFamily: RuntimeFeatureCommandFamily {
    static let feature = RuntimePreparationFeature.goalStep
    static func accepts(_ payload: RuntimeCommandPayload) -> Bool {
        switch payload {
        case .goal, .step: true
        default: false
        }
    }
}

enum ScheduleReminderRuntimeCommandFamily: RuntimeFeatureCommandFamily {
    static let feature = RuntimePreparationFeature.scheduleReminder
    static func accepts(_ payload: RuntimeCommandPayload) -> Bool {
        switch payload {
        case .schedule, .reminder: true
        default: false
        }
    }
}

enum ProfileRuntimeCommandFamily: RuntimeFeatureCommandFamily {
    static let feature = RuntimePreparationFeature.profile
    static func accepts(_ payload: RuntimeCommandPayload) -> Bool {
        if case .profile = payload { return true }
        return false
    }
}

enum HistoryRepairRuntimeCommandFamily: RuntimeFeatureCommandFamily {
    static let feature = RuntimePreparationFeature.historyRepair
    static func accepts(_ payload: RuntimeCommandPayload) -> Bool {
        switch payload {
        case .history, .repair: true
        default: false
        }
    }
}

enum ImportDeletionRuntimeCommandFamily: RuntimeFeatureCommandFamily {
    static let feature = RuntimePreparationFeature.importDeletion
    static func accepts(_ payload: RuntimeCommandPayload) -> Bool {
        if case .importDeletion = payload { return true }
        return false
    }
}

enum ExternalOperationRuntimeCommandFamily: RuntimeFeatureCommandFamily {
    static let feature = RuntimePreparationFeature.externalOperation
    static func accepts(_ payload: RuntimeCommandPayload) -> Bool {
        if case .externalOperation = payload { return true }
        return false
    }
}

enum CompensationRuntimeCommandFamily: RuntimeFeatureCommandFamily {
    static let feature = RuntimePreparationFeature.compensation
    static func accepts(_ payload: RuntimeCommandPayload) -> Bool {
        if case .compensation = payload { return true }
        return false
    }
}

enum AttachmentRuntimeCommandFamily: RuntimeFeatureCommandFamily {
    static let feature = RuntimePreparationFeature.attachment
    static func accepts(_ payload: RuntimeCommandPayload) -> Bool {
        if case .attachment = payload { return true }
        return false
    }
}

struct RuntimeFeatureCommand<Family: RuntimeFeatureCommandFamily>: Sendable, Equatable {
    let value: AmbitionsCommand

    init?(_ value: AmbitionsCommand) {
        guard Family.accepts(value.typedPayload) else { return nil }
        self.value = value
    }
}

typealias RuntimeCaptureCommand = RuntimeFeatureCommand<CaptureRuntimeCommandFamily>
typealias RuntimeGoalStepCommand = RuntimeFeatureCommand<GoalStepRuntimeCommandFamily>
typealias RuntimeScheduleReminderCommand = RuntimeFeatureCommand<ScheduleReminderRuntimeCommandFamily>
typealias RuntimeProfileCommand = RuntimeFeatureCommand<ProfileRuntimeCommandFamily>
typealias RuntimeHistoryRepairCommand = RuntimeFeatureCommand<HistoryRepairRuntimeCommandFamily>
typealias RuntimeImportDeletionCommand = RuntimeFeatureCommand<ImportDeletionRuntimeCommandFamily>
typealias RuntimeExternalOperationFeatureCommand = RuntimeFeatureCommand<ExternalOperationRuntimeCommandFamily>
typealias RuntimeAttachmentFeatureCommand = RuntimeFeatureCommand<AttachmentRuntimeCommandFamily>
typealias RuntimeCompensationFeatureCommand = RuntimeFeatureCommand<CompensationRuntimeCommandFamily>

struct RuntimeFeatureMutationClient<Family: RuntimeFeatureCommandFamily>: Sendable {
    private let preparer: any RuntimeMutationPreparing
    private let submitter: any RuntimeMutationSubmitting

    init(
        preparer: any RuntimeMutationPreparing,
        submitter: any RuntimeMutationSubmitting
    ) {
        self.preparer = preparer
        self.submitter = submitter
    }

    func prepare(
        _ command: RuntimeFeatureCommand<Family>,
        context: RuntimePreparationContext
    ) async -> RuntimePreparationOutcome {
        guard RuntimeFeatureMutationRouter().feature(for: command.value.typedPayload) == Family.feature,
              Self.isMutation(command.value.typedPayload) else {
            return .unsupported(RuntimePreparationFailure(
                commandID: command.value.id,
                reason: .unsupportedInput,
                recovery: .inspect(.unsupportedInput, target: command.value.target),
                originalBytes: nil
            ))
        }
        return await preparer.prepare(command.value, context: context)
    }

    func commit(
        _ preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?
    ) async -> RuntimeCommandOutcome {
        guard Family.accepts(preparation.command.typedPayload),
              RuntimeFeatureMutationRouter().feature(for: preparation.command.typedPayload) == Family.feature,
              Self.isMutation(preparation.command.typedPayload) else {
            return .unsupported(RuntimeTerminalResult(
                preparationID: preparation.preparationID,
                commandID: preparation.commandID.rawValue,
                reason: .identityMismatch,
                recovery: .inspect(.identityMismatch, target: preparation.command.target)
            ))
        }
        return await submitter.commit(preparation, confirmation: confirmation)
    }

    private static func isMutation(_ payload: RuntimeCommandPayload) -> Bool {
        switch payload {
        case let .history(history):
            if case .openDestination = history.action { return false }
            return true
        case let .repair(repair):
            return repair.action != .openDestination
        default:
            return true
        }
    }
}

struct CaptureRuntimeMutationClient: Sendable {
    let boundary: RuntimeFeatureMutationClient<CaptureRuntimeCommandFamily>
    init(preparer: any RuntimeMutationPreparing, submitter: any RuntimeMutationSubmitting) {
        boundary = RuntimeFeatureMutationClient(preparer: preparer, submitter: submitter)
    }
    func prepare(_ command: RuntimeCaptureCommand, context: RuntimePreparationContext) async -> RuntimePreparationOutcome {
        await boundary.prepare(command, context: context)
    }
    func commit(_ preparation: RuntimePreparation, confirmation: RuntimeMutationConfirmation?) async -> RuntimeCommandOutcome {
        await boundary.commit(preparation, confirmation: confirmation)
    }
}

struct GoalStepRuntimeMutationClient: Sendable {
    let boundary: RuntimeFeatureMutationClient<GoalStepRuntimeCommandFamily>
    init(preparer: any RuntimeMutationPreparing, submitter: any RuntimeMutationSubmitting) {
        boundary = RuntimeFeatureMutationClient(preparer: preparer, submitter: submitter)
    }
    func prepare(_ command: RuntimeGoalStepCommand, context: RuntimePreparationContext) async -> RuntimePreparationOutcome {
        await boundary.prepare(command, context: context)
    }
    func commit(_ preparation: RuntimePreparation, confirmation: RuntimeMutationConfirmation?) async -> RuntimeCommandOutcome {
        await boundary.commit(preparation, confirmation: confirmation)
    }
}

struct ScheduleReminderRuntimeMutationClient: Sendable {
    let boundary: RuntimeFeatureMutationClient<ScheduleReminderRuntimeCommandFamily>
    init(preparer: any RuntimeMutationPreparing, submitter: any RuntimeMutationSubmitting) {
        boundary = RuntimeFeatureMutationClient(preparer: preparer, submitter: submitter)
    }
    func prepare(_ command: RuntimeScheduleReminderCommand, context: RuntimePreparationContext) async -> RuntimePreparationOutcome {
        await boundary.prepare(command, context: context)
    }
    func commit(_ preparation: RuntimePreparation, confirmation: RuntimeMutationConfirmation?) async -> RuntimeCommandOutcome {
        await boundary.commit(preparation, confirmation: confirmation)
    }
}

struct ProfileRuntimeMutationClient: Sendable {
    let boundary: RuntimeFeatureMutationClient<ProfileRuntimeCommandFamily>
    init(preparer: any RuntimeMutationPreparing, submitter: any RuntimeMutationSubmitting) {
        boundary = RuntimeFeatureMutationClient(preparer: preparer, submitter: submitter)
    }
    func prepare(_ command: RuntimeProfileCommand, context: RuntimePreparationContext) async -> RuntimePreparationOutcome {
        await boundary.prepare(command, context: context)
    }
    func commit(_ preparation: RuntimePreparation, confirmation: RuntimeMutationConfirmation?) async -> RuntimeCommandOutcome {
        await boundary.commit(preparation, confirmation: confirmation)
    }
}

struct HistoryRepairRuntimeMutationClient: Sendable {
    let boundary: RuntimeFeatureMutationClient<HistoryRepairRuntimeCommandFamily>
    init(preparer: any RuntimeMutationPreparing, submitter: any RuntimeMutationSubmitting) {
        boundary = RuntimeFeatureMutationClient(preparer: preparer, submitter: submitter)
    }
    func prepare(_ command: RuntimeHistoryRepairCommand, context: RuntimePreparationContext) async -> RuntimePreparationOutcome {
        await boundary.prepare(command, context: context)
    }
    func commit(_ preparation: RuntimePreparation, confirmation: RuntimeMutationConfirmation?) async -> RuntimeCommandOutcome {
        await boundary.commit(preparation, confirmation: confirmation)
    }
}

struct ImportDeletionRuntimeMutationClient: Sendable {
    let boundary: RuntimeFeatureMutationClient<ImportDeletionRuntimeCommandFamily>
    init(preparer: any RuntimeMutationPreparing, submitter: any RuntimeMutationSubmitting) {
        boundary = RuntimeFeatureMutationClient(preparer: preparer, submitter: submitter)
    }
    func prepare(_ command: RuntimeImportDeletionCommand, context: RuntimePreparationContext) async -> RuntimePreparationOutcome {
        await boundary.prepare(command, context: context)
    }
    func commit(_ preparation: RuntimePreparation, confirmation: RuntimeMutationConfirmation?) async -> RuntimeCommandOutcome {
        await boundary.commit(preparation, confirmation: confirmation)
    }
}

struct ExternalOperationRuntimeMutationClient: Sendable {
    let boundary: RuntimeFeatureMutationClient<ExternalOperationRuntimeCommandFamily>
    init(preparer: any RuntimeMutationPreparing, submitter: any RuntimeMutationSubmitting) {
        boundary = RuntimeFeatureMutationClient(preparer: preparer, submitter: submitter)
    }
    func prepare(
        _ command: RuntimeExternalOperationFeatureCommand,
        context: RuntimePreparationContext
    ) async -> RuntimePreparationOutcome {
        await boundary.prepare(command, context: context)
    }
    func commit(_ preparation: RuntimePreparation, confirmation: RuntimeMutationConfirmation?) async -> RuntimeCommandOutcome {
        await boundary.commit(preparation, confirmation: confirmation)
    }
}

struct AttachmentRuntimeMutationClient: Sendable {
    let boundary: RuntimeFeatureMutationClient<AttachmentRuntimeCommandFamily>

    init(preparer: any RuntimeMutationPreparing, submitter: any RuntimeMutationSubmitting) {
        boundary = RuntimeFeatureMutationClient(preparer: preparer, submitter: submitter)
    }

    func prepare(
        _ command: RuntimeAttachmentFeatureCommand,
        context: RuntimePreparationContext
    ) async -> RuntimePreparationOutcome {
        await boundary.prepare(command, context: context)
    }

    func commit(
        _ preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?
    ) async -> RuntimeCommandOutcome {
        await boundary.commit(preparation, confirmation: confirmation)
    }
}

struct CompensationRuntimeMutationClient: Sendable {
    let boundary: RuntimeFeatureMutationClient<CompensationRuntimeCommandFamily>
    private let offering: @Sendable (
        RuntimeReceiptID,
        RuntimeReceiptReadAccess,
        RuntimeCompensationOfferContext,
        Date
    ) async throws -> RuntimeCompensationOfferState

    init(
        preparer: any RuntimeMutationPreparing,
        submitter: any RuntimeMutationSubmitting,
        offering: @escaping @Sendable (
            RuntimeReceiptID,
            RuntimeReceiptReadAccess,
            RuntimeCompensationOfferContext,
            Date
        ) async throws -> RuntimeCompensationOfferState
    ) {
        boundary = RuntimeFeatureMutationClient(preparer: preparer, submitter: submitter)
        self.offering = offering
    }

    init(
        store: CanonicalRuntimeStore,
        preparer: any RuntimeMutationPreparing,
        submitter: any RuntimeMutationSubmitting
    ) {
        self.init(
            preparer: preparer,
            submitter: submitter,
            offering: { receiptID, access, context, now in
                try await store.compensationOffer(
                    receiptID: receiptID,
                    access: access,
                    context: context,
                    at: now
                )
            }
        )
    }
    func offer(
        for receiptID: RuntimeReceiptID,
        accessAuthority: RuntimeReceiptAccessAuthority,
        accessRequest: RuntimeReceiptAccessRequest,
        context: RuntimeCompensationOfferContext,
        at now: Date
    ) async throws -> RuntimeCompensationOfferState {
        guard let access = try await accessAuthority.issue(accessRequest) else {
            return .unavailable(.unavailable)
        }
        return try await offering(receiptID, access, context, now)
    }
    func prepare(
        _ command: RuntimeCompensationFeatureCommand,
        context: RuntimePreparationContext
    ) async -> RuntimePreparationOutcome {
        await boundary.prepare(command, context: context)
    }
    func commit(
        _ preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?
    ) async -> RuntimeCommandOutcome {
        await boundary.commit(preparation, confirmation: confirmation)
    }
}
