import Foundation

enum SourceAtlasPublicPackRemoteObjectKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case currentPointer = "current_pointer"
    case revocations
    case manifest
    case lastKnownGood = "last_known_good"
    case lastKnownGoodManifest = "last_known_good_manifest"
    case pack
}

enum SourceAtlasPublicPackRemoteTransportIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsafeManifestRequest = "unsafe_manifest_request"
    case remoteFetchSkipped = "remote_fetch_skipped"
    case missingObjectKey = "missing_object_key"
    case privateObjectKey = "private_object_key"
    case invalidEndpoint = "invalid_endpoint"
    case currentPointerUnavailable = "current_pointer_unavailable"
    case currentPointerInvalid = "current_pointer_invalid"
    case revocationManifestUnavailable = "revocation_manifest_unavailable"
    case revocationManifestInvalid = "revocation_manifest_invalid"
    case currentPackRevoked = "current_pack_revoked"
    case manifestUnavailable = "manifest_unavailable"
    case manifestObjectKeyUnavailable = "manifest_object_key_unavailable"
    case lastKnownGoodUnavailable = "last_known_good_unavailable"
    case lastKnownGoodInvalid = "last_known_good_invalid"
    case lastKnownGoodManifestUnavailable = "last_known_good_manifest_unavailable"
    case packUnavailable = "pack_unavailable"
    case privateEgressFinding = "private_egress_finding"
}

enum SourceAtlasPublicPackRemoteTransportError: Error, Sendable, Equatable {
    case missingObject(String)
    case invalidURL
    case httpStatus(Int)
}

struct SourceAtlasPublicPackRemoteObjectRequest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: SourceAtlasPublicPackRemoteObjectKind
    let objectKey: String

    init(
        kind: SourceAtlasPublicPackRemoteObjectKind,
        objectKey: String
    ) {
        self.kind = kind
        self.objectKey = objectKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.id = "\(kind.rawValue):\(self.objectKey)"
    }

    var validationIssues: [SourceAtlasPublicPackRemoteTransportIssue] {
        var issues: Set<SourceAtlasPublicPackRemoteTransportIssue> = []

        if objectKey.isEmpty {
            issues.insert(.missingObjectKey)
        }
        if SourceAtlasNoPrivateGraphEgressAudit.validate([egressRecord]).isEmpty == false {
            issues.insert(.privateObjectKey)
        }

        return SourceAtlasPublicPackRemoteTransportIssue.allCases.filter { issues.contains($0) }
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .objectKey,
            identifier: "source-atlas-remote-\(kind.rawValue)",
            inspectedValue: objectKey
        )
    }
}

protocol SourceAtlasPublicPackRemoteTransport: Sendable {
    func fetch(_ request: SourceAtlasPublicPackRemoteObjectRequest) async throws -> Data
}

struct SourceAtlasPublicPackRemoteFetchInput: Sendable, Equatable, Hashable {
    let manifestRequest: SourceAtlasPublicManifestRequest
    let targetPackID: String
    let environment: String
    let cachedManifest: SourceAtlasFreshnessManifest?
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
        environment: String = "staging",
        cachedManifest: SourceAtlasFreshnessManifest? = nil,
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
        self.environment = environment.trimmingCharacters(in: .whitespacesAndNewlines)
        self.cachedManifest = cachedManifest
        self.cachedPayload = cachedPayload
        self.bundledPayload = bundledPayload
        self.lastKnownGoodPayload = lastKnownGoodPayload
        self.accessDecision = accessDecision
        self.query = query
        self.checkedAt = checkedAt
        self.policy = policy
    }
}

struct SourceAtlasPublicPackRemoteFetchResolution: Sendable, Equatable, Hashable {
    let transportIssues: [SourceAtlasPublicPackRemoteTransportIssue]
    let objectRequests: [SourceAtlasPublicPackRemoteObjectRequest]
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]
    let pipelineResolution: SourceAtlasPublicPackFetchResolution

    var selectedPack: SourceAtlasPack? {
        pipelineResolution.selectedPack
    }

    var coreLocalPlanningBlocked: Bool {
        false
    }
}

struct SourceAtlasPublicPackRemoteFetchCoordinator {
    private let decoder: JSONDecoder
    private let manifestBridge: SourceAtlasPublishedPackSchemaDecoder
    private let pipeline: SourceAtlasPublicPackFetchPipeline
    private let publicOnlyGate: SourceAtlasPublicOnlyBoundaryGate

    init(
        decoder: JSONDecoder = JSONDecoder(),
        manifestBridge: SourceAtlasPublishedPackSchemaDecoder = SourceAtlasPublishedPackSchemaDecoder(),
        pipeline: SourceAtlasPublicPackFetchPipeline = SourceAtlasPublicPackFetchPipeline(),
        publicOnlyGate: SourceAtlasPublicOnlyBoundaryGate = SourceAtlasPublicOnlyBoundaryGate()
    ) {
        self.decoder = decoder
        self.manifestBridge = manifestBridge
        self.pipeline = pipeline
        self.publicOnlyGate = publicOnlyGate
    }

    func resolve(
        _ input: SourceAtlasPublicPackRemoteFetchInput,
        transport: SourceAtlasPublicPackRemoteTransport
    ) async -> SourceAtlasPublicPackRemoteFetchResolution {
        var issues: [SourceAtlasPublicPackRemoteTransportIssue] = []
        var objectRequests: [SourceAtlasPublicPackRemoteObjectRequest] = []
        var egressRecords = [input.manifestRequest.egressRecord]

        if input.manifestRequest.validationIssues.isEmpty == false {
            issues.append(.unsafeManifestRequest)
            return remoteResolution(
                input: input,
                issues: issues,
                objectRequests: objectRequests,
                egressRecords: egressRecords
            )
        }

        guard input.accessDecision.permitsRemotePublicReference else {
            issues.append(.remoteFetchSkipped)
            return remoteResolution(
                input: input,
                issues: issues,
                objectRequests: objectRequests,
                egressRecords: egressRecords
            )
        }

        let currentPointerRequest = currentPointerObjectRequest(input)
        guard appendIfSafe(
            currentPointerRequest,
            manifestRequest: input.manifestRequest,
            accessDecision: input.accessDecision,
            issues: &issues,
            objectRequests: &objectRequests,
            egressRecords: &egressRecords
        ) else {
            return remoteResolution(
                input: input,
                issues: issues,
                objectRequests: objectRequests,
                egressRecords: egressRecords
            )
        }

        let currentPointerData: Data
        do {
            currentPointerData = try await transport.fetch(currentPointerRequest)
        } catch {
            issues.append(.currentPointerUnavailable)
            return remoteResolution(
                input: input,
                issues: issues,
                objectRequests: objectRequests,
                egressRecords: egressRecords
            )
        }

        guard let currentPointer = currentPointer(from: currentPointerData) else {
            issues.append(.currentPointerInvalid)
            return remoteResolution(
                input: input,
                currentPointerData: currentPointerData,
                issues: issues,
                objectRequests: objectRequests,
                egressRecords: egressRecords
            )
        }

        let revocationData: Data?
        do {
            revocationData = try await optionalObjectData(
                objectKey: currentPointer.revocationManifestKey,
                kind: .revocations,
                unavailableIssue: .revocationManifestUnavailable,
                manifestRequest: input.manifestRequest,
                accessDecision: input.accessDecision,
                transport: transport,
                issues: &issues,
                objectRequests: &objectRequests,
                egressRecords: &egressRecords
            )
        } catch {
            return remoteResolution(
                input: input,
                currentPointerData: currentPointerData,
                issues: issues,
                objectRequests: objectRequests,
                egressRecords: egressRecords
            )
        }

        let manifestRequest = SourceAtlasPublicPackRemoteObjectRequest(
            kind: .manifest,
            objectKey: currentPointer.manifestKey
        )
        guard appendIfSafe(
            manifestRequest,
            manifestRequest: input.manifestRequest,
            accessDecision: input.accessDecision,
            issues: &issues,
            objectRequests: &objectRequests,
            egressRecords: &egressRecords
        ) else {
            return remoteResolution(
                input: input,
                currentPointerData: currentPointerData,
                issues: issues,
                objectRequests: objectRequests,
                egressRecords: egressRecords
            )
        }

        let manifestData: Data
        do {
            manifestData = try await transport.fetch(manifestRequest)
        } catch {
            issues.append(.manifestUnavailable)
            return remoteResolution(
                input: input,
                currentPointerData: currentPointerData,
                issues: issues,
                objectRequests: objectRequests,
                egressRecords: egressRecords
            )
        }

        if let revocationData {
            do {
                if try manifestBridge.currentPackIsRevoked(
                    pointer: currentPointer,
                    manifestData: manifestData,
                    revocationData: revocationData
                ) {
                    issues.append(.currentPackRevoked)
                    return remoteResolution(
                        input: input,
                        currentPointerData: currentPointerData,
                        revocationData: revocationData,
                        manifestData: manifestData,
                        issues: issues,
                        objectRequests: objectRequests,
                        egressRecords: egressRecords
                    )
                }
            } catch {
                issues.append(.revocationManifestInvalid)
                return remoteResolution(
                    input: input,
                    currentPointerData: currentPointerData,
                    revocationData: revocationData,
                    manifestData: manifestData,
                    issues: issues,
                    objectRequests: objectRequests,
                    egressRecords: egressRecords
                )
            }
        }

        let lastKnownGoodPointerData: Data?
        do {
            lastKnownGoodPointerData = try await optionalObjectData(
                objectKey: currentPointer.lastKnownGoodKey,
                kind: .lastKnownGood,
                unavailableIssue: .lastKnownGoodUnavailable,
                manifestRequest: input.manifestRequest,
                accessDecision: input.accessDecision,
                transport: transport,
                issues: &issues,
                objectRequests: &objectRequests,
                egressRecords: &egressRecords
            )
        } catch {
            return remoteResolution(
                input: input,
                currentPointerData: currentPointerData,
                revocationData: revocationData,
                manifestData: manifestData,
                issues: issues,
                objectRequests: objectRequests,
                egressRecords: egressRecords
            )
        }

        let lastKnownGoodManifestData: Data?
        if let lastKnownGoodPointerData {
            do {
                let lkgManifestKey = try manifestBridge.lastKnownGoodManifestKey(from: lastKnownGoodPointerData)
                let lkgManifestRequest = SourceAtlasPublicPackRemoteObjectRequest(
                    kind: .lastKnownGoodManifest,
                    objectKey: lkgManifestKey
                )
                guard appendIfSafe(
                    lkgManifestRequest,
                    manifestRequest: input.manifestRequest,
                    accessDecision: input.accessDecision,
                    issues: &issues,
                    objectRequests: &objectRequests,
                    egressRecords: &egressRecords
                ) else {
                    return remoteResolution(
                        input: input,
                        currentPointerData: currentPointerData,
                        revocationData: revocationData,
                        manifestData: manifestData,
                        lastKnownGoodPointerData: lastKnownGoodPointerData,
                        issues: issues,
                        objectRequests: objectRequests,
                        egressRecords: egressRecords
                    )
                }
                lastKnownGoodManifestData = try await transport.fetch(lkgManifestRequest)
            } catch SourceAtlasPublishedPackSchemaIssue.notPublicReference,
                    SourceAtlasPublishedPackSchemaIssue.manifestDecodeFailed,
                    SourceAtlasPublishedPackSchemaIssue.packObjectKeyMissing {
                issues.append(.lastKnownGoodInvalid)
                lastKnownGoodManifestData = nil
            } catch {
                issues.append(.lastKnownGoodManifestUnavailable)
                lastKnownGoodManifestData = nil
            }
        } else {
            lastKnownGoodManifestData = nil
        }

        let packObjectKey: String
        do {
            _ = try manifestBridge.freshnessManifest(from: manifestData, pointer: currentPointer)
            packObjectKey = try manifestBridge.packObjectKey(from: manifestData)
        } catch {
            issues.append(.manifestObjectKeyUnavailable)
            return remoteResolution(
                input: input,
                currentPointerData: currentPointerData,
                revocationData: revocationData,
                manifestData: manifestData,
                lastKnownGoodPointerData: lastKnownGoodPointerData,
                lastKnownGoodManifestData: lastKnownGoodManifestData,
                issues: issues,
                objectRequests: objectRequests,
                egressRecords: egressRecords
            )
        }

        let packRequest = SourceAtlasPublicPackRemoteObjectRequest(
            kind: .pack,
            objectKey: packObjectKey
        )
        guard appendIfSafe(
            packRequest,
            manifestRequest: input.manifestRequest,
            accessDecision: input.accessDecision,
            issues: &issues,
            objectRequests: &objectRequests,
            egressRecords: &egressRecords
        ) else {
            return remoteResolution(
                input: input,
                currentPointerData: currentPointerData,
                revocationData: revocationData,
                manifestData: manifestData,
                lastKnownGoodPointerData: lastKnownGoodPointerData,
                lastKnownGoodManifestData: lastKnownGoodManifestData,
                issues: issues,
                objectRequests: objectRequests,
                egressRecords: egressRecords
            )
        }

        let packData: Data?
        do {
            packData = try await transport.fetch(packRequest)
        } catch {
            issues.append(.packUnavailable)
            packData = nil
        }

        return remoteResolution(
            input: input,
            currentPointerData: currentPointerData,
            revocationData: revocationData,
            manifestData: manifestData,
            lastKnownGoodPointerData: lastKnownGoodPointerData,
            lastKnownGoodManifestData: lastKnownGoodManifestData,
            packData: packData,
            issues: issues,
            objectRequests: objectRequests,
            egressRecords: egressRecords
        )
    }
}

private extension SourceAtlasPublicPackRemoteFetchCoordinator {
    func currentPointerObjectRequest(_ input: SourceAtlasPublicPackRemoteFetchInput) -> SourceAtlasPublicPackRemoteObjectRequest {
        SourceAtlasPublicPackRemoteObjectRequest(
            kind: .currentPointer,
            objectKey: [
                "source-atlas",
                "v1",
                input.environment,
                input.manifestRequest.channel,
                input.manifestRequest.domainID,
                "current.json"
            ].joined(separator: "/")
        )
    }

    func appendIfSafe(
        _ request: SourceAtlasPublicPackRemoteObjectRequest,
        manifestRequest: SourceAtlasPublicManifestRequest,
        accessDecision: SourceAtlasAccessDecision,
        issues: inout [SourceAtlasPublicPackRemoteTransportIssue],
        objectRequests: inout [SourceAtlasPublicPackRemoteObjectRequest],
        egressRecords: inout [SourceAtlasNoPrivateGraphEgressRecord]
    ) -> Bool {
        objectRequests.append(request)
        egressRecords.append(request.egressRecord)
        let requestIssues = request.validationIssues
        issues.append(contentsOf: requestIssues)
        let publicOnlyDecision = publicOnlyGate.evaluateRemoteObjectRequest(
            request,
            manifestRequest: manifestRequest,
            accessDecision: accessDecision
        )
        if publicOnlyDecision.egressFindings.isEmpty == false {
            issues.append(.privateEgressFinding)
        }
        if publicOnlyDecision.issues.contains(.firewallRejected) ||
            publicOnlyDecision.issues.contains(.remoteReferenceNotPermitted) ||
            publicOnlyDecision.issues.contains(.privateRuntimeDataTouched) {
            issues.append(.unsafeManifestRequest)
        }
        return requestIssues.isEmpty && publicOnlyDecision.isAllowed
    }

    func optionalObjectData(
        objectKey: String?,
        kind: SourceAtlasPublicPackRemoteObjectKind,
        unavailableIssue: SourceAtlasPublicPackRemoteTransportIssue,
        manifestRequest: SourceAtlasPublicManifestRequest,
        accessDecision: SourceAtlasAccessDecision,
        transport: SourceAtlasPublicPackRemoteTransport,
        issues: inout [SourceAtlasPublicPackRemoteTransportIssue],
        objectRequests: inout [SourceAtlasPublicPackRemoteObjectRequest],
        egressRecords: inout [SourceAtlasNoPrivateGraphEgressRecord]
    ) async throws -> Data? {
        guard let objectKey, objectKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return nil
        }
        let request = SourceAtlasPublicPackRemoteObjectRequest(kind: kind, objectKey: objectKey)
        guard appendIfSafe(
            request,
            manifestRequest: manifestRequest,
            accessDecision: accessDecision,
            issues: &issues,
            objectRequests: &objectRequests,
            egressRecords: &egressRecords
        ) else {
            throw SourceAtlasPublicPackRemoteTransportError.invalidURL
        }
        do {
            return try await transport.fetch(request)
        } catch {
            issues.append(unavailableIssue)
            throw error
        }
    }

    func currentPointer(from data: Data) -> SourceAtlasPublishedCurrentPointer? {
        guard let pointer = try? decoder.decode(SourceAtlasPublishedCurrentPointer.self, from: data),
              pointer.validationIssues.isEmpty
        else {
            return nil
        }
        return pointer
    }

    func remoteResolution(
        input: SourceAtlasPublicPackRemoteFetchInput,
        currentPointerData: Data? = nil,
        revocationData: Data? = nil,
        manifestData: Data? = nil,
        lastKnownGoodPointerData: Data? = nil,
        lastKnownGoodManifestData: Data? = nil,
        packData: Data? = nil,
        issues: [SourceAtlasPublicPackRemoteTransportIssue],
        objectRequests: [SourceAtlasPublicPackRemoteObjectRequest],
        egressRecords: [SourceAtlasNoPrivateGraphEgressRecord]
    ) -> SourceAtlasPublicPackRemoteFetchResolution {
        var orderedIssues = orderedTransportIssues(issues)
        let transportFindings = SourceAtlasNoPrivateGraphEgressAudit.validate(egressRecords)
        if transportFindings.isEmpty == false {
            orderedIssues = orderedTransportIssues(orderedIssues + [.privateEgressFinding])
        }

        let pipelineResolution = pipeline.resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: input.manifestRequest,
                targetPackID: input.targetPackID,
                fetchedCurrentPointerData: currentPointerData,
                fetchedManifestData: manifestData,
                fetchedRevocationManifestData: revocationData,
                fetchedLastKnownGoodPointerData: lastKnownGoodPointerData,
                fetchedLastKnownGoodManifestData: lastKnownGoodManifestData,
                cachedManifest: input.cachedManifest,
                downloadedPackData: packData,
                cachedPayload: input.cachedPayload,
                bundledPayload: input.bundledPayload,
                lastKnownGoodPayload: input.lastKnownGoodPayload,
                accessDecision: input.accessDecision,
                query: input.query,
                checkedAt: input.checkedAt,
                policy: input.policy
            )
        )

        return SourceAtlasPublicPackRemoteFetchResolution(
            transportIssues: orderedIssues,
            objectRequests: objectRequests,
            egressFindings: orderedUniqueFindings(transportFindings + pipelineResolution.egressFindings),
            pipelineResolution: pipelineResolution
        )
    }

    func orderedTransportIssues(_ issues: [SourceAtlasPublicPackRemoteTransportIssue]) -> [SourceAtlasPublicPackRemoteTransportIssue] {
        SourceAtlasPublicPackRemoteTransportIssue.allCases.filter { issues.contains($0) }
    }

    func orderedUniqueFindings(_ findings: [SourceAtlasNoPrivateGraphEgressFinding]) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        var seen: Set<SourceAtlasNoPrivateGraphEgressFinding> = []
        return findings.filter { seen.insert($0).inserted }
    }
}
