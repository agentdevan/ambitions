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
        requestID: String? = nil,
        now: Date = Date()
    ) async -> SideEffectAttempt? {
        guard let recorder else { return nil }
        let request = SideEffectOutboxRequest(
            id: requestID ?? [
                "calendar",
                actionKind.rawValue,
                status.rawValue,
                UUID().uuidString.lowercased()
            ].joined(separator: "."),
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
            degradedFacts: degradedFacts,
            receiptID: localCommit?.receiptID
        )
        if let completed = try? await recorder.completedAttempt(for: request) {
            return completed
        }
        return try? await recorder.enqueue(request)
    }

    @discardableResult
    func recordCalendarResult(
        _ result: SideEffectAttemptResult,
        for attempt: SideEffectAttempt?,
        now: Date = Date()
    ) async -> SideEffectReceipt? {
        guard let recorder, let attempt else { return nil }
        return try? await recorder.recordResult(result, for: attempt, occurredAt: now)
    }
}
