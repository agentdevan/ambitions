@testable import Ambitions
import XCTest

final class SourceAtlasPackageManagerLeafTests: XCTestCase {
    func testCompilerFirewallAndR2GatewayPermitOnlyPublicReferenceRequests() throws {
        let pack = Self.pack()
        let payload = try Self.payload(for: pack, source: .cached)
        let entry = SourceAtlasFreshnessPackEntry(
            packID: pack.id,
            currentSHA256: payload.declaredSHA256,
            currentSignature: "sha256:\(payload.declaredSHA256)"
        )
        let manifest = Self.manifest(entry: entry)
        let accessDecision = SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                networkReachability: .online,
                cachedPublicArtifactAvailable: true
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

        XCTAssertTrue(compilation.canFetchRemotePublicReference)
        XCTAssertEqual(compilation.firewallVerdict.issues, [])
        XCTAssertEqual(compilation.firewallVerdict.egressFindings, [])
        XCTAssertEqual(compilation.packRequest?.packID, pack.id)

        let gateway = R2GatewayClient(baseURL: URL(string: "https://r2.example.test/source-atlas")!)
        let compiled = try gateway.compile(
            kind: .pack,
            objectKey: "source-atlas/v1/domain/sports/pack.json",
            manifestRequest: compilation.manifestRequest,
            packRequest: compilation.packRequest,
            accessDecision: accessDecision
        )
        let request = gateway.urlRequest(for: compiled)

        XCTAssertEqual(compiled.kind, .pack)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Ambitions-Data-Class"), "public-reference")
        XCTAssertTrue(compiled.url.absoluteString.contains("source-atlas/v1/domain/sports/pack.json"))
        XCTAssertTrue(compiled.queryItems.keys.contains("pack_id"))
        XCTAssertNil(request.httpBody)

        let logRecord = SourceAtlasPublicArtifactLogRecord(
            event: "source_atlas_r2_public_get_compiled",
            packID: pack.id,
            manifestVersionID: try XCTUnwrap(compilation.packRequest?.manifestVersionID),
            sourceState: .officialCurrent,
            freshnessState: .current,
            selectedSource: .cached
        )
        let requestRecords = [
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .requestShape,
                identifier: "r2-compiled-url",
                inspectedValue: compiled.url.absoluteString
            ),
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .requestShape,
                identifier: "r2-compiled-query",
                inspectedValue: Self.serialized(compiled.queryItems)
            ),
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .requestShape,
                identifier: "r2-url-request-headers",
                inspectedValue: Self.serialized(request.allHTTPHeaderFields ?? [:])
            ),
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .logLine,
                identifier: "r2-public-get-log",
                inspectedValue: logRecord.line
            ),
        ]

        XCTAssertEqual(SourceAtlasNoPrivateGraphEgressAudit.validate(requestRecords), [])
    }

    func testFirewallAndR2GatewayRejectPrivateGraphRequestShapes() throws {
        let accessDecision = SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                networkReachability: .online
            )
        )
        let manifestRequest = SourceAtlasPublicManifestRequest(
            domainID: "sports",
            channel: "stable",
            schemaVersion: "1",
            appVersion: "1.0.0"
        )
        let unsafePackRequest = SourceAtlasPublicPackRequest(
            packID: "sports",
            manifestVersionID: "manifest.v1",
            declaredSHA256: String(repeating: "a", count: 64),
            queryItems: [
                "behavior_history": "opened every night",
                "capture_id": "capture-1",
                "capture_text": "private",
                "goal_id": "goal-1",
                "goal_text": "private",
                "personalization_signal": "protect mornings",
                "private_life_graph": "node-1",
                "proof_payload": "photo",
                "receipt_payload": "receipt",
                "schedule_assumption": "Friday night",
                "account_secret": "secret",
            ]
        )

        let verdict = PublicOnlyFirewall().validate(
            manifestRequest: manifestRequest,
            packRequest: unsafePackRequest,
            accessDecision: accessDecision
        )

        XCTAssertFalse(verdict.isAllowed)
        XCTAssertTrue(verdict.issues.contains(.unsafePackRequest))
        XCTAssertTrue(verdict.egressFindings.contains { $0.forbiddenToken == "behavior_history" })
        XCTAssertTrue(verdict.egressFindings.contains { $0.forbiddenToken == "capture_id" })
        XCTAssertTrue(verdict.egressFindings.contains { $0.forbiddenToken == "capture_text" })
        XCTAssertTrue(verdict.egressFindings.contains { $0.forbiddenToken == "goal_id" })
        XCTAssertTrue(verdict.egressFindings.contains { $0.forbiddenToken == "goal_text" })
        XCTAssertTrue(verdict.egressFindings.contains { $0.forbiddenToken == "personalization" })
        XCTAssertTrue(verdict.egressFindings.contains { $0.forbiddenToken == "private_life_graph" })
        XCTAssertTrue(verdict.egressFindings.contains { $0.forbiddenToken == "proof_payload" })
        XCTAssertTrue(verdict.egressFindings.contains { $0.forbiddenToken == "receipt_payload" })
        XCTAssertTrue(verdict.egressFindings.contains { $0.forbiddenToken == "schedule_assumption" })
        XCTAssertThrowsError(
            try R2GatewayClient(baseURL: URL(string: "https://r2.example.test")!).compile(
                kind: .pack,
                objectKey: "source-atlas/v1/domain/sports/private_graph.json",
                manifestRequest: manifestRequest,
                packRequest: unsafePackRequest,
                accessDecision: accessDecision
            )
        ) { error in
            XCTAssertEqual(error as? R2GatewayClientIssue, .privateObjectKey)
        }
    }

    func testManifestSignatureFreshnessLastKnownGoodCacheAndProjectionFlow() throws {
        let pack = Self.pack()
        let payload = try Self.payload(for: pack, source: .cached)
        let manifestData = Data("manifest-public-sports".utf8)
        let manifestHash = SourceAtlasStore.sha256Hex(for: manifestData)
        let entry = SourceAtlasFreshnessPackEntry(
            packID: pack.id,
            currentSHA256: payload.declaredSHA256,
            currentSignature: "sha256:\(manifestHash)",
            rollbackPointers: ["last_known_good": payload.declaredSHA256]
        )
        let manifest = Self.manifest(entry: entry)

        let verification = ManifestVerifier().verify(
            manifest: manifest,
            packID: pack.id,
            expectedVersionID: "manifest.v1",
            manifestData: manifestData,
            expectedManifestSHA256: manifestHash,
            checkedAt: Self.checkedAt
        )
        let freshness = FreshnessEngine().evaluate(
            manifest: manifest,
            packID: pack.id,
            checkedAt: Self.checkedAt
        )
        let lastKnownGood = LastKnownGoodStore().select(entry: entry, payload: payload)

        XCTAssertTrue(verification.isVerified)
        XCTAssertEqual(verification.issues, [])
        XCTAssertEqual(freshness.status, .current)
        XCTAssertFalse(freshness.blocksCurrentUse)
        XCTAssertTrue(lastKnownGood.canUse)

        let accessDecision = SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                networkReachability: .online,
                cachedPublicArtifactAvailable: true,
                lastKnownGoodAvailable: true
            )
        )
        let compilation = PublicPackRequestCompiler().compile(
            manifest: manifest,
            packID: pack.id,
            channel: "stable",
            appVersion: "1.0.0",
            accessDecision: accessDecision
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
        let projection = SourceAtlasProjection().materialize(
            compilation: compilation,
            cacheResolution: cacheResolution
        )

        XCTAssertTrue(cacheResolution.canSupportCurrentUse)
        XCTAssertEqual(cacheResolution.selectedPack?.id, pack.id)
        XCTAssertEqual(projection.status, .available)
        XCTAssertEqual(projection.freshnessStatus, .current)
        XCTAssertFalse(projection.blocksCurrentUse)
        XCTAssertEqual(projection.selectedSource, .cached)
    }
}

private extension SourceAtlasPackageManagerLeafTests {
    static let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)

    static func serialized(_ values: [String: String]) -> String {
        values
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
    }

    static func manifest(
        entry: SourceAtlasFreshnessPackEntry,
        publishedAt: Date = Date(timeIntervalSince1970: 1_780_000_000)
    ) -> SourceAtlasFreshnessManifest {
        SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: "manifest.v1",
            publishedAt: publishedAt,
            packIndex: [entry]
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

    static func encoded(_ pack: SourceAtlasPack) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(pack)
    }

    static func pack(manifestID: String = "source-atlas/v1/domain/sports") -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: manifestID,
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
                    retrievedAt: "2026-06-01T12:00:00Z",
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
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter.current",
                    title: "Review public rule",
                    stepCandidateSeed: "Review the public rule.",
                    storesFinalSchedule: false
                )
            ],
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
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection.current",
                    goalIntent: "starter_goal",
                    requiredPackIDs: [manifestID],
                    projectionProfiles: []
                )
            ],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Context needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Planning support only."
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
