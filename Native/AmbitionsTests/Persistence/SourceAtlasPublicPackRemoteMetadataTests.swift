import XCTest
@testable import Ambitions

final class SourceAtlasPublicPackRemoteMetadataTests: XCTestCase {
    func testRevocationManifestBlocksCurrentPackBeforePackFetch() async throws {
        let fixture = try Self.fixture(revokedPackIDs: [Self.currentPackID], includeLKG: false)
        let resolution = await Self.coordinator.resolve(
            Self.input(targetPackID: Self.currentPackID),
            transport: SourceAtlasStaticPublicPackRemoteTransport(objectsByKey: [
                Self.currentPointerKey: fixture.pointerData,
                Self.revocationsKey: fixture.revocationData,
                Self.currentManifestKey: fixture.currentManifestData
            ])
        )

        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [Self.currentPointerKey, Self.revocationsKey, Self.currentManifestKey]
        )
        XCTAssertFalse(resolution.objectRequests.contains { $0.kind == .pack })
        XCTAssertEqual(resolution.transportIssues, [.currentPackRevoked])
        XCTAssertEqual(resolution.pipelineResolution.status, .quarantined)
        XCTAssertTrue(resolution.pipelineResolution.cacheResolution?.cacheIssues.contains(.revokedByManifest) == true)
        XCTAssertNil(resolution.selectedPack)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testLastKnownGoodPointerAddsRollbackHashForExistingLocalPayloadWhenPackMissing() async throws {
        let fixture = try Self.fixture(includeLKG: true)
        let lastKnownGoodPayload = try Self.payload(for: fixture.lastKnownGoodPack, source: .lastKnownGood)

        let resolution = await Self.coordinator.resolve(
            Self.input(
                targetPackID: Self.currentPackID,
                lastKnownGoodPayload: lastKnownGoodPayload
            ),
            transport: SourceAtlasStaticPublicPackRemoteTransport(objectsByKey: [
                Self.currentPointerKey: fixture.pointerData,
                Self.revocationsKey: fixture.revocationData,
                Self.currentManifestKey: fixture.currentManifestData,
                Self.lkgKey: fixture.lkgPointerData,
                Self.lkgManifestKey: fixture.lkgManifestData
            ])
        )

        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [
                Self.currentPointerKey,
                Self.revocationsKey,
                Self.currentManifestKey,
                Self.lkgKey,
                Self.lkgManifestKey,
                Self.currentPackObjectKey
            ]
        )
        XCTAssertEqual(resolution.transportIssues, [.packUnavailable])
        XCTAssertEqual(resolution.pipelineResolution.status, .usingLocalFallback)
        XCTAssertEqual(resolution.pipelineResolution.cacheResolution?.loadResult.selectedSource, .lastKnownGood)
        XCTAssertEqual(resolution.selectedPack?.id, Self.lkgPackID)
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testPrivateLastKnownGoodManifestKeyStopsBeforePackFetch() async throws {
        let privateManifestKey = "source-atlas/v1/staging/candidate/user_id/lkg-manifest.json"
        let fixture = try Self.fixture(includeLKG: true, lkgManifestKey: privateManifestKey)

        let resolution = await Self.coordinator.resolve(
            Self.input(targetPackID: Self.currentPackID),
            transport: SourceAtlasStaticPublicPackRemoteTransport(objectsByKey: [
                Self.currentPointerKey: fixture.pointerData,
                Self.revocationsKey: fixture.revocationData,
                Self.currentManifestKey: fixture.currentManifestData,
                Self.lkgKey: fixture.lkgPointerData
            ])
        )

        XCTAssertEqual(
            resolution.objectRequests.map(\.objectKey),
            [Self.currentPointerKey, Self.revocationsKey, Self.currentManifestKey, Self.lkgKey, privateManifestKey]
        )
        XCTAssertFalse(resolution.objectRequests.contains { $0.kind == .pack })
        XCTAssertTrue(resolution.transportIssues.contains(.privateObjectKey))
        XCTAssertTrue(resolution.transportIssues.contains(.privateEgressFinding))
        XCTAssertTrue(resolution.pipelineResolution.fetchIssues.contains(.lastKnownGoodInvalid))
        XCTAssertNil(resolution.selectedPack)
    }
}

private extension SourceAtlasPublicPackRemoteMetadataTests {
    static let coordinator = SourceAtlasPublicPackRemoteFetchCoordinator()
    static let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)
    static let currentPackID = "source-atlas/v1/domain/public_civic_requirements/20260627T000000Z"
    static let lkgPackID = "source-atlas/v1/domain/public_civic_requirements/20260626T000000Z"
    static let currentPointerKey = "source-atlas/v1/staging/candidate/public_civic_requirements/current.json"
    static let currentManifestKey = "source-atlas/v1/staging/candidate/public_civic_requirements/20260627T000000Z/manifest.json"
    static let lkgManifestKey = "source-atlas/v1/staging/candidate/public_civic_requirements/20260626T000000Z/manifest.json"
    static let currentPackObjectKey = "source-atlas/v1/staging/candidate/public_civic_requirements/20260627T000000Z/pack.json"
    static let revocationsKey = "source-atlas/v1/staging/candidate/public_civic_requirements/revocations.json"
    static let lkgKey = "source-atlas/v1/staging/candidate/public_civic_requirements/lkg.json"
    static let manifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "public_civic_requirements",
        channel: "candidate",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )

    struct Fixture {
        let pointerData: Data
        let revocationData: Data
        let currentManifestData: Data
        let lkgPointerData: Data
        let lkgManifestData: Data
        let lastKnownGoodPack: SourceAtlasPack
    }

    static func fixture(
        revokedPackIDs: [String] = [],
        includeLKG: Bool,
        lkgManifestKey: String = lkgManifestKey
    ) throws -> Fixture {
        let currentPackData = publishedDomainPackData(packID: currentPackID)
        let currentPackSHA = SourceAtlasStore.sha256Hex(for: currentPackData)
        let currentManifestData = publishedManifestData(
            packID: currentPackID,
            packObjectKey: currentPackObjectKey,
            packSHA256: currentPackSHA
        )
        let lkgPack = nativePack(id: lkgPackID)
        let lkgPayloadData = try encoded(lkgPack)
        let lkgManifestData = publishedManifestData(
            packID: lkgPackID,
            packObjectKey: "source-atlas/v1/staging/candidate/public_civic_requirements/20260626T000000Z/pack.json",
            packSHA256: SourceAtlasStore.sha256Hex(for: lkgPayloadData)
        )
        let lkgPointerData = lastKnownGoodPointerData(
            manifestKey: lkgManifestKey,
            manifestSHA256: SourceAtlasStore.sha256Hex(for: lkgManifestData)
        )
        return Fixture(
            pointerData: pointerData(
                manifestSHA256: SourceAtlasStore.sha256Hex(for: currentManifestData),
                packSHA256: currentPackSHA,
                includeLKG: includeLKG
            ),
            revocationData: revocationData(revokedPackIDs: revokedPackIDs),
            currentManifestData: currentManifestData,
            lkgPointerData: lkgPointerData,
            lkgManifestData: lkgManifestData,
            lastKnownGoodPack: lkgPack
        )
    }

    static func input(
        targetPackID: String,
        lastKnownGoodPayload: SourceAtlasStorePayload? = nil
    ) -> SourceAtlasPublicPackRemoteFetchInput {
        SourceAtlasPublicPackRemoteFetchInput(
            manifestRequest: manifestRequest,
            targetPackID: targetPackID,
            lastKnownGoodPayload: lastKnownGoodPayload,
            accessDecision: SourceAtlasAccessBoundary().resolve(
                SourceAtlasAccessRequest(
                    artifactTier: .publicFreshness,
                    accountSessionState: .noAccount,
                    entitlementState: .bundledOnly,
                    networkReachability: .online,
                    lastKnownGoodAvailable: lastKnownGoodPayload != nil,
                    bundledPublicArtifactAvailable: false
                )
            ),
            query: SourceAtlasQuery(domainID: "public_civic_requirements"),
            checkedAt: checkedAt
        )
    }

    static func pointerData(
        manifestSHA256: String,
        packSHA256: String,
        includeLKG: Bool
    ) -> Data {
        Data(
            """
            {
              "schemaVersion": 1,
              "kind": "ambitions.sourceAtlas.currentPackPointer.v1",
              "createdAt": "2026-06-27T00:00:00Z",
              "environment": "staging",
              "channel": "candidate",
              "packID": "\(currentPackID)",
              "packVersion": "20260627T000000Z",
              "manifestKey": "\(currentManifestKey)",
              "manifestSHA256": "\(manifestSHA256)",
              "packSHA256": "\(packSHA256)",
              "revocationManifestKey": "\(revocationsKey)",
              "lastKnownGoodKey": \(includeLKG ? "\"\(lkgKey)\"" : "null"),
              "publicReferenceOnly": true,
              "dataClass": "public_freshness",
              "privacyBoundary": "public/reference/freshness only",
              "nonClaims": ["not a final user plan, schedule, or Step generator"]
            }
            """.utf8
        )
    }

    static func revocationData(revokedPackIDs: [String]) -> Data {
        let ids = revokedPackIDs.map { "\"\($0)\"" }.joined(separator: ",")
        return Data(
            """
            {
              "revocation_id": "source_atlas_revocation.test",
              "created_at": "2026-06-27T00:00:00Z",
              "revoked_pack_ids": [\(ids)],
              "revoked_object_keys": [],
              "reason": "test_revocation",
              "severity": "\(revokedPackIDs.isEmpty ? "none" : "high")",
              "publicReferenceOnly": true,
              "dataClass": "public_freshness",
              "privacyBoundary": "public/reference/freshness only",
              "nonClaims": ["not a final user plan, schedule, or Step generator"]
            }
            """.utf8
        )
    }

    static func lastKnownGoodPointerData(
        manifestKey: String,
        manifestSHA256: String
    ) -> Data {
        Data(
            """
            {
              "domain": "public_civic_requirements",
              "channel": "candidate",
              "pack_id": "\(lkgPackID)",
              "manifest_key": "\(manifestKey)",
              "sha256": "\(manifestSHA256)",
              "created_at": "2026-06-27T00:00:00Z",
              "valid_until": null,
              "reason_selected": "test_lkg",
              "rollback_safe": true,
              "publicReferenceOnly": true,
              "dataClass": "public_freshness",
              "privacyBoundary": "public/reference/freshness only",
              "nonClaims": ["not a final user plan, schedule, or Step generator"]
            }
            """.utf8
        )
    }

    static func publishedManifestData(
        packID: String,
        packObjectKey: String,
        packSHA256: String
    ) -> Data {
        Data(
            """
            {
              "kind": "ambitions.sourceAtlas.packManifest.v1",
              "schema_version": "1.0.0",
              "manifest_id": "source_atlas_pack_manifest.test",
              "pack_id": "\(packID)",
              "created_at": "2026-06-27T00:00:00Z",
              "object_keys": {"pack": "\(packObjectKey)"},
              "sha256": "\(packSHA256)",
              "freshness_status": "current",
              "publicReferenceOnly": true
            }
            """.utf8
        )
    }

    static func publishedDomainPackData(packID: String) -> Data {
        Data(
            """
            {
              "kind": "ambitions.sourceAtlas.domainPack.v1",
              "schema_version": "1.0.0",
              "pack_id": "\(packID)",
              "frontier_id": "public_civic_requirements",
              "created_at": "2026-06-27T00:00:00Z",
              "publicReferenceOnly": true,
              "sources": [],
              "claims": []
            }
            """.utf8
        )
    }

    static func nativePack(id: String) -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: id,
                title: "Public Civic Reference",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "public_civic_requirements"
            ),
            sources: [
                SourceAtlasSourceRecord(
                    id: "source.official",
                    title: "Official civic source",
                    kind: .official,
                    locator: "https://example.test/civic",
                    approvedForOfficialClaims: true
                )
            ],
            claims: [
                SourceAtlasClaim(
                    id: "claim.current",
                    text: "Public civic reference is available.",
                    state: .official,
                    freshness: .current,
                    riskClass: .legalCivic,
                    sourceIDs: ["source.official"],
                    reviewRequired: true
                )
            ],
            requirements: [
                SourceAtlasRequirement(
                    id: "requirement.current",
                    claimID: "claim.current",
                    title: "Use public civic reference",
                    kind: .hard,
                    required: true,
                    sourceState: .officialCurrent,
                    freshnessState: .current,
                    riskState: .low,
                    reviewState: .required
                )
            ],
            starterItems: [],
            proofMap: [],
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection.current",
                    goalIntent: "public_civic_requirements",
                    requiredPackIDs: [id]
                )
            ],
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

    static func payload(
        for pack: SourceAtlasPack,
        source: SourceAtlasStorePayloadSource
    ) throws -> SourceAtlasStorePayload {
        let data = try encoded(pack)
        return SourceAtlasStorePayload(
            source: source,
            data: data,
            declaredSHA256: SourceAtlasStore.sha256Hex(for: data)
        )
    }

    static func encoded<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }
}
