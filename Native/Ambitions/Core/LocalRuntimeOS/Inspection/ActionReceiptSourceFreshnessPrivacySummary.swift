import Foundation

struct ActionReceiptSourceFreshnessPrivacySummary: Sendable, Equatable, Identifiable {
    let id: String
    let receiptID: String
    let sourceFreshnessLabel: String
    let privacyReceiptLabel: String
    let sourceEvidenceLabel: String
    let nonClaimLabel: String
    let canUseAsCurrentLocalSource: Bool
    let redactsPrivateDetail: Bool
    let requiresFreshnessReview: Bool
    let localOnly: Bool
    let publicClaimAllowed: Bool

    init(record: ActionReceiptHistoryRecord) {
        let lineage = record.proofFreshnessLineage

        self.id = "receipt.source-freshness-privacy.\(lineage.receiptID)"
        self.receiptID = lineage.receiptID
        self.sourceFreshnessLabel = lineage.sourceFreshnessLabel
        self.privacyReceiptLabel = lineage.privacyReceiptLabel
        self.sourceEvidenceLabel = lineage.sourceEvidenceLabel
        self.nonClaimLabel = lineage.nonClaimLabel
        self.canUseAsCurrentLocalSource = lineage.canUseAsCurrentLocalSource
        self.redactsPrivateDetail = lineage.redactsPrivateDetail
        self.requiresFreshnessReview = lineage.requiresFreshnessReview
        self.localOnly = lineage.localOnly
        self.publicClaimAllowed = lineage.publicClaimAllowed
    }
}

struct ActionReceiptRecoveryAuditExportSummary: Sendable, Equatable, Identifiable {
    let id: String
    let receiptID: String
    let auditTrailLabel: String
    let undoLabel: String
    let correctionLabel: String
    let exportLabel: String
    let privacyBoundaryLabel: String
    let rollbackBoundaryLabel: String
    let canAttemptLocalUndo: Bool
    let canRequestCorrection: Bool
    let canIncludeInLocalExportSummary: Bool
    let safeToShowInExternalSurface: Bool
    let requiresConfirmationBeforeAction: Bool
    let noSilentChanges: Bool

    init(record: ActionReceiptHistoryRecord) {
        let receipt = record.receipt
        self.id = "receipt.recovery-audit-export.\(receipt.id)"
        self.receiptID = receipt.id
        self.auditTrailLabel = Self.auditTrailLabel(record: record)
        self.undoLabel = Self.undoLabel(receipt.undoAvailability)
        self.correctionLabel = Self.correctionLabel(receipt.correctionAvailability)
        self.exportLabel = Self.exportLabel(record: record)
        self.privacyBoundaryLabel = Self.privacyBoundaryLabel(record: record)
        self.rollbackBoundaryLabel = "Rollback uses the receipt record and source object; no silent mutation"
        self.canAttemptLocalUndo = receipt.undoAvailability == .availableLocal
        self.canRequestCorrection = receipt.correctionAvailability.isAvailable
        self.canIncludeInLocalExportSummary = record.localOnly &&
            record.privacyLevel.requiresRedactionByDefault == false &&
            record.hasMissingDetail == false
        self.safeToShowInExternalSurface = record.safeToShowInExternalSurface
        self.requiresConfirmationBeforeAction = record.requiresConfirmationBeforeBroaderUse ||
            receipt.undoAvailability == .requiresConfirmation ||
            receipt.safetyState == .confirmationRequired ||
            receipt.resultState == .needsConfirmation
        self.noSilentChanges = true
    }

    static func auditTrailLabel(record: ActionReceiptHistoryRecord) -> String {
        if record.hasMissingDetail {
            return "Audit trail needs detail before use"
        }
        if record.receipt.changedFacts.isEmpty {
            return "Audit trail records receipt metadata"
        }
        if record.receipt.why != nil {
            return "Audit trail includes source, reason, changed facts, and receipt time"
        }
        return "Audit trail includes source, changed facts, and receipt time"
    }

    static func undoLabel(_ availability: ActionReceiptUndoAvailability) -> String {
        switch availability {
        case .availableLocal:
            return "Undo available on this device"
        case .requiresConfirmation:
            return "Undo needs confirmation"
        case .unsafe:
            return "Undo blocked"
        case .notSupportedYet:
            return "Undo future-owned"
        case .unavailable:
            return "Undo not available"
        }
    }

    static func correctionLabel(_ availability: ActionReceiptCorrectionAvailability) -> String {
        switch availability {
        case .available:
            return "Correction available"
        case .availableWithReason:
            return "Correction available with reason"
        case .notSupportedYet:
            return "Correction future-owned"
        case .unavailable:
            return "Correction not available"
        }
    }

    static func exportLabel(record: ActionReceiptHistoryRecord) -> String {
        if record.localOnly == false {
            return "Export needs confirmation"
        }
        if record.privacyLevel.requiresRedactionByDefault || record.hasMissingDetail {
            return "Export summary redacted"
        }
        return "Local export summary available"
    }

    static func privacyBoundaryLabel(record: ActionReceiptHistoryRecord) -> String {
        if record.localOnly == false {
            return "Not local-only"
        }
        if record.privacyLevel.requiresRedactionByDefault {
            return "Private detail hidden"
        }
        return "Stored on this device"
    }
}

struct ActionReceiptSearchQuery: Sendable, Equatable {
    let startDate: String?
    let endDate: String?
    let actionKinds: Set<ActionReceiptChangedFactKind>
    let resultStates: Set<ActionReceiptResultState>
    let relatedGoalID: String?
    let relatedCaptureID: String?
    let relatedPlanItemID: String?
    let sourceDomains: Set<ActionReceiptSourceDomain>
    let privacyLevels: Set<ActionReceiptPrivacyLevel>
    let undoAvailability: Set<ActionReceiptUndoAvailability>
    let trustStatuses: Set<ActionReceiptTrustStatus>
    let proofRelevance: Set<ActionReceiptProofRelevance>
    let requiresFreshnessReview: Bool?
    let searchText: String?
    let limit: Int?
    let projectionDetail: ActionReceiptProjectionDetail

    init(
        startDate: String? = nil,
        endDate: String? = nil,
        actionKinds: Set<ActionReceiptChangedFactKind> = [],
        resultStates: Set<ActionReceiptResultState> = [],
        relatedGoalID: String? = nil,
        relatedCaptureID: String? = nil,
        relatedPlanItemID: String? = nil,
        sourceDomains: Set<ActionReceiptSourceDomain> = [],
        privacyLevels: Set<ActionReceiptPrivacyLevel> = [],
        undoAvailability: Set<ActionReceiptUndoAvailability> = [],
        trustStatuses: Set<ActionReceiptTrustStatus> = [],
        proofRelevance: Set<ActionReceiptProofRelevance> = [],
        requiresFreshnessReview: Bool? = nil,
        searchText: String? = nil,
        limit: Int? = nil,
        projectionDetail: ActionReceiptProjectionDetail = .redacted
    ) {
        self.startDate = ActionReceiptChangedFact.normalizedOptional(startDate)
        self.endDate = ActionReceiptChangedFact.normalizedOptional(endDate)
        self.actionKinds = actionKinds
        self.resultStates = resultStates
        self.relatedGoalID = ActionReceiptChangedFact.normalizedOptional(relatedGoalID)
        self.relatedCaptureID = ActionReceiptChangedFact.normalizedOptional(relatedCaptureID)
        self.relatedPlanItemID = ActionReceiptChangedFact.normalizedOptional(relatedPlanItemID)
        self.sourceDomains = sourceDomains
        self.privacyLevels = privacyLevels
        self.undoAvailability = undoAvailability
        self.trustStatuses = trustStatuses
        self.proofRelevance = proofRelevance
        self.requiresFreshnessReview = requiresFreshnessReview
        self.searchText = ActionReceiptChangedFact.normalizedOptional(searchText)
        self.limit = limit
        self.projectionDetail = projectionDetail
    }
}

struct ActionReceiptSearchResult: Sendable, Equatable, Identifiable {
    let id: String
    let receiptID: String
    let title: String
    let summary: String
    let resultState: ActionReceiptResultState
    let occurredAt: String
    let sourceDomain: ActionReceiptSourceDomain
    let privacyLevel: ActionReceiptPrivacyLevel
    let trustStatus: ActionReceiptTrustStatus
    let proofRelevance: ActionReceiptProofRelevance
    let localOnly: Bool
    let safeToShowInExternalSurface: Bool
    let undoLabel: String
    let proofLabel: String
    let proofFreshnessLineage: ActionReceiptProofFreshnessLineage
    let runtimeLineage: RuntimeTrustLineage?
    let relatedObjectLabels: [String]
    let changedFactSummaries: [String]
    let hiddenDetailLabel: String?

    var isRedacted: Bool {
        hiddenDetailLabel != nil || privacyLevel == .redacted
    }
}

struct ActionReceiptSearchProjection: Sendable, Equatable {
    let query: ActionReceiptSearchQuery
    let results: [ActionReceiptSearchResult]
    let totalMatchCount: Int
    let emptyTitle: String
    let emptyDetail: String
    let localOnly: Bool

    var isEmpty: Bool {
        results.isEmpty
    }
}

struct ActionReceiptHistoryProjection: Sendable, Equatable {
    let records: [ActionReceiptHistoryRecord]
    let rejectedReceiptIDs: [String]

    init(records: [ActionReceiptHistoryRecord]) {
        var seen = Set<String>()
        var accepted: [ActionReceiptHistoryRecord] = []
        var rejected: [String] = []

        for record in records {
            guard record.receipt.isWellFormed, seen.insert(record.receipt.dedupeKey).inserted else {
                rejected.append(record.receipt.id.isEmpty ? "malformed-receipt" : record.receipt.id)
                continue
            }
            accepted.append(record)
        }

        self.records = accepted.sorted(by: Self.receiptSort)
        self.rejectedReceiptIDs = rejected.sorted()
    }

    func search(_ query: ActionReceiptSearchQuery = ActionReceiptSearchQuery()) -> ActionReceiptSearchProjection {
        let matched = records.filter { record in
            matches(record, query: query)
        }
        let limited: [ActionReceiptHistoryRecord]
        if let limit = query.limit {
            limited = Array(matched.prefix(max(0, limit)))
        } else {
            limited = matched
        }

        return ActionReceiptSearchProjection(
            query: query,
            results: limited.map { $0.projection(detail: query.projectionDetail) },
            totalMatchCount: matched.count,
            emptyTitle: "Nothing matched",
            emptyDetail: "Try a different filter.",
            localOnly: true
        )
    }

    func matches(_ record: ActionReceiptHistoryRecord, query: ActionReceiptSearchQuery) -> Bool {
        if let startDate = query.startDate, record.receipt.occurredAt < startDate { return false }
        if let endDate = query.endDate, record.receipt.occurredAt > endDate { return false }
        if query.actionKinds.isEmpty == false && record.receipt.changedFacts.contains(where: { query.actionKinds.contains($0.kind) }) == false { return false }
        if query.resultStates.isEmpty == false && query.resultStates.contains(record.receipt.resultState) == false { return false }
        if let relatedGoalID = query.relatedGoalID, record.relatedGoalIDs.contains(relatedGoalID) == false { return false }
        if let relatedCaptureID = query.relatedCaptureID, record.relatedCaptureIDs.contains(relatedCaptureID) == false { return false }
        if let relatedPlanItemID = query.relatedPlanItemID, record.relatedPlanItemIDs.contains(relatedPlanItemID) == false { return false }
        if query.sourceDomains.isEmpty == false && query.sourceDomains.contains(record.receipt.sourceDomain) == false { return false }
        if query.privacyLevels.isEmpty == false && query.privacyLevels.contains(record.privacyLevel) == false { return false }
        if query.undoAvailability.isEmpty == false && query.undoAvailability.contains(record.receipt.undoAvailability) == false { return false }
        if query.trustStatuses.isEmpty == false && query.trustStatuses.contains(record.trustStatus) == false { return false }
        if query.proofRelevance.isEmpty == false && query.proofRelevance.contains(record.proofRelevance) == false { return false }
        if let requiresFreshnessReview = query.requiresFreshnessReview, record.proofFreshnessLineage.requiresFreshnessReview != requiresFreshnessReview { return false }
        if let searchText = query.searchText, record.searchIndex.contains(searchText.lowercased()) == false { return false }
        return true
    }

    static func receiptSort(_ lhs: ActionReceiptHistoryRecord, _ rhs: ActionReceiptHistoryRecord) -> Bool {
        if lhs.receipt.occurredAt != rhs.receipt.occurredAt {
            return lhs.receipt.occurredAt > rhs.receipt.occurredAt
        }
        if lhs.receipt.createdAt != rhs.receipt.createdAt {
            return lhs.receipt.createdAt > rhs.receipt.createdAt
        }
        return lhs.receipt.id < rhs.receipt.id
    }
}

extension ActionReceiptHistoryRecord {
    var searchIndex: String {
        ([
            receipt.id,
            receipt.title,
            receipt.summary,
            receipt.sourceDomain.rawValue,
            receipt.resultState.rawValue
        ] + receipt.changedFacts.flatMap { fact in
            [fact.kind.rawValue, fact.summary, fact.fieldName, fact.previousValueSummary, fact.newValueSummary].compactMap { $0 }
        } + receipt.affectedObjects.flatMap { object in
            [object.kind.rawValue, object.id, object.label, object.sourceDomain?.rawValue].compactMap { $0 }
        }).joined(separator: " ").lowercased()
    }
}
