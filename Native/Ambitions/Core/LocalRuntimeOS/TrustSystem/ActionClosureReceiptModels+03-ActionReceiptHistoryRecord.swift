import Foundation

struct ActionReceiptHistoryRecord: Sendable, Equatable, Identifiable {
    let receipt: ActionReceipt
    let privacyLevel: ActionReceiptPrivacyLevel
    let localOnly: Bool
    let proofRelevance: ActionReceiptProofRelevance
    let requiresConfirmationBeforeBroaderUse: Bool
    let proofFreshnessLineage: ActionReceiptProofFreshnessLineage

    init(
        receipt: ActionReceipt,
        privacyLevel: ActionReceiptPrivacyLevel = .safeToShow,
        localOnly: Bool = true,
        proofRelevance: ActionReceiptProofRelevance? = nil,
        requiresConfirmationBeforeBroaderUse: Bool? = nil,
        proofFreshnessLineage: ActionReceiptProofFreshnessLineage? = nil
    ) {
        self.receipt = receipt
        self.privacyLevel = privacyLevel
        self.localOnly = localOnly
        self.proofRelevance = proofRelevance ?? Self.inferredProofRelevance(receipt)
        self.requiresConfirmationBeforeBroaderUse = requiresConfirmationBeforeBroaderUse ?? Self.inferredConfirmationNeed(receipt)
        self.proofFreshnessLineage = proofFreshnessLineage ?? Self.proofFreshnessLineage(
            receipt: receipt,
            privacyLevel: privacyLevel,
            localOnly: localOnly,
            proofRelevance: self.proofRelevance,
            requiresConfirmationBeforeBroaderUse: self.requiresConfirmationBeforeBroaderUse
        )
    }

    var id: String { receipt.id }

    var relatedGoalIDs: [String] {
        relatedObjectIDs(kind: .goal)
    }

    var relatedCaptureIDs: [String] {
        relatedObjectIDs(kind: .capture)
    }

    var relatedPlanItemIDs: [String] {
        receipt.affectedObjects.filter { object in
            object.sourceDomain == .time || object.kind == .step || object.kind == .action
        }.map(\.id).sorted()
    }

    var trustStatus: ActionReceiptTrustStatus {
        if hasMissingDetail || privacyLevel == .unavailable {
            return .missingDetail
        }
        if receipt.resultState == .needsConfirmation || receipt.safetyState == .confirmationRequired || requiresConfirmationBeforeBroaderUse {
            return .confirmationRequired
        }
        if receipt.resultState == .failedSafely || receipt.safetyState == .safeFailure {
            return .safeFailure
        }
        if receipt.correctionAvailability.isAvailable {
            return .needsReview
        }
        return .safeToShow
    }

    var safeToShowInExternalSurface: Bool {
        localOnly &&
            privacyLevel == .safeToShow &&
            receipt.safetyState == .normal &&
            receipt.resultState != .needsConfirmation &&
            requiresConfirmationBeforeBroaderUse == false
    }

    var hasMissingDetail: Bool {
        receipt.summary.isEmpty ||
            (receipt.changedFacts.isEmpty && receipt.safeFailure == nil && receipt.why == nil)
    }

    func projection(detail: ActionReceiptProjectionDetail) -> ActionReceiptSearchResult {
        let shouldRedact = detail == .redacted || privacyLevel.requiresRedactionByDefault
        let redactedTitle = privacyLevel == .unavailable || hasMissingDetail ? "Detail hidden" : "Private item"
        let title = shouldRedact ? redactedTitle : receipt.title
        let summary = shouldRedact ? redactedSummary : receipt.summary

        return ActionReceiptSearchResult(
            id: "receipt.search.\(receipt.id)",
            receiptID: receipt.id,
            title: title,
            summary: summary,
            resultState: receipt.resultState,
            occurredAt: receipt.occurredAt,
            sourceDomain: receipt.sourceDomain,
            privacyLevel: shouldRedact ? .redacted : privacyLevel,
            trustStatus: trustStatus,
            proofRelevance: proofRelevance,
            localOnly: localOnly,
            safeToShowInExternalSurface: shouldRedact ? false : safeToShowInExternalSurface,
            undoLabel: receipt.undoAvailability.isAvailable ? "Undo available" : "Undo not available",
            proofLabel: proofLabel,
            proofFreshnessLineage: proofFreshnessLineage,
            relatedObjectLabels: relatedObjectLabels,
            changedFactSummaries: shouldRedact ? redactedChangedFactSummaries : receipt.changedFacts.map(\.summary),
            hiddenDetailLabel: shouldRedact ? "Detail hidden" : nil
        )
    }

    var redactedSummary: String {
        if privacyLevel == .unavailable || hasMissingDetail {
            return "Detail hidden"
        }
        return "Private item"
    }

    var redactedChangedFactSummaries: [String] {
        if hasMissingDetail {
            return ["Detail hidden"]
        }
        return receipt.changedFacts.isEmpty ? ["Detail hidden"] : receipt.changedFacts.map { _ in "Detail hidden" }
    }

    var proofLabel: String {
        switch proofRelevance {
        case .notProof:
            return "Receipt"
        case .mayCountAsProof:
            return "May count as proof"
        case .countsAsProof:
            return "Added to proof"
        case .needsConfirmation:
            return "Needs confirmation"
        }
    }

    var recoveryAuditExportSummary: ActionReceiptRecoveryAuditExportSummary {
        ActionReceiptRecoveryAuditExportSummary(record: self)
    }

    var sourceFreshnessPrivacySummary: ActionReceiptSourceFreshnessPrivacySummary {
        ActionReceiptSourceFreshnessPrivacySummary(record: self)
    }

    var sourceRecordIDs: [String] {
        [receipt.id]
    }

    var sourceObjectID: String? {
        receipt.sourceObject?.id
    }

    var sourceObjectKind: LifeGraphObjectKind? {
        receipt.sourceObject?.kind
    }

    var stepObjectIDs: [String] {
        Self.orderedUnique(receipt.affectedObjects.filter { $0.kind == .step }.map(\.id))
    }

    var goalThreadContextIDs: [String] {
        Self.orderedUnique(
            receipt.affectedObjects.compactMap(\.parentContextID) +
                [receipt.sourceObject?.parentContextID].compactMap { $0 }
        )
    }

    var captureObjectIDs: [String] {
        Self.orderedUnique(receipt.affectedObjects.filter { $0.kind == .capture }.map(\.id))
    }

    var timeObjectIDs: [String] {
        Self.orderedUnique(
            receipt.affectedObjects.filter {
                $0.sourceDomain == .time || $0.kind == .action
            }.map(\.id)
        )
    }

    var proofReferenceIDs: [String] {
        proofFreshnessLineage.proofReferenceIDs
    }

    var relatedObjectIDs: [String] {
        proofFreshnessLineage.lineageObjectIDs
    }

    var sourceRecordLabel: String {
        sourceObjectID == nil ? "Source record is receipt-backed" : "Source record is source-tied"
    }

    var receiptLabel: String {
        proofFreshnessLineage.privacyReceiptLabel
    }

    var replayTraceLabel: String {
        proofFreshnessLineage.canUseAsCurrentLocalSource ? "Replay trace stays local and inspectable" : "Replay trace needs review"
    }

    var hasProofBridge: Bool {
        proofReferenceIDs.isEmpty == false
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }

    var relatedObjectLabels: [String] {
        receipt.affectedObjects.map { object in
            switch object.kind {
            case .goal:
                return "Linked to goal"
            case .oneStepGoal:
                return "Linked to task"
            case .capture:
                return "Linked to capture"
            case .step, .action:
                return "Linked to plan"
            case .proof, .evidence:
                return "Linked to proof"
            default:
                return "Linked item"
            }
        }
    }

    func relatedObjectIDs(kind: LifeGraphObjectKind) -> [String] {
        receipt.affectedObjects.filter { $0.kind == kind }.map(\.id).sorted()
    }

    static func proofFreshnessLineage(
        receipt: ActionReceipt,
        privacyLevel: ActionReceiptPrivacyLevel,
        localOnly: Bool,
        proofRelevance: ActionReceiptProofRelevance,
        requiresConfirmationBeforeBroaderUse: Bool
    ) -> ActionReceiptProofFreshnessLineage {
        let hasSourceTiedAffectedObject = receipt.sourceObject != nil && receipt.affectedObjects.isEmpty == false
        let hasMissingDetail = receipt.summary.isEmpty ||
            (receipt.changedFacts.isEmpty && hasSourceTiedAffectedObject == false && receipt.safeFailure == nil && receipt.why == nil)
        let redactsPrivateDetail = privacyLevel.requiresRedactionByDefault || hasMissingDetail
        let requiresFreshnessReview = Self.requiresFreshnessReview(
            receipt: receipt,
            proofRelevance: proofRelevance,
            requiresConfirmationBeforeBroaderUse: requiresConfirmationBeforeBroaderUse
        )

        return ActionReceiptProofFreshnessLineage(
            id: "receipt.proof-freshness-lineage.\(receipt.id)",
            receiptID: receipt.id,
            sourceDomain: receipt.sourceDomain,
            sourceObjectID: receipt.sourceObject?.id,
            sourceObjectKind: receipt.sourceObject?.kind,
            lineageObjectIDs: Self.lineageObjectIDs(receipt: receipt),
            proofReferenceIDs: Self.proofReferenceIDs(
                receipt: receipt,
                proofRelevance: proofRelevance,
                requiresFreshnessReview: requiresFreshnessReview
            ),
            sourceFreshnessLabel: Self.sourceFreshnessLabel(
                receipt: receipt,
                redactsPrivateDetail: redactsPrivateDetail,
                requiresFreshnessReview: requiresFreshnessReview
            ),
            privacyReceiptLabel: Self.privacyReceiptLabel(
                localOnly: localOnly,
                redactsPrivateDetail: redactsPrivateDetail,
                hasMissingDetail: hasMissingDetail
            ),
            sourceEvidenceLabel: Self.sourceEvidenceLabel(receipt: receipt),
            nonClaimLabel: "Public proof stays locked until evidence exists",
            canUseAsCurrentLocalSource: localOnly &&
                redactsPrivateDetail == false &&
                requiresFreshnessReview == false,
            redactsPrivateDetail: redactsPrivateDetail,
            requiresFreshnessReview: requiresFreshnessReview,
            localOnly: localOnly,
            publicClaimAllowed: false
        )
    }

    static func lineageObjectIDs(receipt: ActionReceipt) -> [String] {
        var seen = Set<String>()
        var ids: [String] = []

        if let sourceObjectID = receipt.sourceObject?.id, seen.insert(sourceObjectID).inserted {
            ids.append(sourceObjectID)
        }

        let remainingObjectIDs = (receipt.affectedObjects.map(\.id) + receipt.changedFacts.compactMap { $0.object?.id })
            .filter { seen.contains($0) == false }
            .sorted()

        for objectID in remainingObjectIDs where seen.insert(objectID).inserted {
            ids.append(objectID)
        }

        return ids
    }

    static func proofReferenceIDs(
        receipt: ActionReceipt,
        proofRelevance: ActionReceiptProofRelevance,
        requiresFreshnessReview: Bool
    ) -> [String] {
        guard proofRelevance == .countsAsProof,
              requiresFreshnessReview == false,
              receipt.affectedObjects.isEmpty == false else {
            return []
        }
        return ["proof.\(receipt.id)"]
    }

    static func requiresFreshnessReview(
        receipt: ActionReceipt,
        proofRelevance: ActionReceiptProofRelevance,
        requiresConfirmationBeforeBroaderUse: Bool
    ) -> Bool {
        receipt.summary.isEmpty ||
            (receipt.changedFacts.isEmpty && !(receipt.sourceObject != nil && receipt.affectedObjects.isEmpty == false) && receipt.safeFailure == nil && receipt.why == nil) ||
            requiresConfirmationBeforeBroaderUse ||
            receipt.safetyState != .normal ||
            receipt.resultState == .needsConfirmation ||
            receipt.resultState == .failedSafely ||
            receipt.resultState == .draftedPrepared ||
            proofRelevance == .needsConfirmation
    }

    static func sourceFreshnessLabel(
        receipt: ActionReceipt,
        redactsPrivateDetail: Bool,
        requiresFreshnessReview: Bool
    ) -> String {
        if receipt.summary.isEmpty ||
            (receipt.changedFacts.isEmpty && !(receipt.sourceObject != nil && receipt.affectedObjects.isEmpty == false) && receipt.safeFailure == nil && receipt.why == nil) {
            return "Source freshness needs detail"
        }
        if receipt.safetyState != .normal || receipt.resultState == .failedSafely {
            return "Source freshness degraded"
        }
        if redactsPrivateDetail {
            return "Source freshness private"
        }
        if requiresFreshnessReview {
            return "Source freshness needs review"
        }
        return "Source freshness current local receipt"
    }

    static func privacyReceiptLabel(
        localOnly: Bool,
        redactsPrivateDetail: Bool,
        hasMissingDetail: Bool
    ) -> String {
        if localOnly == false {
            return "Privacy receipt needs confirmation"
        }
        if redactsPrivateDetail || hasMissingDetail {
            return "Privacy receipt hides private detail"
        }
        return "Privacy receipt stored on this device"
    }

    static func sourceEvidenceLabel(receipt: ActionReceipt) -> String {
        if receipt.summary.isEmpty ||
            (receipt.changedFacts.isEmpty && receipt.safeFailure == nil && receipt.why == nil) {
            return "Source evidence unavailable"
        }
        if receipt.sourceObject != nil {
            return "Source evidence links receipt to source object"
        }
        if receipt.why != nil {
            return "Source evidence includes reason"
        }
        if receipt.changedFacts.isEmpty == false {
            return "Source evidence includes changed facts"
        }
        return "Source evidence is receipt metadata only"
    }

    static func inferredProofRelevance(_ receipt: ActionReceipt) -> ActionReceiptProofRelevance {
        if receipt.resultState == .needsConfirmation {
            return .needsConfirmation
        }
        if receipt.affectedObjects.contains(where: { $0.kind == .proof || $0.kind == .evidence }) ||
            receipt.sourceDomain == .proof ||
            receipt.changedFacts.contains(where: { $0.kind == .completedAction || $0.kind == .completedTask }) {
            return .countsAsProof
        }
        if receipt.resultState == .completed {
            return .mayCountAsProof
        }
        return .notProof
    }

    static func inferredConfirmationNeed(_ receipt: ActionReceipt) -> Bool {
        receipt.resultState == .needsConfirmation ||
            receipt.safetyState == .confirmationRequired ||
            receipt.undoAvailability == .requiresConfirmation ||
            receipt.correctionAvailability == .availableWithReason
    }
}
