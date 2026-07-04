import CryptoKit
import Foundation

enum CaptureAttachmentVaultError: Error, Equatable {
    case emptyPayload
    case missingDurableIntake(String)
    case missingAttachment(String)
}

enum CaptureAttachmentVaultState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case staged
    case quarantined
}

struct CaptureAttachmentVaultStageRequest: Sendable, Equatable {
    let captureID: String
    let intakeRecordID: String?
    let originalFilename: String
    let contentType: String
    let data: Data
    let privacy: EventLedgerPrivacyClassification
    let stagedAt: String

    init(
        captureID: String,
        intakeRecordID: String? = nil,
        originalFilename: String,
        contentType: String,
        data: Data,
        privacy: EventLedgerPrivacyClassification = .privateUserText,
        stagedAt: String
    ) {
        self.captureID = CaptureRoutingStableID.required(captureID)
        self.intakeRecordID = CaptureRoutingStableID.optional(intakeRecordID)
        self.originalFilename = CaptureRoutingStableID.required(originalFilename)
        self.contentType = CaptureRoutingStableID.required(contentType)
        self.data = data
        self.privacy = privacy
        self.stagedAt = CaptureRoutingStableID.required(stagedAt)
    }
}

struct CaptureAttachmentVaultRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let captureID: String
    let intakeRecordID: String?
    let originalFilename: String
    let storedFilename: String
    let contentType: String
    let byteCount: Int
    let sha256: String
    let state: CaptureAttachmentVaultState
    let quarantineReason: String?
    let privacy: EventLedgerPrivacyClassification
    let stagedAt: String
    let updatedAt: String
    let localOnly: Bool
    let checksum: String

    init(
        request: CaptureAttachmentVaultStageRequest,
        storedFilename: String,
        sha256: String,
        state: CaptureAttachmentVaultState = .staged,
        quarantineReason: String? = nil,
        updatedAt: String? = nil
    ) throws {
        guard request.data.isEmpty == false else {
            throw CaptureAttachmentVaultError.emptyPayload
        }
        captureID = request.captureID
        intakeRecordID = request.intakeRecordID
        originalFilename = request.originalFilename
        self.storedFilename = CaptureRoutingStableID.required(storedFilename)
        contentType = request.contentType
        byteCount = request.data.count
        self.sha256 = CaptureRoutingStableID.required(sha256)
        self.state = state
        self.quarantineReason = CaptureRoutingStableID.optional(quarantineReason)
        privacy = request.privacy
        stagedAt = request.stagedAt
        self.updatedAt = CaptureRoutingStableID.required(updatedAt ?? request.stagedAt)
        localOnly = true
        id = CaptureRoutingStableID.make(prefix: "capture-attachment", components: [captureID, self.sha256, originalFilename])
        checksum = CaptureRoutingStableID.checksum(
            prefix: "capture-attachment",
            components: [
                id,
                captureID,
                intakeRecordID ?? "",
                originalFilename,
                self.storedFilename,
                contentType,
                String(byteCount),
                self.sha256,
                state.rawValue,
                self.quarantineReason ?? "",
                privacy.rawValue,
                stagedAt,
                self.updatedAt,
                "local"
            ]
        )
    }

    private init(
        id: String,
        captureID: String,
        intakeRecordID: String?,
        originalFilename: String,
        storedFilename: String,
        contentType: String,
        byteCount: Int,
        sha256: String,
        state: CaptureAttachmentVaultState,
        quarantineReason: String?,
        privacy: EventLedgerPrivacyClassification,
        stagedAt: String,
        updatedAt: String,
        localOnly: Bool
    ) {
        self.id = id
        self.captureID = captureID
        self.intakeRecordID = intakeRecordID
        self.originalFilename = originalFilename
        self.storedFilename = storedFilename
        self.contentType = contentType
        self.byteCount = byteCount
        self.sha256 = sha256
        self.state = state
        self.quarantineReason = quarantineReason
        self.privacy = privacy
        self.stagedAt = stagedAt
        self.updatedAt = updatedAt
        self.localOnly = localOnly
        checksum = CaptureRoutingStableID.checksum(
            prefix: "capture-attachment",
            components: [
                id,
                captureID,
                intakeRecordID ?? "",
                originalFilename,
                storedFilename,
                contentType,
                String(byteCount),
                sha256,
                state.rawValue,
                quarantineReason ?? "",
                privacy.rawValue,
                stagedAt,
                updatedAt,
                localOnly ? "local" : "non-local"
            ]
        )
    }

    func quarantined(reason: String, updatedAt: String) -> CaptureAttachmentVaultRecord {
        CaptureAttachmentVaultRecord(
            id: id,
            captureID: captureID,
            intakeRecordID: intakeRecordID,
            originalFilename: originalFilename,
            storedFilename: storedFilename,
            contentType: contentType,
            byteCount: byteCount,
            sha256: sha256,
            state: .quarantined,
            quarantineReason: CaptureRoutingStableID.required(reason),
            privacy: privacy,
            stagedAt: stagedAt,
            updatedAt: CaptureRoutingStableID.required(updatedAt),
            localOnly: localOnly
        )
    }
}

actor CaptureAttachmentVault {
    private let rootDirectory: URL?
    private var recordsCache: [CaptureAttachmentVaultRecord]?
    private let fileStore: CaptureRoutingJSONFileStore<[CaptureAttachmentVaultRecord]>?

    init(rootDirectory: URL? = nil, indexFileURL: URL? = nil) {
        self.rootDirectory = rootDirectory
        fileStore = indexFileURL.map { CaptureRoutingJSONFileStore(fileURL: $0, emptyValue: []) }
    }

    static func fileBacked(rootDirectory: URL) -> CaptureAttachmentVault {
        let vaultDirectory = rootDirectory.appendingPathComponent("AttachmentVault", isDirectory: true)
        return CaptureAttachmentVault(
            rootDirectory: vaultDirectory,
            indexFileURL: CaptureRoutingJSONFileStore<[CaptureAttachmentVaultRecord]>.fileURL(
                rootDirectory: rootDirectory,
                fileName: "CaptureAttachmentVault.json"
            )
        )
    }

    @discardableResult
    func stage(_ request: CaptureAttachmentVaultStageRequest) async throws -> CaptureAttachmentVaultRecord {
        guard request.data.isEmpty == false else {
            throw CaptureAttachmentVaultError.emptyPayload
        }
        guard request.intakeRecordID != nil else {
            throw CaptureAttachmentVaultError.missingDurableIntake(request.captureID)
        }
        let sha256 = Self.sha256Hex(request.data)
        let storedFilename = "\(sha256)-\(Self.safeFilename(request.originalFilename))"
        if let rootDirectory {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: rootDirectory.path) == false {
                try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
            }
            let fileURL = rootDirectory.appendingPathComponent(storedFilename, isDirectory: false)
            try request.data.write(to: fileURL, options: [.atomic])
            CaptureRoutingLocalFileProtection.apply(to: fileURL)
        }
        var records = try await loadRecords()
        let record = try CaptureAttachmentVaultRecord(request: request, storedFilename: storedFilename, sha256: sha256)
        records.removeAll { $0.id == record.id }
        records.append(record)
        records.sort { $0.updatedAt < $1.updatedAt }
        try await persist(records)
        return record
    }

    @discardableResult
    func quarantine(id: String, reason: String, updatedAt: String) async throws -> CaptureAttachmentVaultRecord {
        var records = try await loadRecords()
        guard let index = records.firstIndex(where: { $0.id == id }) else {
            throw CaptureAttachmentVaultError.missingAttachment(id)
        }
        let record = records[index].quarantined(reason: reason, updatedAt: updatedAt)
        records[index] = record
        try await persist(records)
        return record
    }

    func record(id: String) async throws -> CaptureAttachmentVaultRecord? {
        try await loadRecords().first { $0.id == id }
    }

    func records(captureID: String? = nil) async throws -> [CaptureAttachmentVaultRecord] {
        let records = try await loadRecords()
        guard let captureID = CaptureRoutingStableID.optional(captureID) else {
            return records
        }
        return records.filter { $0.captureID == captureID }
    }

    static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private static func safeFilename(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        var output = ""
        for character in trimmed {
            if character.isLetter || character.isNumber || character == "." || character == "-" || character == "_" {
                output.append(character)
            } else if output.last != "-" {
                output.append("-")
            }
        }
        let sanitized = output.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return sanitized.isEmpty ? "attachment.bin" : sanitized
    }

    private func loadRecords() async throws -> [CaptureAttachmentVaultRecord] {
        if let recordsCache {
            return recordsCache
        }
        let loaded = try await fileStore?.load() ?? []
        recordsCache = loaded.sorted { $0.updatedAt < $1.updatedAt }
        return recordsCache ?? []
    }

    private func persist(_ records: [CaptureAttachmentVaultRecord]) async throws {
        recordsCache = records
        try await fileStore?.save(records)
    }
}
