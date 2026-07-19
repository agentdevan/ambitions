import Foundation

struct CaptureDraftRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let intakeRecordID: String
    let captureID: String
    let rawText: String
    let proposedKind: CaptureKind
    let proposedRoute: CaptureRoute
    let triageStatus: CaptureTriageStatus
    let sourceSurface: String
    let attachmentIDs: [String]
    let privacy: EventLedgerPrivacyClassification
    let createdAt: String
    let updatedAt: String
    let checksum: String

    init(
        intake: CaptureIntakeJournalRecord,
        decision: CaptureRouteDecision,
        updatedAt: String
    ) {
        intakeRecordID = intake.id
        captureID = intake.captureID
        rawText = intake.rawText
        proposedKind = decision.kind
        proposedRoute = decision.route
        triageStatus = decision.triageStatus
        sourceSurface = intake.sourceSurface
        attachmentIDs = intake.attachmentIDs
        privacy = intake.privacy
        createdAt = intake.receivedAt
        self.updatedAt = CaptureRoutingStableID.required(updatedAt)
        id = CaptureRoutingStableID.make(prefix: "capture-draft", components: [intake.id, decision.id])
        checksum = CaptureRoutingStableID.checksum(
            prefix: "capture-draft",
            components: [
                id,
                intakeRecordID,
                captureID,
                rawText,
                proposedKind.rawValue,
                proposedRoute.rawValue,
                triageStatus.rawValue,
                sourceSurface,
                attachmentIDs.joined(separator: ","),
                privacy.rawValue,
                createdAt,
                self.updatedAt
            ]
        )
    }
}

actor CaptureDraftStore {
    private var recordsCache: [CaptureDraftRecord]?
    private let fileStore: CaptureRoutingJSONFileStore<[CaptureDraftRecord]>?

    init(fileURL: URL? = nil) {
        fileStore = fileURL.map { CaptureRoutingJSONFileStore(fileURL: $0, emptyValue: []) }
    }

    static func fileBacked(rootDirectory: URL) -> CaptureDraftStore {
        CaptureDraftStore(
            fileURL: CaptureRoutingJSONFileStore<[CaptureDraftRecord]>.fileURL(
                rootDirectory: rootDirectory,
                fileName: "CaptureDraftStore.json"
            )
        )
    }

    @discardableResult
    func upsert(
        intake: CaptureIntakeJournalRecord,
        decision: CaptureRouteDecision,
        updatedAt: String
    ) async throws -> CaptureDraftRecord {
        var records = try await loadRecords()
        let record = CaptureDraftRecord(intake: intake, decision: decision, updatedAt: updatedAt)
        records.removeAll { $0.captureID == record.captureID || $0.id == record.id }
        records.append(record)
        records.sort { $0.updatedAt < $1.updatedAt }
        try await persist(records)
        return record
    }

    func record(id: String) async throws -> CaptureDraftRecord? {
        try await loadRecords().first { $0.id == id }
    }

    func latestDraft(captureID: String) async throws -> CaptureDraftRecord? {
        try await loadRecords().last { $0.captureID == captureID }
    }

    func records() async throws -> [CaptureDraftRecord] {
        try await loadRecords()
    }

    private func loadRecords() async throws -> [CaptureDraftRecord] {
        if let recordsCache {
            return recordsCache
        }
        let loaded = try await fileStore?.load() ?? []
        recordsCache = loaded.sorted { $0.updatedAt < $1.updatedAt }
        return recordsCache ?? []
    }

    private func persist(_ records: [CaptureDraftRecord]) async throws {
        recordsCache = records
        try await fileStore?.save(records)
    }
}
