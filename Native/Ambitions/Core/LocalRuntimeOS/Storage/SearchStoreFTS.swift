import Foundation
import SQLite3

let searchStoreFTSSchemaVersion = "search_store_fts.native.v1"

struct SearchStoreFTSRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let objectFamily: String
    let title: String
    let body: String
    let provenance: String
    let actionValidation: AmbitionsCommandValidationState
    let privacy: EventLedgerPrivacyClassification
    let eventID: String
    let objectIDs: [String]
    let updatedAt: String
    let score: Int

    init(result: SearchProjectionResult, updatedAt: String) {
        id = result.id
        objectFamily = result.objectIDs.first?.split(separator: ".").first.map(String.init) ?? "runtime_event"
        title = result.title
        body = result.objectIDs.joined(separator: " ")
        provenance = result.provenance
        actionValidation = result.actionValidation
        privacy = result.privacy
        eventID = result.eventID
        objectIDs = result.objectIDs
        self.updatedAt = updatedAt
        score = result.score
    }

    init(
        id: String,
        objectFamily: String,
        title: String,
        body: String,
        provenance: String,
        actionValidation: AmbitionsCommandValidationState,
        privacy: EventLedgerPrivacyClassification,
        eventID: String,
        objectIDs: [String],
        updatedAt: String,
        score: Int
    ) {
        self.id = id
        self.objectFamily = objectFamily
        self.title = title
        self.body = body
        self.provenance = provenance
        self.actionValidation = actionValidation
        self.privacy = privacy
        self.eventID = eventID
        self.objectIDs = Array(Set(objectIDs.filter { $0.isEmpty == false })).sorted()
        self.updatedAt = updatedAt
        self.score = max(0, score)
    }
}

struct SearchStoreFTSQuery: Sendable, Equatable, Hashable {
    let rawText: String
    let allowedPrivacy: Set<EventLedgerPrivacyClassification>
    let limit: Int

    static let allPrivacyClasses: Set<EventLedgerPrivacyClassification> = [
        .standard,
        .sensitive,
        .privateUserText,
        .calendarDerived,
        .syncMetadata
    ]

    init(
        rawText: String,
        allowedPrivacy: Set<EventLedgerPrivacyClassification> = SearchStoreFTSQuery.allPrivacyClasses,
        limit: Int = 32
    ) {
        self.rawText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.allowedPrivacy = allowedPrivacy
        self.limit = max(0, limit)
    }

    var normalizedFTSText: String {
        rawText
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9]+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct SearchStoreFTSHealth: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let indexedRecordCount: Int
    let indexedEventIDs: [String]
    let storageTier: LocalRuntimeStorageTier
}

actor SearchStoreFTS {
    private let databaseURL: URL

    init(databaseURL: URL) {
        self.databaseURL = databaseURL
    }

    static func defaultLiveStore(fileManager: FileManager = .default) -> SearchStoreFTS {
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: "/tmp", isDirectory: true)
        return SearchStoreFTS(
            databaseURL: supportDirectory
                .appendingPathComponent("AmbitionsLocalRuntimeOS", isDirectory: true)
                .appendingPathComponent("SearchStore.sqlite", isDirectory: false)
        )
    }

    func rebuild(from projection: SearchProjection, updatedAt: String) async throws {
        try await replaceAll(projection.results.map { SearchStoreFTSRecord(result: $0, updatedAt: updatedAt) })
    }

    func replaceAll(_ records: [SearchStoreFTSRecord]) async throws {
        let database = try openDatabase()
        try createSchema(database)
        try database.transaction {
            try database.execute("DELETE FROM search_records")
            for record in records {
                try insert(record, database: database)
            }
        }
    }

    func search(_ query: SearchStoreFTSQuery) async throws -> [SearchStoreFTSRecord] {
        let database = try openDatabase()
        try createSchema(database)
        if query.normalizedFTSText.isEmpty {
            return try selectRecords(
                sql: "SELECT * FROM search_records ORDER BY score DESC, updated_at DESC, title ASC LIMIT ?",
                database: database
            ) {
                try LocalRuntimeSQLite.bind(query.limit, to: $0, at: 1, parameter: "limit")
            }
            .filter { query.allowedPrivacy.contains($0.privacy) }
        }

        return try selectRecords(
            sql: "SELECT * FROM search_records WHERE search_records MATCH ? ORDER BY rank, score DESC, updated_at DESC LIMIT ?",
            database: database
        ) {
            try LocalRuntimeSQLite.bind(query.normalizedFTSText, to: $0, at: 1, parameter: "query")
            try LocalRuntimeSQLite.bind(query.limit, to: $0, at: 2, parameter: "limit")
        }
        .filter { query.allowedPrivacy.contains($0.privacy) }
    }

    func health() async throws -> SearchStoreFTSHealth {
        let records = try await search(SearchStoreFTSQuery(rawText: "", limit: Int.max))
        return SearchStoreFTSHealth(
            schemaVersion: searchStoreFTSSchemaVersion,
            indexedRecordCount: records.count,
            indexedEventIDs: records.map(\.eventID).sorted(),
            storageTier: .searchStoreFTS
        )
    }
}

private extension SearchStoreFTS {
    func openDatabase() throws -> LocalRuntimeSQLiteDatabase {
        try LocalRuntimeSQLiteDatabase(url: databaseURL)
    }

    func createSchema(_ database: LocalRuntimeSQLiteDatabase) throws {
        try database.execute(
            """
            CREATE VIRTUAL TABLE IF NOT EXISTS search_records USING fts5(
                id UNINDEXED,
                object_family,
                title,
                body,
                provenance,
                action_validation UNINDEXED,
                privacy UNINDEXED,
                event_id UNINDEXED,
                object_ids_json UNINDEXED,
                updated_at UNINDEXED,
                score UNINDEXED
            );
            """
        )
    }

    func insert(_ record: SearchStoreFTSRecord, database: LocalRuntimeSQLiteDatabase) throws {
        let sql =
            """
            INSERT INTO search_records (
                id, object_family, title, body, provenance, action_validation,
                privacy, event_id, object_ids_json, updated_at, score
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try LocalRuntimeSQLite.bind(record.id, to: statement, at: 1, parameter: "id")
        try LocalRuntimeSQLite.bind(record.objectFamily, to: statement, at: 2, parameter: "object_family")
        try LocalRuntimeSQLite.bind(record.title, to: statement, at: 3, parameter: "title")
        try LocalRuntimeSQLite.bind(record.body, to: statement, at: 4, parameter: "body")
        try LocalRuntimeSQLite.bind(record.provenance, to: statement, at: 5, parameter: "provenance")
        try LocalRuntimeSQLite.bind(record.actionValidation.rawValue, to: statement, at: 6, parameter: "action_validation")
        try LocalRuntimeSQLite.bind(record.privacy.rawValue, to: statement, at: 7, parameter: "privacy")
        try LocalRuntimeSQLite.bind(record.eventID, to: statement, at: 8, parameter: "event_id")
        try LocalRuntimeSQLite.bind(try LocalRuntimeStorageCoding.encode(record.objectIDs), to: statement, at: 9, parameter: "object_ids_json")
        try LocalRuntimeSQLite.bind(record.updatedAt, to: statement, at: 10, parameter: "updated_at")
        try LocalRuntimeSQLite.bind(record.score, to: statement, at: 11, parameter: "score")
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: database.sqliteMessage)
        }
    }

    func selectRecords(
        sql: String,
        database: LocalRuntimeSQLiteDatabase,
        binder: ((OpaquePointer) throws -> Void)? = nil
    ) throws -> [SearchStoreFTSRecord] {
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try binder?(statement)

        var records: [SearchStoreFTSRecord] = []
        while true {
            let result = sqlite3_step(statement)
            if result == SQLITE_ROW {
                let validationRaw = try LocalRuntimeSQLite.text(statement, 5, column: "action_validation")
                let privacyRaw = try LocalRuntimeSQLite.text(statement, 6, column: "privacy")
                guard let actionValidation = AmbitionsCommandValidationState(rawValue: validationRaw) else {
                    throw LocalRuntimeStorageError.sqliteCorruptText(column: "action_validation")
                }
                guard let privacy = EventLedgerPrivacyClassification(rawValue: privacyRaw) else {
                    throw LocalRuntimeStorageError.sqliteCorruptText(column: "privacy")
                }
                let objectIDsData = try LocalRuntimeSQLite.blob(statement, 8, column: "object_ids_json")
                records.append(SearchStoreFTSRecord(
                    id: try LocalRuntimeSQLite.text(statement, 0, column: "id"),
                    objectFamily: try LocalRuntimeSQLite.text(statement, 1, column: "object_family"),
                    title: try LocalRuntimeSQLite.text(statement, 2, column: "title"),
                    body: try LocalRuntimeSQLite.text(statement, 3, column: "body"),
                    provenance: try LocalRuntimeSQLite.text(statement, 4, column: "provenance"),
                    actionValidation: actionValidation,
                    privacy: privacy,
                    eventID: try LocalRuntimeSQLite.text(statement, 7, column: "event_id"),
                    objectIDs: try LocalRuntimeStorageCoding.decode([String].self, from: objectIDsData),
                    updatedAt: try LocalRuntimeSQLite.text(statement, 9, column: "updated_at"),
                    score: Int(LocalRuntimeSQLite.int64(statement, 10))
                ))
            } else if result == SQLITE_DONE {
                return records
            } else {
                throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: database.sqliteMessage)
            }
        }
    }
}
