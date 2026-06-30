import Foundation

struct WidgetRefreshOutbox: Sendable {
    private let recorder: (any SideEffectOutboxing)?

    init(recorder: (any SideEffectOutboxing)?) {
        self.recorder = recorder
    }

    func recordSnapshotRefresh(snapshotID: String, generatedAt: Date, safeForExternalSurface: Bool) async {
        guard let recorder else { return }
        let request = SideEffectOutboxRequest(
            id: "widget-refresh.\(snapshotID).\(Int(generatedAt.timeIntervalSince1970))",
            effectKind: .externalSnapshot,
            actionKind: .noOp,
            sourceDomain: .system,
            requestedAt: generatedAt,
            externalEffect: false,
            requiresConfirmation: safeForExternalSurface == false,
            commitRequirement: .committedProjection,
            requestedStatus: safeForExternalSurface ? .recordedLocalOnly : .blocked,
            requestedBoundary: safeForExternalSurface ? .localOnly : .privacySensitive,
            reasons: safeForExternalSurface ? [] : [.privacySensitive],
            blockedFacts: safeForExternalSurface ? [] : ["Widget snapshot refresh was blocked because the projection was not safe for external surfaces."],
            receiptID: "widget-refresh-receipt.\(snapshotID)"
        )
        _ = try? await recorder.enqueue(request)
    }
}
