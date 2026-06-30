import Foundation

struct ReminderOutbox: Sendable {
    private let recorder: (any SideEffectOutboxing)?

    init(recorder: (any SideEffectOutboxing)?) {
        self.recorder = recorder
    }

    func enqueueReminderWrite(
        selection: NextStepSchedulingSelection,
        localCommit: SideEffectLocalCommitEvidence,
        requestedAt: Date
    ) async throws -> SideEffectAttempt {
        guard let recorder else {
            throw SideEffectOutboxError.missingLocalCommitReceipt
        }
        let request = SideEffectOutboxRequest(
            id: "reminder.write.\(selection.stepID).\(Int(requestedAt.timeIntervalSince1970))",
            effectKind: .notification,
            actionKind: .externalCommand,
            sourceDomain: .today,
            targetObjects: [
                LifeGraphObjectReference(
                    kind: .step,
                    id: selection.stepID,
                    label: selection.stepTitle,
                    sourceDomain: .today
                )
            ],
            requestedAt: requestedAt,
            externalEffect: true,
            requiresConfirmation: false,
            commitRequirement: .localCommitRequired,
            localCommit: localCommit,
            requestedStatus: .queued,
            requestedBoundary: .externalEffect,
            reasons: [.externalSideEffect]
        )
        return try await recorder.enqueue(request)
    }
}
