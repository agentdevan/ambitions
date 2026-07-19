import Foundation

enum SourceAtlasPublicManifestRequestIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingDomainID = "missing_domain_id"
    case missingChannel = "missing_channel"
    case missingSchemaVersion = "missing_schema_version"
    case missingAppVersion = "missing_app_version"
    case privateEgressMarker = "private_egress_marker"
}

struct SourceAtlasPublicManifestRequest: Codable, Sendable, Equatable, Hashable {
    let domainID: String
    let channel: String
    let schemaVersion: String
    let appVersion: String
    let routePath: String
    let publicLocale: String?

    init(
        domainID: String,
        channel: String,
        schemaVersion: String,
        appVersion: String,
        routePath: String = "/source-atlas/public/manifests",
        publicLocale: String? = nil
    ) {
        self.domainID = Self.trimmed(domainID)
        self.channel = Self.trimmed(channel)
        self.schemaVersion = Self.trimmed(schemaVersion)
        self.appVersion = Self.trimmed(appVersion)
        self.routePath = Self.trimmed(routePath)
        self.publicLocale = Self.trimmedOptional(publicLocale)
    }

    var queryItems: [String: String] {
        var values = [
            "app_version": appVersion,
            "channel": channel,
            "domain_id": domainID,
            "schema_version": schemaVersion,
        ]
        if let publicLocale {
            values["locale"] = publicLocale
        }
        return values
    }

    var validationIssues: [SourceAtlasPublicManifestRequestIssue] {
        SourceAtlasPublicManifestRequestValidator().validate(self)
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        let serialized = queryItems
            .merging(["route": routePath], uniquingKeysWith: { current, _ in current })
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        return SourceAtlasNoPrivateGraphEgressRecord(
            surface: .requestShape,
            identifier: "source-atlas-manifest-request",
            inspectedValue: serialized
        )
    }

    private static func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func trimmedOptional(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        let trimmed = trimmed(value)
        return trimmed.isEmpty ? nil : trimmed
    }
}

struct SourceAtlasPublicManifestRequestValidator: Sendable, Equatable, Hashable {
    func validate(_ request: SourceAtlasPublicManifestRequest) -> [SourceAtlasPublicManifestRequestIssue] {
        var issues: Set<SourceAtlasPublicManifestRequestIssue> = []

        if request.domainID.isEmpty {
            issues.insert(.missingDomainID)
        }
        if request.channel.isEmpty {
            issues.insert(.missingChannel)
        }
        if request.schemaVersion.isEmpty {
            issues.insert(.missingSchemaVersion)
        }
        if request.appVersion.isEmpty {
            issues.insert(.missingAppVersion)
        }
        if SourceAtlasNoPrivateGraphEgressAudit.validate([request.egressRecord]).isEmpty == false {
            issues.insert(.privateEgressMarker)
        }

        return SourceAtlasPublicManifestRequestIssue.allCases.filter { issues.contains($0) }
    }
}

enum SourceAtlasPublicPackFetchIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsafeManifestRequest = "unsafe_manifest_request"
    case currentPointerDecodeFailed = "current_pointer_decode_failed"
    case unsafeCurrentPointer = "unsafe_current_pointer"
    case manifestUnavailable = "manifest_unavailable"
    case manifestDecodeFailed = "manifest_decode_failed"
    case manifestHashMismatch = "manifest_hash_mismatch"
    case revocationManifestInvalid = "revocation_manifest_invalid"
    case lastKnownGoodInvalid = "last_known_good_invalid"
    case unsupportedManifestSchema = "unsupported_manifest_schema"
    case missingManifestEntry = "missing_manifest_entry"
    case packDownloadUnavailable = "pack_download_unavailable"
    case unsafePackRequest = "unsafe_pack_request"
    case accessBoundaryUnavailable = "access_boundary_unavailable"
    case noEligiblePack = "no_eligible_pack"
    case privateEgressFinding = "private_egress_finding"
}

enum SourceAtlasPublicPackFetchStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case accepted
    case usingLocalFallback = "using_local_fallback"
    case quarantined
    case unavailable
}

struct SourceAtlasPublicPackFetchInput: Sendable, Equatable, Hashable {
    let manifestRequest: SourceAtlasPublicManifestRequest
    let targetPackID: String
    let fetchedCurrentPointerData: Data?
    let fetchedManifestData: Data?
    let fetchedRevocationManifestData: Data?
    let fetchedLastKnownGoodPointerData: Data?
    let fetchedLastKnownGoodManifestData: Data?
    let cachedManifest: SourceAtlasFreshnessManifest?
    let downloadedPackData: Data?
    let cachedPayload: SourceAtlasStorePayload?
    let bundledPayload: SourceAtlasStorePayload?
    let lastKnownGoodPayload: SourceAtlasStorePayload?
    let accessDecision: SourceAtlasAccessDecision
    let query: SourceAtlasQuery
    let checkedAt: Date
    let policy: SourceAtlasLocalPackCachePolicy

    init(
        manifestRequest: SourceAtlasPublicManifestRequest,
        targetPackID: String,
        fetchedCurrentPointerData: Data? = nil,
        fetchedManifestData: Data? = nil,
        fetchedRevocationManifestData: Data? = nil,
        fetchedLastKnownGoodPointerData: Data? = nil,
        fetchedLastKnownGoodManifestData: Data? = nil,
        cachedManifest: SourceAtlasFreshnessManifest? = nil,
        downloadedPackData: Data? = nil,
        cachedPayload: SourceAtlasStorePayload? = nil,
        bundledPayload: SourceAtlasStorePayload? = nil,
        lastKnownGoodPayload: SourceAtlasStorePayload? = nil,
        accessDecision: SourceAtlasAccessDecision,
        query: SourceAtlasQuery = SourceAtlasQuery(),
        checkedAt: Date,
        policy: SourceAtlasLocalPackCachePolicy = SourceAtlasLocalPackCachePolicy()
    ) {
        self.manifestRequest = manifestRequest
        self.targetPackID = targetPackID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fetchedCurrentPointerData = fetchedCurrentPointerData
        self.fetchedManifestData = fetchedManifestData
        self.fetchedRevocationManifestData = fetchedRevocationManifestData
        self.fetchedLastKnownGoodPointerData = fetchedLastKnownGoodPointerData
        self.fetchedLastKnownGoodManifestData = fetchedLastKnownGoodManifestData
        self.cachedManifest = cachedManifest
        self.downloadedPackData = downloadedPackData
        self.cachedPayload = cachedPayload
        self.bundledPayload = bundledPayload
        self.lastKnownGoodPayload = lastKnownGoodPayload
        self.accessDecision = accessDecision
        self.query = query
        self.checkedAt = checkedAt
        self.policy = policy
    }
}

struct SourceAtlasPublicPackFetchResolution: Sendable, Equatable, Hashable {
    let status: SourceAtlasPublicPackFetchStatus
    let fetchIssues: [SourceAtlasPublicPackFetchIssue]
    let manifestRequestIssues: [SourceAtlasPublicManifestRequestIssue]
    let packRequest: SourceAtlasPublicPackRequest?
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]
    let cacheResolution: SourceAtlasLocalPackCacheResolution?

    var selectedPack: SourceAtlasPack? {
        cacheResolution?.selectedPack
    }

    var coreLocalPlanningBlocked: Bool {
        false
    }
}

struct SourceAtlasPublicPackFetchPipeline {
    private let decoder: JSONDecoder
    private let cache: SourceAtlasLocalPackCache

    init(
        decoder: JSONDecoder = JSONDecoder(),
        cache: SourceAtlasLocalPackCache = SourceAtlasLocalPackCache()
    ) {
        self.decoder = decoder
        self.cache = cache
    }

    func resolve(_ input: SourceAtlasPublicPackFetchInput) -> SourceAtlasPublicPackFetchResolution {
        let manifestRequestIssues = SourceAtlasPublicManifestRequestValidator().validate(input.manifestRequest)
        var fetchIssues: [SourceAtlasPublicPackFetchIssue] = []
        var egressRecords = [input.manifestRequest.egressRecord]

        if manifestRequestIssues.isEmpty == false {
            fetchIssues.append(.unsafeManifestRequest)
        }

        let currentPointerResult = resolvedCurrentPointer(from: input.fetchedCurrentPointerData)
        fetchIssues.append(contentsOf: currentPointerResult.issues)
        egressRecords.append(contentsOf: currentPointerResult.pointer?.objectKeyEgressRecords ?? [])

        let manifestResult = resolvedManifest(from: input, currentPointer: currentPointerResult.pointer)
        fetchIssues.append(contentsOf: manifestResult.issues)

        guard manifestRequestIssues.isEmpty, let manifest = manifestResult.manifest else {
            let findings = SourceAtlasNoPrivateGraphEgressAudit.validate(egressRecords)
            if findings.isEmpty == false {
                fetchIssues.append(.privateEgressFinding)
            }
            return SourceAtlasPublicPackFetchResolution(
                status: earlyUnavailableStatus(fetchIssues),
                fetchIssues: orderedIssues(fetchIssues),
                manifestRequestIssues: manifestRequestIssues,
                packRequest: nil,
                egressFindings: findings,
                cacheResolution: nil
            )
        }

        guard manifest.schemaVersion == 1 else {
            fetchIssues.append(.unsupportedManifestSchema)
            let findings = SourceAtlasNoPrivateGraphEgressAudit.validate(egressRecords)
            return SourceAtlasPublicPackFetchResolution(
                status: .quarantined,
                fetchIssues: orderedIssues(fetchIssues),
                manifestRequestIssues: manifestRequestIssues,
                packRequest: nil,
                egressFindings: findings,
                cacheResolution: nil
            )
        }

        guard let entry = manifest.packIndex.first(where: { $0.packID == input.targetPackID }) else {
            fetchIssues.append(.missingManifestEntry)
            let findings = SourceAtlasNoPrivateGraphEgressAudit.validate(egressRecords)
            return SourceAtlasPublicPackFetchResolution(
                status: .unavailable,
                fetchIssues: orderedIssues(fetchIssues),
                manifestRequestIssues: manifestRequestIssues,
                packRequest: nil,
                egressFindings: findings,
                cacheResolution: nil
            )
        }

        let packRequest = SourceAtlasPublicPackRequest.publicPack(
            manifestVersionID: manifest.versionID,
            entry: entry
        )
        egressRecords.append(packRequestEgressRecord(packRequest))

        if packRequest.validationIssues.isEmpty == false {
            fetchIssues.append(.unsafePackRequest)
        }
        if input.accessDecision.route == .unavailable {
            fetchIssues.append(.accessBoundaryUnavailable)
        }

        let downloadedPayload = downloadedPayload(input.downloadedPackData, entry: entry)
        if input.accessDecision.permitsRemotePublicReference && downloadedPayload == nil {
            fetchIssues.append(.packDownloadUnavailable)
        }

        let resolution = cache.resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: manifest,
                request: packRequest,
                cachedPayload: downloadedPayload ?? input.cachedPayload,
                bundledPayload: input.bundledPayload,
                lastKnownGoodPayload: input.lastKnownGoodPayload,
                query: input.query,
                checkedAt: input.checkedAt,
                policy: input.policy,
                accessDecision: input.accessDecision
            )
        )
        if resolution.cacheIssues.contains(.noEligiblePack) {
            fetchIssues.append(.noEligiblePack)
        }

        let findings = SourceAtlasNoPrivateGraphEgressAudit.validate(egressRecords)
        if findings.isEmpty == false {
            fetchIssues.append(.privateEgressFinding)
        }

        return SourceAtlasPublicPackFetchResolution(
            status: status(fetchIssues: fetchIssues, resolution: resolution),
            fetchIssues: orderedIssues(fetchIssues),
            manifestRequestIssues: manifestRequestIssues,
            packRequest: packRequest,
            egressFindings: findings,
            cacheResolution: resolution
        )
    }
}

private extension SourceAtlasPublicPackFetchPipeline {
    func resolvedManifest(from input: SourceAtlasPublicPackFetchInput) -> (
        manifest: SourceAtlasFreshnessManifest?,
        issues: [SourceAtlasPublicPackFetchIssue]
    ) {
        resolvedManifest(from: input, currentPointer: nil)
    }

    func resolvedManifest(
        from input: SourceAtlasPublicPackFetchInput,
        currentPointer: SourceAtlasPublishedCurrentPointer?
    ) -> (
        manifest: SourceAtlasFreshnessManifest?,
        issues: [SourceAtlasPublicPackFetchIssue]
    ) {
        if let fetchedManifestData = input.fetchedManifestData {
            if let currentPointer {
                do {
                    var issues: [SourceAtlasPublicPackFetchIssue] = []
                    let bridge = SourceAtlasPublishedPackSchemaDecoder(decoder: decoder)
                    var manifest = try bridge.freshnessManifest(
                        from: fetchedManifestData,
                        pointer: currentPointer
                    )
                    if let revocationData = input.fetchedRevocationManifestData {
                        do {
                            if try bridge.currentPackIsRevoked(
                                pointer: currentPointer,
                                manifestData: fetchedManifestData,
                                revocationData: revocationData
                            ) {
                                manifest = bridge.markPackRevoked(manifest, packID: currentPointer.packID)
                            }
                        } catch {
                            return (nil, [.revocationManifestInvalid])
                        }
                    }
                    if input.fetchedLastKnownGoodPointerData != nil || input.fetchedLastKnownGoodManifestData != nil {
                        guard let pointerData = input.fetchedLastKnownGoodPointerData,
                              let manifestData = input.fetchedLastKnownGoodManifestData
                        else {
                            issues.append(.lastKnownGoodInvalid)
                            return (manifest, issues)
                        }
                        do {
                            manifest = try bridge.applyingLastKnownGoodPointer(
                                pointerData,
                                manifestData: manifestData,
                                to: manifest
                            )
                        } catch {
                            issues.append(.lastKnownGoodInvalid)
                        }
                    }
                    return (manifest, issues)
                } catch SourceAtlasPublishedPackSchemaIssue.manifestHashMismatch {
                    if let cachedManifest = input.cachedManifest {
                        return (cachedManifest, [.manifestHashMismatch])
                    }
                    return (nil, [.manifestHashMismatch])
                } catch {
                    if let cachedManifest = input.cachedManifest {
                        return (cachedManifest, [.manifestDecodeFailed])
                    }
                    return (nil, [.manifestDecodeFailed])
                }
            }

            do {
                return (try decoder.decode(SourceAtlasFreshnessManifest.self, from: fetchedManifestData), [])
            } catch {
                if let cachedManifest = input.cachedManifest {
                    return (cachedManifest, [.manifestDecodeFailed])
                }
                return (nil, [.manifestDecodeFailed])
            }
        }

        if let cachedManifest = input.cachedManifest {
            return (cachedManifest, [.manifestUnavailable])
        }
        return (nil, [.manifestUnavailable])
    }

    func resolvedCurrentPointer(from data: Data?) -> (
        pointer: SourceAtlasPublishedCurrentPointer?,
        issues: [SourceAtlasPublicPackFetchIssue]
    ) {
        guard let data else {
            return (nil, [])
        }

        do {
            let pointer = try decoder.decode(SourceAtlasPublishedCurrentPointer.self, from: data)
            guard pointer.validationIssues.isEmpty else {
                return (nil, [.unsafeCurrentPointer])
            }
            return (pointer, [])
        } catch {
            return (nil, [.currentPointerDecodeFailed])
        }
    }

    func downloadedPayload(
        _ data: Data?,
        entry: SourceAtlasFreshnessPackEntry
    ) -> SourceAtlasStorePayload? {
        guard let data else {
            return nil
        }
        return SourceAtlasStorePayload(
            source: .cached,
            data: data,
            declaredSHA256: entry.currentSHA256
        )
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
            identifier: "source-atlas-pack-request",
            inspectedValue: serialized
        )
    }

    func status(
        fetchIssues: [SourceAtlasPublicPackFetchIssue],
        resolution: SourceAtlasLocalPackCacheResolution
    ) -> SourceAtlasPublicPackFetchStatus {
        if fetchIssues.contains(.privateEgressFinding) ||
            fetchIssues.contains(.unsafeManifestRequest) ||
            fetchIssues.contains(.unsafeCurrentPointer) ||
            fetchIssues.contains(.currentPointerDecodeFailed) ||
            fetchIssues.contains(.unsafePackRequest) ||
            fetchIssues.contains(.revocationManifestInvalid) ||
            fetchIssues.contains(.manifestHashMismatch) ||
            resolution.cacheIssues.contains(.manifestHashMismatch) ||
            resolution.cacheIssues.contains(.staleCriticalByManifest) ||
            resolution.cacheIssues.contains(.revokedByManifest) ||
            resolution.cacheIssues.contains(.contradictedByManifest) {
            return .quarantined
        }

        if resolution.selectedPack == nil {
            return .unavailable
        }

        if resolution.loadResult.selectedSource == .bundled ||
            resolution.loadResult.selectedSource == .lastKnownGood ||
            resolution.cacheIssues.contains(.localFallbackUsed) ||
            fetchIssues.contains(.manifestUnavailable) ||
            fetchIssues.contains(.manifestDecodeFailed) ||
            fetchIssues.contains(.packDownloadUnavailable) {
            return .usingLocalFallback
        }

        return .accepted
    }

    func earlyUnavailableStatus(_ fetchIssues: [SourceAtlasPublicPackFetchIssue]) -> SourceAtlasPublicPackFetchStatus {
        if fetchIssues.contains(.privateEgressFinding) ||
            fetchIssues.contains(.unsafeManifestRequest) ||
            fetchIssues.contains(.unsafeCurrentPointer) ||
            fetchIssues.contains(.currentPointerDecodeFailed) ||
            fetchIssues.contains(.revocationManifestInvalid) ||
            fetchIssues.contains(.manifestHashMismatch) {
            return .quarantined
        }
        return .unavailable
    }

    func orderedIssues(_ issues: [SourceAtlasPublicPackFetchIssue]) -> [SourceAtlasPublicPackFetchIssue] {
        SourceAtlasPublicPackFetchIssue.allCases.filter { issues.contains($0) }
    }
}
