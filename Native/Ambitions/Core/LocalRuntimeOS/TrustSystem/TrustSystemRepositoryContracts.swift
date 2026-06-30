import Foundation

protocol ActionReceiptHistoryRepository: Sendable {
    func save(_ records: [ActionReceiptHistoryRecord]) async throws
    func fetch(_ query: ActionReceiptSearchQuery) async throws -> ActionReceiptSearchProjection
    func listRecords() async throws -> [ActionReceiptHistoryRecord]
}

enum TrustHistoryQueryItemKind: String, Sendable, Codable, Equatable {
    case actionReceipt = "action_receipt"
    case eventLedger = "event_ledger"
}

struct TrustHistoryQuery: Sendable, Equatable {
    let startDate: String?
    let endDate: String?
    let receiptSourceDomains: Set<ActionReceiptSourceDomain>
    let receiptPrivacyLevels: Set<ActionReceiptPrivacyLevel>
    let receiptProofRelevance: Set<ActionReceiptProofRelevance>
    let receiptTrustStatuses: Set<ActionReceiptTrustStatus>
    let receiptRequiresFreshnessReview: Bool?
    let eventSources: Set<EventLedgerSource>
    let eventPrivacyLevels: Set<EventLedgerPrivacyClassification>
    let requiresReview: Bool?
    let userConfirmed: Bool?
    let proofReferenceKinds: Set<EventLedgerEvidenceKind>
    let requiresProofReferences: Bool?
    let includeReceiptHistory: Bool
    let includeEventLedger: Bool
    let limit: Int?

    init(
        startDate: String? = nil,
        endDate: String? = nil,
        receiptSourceDomains: Set<ActionReceiptSourceDomain> = [],
        receiptPrivacyLevels: Set<ActionReceiptPrivacyLevel> = [],
        receiptProofRelevance: Set<ActionReceiptProofRelevance> = [],
        receiptTrustStatuses: Set<ActionReceiptTrustStatus> = [],
        receiptRequiresFreshnessReview: Bool? = nil,
        eventSources: Set<EventLedgerSource> = [],
        eventPrivacyLevels: Set<EventLedgerPrivacyClassification> = [],
        requiresReview: Bool? = nil,
        userConfirmed: Bool? = nil,
        proofReferenceKinds: Set<EventLedgerEvidenceKind> = [],
        requiresProofReferences: Bool? = nil,
        includeReceiptHistory: Bool = true,
        includeEventLedger: Bool = true,
        limit: Int? = nil
    ) {
        self.startDate = startDate?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.endDate = endDate?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.receiptSourceDomains = receiptSourceDomains
        self.receiptPrivacyLevels = receiptPrivacyLevels
        self.receiptProofRelevance = receiptProofRelevance
        self.receiptTrustStatuses = receiptTrustStatuses
        self.receiptRequiresFreshnessReview = receiptRequiresFreshnessReview
        self.eventSources = eventSources
        self.eventPrivacyLevels = eventPrivacyLevels
        self.requiresReview = requiresReview
        self.userConfirmed = userConfirmed
        self.proofReferenceKinds = proofReferenceKinds
        self.requiresProofReferences = requiresProofReferences
        self.includeReceiptHistory = includeReceiptHistory
        self.includeEventLedger = includeEventLedger
        self.limit = limit
    }
}

struct TrustHistoryQueryResult: Sendable, Equatable, Identifiable {
    let id: String
    let kind: TrustHistoryQueryItemKind
    let source: String
    let occurredAt: String
    let privacy: String
    let proofRelevance: ActionReceiptProofRelevance?
    let trustStatus: ActionReceiptTrustStatus?
    let requiresReview: Bool?
    let userConfirmed: Bool?
    let proofReferenceKinds: [EventLedgerEvidenceKind]
    let localOnly: Bool
    let title: String
    let summary: String
    let proofFreshnessLineage: ActionReceiptProofFreshnessLineage?
}

struct TrustHistoryQueryProjection: Sendable, Equatable {
    let query: TrustHistoryQuery
    let results: [TrustHistoryQueryResult]
    let totalMatchCount: Int
    let emptyTitle: String
    let emptyDetail: String
    let localOnly: Bool

    var isEmpty: Bool {
        results.isEmpty
    }
}

protocol TrustHistoryQueryRepository: Sendable {
    func fetch(_ query: TrustHistoryQuery) async throws -> TrustHistoryQueryProjection
}

protocol EventLedgerRepository: Sendable {
    func append(_ event: EventLedgerEntry) async throws
    func fetchRecent(limit: Int) async throws -> [EventLedgerEntry]
    func fetchEvents(goalID: String) async throws -> [EventLedgerEntry]
    func fetchEvents(captureID: String) async throws -> [EventLedgerEntry]
    func fetchEvents(kind: EventLedgerKind) async throws -> [EventLedgerEntry]
    func fetchEvents(from start: String, through end: String) async throws -> [EventLedgerEntry]
    func redactEvent(id: String, at timestamp: String) async throws
    func deleteEvent(id: String) async throws
}

protocol EntityRevisionTombstoneRepository: Sendable {
    func append(_ tombstone: EntityRevisionTombstone) async throws
    func fetchRecent(limit: Int) async throws -> [EntityRevisionTombstone]
    func fetch(for entityID: String) async throws -> [EntityRevisionTombstone]
    func fetch(lineageID: String) async throws -> [EntityRevisionTombstone]
    func fetchRecoverable(limit: Int) async throws -> [EntityRevisionTombstone]
    func fetchFinalized(limit: Int) async throws -> [EntityRevisionTombstone]
}

protocol ExecutionLedgerReplayInspectionRepository: Sendable {
    func fetch(_ query: ExecutionLedgerReplayInspectionQuery) async throws -> ExecutionLedgerReplayInspectionProjection
}
