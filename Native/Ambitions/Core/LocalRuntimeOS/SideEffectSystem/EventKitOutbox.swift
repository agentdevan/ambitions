import Foundation

struct EventKitOutbox: Sendable {
    private let recorder: (any SideEffectOutboxing)?

    init(recorder: (any SideEffectOutboxing)?) {
        self.recorder = recorder
    }

    @discardableResult
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
    ) async -> SideEffectAttempt? {
        guard let recorder else { return nil }
        let request = SideEffectOutboxRequest(
            id: "calendar.\(actionKind.rawValue).\(status.rawValue).\(UUID().uuidString.lowercased())",
            effectKind: .calendar,
            actionKind: actionKind,
            sourceDomain: .time,
            requestedAt: now,
            externalEffect: externalEffect,
            requiresConfirmation: requiresConfirmation,
            commitRequirement: externalEffect ? .localCommitRequired : .noUserStateMutation,
            localCommit: localCommit,
            requestedStatus: status,
            requestedBoundary: boundary,
            reasons: reasons,
            blockedFacts: blockedFacts,
            degradedFacts: degradedFacts
        )
        return try? await recorder.enqueue(request)
    }
}
