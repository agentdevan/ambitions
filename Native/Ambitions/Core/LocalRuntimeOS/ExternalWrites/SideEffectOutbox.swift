import Foundation

enum SideEffectOutboxError: LocalizedError, Sendable, Equatable {
    case missingDurableID
    case missingLocalCommitReceipt
    case invalidClaimToken
    case claimBackpressureExceeded

    var errorDescription: String? {
        switch self {
        case .missingDurableID:
            return "Side-effect requests require a durable id."
        case .missingLocalCommitReceipt:
            return "External side-effect attempts require a committed local mutation receipt."
        case .invalidClaimToken:
            return "The durable side-effect claim no longer belongs to this attempt."
        case .claimBackpressureExceeded:
            return "Too many callers are waiting for the same side-effect claim."
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
    let claimToken: String?

    var mayAttemptExternalWrite: Bool {
        decision.mayAttemptExternalWrite
    }
}

enum SideEffectClaim: Sendable, Equatable {
    case claimed(SideEffectAttempt)
    case terminal(SideEffectAttempt)
    case reconciliationRequired(SideEffectAttempt)
    case denied(SideEffectAttempt)

    var attempt: SideEffectAttempt {
        switch self {
        case let .claimed(attempt), let .terminal(attempt), let .reconciliationRequired(attempt), let .denied(attempt):
            return attempt
        }
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
        self.externalReceiptID = externalReceiptID?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty
        let normalizedFacts = degradedFacts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
        self.degradedFacts = Array(Set(normalizedFacts)).sorted()
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
    func recordResult(
        _ result: SideEffectAttemptResult,
        for attempt: SideEffectAttempt,
        occurredAt: Date
    ) async throws -> SideEffectReceipt
    func completedAttempt(for request: SideEffectOutboxRequest) async throws -> SideEffectAttempt?
    func claim(_ request: SideEffectOutboxRequest) async throws -> SideEffectClaim
}

extension SideEffectOutboxing {
    func completedAttempt(for request: SideEffectOutboxRequest) async throws -> SideEffectAttempt? {
        _ = request
        return nil
    }

    func claim(_ request: SideEffectOutboxRequest) async throws -> SideEffectClaim {
        if let completed = try await completedAttempt(for: request) {
            return .terminal(completed)
        }
        return .claimed(try await enqueue(request))
    }
}

actor SideEffectOutbox: SideEffectOutboxing {
    private static let maximumWaitersPerClaim = 32

    private let ledger: any SideEffectLedgerRepository
    private let policyEngine: SideEffectPolicyEngine
    private let leaseDuration: TimeInterval
    private var activeClaimIDs = Set<String>()
    private var claimWaiters: [String: [UUID: CheckedContinuation<Void, Error>]] = [:]

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
            return SideEffectAttempt(
                id: request.id,
                request: request,
                decision: decision,
                ledgerRecord: record,
                lease: nil,
                claimToken: nil
            )
        }

        return SideEffectAttempt(
            id: request.id,
            request: request,
            decision: decision,
            ledgerRecord: record,
            lease: lease,
            claimToken: nil
        )
    }

    func completedAttempt(for request: SideEffectOutboxRequest) async throws -> SideEffectAttempt? {
        guard let existing = try await ledger.fetchRecord(id: request.id), existing.status == .succeeded else {
            return nil
        }
        return SideEffectAttempt(
            id: request.id,
            request: request,
            decision: policyEngine.evaluate(request),
            ledgerRecord: existing,
            lease: nil,
            claimToken: nil
        )
    }

    func claim(_ request: SideEffectOutboxRequest) async throws -> SideEffectClaim {
        guard request.id.isEmpty == false else {
            throw SideEffectOutboxError.missingDurableID
        }
        while activeClaimIDs.contains(request.id) {
            try await waitForClaimCompletion(id: request.id)
        }

        activeClaimIDs.insert(request.id)
        do {
            let decision = policyEngine.evaluate(request)
            let lease = makeLease(for: request, decision: decision)
            let proposed = makeRecord(request: request, decision: decision, lease: lease)
            guard decision.mayAttemptExternalWrite else {
                return try await deny(request: request, decision: decision, record: proposed)
            }
            let token = UUID().uuidString.lowercased()
            switch try await ledger.claim(proposed, token: token) {
            case let .existing(existing):
                finishClaim(id: request.id)
                let attempt = SideEffectAttempt(
                    id: request.id,
                    request: request,
                    decision: decision,
                    ledgerRecord: existing,
                    lease: nil,
                    claimToken: nil
                )
                return classifyExisting(attempt)
            case let .claimed(claimed):
                let attempt = SideEffectAttempt(
                    id: request.id,
                    request: request,
                    decision: decision,
                    ledgerRecord: claimed,
                    lease: lease,
                    claimToken: token
                )
                // The actor-local claim only serializes the durable ledger
                // admission. Keeping it active while the caller performs an
                // external write lets a cancelled or abandoned caller strand
                // every later request for this ID in memory. The durable
                // record/token remains the sole ownership authority after
                // this point; later callers receive reconciliation-required.
                finishClaim(id: request.id)
                return .claimed(attempt)
            }
        } catch {
            finishClaim(id: request.id)
            throw error
        }
    }

    private func classifyExisting(_ attempt: SideEffectAttempt) -> SideEffectClaim {
        let existing = attempt.ledgerRecord
        guard existing.commandID == attempt.request.commandID,
              existing.operationID == attempt.request.operationID else { return .denied(attempt) }
        return existing.status == .succeeded ? .terminal(attempt) : .reconciliationRequired(attempt)
    }

    private func deny(
        request: SideEffectOutboxRequest,
        decision: SideEffectPolicyDecision,
        record: SideEffectLedgerRecord
    ) async throws -> SideEffectClaim {
        let persisted: SideEffectLedgerRecord
        switch try await ledger.insertIfAbsent(record) {
        case let .claimed(inserted), let .existing(inserted):
            persisted = inserted
        }
        finishClaim(id: request.id)
        return .denied(
            SideEffectAttempt(
                id: request.id,
                request: request,
                decision: decision,
                ledgerRecord: persisted,
                lease: nil,
                claimToken: nil
            )
        )
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
            operationID: attempt.request.operationID,
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
        do {
            if let token = attempt.claimToken {
                guard try await ledger.finalize(updated, token: token) else {
                    throw SideEffectOutboxError.invalidClaimToken
                }
            } else {
                try await ledger.append(updated)
            }
            finishClaim(id: attempt.id)
            return receipt
        } catch {
            finishClaim(id: attempt.id)
            throw error
        }
    }

    private func finishClaim(id: String) {
        activeClaimIDs.remove(id)
        let waiters = claimWaiters.removeValue(forKey: id)?.values ?? []
        waiters.forEach { $0.resume() }
    }

    private func waitForClaimCompletion(id: String) async throws {
        try Task.checkCancellation()
        let waiterID = UUID()
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                registerClaimWaiter(
                    id: id,
                    waiterID: waiterID,
                    continuation: continuation
                )
            }
        } onCancel: {
            Task { await self.cancelClaimWaiter(id: id, waiterID: waiterID) }
        }
        try Task.checkCancellation()
    }

    private func registerClaimWaiter(
        id: String,
        waiterID: UUID,
        continuation: CheckedContinuation<Void, Error>
    ) {
        guard activeClaimIDs.contains(id) else {
            continuation.resume()
            return
        }
        guard claimWaiters[id, default: [:]].count < Self.maximumWaitersPerClaim else {
            continuation.resume(throwing: SideEffectOutboxError.claimBackpressureExceeded)
            return
        }
        claimWaiters[id, default: [:]][waiterID] = continuation
    }

    private func cancelClaimWaiter(id: String, waiterID: UUID) {
        guard let continuation = claimWaiters[id]?.removeValue(forKey: waiterID) else { return }
        if claimWaiters[id]?.isEmpty == true {
            claimWaiters.removeValue(forKey: id)
        }
        continuation.resume(throwing: CancellationError())
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
            degradedFacts.append(
                "Local commit receipt \(localCommit.receiptID) completed before side-effect recording."
            )
        }

        return SideEffectLedgerRecord(
            id: request.id,
            effectKind: request.effectKind,
            status: decision.status,
            boundary: decision.boundary,
            actionKind: request.actionKind,
            sourceDomain: request.sourceDomain,
            commandID: request.commandID,
            operationID: request.operationID,
            leaseID: lease?.id,
            leasedAt: lease?.leasedAt,
            leaseExpiresAt: lease?.expiresAt,
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
