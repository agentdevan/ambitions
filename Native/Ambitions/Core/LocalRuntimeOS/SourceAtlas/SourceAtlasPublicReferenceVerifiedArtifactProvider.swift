import Foundation

enum SourceAtlasPublicReferenceVerifiedArtifactFailure: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingCachedArtifact = "missing_cached_artifact"
    case missingManifestData = "missing_manifest_data"
    case manifestHashMismatch = "manifest_hash_mismatch"
    case malformedManifest = "malformed_manifest"
    case missingTrustRoot = "missing_trust_root"
    case missingArtifactEntry = "missing_artifact_entry"
    case unsupportedArtifact = "unsupported_artifact"
    case unsupportedRelease = "unsupported_release"
    case unsupportedSignature = "unsupported_signature"
    case signatureInvalid = "signature_invalid"
    case packHashMismatch = "pack_hash_mismatch"
    case invalidPack = "invalid_pack"
    case unsupportedSource = "unsupported_source"
    case unsupportedSubject = "unsupported_subject"
    case unsupportedPredicate = "unsupported_predicate"
}

struct SourceAtlasPublicReferenceArtifactVerificationInput: Sendable, Equatable, Hashable {
    let manifestData: Data
    let expectedManifestSHA256: String
    let packPayload: SourceAtlasStorePayload
    let checkedAt: Date
    let ed25519PublicKey: Data?

    init(
        manifestData: Data,
        expectedManifestSHA256: String,
        packPayload: SourceAtlasStorePayload,
        checkedAt: Date,
        ed25519PublicKey: Data?
    ) {
        self.manifestData = manifestData
        self.expectedManifestSHA256 = expectedManifestSHA256
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        self.packPayload = packPayload
        self.checkedAt = checkedAt
        self.ed25519PublicKey = ed25519PublicKey
    }
}

struct SourceAtlasPublicReferenceArtifactVerificationEvidence: Codable, Sendable, Equatable, Hashable {
    let artifactID: String
    let manifestVersionID: String
    let manifestSHA256: String
    let packSHA256: String
    let packSource: SourceAtlasStorePayloadSource
    let checkedAt: Date
    let sourceNativeSubjectID: String
    let predicateIDs: [String]
    let sourceIDs: [String]
    let signatureResult: SignatureVerificationResult
}

struct SourceAtlasPublicReferenceVerifiedArtifact: Sendable, Equatable, Hashable {
    let pack: SourceAtlasPack
    let evidence: SourceAtlasPublicReferenceArtifactVerificationEvidence

    fileprivate init(
        pack: SourceAtlasPack,
        evidence: SourceAtlasPublicReferenceArtifactVerificationEvidence
    ) {
        self.pack = pack
        self.evidence = evidence
    }
}

struct SourceAtlasPublicReferenceArtifactVerificationResult: Sendable, Equatable, Hashable {
    let artifact: SourceAtlasPublicReferenceVerifiedArtifact?
    let failures: [SourceAtlasPublicReferenceVerifiedArtifactFailure]
    let manifestVerification: ManifestVerificationResult?
    let storeQuarantines: [SourceAtlasStoreQuarantine]

    var isVerified: Bool {
        artifact != nil && failures.isEmpty && storeQuarantines.isEmpty
    }
}

/// Loads and verifies the one approved public-reference artifact from the
/// Source Atlas public cache. Trust is derived from signed bytes and typed
/// evidence; callers cannot assert verification through a Boolean flag.
struct SourceAtlasPublicReferenceVerifiedArtifactProvider: Sendable, Equatable, Hashable {
    static let approvedArtifactID = "onet-30.3"
    static let approvedReleaseID = "30.3"
    static let approvedSourceID = "onet.database"
    static let approvedSourceLocator = "https://www.onetcenter.org/database.html"
    static let approvedSubjectID = "15-1252.00"
    static let approvedLicenseIdentifier = "CC-BY-4.0"
    static let approvedAttribution = "O*NET 30.3, CC BY 4.0"
    static let approvedSourceFieldsByPredicate: [String: Set<String>] = [
        "occupation.identity": ["identity-1"],
        "occupation.task": ["task-1"],
        "occupation.skill": ["skill-1"],
        "occupation.knowledge": ["knowledge-1"],
        "occupation.work_activity": ["work-activity-1"],
        "occupation.work_context": ["work-context-1"],
        "occupation.education": ["education-1"],
        "occupation.experience": ["experience-1"]
    ]
    static let approvedPredicateIDs = Set(approvedSourceFieldsByPredicate.keys)

    private let manifestVerifier: ManifestVerifier
    private let store: SourceAtlasStore
    private let decoder: JSONDecoder

    init(
        manifestVerifier: ManifestVerifier = ManifestVerifier(),
        store: SourceAtlasStore = SourceAtlasStore(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.manifestVerifier = manifestVerifier
        self.store = store
        self.decoder = decoder
    }

    static func == (
        lhs: SourceAtlasPublicReferenceVerifiedArtifactProvider,
        rhs: SourceAtlasPublicReferenceVerifiedArtifactProvider
    ) -> Bool {
        lhs.manifestVerifier == rhs.manifestVerifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(manifestVerifier)
    }

    func verify(
        _ input: SourceAtlasPublicReferenceArtifactVerificationInput
    ) -> SourceAtlasPublicReferenceArtifactVerificationResult {
        guard let publicKey = input.ed25519PublicKey, publicKey.isEmpty == false else {
            return failure(.missingTrustRoot)
        }

        let actualManifestSHA256 = SourceAtlasStore.sha256Hex(for: input.manifestData)
        guard actualManifestSHA256 == input.expectedManifestSHA256 else {
            return failure(.manifestHashMismatch)
        }

        let manifest: SourceAtlasFreshnessManifest
        do {
            manifest = try decoder.decode(SourceAtlasFreshnessManifest.self, from: input.manifestData)
        } catch {
            return failure(.malformedManifest)
        }

        guard let entry = manifest.packIndex.first(where: { $0.packID == Self.approvedArtifactID }) else {
            return failure(.missingArtifactEntry)
        }
        guard entry.currentSignature.hasPrefix("ed25519:") else {
            return failure(.unsupportedSignature)
        }

        let manifestVerification = manifestVerifier.verify(
            manifest: manifest,
            packID: Self.approvedArtifactID,
            expectedVersionID: Self.approvedReleaseID,
            manifestData: input.manifestData,
            expectedManifestSHA256: input.expectedManifestSHA256,
            checkedAt: input.checkedAt,
            ed25519PublicKey: publicKey
        )
        guard manifestVerification.isVerified else {
            return failure(
                manifestVerification.issues.contains(.versionMismatch) ? .unsupportedRelease : .signatureInvalid,
                manifestVerification: manifestVerification
            )
        }

        let actualPackSHA256 = SourceAtlasStore.sha256Hex(for: input.packPayload.data)
        guard actualPackSHA256 == entry.currentSHA256.lowercased(),
              input.packPayload.declaredSHA256 == entry.currentSHA256.lowercased()
        else {
            return failure(.packHashMismatch, manifestVerification: manifestVerification)
        }

        let decodedPack: SourceAtlasPack
        do {
            decodedPack = try decoder.decode(SourceAtlasPack.self, from: input.packPayload.data)
        } catch {
            return failure(.invalidPack, manifestVerification: manifestVerification)
        }
        guard hasUniqueIDs(in: decodedPack) else {
            return failure(.invalidPack, manifestVerification: manifestVerification)
        }

        let binding = bindingFailures(for: decodedPack, manifest: manifest)
        guard binding.failures.isEmpty else {
            return SourceAtlasPublicReferenceArtifactVerificationResult(
                artifact: nil,
                failures: ordered(binding.failures),
                manifestVerification: manifestVerification,
                storeQuarantines: []
            )
        }

        let loadResult = store.load(
            bundled: nil,
            cached: SourceAtlasStorePayload(
                source: input.packPayload.source,
                data: input.packPayload.data,
                declaredSHA256: entry.currentSHA256
            ),
            lastKnownGood: nil
        )
        guard let pack = loadResult.pack else {
            return failure(
                .invalidPack,
                manifestVerification: manifestVerification,
                storeQuarantines: loadResult.quarantines
            )
        }

        let evidence = SourceAtlasPublicReferenceArtifactVerificationEvidence(
            artifactID: Self.approvedArtifactID,
            manifestVersionID: manifest.versionID,
            manifestSHA256: actualManifestSHA256,
            packSHA256: actualPackSHA256,
            packSource: input.packPayload.source,
            checkedAt: input.checkedAt,
            sourceNativeSubjectID: Self.approvedSubjectID,
            predicateIDs: binding.predicateIDs,
            sourceIDs: binding.sourceIDs,
            signatureResult: manifestVerification.signatureResult ?? SignatureVerificationResult(
                signature: entry.currentSignature,
                issues: [.signatureMismatch]
            )
        )
        return SourceAtlasPublicReferenceArtifactVerificationResult(
            artifact: SourceAtlasPublicReferenceVerifiedArtifact(pack: pack, evidence: evidence),
            failures: [],
            manifestVerification: manifestVerification,
            storeQuarantines: loadResult.quarantines
        )
    }

    func verifiedArtifact(
        in repository: SourceAtlasPublicPackCacheFileRepository,
        checkedAt: Date,
        ed25519PublicKey: Data?,
        matching pointer: PublicReferenceVerifiedReleasePointer? = nil
    ) throws -> SourceAtlasPublicReferenceArtifactVerificationResult {
        let lookup: SourceAtlasPublicPackCacheManifestLookup?
        if let pointer {
            guard pointer.artifactID == Self.approvedArtifactID else {
                return failure(.unsupportedArtifact)
            }
            lookup = SourceAtlasPublicPackCacheManifestLookup(
                packID: pointer.artifactID,
                manifestVersionID: pointer.manifestVersionID,
                declaredPackSHA256: pointer.packSHA256
            )
        } else {
            lookup = try repository.latestManifestLookup(packID: Self.approvedArtifactID)
        }

        guard let lookup,
              let index = try repository.loadIndex(
                packID: lookup.packID,
                manifestVersionID: lookup.manifestVersionID,
                declaredSHA256: lookup.declaredPackSHA256
              ),
              pointer == nil || index.manifestSHA256 == pointer?.manifestSHA256,
              let manifestRelativePath = index.manifestRelativePath,
              let manifestSHA256 = index.manifestSHA256,
              let payload = try repository.loadPayload(
                SourceAtlasPublicPackCachePayloadLookup(
                    packID: lookup.packID,
                    manifestVersionID: lookup.manifestVersionID,
                    declaredSHA256: lookup.declaredPackSHA256
                )
              )
        else {
            return failure(.missingCachedArtifact)
        }

        let manifestURL = repository.absoluteURL(for: manifestRelativePath)
        guard repository.fileManager.fileExists(atPath: manifestURL.path) else {
            return failure(.missingManifestData)
        }
        let manifestData: Data
        do {
            manifestData = try Data(contentsOf: manifestURL)
        } catch {
            return failure(.missingManifestData)
        }

        return verify(SourceAtlasPublicReferenceArtifactVerificationInput(
            manifestData: manifestData,
            expectedManifestSHA256: manifestSHA256,
            packPayload: payload,
            checkedAt: checkedAt,
            ed25519PublicKey: ed25519PublicKey
        ))
    }
}

private extension SourceAtlasPublicReferenceVerifiedArtifactProvider {
    struct ArtifactBinding {
        let failures: Set<SourceAtlasPublicReferenceVerifiedArtifactFailure>
        let predicateIDs: [String]
        let sourceIDs: [String]
    }

    func hasUniqueIDs(in pack: SourceAtlasPack) -> Bool {
        Set(pack.sources.map(\.id)).count == pack.sources.count &&
            Set(pack.claims.map(\.id)).count == pack.claims.count &&
            Set(pack.requirements.map(\.id)).count == pack.requirements.count
    }

    func bindingFailures(
        for pack: SourceAtlasPack,
        manifest: SourceAtlasFreshnessManifest
    ) -> ArtifactBinding {
        var failures: Set<SourceAtlasPublicReferenceVerifiedArtifactFailure> = []
        var predicates: Set<String> = []

        if pack.manifest.id != Self.approvedArtifactID {
            failures.insert(.unsupportedArtifact)
        }
        if manifest.versionID != Self.approvedReleaseID ||
            pack.manifest.version != Self.approvedReleaseID {
            failures.insert(.unsupportedRelease)
        }
        if pack.manifest.specificDomainID != Self.approvedSubjectID {
            failures.insert(.unsupportedSubject)
        }

        let sourceIDs = Set(pack.sources.map(\.id))
        let hasSoleApprovedOfficialSource = pack.sources.count == 1 &&
            pack.sources[0].id == Self.approvedSourceID &&
            pack.sources[0].kind == .official &&
            pack.sources[0].approvedForOfficialClaims &&
            pack.sources[0].locator == Self.approvedSourceLocator &&
            pack.sources[0].licenseIdentifier == Self.approvedLicenseIdentifier &&
            pack.sources[0].requiredAttribution == Self.approvedAttribution
        let hasOnlyApprovedOfficialClaims = pack.claims.allSatisfy {
            $0.state == .official &&
                $0.reviewRequired == false &&
                $0.sourceIDs == [Self.approvedSourceID]
        }
        if hasSoleApprovedOfficialSource == false ||
            hasOnlyApprovedOfficialClaims == false {
            failures.insert(.unsupportedSource)
        }

        if pack.claims.isEmpty {
            failures.insert(.unsupportedPredicate)
        }
        for claim in pack.claims {
            let components = claim.id.components(separatedBy: "::")
            guard components.count == 3 else {
                failures.insert(.unsupportedPredicate)
                continue
            }
            if components[0] != Self.approvedSubjectID {
                failures.insert(.unsupportedSubject)
            }
            let predicate = components[1]
            if Self.approvedSourceFieldsByPredicate[predicate]?.contains(components[2]) != true {
                failures.insert(.unsupportedPredicate)
            } else {
                predicates.insert(predicate)
            }
        }

        return ArtifactBinding(
            failures: failures,
            predicateIDs: predicates.sorted(),
            sourceIDs: sourceIDs.sorted()
        )
    }

    func failure(
        _ failure: SourceAtlasPublicReferenceVerifiedArtifactFailure,
        manifestVerification: ManifestVerificationResult? = nil,
        storeQuarantines: [SourceAtlasStoreQuarantine] = []
    ) -> SourceAtlasPublicReferenceArtifactVerificationResult {
        SourceAtlasPublicReferenceArtifactVerificationResult(
            artifact: nil,
            failures: [failure],
            manifestVerification: manifestVerification,
            storeQuarantines: storeQuarantines
        )
    }

    func ordered(
        _ failures: Set<SourceAtlasPublicReferenceVerifiedArtifactFailure>
    ) -> [SourceAtlasPublicReferenceVerifiedArtifactFailure] {
        SourceAtlasPublicReferenceVerifiedArtifactFailure.allCases.filter(failures.contains)
    }
}
