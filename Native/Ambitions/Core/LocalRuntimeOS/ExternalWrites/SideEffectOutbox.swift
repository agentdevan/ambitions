import Foundation

enum SideEffectOutboxError: LocalizedError, Sendable, Equatable {
    case missingDurableID
    case missingLocalCommitReceipt

    var errorDescription: String? {
        switch self {
        case .missingDurableID:
            return "Side-effect requests require a durable id."
        case .missingLocalCommitReceipt:
            return "External side-effect attempts require a committed local mutation receipt."
        }
    }
}

struct ExternalWriteLease: Codable, Sendable, Equatable, Hashable {
    let id: String
    let sideEffectID: String
    let leasedAt: String
    let expiresAt: String

    var isWellFormed: Bool {
        id.isEmpty == false && sideEffectID.isEmpty == false && leasedAt.isEmpty == false && expiresAt.isEmpty == false
    }
}

struct SideEffectAttempt: Sendable, Equatable {
    let id: String
    let request: SideEffectOutboxRequest
    let decision: SideEffectPolicyDecision
    let ledgerRecord: SideEffectLedgerRecord
    let lease: ExternalWriteLease?

    var mayAttemptExternalWrite: Bool {
        decision.mayAttemptExternalWrite
    }
}

enum SideEffectAttemptResultState: String, Codable, Sendable, Equatable, Hashable {
    case succeeded
    case failedSafely = "failed_safely"
    case permissionDenied = "permission_denied"
    case userConfirmationRequired = "user_confirmation_required"
}

struct SideEffectAttemptResult: Sendable, Equatable {
    let state: SideEffectAttemptResultState
    let externalReceiptID: String?
    let degradedFacts: [String]

    init(
        state: SideEffectAttemptResultState,
        externalReceiptID: String? = nil,
        degradedFacts: [String] = []
    ) {
        self.state = state
        self.externalReceiptID = externalReceiptID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.degradedFacts = Array(Set(degradedFacts.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct SideEffectReceipt: Codable, Sendable, Equatable, Hashable {
    let id: String
    let sideEffectID: String
    let localCommitReceiptID: String?
    let externalReceiptID: String?
    let status: SideEffectLedgerStatus
    let recordedAt: String
    let localOnly: Bool
    let degradedFacts: [String]

    var isWellFormed: Bool {
        id.isEmpty == false && sideEffectID.isEmpty == false && recordedAt.isEmpty == false
    }
}

protocol SideEffectOutboxing: Sendable {
    func enqueue(_ request: SideEffectOutboxRequest) async throws -> SideEffectAttempt
    func recordResult(_ result: SideEffectAttemptResult, for attempt: SideEffectAttempt, occurredAt: Date) async throws -> SideEffectReceipt
}

actor SideEffectOutbox: SideEffectOutboxing {
    private let ledger: any SideEffectLedgerRepository
    private let policyEngine: SideEffectPolicyEngine
    private let leaseDuration: TimeInterval

    init(
        ledger: any SideEffectLedgerRepository,
        policyEngine: SideEffectPolicyEngine = SideEffectPolicyEngine(),
        leaseDuration: TimeInterval = 5 * 60
    ) {
        self.ledger = ledger
        self.policyEngine = policyEngine
        self.leaseDuration = leaseDuration
    }

    func enqueue(_ request: SideEffectOutboxRequest) async throws -> SideEffectAttempt {
        guard request.id.isEmpty == false else {
            throw SideEffectOutboxError.missingDurableID
        }

        let decision = policyEngine.evaluate(request)
        let lease = makeLease(for: request, decision: decision)
        let record = makeRecord(request: request, decision: decision, lease: lease)
        try await ledger.append(record)

        if request.commitRequirement == .localCommitRequired &&
            request.externalEffect &&
            request.localCommit?.provesCommittedLocalMutationWithoutExternalEffects != true {
            return SideEffectAttempt(id: request.id, request: request, decision: decision, ledgerRecord: record, lease: nil)
        }

        return SideEffectAttempt(id: request.id, request: request, decision: decision, ledgerRecord: record, lease: lease)
    }

    func recordResult(
        _ result: SideEffectAttemptResult,
        for attempt: SideEffectAttempt,
        occurredAt: Date
    ) async throws -> SideEffectReceipt {
        let status = ledgerStatus(for: result.state)
        let recordedAt = DomainTimestamp.string(from: occurredAt)
        let receiptID = result.externalReceiptID ?? attempt.request.receiptID ?? "side-effect-receipt.\(attempt.id)"
        let receipt = SideEffectReceipt(
            id: receiptID,
            sideEffectID: attempt.id,
            localCommitReceiptID: attempt.request.localCommit?.receiptID,
            externalReceiptID: result.externalReceiptID,
            status: status,
            recordedAt: recordedAt,
            localOnly: attempt.request.externalEffect == false,
            degradedFacts: result.degradedFacts
        )

        let updated = SideEffectLedgerRecord(
            id: attempt.id,
            effectKind: attempt.request.effectKind,
            status: status,
            boundary: attempt.decision.boundary,
            actionKind: attempt.request.actionKind,
            sourceDomain: attempt.request.sourceDomain,
            commandID: attempt.request.commandID,
            targetObjects: attempt.request.targetObjects,
            occurredAt: recordedAt,
            localOnly: attempt.request.externalEffect == false,
            requiresConfirmation: result.state == .userConfirmationRequired || attempt.request.requiresConfirmation,
            externalEffect: attempt.request.externalEffect,
            reasons: attempt.decision.reasons,
            blockedFacts: attempt.decision.blockedFacts,
            degradedFacts: result.degradedFacts.isEmpty ? attempt.decision.degradedFacts : result.degradedFacts,
            receiptID: receipt.id
        )
        try await ledger.append(updated)
        return receipt
    }

    private func makeRecord(
        request: SideEffectOutboxRequest,
        decision: SideEffectPolicyDecision,
        lease: ExternalWriteLease?
    ) -> SideEffectLedgerRecord {
        var degradedFacts = decision.degradedFacts
        if let lease {
            degradedFacts.append("External write lease \(lease.id) expires at \(lease.expiresAt).")
        }
        if let localCommit = request.localCommit {
            degradedFacts.append("Local commit receipt \(localCommit.receiptID) completed before side-effect recording.")
        }

        return SideEffectLedgerRecord(
            id: request.id,
            effectKind: request.effectKind,
            status: decision.status,
            boundary: decision.boundary,
            actionKind: request.actionKind,
            sourceDomain: request.sourceDomain,
            commandID: request.commandID,
            targetObjects: request.targetObjects,
            occurredAt: DomainTimestamp.string(from: request.requestedAt),
            localOnly: decision.localOnly,
            requiresConfirmation: decision.requiresConfirmation,
            externalEffect: request.externalEffect,
            reasons: decision.reasons,
            blockedFacts: decision.blockedFacts,
            degradedFacts: Array(Set(degradedFacts)).sorted(),
            receiptID: request.receiptID
        )
    }

    private func makeLease(
        for request: SideEffectOutboxRequest,
        decision: SideEffectPolicyDecision
    ) -> ExternalWriteLease? {
        guard decision.mayAttemptExternalWrite else { return nil }
        let leasedAt = request.requestedAt
        return ExternalWriteLease(
            id: "lease.\(request.id)",
            sideEffectID: request.id,
            leasedAt: DomainTimestamp.string(from: leasedAt),
            expiresAt: DomainTimestamp.string(from: leasedAt.addingTimeInterval(leaseDuration))
        )
    }

    private func ledgerStatus(for state: SideEffectAttemptResultState) -> SideEffectLedgerStatus {
        switch state {
        case .succeeded:
            return .succeeded
        case .failedSafely, .permissionDenied:
            return .failedSafely
        case .userConfirmationRequired:
            return .confirmationRequired
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
