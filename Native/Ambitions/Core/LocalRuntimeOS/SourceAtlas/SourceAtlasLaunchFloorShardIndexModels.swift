import Foundation

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
