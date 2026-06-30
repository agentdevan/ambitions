import Foundation

struct AppIntentBridge {
    private let recorder: (any SideEffectOutboxing)?
    private let store: SharedExternalCreationStore

    init(
        recorder: (any SideEffectOutboxing)?,
        store: SharedExternalCreationStore = SharedExternalCreationStore()
    ) {
        self.recorder = recorder
        self.store = store
    }

    @discardableResult
    func enqueueExternalCreation(
        _ request: ExternalCreationRequest,
        acceptedAt: Date
    ) async throws -> SideEffectAttempt? {
        try store.append(request)
        guard let recorder else { return nil }
        let outboxRequest = SideEffectOutboxRequest(
            id: "app-intent-intake.\(request.id)",
            effectKind: .externalSnapshot,
            actionKind: .createCapture,
            sourceDomain: .externalSurface,
            requestedAt: acceptedAt,
            externalEffect: false,
            requiresConfirmation: false,
            commitRequirement: .committedProjection,
            requestedStatus: .recordedLocalOnly,
            requestedBoundary: .localOnly,
            degradedFacts: [
                "App Intent external creation \(request.id) stored for local command-backed import.",
                "Landing: \(request.landing.rawValue).",
            ],
            receiptID: "app-intent-intake-receipt.\(request.id)"
        )
        return try await recorder.enqueue(outboxRequest)
    }

    func recordCommandBridge(command: AmbitionsCommand, acceptedAt: Date) async {
        guard let recorder else { return }
        let record = SideEffectLedgerRecord.fromCommand(command, occurredAt: DomainTimestamp.string(from: acceptedAt))
        let request = SideEffectOutboxRequest(
            id: record.id,
            effectKind: record.effectKind,
            actionKind: record.actionKind,
            sourceDomain: record.sourceDomain,
            commandID: record.commandID,
            targetObjects: record.targetObjects,
            requestedAt: acceptedAt,
            externalEffect: record.externalEffect,
            requiresConfirmation: record.requiresConfirmation,
            commitRequirement: .noUserStateMutation,
            requestedStatus: record.status,
            requestedBoundary: record.boundary,
            reasons: record.reasons,
            blockedFacts: record.blockedFacts,
            degradedFacts: record.degradedFacts,
            receiptID: record.receiptID
        )
        _ = try? await recorder.enqueue(request)
    }
}
