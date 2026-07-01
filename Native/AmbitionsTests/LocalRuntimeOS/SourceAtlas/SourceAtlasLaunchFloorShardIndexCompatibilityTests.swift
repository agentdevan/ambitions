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
