import Foundation

enum CaptureIntakeJournalError: Error, Equatable {
    case emptyText
    case missingDurableReceipt(String)
    case nonAppendOnlySequence(expected: Int, actual: Int)
}

struct CaptureIntakeJournalAppendRequest: Sendable, Equatable {
    let captureID: String
    let rawText: String
    let sourceType: CaptureSourceType?
    let sourceSurface: String
    let receivedAt: String
    let commandID: String?
    let attachmentIDs: [String]
    let deadlineIntent: String?
    let goalIntent: String?
    let stepIntent: String?
    let proofIntent: String?
    let privacy: EventLedgerPrivacyClassification

    init(
        captureID: String,
        rawText: String,
        sourceType: CaptureSourceType?,
        sourceSurface: String,
        receivedAt: String,
        commandID: String? = nil,
        attachmentIDs: [String] = [],
        deadlineIntent: String? = nil,
        goalIntent: String? = nil,
        stepIntent: String? = nil,
        proofIntent: String? = nil,
        privacy: EventLedgerPrivacyClassification = .privateUserText
    ) {
        self.captureID = CaptureRouteGraphStableID.required(captureID)
        self.rawText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceType = sourceType
        self.sourceSurface = CaptureRouteGraphStableID.required(sourceSurface)
        self.receivedAt = CaptureRouteGraphStableID.required(receivedAt)
        self.commandID = CaptureRouteGraphStableID.optional(commandID)
        self.attachmentIDs = CaptureRouteGraphStableID.unique(attachmentIDs)
        self.deadlineIntent = CaptureRouteGraphStableID.optional(deadlineIntent)
        self.goalIntent = CaptureRouteGraphStableID.optional(goalIntent)
        self.stepIntent = CaptureRouteGraphStableID.optional(stepIntent)
        self.proofIntent = CaptureRouteGraphStableID.optional(proofIntent)
        self.privacy = privacy
    }
}

struct CaptureIntakeJournalRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sequence: Int
    let captureID: String
    let rawText: String
    let sourceType: CaptureSourceType?
    let sourceSurface: String
    let receivedAt: String
    let commandID: String?
    let attachmentIDs: [String]
    let deadlineIntent: String?
    let goalIntent: String?
    let stepIntent: String?
    let proofIntent: String?
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let checksum: String

    init(sequence: Int, request: CaptureIntakeJournalAppendRequest) throws {
        guard request.rawText.isEmpty == false else {
            throw CaptureIntakeJournalError.emptyText
        }
        self.sequence = sequence
        captureID = request.captureID
        rawText = request.rawText
        sourceType = request.sourceType
        sourceSurface = request.sourceSurface
        receivedAt = request.receivedAt
        commandID = request.commandID
        attachmentIDs = request.attachmentIDs
        deadlineIntent = request.deadlineIntent
        goalIntent = request.goalIntent
        stepIntent = request.stepIntent
        proofIntent = request.proofIntent
        privacy = request.privacy
        localOnly = true
        id = CaptureRouteGraphStableID.make(
            prefix: "capture-intake.record",
            components: [captureID, receivedAt, String(sequence), rawText]
        )
        checksum = CaptureRouteGraphStableID.checksum(
            prefix: "capture-intake.record",
            components: [
                id,
                String(sequence),
                captureID,
                rawText,
                sourceType?.rawValue ?? "",
                sourceSurface,
                receivedAt,
                commandID ?? "",
                attachmentIDs.joined(separator: ","),
                deadlineIntent ?? "",
                goalIntent ?? "",
                stepIntent ?? "",
                proofIntent ?? "",
                privacy.rawValue,
                "local"
            ]
        )
    }
}

struct CaptureIntakeJournalReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let journalRecordID: String
    let sequence: Int
    let captureID: String
    let occurredAt: String
    let checksum: String
    let localOnly: Bool
    let acknowledgedAfterDurableWrite: Bool
    let privacy: EventLedgerPrivacyClassification
    let runtimeTrace: CaptureRouteGraphRuntimeTrace

    init(record: CaptureIntakeJournalRecord, acknowledgedAfterDurableWrite: Bool) {
        journalRecordID = record.id
        sequence = record.sequence
        captureID = record.captureID
        occurredAt = record.receivedAt
        checksum = record.checksum
        localOnly = record.localOnly
        self.acknowledgedAfterDurableWrite = acknowledgedAfterDurableWrite
        privacy = record.privacy
        runtimeTrace = CaptureRouteGraphRuntimeTrace.make(owner: "CaptureIntakeJournal", sourceID: record.id, localOnly: record.localOnly)
        id = CaptureRouteGraphStableID.make(prefix: "capture-intake.receipt", components: [record.id, record.checksum])
    }

    var canClassify: Bool {
        localOnly && acknowledgedAfterDurableWrite && runtimeTrace.satisfiesRuntimeSpine
    }
}

actor CaptureIntakeJournal {
    private var recordsCache: [CaptureIntakeJournalRecord]?
    private let fileStore: CaptureRouteGraphJSONFileStore<[CaptureIntakeJournalRecord]>?

    init(fileURL: URL? = nil) {
        fileStore = fileURL.map { CaptureRouteGraphJSONFileStore(fileURL: $0, emptyValue: []) }
    }

    static func fileBacked(rootDirectory: URL) -> CaptureIntakeJournal {
        CaptureIntakeJournal(
            fileURL: CaptureRouteGraphJSONFileStore<[CaptureIntakeJournalRecord]>.fileURL(
                rootDirectory: rootDirectory,
                fileName: "CaptureIntakeJournal.json"
            )
        )
    }

    @discardableResult
    func append(_ request: CaptureIntakeJournalAppendRequest) async throws -> CaptureIntakeJournalReceipt {
        var records = try await loadRecords()
        let sequence = records.count + 1
        let record = try CaptureIntakeJournalRecord(sequence: sequence, request: request)
        try validateAppend(record, after: records.last)
        records.append(record)
        try await persist(records)
        return CaptureIntakeJournalReceipt(record: record, acknowledgedAfterDurableWrite: true)
    }

    func record(id: String) async throws -> CaptureIntakeJournalRecord? {
        try await loadRecords().first { $0.id == id }
    }

    func latestRecord(captureID: String) async throws -> CaptureIntakeJournalRecord? {
        try await loadRecords().last { $0.captureID == captureID }
    }

    func records() async throws -> [CaptureIntakeJournalRecord] {
        try await loadRecords()
    }

    private func validateAppend(_ record: CaptureIntakeJournalRecord, after previous: CaptureIntakeJournalRecord?) throws {
        let expected = (previous?.sequence ?? 0) + 1
        guard record.sequence == expected else {
            throw CaptureIntakeJournalError.nonAppendOnlySequence(expected: expected, actual: record.sequence)
        }
    }

    private func loadRecords() async throws -> [CaptureIntakeJournalRecord] {
        if let recordsCache {
            return recordsCache
        }
        let loaded = try await fileStore?.load() ?? []
        recordsCache = loaded.sorted { $0.sequence < $1.sequence }
        return recordsCache ?? []
    }

    private func persist(_ records: [CaptureIntakeJournalRecord]) async throws {
        recordsCache = records
        try await fileStore?.save(records)
    }
}
