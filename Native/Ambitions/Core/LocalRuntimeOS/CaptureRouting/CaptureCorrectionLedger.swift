import Foundation

struct CaptureCorrectionLedgerRequest: Sendable, Equatable {
    let captureID: String
    let previousRoute: CaptureRoute
    let correctedRoute: CaptureRoute
    let previousKind: CaptureKind
    let correctedKind: CaptureKind
    let reason: String
    let occurredAt: String
    let intakeRecordID: String?
    let decisionID: String?
    let privacy: EventLedgerPrivacyClassification

    init(
        captureID: String,
        previousRoute: CaptureRoute,
        correctedRoute: CaptureRoute,
        previousKind: CaptureKind,
        correctedKind: CaptureKind,
        reason: String,
        occurredAt: String,
        intakeRecordID: String? = nil,
        decisionID: String? = nil,
        privacy: EventLedgerPrivacyClassification = .privateUserText
    ) {
        self.captureID = CaptureRoutingStableID.required(captureID)
        self.previousRoute = previousRoute
        self.correctedRoute = correctedRoute
        self.previousKind = previousKind
        self.correctedKind = correctedKind
        self.reason = CaptureRoutingStableID.required(reason)
        self.occurredAt = CaptureRoutingStableID.required(occurredAt)
        self.intakeRecordID = CaptureRoutingStableID.optional(intakeRecordID)
        self.decisionID = CaptureRoutingStableID.optional(decisionID)
        self.privacy = privacy
    }
}

struct CaptureCorrectionLedgerRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sequence: Int
    let captureID: String
    let previousRoute: CaptureRoute
    let correctedRoute: CaptureRoute
    let previousKind: CaptureKind
    let correctedKind: CaptureKind
    let reason: String
    let occurredAt: String
    let intakeRecordID: String?
    let decisionID: String?
    let privacy: EventLedgerPrivacyClassification
    let runtimeTrace: CaptureRoutingRuntimeTrace
    let checksum: String

    init(sequence: Int, request: CaptureCorrectionLedgerRequest) {
        self.sequence = sequence
        captureID = request.captureID
        previousRoute = request.previousRoute
        correctedRoute = request.correctedRoute
        previousKind = request.previousKind
        correctedKind = request.correctedKind
        reason = request.reason
        occurredAt = request.occurredAt
        intakeRecordID = request.intakeRecordID
        decisionID = request.decisionID
        privacy = request.privacy
        id = CaptureRoutingStableID.make(
            prefix: "capture-correction",
            components: [captureID, String(sequence), previousRoute.rawValue, correctedRoute.rawValue, occurredAt]
        )
        runtimeTrace = CaptureRoutingRuntimeTrace.make(owner: "CaptureCorrectionLedger", sourceID: id)
        checksum = CaptureRoutingStableID.checksum(
            prefix: "capture-correction",
            components: [
                id,
                String(sequence),
                captureID,
                previousRoute.rawValue,
                correctedRoute.rawValue,
                previousKind.rawValue,
                correctedKind.rawValue,
                reason,
                occurredAt,
                intakeRecordID ?? "",
                decisionID ?? "",
                privacy.rawValue,
                runtimeTrace.checksum
            ]
        )
    }
}

actor CaptureCorrectionLedger {
    private var recordsCache: [CaptureCorrectionLedgerRecord]?
    private let fileStore: CaptureRoutingJSONFileStore<[CaptureCorrectionLedgerRecord]>?

    init(fileURL: URL? = nil) {
        fileStore = fileURL.map { CaptureRoutingJSONFileStore(fileURL: $0, emptyValue: []) }
    }

    static func fileBacked(rootDirectory: URL) -> CaptureCorrectionLedger {
        CaptureCorrectionLedger(
            fileURL: CaptureRoutingJSONFileStore<[CaptureCorrectionLedgerRecord]>.fileURL(
                rootDirectory: rootDirectory,
                fileName: "CaptureCorrectionLedger.json"
            )
        )
    }

    @discardableResult
    func append(_ request: CaptureCorrectionLedgerRequest) async throws -> CaptureCorrectionLedgerRecord {
        var records = try await loadRecords()
        let record = CaptureCorrectionLedgerRecord(sequence: records.count + 1, request: request)
        records.append(record)
        try await persist(records)
        return record
    }

    func records(captureID: String? = nil) async throws -> [CaptureCorrectionLedgerRecord] {
        let records = try await loadRecords()
        guard let captureID = CaptureRoutingStableID.optional(captureID) else {
            return records
        }
        return records.filter { $0.captureID == captureID }
    }

    private func loadRecords() async throws -> [CaptureCorrectionLedgerRecord] {
        if let recordsCache {
            return recordsCache
        }
        let loaded = try await fileStore?.load() ?? []
        recordsCache = loaded.sorted { $0.sequence < $1.sequence }
        return recordsCache ?? []
    }

    private func persist(_ records: [CaptureCorrectionLedgerRecord]) async throws {
        recordsCache = records
        try await fileStore?.save(records)
    }
}
