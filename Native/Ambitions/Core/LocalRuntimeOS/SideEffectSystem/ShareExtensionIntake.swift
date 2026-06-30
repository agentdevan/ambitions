import Foundation

struct ShareExtensionIntake: Sendable {
    private let recorder: (any SideEffectOutboxing)?

    init(recorder: (any SideEffectOutboxing)?) {
        self.recorder = recorder
    }

    func recordDurableIntake(requestID: String, landing: ExternalCreationLanding, receivedAt: Date) async {
        guard let recorder else { return }
        let request = SideEffectOutboxRequest(
            id: "share-intake.\(requestID)",
            effectKind: .externalSnapshot,
            actionKind: .createCapture,
            sourceDomain: .capture,
            requestedAt: receivedAt,
            externalEffect: false,
            requiresConfirmation: false,
            commitRequirement: .committedProjection,
            requestedStatus: .recordedLocalOnly,
            requestedBoundary: .localOnly,
            degradedFacts: ["Share extension intake stored request for \(landing.rawValue) without direct private graph mutation."],
            receiptID: "share-intake-receipt.\(requestID)"
        )
        _ = try? await recorder.enqueue(request)
    }
}
