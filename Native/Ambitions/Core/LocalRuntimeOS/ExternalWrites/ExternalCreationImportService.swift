import Foundation

struct ExternalCreationImportResult: Sendable, Equatable {
    let importedCaptureIDs: [String]
    let preferredLanding: ExternalCreationLanding?
    let source: ExternalCreationSource?

    var importedCount: Int { importedCaptureIDs.count }
}

@MainActor
protocol ExternalCreationImporting: AnyObject {
    func importPendingCreations(now: Date) async -> ExternalCreationImportResult
}

enum ExternalCreationCommandMetadataKey {
    static let requestID = "externalCreationRequestID"
    static let source = "externalCreationSource"
    static let sourceApplication = "externalCreationSourceApplication"
    static let sourceURL = "externalCreationSourceURL"
    static let sourceType = "externalCreationCaptureSourceType"
    static let landing = "externalCreationLanding"
    static let provenanceHint = "externalCreationProvenanceHint"
}

@MainActor
final class DefaultExternalCreationImportService: ExternalCreationImporting {
    private let store: SharedExternalCreationStore
    private let commandExecutor: any CommandExecuting
    private let externalSurfaceSideEffectLedger: FileSideEffectLedgerRepository?
    private let appSideEffectLedger: (any SideEffectLedgerRepository)?

    init(
        store: SharedExternalCreationStore = SharedExternalCreationStore(),
        commandExecutor: any CommandExecuting,
        externalSurfaceSideEffectLedger: FileSideEffectLedgerRepository? = nil,
        appSideEffectLedger: (any SideEffectLedgerRepository)? = nil
    ) {
        self.store = store
        self.commandExecutor = commandExecutor
        self.externalSurfaceSideEffectLedger = externalSurfaceSideEffectLedger
        self.appSideEffectLedger = appSideEffectLedger
    }

    func importPendingCreations(now: Date = .now) async -> ExternalCreationImportResult {
        await reconcileExternalSurfaceSideEffects()

        let requests: [ExternalCreationRequest]
        do {
            requests = try store.pendingRequests()
        } catch {
            return ExternalCreationImportResult(importedCaptureIDs: [], preferredLanding: nil, source: nil)
        }

        var importedIDs: [String] = []
        var preferredLanding: ExternalCreationLanding?
        var source: ExternalCreationSource?
        var handledRequestIDs: Set<ExternalCreationRequest.ID> = []
        var acknowledgedRequestIDs: Set<ExternalCreationRequest.ID> = []

        for request in requests {
            guard handledRequestIDs.insert(request.id).inserted else { continue }
            let command = command(for: request, now: now)
            let result = await commandExecutor.execute(
                command,
                context: CommandExecutionContext(
                    now: now,
                    actor: .externalSurface,
                    sourceSurface: command.sourceSurface
                )
            )
            guard result.status == .succeeded,
                  let captureID = result.target?.captureID,
                  RuntimeTransactionCommitPolicy.hasCommittedEvidence(result)
            else {
                continue
            }
            importedIDs.append(captureID)
            preferredLanding = preferredLanding ?? request.landing
            source = source ?? request.source
            acknowledgedRequestIDs.insert(request.id)
        }

        if acknowledgedRequestIDs.isEmpty == false {
            do {
                try store.acknowledge(requestIDs: acknowledgedRequestIDs)
            } catch {
                // A committed command remains replay-safe under its stable command ID.
                // Preserve the queue rows so a later import can retry acknowledgement.
            }
        }

        return ExternalCreationImportResult(
            importedCaptureIDs: importedIDs,
            preferredLanding: preferredLanding,
            source: source
        )
    }

    private func reconcileExternalSurfaceSideEffects() async {
        guard let externalSurfaceSideEffectLedger, let appSideEffectLedger else { return }
        do {
            let records = try await externalSurfaceSideEffectLedger.drainRecords()
            for record in records {
                try await appSideEffectLedger.append(record)
            }
        } catch {
            let occurredAt = DomainTimestamp.string(from: Date())
            let record = SideEffectLedgerRecord(
                id: "external-intake-reconciliation.failed.\(Int(Date().timeIntervalSince1970))",
                effectKind: .externalSnapshot,
                status: .failedSafely,
                boundary: .localOnly,
                actionKind: .createCapture,
                sourceDomain: .externalSurface,
                occurredAt: occurredAt,
                localOnly: true,
                requiresConfirmation: false,
                externalEffect: false,
                degradedFacts: ["External surface side-effect ledger reconciliation failed safely before import."]
            )
            try? await appSideEffectLedger.append(record)
        }
    }

    private func command(for request: ExternalCreationRequest, now: Date) -> AmbitionsCommand {
        let sourceType = CaptureSourceType(rawValue: request.source.captureSourceTypeRawValue) ?? .todayQuickCapture
        var metadata = [
            ExternalCreationCommandMetadataKey.requestID: request.id,
            ExternalCreationCommandMetadataKey.source: request.source.rawValue,
            ExternalCreationCommandMetadataKey.sourceType: sourceType.rawValue,
            ExternalCreationCommandMetadataKey.landing: request.landing.rawValue
        ]
        metadata[ExternalCreationCommandMetadataKey.sourceApplication] = request.sourceApplication
        metadata[ExternalCreationCommandMetadataKey.sourceURL] = request.sourceURL
        metadata[ExternalCreationCommandMetadataKey.provenanceHint] = provenanceHint(for: request)

        return AmbitionsCommand(
            id: "external.creation.command.\(request.id)",
            kind: .quickCapture,
            source: commandSource(for: request.source),
            payload: AmbitionsCommandPayload(
                rawText: request.text,
                metadata: metadata
            ),
            createdAt: request.createdAt.isEmpty ? DomainTimestamp.string(from: now) : request.createdAt,
            requestedAt: DomainTimestamp.string(from: now),
            actor: .externalSurface,
            sourceSurface: sourceSurface(for: request.source),
            privacy: .privateUserText
        )
    }

    private func commandSource(for source: ExternalCreationSource) -> AmbitionsCommandSource {
        switch source {
        case .appIntent:
            return .appIntent
        case .shareExtensionText, .shareExtensionURL:
            return .deepLink
        }
    }

    private func sourceSurface(for source: ExternalCreationSource) -> String {
        switch source {
        case .appIntent:
            return "app_intent"
        case .shareExtensionText, .shareExtensionURL:
            return "share_extension"
        }
    }

    private func provenanceHint(for request: ExternalCreationRequest) -> String? {
        switch (request.sourceApplication, request.sourceURL) {
        case let (.some(application), .some(url)):
            return "From \(application): \(url)"
        case let (.some(application), .none):
            return "From \(application)"
        case let (.none, .some(url)):
            return "Shared URL: \(url)"
        case (.none, .none):
            return nil
        }
    }
}
