import AmbitionsDesignSystem
import Foundation
import SwiftData

struct SwiftDataTrustHistoryQueryRepository: TrustHistoryQueryRepository {
    let store: AmbitionsPersistenceStore

    func fetch(_ query: TrustHistoryQuery) async throws -> TrustHistoryQueryProjection {
        try await store.read { context in
            var items: [TrustHistoryQueryResult] = []

            if query.includeReceiptHistory {
                let receiptItems = try context
                    .fetch(FetchDescriptor<ActionReceiptHistoryRecordModel>())
                    .compactMap { persistedRecord in
                        try? RepositoryMapping.actionReceiptHistoryRecord(from: persistedRecord)
                    }
                    .filter { self.matches($0, query: query) }
                    .map(self.makeResult(from:))
                items.append(contentsOf: receiptItems)
            }

            if query.includeEventLedger {
                let eventItems = try context
                    .fetch(FetchDescriptor<EventLedgerRecord>())
                    .compactMap { persistedRecord in
                        try? RepositoryMapping.eventLedgerEntry(from: persistedRecord)
                    }
                    .filter { self.matches($0, query: query) }
                    .map(self.makeResult(from:))
                items.append(contentsOf: eventItems)
            }

            let sorted = items
                .sorted {
                    let lhsDate = PersistedTemporalValue.date(from: $0.occurredAt)
                    let rhsDate = PersistedTemporalValue.date(from: $1.occurredAt)
                    if lhsDate != rhsDate { return lhsDate > rhsDate }
                    if $0.kind != $1.kind {
                        return $0.kind == .actionReceipt && $1.kind == .eventLedger
                    }
                    return $0.id < $1.id
                }

            let bounded = max(0, query.limit ?? sorted.count)
            let results = Array(sorted.prefix(min(bounded, sorted.count)))
            let localOnly = results.allSatisfy { $0.localOnly }

            return TrustHistoryQueryProjection(
                query: query,
                results: results,
                totalMatchCount: sorted.count,
                emptyTitle: "Nothing matched",
                emptyDetail: "Try a different query or relax review and proof filters.",
                localOnly: localOnly
            )
        }
    }

    func makeResult(from record: ActionReceiptHistoryRecord) -> TrustHistoryQueryResult {
        TrustHistoryQueryResult(
            id: "receipt.\(record.receipt.id)",
            kind: .actionReceipt,
            source: record.receipt.sourceDomain.rawValue,
            occurredAt: record.receipt.occurredAt,
            privacy: record.privacyLevel.rawValue,
            proofRelevance: record.proofRelevance,
            trustStatus: record.trustStatus,
            requiresReview: nil,
            userConfirmed: nil,
            proofReferenceKinds: [],
            localOnly: record.localOnly,
            title: record.receipt.title,
            summary: record.receipt.summary,
            proofFreshnessLineage: record.proofFreshnessLineage
        )
    }

    func makeResult(from event: EventLedgerEntry) -> TrustHistoryQueryResult {
        TrustHistoryQueryResult(
            id: "event.\(event.id)",
            kind: .eventLedger,
            source: event.source.rawValue,
            occurredAt: event.occurredAt,
            privacy: event.privacy.rawValue,
            proofRelevance: nil,
            trustStatus: nil,
            requiresReview: event.trust.requiresReview,
            userConfirmed: event.trust.isUserConfirmed,
            proofReferenceKinds: event.evidenceReferences
                .map { $0.kind }
                .sorted { lhs, rhs in
                    lhs.rawValue < rhs.rawValue
                },
            localOnly: event.localOnly,
            title: event.title,
            summary: event.summary ?? "",
            proofFreshnessLineage: nil
        )
    }

    func matches(_ record: ActionReceiptHistoryRecord, query: TrustHistoryQuery) -> Bool {
        if query.includeReceiptHistory == false { return false }
        let occurredAtDate = PersistedTemporalValue.date(from: record.receipt.occurredAt)
        if let startDate = query.startDate, occurredAtDate < PersistedTemporalValue.date(from: startDate) { return false }
        if let endDate = query.endDate, occurredAtDate > PersistedTemporalValue.date(from: endDate, fallback: .distantFuture) { return false }
        if query.receiptSourceDomains.isEmpty == false && query.receiptSourceDomains.contains(record.receipt.sourceDomain) == false { return false }
        if query.receiptPrivacyLevels.isEmpty == false && query.receiptPrivacyLevels.contains(record.privacyLevel) == false { return false }
        if query.receiptProofRelevance.isEmpty == false && query.receiptProofRelevance.contains(record.proofRelevance) == false { return false }
        if query.receiptTrustStatuses.isEmpty == false && query.receiptTrustStatuses.contains(record.trustStatus) == false { return false }
        if let requiresFreshnessReview = query.receiptRequiresFreshnessReview, record.proofFreshnessLineage.requiresFreshnessReview != requiresFreshnessReview { return false }
        return true
    }

    func matches(_ event: EventLedgerEntry, query: TrustHistoryQuery) -> Bool {
        if query.includeEventLedger == false { return false }
        let occurredAtDate = PersistedTemporalValue.date(from: event.occurredAt)
        if let startDate = query.startDate, occurredAtDate < PersistedTemporalValue.date(from: startDate) { return false }
        if let endDate = query.endDate, occurredAtDate > PersistedTemporalValue.date(from: endDate, fallback: .distantFuture) { return false }
        if query.eventSources.isEmpty == false && query.eventSources.contains(event.source) == false { return false }
        if query.eventPrivacyLevels.isEmpty == false && query.eventPrivacyLevels.contains(event.privacy) == false { return false }
        if let requiresReview = query.requiresReview, event.trust.requiresReview != requiresReview { return false }
        if let userConfirmed = query.userConfirmed, event.trust.isUserConfirmed != userConfirmed { return false }
        if let requiresProofReferences = query.requiresProofReferences {
            if event.evidenceReferences.isEmpty == requiresProofReferences { return false }
        }
        if query.proofReferenceKinds.isEmpty == false {
            if event.evidenceReferences.map({ $0.kind }).contains(where: { query.proofReferenceKinds.contains($0) }) == false { return false }
        }
        return true
    }
}

struct SwiftDataEventLedgerRepository: EventLedgerRepository {
    let store: AmbitionsPersistenceStore

    func append(_ event: EventLedgerEntry) async throws {
        try await store.write { context in
            if let record = try context.fetch(FetchDescriptor<EventLedgerRecord>()).first(where: { $0.id == event.id }) {
                try RepositoryMapping.apply(event, to: record)
            } else {
                context.insert(try RepositoryMapping.eventLedgerRecord(from: event))
            }
        }
    }

    func fetchRecent(limit: Int) async throws -> [EventLedgerEntry] {
        let boundedLimit = max(0, limit)
        let events = try await fetchAll { _ in true }
        return events.prefixArray(boundedLimit)
    }

    func fetchEvents(goalID: String) async throws -> [EventLedgerEntry] {
        try await fetchAll { $0.goalID == goalID }
    }

    func fetchEvents(captureID: String) async throws -> [EventLedgerEntry] {
        try await fetchAll { $0.captureID == captureID }
    }

    func fetchEvents(kind: EventLedgerKind) async throws -> [EventLedgerEntry] {
        try await fetchAll { $0.kindRaw == kind.rawValue }
    }

    func fetchEvents(from start: String, through end: String) async throws -> [EventLedgerEntry] {
        let startDate = PersistedTemporalValue.date(from: start)
        let endDate = PersistedTemporalValue.date(from: end, fallback: .distantFuture)
        return try await fetchAll {
            let occurredAtDate = PersistedTemporalValue.dateKey(primary: $0.occurredAtDate, rawValue: $0.occurredAt)
            return occurredAtDate >= startDate && occurredAtDate <= endDate
        }
    }

    func redactEvent(id: String, at timestamp: String) async throws {
        try await store.write { context in
            guard let record = try context.fetch(FetchDescriptor<EventLedgerRecord>()).first(where: { $0.id == id }) else {
                return
            }
            let redacted = try RepositoryMapping.eventLedgerEntry(from: record).redacted(at: timestamp)
            try RepositoryMapping.apply(redacted, to: record)
        }
    }

    func deleteEvent(id: String) async throws {
        try await store.write { context in
            for record in try context.fetch(FetchDescriptor<EventLedgerRecord>()) where record.id == id {
                context.delete(record)
            }
        }
    }

    func fetchAll(where isIncluded: @escaping @Sendable (EventLedgerRecord) -> Bool) async throws -> [EventLedgerEntry] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<EventLedgerRecord>())
                .filter(isIncluded)
                .sorted {
                    let lhsDate = PersistedTemporalValue.dateKey(primary: $0.occurredAtDate, rawValue: $0.occurredAt)
                    let rhsDate = PersistedTemporalValue.dateKey(primary: $1.occurredAtDate, rawValue: $1.occurredAt)
                    if lhsDate != rhsDate {
                        return lhsDate > rhsDate
                    }
                    return $0.id > $1.id
                }
                .map(RepositoryMapping.eventLedgerEntry(from:))
        }
    }
}

extension Array where Element == EventLedgerEntry {
    func prefixArray(_ count: Int) -> [EventLedgerEntry] {
        Array(prefix(count))
    }
}

struct SwiftDataAppStateRepository: AppStateRepository {
    let store: AmbitionsPersistenceStore

    func loadState() async throws -> AppStateSnapshot {
        try await store.read { context in
            guard let record = try context.fetch(FetchDescriptor<AppStateRecord>()).first else {
                return .default
            }
            return try RepositoryMapping.appState(from: record)
        }
    }

    func saveState(_ state: AppStateSnapshot) async throws {
        try await store.write { context in
            if let record = try context.fetch(FetchDescriptor<AppStateRecord>()).first(where: { $0.id == state.id }) {
                record.preferredTabRaw = state.preferredTab.rawValue
                record.userDisplayName = state.userDisplayName
                record.appearancePreferenceRaw = state.appearancePreference.rawValue
                record.hasCompletedBootstrap = state.hasCompletedBootstrap
                record.lastBootstrapSourceRaw = state.lastBootstrapSource?.rawValue
                record.lastBootstrapAt = state.lastBootstrapAt
                record.lastSeedVersion = state.lastSeedVersion
                record.lastSeededAt = state.lastSeededAt
                record.lastOpenedGoalID = state.lastOpenedGoalID
                record.snapshotData = try PersistenceCoding.encode(state)
            } else {
                context.insert(try RepositoryMapping.appStateRecord(from: state))
            }
        }
    }
}

struct SwiftDataActionReceiptHistoryRepository: ActionReceiptHistoryRepository {
    let store: AmbitionsPersistenceStore

    func save(_ records: [ActionReceiptHistoryRecord]) async throws {
        try await store.write { context in
            let existing = Dictionary(
                uniqueKeysWithValues: try context.fetch(FetchDescriptor<ActionReceiptHistoryRecordModel>()).map { ($0.id, $0) }
            )

            for record in records {
                if let persisted = existing[record.id] {
                    try RepositoryMapping.apply(record, to: persisted)
                } else {
                    context.insert(try RepositoryMapping.actionReceiptHistoryRecord(from: record))
                }
            }
        }
    }

    func fetch(_ query: ActionReceiptSearchQuery) async throws -> ActionReceiptSearchProjection {
        try await store.read { context in
            let persisted = try context.fetch(FetchDescriptor<ActionReceiptHistoryRecordModel>())
            let records = persisted.compactMap { persistedRecord in
                try? RepositoryMapping.actionReceiptHistoryRecord(from: persistedRecord)
            }
            return ActionReceiptHistoryProjection(records: records).search(query)
        }
    }

    func listRecords() async throws -> [ActionReceiptHistoryRecord] {
        try await store.read { context in
            let persisted = try context.fetch(FetchDescriptor<ActionReceiptHistoryRecordModel>())
            return persisted.compactMap { persistedRecord in
                try? RepositoryMapping.actionReceiptHistoryRecord(from: persistedRecord)
            }
        }
    }
}
