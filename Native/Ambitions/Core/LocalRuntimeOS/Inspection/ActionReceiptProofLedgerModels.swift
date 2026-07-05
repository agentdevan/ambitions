import Foundation

enum ActionReceiptVisibilityLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case toast
    case peek
    case trail
    case search
    case export
}

struct ActionReceiptProofLedgerEntry: Sendable, Equatable, Identifiable {
    let receiptRecord: ActionReceiptHistoryRecord
    let proofReference: ProofReference?
    let visibilityLevels: [ActionReceiptVisibilityLevel]
    let noSilentChanges: Bool
    let localOnly: Bool
    let runtimeLineage: RuntimeTrustLineage?

    init(
        receipt: ActionReceipt,
        privacyLevel: ActionReceiptPrivacyLevel = .safeToShow,
        localOnly: Bool = true,
        visibilityLevels: [ActionReceiptVisibilityLevel] = [.toast, .peek, .trail, .search],
        proofRelevance: ActionReceiptProofRelevance? = nil,
        runtimeLineage: RuntimeTrustLineage? = nil
    ) {
        let record = ActionReceiptHistoryRecord(
            receipt: receipt,
            privacyLevel: privacyLevel,
            localOnly: localOnly,
            proofRelevance: proofRelevance,
            runtimeLineage: runtimeLineage
        )
        self.receiptRecord = record
        self.proofReference = Self.proofReference(for: record)
        self.visibilityLevels = Self.normalizedVisibility(visibilityLevels)
        self.noSilentChanges = true
        self.localOnly = localOnly
        self.runtimeLineage = runtimeLineage
    }

    var id: String { receiptRecord.id }

    var receipt: ActionReceipt {
        receiptRecord.receipt
    }

    var proofFreshnessLineage: ActionReceiptProofFreshnessLineage {
        receiptRecord.proofFreshnessLineage
    }

    var sourceRecordIDs: [String] {
        receiptRecord.sourceRecordIDs
    }

    var sourceObjectID: String? {
        receiptRecord.sourceObjectID
    }

    var sourceRecordLabel: String {
        receiptRecord.sourceRecordLabel
    }

    var replayTraceLabel: String {
        receiptRecord.replayTraceLabel
    }

    var hasRuntimeLineage: Bool {
        runtimeLineage?.hasCompleteTrustTrace == true
    }

    var runtimeTransactionID: String? {
        runtimeLineage?.runtimeTransactionID
    }

    var runtimeEventID: String? {
        runtimeLineage?.runtimeEventID
    }

    var runtimeReceiptID: String? {
        runtimeLineage?.runtimeReceiptID
    }

    var runtimeReplayTraceID: String? {
        runtimeLineage?.runtimeReplayTraceID
    }

    var hasProofBridge: Bool {
        receiptRecord.hasProofBridge
    }

    var stepObjectIDs: [String] {
        receiptRecord.stepObjectIDs
    }

    var goalThreadContextIDs: [String] {
        receiptRecord.goalThreadContextIDs
    }

    var captureObjectIDs: [String] {
        receiptRecord.captureObjectIDs
    }

    var timeObjectIDs: [String] {
        receiptRecord.timeObjectIDs
    }

    var proofReferenceIDs: [String] {
        receiptRecord.proofReferenceIDs
    }

    var relatedObjectIDs: [String] {
        receiptRecord.relatedObjectIDs
    }

    var peekTitle: String {
        if proofReference != nil {
            return "Proof saved"
        }
        switch receiptRecord.trustStatus {
        case .confirmationRequired:
            return "Needs confirmation"
        case .safeFailure:
            return "No changes made"
        case .missingDetail:
            return "Detail hidden"
        case .needsReview:
            return "Receipt saved"
        case .safeToShow:
            return "Receipt saved"
        }
    }

    var peekSubtitle: String {
        if let proofReference {
            return "\(proofReference.title) · \(receipt.summary)"
        }
        return "\(receipt.title) · \(receiptRecord.proofLabel)"
    }

    var privacyLabel: String {
        receiptRecord.localOnly ? "Stored on this device" : "Requires your confirmation"
    }

    var noSilentChangesLabel: String {
        "No silent changes"
    }

    var privacyPostureLabel: String {
        if localOnly == false {
            return "Broader use requires confirmation"
        }
        if receiptRecord.privacyLevel.requiresRedactionByDefault || receiptRecord.hasMissingDetail {
            return "Local-only and redacted"
        }
        return "Local-only and inspectable"
    }

    var exportPostureLabel: String {
        if localOnly == false {
            return "Export review required"
        }
        if receiptRecord.safeToShowInExternalSurface {
            return "Export-safe receipt summary"
        }
        if receiptRecord.hasMissingDetail {
            return "Export summary redacted"
        }
        return "Export review only"
    }

    var proofImmutabilityLabel: String {
        noSilentChanges ? "Proof stays immutable" : "Proof changes are possible"
    }

    var closureImmutabilityLabel: String {
        receiptRecord.requiresConfirmationBeforeBroaderUse ? "Closure stays confirmation-gated" : "Closure remains immutable"
    }

    var isRecoverableBeyondToast: Bool {
        visibilityLevels.contains(.trail) || visibilityLevels.contains(.search)
    }

    private static func proofReference(for record: ActionReceiptHistoryRecord) -> ProofReference? {
        guard record.proofRelevance == .countsAsProof,
              record.receipt.resultState != .needsConfirmation,
              record.receipt.safetyState != .confirmationRequired,
              record.receipt.safetyState != .safeFailure,
              let attachedObject = record.receipt.affectedObjects.first else {
            return nil
        }

        return ProofReference(
            id: "proof.\(record.receipt.id)",
            kind: proofKind(for: record.receipt),
            title: proofTitle(for: record.receipt),
            summary: record.receipt.summary,
            sourceObject: record.receipt.lifeGraphObjectReference,
            attachedObject: attachedObject,
            occurredAt: record.receipt.occurredAt,
            createdAt: record.receipt.createdAt,
            strength: proofStrength(for: record.receipt),
            sourceDomain: record.receipt.sourceDomain.lifeGraphSourceDomain
        )
    }

    private static func proofKind(for receipt: ActionReceipt) -> ProofReferenceKind {
        if isStillCounts(receipt) {
            return .stillCounts
        }
        if receipt.changedFacts.contains(where: { $0.kind == .completedAction || $0.kind == .completedTask }) {
            return .completedAction
        }
        return .milestoneEvidence
    }

    private static func proofTitle(for receipt: ActionReceipt) -> String {
        isStillCounts(receipt) ? "Still counts" : receipt.title
    }

    private static func proofStrength(for receipt: ActionReceipt) -> ProofStrength {
        isStillCounts(receipt) ? .supporting : .strong
    }

    private static func isStillCounts(_ receipt: ActionReceipt) -> Bool {
        receipt.title.localizedCaseInsensitiveContains("Still counts") ||
            receipt.changedFacts.contains { fact in
                fact.newValueSummary?.localizedCaseInsensitiveContains("Still counts") == true ||
                    fact.summary.localizedCaseInsensitiveContains("Still counts")
            }
    }

    private static func normalizedVisibility(_ visibilityLevels: [ActionReceiptVisibilityLevel]) -> [ActionReceiptVisibilityLevel] {
        var seen = Set<ActionReceiptVisibilityLevel>()
        return visibilityLevels.filter { seen.insert($0).inserted }
    }
}

extension ActionReceipt {
    var proofReferenceIDs: [String] {
        ActionReceiptHistoryRecord(receipt: self, proofRelevance: .countsAsProof).proofReferenceIDs
    }
}

extension Reflection {
    var isDeleted: Bool { false }
}

extension Optional where Wrapped == String {
    func compactMap(_ transform: (String) throws -> String?) rethrows -> [String] {
        guard let wrapped = self else { return [] }
        guard let transformed = try transform(wrapped) else { return [] }
        return [transformed]
    }
}

extension Optional where Wrapped == String? {
    func compactMap(_ transform: (String?) throws -> String?) rethrows -> [String] {
        guard let wrapped = self else { return [] }
        guard let transformed = try transform(wrapped) else { return [] }
        return [transformed]
    }
}

extension GoalTempo {
    static var recurring: GoalTempo { .ongoing }
}

extension KnowledgeProviderStatus {
    init(
        provider: KnowledgeProviderDescriptor,
        availability: KnowledgeProviderAvailability,
        detail: String
    ) {
        self.init(
            provider: provider,
            availability: availability,
            detail: detail,
            runtimeTrustPosture: .localOnly
        )
    }
}
