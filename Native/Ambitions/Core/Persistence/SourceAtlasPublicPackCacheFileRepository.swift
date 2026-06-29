import Foundation

enum SourceAtlasPublicPackCacheRepositoryCommitStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case persistedCurrent = "persisted_current"
    case recordedOnly = "recorded_only"
    case rejected
}

enum SourceAtlasPublicPackCacheRepositoryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsafeJournalRecord = "unsafe_journal_record"
    case privateCacheMetadata = "private_cache_metadata"
    case missingPackArtifact = "missing_pack_artifact"
    case missingPackData = "missing_pack_data"
    case packDataHashMismatch = "pack_data_hash_mismatch"
    case missingManifestData = "missing_manifest_data"
    case manifestDataHashMismatch = "manifest_data_hash_mismatch"
    case readbackHashMismatch = "readback_hash_mismatch"
    case lookupRejected = "lookup_rejected"
}

enum SourceAtlasPublicPackCacheRepositoryError: Error, Sendable, Equatable {
    case writeFailed(String)
    case readFailed(String)
    case decodeFailed(String)
}

struct SourceAtlasPublicPackCacheRepositoryStoredArtifact: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: SourceAtlasPublicPackCacheArtifactKind
    let sha256: String
    let byteCount: Int
    let relativePath: String
    let readbackSHA256: String

    init(
        kind: SourceAtlasPublicPackCacheArtifactKind,
        sha256: String,
        byteCount: Int,
        relativePath: String,
        readbackSHA256: String
    ) {
        self.kind = kind
        self.sha256 = sha256.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.byteCount = byteCount
        self.relativePath = relativePath
        self.readbackSHA256 = readbackSHA256.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.id = "\(kind.rawValue):\(self.sha256)"
    }
}

struct SourceAtlasPublicPackCacheRepositoryCommitResult: Codable, Sendable, Equatable, Hashable {
    let status: SourceAtlasPublicPackCacheRepositoryCommitStatus
    let journalRelativePath: String?
    let packIndexRelativePath: String?
    let storedArtifacts: [SourceAtlasPublicPackCacheRepositoryStoredArtifact]
    let issues: [SourceAtlasPublicPackCacheRepositoryIssue]
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]
    let coreLocalPlanningBlocked: Bool

    var persistedPackPayload: Bool {
        status == .persistedCurrent &&
            storedArtifacts.contains { $0.kind == .pack } &&
            issues.isEmpty &&
            egressFindings.isEmpty
    }
}

struct SourceAtlasPublicPackCacheRepositoryCommitInput: Sendable, Equatable, Hashable {
    let journalRecord: SourceAtlasPublicPackCacheJournalRecord
    let manifestData: Data?
    let packData: Data?

    init(
        journalRecord: SourceAtlasPublicPackCacheJournalRecord,
        manifestData: Data? = nil,
        packData: Data? = nil
    ) {
        self.journalRecord = journalRecord
        self.manifestData = manifestData
        self.packData = packData
    }
}

struct SourceAtlasPublicPackCachePayloadLookup: Codable, Sendable, Equatable, Hashable {
    let packID: String
    let manifestVersionID: String
    let declaredSHA256: String

    init(
        packID: String,
        manifestVersionID: String,
        declaredSHA256: String
    ) {
        self.packID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.manifestVersionID = manifestVersionID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.declaredSHA256 = declaredSHA256.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .cacheMetadata,
            identifier: "source-atlas-cache-payload-lookup",
            inspectedValue: [
                "pack_id=\(packID)",
                "manifest_version=\(manifestVersionID)",
                "sha256=\(declaredSHA256)"
            ].joined(separator: " ")
        )
    }
}

struct SourceAtlasPublicPackCacheManifestLookup: Codable, Sendable, Equatable, Hashable {
    let packID: String
    let manifestVersionID: String
    let declaredPackSHA256: String

    init(
        packID: String,
        manifestVersionID: String,
        declaredPackSHA256: String
    ) {
        self.packID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.manifestVersionID = manifestVersionID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.declaredPackSHA256 = declaredPackSHA256.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .cacheMetadata,
            identifier: "source-atlas-cache-manifest-lookup",
            inspectedValue: [
                "pack_id=\(packID)",
                "manifest_version=\(manifestVersionID)",
                "pack_sha256=\(declaredPackSHA256)"
            ].joined(separator: " ")
        )
    }
}

private struct SourceAtlasPublicPackCacheRepositoryIndex: Codable, Sendable, Equatable, Hashable {
    let packID: String
    let manifestVersionID: String
    let declaredSHA256: String
    let packRelativePath: String
    let manifestRelativePath: String?
    let manifestSHA256: String?
    let committedAt: Date
}

struct SourceAtlasPublicPackCacheFileRepository: @unchecked Sendable {
    static let namespace = "source-atlas-public-pack-cache/v1"

    let rootDirectory: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        rootDirectory: URL,
        fileManager: FileManager = .default,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.rootDirectory = rootDirectory
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
        self.encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    }

    func commit(
        _ input: SourceAtlasPublicPackCacheRepositoryCommitInput
    ) throws -> SourceAtlasPublicPackCacheRepositoryCommitResult {
        let record = input.journalRecord
        var issues = issueSet(for: record)
        let egressFindings = orderedFindings(record.egressFindings + egressFindings(for: record))
        if egressFindings.isEmpty == false {
            issues.insert(.privateCacheMetadata)
        }

        if privacyBlockingIssues(in: issues).isEmpty == false {
            return SourceAtlasPublicPackCacheRepositoryCommitResult(
                status: .rejected,
                journalRelativePath: nil,
                packIndexRelativePath: nil,
                storedArtifacts: [],
                issues: orderedIssues(Array(issues)),
                egressFindings: egressFindings,
                coreLocalPlanningBlocked: record.coreLocalPlanningBlocked
            )
        }

        let journalPath = try writeJSON(
            record,
            relativePath: relativePath(directory: "journals", storageID: storageID(record.id), extension: "json")
        )

        var storedArtifacts: [SourceAtlasPublicPackCacheRepositoryStoredArtifact] = []
        var packIndexPath: String?
        if record.canPersistCurrentPack {
            let packArtifact = record.artifacts.first { $0.kind == .pack }
            guard let packArtifact else {
                issues.insert(.missingPackArtifact)
                return recordedOnlyResult(
                    journalPath: journalPath,
                    issues: issues,
                    egressFindings: egressFindings,
                    record: record
                )
            }
            guard let packData = input.packData else {
                issues.insert(.missingPackData)
                return recordedOnlyResult(
                    journalPath: journalPath,
                    issues: issues,
                    egressFindings: egressFindings,
                    record: record
                )
            }
            guard SourceAtlasStore.sha256Hex(for: packData) == packArtifact.sha256 else {
                issues.insert(.packDataHashMismatch)
                return recordedOnlyResult(
                    journalPath: journalPath,
                    issues: issues,
                    egressFindings: egressFindings,
                    record: record
                )
            }
            let packStoredArtifact = try writeArtifact(
                kind: .pack,
                data: packData,
                expectedSHA256: packArtifact.sha256
            )
            storedArtifacts.append(packStoredArtifact)

            var manifestStoredArtifact: SourceAtlasPublicPackCacheRepositoryStoredArtifact?
            if let manifestArtifact = record.artifacts.first(where: { $0.kind == .manifest }) {
                guard let manifestData = input.manifestData else {
                    issues.insert(.missingManifestData)
                    return recordedOnlyResult(
                        journalPath: journalPath,
                        storedArtifacts: storedArtifacts,
                        issues: issues,
                        egressFindings: egressFindings,
                        record: record
                    )
                }
                guard SourceAtlasStore.sha256Hex(for: manifestData) == manifestArtifact.sha256 else {
                    issues.insert(.manifestDataHashMismatch)
                    return recordedOnlyResult(
                        journalPath: journalPath,
                        storedArtifacts: storedArtifacts,
                        issues: issues,
                        egressFindings: egressFindings,
                        record: record
                    )
                }
                manifestStoredArtifact = try writeArtifact(
                    kind: .manifest,
                    data: manifestData,
                    expectedSHA256: manifestArtifact.sha256
                )
                if let manifestStoredArtifact {
                    storedArtifacts.append(manifestStoredArtifact)
                }
            }

            if issues.isEmpty {
                packIndexPath = try writeJSON(
                    SourceAtlasPublicPackCacheRepositoryIndex(
                        packID: record.targetPackID,
                        manifestVersionID: record.manifestVersionID ?? "",
                        declaredSHA256: packArtifact.sha256,
                        packRelativePath: packStoredArtifact.relativePath,
                        manifestRelativePath: manifestStoredArtifact?.relativePath,
                        manifestSHA256: manifestStoredArtifact?.sha256,
                        committedAt: record.committedAt
                    ),
                    relativePath: indexRelativePath(
                        packID: record.targetPackID,
                        manifestVersionID: record.manifestVersionID ?? "",
                        declaredSHA256: packArtifact.sha256
                    )
                )
            }
        }

        return SourceAtlasPublicPackCacheRepositoryCommitResult(
            status: storedArtifacts.contains { $0.kind == .pack } && issues.isEmpty ? .persistedCurrent : .recordedOnly,
            journalRelativePath: journalPath,
            packIndexRelativePath: packIndexPath,
            storedArtifacts: storedArtifacts.sorted { $0.id < $1.id },
            issues: orderedIssues(Array(issues)),
            egressFindings: egressFindings,
            coreLocalPlanningBlocked: record.coreLocalPlanningBlocked
        )
    }

    func loadPayload(
        _ lookup: SourceAtlasPublicPackCachePayloadLookup
    ) throws -> SourceAtlasStorePayload? {
        guard egressFindings(for: lookup).isEmpty else {
            return nil
        }
        guard Self.isSHA256Hex(lookup.declaredSHA256) else {
            return nil
        }
        let indexPath = absoluteURL(for: indexRelativePath(
            packID: lookup.packID,
            manifestVersionID: lookup.manifestVersionID,
            declaredSHA256: lookup.declaredSHA256
        ))
        guard fileManager.fileExists(atPath: indexPath.path) else {
            return nil
        }
        let indexData: Data
        do {
            indexData = try Data(contentsOf: indexPath)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.readFailed(indexPath.lastPathComponent)
        }
        let index: SourceAtlasPublicPackCacheRepositoryIndex
        do {
            index = try decoder.decode(SourceAtlasPublicPackCacheRepositoryIndex.self, from: indexData)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.decodeFailed(indexPath.lastPathComponent)
        }
        guard index.packID == lookup.packID,
              index.manifestVersionID == lookup.manifestVersionID,
              index.declaredSHA256 == lookup.declaredSHA256
        else {
            return nil
        }
        let payloadURL = absoluteURL(for: index.packRelativePath)
        guard fileManager.fileExists(atPath: payloadURL.path) else {
            return nil
        }
        let data: Data
        do {
            data = try Data(contentsOf: payloadURL)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.readFailed(payloadURL.lastPathComponent)
        }
        guard SourceAtlasStore.sha256Hex(for: data) == lookup.declaredSHA256 else {
            return nil
        }
        return SourceAtlasStorePayload(
            source: .cached,
            data: data,
            declaredSHA256: lookup.declaredSHA256
        )
    }

    func loadManifest(
        _ lookup: SourceAtlasPublicPackCacheManifestLookup
    ) throws -> SourceAtlasFreshnessManifest? {
        guard egressFindings(for: lookup).isEmpty else {
            return nil
        }
        guard Self.isSHA256Hex(lookup.declaredPackSHA256) else {
            return nil
        }
        guard let index = try loadIndex(
            packID: lookup.packID,
            manifestVersionID: lookup.manifestVersionID,
            declaredSHA256: lookup.declaredPackSHA256
        ) else {
            return nil
        }
        guard index.packID == lookup.packID,
              index.manifestVersionID == lookup.manifestVersionID,
              index.declaredSHA256 == lookup.declaredPackSHA256,
              let manifestRelativePath = index.manifestRelativePath,
              let manifestSHA256 = index.manifestSHA256,
              Self.isSHA256Hex(manifestSHA256)
        else {
            return nil
        }
        let manifestURL = absoluteURL(for: manifestRelativePath)
        guard fileManager.fileExists(atPath: manifestURL.path) else {
            return nil
        }
        let data: Data
        do {
            data = try Data(contentsOf: manifestURL)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.readFailed(manifestURL.lastPathComponent)
        }
        guard SourceAtlasStore.sha256Hex(for: data) == manifestSHA256 else {
            return nil
        }
        return try freshnessManifest(
            from: data,
            index: index,
            manifestSHA256: manifestSHA256
        )
    }

    func latestManifestLookup(
        packID: String
    ) throws -> SourceAtlasPublicPackCacheManifestLookup? {
        let trimmedPackID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedPackID.isEmpty == false else {
            return nil
        }
        let lookupRecord = SourceAtlasNoPrivateGraphEgressRecord(
            surface: .cacheMetadata,
            identifier: "source-atlas-cache-latest-manifest-lookup",
            inspectedValue: "pack_id=\(trimmedPackID)"
        )
        guard orderedFindings(
            SourceAtlasNoPrivateGraphEgressAudit.validate([lookupRecord]) +
                privateCacheMetadataFindings([lookupRecord])
        ).isEmpty else {
            return nil
        }

        let indexesURL = absoluteURL(for: "indexes")
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: indexesURL.path, isDirectory: &isDirectory),
              isDirectory.boolValue
        else {
            return nil
        }

        let indexFiles: [URL]
        do {
            indexFiles = try fileManager.contentsOfDirectory(
                at: indexesURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.readFailed("indexes")
        }

        var candidates: [(index: SourceAtlasPublicPackCacheRepositoryIndex, lookup: SourceAtlasPublicPackCacheManifestLookup)] = []
        for indexFile in indexFiles where indexFile.pathExtension == "json" {
            guard let index = try? decodedIndex(at: indexFile),
                  index.packID == trimmedPackID,
                  index.manifestRelativePath != nil,
                  Self.isSHA256Hex(index.declaredSHA256)
            else {
                continue
            }
            let lookup = SourceAtlasPublicPackCacheManifestLookup(
                packID: index.packID,
                manifestVersionID: index.manifestVersionID,
                declaredPackSHA256: index.declaredSHA256
            )
            guard egressFindings(for: lookup).isEmpty,
                  try loadManifest(lookup) != nil
            else {
                continue
            }
            candidates.append((index, lookup))
        }

        return candidates.sorted { lhs, rhs in
            if lhs.index.committedAt != rhs.index.committedAt {
                return lhs.index.committedAt > rhs.index.committedAt
            }
            if lhs.index.manifestVersionID != rhs.index.manifestVersionID {
                return lhs.index.manifestVersionID > rhs.index.manifestVersionID
            }
            return lhs.index.declaredSHA256 < rhs.index.declaredSHA256
        }.first?.lookup
    }
}

private extension SourceAtlasPublicPackCacheFileRepository {
    func decodedIndex(at url: URL) throws -> SourceAtlasPublicPackCacheRepositoryIndex {
        let indexData: Data
        do {
            indexData = try Data(contentsOf: url)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.readFailed(url.lastPathComponent)
        }
        do {
            return try decoder.decode(SourceAtlasPublicPackCacheRepositoryIndex.self, from: indexData)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.decodeFailed(url.lastPathComponent)
        }
    }

    func loadIndex(
        packID: String,
        manifestVersionID: String,
        declaredSHA256: String
    ) throws -> SourceAtlasPublicPackCacheRepositoryIndex? {
        let indexPath = absoluteURL(for: indexRelativePath(
            packID: packID,
            manifestVersionID: manifestVersionID,
            declaredSHA256: declaredSHA256
        ))
        guard fileManager.fileExists(atPath: indexPath.path) else {
            return nil
        }
        let indexData: Data
        do {
            indexData = try Data(contentsOf: indexPath)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.readFailed(indexPath.lastPathComponent)
        }
        do {
            return try decoder.decode(SourceAtlasPublicPackCacheRepositoryIndex.self, from: indexData)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.decodeFailed(indexPath.lastPathComponent)
        }
    }

    func freshnessManifest(
        from data: Data,
        index: SourceAtlasPublicPackCacheRepositoryIndex,
        manifestSHA256: String
    ) throws -> SourceAtlasFreshnessManifest? {
        if let manifest = try? decoder.decode(SourceAtlasFreshnessManifest.self, from: data) {
            return manifest
        }
        let pointer = SourceAtlasPublishedCurrentPointer(
            schemaVersion: 1,
            kind: "ambitions.sourceAtlas.currentPackPointer.v1",
            createdAt: ISO8601DateFormatter().string(from: index.committedAt),
            environment: "cached",
            channel: "cached",
            packID: index.packID,
            packVersion: index.manifestVersionID,
            manifestKey: index.manifestVersionID,
            manifestSHA256: manifestSHA256,
            packSHA256: index.declaredSHA256,
            revocationManifestKey: nil,
            lastKnownGoodKey: nil,
            publicReferenceOnly: true,
            dataClass: "public_freshness",
            privacyBoundary: "public/reference/freshness only",
            nonClaims: [
                "not a final user plan, schedule, or Step generator"
            ]
        )
        return try SourceAtlasPublishedPackManifestBridge(decoder: decoder)
            .freshnessManifest(from: data, pointer: pointer)
    }

    func recordedOnlyResult(
        journalPath: String,
        storedArtifacts: [SourceAtlasPublicPackCacheRepositoryStoredArtifact] = [],
        issues: Set<SourceAtlasPublicPackCacheRepositoryIssue>,
        egressFindings: [SourceAtlasNoPrivateGraphEgressFinding],
        record: SourceAtlasPublicPackCacheJournalRecord
    ) -> SourceAtlasPublicPackCacheRepositoryCommitResult {
        SourceAtlasPublicPackCacheRepositoryCommitResult(
            status: .recordedOnly,
            journalRelativePath: journalPath,
            packIndexRelativePath: nil,
            storedArtifacts: storedArtifacts.sorted { $0.id < $1.id },
            issues: orderedIssues(Array(issues)),
            egressFindings: egressFindings,
            coreLocalPlanningBlocked: record.coreLocalPlanningBlocked
        )
    }

    func issueSet(
        for record: SourceAtlasPublicPackCacheJournalRecord
    ) -> Set<SourceAtlasPublicPackCacheRepositoryIssue> {
        var issues: Set<SourceAtlasPublicPackCacheRepositoryIssue> = []
        if record.egressFindings.isEmpty == false ||
            record.issues.contains(where: privacyBlockingJournalIssue(_:)) {
            issues.insert(.unsafeJournalRecord)
        }
        return issues
    }

    func privacyBlockingJournalIssue(
        _ issue: SourceAtlasPublicPackCacheCommitIssue
    ) -> Bool {
        switch issue {
        case .unsafeManifestRequest, .unsafePackRequest, .missingObjectKey,
             .privateObjectKey, .privateCacheMetadata, .privateEgressFinding:
            return true
        case .missingCacheResolution, .noSelectedPack, .downloadedPackHashMismatch,
             .quarantinedFetch, .unavailableFetch:
            return false
        }
    }

    func writeArtifact(
        kind: SourceAtlasPublicPackCacheArtifactKind,
        data: Data,
        expectedSHA256: String
    ) throws -> SourceAtlasPublicPackCacheRepositoryStoredArtifact {
        let relative = relativePath(directory: kind == .pack ? "packs" : "manifests", storageID: expectedSHA256, extension: "json")
        let absolute = absoluteURL(for: relative)
        do {
            try fileManager.createDirectory(at: absolute.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: absolute, options: .atomic)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.writeFailed(absolute.lastPathComponent)
        }

        let readback: Data
        do {
            readback = try Data(contentsOf: absolute)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.readFailed(absolute.lastPathComponent)
        }
        let readbackSHA256 = SourceAtlasStore.sha256Hex(for: readback)
        guard readbackSHA256 == expectedSHA256 else {
            throw SourceAtlasPublicPackCacheRepositoryError.writeFailed(SourceAtlasPublicPackCacheRepositoryIssue.readbackHashMismatch.rawValue)
        }

        return SourceAtlasPublicPackCacheRepositoryStoredArtifact(
            kind: kind,
            sha256: expectedSHA256,
            byteCount: data.count,
            relativePath: relative,
            readbackSHA256: readbackSHA256
        )
    }

    func writeJSON<T: Encodable>(
        _ value: T,
        relativePath: String
    ) throws -> String {
        let data: Data
        do {
            data = try encoder.encode(value)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.writeFailed(relativePath)
        }
        let absolute = absoluteURL(for: relativePath)
        do {
            try fileManager.createDirectory(at: absolute.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: absolute, options: .atomic)
        } catch {
            throw SourceAtlasPublicPackCacheRepositoryError.writeFailed(absolute.lastPathComponent)
        }
        return relativePath
    }

    func absoluteURL(for relativePath: String) -> URL {
        rootDirectory
            .appendingPathComponent(Self.namespace, isDirectory: true)
            .appendingPathComponent(relativePath, isDirectory: false)
    }

    func relativePath(
        directory: String,
        storageID: String,
        extension pathExtension: String
    ) -> String {
        "\(directory)/\(storageID).\(pathExtension)"
    }

    func indexRelativePath(
        packID: String,
        manifestVersionID: String,
        declaredSHA256: String
    ) -> String {
        relativePath(
            directory: "indexes",
            storageID: storageID("\(packID)|\(manifestVersionID)|\(declaredSHA256.lowercased())"),
            extension: "json"
        )
    }

    func storageID(_ value: String) -> String {
        SourceAtlasStore.sha256Hex(for: Data(value.utf8))
    }

    func egressFindings(
        for record: SourceAtlasPublicPackCacheJournalRecord
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        orderedFindings(
            SourceAtlasNoPrivateGraphEgressAudit.validate(record.artifacts.map(\.egressRecord)) +
                privateCacheMetadataFindings(record.artifacts.map(\.egressRecord))
        )
    }

    func egressFindings(
        for lookup: SourceAtlasPublicPackCachePayloadLookup
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        orderedFindings(
            SourceAtlasNoPrivateGraphEgressAudit.validate([lookup.egressRecord]) +
                privateCacheMetadataFindings([lookup.egressRecord])
        )
    }

    func egressFindings(
        for lookup: SourceAtlasPublicPackCacheManifestLookup
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        orderedFindings(
            SourceAtlasNoPrivateGraphEgressAudit.validate([lookup.egressRecord]) +
                privateCacheMetadataFindings([lookup.egressRecord])
        )
    }

    func privateCacheMetadataFindings(
        _ records: [SourceAtlasNoPrivateGraphEgressRecord]
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        let extraTokens = [
            "account_id",
            "device_id",
            "goal_id",
            "goal_text",
            "capture_text",
            "schedule",
            "calendar",
            "proof_payload",
            "receipt_payload",
            "private_context",
            "private_user_context",
            "life_graph",
        ]
        return records.flatMap { record in
            let normalized = SourceAtlasNoPrivateGraphEgressAudit.normalize(record.inspectedValue)
            return extraTokens.compactMap { token in
                normalized.contains(token)
                    ? SourceAtlasNoPrivateGraphEgressFinding(
                        surface: record.surface,
                        identifier: record.identifier,
                        forbiddenToken: token
                    )
                    : nil
            }
        }
    }

    func privacyBlockingIssues(
        in issues: Set<SourceAtlasPublicPackCacheRepositoryIssue>
    ) -> Set<SourceAtlasPublicPackCacheRepositoryIssue> {
        issues.intersection([
            .unsafeJournalRecord,
            .privateCacheMetadata,
            .lookupRejected,
        ])
    }

    func orderedIssues(
        _ issues: [SourceAtlasPublicPackCacheRepositoryIssue]
    ) -> [SourceAtlasPublicPackCacheRepositoryIssue] {
        SourceAtlasPublicPackCacheRepositoryIssue.allCases.filter { issues.contains($0) }
    }

    func orderedFindings(
        _ findings: [SourceAtlasNoPrivateGraphEgressFinding]
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        var seen: Set<SourceAtlasNoPrivateGraphEgressFinding> = []
        return findings.filter { seen.insert($0).inserted }
            .sorted {
                if $0.identifier != $1.identifier {
                    return $0.identifier < $1.identifier
                }
                return $0.forbiddenToken < $1.forbiddenToken
            }
    }

    static func isSHA256Hex(_ value: String) -> Bool {
        value.count == 64 && value.allSatisfy { character in
            character.isNumber || ("a"..."f").contains(character)
        }
    }
}
