import Foundation

enum SourceAtlasPublishedCurrentPointerIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case unsupportedKind = "unsupported_kind"
    case notPublicReference = "not_public_reference"
    case missingPackID = "missing_pack_id"
    case missingManifestKey = "missing_manifest_key"
    case invalidManifestSHA256 = "invalid_manifest_sha256"
    case invalidPackSHA256 = "invalid_pack_sha256"
    case privateObjectKey = "private_object_key"
    case missingRequiredNonClaim = "missing_required_non_claim"
}

struct SourceAtlasPublishedCurrentPointer: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: Int
    let kind: String
    let createdAt: String
    let environment: String
    let channel: String
    let packID: String
    let packVersion: String
    let manifestKey: String
    let manifestSHA256: String
    let packSHA256: String
    let revocationManifestKey: String?
    let lastKnownGoodKey: String?
    let publicReferenceOnly: Bool
    let dataClass: String
    let privacyBoundary: String
    let nonClaims: [String]

    var validationIssues: [SourceAtlasPublishedCurrentPointerIssue] {
        SourceAtlasPublishedCurrentPointerValidator().validate(self)
    }

    var objectKeyEgressRecords: [SourceAtlasNoPrivateGraphEgressRecord] {
        [
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .objectKey,
                identifier: "source-atlas-current-pointer-pack-id",
                inspectedValue: packID
            ),
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .objectKey,
                identifier: "source-atlas-current-pointer-manifest-key",
                inspectedValue: manifestKey
            ),
            revocationManifestKey.map {
                SourceAtlasNoPrivateGraphEgressRecord(
                    surface: .objectKey,
                    identifier: "source-atlas-current-pointer-revocation-key",
                    inspectedValue: $0
                )
            },
            lastKnownGoodKey.map {
                SourceAtlasNoPrivateGraphEgressRecord(
                    surface: .objectKey,
                    identifier: "source-atlas-current-pointer-lkg-key",
                    inspectedValue: $0
                )
            }
        ].compactMap { $0 }
    }
}

struct SourceAtlasPublishedCurrentPointerValidator: Sendable, Equatable, Hashable {
    func validate(_ pointer: SourceAtlasPublishedCurrentPointer) -> [SourceAtlasPublishedCurrentPointerIssue] {
        var issues: Set<SourceAtlasPublishedCurrentPointerIssue> = []

        if pointer.schemaVersion != 1 {
            issues.insert(.unsupportedSchema)
        }
        if pointer.kind != "ambitions.sourceAtlas.currentPackPointer.v1" {
            issues.insert(.unsupportedKind)
        }
        if pointer.publicReferenceOnly == false || pointer.dataClass != "public_freshness" {
            issues.insert(.notPublicReference)
        }
        if pointer.packID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.insert(.missingPackID)
        }
        if pointer.manifestKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.insert(.missingManifestKey)
        }
        if Self.isSHA256Hex(pointer.manifestSHA256) == false {
            issues.insert(.invalidManifestSHA256)
        }
        if Self.isSHA256Hex(pointer.packSHA256) == false {
            issues.insert(.invalidPackSHA256)
        }
        if SourceAtlasNoPrivateGraphEgressAudit.validate(pointer.objectKeyEgressRecords).isEmpty == false {
            issues.insert(.privateObjectKey)
        }
        if pointer.nonClaims.contains(where: { $0.localizedCaseInsensitiveContains("not a final user plan") }) == false {
            issues.insert(.missingRequiredNonClaim)
        }

        return SourceAtlasPublishedCurrentPointerIssue.allCases.filter { issues.contains($0) }
    }

    static func isSHA256Hex(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.count == 64 && trimmed.allSatisfy { character in
            character.isNumber || ("a"..."f").contains(character)
        }
    }
}

enum SourceAtlasPublishedPackSchemaIssue: String, Error, Codable, Sendable, Equatable, Hashable {
    case manifestHashMismatch = "manifest_hash_mismatch"
    case manifestDecodeFailed = "manifest_decode_failed"
    case unsupportedManifestKind = "unsupported_manifest_kind"
    case unsupportedManifestSchema = "unsupported_manifest_schema"
    case manifestPackMismatch = "manifest_pack_mismatch"
    case manifestHashMissing = "manifest_hash_missing"
    case packObjectKeyMissing = "pack_object_key_missing"
    case notPublicReference = "not_public_reference"
}

struct SourceAtlasPublishedPackSchemaDecoder {
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    func freshnessManifest(
        from data: Data,
        pointer: SourceAtlasPublishedCurrentPointer
    ) throws -> SourceAtlasFreshnessManifest {
        guard SourceAtlasStore.sha256Hex(for: data) == pointer.manifestSHA256.lowercased() else {
            throw SourceAtlasPublishedPackSchemaIssue.manifestHashMismatch
        }

        let manifest: PublishedPackManifest
        do {
            manifest = try decoder.decode(PublishedPackManifest.self, from: data)
        } catch {
            throw SourceAtlasPublishedPackSchemaIssue.manifestDecodeFailed
        }

        guard manifest.kind == "ambitions.sourceAtlas.packManifest.v1" else {
            throw SourceAtlasPublishedPackSchemaIssue.unsupportedManifestKind
        }
        guard manifest.schemaVersion == "1.0.0" else {
            throw SourceAtlasPublishedPackSchemaIssue.unsupportedManifestSchema
        }
        guard manifest.publicReferenceOnly else {
            throw SourceAtlasPublishedPackSchemaIssue.notPublicReference
        }
        guard manifest.packID == pointer.packID else {
            throw SourceAtlasPublishedPackSchemaIssue.manifestPackMismatch
        }
        guard manifest.sha256?.lowercased() == pointer.packSHA256.lowercased() else {
            throw SourceAtlasPublishedPackSchemaIssue.manifestHashMissing
        }

        return SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: pointer.manifestKey,
            publishedAt: Self.date(from: manifest.createdAt) ?? Self.date(from: pointer.createdAt) ?? Date(timeIntervalSince1970: 0),
            packIndex: [
                SourceAtlasFreshnessPackEntry(
                    packID: pointer.packID,
                    currentSHA256: pointer.packSHA256,
                    currentSignature: "publisher-pointer:\(pointer.manifestSHA256)",
                    claimStateBuckets: claimStateBuckets(from: manifest.freshnessStatus)
                )
            ]
        )
    }

    func packObjectKey(from data: Data) throws -> String {
        let manifest: PublishedPackManifest
        do {
            manifest = try decoder.decode(PublishedPackManifest.self, from: data)
        } catch {
            throw SourceAtlasPublishedPackSchemaIssue.manifestDecodeFailed
        }

        guard manifest.kind == "ambitions.sourceAtlas.packManifest.v1" else {
            throw SourceAtlasPublishedPackSchemaIssue.unsupportedManifestKind
        }
        guard manifest.schemaVersion == "1.0.0" else {
            throw SourceAtlasPublishedPackSchemaIssue.unsupportedManifestSchema
        }
        guard manifest.publicReferenceOnly else {
            throw SourceAtlasPublishedPackSchemaIssue.notPublicReference
        }
        guard let packObjectKey = manifest.objectKeys?["pack"]?.trimmingCharacters(in: .whitespacesAndNewlines),
              packObjectKey.isEmpty == false
        else {
            throw SourceAtlasPublishedPackSchemaIssue.packObjectKeyMissing
        }
        return packObjectKey
    }

    private func claimStateBuckets(from freshnessStatus: String?) -> [SourceAtlasFreshnessBrokerClaimStateBucket] {
        switch freshnessStatus {
        case "stale", "stale_critical":
            return [SourceAtlasFreshnessBrokerClaimStateBucket(state: .stale, claimIDs: ["source-atlas-pack"])]
        case "revoked":
            return [SourceAtlasFreshnessBrokerClaimStateBucket(state: .revoked, claimIDs: ["source-atlas-pack"])]
        case "contradicted", "conflicted":
            return [SourceAtlasFreshnessBrokerClaimStateBucket(state: .contradicted, claimIDs: ["source-atlas-pack"])]
        default:
            return []
        }
    }

    private static func date(from value: String?) -> Date? {
        guard let value else {
            return nil
        }
        return ISO8601DateFormatter().date(from: value)
    }
}

struct SourceAtlasPublishedDomainPackDecoder {
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    func nativePack(from data: Data) throws -> SourceAtlasPack {
        let published = try decoder.decode(PublishedDomainPack.self, from: data)
        guard published.kind == "ambitions.sourceAtlas.domainPack.v1",
              published.schemaVersion == "1.0.0",
              published.publicReferenceOnly
        else {
            throw SourceAtlasPublishedPackSchemaIssue.notPublicReference
        }

        let domainID = published.frontierID ?? published.claims.first?.domain ?? "public_reference"
        let sources = nativeSources(from: published)
        let claims = nativeClaims(from: published, fallbackSourceIDs: sources.map(\.id), domainID: domainID)
        let requirements = nativeRequirements(from: claims)
        let proofMap = nativeProofMap(from: requirements, claims: claims)

        return SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: published.packID,
                title: title(for: domainID),
                kind: .domainPack,
                version: published.manifest?.packVersion ?? published.createdAt ?? "published",
                domainID: domainID,
                classification: "source_atlas_published_domain_pack",
                productionUse: false
            ),
            sources: sources,
            claims: claims,
            requirements: requirements,
            starterItems: [],
            proofMap: proofMap,
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection.\(domainID)",
                    goalIntent: domainID,
                    requiredPackIDs: [published.packID]
                )
            ],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Public reference source needed.",
                reviewRequired: "This public reference may need confirmation.",
                notProfessionalAdvice: "Public reference only. This is not professional advice or a completed plan."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["published.\(domainID).reference"],
                overlayDependencyIDs: ["published.\(domainID).source"],
                projectionRecipeIDs: ["published.\(domainID).local_reference"],
                ownsIndividualGoalPhrase: false
            )
        )
    }

    private func nativeSources(from published: PublishedDomainPack) -> [SourceAtlasSourceRecord] {
        let claimLocatorsBySource = Dictionary(
            grouping: published.claims,
            by: { $0.sourceID ?? "source.unknown" }
        ).mapValues { claims in
            claims.first(where: { ($0.locator ?? "").isEmpty == false })?.locator
        }

        return published.sources.map { source in
            let sourceID = source.sourceID.trimmingCharacters(in: .whitespacesAndNewlines)
            let locator = claimLocatorsBySource[sourceID].flatMap { $0 } ?? "source-atlas://public-reference/\(sourceID)"
            return SourceAtlasSourceRecord(
                id: sourceID,
                title: source.sourceName,
                kind: sourceKind(authorityClass: source.authorityClass),
                locator: locator,
                retrievedAt: nil,
                contentHash: nil,
                approvedForOfficialClaims: sourceKind(authorityClass: source.authorityClass) == .official &&
                    source.reviewStatus == "reviewed" &&
                    (source.r2PackPolicy ?? "").contains("pack_allowed")
            )
        }.sorted { $0.id < $1.id }
    }

    private func nativeClaims(
        from published: PublishedDomainPack,
        fallbackSourceIDs: [String],
        domainID: String
    ) -> [SourceAtlasClaim] {
        published.claims.map { claim in
            let riskClass = riskClass(domainID: domainID, claimType: claim.claimType)
            let reviewRequired = riskClass.requiresStrictReview || (claim.reviewRequired ?? true)
            return SourceAtlasClaim(
                id: claim.claimID,
                text: claim.objectValue ?? claim.predicate ?? claim.claimType ?? "Public reference claim",
                state: claimState(authorityClass: claim.authorityClass),
                freshness: freshnessState(claim.freshnessStatus),
                riskClass: riskClass,
                sourceIDs: [claim.sourceID].compactMap { $0 }.isEmpty ? fallbackSourceIDs : [claim.sourceID].compactMap { $0 },
                reviewRequired: reviewRequired
            )
        }.sorted { $0.id < $1.id }
    }

    private func nativeRequirements(from claims: [SourceAtlasClaim]) -> [SourceAtlasRequirement] {
        claims.map { claim in
            SourceAtlasRequirement(
                id: "requirement.\(claim.id)",
                claimID: claim.id,
                title: claim.text,
                kind: .hard,
                required: true,
                sourceState: claim.state == .official ? .official : .current,
                freshnessState: claim.freshness == .current ? .current : .stale,
                riskState: claim.riskClass.requiresStrictReview ? .high : .low,
                reviewState: claim.reviewRequired ? .required : .approved
            )
        }.sorted { $0.id < $1.id }
    }

    private func nativeProofMap(
        from requirements: [SourceAtlasRequirement],
        claims: [SourceAtlasClaim]
    ) -> [SourceAtlasProofMapEntry] {
        let claimsByID = Dictionary(uniqueKeysWithValues: claims.map { ($0.id, $0) })
        return requirements.map { requirement in
            let sourceIDs = claimsByID[requirement.claimID]?.sourceIDs ?? []
            return SourceAtlasProofMapEntry(
                id: "proof.\(requirement.id)",
                requirementID: requirement.id,
                proofDescription: "Public reference provenance from Source Atlas publisher pack.",
                privacyClass: .externalRedacted,
                proofCandidate: .sourceEvidence,
                proofStrength: .moderate,
                capabilityNodeID: "published.reference",
                sourceRecordIDs: sourceIDs,
                sourceClaimIDs: [requirement.claimID]
            )
        }
    }

    private func sourceKind(authorityClass: String?) -> SourceAtlasSourceKind {
        switch authorityClass {
        case "official_government", "official_institution", "regulated_body":
            return .official
        case "standards_body", "scholarly_metadata":
            return .semiOfficial
        case "open_knowledge_graph":
            return .maintainerCurated
        default:
            return .unknown
        }
    }

    private func claimState(authorityClass: String?) -> SourceAtlasClaimState {
        sourceKind(authorityClass: authorityClass) == .official ? .official : .sourced
    }

    private func freshnessState(_ value: String?) -> SourceAtlasFreshnessState {
        switch value {
        case "current":
            return .current
        case "stale":
            return .stale
        case "stale_critical":
            return .staleCritical
        case "revoked":
            return .revoked
        case "contradicted", "conflicted":
            return .disputed
        default:
            return .unknown
        }
    }

    private func riskClass(domainID: String, claimType: String?) -> SourceAtlasRiskClass {
        let combined = "\(domainID) \(claimType ?? "")"
        if combined.contains("health") {
            return .healthMedical
        }
        if combined.contains("finance") || combined.contains("tax") {
            return .financial
        }
        if combined.contains("education") || combined.contains("credential") {
            return .educationEligibility
        }
        if combined.contains("civic") || combined.contains("legal") || combined.contains("requirement") {
            return .legalCivic
        }
        return .careerContext
    }

    private func title(for domainID: String) -> String {
        domainID
            .split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}

private struct PublishedPackManifest: Decodable {
    let kind: String
    let schemaVersion: String
    let manifestID: String?
    let packID: String
    let createdAt: String?
    let sha256: String?
    let objectKeys: [String: String]?
    let freshnessStatus: String?
    let publicReferenceOnly: Bool

    enum CodingKeys: String, CodingKey {
        case kind
        case schemaVersion = "schema_version"
        case manifestID = "manifest_id"
        case packID = "pack_id"
        case createdAt = "created_at"
        case sha256
        case objectKeys = "object_keys"
        case freshnessStatus = "freshness_status"
        case publicReferenceOnly
    }
}

private struct PublishedDomainPack: Decodable {
    let kind: String
    let schemaVersion: String
    let packID: String
    let frontierID: String?
    let createdAt: String?
    let publicReferenceOnly: Bool
    let manifest: PublishedDomainPackManifest?
    let sources: [PublishedDomainSource]
    let claims: [PublishedDomainClaim]

    enum CodingKeys: String, CodingKey {
        case kind
        case schemaVersion = "schema_version"
        case packID = "pack_id"
        case frontierID = "frontier_id"
        case createdAt = "created_at"
        case publicReferenceOnly
        case manifest
        case sources
        case claims
    }
}

private struct PublishedDomainPackManifest: Decodable {
    let packVersion: String?

    enum CodingKeys: String, CodingKey {
        case packVersion = "pack_version"
    }
}

private struct PublishedDomainSource: Decodable {
    let sourceID: String
    let sourceName: String
    let authorityClass: String?
    let reviewStatus: String?
    let r2PackPolicy: String?

    enum CodingKeys: String, CodingKey {
        case sourceID = "source_id"
        case sourceName = "source_name"
        case authorityClass = "authority_class"
        case reviewStatus = "review_status"
        case r2PackPolicy = "r2_pack_policy"
    }
}

private struct PublishedDomainClaim: Decodable {
    let claimID: String
    let claimType: String?
    let predicate: String?
    let objectValue: String?
    let sourceID: String?
    let authorityClass: String?
    let freshnessStatus: String?
    let reviewRequired: Bool?
    let locator: String?
    let domain: String?

    enum CodingKeys: String, CodingKey {
        case claimID = "claim_id"
        case claimType = "claim_type"
        case predicate
        case objectValue = "object_value"
        case sourceID = "source_id"
        case authorityClass = "authority_class"
        case freshnessStatus = "freshness_status"
        case reviewRequired = "review_required"
        case locator
        case domain
    }
}
