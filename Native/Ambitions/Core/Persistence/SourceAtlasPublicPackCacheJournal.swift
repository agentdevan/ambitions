import Foundation

enum SourceAtlasPublicPackCacheCommitStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case acceptedCurrent = "accepted_current"
    case verifiedReference = "verified_reference"
    case localFallback = "local_fallback"
    case quarantined
    case rejected
}

enum SourceAtlasPublicPackCacheArtifactKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case manifest
    case pack
}

enum SourceAtlasPublicPackCacheCommitIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsafeManifestRequest = "unsafe_manifest_request"
    case unsafePackRequest = "unsafe_pack_request"
    case missingObjectKey = "missing_object_key"
    case privateObjectKey = "private_object_key"
    case privateCacheMetadata = "private_cache_metadata"
    case privateEgressFinding = "private_egress_finding"
    case missingCacheResolution = "missing_cache_resolution"
    case noSelectedPack = "no_selected_pack"
    case downloadedPackHashMismatch = "downloaded_pack_hash_mismatch"
    case quarantinedFetch = "quarantined_fetch"
    case unavailableFetch = "unavailable_fetch"
}

struct SourceAtlasPublicPackCacheArtifactRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: SourceAtlasPublicPackCacheArtifactKind
    let objectKey: String?
    let packID: String
    let manifestVersionID: String?
    let sha256: String
    let byteCount: Int
    let selectedSource: SourceAtlasStorePayloadSource?
    let recordedAt: Date

    init(
        kind: SourceAtlasPublicPackCacheArtifactKind,
        objectKey: String?,
        packID: String,
        manifestVersionID: String?,
        data: Data,
        selectedSource: SourceAtlasStorePayloadSource?,
        recordedAt: Date
    ) {
        let normalizedPackID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedManifestVersionID = manifestVersionID?.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedObjectKey = objectKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.objectKey = normalizedObjectKey?.isEmpty == true ? nil : normalizedObjectKey
        self.packID = normalizedPackID
        self.manifestVersionID = normalizedManifestVersionID?.isEmpty == true ? nil : normalizedManifestVersionID
        self.sha256 = SourceAtlasStore.sha256Hex(for: data)
        self.byteCount = data.count
        self.selectedSource = selectedSource
        self.recordedAt = recordedAt
        self.id = [
            kind.rawValue,
            normalizedPackID,
            normalizedManifestVersionID ?? "none",
            self.sha256
        ].joined(separator: ":")
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .cacheMetadata,
            identifier: "source-atlas-cache-artifact-\(kind.rawValue)",
            inspectedValue: [
                "kind=\(kind.rawValue)",
                "object_key=\(objectKey ?? "none")",
                "pack_id=\(packID)",
                "manifest_version=\(manifestVersionID ?? "none")",
                "sha256=\(sha256)",
                "source=\(selectedSource?.rawValue ?? "none")",
            ].joined(separator: " ")
        )
    }
}

struct SourceAtlasPublicPackCacheQuarantineRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let source: SourceAtlasStorePayloadSource
    let reason: SourceAtlasStoreQuarantineReason
    let validationIssueCodes: [String]
    let recordedAt: Date

    init(
        quarantine: SourceAtlasStoreQuarantine,
        recordedAt: Date
    ) {
        self.source = quarantine.source
        self.reason = quarantine.reason
        self.validationIssueCodes = quarantine.validationIssues.map(\.rawValue).sorted()
        self.recordedAt = recordedAt
        self.id = "\(source.rawValue):\(reason.rawValue):\(validationIssueCodes.joined(separator: ","))"
    }
}

struct SourceAtlasPublicPackCacheJournalRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    static let requiredNonClaims = [
        "not a personalized plan",
        "not a final user schedule",
        "not a Step generator",
        "not private graph storage",
        "not production R2 readiness"
    ]

    let id: String
    let cacheNamespace: String
    let committedAt: Date
    let status: SourceAtlasPublicPackCacheCommitStatus
    let targetPackID: String
    let manifestVersionID: String?
    let selectedPackIDs: [String]
    let selectedSource: SourceAtlasStorePayloadSource?
    let selectedSourceState: SourceAtlasRequirementSourceState?
    let selectedFreshnessState: SourceAtlasRequirementFreshnessState?
    let fallbackTriggered: Bool
    let coreLocalPlanningBlocked: Bool
    let artifacts: [SourceAtlasPublicPackCacheArtifactRecord]
    let quarantines: [SourceAtlasPublicPackCacheQuarantineRecord]
    let issues: [SourceAtlasPublicPackCacheCommitIssue]
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]
    let nonClaims: [String]

    var canPersistCurrentPack: Bool {
        (status == .acceptedCurrent || status == .verifiedReference) &&
            issues.isEmpty &&
            egressFindings.isEmpty &&
            artifacts.contains { $0.kind == .pack }
    }
}

struct SourceAtlasPublicPackCacheJournalInput: Sendable, Equatable, Hashable {
    let manifestRequest: SourceAtlasPublicManifestRequest
    let targetPackID: String
    let objectRequests: [SourceAtlasPublicPackRemoteObjectRequest]
    let fetchResolution: SourceAtlasPublicPackFetchResolution
    let fetchedManifestData: Data?
    let downloadedPackData: Data?
    let committedAt: Date

    init(
        manifestRequest: SourceAtlasPublicManifestRequest,
        targetPackID: String,
        objectRequests: [SourceAtlasPublicPackRemoteObjectRequest] = [],
        fetchResolution: SourceAtlasPublicPackFetchResolution,
        fetchedManifestData: Data? = nil,
        downloadedPackData: Data? = nil,
        committedAt: Date
    ) {
        self.manifestRequest = manifestRequest
        self.targetPackID = targetPackID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.objectRequests = objectRequests
        self.fetchResolution = fetchResolution
        self.fetchedManifestData = fetchedManifestData
        self.downloadedPackData = downloadedPackData
        self.committedAt = committedAt
    }
}

struct SourceAtlasPublicPackCacheJournal: Sendable {
    func record(_ input: SourceAtlasPublicPackCacheJournalInput) -> SourceAtlasPublicPackCacheJournalRecord {
        let cacheResolution = input.fetchResolution.cacheResolution
        var issues = issueSet(input: input, cacheResolution: cacheResolution)
        var egressRecords = egressRecords(input: input, cacheResolution: cacheResolution)
        let artifactRecords = artifacts(input: input, cacheResolution: cacheResolution, issues: &issues)
        egressRecords.append(contentsOf: artifactRecords.map(\.egressRecord))

        let egressFindings = orderedFindings(
            SourceAtlasNoPrivateGraphEgressAudit.validate(egressRecords) +
                privateCacheMetadataFindings(in: egressRecords)
        )
        if egressFindings.isEmpty == false {
            issues.insert(.privateEgressFinding)
        }

        return SourceAtlasPublicPackCacheJournalRecord(
            id: journalID(input: input, cacheResolution: cacheResolution),
            cacheNamespace: SourceAtlasLocalStorageBoundaryProof.publicReferenceCacheNamespace,
            committedAt: input.committedAt,
            status: status(input: input, issues: issues, artifacts: artifactRecords),
            targetPackID: input.targetPackID,
            manifestVersionID: cacheResolution?.updateRecord.manifestVersionID ?? input.fetchResolution.packRequest?.manifestVersionID,
            selectedPackIDs: cacheResolution?.updateRecord.selectedPackIDs ?? [],
            selectedSource: cacheResolution?.loadResult.selectedSource,
            selectedSourceState: cacheResolution?.fallback.selectedSourceState,
            selectedFreshnessState: cacheResolution?.fallback.selectedFreshnessState,
            fallbackTriggered: cacheResolution?.updateRecord.fallbackTriggered ?? true,
            coreLocalPlanningBlocked: input.fetchResolution.coreLocalPlanningBlocked,
            artifacts: artifactRecords.sorted { $0.id < $1.id },
            quarantines: quarantineRecords(cacheResolution: cacheResolution, recordedAt: input.committedAt),
            issues: orderedIssues(Array(issues)),
            egressFindings: egressFindings,
            nonClaims: SourceAtlasPublicPackCacheJournalRecord.requiredNonClaims
        )
    }
}

private extension SourceAtlasPublicPackCacheJournal {
    func issueSet(
        input: SourceAtlasPublicPackCacheJournalInput,
        cacheResolution: SourceAtlasLocalPackCacheResolution?
    ) -> Set<SourceAtlasPublicPackCacheCommitIssue> {
        var issues: Set<SourceAtlasPublicPackCacheCommitIssue> = []
        if input.manifestRequest.validationIssues.isEmpty == false {
            issues.insert(.unsafeManifestRequest)
        }
        if privateCacheMetadataFindings(in: [input.manifestRequest.egressRecord]).isEmpty == false {
            issues.insert(.privateCacheMetadata)
        }
        if input.fetchResolution.packRequest?.validationIssues.isEmpty == false {
            issues.insert(.unsafePackRequest)
        }
        if let packRequest = input.fetchResolution.packRequest,
           privateCacheMetadataFindings(in: [packRequestEgressRecord(packRequest)]).isEmpty == false {
            issues.insert(.privateCacheMetadata)
        }
        for request in input.objectRequests {
            let requestIssues = request.validationIssues
            if requestIssues.contains(.missingObjectKey) {
                issues.insert(.missingObjectKey)
            }
            if requestIssues.contains(.privateObjectKey) {
                issues.insert(.privateObjectKey)
            }
            if privateCacheMetadataFindings(in: [request.egressRecord]).isEmpty == false {
                issues.insert(.privateObjectKey)
            }
        }
        if cacheResolution == nil {
            issues.insert(.missingCacheResolution)
        }
        if cacheResolution?.selectedPack == nil {
            issues.insert(.noSelectedPack)
        }
        if input.fetchResolution.status == .quarantined {
            issues.insert(.quarantinedFetch)
        }
        if input.fetchResolution.status == .unavailable {
            issues.insert(.unavailableFetch)
        }
        return issues
    }

    func artifacts(
        input: SourceAtlasPublicPackCacheJournalInput,
        cacheResolution: SourceAtlasLocalPackCacheResolution?,
        issues: inout Set<SourceAtlasPublicPackCacheCommitIssue>
    ) -> [SourceAtlasPublicPackCacheArtifactRecord] {
        guard privacyBlockingIssues(in: issues).isEmpty else {
            return []
        }

        var records: [SourceAtlasPublicPackCacheArtifactRecord] = []
        if let manifestData = input.fetchedManifestData {
            records.append(
                SourceAtlasPublicPackCacheArtifactRecord(
                    kind: .manifest,
                    objectKey: objectKey(for: .manifest, in: input.objectRequests),
                    packID: input.targetPackID,
                    manifestVersionID: cacheResolution?.updateRecord.manifestVersionID ?? input.fetchResolution.packRequest?.manifestVersionID,
                    data: manifestData,
                    selectedSource: nil,
                    recordedAt: input.committedAt
                )
            )
        }

        if let downloadedPackData = input.downloadedPackData {
            if let declaredSHA256 = input.fetchResolution.packRequest?.declaredSHA256,
               SourceAtlasStore.sha256Hex(for: downloadedPackData) == declaredSHA256.lowercased() {
                records.append(
                    SourceAtlasPublicPackCacheArtifactRecord(
                        kind: .pack,
                        objectKey: objectKey(for: .pack, in: input.objectRequests),
                        packID: input.targetPackID,
                        manifestVersionID: cacheResolution?.updateRecord.manifestVersionID ?? input.fetchResolution.packRequest?.manifestVersionID,
                        data: downloadedPackData,
                        selectedSource: cacheResolution?.loadResult.selectedSource,
                        recordedAt: input.committedAt
                    )
                )
            } else {
                issues.insert(.downloadedPackHashMismatch)
            }
        }
        return records
    }

    func status(
        input: SourceAtlasPublicPackCacheJournalInput,
        issues: Set<SourceAtlasPublicPackCacheCommitIssue>,
        artifacts: [SourceAtlasPublicPackCacheArtifactRecord]
    ) -> SourceAtlasPublicPackCacheCommitStatus {
        if privacyBlockingIssues(in: issues).isEmpty == false {
            return .rejected
        }
        switch input.fetchResolution.status {
        case .accepted:
            return artifacts.contains { $0.kind == .pack } ? .acceptedCurrent : .rejected
        case .usingLocalFallback:
            if verifiedDownloadedProductionReference(input: input, issues: issues, artifacts: artifacts) {
                return .verifiedReference
            }
            return .localFallback
        case .quarantined:
            return .quarantined
        case .unavailable:
            return .rejected
        }
    }

    func verifiedDownloadedProductionReference(
        input: SourceAtlasPublicPackCacheJournalInput,
        issues: Set<SourceAtlasPublicPackCacheCommitIssue>,
        artifacts: [SourceAtlasPublicPackCacheArtifactRecord]
    ) -> Bool {
        input.manifestRequest.channel == "stable" &&
            input.fetchResolution.fetchIssues.isEmpty &&
            issues.isEmpty &&
            input.fetchResolution.cacheResolution?.loadResult.selectedSource == .cached &&
            artifacts.contains { $0.kind == .pack } &&
            input.objectRequests.contains { request in
                request.kind == .pack &&
                    request.objectKey.contains("/production/stable/")
            }
    }

    func egressRecords(
        input: SourceAtlasPublicPackCacheJournalInput,
        cacheResolution: SourceAtlasLocalPackCacheResolution?
    ) -> [SourceAtlasNoPrivateGraphEgressRecord] {
        var records = [input.manifestRequest.egressRecord]
        records.append(contentsOf: input.objectRequests.map(\.egressRecord))
        if let packRequest = input.fetchResolution.packRequest {
            records.append(packRequestEgressRecord(packRequest))
        }
        if let cacheResolution {
            records.append(
                SourceAtlasPublicArtifactCacheMetadata.make(
                    packID: input.targetPackID,
                    resolution: cacheResolution
                ).egressRecord
            )
        }
        return records
    }

    func packRequestEgressRecord(_ request: SourceAtlasPublicPackRequest) -> SourceAtlasNoPrivateGraphEgressRecord {
        let serialized = request.queryItems
            .merging(
                [
                    "declared_sha256": request.declaredSHA256,
                    "manifest_version": request.manifestVersionID,
                    "pack_id": request.packID,
                    "route": request.routePath,
                ],
                uniquingKeysWith: { current, _ in current }
            )
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        return SourceAtlasNoPrivateGraphEgressRecord(
            surface: .requestShape,
            identifier: "source-atlas-cache-pack-request",
            inspectedValue: serialized
        )
    }

    func privateCacheMetadataFindings(
        in records: [SourceAtlasNoPrivateGraphEgressRecord]
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        let extraTokens = [
            "account_id",
            "device_id",
            "goal_id",
            "goal_text",
            "capture",
            "schedule",
            "calendar",
            "proof",
            "receipt",
            "private",
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

    func quarantineRecords(
        cacheResolution: SourceAtlasLocalPackCacheResolution?,
        recordedAt: Date
    ) -> [SourceAtlasPublicPackCacheQuarantineRecord] {
        (cacheResolution?.loadResult.quarantines ?? [])
            .map { SourceAtlasPublicPackCacheQuarantineRecord(quarantine: $0, recordedAt: recordedAt) }
            .sorted { $0.id < $1.id }
    }

    func objectKey(
        for kind: SourceAtlasPublicPackRemoteObjectKind,
        in requests: [SourceAtlasPublicPackRemoteObjectRequest]
    ) -> String? {
        requests.first { $0.kind == kind }?.objectKey
    }

    func journalID(
        input: SourceAtlasPublicPackCacheJournalInput,
        cacheResolution: SourceAtlasLocalPackCacheResolution?
    ) -> String {
        [
            "source-atlas-cache-journal",
            input.targetPackID,
            cacheResolution?.updateRecord.manifestVersionID ?? input.fetchResolution.packRequest?.manifestVersionID ?? "no-manifest",
            String(Int(input.committedAt.timeIntervalSince1970))
        ].joined(separator: ":")
    }

    func privacyBlockingIssues(
        in issues: Set<SourceAtlasPublicPackCacheCommitIssue>
    ) -> Set<SourceAtlasPublicPackCacheCommitIssue> {
        issues.intersection([
            .unsafeManifestRequest,
            .unsafePackRequest,
            .missingObjectKey,
            .privateObjectKey,
            .privateCacheMetadata,
            .privateEgressFinding,
        ])
    }

    func orderedIssues(
        _ issues: [SourceAtlasPublicPackCacheCommitIssue]
    ) -> [SourceAtlasPublicPackCacheCommitIssue] {
        SourceAtlasPublicPackCacheCommitIssue.allCases.filter { issues.contains($0) }
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
}
