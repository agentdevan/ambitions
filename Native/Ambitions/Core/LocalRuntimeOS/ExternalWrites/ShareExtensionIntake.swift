import Foundation

struct ShareExtensionIntake: Sendable {
    private let recorder: (any SideEffectOutboxing)?
    private let privacyGate: PrivacyExternalBoundaryGate

    init(
        recorder: (any SideEffectOutboxing)?,
        privacyGate: PrivacyExternalBoundaryGate = PrivacyExternalBoundaryGate()
    ) {
        self.recorder = recorder
        self.privacyGate = privacyGate
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
        let privacyDecision = privacyGate.evaluateExternalSurfaceBridge(
            PrivacyExternalSurfaceBridgeEvidence(
                id: requestID,
                kind: .shareHandoff,
                commitRequirement: request.commitRequirement,
                requestedBoundary: request.requestedBoundary,
                requestedStatus: request.requestedStatus,
                externalEffect: request.externalEffect,
                containsPrivateRuntimeData: false,
                receiptID: request.receiptID,
                summary: "Share handoff stores incoming text for local command-backed import without exposing private runtime data."
            )
        )
        guard privacyDecision.isPermitted else { return }
        _ = try? await recorder.enqueue(request)
    }
}
