import Foundation

struct ExternalCreationImportResult: Sendable, Equatable {
    let importedCaptureIDs: [String]
    let preferredLanding: ExternalCreationLanding?
    let source: ExternalCreationSource?
    /// Queue records that were deliberately retained because canonical
    /// authority did not produce a durable receipt. This is recovery state,
    /// not a successful import count.
    let retainedRequestIDs: [String]
    let authorityWasUnavailable: Bool

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
    private let handoff: any RuntimeExternalMutationHandingOff
    private let externalSurfaceSideEffectLedger: FileSideEffectLedgerRepository?
    private let appSideEffectLedger: (any SideEffectLedgerRepository)?
    /// `AppBootstrapper` can ask for import during both startup and the first
    /// active-scene reconciliation. The importer is main-actor isolated, but
    /// awaits canonical command execution, so a second invocation could
    /// otherwise observe and dispatch the same still-unacknowledged row.
    private var isImporting = false

    init(
        store: SharedExternalCreationStore = SharedExternalCreationStore(),
        commandExecutor: any CommandExecuting,
        externalSurfaceSideEffectLedger: FileSideEffectLedgerRepository? = nil,
        appSideEffectLedger: (any SideEffectLedgerRepository)? = nil
    ) {
        self.store = store
        self.handoff = RuntimeExternalMutationHandoff(commandExecutor: commandExecutor)
        self.externalSurfaceSideEffectLedger = externalSurfaceSideEffectLedger
        self.appSideEffectLedger = appSideEffectLedger
    }

    /// Allows a production composition root to inject an authority-selected
    /// handoff adapter without exposing the app-group queue to arbitrary
    /// writers. Passing an unavailable adapter remains fail-closed.
    init(
        store: SharedExternalCreationStore = SharedExternalCreationStore(),
        handoff: any RuntimeExternalMutationHandingOff,
        externalSurfaceSideEffectLedger: FileSideEffectLedgerRepository? = nil,
        appSideEffectLedger: (any SideEffectLedgerRepository)? = nil
    ) {
        self.store = store
        self.handoff = handoff
        self.externalSurfaceSideEffectLedger = externalSurfaceSideEffectLedger
        self.appSideEffectLedger = appSideEffectLedger
    }

    func importPendingCreations(now: Date = .now) async -> ExternalCreationImportResult {
        guard isImporting == false else {
            // The in-flight pass owns the queue snapshot and its corresponding
            // UI dispatch. Stable command identity protects canonical commit;
            // this guard also prevents duplicate launch routing for a replay.
            return Self.emptyResult
        }
        isImporting = true
        defer { isImporting = false }

        await reconcileExternalSurfaceSideEffects()

        let records: [ExternalCreationQueueRecord]
        do {
            records = try store.pendingRecords()
        } catch {
            return Self.emptyResult
        }

        var importedIDs: [String] = []
        var preferredLanding: ExternalCreationLanding?
        var source: ExternalCreationSource?
        var handledRequestIDs: Set<ExternalCreationRequest.ID> = []
        var acknowledgedRecordIDs: Set<ExternalCreationQueueRecord.ID> = []
        var retainedRequestIDs: [String] = []
        var authorityWasUnavailable = false

        for record in records {
            let request = record.request
            guard handledRequestIDs.insert(request.id).inserted else { continue }
            let admission = await handoff.submit(
                RuntimeExternalMutationHandoffRequest(externalRequest: request),
                now: now
            )
            switch admission {
            case let .committed(_, _, target):
                guard let captureID = target?.captureID else {
                    retainedRequestIDs.append(request.id)
                    continue
                }
                importedIDs.append(captureID)
                preferredLanding = preferredLanding ?? request.landing
                source = source ?? request.source
                acknowledgedRecordIDs.insert(record.id)
            case .deferredForCanonicalImport:
                retainedRequestIDs.append(request.id)
            case let .pendingRecovery(commandID, status, reason):
                retainedRequestIDs.append(request.id)
                recordRecovery(
                    for: record.id,
                    commandID: commandID,
                    status: status.rawValue,
                    reason: reason.rawValue,
                    now: now
                )
            case .authorityUnavailable:
                authorityWasUnavailable = true
                retainedRequestIDs.append(request.id)
                recordRecovery(
                    for: record.id,
                    commandID: RuntimeExternalMutationHandoffRequest(externalRequest: request).stableCommandID,
                    status: AmbitionsCommandExecutionStatus.blocked.rawValue,
                    reason: "authority_unavailable",
                    now: now
                )
            }
        }

        if acknowledgedRecordIDs.isEmpty == false {
            do {
                try store.acknowledge(recordIDs: acknowledgedRecordIDs)
            } catch {
                // A committed command remains replay-safe under its stable command ID.
                // Preserve the queue rows so a later import can retry acknowledgement.
            }
        }

        return ExternalCreationImportResult(
            importedCaptureIDs: importedIDs,
            preferredLanding: preferredLanding,
            source: source,
            retainedRequestIDs: retainedRequestIDs,
            authorityWasUnavailable: authorityWasUnavailable
        )
    }

    private static let emptyResult = ExternalCreationImportResult(
        importedCaptureIDs: [],
        preferredLanding: nil,
        source: nil,
        retainedRequestIDs: [],
        authorityWasUnavailable: false
    )

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

    private func recordRecovery(
        for recordID: ExternalCreationQueueRecord.ID,
        commandID: String,
        status: String,
        reason: String,
        now: Date
    ) {
        do {
            try store.recordRecovery(
                recordID: recordID,
                recovery: ExternalCreationQueueRecoveryState(
                    commandID: commandID,
                    status: status,
                    reason: reason,
                    recordedAt: DomainTimestamp.string(from: now)
                )
            )
        } catch {
            // The original queue record is intentionally retained. A failed
            // diagnostic update cannot convert recovery-required work into an
            // acknowledged mutation.
        }
    }

}
