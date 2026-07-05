import Foundation

enum SourceAtlasLaunchFloorShardIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case unsupportedKind = "unsupported_kind"
    case notPublicReference = "not_public_reference"
    case privateContextAllowed = "private_context_allowed"
    case finalOutputAllowed = "final_output_allowed"
    case missingRequiredNonClaim = "missing_required_non_claim"
    case missingPartition = "missing_partition"
    case duplicatePartitionID = "duplicate_partition_id"
    case missingPartitionIdentity = "missing_partition_identity"
    case launchFloorExcludedPartition = "launch_floor_excluded_partition"
    case invalidShardRange = "invalid_shard_range"
    case invalidShardCount = "invalid_shard_count"
    case invalidSHA256 = "invalid_sha256"
    case missingSourceLane = "missing_source_lane"
    case missingR2Layout = "missing_r2_layout"
    case missingNativeCompatibility = "missing_native_compatibility"
    case unsupportedNativeRequestShape = "unsupported_native_request_shape"
    case unverifiedReadbackProof = "unverified_readback_proof"
    case missingObjectKey = "missing_object_key"
    case privateObjectKey = "private_object_key"
    case objectMissingFromInventory = "object_missing_from_inventory"
    case inventoryMismatch = "inventory_mismatch"
    case revokedPartition = "revoked_partition"
    case missingPartitionNeedsLastKnownGood = "missing_partition_needs_last_known_good"
    case stalePartitionNeedsLastKnownGood = "stale_partition_needs_last_known_good"
    case firewallRejected = "firewall_rejected"
}

enum SourceAtlasLaunchFloorShardObjectRole: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case currentPointer = "current_pointer"
    case partitionManifest = "partition_manifest"
    case partitionIndex = "partition_index"
    case stagedManifest = "staged_manifest"
    case promotedManifest = "promoted_manifest"
    case revocationManifest = "revocation_manifest"
    case rollbackPlan = "rollback_plan"
    case gatewayAllowlist = "gateway_allowlist"
    case lastKnownGood = "last_known_good"

    var gatewayRequestKind: R2GatewayRequestKind {
        switch self {
        case .currentPointer:
            return .currentPointer
        case .partitionManifest:
            return .partitionManifest
        case .partitionIndex:
            return .partitionIndex
        case .stagedManifest:
            return .stagedManifest
        case .promotedManifest:
            return .promotedManifest
        case .revocationManifest:
            return .revocation
        case .rollbackPlan:
            return .rollback
        case .gatewayAllowlist:
            return .gatewayAllowlist
        case .lastKnownGood:
            return .lastKnownGood
        }
    }
}

enum SourceAtlasLaunchFloorShardPartitionRoute: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case usingLastKnownGood = "using_last_known_good"
    case unavailable
    case quarantinedRevoked = "quarantined_revoked"
}

struct SourceAtlasLaunchFloorShardCorpusManifest: Codable, Sendable, Equatable, Hashable {
    let createdAt: String
    let finalOutputAllowed: Bool
    let kind: String
    let nonClaims: [String]
    let partitions: [SourceAtlasLaunchFloorShardPartition]
    let privateContextAllowed: Bool
    let publicReferenceOnly: Bool
    let schemaVersion: Int
    let versionID: String

    var validationIssues: [SourceAtlasLaunchFloorShardIssue] {
        SourceAtlasLaunchFloorShardValidator().validate(manifest: self)
    }

    var countedPartitions: [SourceAtlasLaunchFloorShardPartition] {
        partitions.filter(\.countsTowardLaunchFloor)
    }

    var publicReferenceShardCount: Int {
        countedPartitions.reduce(0) { $0 + $1.shardCount }
    }

    func partition(id: String) -> SourceAtlasLaunchFloorShardPartition? {
        let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
        return partitions.first { $0.partitionID == trimmed }
    }
}

struct SourceAtlasLaunchFloorShardPartition: Codable, Sendable, Equatable, Hashable {
    let apiPolicyState: String
    let countsTowardLaunchFloor: Bool
    let domainID: String
    let finalOutputAllowed: Bool
    let freshnessSLA: String
    let indexObjectKey: String
    let indexSHA256: String
    let legalPolicyState: String
    let manifestObjectKey: String
    let manifestSHA256: String
    let nativeCompatibility: SourceAtlasLaunchFloorShardNativeCompatibility
    let partitionID: String
    let privateContextAllowed: Bool
    let publicReferenceOnly: Bool
    let r2Layout: SourceAtlasLaunchFloorShardR2Layout
    let readbackProof: SourceAtlasLaunchFloorShardReadbackProof
    let revocationState: String
    let shardCount: Int
    let shardRangeEndInclusive: Int
    let shardRangeStart: Int
    let sourceLane: SourceAtlasLaunchFloorShardSourceLane
    let subdomainID: String

    func objectDescriptor(
        role: SourceAtlasLaunchFloorShardObjectRole,
        inventory: SourceAtlasLaunchFloorR2LayoutInventory? = nil
    ) -> SourceAtlasLaunchFloorShardObjectRequest {
        let inventoryObject = inventory?.object(partitionID: partitionID, role: role)
        let keyAndHash = objectKeyAndHash(role: role, inventoryObject: inventoryObject)
        return SourceAtlasLaunchFloorShardObjectRequest(
            partitionID: partitionID,
            domainID: domainID,
            subdomainID: subdomainID,
            role: role,
            objectKey: keyAndHash.objectKey,
            expectedSHA256: keyAndHash.expectedSHA256,
            expectedBytes: inventoryObject?.expectedBytes,
            shardRangeStart: shardRangeStart,
            shardRangeEndInclusive: shardRangeEndInclusive,
            shardCount: shardCount
        )
    }

    private func objectKeyAndHash(
        role: SourceAtlasLaunchFloorShardObjectRole,
        inventoryObject: SourceAtlasLaunchFloorR2LayoutInventoryObject?
    ) -> (objectKey: String, expectedSHA256: String?) {
        switch role {
        case .currentPointer:
            return (r2Layout.currentPointerKey, inventoryObject?.expectedSHA256)
        case .partitionManifest:
            return (manifestObjectKey, manifestSHA256)
        case .partitionIndex:
            return (indexObjectKey, indexSHA256)
        case .stagedManifest:
            return (r2Layout.stagedPrefix, inventoryObject?.expectedSHA256)
        case .promotedManifest:
            return (r2Layout.promotedPrefix, inventoryObject?.expectedSHA256)
        case .revocationManifest:
            return (r2Layout.revocationKey, inventoryObject?.expectedSHA256)
        case .rollbackPlan:
            return (r2Layout.rollbackKey, inventoryObject?.expectedSHA256)
        case .gatewayAllowlist:
            return (r2Layout.gatewayAllowlistKey, inventoryObject?.expectedSHA256)
        case .lastKnownGood:
            return (r2Layout.lastKnownGoodKey, inventoryObject?.expectedSHA256)
        }
    }
}

struct SourceAtlasLaunchFloorShardNativeCompatibility: Codable, Sendable, Equatable, Hashable {
    let partitionedShardIndexV1: Bool
    let privateContextAllowed: Bool
    let requestShape: String
}

struct SourceAtlasLaunchFloorShardR2Layout: Codable, Sendable, Equatable, Hashable {
    let currentPointerKey: String
    let gatewayAllowlistKey: String
    let lastKnownGoodKey: String
    let promotedPrefix: String
    let revocationKey: String
    let rollbackKey: String
    let stagedPrefix: String
}

struct SourceAtlasLaunchFloorShardReadbackProof: Codable, Sendable, Equatable, Hashable {
    let checksumVerified: Bool
    let gatewayAllowlistVerified: Bool
    let rollbackVerified: Bool
}

struct SourceAtlasLaunchFloorShardSourceLane: Codable, Sendable, Equatable, Hashable {
    let profileIDs: [String]
    let registryIDs: [String]
}

struct SourceAtlasLaunchFloorR2LayoutInventory: Codable, Sendable, Equatable, Hashable {
    let createdAt: String
    let kind: String
    let nonClaims: [String]
    let objects: [SourceAtlasLaunchFloorR2LayoutInventoryObject]
    let publicReferenceOnly: Bool
    let recordCounts: [String: Int]
    let schemaVersion: Int

    var validationIssues: [SourceAtlasLaunchFloorShardIssue] {
        SourceAtlasLaunchFloorShardValidator().validate(inventory: self)
    }

    func object(
        partitionID: String,
        role: SourceAtlasLaunchFloorShardObjectRole
    ) -> SourceAtlasLaunchFloorR2LayoutInventoryObject? {
        objects.first { $0.partitionID == partitionID && $0.objectRole == role }
    }
}

struct SourceAtlasLaunchFloorR2LayoutInventoryObject: Codable, Sendable, Equatable, Hashable {
    let domainID: String
    let expectedBytes: Int
    let expectedSHA256: String
    let finalOutputAllowed: Bool
    let label: String
    let objectKey: String
    let objectRole: SourceAtlasLaunchFloorShardObjectRole
    let partitionID: String
    let privateContextAllowed: Bool
    let publicReferenceOnly: Bool
    let shardCount: Int
    let shardRangeEndInclusive: Int
    let shardRangeStart: Int
    let subdomainID: String
}

struct SourceAtlasLaunchFloorShardObjectRequest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let partitionID: String
    let domainID: String
    let subdomainID: String
    let role: SourceAtlasLaunchFloorShardObjectRole
    let objectKey: String
    let expectedSHA256: String?
    let expectedBytes: Int?
    let shardRangeStart: Int
    let shardRangeEndInclusive: Int
    let shardCount: Int

    init(
        partitionID: String,
        domainID: String,
        subdomainID: String,
        role: SourceAtlasLaunchFloorShardObjectRole,
        objectKey: String,
        expectedSHA256: String? = nil,
        expectedBytes: Int? = nil,
        shardRangeStart: Int,
        shardRangeEndInclusive: Int,
        shardCount: Int
    ) {
        self.partitionID = partitionID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.domainID = domainID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.subdomainID = subdomainID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.role = role
        self.objectKey = objectKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.expectedSHA256 = expectedSHA256?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.expectedBytes = expectedBytes
        self.shardRangeStart = shardRangeStart
        self.shardRangeEndInclusive = shardRangeEndInclusive
        self.shardCount = shardCount
        self.id = "\(role.rawValue):\(self.partitionID):\(self.objectKey)"
    }

    var queryItems: [String: String] {
        var values = [
            "domain_id": domainID,
            "object_key": objectKey,
            "object_role": role.rawValue,
            "partition_id": partitionID,
            "shard_count": String(shardCount),
            "shard_range_end": String(shardRangeEndInclusive),
            "shard_range_start": String(shardRangeStart),
            "subdomain_id": subdomainID,
        ]
        if let expectedSHA256 {
            values["expected_sha256"] = expectedSHA256
        }
        if let expectedBytes {
            values["expected_bytes"] = String(expectedBytes)
        }
        return values
    }

    var validationIssues: [SourceAtlasLaunchFloorShardIssue] {
        SourceAtlasLaunchFloorShardValidator().validate(request: self)
    }

    var objectKeyEgressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .objectKey,
            identifier: "source-atlas-launch-floor-\(role.rawValue)-object-key",
            inspectedValue: objectKey
        )
    }

    var requestShapeEgressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .requestShape,
            identifier: "source-atlas-launch-floor-\(role.rawValue)-request",
            inspectedValue: queryItems
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: " ")
        )
    }
}

struct SourceAtlasLaunchFloorShardRequestPolicy: Codable, Sendable, Equatable, Hashable {
    let requestedObjectRoles: [SourceAtlasLaunchFloorShardObjectRole]
    let missingPartitionIDs: Set<String>
    let stalePartitionIDs: Set<String>
    let revokedPartitionIDs: Set<String>
    let lastKnownGoodAvailablePartitionIDs: Set<String>

    init(
        requestedObjectRoles: [SourceAtlasLaunchFloorShardObjectRole] = [.currentPointer, .partitionManifest, .partitionIndex],
        missingPartitionIDs: Set<String> = [],
        stalePartitionIDs: Set<String> = [],
        revokedPartitionIDs: Set<String> = [],
        lastKnownGoodAvailablePartitionIDs: Set<String> = []
    ) {
        self.requestedObjectRoles = requestedObjectRoles
        self.missingPartitionIDs = missingPartitionIDs
        self.stalePartitionIDs = stalePartitionIDs
        self.revokedPartitionIDs = revokedPartitionIDs
        self.lastKnownGoodAvailablePartitionIDs = lastKnownGoodAvailablePartitionIDs
    }
}

struct SourceAtlasLaunchFloorShardPartitionRequestPlan: Codable, Sendable, Equatable, Hashable {
    let partitionID: String
    let route: SourceAtlasLaunchFloorShardPartitionRoute
    let objectRequests: [SourceAtlasLaunchFloorShardObjectRequest]
    let issues: [SourceAtlasLaunchFloorShardIssue]
}

struct SourceAtlasLaunchFloorShardRequestCompilation: Codable, Sendable, Equatable, Hashable {
    let manifestRequest: SourceAtlasPublicManifestRequest
    let partitionPlans: [SourceAtlasLaunchFloorShardPartitionRequestPlan]
    let firewallVerdict: PublicOnlyFirewallVerdict
    let manifestIssues: [SourceAtlasLaunchFloorShardIssue]
    let requestIssues: [SourceAtlasLaunchFloorShardIssue]
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]

    var objectRequests: [SourceAtlasLaunchFloorShardObjectRequest] {
        partitionPlans.flatMap(\.objectRequests)
    }

    var issues: [SourceAtlasLaunchFloorShardIssue] {
        SourceAtlasLaunchFloorShardIssue.allCases.filter { issue in
            manifestIssues.contains(issue) ||
                requestIssues.contains(issue) ||
                partitionPlans.contains { plan in plan.issues.contains(issue) }
        }
    }

    var canFetchRemotePublicReference: Bool {
        issues.isEmpty && firewallVerdict.isAllowed && egressFindings.isEmpty
    }
}
