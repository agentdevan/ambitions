import Foundation

struct EventKitOutbox: Sendable {
    private let recorder: (any SideEffectOutboxing)?

    init(recorder: (any SideEffectOutboxing)?) {
        self.recorder = recorder
    }

    func recordCalendarSideEffect(
        actionKind: SafeAutomationActionKind,
        status: SideEffectLedgerStatus,
        boundary: SideEffectLedgerBoundary,
        requiresConfirmation: Bool,
        externalEffect: Bool,
        reasons: [SafeAutomationPolicyReason] = [],
        blockedFacts: [String] = [],
        degradedFacts: [String] = [],
        localCommit: SideEffectLocalCommitEvidence? = nil,
        now: Date = Date()
    ) async {
        guard let recorder else { return }
        let request = SideEffectOutboxRequest(
            id: "calendar.\(actionKind.rawValue).\(status.rawValue).\(UUID().uuidString.lowercased())",
            effectKind: .calendar,
            actionKind: actionKind,
            sourceDomain: .time,
            requestedAt: now,
            externalEffect: externalEffect,
            requiresConfirmation: requiresConfirmation,
            commitRequirement: externalEffect ? .resultObservation : .noUserStateMutation,
            localCommit: localCommit,
            requestedStatus: status,
            requestedBoundary: boundary,
            reasons: reasons,
            blockedFacts: blockedFacts,
            degradedFacts: degradedFacts
        )
        _ = try? await recorder.enqueue(request)
    }
}
