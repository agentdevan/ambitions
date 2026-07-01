import Foundation

enum SideEffectCommitRequirement: String, Codable, Sendable, Equatable, Hashable {
    case localCommitRequired = "local_commit_required"
    case committedProjection = "committed_projection"
    case noUserStateMutation = "no_user_state_mutation"
    case resultObservation = "result_observation"
}

struct SideEffectLocalCommitEvidence: Codable, Sendable, Equatable, Hashable {
    let receiptID: String
    let writeScope: AppUnitOfWorkWriteScope
    let committedAt: String
    let didCommitChanges: Bool
    let sideEffectPolicy: String
    let runtimeTransactionID: String?
    let runtimeEventID: String?
    let runtimeReceiptID: String?
    let rollbackPlanID: String?

    init(
        receiptID: String,
        writeScope: AppUnitOfWorkWriteScope,
        committedAt: String,
        didCommitChanges: Bool,
        sideEffectPolicy: String,
        runtimeTransactionID: String? = nil,
        runtimeEventID: String? = nil,
        runtimeReceiptID: String? = nil,
        rollbackPlanID: String? = nil
    ) {
        self.receiptID = receiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.writeScope = writeScope
        self.committedAt = committedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.didCommitChanges = didCommitChanges
        self.sideEffectPolicy = sideEffectPolicy.trimmingCharacters(in: .whitespacesAndNewlines)
        self.runtimeTransactionID = runtimeTransactionID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.runtimeEventID = runtimeEventID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.runtimeReceiptID = runtimeReceiptID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.rollbackPlanID = rollbackPlanID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
    }

    init(receipt: AppUnitOfWorkReceipt) {
        self.init(
            receiptID: receipt.id,
            writeScope: receipt.writeScope,
            committedAt: receipt.completedAt,
            didCommitChanges: receipt.didCommitChanges,
            sideEffectPolicy: receipt.sideEffectPolicy
        )
    }

    init(runtimeReceipt: RuntimeCommitReceipt, writeScope: AppUnitOfWorkWriteScope = .localSwiftDataSingleContext) {
        self.init(
            receiptID: runtimeReceipt.id,
            writeScope: writeScope,
            committedAt: runtimeReceipt.committedAt,
            didCommitChanges: true,
            sideEffectPolicy: AppUnitOfWorkReceipt.noExternalSideEffects,
            runtimeTransactionID: runtimeReceipt.transactionID,
            runtimeEventID: runtimeReceipt.eventID,
            runtimeReceiptID: runtimeReceipt.receiptID,
            rollbackPlanID: runtimeReceipt.rollbackPlanID
        )
    }

    var provesCommittedLocalMutationWithoutExternalEffects: Bool {
        receiptID.isEmpty == false &&
            committedAt.isEmpty == false &&
            didCommitChanges &&
            sideEffectPolicy == AppUnitOfWorkReceipt.noExternalSideEffects &&
            runtimeTransactionID != nil &&
            runtimeEventID != nil &&
            runtimeReceiptID != nil &&
            rollbackPlanID != nil
    }
}

struct SideEffectOutboxRequest: Sendable, Equatable {
    let id: String
    let effectKind: SideEffectLedgerEffectKind
    let actionKind: SafeAutomationActionKind
    let sourceDomain: ActionReceiptSourceDomain
    let commandID: String?
    let targetObjects: [LifeGraphObjectReference]
    let requestedAt: Date
    let externalEffect: Bool
    let requiresConfirmation: Bool
    let commitRequirement: SideEffectCommitRequirement
    let localCommit: SideEffectLocalCommitEvidence?
    let requestedStatus: SideEffectLedgerStatus?
    let requestedBoundary: SideEffectLedgerBoundary?
    let reasons: [SafeAutomationPolicyReason]
    let blockedFacts: [String]
    let degradedFacts: [String]
    let receiptID: String?

    init(
        id: String,
        effectKind: SideEffectLedgerEffectKind,
        actionKind: SafeAutomationActionKind,
        sourceDomain: ActionReceiptSourceDomain,
        commandID: String? = nil,
        targetObjects: [LifeGraphObjectReference] = [],
        requestedAt: Date,
        externalEffect: Bool,
        requiresConfirmation: Bool,
        commitRequirement: SideEffectCommitRequirement,
        localCommit: SideEffectLocalCommitEvidence? = nil,
        requestedStatus: SideEffectLedgerStatus? = nil,
        requestedBoundary: SideEffectLedgerBoundary? = nil,
        reasons: [SafeAutomationPolicyReason] = [],
        blockedFacts: [String] = [],
        degradedFacts: [String] = [],
        receiptID: String? = nil
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.effectKind = effectKind
        self.actionKind = actionKind
        self.sourceDomain = sourceDomain
        self.commandID = commandID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        self.targetObjects = targetObjects
        self.requestedAt = requestedAt
        self.externalEffect = externalEffect
        self.requiresConfirmation = requiresConfirmation
        self.commitRequirement = commitRequirement
        self.localCommit = localCommit
        self.requestedStatus = requestedStatus
        self.requestedBoundary = requestedBoundary
        self.reasons = reasons
        self.blockedFacts = blockedFacts
        self.degradedFacts = degradedFacts
        self.receiptID = receiptID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
    }
}

struct SideEffectPolicyDecision: Sendable, Equatable {
    let status: SideEffectLedgerStatus
    let boundary: SideEffectLedgerBoundary
    let localOnly: Bool
    let mayAttemptExternalWrite: Bool
    let requiresConfirmation: Bool
    let reasons: [SafeAutomationPolicyReason]
    let blockedFacts: [String]
    let degradedFacts: [String]

    var isBlocked: Bool {
        status == .blocked || status == .unsupported
    }
}

struct SideEffectPolicyEngine: Sendable {
    func evaluate(_ request: SideEffectOutboxRequest) -> SideEffectPolicyDecision {
        var reasons = normalizedReasons(request.reasons)
        var blockedFacts = normalizedStrings(request.blockedFacts)
        let degradedFacts = normalizedStrings(request.degradedFacts)

        if request.id.isEmpty {
            blockedFacts.append("Side-effect request did not include a durable id.")
        }

        let localCommitIsValid = request.localCommit?.provesCommittedLocalMutationWithoutExternalEffects ?? false
        if request.externalEffect && request.commitRequirement != .localCommitRequired {
            blockedFacts.append("External side effect must declare a local runtime commit receipt requirement.")
        }
        if request.commitRequirement == .localCommitRequired && localCommitIsValid == false {
            blockedFacts.append("External side effect cannot be attempted before a committed local mutation receipt.")
        }

        if request.externalEffect {
            reasons.append(.externalSideEffect)
        }

        if request.requiresConfirmation {
            reasons.append(.confirmationRequired)
        }

        if blockedFacts.isEmpty == false {
            return SideEffectPolicyDecision(
                status: .blocked,
                boundary: request.externalEffect ? .externalEffect : .localOnly,
                localOnly: request.externalEffect == false,
                mayAttemptExternalWrite: false,
                requiresConfirmation: request.requiresConfirmation || request.externalEffect,
                reasons: normalizedReasons(reasons),
                blockedFacts: normalizedStrings(blockedFacts),
                degradedFacts: normalizedStrings(degradedFacts)
            )
        }

        let status: SideEffectLedgerStatus = {
            if let requestedStatus = request.requestedStatus {
                return requestedStatus
            }
            if request.requiresConfirmation {
                return .confirmationRequired
            }
            return request.externalEffect ? .queued : .recordedLocalOnly
        }()

        let boundary: SideEffectLedgerBoundary = {
            if let requestedBoundary = request.requestedBoundary {
                return requestedBoundary
            }
            if request.requiresConfirmation {
                return .confirmationGate
            }
            return request.externalEffect ? .externalEffect : .localOnly
        }()

        let confirmationGateSatisfied = request.requiresConfirmation == false || status == .queued
        let mayAttempt = request.externalEffect &&
            confirmationGateSatisfied &&
            status != .blocked &&
            status != .failedSafely &&
            status != .confirmationRequired

        return SideEffectPolicyDecision(
            status: status,
            boundary: boundary,
            localOnly: request.externalEffect == false,
            mayAttemptExternalWrite: mayAttempt,
            requiresConfirmation: request.requiresConfirmation,
            reasons: normalizedReasons(reasons),
            blockedFacts: normalizedStrings(blockedFacts),
            degradedFacts: normalizedStrings(degradedFacts)
        )
    }

    private func normalizedReasons(_ reasons: [SafeAutomationPolicyReason]) -> [SafeAutomationPolicyReason] {
        var seen = Set<SafeAutomationPolicyReason>()
        return reasons.filter { seen.insert($0).inserted }
    }

    private func normalizedStrings(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
