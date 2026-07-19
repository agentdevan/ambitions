@testable import Ambitions
import XCTest

final class SourceAtlasLaunchFloorShardIndexCompatibilityTests: XCTestCase {
    func testDecodesCurrentLaunchFloorShardCorpusAndR2InventoryAsPublicReferencePartitionIndex() throws {
        let manifest = try Self.currentManifest()
        let inventory = try Self.currentInventory()

        XCTAssertEqual(manifest.validationIssues, [])
        XCTAssertEqual(inventory.validationIssues, [])
        XCTAssertEqual(manifest.countedPartitions.count, 14)
        XCTAssertEqual(manifest.publicReferenceShardCount, 71)
        XCTAssertEqual(inventory.recordCounts["objects"], 126)
        XCTAssertTrue(manifest.countedPartitions.allSatisfy(\.nativeCompatibility.partitionedShardIndexV1))
        XCTAssertTrue(manifest.countedPartitions.allSatisfy { $0.nativeCompatibility.requestShape == "public_ids_hashes_only" })

        let first = try XCTUnwrap(manifest.countedPartitions.first)
        let indexRequest = first.objectDescriptor(role: .partitionIndex, inventory: inventory)
        let manifestRequest = first.objectDescriptor(role: .partitionManifest, inventory: inventory)

        XCTAssertEqual(indexRequest.validationIssues, [])
        XCTAssertEqual(manifestRequest.validationIssues, [])
        XCTAssertEqual(indexRequest.expectedSHA256, first.indexSHA256)
        XCTAssertEqual(manifestRequest.expectedSHA256, first.manifestSHA256)
        XCTAssertEqual(indexRequest.shardCount, first.shardCount)
        XCTAssertEqual(indexRequest.shardRangeEndInclusive - indexRequest.shardRangeStart + 1, first.shardCount)
    }

    func testRequestCompilerAndR2GatewayUseOnlyPublicIDsHashesAndObjectKeys() throws {
        let manifest = try Self.currentManifest()
        let inventory = try Self.currentInventory()
        let first = try XCTUnwrap(manifest.countedPartitions.first)
        let access = Self.remotePublicAccess()

        let compilation = PublicPackRequestCompiler().compileLaunchFloorShardIndexRequests(
            manifest: manifest,
            inventory: inventory,
            partitionIDs: [first.partitionID],
            channel: "stable",
            appVersion: "1.0.0",
            accessDecision: access,
            publicLocale: "en-US"
        )

        XCTAssertTrue(compilation.canFetchRemotePublicReference)
        XCTAssertEqual(compilation.issues, [])
        XCTAssertEqual(compilation.egressFindings, [])
        XCTAssertEqual(
            compilation.objectRequests.map(\.role),
            [.currentPointer, .partitionManifest, .partitionIndex]
        )

        let indexRequest = try XCTUnwrap(compilation.objectRequests.first { $0.role == .partitionIndex })
        let gateway = R2GatewayClient(baseURL: URL(string: "https://r2.example.test/source-atlas")!)
        let compiled = try gateway.compile(
            objectRequest: indexRequest,
            manifestRequest: compilation.manifestRequest,
            accessDecision: access
        )
        let urlRequest = gateway.urlRequest(for: compiled)

        XCTAssertEqual(compiled.kind, .partitionIndex)
        XCTAssertEqual(compiled.objectKey, first.indexObjectKey)
        XCTAssertEqual(compiled.queryItems["partition_id"], first.partitionID)
        XCTAssertEqual(compiled.queryItems["expected_sha256"], first.indexSHA256)
        XCTAssertEqual(compiled.queryItems["object_role"], "partition_index")
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-Ambitions-Data-Class"), "public-reference")
        XCTAssertEqual(compiled.firewallVerdict.egressFindings, [])
        XCTAssertFalse(compiled.queryItems.keys.contains("goal_text"))
        XCTAssertFalse(compiled.queryItems.keys.contains("account_id"))
        XCTAssertFalse(compiled.queryItems.keys.contains("device_id"))
    }

    func testPrivatePartitionObjectKeyFailsClosedBeforeR2GatewayCompilation() throws {
        let data = try Self.currentManifestData()
        let original = try Self.currentManifest().countedPartitions[0].indexObjectKey
        let unsafeData = Data(
            String(decoding: data, as: UTF8.self)
                .replacingOccurrences(
                    of: original,
                    with: "source-atlas/public-reference/corpus/user_id/private-goal/index-v1.json"
                )
                .utf8
        )
        let unsafeManifest = try JSONDecoder().decode(SourceAtlasLaunchFloorShardCorpusManifest.self, from: unsafeData)

        XCTAssertTrue(unsafeManifest.validationIssues.contains(.privateObjectKey))
        XCTAssertThrowsError(
            try SourceAtlasPublishedPackSchemaDecoder().launchFloorShardCorpusManifest(from: unsafeData)
        ) { error in
            XCTAssertEqual(error as? SourceAtlasPublishedPackSchemaIssue, .notPublicReference)
        }

        let request = SourceAtlasLaunchFloorShardObjectRequest(
            partitionID: "lfsc-test",
            domainID: "public_civic_requirements",
            subdomainID: "public_civic_requirements__costs_fees_and_funding",
            role: .partitionIndex,
            objectKey: "source-atlas/public-reference/corpus/user_id/private-goal/index-v1.json",
            expectedSHA256: String(repeating: "a", count: 64),
            shardRangeStart: 0,
            shardRangeEndInclusive: 0,
            shardCount: 1
        )
        XCTAssertTrue(request.validationIssues.contains(.privateObjectKey))
        XCTAssertThrowsError(
            try R2GatewayClient(baseURL: URL(string: "https://r2.example.test")!).compile(
                objectRequest: request,
                manifestRequest: SourceAtlasPublicManifestRequest(
                    domainID: "source_atlas_launch_floor_partition_index",
                    channel: "stable",
                    schemaVersion: "1",
                    appVersion: "1.0.0"
                ),
                accessDecision: Self.remotePublicAccess()
            )
        ) { error in
            XCTAssertEqual(error as? R2GatewayClientIssue, .privateObjectKey)
        }
    }

    func testMissingStaleAndRevokedPartitionsUseFallbackOrQuarantineWithoutBlockingLocalPlanning() throws {
        let manifest = try Self.currentManifest()
        let inventory = try Self.currentInventory()
        let partitions = Array(manifest.countedPartitions.prefix(3))
        XCTAssertEqual(partitions.count, 3)
        let missing = partitions[0]
        let stale = partitions[1]
        let revoked = partitions[2]
        let access = Self.remotePublicAccess(lastKnownGoodAvailable: true)

        let compilation = PublicPackRequestCompiler().compileLaunchFloorShardIndexRequests(
            manifest: manifest,
            inventory: inventory,
            partitionIDs: Set(partitions.map(\.partitionID)),
            channel: "stable",
            appVersion: "1.0.0",
            accessDecision: access,
            policy: SourceAtlasLaunchFloorShardRequestPolicy(
                missingPartitionIDs: [missing.partitionID],
                stalePartitionIDs: [stale.partitionID],
                revokedPartitionIDs: [revoked.partitionID],
                lastKnownGoodAvailablePartitionIDs: [missing.partitionID, stale.partitionID]
            )
        )

        let plansByID = Dictionary(uniqueKeysWithValues: compilation.partitionPlans.map { ($0.partitionID, $0) })
        XCTAssertEqual(plansByID[missing.partitionID]?.route, .usingLastKnownGood)
        XCTAssertEqual(plansByID[missing.partitionID]?.objectRequests.map(\.role), [.lastKnownGood])
        XCTAssertEqual(plansByID[stale.partitionID]?.route, .usingLastKnownGood)
        XCTAssertEqual(plansByID[stale.partitionID]?.objectRequests.map(\.role), [.lastKnownGood])
        XCTAssertEqual(plansByID[revoked.partitionID]?.route, .quarantinedRevoked)
        XCTAssertEqual(plansByID[revoked.partitionID]?.objectRequests.map(\.role), [.revocationManifest])
        XCTAssertFalse(compilation.objectRequests.contains { $0.partitionID == revoked.partitionID && $0.role == .partitionIndex })
        XCTAssertEqual(compilation.egressFindings, [])
        XCTAssertFalse(access.coreLocalPlanningBlocked)
    }

    func testLargeLaunchFloorShardIndexPerformanceEnvelopeUsesBoundedPublicRequests() throws {
        let launchFloorPartitionCount = 5_000
        let shardsPerPartition = 200
        let maximumMobilePartitionFetchWindow = 64
        let maximumMobileObjectRequestsPerRefresh = maximumMobilePartitionFetchWindow * 3
        let manifest = Self.syntheticLaunchFloorManifest(
            partitionCount: launchFloorPartitionCount,
            shardsPerPartition: shardsPerPartition
        )
        let selectedPartitionIDs = Set(
            manifest.countedPartitions
                .prefix(maximumMobilePartitionFetchWindow)
                .map(\.partitionID)
        )

        XCTAssertEqual(manifest.validationIssues, [])
        XCTAssertEqual(manifest.countedPartitions.count, launchFloorPartitionCount)
        XCTAssertEqual(manifest.publicReferenceShardCount, 1_000_000)

        let compilation = PublicPackRequestCompiler().compileLaunchFloorShardIndexRequests(
            manifest: manifest,
            partitionIDs: selectedPartitionIDs,
            channel: "stable",
            appVersion: "1.0.0",
            accessDecision: Self.remotePublicAccess(),
            publicLocale: "en-US"
        )

        XCTAssertTrue(compilation.canFetchRemotePublicReference)
        XCTAssertEqual(compilation.issues, [])
        XCTAssertEqual(compilation.egressFindings, [])
        XCTAssertEqual(compilation.partitionPlans.count, maximumMobilePartitionFetchWindow)
        XCTAssertEqual(Set(compilation.partitionPlans.map(\.partitionID)), selectedPartitionIDs)
        XCTAssertEqual(compilation.objectRequests.count, maximumMobileObjectRequestsPerRefresh)
        XCTAssertEqual(
            Set(compilation.partitionPlans.map(\.route)),
            Set([SourceAtlasLaunchFloorShardPartitionRoute.current])
        )
        XCTAssertEqual(
            Dictionary(grouping: compilation.objectRequests, by: \.role).mapValues(\.count),
            [
                .currentPointer: maximumMobilePartitionFetchWindow,
                .partitionManifest: maximumMobilePartitionFetchWindow,
                .partitionIndex: maximumMobilePartitionFetchWindow,
            ]
        )
        XCTAssertTrue(compilation.objectRequests.allSatisfy { $0.validationIssues.isEmpty })
        XCTAssertTrue(compilation.objectRequests.allSatisfy { $0.queryItems.keys.contains("object_key") })
        XCTAssertTrue(
            compilation.objectRequests
                .filter { $0.role != .currentPointer }
                .allSatisfy { $0.queryItems.keys.contains("expected_sha256") }
        )
        XCTAssertTrue(
            compilation.objectRequests
                .filter { $0.role == .currentPointer }
                .allSatisfy { $0.queryItems.keys.contains("expected_sha256") == false }
        )
        XCTAssertFalse(compilation.objectRequests.contains { request in
            request.requestShapeEgressRecord.inspectedValue.contains("goal_text") ||
                request.requestShapeEgressRecord.inspectedValue.contains("account_id") ||
                request.requestShapeEgressRecord.inspectedValue.contains("device_id")
        })
    }
}

private extension SourceAtlasLaunchFloorShardIndexCompatibilityTests {
    static func currentManifest() throws -> SourceAtlasLaunchFloorShardCorpusManifest {
        try SourceAtlasPublishedPackSchemaDecoder().launchFloorShardCorpusManifest(from: currentManifestData())
    }

    static func currentInventory() throws -> SourceAtlasLaunchFloorR2LayoutInventory {
        try SourceAtlasPublishedPackSchemaDecoder().launchFloorR2LayoutInventory(from: currentInventoryData())
    }

    static func currentManifestData() throws -> Data {
        try Data(contentsOf: repoRoot().appendingPathComponent(
            "tools/source-atlas/generated/source-atlas-launch-floor-shard-corpus-compiler/lff-m02-l02-current/launch-floor-shard-corpus-manifest.json"
        ))
    }

    static func currentInventoryData() throws -> Data {
        try Data(contentsOf: repoRoot().appendingPathComponent(
            "tools/source-atlas/generated/source-atlas-launch-floor-r2-layout-proof/lff-m02-l03-current/r2-layout-inventory.json"
        ))
    }

    static func remotePublicAccess(lastKnownGoodAvailable: Bool = false) -> SourceAtlasAccessDecision {
        SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .online,
                cachedPublicArtifactAvailable: true,
                lastKnownGoodAvailable: lastKnownGoodAvailable,
                bundledPublicArtifactAvailable: false
            )
        )
    }

    static func syntheticLaunchFloorManifest(
        partitionCount: Int,
        shardsPerPartition: Int
    ) -> SourceAtlasLaunchFloorShardCorpusManifest {
        SourceAtlasLaunchFloorShardCorpusManifest(
            createdAt: "2026-07-01T00:00:00Z",
            finalOutputAllowed: false,
            kind: "ambitions.sourceAtlas.launchFloorShardCorpusManifest.v1",
            nonClaims: [
                "not final user plans, schedules, or Steps",
                "public/reference/freshness infrastructure only",
            ],
            partitions: (0..<partitionCount).map { index in
                syntheticPartition(index: index, shardsPerPartition: shardsPerPartition)
            },
            privateContextAllowed: false,
            publicReferenceOnly: true,
            schemaVersion: 1,
            versionID: "synthetic-launch-floor-1m-performance-envelope"
        )
    }

    static func syntheticPartition(
        index: Int,
        shardsPerPartition: Int
    ) -> SourceAtlasLaunchFloorShardPartition {
        let domainIndex = index / 10
        let domainID = "public_domain_\(padded(domainIndex, width: 4))"
        let subdomainID = "\(domainID)__public_subdomain_\(padded(index, width: 5))"
        let partitionID = "lfp_\(padded(index, width: 5))"
        let start = index * shardsPerPartition
        let end = start + shardsPerPartition - 1
        let baseKey = "source-atlas/public-reference/launch-floor/\(domainID)/\(subdomainID)/\(partitionID)"

        return SourceAtlasLaunchFloorShardPartition(
            apiPolicyState: "approved",
            countsTowardLaunchFloor: true,
            domainID: domainID,
            finalOutputAllowed: false,
            freshnessSLA: "P30D",
            indexObjectKey: "\(baseKey)/index-v1.json",
            indexSHA256: hex64(index + 1),
            legalPolicyState: "approved",
            manifestObjectKey: "\(baseKey)/manifest-v1.json",
            manifestSHA256: hex64(index + 10_001),
            nativeCompatibility: SourceAtlasLaunchFloorShardNativeCompatibility(
                partitionedShardIndexV1: true,
                privateContextAllowed: false,
                requestShape: "public_ids_hashes_only"
            ),
            partitionID: partitionID,
            privateContextAllowed: false,
            publicReferenceOnly: true,
            r2Layout: SourceAtlasLaunchFloorShardR2Layout(
                currentPointerKey: "\(baseKey)/current.json",
                gatewayAllowlistKey: "\(baseKey)/gateway-allowlist.json",
                lastKnownGoodKey: "\(baseKey)/lkg.json",
                promotedPrefix: "\(baseKey)/promoted/",
                revocationKey: "\(baseKey)/revocations.json",
                rollbackKey: "\(baseKey)/rollback-plan.json",
                stagedPrefix: "\(baseKey)/staged/"
            ),
            readbackProof: SourceAtlasLaunchFloorShardReadbackProof(
                checksumVerified: true,
                gatewayAllowlistVerified: true,
                rollbackVerified: true
            ),
            revocationState: "current",
            shardCount: shardsPerPartition,
            shardRangeEndInclusive: end,
            shardRangeStart: start,
            sourceLane: SourceAtlasLaunchFloorShardSourceLane(
                profileIDs: ["public-source-profile-\(padded(domainIndex, width: 4))"],
                registryIDs: ["public-source-registry-\(padded(index, width: 5))"]
            ),
            subdomainID: subdomainID
        )
    }

    static func padded(_ value: Int, width: Int) -> String {
        let raw = String(value)
        return String(repeating: "0", count: max(0, width - raw.count)) + raw
    }

    static func hex64(_ value: Int) -> String {
        let raw = String(value, radix: 16)
        return String(repeating: "0", count: max(0, 64 - raw.count)) + raw
    }

    static func repoRoot() -> URL {
        let current = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let candidates = sequence(first: current) { url in
            let parent = url.deletingLastPathComponent()
            return parent.path == url.path ? nil : parent
        }
        for candidate in candidates {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
        }
        return current
    }
}
