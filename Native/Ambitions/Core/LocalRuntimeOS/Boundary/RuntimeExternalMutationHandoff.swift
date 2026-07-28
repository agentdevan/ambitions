import Foundation

/// A typed description of work arriving from an Apple-owned process or system
/// surface. It is deliberately a handoff, not a second mutation API: only an
/// injected `CommandExecuting` authority may turn this request into a canonical
/// mutation. Extension processes may durably queue the file-protected/app-group
/// request, but cannot report a runtime receipt before that authority commits.
struct RuntimeExternalMutationHandoffRequest: Sendable, Equatable {
    let externalRequest: ExternalCreationRequest
    let privacy: EventLedgerPrivacyClassification

    init(
        externalRequest: ExternalCreationRequest,
        privacy: EventLedgerPrivacyClassification = .privateUserText
    ) {
        self.externalRequest = externalRequest
        self.privacy = privacy
    }

    var stableCommandID: String {
        "external.creation.command.\(externalRequest.id)"
    }

    var sourceSurface: String {
        switch externalRequest.source {
        case .appIntent: "app_intent"
        case .shareExtensionText, .shareExtensionURL: "share_extension"
        }
    }
}

enum RuntimeExternalMutationHandoffDisposition: Sendable, Equatable {
    /// The external process wrote a local, app-group handoff record. This is
    /// intentionally not a canonical mutation receipt.
    case deferredForCanonicalImport(requestID: String)
    /// A canonical command was committed and supplied durable receipt evidence.
    case committed(commandID: String, receiptID: String, target: AmbitionsCommandTarget?)
    /// Canonical authority rejected or could not commit the handoff. The queue
    /// record must remain available for explicit recovery/retry.
    case pendingRecovery(
        commandID: String,
        status: AmbitionsCommandExecutionStatus,
        reason: RuntimeExternalMutationRecoveryReason
    )
    /// No canonical authority was installed in this process. Callers must not
    /// manufacture success, receipts, or direct persistence fallbacks.
    case authorityUnavailable(requestID: String)
}

enum RuntimeExternalMutationRecoveryReason: String, Sendable, Equatable {
    case authorityDidNotCommit
    case captureMaterializationPending
    case captureMaterializationFailed
    case malformedCommitEvidence
}

protocol RuntimeExternalMutationHandingOff: Sendable {
    func submit(
        _ request: RuntimeExternalMutationHandoffRequest,
        now: Date
    ) async -> RuntimeExternalMutationHandoffDisposition
}

/// The sole adapter from external-intake bytes to an `AmbitionsCommand`.
/// Reusing this factory for both immediate and deferred ingestion prevents the
/// app intent, share extension, and launch importer from drifting into distinct
/// command identities or privacy classifications.
enum RuntimeExternalMutationCommandFactory {
    static func command(
        for handoff: RuntimeExternalMutationHandoffRequest,
        now: Date
    ) -> AmbitionsCommand {
        let request = handoff.externalRequest
        let sourceType = CaptureSourceType(rawValue: request.source.captureSourceTypeRawValue) ?? .todayQuickCapture
        let content = AmbitionsCommandPayload(rawText: request.text)
        let provenance = ExternalCreationProvenance(
            requestID: request.id,
            source: request.source,
            sourceApplication: request.sourceApplication,
            sourceURL: request.sourceURL,
            sourceType: sourceType,
            landing: request.landing,
            provenanceHint: provenanceHint(for: request)
        )

        return AmbitionsCommand(
            id: handoff.stableCommandID,
            source: commandSource(for: request.source),
            typedPayload: .capture(CaptureCommand(
                action: .quickCapture(externalCreation: provenance),
                target: AmbitionsCommandTarget(),
                content: RuntimeCommandContent(content),
                sourceType: sourceType,
                entryPoint: entryPoint(for: request.source)
            )),
            createdAt: request.createdAt.isEmpty ? DomainTimestamp.string(from: now) : request.createdAt,
            requestedAt: DomainTimestamp.string(from: now),
            actor: .externalSurface,
            sourceSurface: handoff.sourceSurface,
            privacy: handoff.privacy
        )
    }

    private static func commandSource(for source: ExternalCreationSource) -> AmbitionsCommandSource {
        switch source {
        case .appIntent: .appIntent
        case .shareExtensionText, .shareExtensionURL: .deepLink
        }
    }

    private static func entryPoint(for source: ExternalCreationSource) -> CaptureCommand.EntryPoint {
        switch source {
        case .appIntent: .appIntent
        case .shareExtensionText, .shareExtensionURL: .shareExtension
        }
    }

    private static func provenanceHint(for request: ExternalCreationRequest) -> String? {
        switch (request.sourceApplication, request.sourceURL) {
        case let (.some(application), .some(url)): "From \(application): \(url)"
        case let (.some(application), .none): "From \(application)"
        case let (.none, .some(url)): "Shared URL: \(url)"
        case (.none, .none): nil
        }
    }
}

/// Production injection point for the main-app importer. It makes absence of a
/// runtime client observable and refuses to turn an uncommitted command result
/// into a receipt. The extension never owns this adapter.
struct RuntimeExternalMutationHandoff: RuntimeExternalMutationHandingOff {
    private let executor: (any CommandExecuting)?

    init(commandExecutor: (any CommandExecuting)? = nil) {
        self.executor = commandExecutor
    }

    func submit(
        _ request: RuntimeExternalMutationHandoffRequest,
        now: Date
    ) async -> RuntimeExternalMutationHandoffDisposition {
        guard let executor else {
            return .authorityUnavailable(requestID: request.externalRequest.id)
        }
        let command = RuntimeExternalMutationCommandFactory.command(for: request, now: now)
        let result = await executor.execute(
            command,
            context: CommandExecutionContext(
                now: now,
                actor: .externalSurface,
                sourceSurface: request.sourceSurface
            )
        )
        guard result.status == .succeeded,
              RuntimeTransactionCommitPolicy.hasCommittedEvidence(result) else {
            return .pendingRecovery(
                commandID: command.id,
                status: result.status,
                reason: .authorityDidNotCommit
            )
        }
        guard let receiptID = result.metadata["runtimeReceiptID"],
              receiptID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              let dispositionRaw = result.metadata["runtimeTransactionDisposition"],
              RuntimeTransactionCommitDisposition(rawValue: dispositionRaw) != nil,
              let captureID = result.target?.captureID,
              result.metadata["captureID"] == captureID else {
            return .pendingRecovery(
                commandID: command.id,
                status: result.status,
                reason: .malformedCommitEvidence
            )
        }
        switch result.metadata["captureMaterialization"] {
        case "saved", "saved_post_authority":
            break
        case "needs_recovery":
            return .pendingRecovery(
                commandID: command.id,
                status: result.status,
                reason: .captureMaterializationFailed
            )
        default:
            return .pendingRecovery(
                commandID: command.id,
                status: result.status,
                reason: .captureMaterializationPending
            )
        }
        return .committed(commandID: command.id, receiptID: receiptID, target: result.target)
    }
}
