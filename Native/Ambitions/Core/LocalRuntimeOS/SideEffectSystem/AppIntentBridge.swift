import Foundation

struct AppIntentBridge: Sendable {
    private let recorder: (any SideEffectOutboxing)?

    init(recorder: (any SideEffectOutboxing)?) {
        self.recorder = recorder
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
