import Foundation
@testable import Ambitions
import XCTest

final class SourceAtlasPublicOnlyBoundaryGateTests: XCTestCase {
    func testPublicOnlyBoundaryGateAllowsRequestGatewayEndpointCacheRollbackAndProjectionEvidence() throws {
        let gate = SourceAtlasPublicOnlyBoundaryGate()
        let pack = Self.pack()
        let payload = try Self.payload(for: pack, source: .cached)
        let manifestData = Data("manifest-public-reference-sports".utf8)
        let manifestHash = SourceAtlasStore.sha256Hex(for: manifestData)
        let entry = SourceAtlasFreshnessPackEntry(
            packID: pack.id,
            currentSHA256: payload.declaredSHA256,
            currentSignature: "sha256:\(manifestHash)",
            rollbackPointers: ["last_known_good": payload.declaredSHA256]
        )
        let manifest = Self.manifest(entry: entry)
        let accessDecision = SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                networkReachability: .online,
                cachedPublicArtifactAvailable: true,
                lastKnownGoodAvailable: true,
                bundledPublicArtifactAvailable: true
            )
        )

        let compilation = PublicPackRequestCompiler().compile(
            manifest: manifest,
            packID: pack.id,
            channel: "stable",
            appVersion: "1.0.0",
            accessDecision: accessDecision,
            publicLocale: "en-US",
            publicJurisdiction: "US"
        )
        let requestDecision = gate.evaluatePublicPackRequest(
            manifestRequest: compilation.manifestRequest,
            packRequest: compilation.packRequest,
            accessDecision: accessDecision
        )

        XCTAssertTrue(requestDecision.isAllowed)
        XCTAssertTrue(compilation.canFetchRemotePublicReference)

        let endpoint = SourceAtlasPublicPackRemoteEndpoint(
            baseURLString: "https://r2.example.test/source-atlas"
        )
        let remoteObject = SourceAtlasPublicPackRemoteObjectRequest(
            kind: .pack,
            objectKey: "source-atlas/v1/production/stable/sports/20260701T000000Z/pack.json"
        )
        XCTAssertTrue(gate.evaluateRemoteEndpoint(endpoint).isAllowed)
        XCTAssertTrue(
            gate.evaluateRemoteObjectRequest(
                remoteObject,
                manifestRequest: compilation.manifestRequest,
                accessDecision: accessDecision
            ).isAllowed
        )

        let gateway = R2GatewayClient(baseURL: URL(string: "https://r2.example.test/source-atlas")!)
        let compiledGateway = try gateway.compile(
            kind: .pack,
            objectKey: remoteObject.objectKey,
            manifestRequest: compilation.manifestRequest,
            packRequest: try XCTUnwrap(compilation.packRequest),
            accessDecision: accessDecision
        )
        XCTAssertTrue(gate.evaluateCompiledR2GatewayRequest(compiledGateway).isAllowed)
        XCTAssertTrue(gate.evaluateURLRequest(gateway.urlRequest(for: compiledGateway)).isAllowed)

        let verification = ManifestVerifier().verify(
            manifest: manifest,
            packID: pack.id,
            expectedVersionID: manifest.versionID,
            manifestData: manifestData,
            expectedManifestSHA256: manifestHash,
            checkedAt: Self.checkedAt
        )
        let freshness = FreshnessEngine().evaluate(
            manifest: manifest,
            packID: pack.id,
            checkedAt: Self.checkedAt
        )
        let cacheResolution = PublicPackCache().resolve(
            PublicPackCacheInput(
                manifest: manifest,
                request: try XCTUnwrap(compilation.packRequest),
                cachedPayload: payload,
                lastKnownGoodPayload: payload,
                accessDecision: accessDecision,
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )
        let lastKnownGood = LastKnownGoodStore().select(entry: entry, payload: payload)
        XCTAssertTrue(
            gate.evaluateManifestCacheRollbackEvidence(
                verification: verification,
                freshness: freshness,
                cacheResolution: cacheResolution,
                lastKnownGood: lastKnownGood
            ).isAllowed
        )

        let projection = SourceAtlasProjection().materialize(
            compilation: compilation,
            cacheResolution: cacheResolution
        )
        XCTAssertTrue(gate.evaluateSourceAtlasProjection(projection).isAllowed)
    }

    func testPublicOnlyBoundaryGateRejectsPrivateRuntimeR2EndpointHeaderAndProjectionMarkers() throws {
        let gate = SourceAtlasPublicOnlyBoundaryGate()
        let unsafeAccessDecision = SourceAtlasAccessDecision(
            route: .remotePublicReference,
            issues: [],
            permitsRemotePublicReference: true,
            permitsPublicCacheRead: false,
            coreLocalPlanningBlocked: false,
            privateRuntimeDataTouched: true,
            unavailableStateTitle: "",
            unavailableStateDetail: ""
        )
        let unsafeManifestRequest = SourceAtlasPublicManifestRequest(
            domainID: "goal_text",
            channel: "stable",
            schemaVersion: "1",
            appVersion: "1.0.0"
        )
        let unsafePackRequest = SourceAtlasPublicPackRequest(
            packID: "source-atlas/v1/domain/user_id/private-goal",
            manifestVersionID: "manifest.v1",
            declaredSHA256: String(repeating: "a", count: 64),
            queryItems: [
                "goal_text": "private",
                "receipt_payload": "private"
            ]
        )

        let requestDecision = gate.evaluatePublicPackRequest(
            manifestRequest: unsafeManifestRequest,
            packRequest: unsafePackRequest,
            accessDecision: unsafeAccessDecision
        )
        XCTAssertFalse(requestDecision.isAllowed)
        XCTAssertTrue(requestDecision.issues.contains(.privateRuntimeDataTouched))
        XCTAssertTrue(requestDecision.issues.contains(.privateEgressFinding))
        XCTAssertTrue(requestDecision.issues.contains(.firewallRejected))

        let objectDecision = gate.evaluateRemoteObjectRequest(
            SourceAtlasPublicPackRemoteObjectRequest(
                kind: .pack,
                objectKey: "source-atlas/v1/production/stable/user_id/private_graph.json"
            ),
            manifestRequest: SourceAtlasPublicManifestRequest(
                domainID: "sports",
                channel: "stable",
                schemaVersion: "1",
                appVersion: "1.0.0"
            ),
            accessDecision: SourceAtlasBoundary().resolve(
                SourceAtlasAccessRequest(
                    artifactTier: .publicFreshness,
                    networkReachability: .online
                )
            )
        )
        XCTAssertFalse(objectDecision.isAllowed)
        XCTAssertTrue(objectDecision.issues.contains(.unsafeR2ObjectKey))
        XCTAssertTrue(objectDecision.issues.contains(.privateEgressFinding))

        let endpointDecision = gate.evaluateRemoteEndpoint(
            SourceAtlasPublicPackRemoteEndpoint(baseURLString: "https://user@r2.example.test/source")
        )
        XCTAssertFalse(endpointDecision.isAllowed)
        XCTAssertTrue(endpointDecision.issues.contains(.unsafeRemoteEndpoint))

        var urlRequest = URLRequest(url: URL(string: "https://r2.example.test/source")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("private-runtime", forHTTPHeaderField: "X-Ambitions-Data-Class")
        urlRequest.setValue("Bearer private", forHTTPHeaderField: "Authorization")
        let urlRequestDecision = gate.evaluateURLRequest(urlRequest)
        XCTAssertFalse(urlRequestDecision.isAllowed)
        XCTAssertTrue(urlRequestDecision.issues.contains(.unsafeURLRequestMethod))
        XCTAssertTrue(urlRequestDecision.issues.contains(.unsafeURLRequestHeader))

        let projectionDecision = gate.evaluateSourceAtlasProjection(
            SourceAtlasProjectionRecord(
                id: "source-atlas.projection.private",
                packID: "source-atlas/v1/domain/private_graph",
                status: .available,
                selectedSource: .cached,
                fallbackReason: .none,
                freshnessStatus: .current,
                proofEntryIDs: ["proof_payload.private"],
                provenanceSourceIDs: ["source.public"],
                blocksCurrentUse: false
            )
        )
        XCTAssertFalse(projectionDecision.isAllowed)
        XCTAssertTrue(projectionDecision.issues.contains(.projectionNotPublicReferenceOnly))
        XCTAssertTrue(projectionDecision.issues.contains(.privateEgressFinding))
    }
}

private extension SourceAtlasPublicOnlyBoundaryGateTests {
    static let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)

    static func manifest(entry: SourceAtlasFreshnessPackEntry) -> SourceAtlasFreshnessManifest {
        SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: "manifest.v1",
            publishedAt: checkedAt,
            packIndex: [entry]
        )
    }

    static func payload(
        for pack: SourceAtlasPack,
        source: SourceAtlasStorePayloadSource
    ) throws -> SourceAtlasStorePayload {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(pack)
        return SourceAtlasStorePayload(
            source: source,
            data: data,
            declaredSHA256: SourceAtlasStore.sha256Hex(for: data)
        )
    }

    static func pack() -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: "source-atlas/v1/domain/sports",
                title: "Public Sports Pack",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "sports"
            ),
            sources: [
                SourceAtlasSourceRecord(
                    id: "source.official",
                    title: "Official rules",
                    kind: .official,
                    locator: "https://example.test/rules",
                    retrievedAt: "2026-07-01T00:00:00Z",
                    contentHash: "hash",
                    approvedForOfficialClaims: true
                )
            ],
            claims: [
                SourceAtlasClaim(
                    id: "claim.current",
                    text: "The public rule is current.",
                    state: .official,
                    freshness: .current,
                    riskClass: .sportRules,
                    sourceIDs: ["source.official"],
                    reviewRequired: false
                )
            ],
            requirements: [
                SourceAtlasRequirement(
                    id: "requirement.current",
                    claimID: "claim.current",
                    title: "Use current public rule",
                    kind: .hard,
                    required: true,
                    sourceState: .officialCurrent,
                    freshnessState: .current,
                    riskState: .low,
                    reviewState: .approved
                )
            ],
            starterItems: [],
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof.current",
                    requirementID: "requirement.current",
                    proofDescription: "Public source proof.",
                    privacyClass: .externalRedacted,
                    proofCandidate: .sourceEvidence,
                    proofStrength: .high,
                    capabilityNodeID: "node.current",
                    sourceRecordIDs: ["source.official"],
                    sourceClaimIDs: ["claim.current"]
                )
            ],
            projections: [],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Context needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Public reference only."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["node.current"],
                overlayDependencyIDs: ["overlay.current"],
                projectionRecipeIDs: ["projection.current"],
                ownsIndividualGoalPhrase: false
            )
        )
    }
}
