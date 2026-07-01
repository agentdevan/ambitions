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

struct SourceAtlasLaunchFloorShardValidator: Sendable, Equatable, Hashable {
    func validate(manifest: SourceAtlasLaunchFloorShardCorpusManifest) -> [SourceAtlasLaunchFloorShardIssue] {
        var issues: Set<SourceAtlasLaunchFloorShardIssue> = []
        if manifest.schemaVersion != 1 {
            issues.insert(.unsupportedSchema)
        }
        if manifest.kind != "ambitions.sourceAtlas.launchFloorShardCorpusManifest.v1" {
            issues.insert(.unsupportedKind)
        }
        if manifest.publicReferenceOnly == false {
            issues.insert(.notPublicReference)
        }
        if manifest.privateContextAllowed {
            issues.insert(.privateContextAllowed)
        }
        if manifest.finalOutputAllowed {
            issues.insert(.finalOutputAllowed)
        }
        if manifest.nonClaims.contains(where: { $0.localizedCaseInsensitiveContains("not final user plans") }) == false {
            issues.insert(.missingRequiredNonClaim)
        }
        if manifest.partitions.isEmpty {
            issues.insert(.missingPartition)
        }

        var seenPartitionIDs: Set<String> = []
        for partition in manifest.partitions {
            if seenPartitionIDs.insert(partition.partitionID).inserted == false {
                issues.insert(.duplicatePartitionID)
            }
            issues.formUnion(validate(partition: partition))
        }
        return SourceAtlasLaunchFloorShardIssue.allCases.filter { issues.contains($0) }
    }

    func validate(inventory: SourceAtlasLaunchFloorR2LayoutInventory) -> [SourceAtlasLaunchFloorShardIssue] {
        var issues: Set<SourceAtlasLaunchFloorShardIssue> = []
        if inventory.schemaVersion != 1 {
            issues.insert(.unsupportedSchema)
        }
        if inventory.kind != "ambitions.sourceAtlas.launchFloorR2LayoutInventory.v1" {
            issues.insert(.unsupportedKind)
        }
        if inventory.publicReferenceOnly == false {
            issues.insert(.notPublicReference)
        }
        for object in inventory.objects {
            if object.publicReferenceOnly == false {
                issues.insert(.notPublicReference)
            }
            if object.privateContextAllowed {
                issues.insert(.privateContextAllowed)
            }
            if object.finalOutputAllowed {
                issues.insert(.finalOutputAllowed)
            }
            if SourceAtlasPublishedCurrentPointerValidator.isSHA256Hex(object.expectedSHA256) == false {
                issues.insert(.invalidSHA256)
            }
            if SourceAtlasNoPrivateGraphEgressAudit.validate([
                SourceAtlasNoPrivateGraphEgressRecord(
                    surface: .objectKey,
                    identifier: "source-atlas-launch-floor-inventory-object-key",
                    inspectedValue: object.objectKey
                )
            ]).isEmpty == false {
                issues.insert(.privateObjectKey)
            }
        }
        return SourceAtlasLaunchFloorShardIssue.allCases.filter { issues.contains($0) }
    }

    func validate(partition: SourceAtlasLaunchFloorShardPartition) -> [SourceAtlasLaunchFloorShardIssue] {
        var issues: Set<SourceAtlasLaunchFloorShardIssue> = []
        if partition.partitionID.isEmpty || partition.domainID.isEmpty || partition.subdomainID.isEmpty {
            issues.insert(.missingPartitionIdentity)
        }
        if partition.countsTowardLaunchFloor == false {
            issues.insert(.launchFloorExcludedPartition)
        }
        if partition.publicReferenceOnly == false {
            issues.insert(.notPublicReference)
        }
        if partition.privateContextAllowed {
            issues.insert(.privateContextAllowed)
        }
        if partition.finalOutputAllowed {
            issues.insert(.finalOutputAllowed)
        }
        if partition.shardCount <= 0 {
            issues.insert(.invalidShardCount)
        }
        if partition.shardRangeEndInclusive < partition.shardRangeStart ||
            partition.shardRangeEndInclusive - partition.shardRangeStart + 1 != partition.shardCount {
            issues.insert(.invalidShardRange)
        }
        if SourceAtlasPublishedCurrentPointerValidator.isSHA256Hex(partition.indexSHA256) == false ||
            SourceAtlasPublishedCurrentPointerValidator.isSHA256Hex(partition.manifestSHA256) == false {
            issues.insert(.invalidSHA256)
        }
        if partition.sourceLane.profileIDs.isEmpty || partition.sourceLane.registryIDs.isEmpty {
            issues.insert(.missingSourceLane)
        }
        if partition.nativeCompatibility.partitionedShardIndexV1 == false ||
            partition.nativeCompatibility.privateContextAllowed {
            issues.insert(.missingNativeCompatibility)
        }
        if partition.nativeCompatibility.requestShape != "public_ids_hashes_only" {
            issues.insert(.unsupportedNativeRequestShape)
        }
        if partition.readbackProof.checksumVerified == false ||
            partition.readbackProof.gatewayAllowlistVerified == false ||
            partition.readbackProof.rollbackVerified == false {
            issues.insert(.unverifiedReadbackProof)
        }

        for role in SourceAtlasLaunchFloorShardObjectRole.allCases {
            let request = partition.objectDescriptor(role: role)
            let requestIssues = validate(request: request)
            if requestIssues.contains(.missingObjectKey) {
                issues.insert(.missingR2Layout)
            }
            issues.formUnion(requestIssues)
        }
        return SourceAtlasLaunchFloorShardIssue.allCases.filter { issues.contains($0) }
    }

    func validate(request: SourceAtlasLaunchFloorShardObjectRequest) -> [SourceAtlasLaunchFloorShardIssue] {
        var issues: Set<SourceAtlasLaunchFloorShardIssue> = []
        if request.objectKey.isEmpty {
            issues.insert(.missingObjectKey)
        }
        if let expectedSHA256 = request.expectedSHA256,
           SourceAtlasPublishedCurrentPointerValidator.isSHA256Hex(expectedSHA256) == false {
            issues.insert(.invalidSHA256)
        }
        if request.shardCount <= 0 {
            issues.insert(.invalidShardCount)
        }
        if request.shardRangeEndInclusive < request.shardRangeStart ||
            request.shardRangeEndInclusive - request.shardRangeStart + 1 != request.shardCount {
            issues.insert(.invalidShardRange)
        }
        if SourceAtlasNoPrivateGraphEgressAudit.validate([
            request.objectKeyEgressRecord,
            request.requestShapeEgressRecord,
        ]).isEmpty == false {
            issues.insert(.privateObjectKey)
        }
        return SourceAtlasLaunchFloorShardIssue.allCases.filter { issues.contains($0) }
    }
}

extension SourceAtlasPublishedPackSchemaDecoder {
    func launchFloorShardCorpusManifest(from data: Data) throws -> SourceAtlasLaunchFloorShardCorpusManifest {
        let manifest: SourceAtlasLaunchFloorShardCorpusManifest
        do {
            manifest = try JSONDecoder().decode(SourceAtlasLaunchFloorShardCorpusManifest.self, from: data)
        } catch {
            throw SourceAtlasPublishedPackSchemaIssue.manifestDecodeFailed
        }
        guard manifest.validationIssues.isEmpty else {
            throw SourceAtlasPublishedPackSchemaIssue.notPublicReference
        }
        return manifest
    }

    func launchFloorR2LayoutInventory(from data: Data) throws -> SourceAtlasLaunchFloorR2LayoutInventory {
        let inventory: SourceAtlasLaunchFloorR2LayoutInventory
        do {
            inventory = try JSONDecoder().decode(SourceAtlasLaunchFloorR2LayoutInventory.self, from: data)
        } catch {
            throw SourceAtlasPublishedPackSchemaIssue.manifestDecodeFailed
        }
        guard inventory.validationIssues.isEmpty else {
            throw SourceAtlasPublishedPackSchemaIssue.notPublicReference
        }
        return inventory
    }
}

extension PublicPackRequestCompiler {
    func compileLaunchFloorShardIndexRequests(
        manifest: SourceAtlasLaunchFloorShardCorpusManifest,
        inventory: SourceAtlasLaunchFloorR2LayoutInventory? = nil,
        partitionIDs: Set<String>? = nil,
        channel: String,
        appVersion: String,
        accessDecision: SourceAtlasAccessDecision,
        policy: SourceAtlasLaunchFloorShardRequestPolicy = SourceAtlasLaunchFloorShardRequestPolicy(),
        publicLocale: String? = nil
    ) -> SourceAtlasLaunchFloorShardRequestCompilation {
        let selectedPartitions = manifest.countedPartitions.filter { partition in
            partitionIDs.map { $0.contains(partition.partitionID) } ?? true
        }
        let manifestRequest = SourceAtlasPublicManifestRequest(
            domainID: "source_atlas_launch_floor_partition_index",
            channel: channel,
            schemaVersion: String(manifest.schemaVersion),
            appVersion: appVersion,
            routePath: "/source-atlas/public/launch-floor/shard-index",
            publicLocale: publicLocale
        )

        var manifestIssues = manifest.validationIssues
        if let inventory {
            manifestIssues.append(contentsOf: inventory.validationIssues)
        }
        if selectedPartitions.isEmpty {
            manifestIssues.append(.missingPartition)
        }

        let plans = selectedPartitions.map { partition in
            partitionPlan(
                partition: partition,
                inventory: inventory,
                policy: policy
            )
        }
        let requestIssues = SourceAtlasLaunchFloorShardIssue.allCases.filter { issue in
            plans.contains { $0.issues.contains(issue) } ||
                plans.flatMap(\.objectRequests).contains { $0.validationIssues.contains(issue) }
        }
        let records = plans
            .flatMap(\.objectRequests)
            .flatMap { [$0.objectKeyEgressRecord, $0.requestShapeEgressRecord] }
        let verdict = PublicOnlyFirewall().validate(
            manifestRequest: manifestRequest,
            packRequest: nil,
            accessDecision: accessDecision,
            additionalRecords: records
        )
        let firewallIssues: [SourceAtlasLaunchFloorShardIssue] = verdict.isAllowed ? [] : [.firewallRejected]
        let egressFindings = SourceAtlasNoPrivateGraphEgressAudit.validate(records + [manifestRequest.egressRecord])

        return SourceAtlasLaunchFloorShardRequestCompilation(
            manifestRequest: manifestRequest,
            partitionPlans: plans,
            firewallVerdict: verdict,
            manifestIssues: SourceAtlasLaunchFloorShardIssue.allCases.filter { Set(manifestIssues).contains($0) },
            requestIssues: SourceAtlasLaunchFloorShardIssue.allCases.filter { Set(requestIssues + firewallIssues).contains($0) },
            egressFindings: egressFindings
        )
    }

    private func partitionPlan(
        partition: SourceAtlasLaunchFloorShardPartition,
        inventory: SourceAtlasLaunchFloorR2LayoutInventory?,
        policy: SourceAtlasLaunchFloorShardRequestPolicy
    ) -> SourceAtlasLaunchFloorShardPartitionRequestPlan {
        if policy.revokedPartitionIDs.contains(partition.partitionID) {
            let request = partition.objectDescriptor(role: .revocationManifest, inventory: inventory)
            return SourceAtlasLaunchFloorShardPartitionRequestPlan(
                partitionID: partition.partitionID,
                route: .quarantinedRevoked,
                objectRequests: request.validationIssues.isEmpty ? [request] : [],
                issues: request.validationIssues + [.revokedPartition]
            )
        }

        if policy.missingPartitionIDs.contains(partition.partitionID) ||
            policy.stalePartitionIDs.contains(partition.partitionID) {
            guard policy.lastKnownGoodAvailablePartitionIDs.contains(partition.partitionID) else {
                return SourceAtlasLaunchFloorShardPartitionRequestPlan(
                    partitionID: partition.partitionID,
                    route: .unavailable,
                    objectRequests: [],
                    issues: [
                        policy.missingPartitionIDs.contains(partition.partitionID) ? .missingPartitionNeedsLastKnownGood : nil,
                        policy.stalePartitionIDs.contains(partition.partitionID) ? .stalePartitionNeedsLastKnownGood : nil,
                    ].compactMap { $0 }
                )
            }
            let request = partition.objectDescriptor(role: .lastKnownGood, inventory: inventory)
            return SourceAtlasLaunchFloorShardPartitionRequestPlan(
                partitionID: partition.partitionID,
                route: .usingLastKnownGood,
                objectRequests: request.validationIssues.isEmpty ? [request] : [],
                issues: request.validationIssues
            )
        }

        let requests = policy.requestedObjectRoles.map { partition.objectDescriptor(role: $0, inventory: inventory) }
        let requestIssues = SourceAtlasLaunchFloorShardIssue.allCases.filter { issue in
            requests.contains { $0.validationIssues.contains(issue) } ||
                requests.contains { inventoryIssues(partition: partition, request: $0, inventory: inventory).contains(issue) }
        }
        return SourceAtlasLaunchFloorShardPartitionRequestPlan(
            partitionID: partition.partitionID,
            route: .current,
            objectRequests: requests.filter { $0.validationIssues.isEmpty },
            issues: requestIssues
        )
    }

    private func inventoryIssues(
        partition: SourceAtlasLaunchFloorShardPartition,
        request: SourceAtlasLaunchFloorShardObjectRequest,
        inventory: SourceAtlasLaunchFloorR2LayoutInventory?
    ) -> [SourceAtlasLaunchFloorShardIssue] {
        guard let inventory else {
            return []
        }
        guard let object = inventory.object(partitionID: partition.partitionID, role: request.role) else {
            return [.objectMissingFromInventory]
        }
        if object.objectKey != request.objectKey ||
            object.domainID != request.domainID ||
            object.subdomainID != request.subdomainID ||
            object.shardRangeStart != request.shardRangeStart ||
            object.shardRangeEndInclusive != request.shardRangeEndInclusive ||
            object.shardCount != request.shardCount {
            return [.inventoryMismatch]
        }
        if let expectedSHA256 = request.expectedSHA256,
           object.expectedSHA256.lowercased() != expectedSHA256.lowercased() {
            return [.inventoryMismatch]
        }
        return []
    }
}
