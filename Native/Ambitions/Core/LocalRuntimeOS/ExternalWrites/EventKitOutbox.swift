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
        return try? await recorder.claim(request).attempt
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

    func claimCalendarSideEffect(
        requestID: String,
        localCommit: SideEffectLocalCommitEvidence,
        now: Date
    ) async throws -> SideEffectClaim {
        guard let recorder else { throw SideEffectOutboxError.missingDurableID }
        let request = SideEffectOutboxRequest(
            id: requestID,
            effectKind: .calendar,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            requestedAt: now,
            externalEffect: true,
            requiresConfirmation: false,
            commitRequirement: .localCommitRequired,
            localCommit: localCommit,
            requestedStatus: .queued,
            requestedBoundary: .externalEffect,
            reasons: [.externalSideEffect],
            degradedFacts: ["EventKit write queued after explicit user request."],
            receiptID: localCommit.receiptID
        )
        return try await recorder.claim(request)
    }

    func recordCalendarResultStrict(
        _ result: SideEffectAttemptResult,
        for attempt: SideEffectAttempt,
        now: Date
    ) async throws -> SideEffectReceipt {
        guard let recorder else { throw SideEffectOutboxError.missingDurableID }
        return try await recorder.recordResult(result, for: attempt, occurredAt: now)
    }
}
