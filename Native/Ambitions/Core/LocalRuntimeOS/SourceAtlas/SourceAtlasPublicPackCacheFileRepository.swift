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

struct SourceAtlasPublicPackCacheRepositoryIndex: Codable, Sendable, Equatable, Hashable {
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
    let fileManager: FileManager
    let encoder: JSONEncoder
    let decoder: JSONDecoder

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
