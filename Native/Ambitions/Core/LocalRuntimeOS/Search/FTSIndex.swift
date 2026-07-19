import Foundation

let ftsIndexSchemaVersion = "search_fts_index.native.v1"

struct FTSIndexHealth: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let storageHealth: SearchStoreFTSHealth
    let validatesActions: Bool
    let localOnly: Bool
}

actor FTSIndex {
    private let store: SearchStoreFTS
    private let ranker: ResultRanker
    private let validator: SearchActionValidator

    init(
        store: SearchStoreFTS,
        ranker: ResultRanker = ResultRanker(),
        validator: SearchActionValidator = SearchActionValidator()
    ) {
        self.store = store
        self.ranker = ranker
        self.validator = validator
    }

    func rebuild(from projection: SearchProjection, updatedAt: String) async throws -> SearchRebuildIndexReceipt {
        try await store.rebuild(from: projection, updatedAt: updatedAt)
        let health = try await store.health()
        return SearchRebuildIndexReceipt(
            projectionID: projection.id,
            cursor: projection.cursor,
            indexedRecordCount: health.indexedRecordCount,
            indexedEventIDs: health.indexedEventIDs,
            updatedAt: updatedAt
        )
    }

    func replaceAll(_ records: [SearchStoreFTSRecord]) async throws {
        try await store.replaceAll(records)
    }

    func search(
        _ query: SearchQuery,
        familyPriority: [LocalSearchObjectFamily: Int] = [:],
        searchedAt: String
    ) async throws -> [FindActInspectResult] {
        let storeRecords = try await store.search(
            SearchStoreFTSQuery(
                rawText: query.rawText,
                allowedPrivacy: query.allowedPrivacy,
                limit: max(query.limit * 3, query.limit)
            )
        )
        let directResults = storeRecords
            .map(FindActInspectResult.init)
            .filter { query.allowedFamilies?.contains($0.family) ?? true }
            .filter { query.requiresLocalOnly == false || $0.localOnly }

        let semanticMatches = SemanticLocalIndex(results: directResults)
            .search(query)
            .map(\.result)

        let merged = Self.merge(directResults + semanticMatches)
        let validated = merged.filter { result in
            validator.validate(
                result: result,
                query: query,
                validatedAt: searchedAt
            ).isAllowed
        }

        return ranker.rank(validated, query: query, familyPriority: familyPriority)
    }

    func validationReport(
        for result: FindActInspectResult,
        query: SearchQuery,
        actionKind: SearchActionKind = .open,
        validatedAt: String
    ) -> SearchActionValidationReport {
        validator.validate(
            result: result,
            query: query,
            actionKind: actionKind,
            validatedAt: validatedAt
        )
    }

    func health() async throws -> FTSIndexHealth {
        FTSIndexHealth(
            schemaVersion: ftsIndexSchemaVersion,
            storageHealth: try await store.health(),
            validatesActions: true,
            localOnly: true
        )
    }

    private static func merge(_ results: [FindActInspectResult]) -> [FindActInspectResult] {
        var bestByID: [String: FindActInspectResult] = [:]
        for result in results {
            if let existing = bestByID[result.id] {
                bestByID[result.id] = result.rankScore > existing.rankScore ? result : existing
            } else {
                bestByID[result.id] = result
            }
        }
        return Array(bestByID.values)
    }
}

struct SearchRebuildIndexReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let projectionID: ProjectionID
    let cursor: ProjectionCursor
    let indexedRecordCount: Int
    let indexedEventIDs: [String]
    let updatedAt: String
    let schemaVersion: String

    init(
        projectionID: ProjectionID,
        cursor: ProjectionCursor,
        indexedRecordCount: Int,
        indexedEventIDs: [String],
        updatedAt: String,
        schemaVersion: String = ftsIndexSchemaVersion
    ) {
        id = "search.fts-index.\(cursor.sequence).\(updatedAt)"
        self.projectionID = projectionID
        self.cursor = cursor
        self.indexedRecordCount = max(0, indexedRecordCount)
        self.indexedEventIDs = Array(Set(indexedEventIDs.filter { $0.isEmpty == false })).sorted()
        self.updatedAt = updatedAt
        self.schemaVersion = schemaVersion
    }
}
