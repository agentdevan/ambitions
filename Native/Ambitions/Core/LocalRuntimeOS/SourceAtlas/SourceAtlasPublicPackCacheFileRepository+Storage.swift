import Foundation

extension SourceAtlasPublicPackCacheFileRepository {
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
        return try SourceAtlasPublishedPackSchemaDecoder(decoder: decoder)
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
