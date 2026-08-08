import Foundation

enum SourceAtlasPublicReferenceTrustRoot {
    static let resourceName = "onet-30.3-ed25519-public-key"
    static let resourceExtension = "txt"

    static func defaultAppKey(bundle: Bundle = .main) -> Data? {
        guard let url = bundle.url(
            forResource: resourceName,
            withExtension: resourceExtension
        ),
        let encoded = try? String(contentsOf: url, encoding: .utf8),
        let key = Data(base64Encoded: encoded.trimmingCharacters(in: .whitespacesAndNewlines)),
        key.count == 32
        else { return nil }
        return key
    }
}

/// Converts only cryptographically verified Source Atlas bytes into the
/// narrower public-reference repository contract.
extension SourceAtlasPublicReferenceVerifiedArtifact {
    func publicReferencePackArtifact() -> PublicReferencePackArtifact? {
        guard Set(pack.sources.map(\.id)).count == pack.sources.count,
              Set(pack.claims.map(\.id)).count == pack.claims.count,
              Set(pack.requirements.map(\.id)).count == pack.requirements.count
        else {
            return nil
        }
        let sourcesByID = Dictionary(uniqueKeysWithValues: pack.sources.map { ($0.id, $0) })
        let claims = pack.claims.compactMap { claim -> PublicReferenceClaimEnvelope? in
            let components = claim.id.components(separatedBy: "::")
            guard components.count == 3,
                  components[0] == evidence.sourceNativeSubjectID,
                  evidence.predicateIDs.contains(components[1]),
                  claim.sourceIDs.count == 1,
                  let sourceID = claim.sourceIDs.first,
                  let source = sourcesByID[sourceID],
                  source.licenseIdentifier == SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedLicenseIdentifier,
                  let requiredAttribution = source.requiredAttribution,
                  requiredAttribution == SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedAttribution,
                  let retrievedAt = source.retrievedAt?.trimmingCharacters(in: .whitespacesAndNewlines),
                  retrievedAt.isEmpty == false
            else {
                return nil
            }
            let predicateID = components[1]
            return PublicReferenceClaimEnvelope(
                id: PublicReferenceClaimID(claim.id),
                sourceNativeSubjectID: evidence.sourceNativeSubjectID,
                predicateID: predicateID,
                value: PublicReferenceClaimValue(text: claim.text, languageCode: "en"),
                sourceRecordID: source.id,
                authority: PublicReferenceAuthority(
                    publisherID: "onet",
                    lane: Self.authorityLane(for: predicateID),
                    statement: "O*NET is authoritative for this descriptive occupation claim."
                ),
                jurisdiction: PublicReferenceJurisdiction(code: "US", label: "United States"),
                release: PublicReferenceRelease(id: evidence.manifestVersionID),
                retrievedAt: retrievedAt,
                checkedAt: ISO8601DateFormatter().string(from: evidence.checkedAt),
                deliveryState: Self.deliveryState(for: evidence.packSource),
                semanticReviewState: claim.reviewRequired ? .incomplete : .complete,
                freshnessState: Self.freshnessState(for: claim.freshness),
                rightsState: .approvedWithAttribution,
                requiredAttribution: requiredAttribution,
                riskState: claim.riskClass.rawValue,
                contentHash: SourceAtlasStore.sha256Hex(
                    for: Data([claim.id, claim.text, source.id, evidence.packSHA256].joined(separator: "|").utf8)
                )
            )
        }
        guard claims.count == pack.claims.count, claims.isEmpty == false else { return nil }

        return PublicReferencePackArtifact(
            id: evidence.artifactID,
            request: SourceAtlasPublicPackRequest(
                packID: evidence.artifactID,
                manifestVersionID: evidence.manifestVersionID,
                declaredSHA256: evidence.packSHA256
            ),
            release: PublicReferenceRelease(id: evidence.manifestVersionID),
            publisherID: "onet",
            jurisdiction: PublicReferenceJurisdiction(code: "US", label: "United States"),
            verificationEvidence: evidence,
            claims: claims
        )
    }
}

private extension SourceAtlasPublicReferenceVerifiedArtifact {
    static func authorityLane(for predicateID: String) -> PublicReferenceAuthorityLane {
        switch predicateID {
        case "occupation.identity":
            return .classification
        case "occupation.education", "occupation.experience":
            return .typicalPreparation
        default:
            return .description
        }
    }

    static func deliveryState(for source: SourceAtlasStorePayloadSource) -> PublicReferenceDeliveryState {
        switch source {
        case .bundled: .bundled
        case .cached: .cachedVerified
        case .lastKnownGood: .lastKnownGood
        }
    }

    static func freshnessState(for state: SourceAtlasFreshnessState) -> PublicReferenceFreshnessState {
        switch state {
        case .current: .current
        case .aging: .aging
        case .stale: .staleAllowed
        case .staleCritical: .staleBlocked
        case .sourceChanged: .sourceChanged
        case .revoked: .revoked
        case .disputed, .unknown, .userProvided, .needsReview: .unknown
        }
    }
}

struct SourceAtlasCachePublicReferenceVerifiedPackProvider: PublicReferenceVerifiedPackProviding {
    let repository: SourceAtlasPublicPackCacheFileRepository
    let verifier: SourceAtlasPublicReferenceVerifiedArtifactProvider
    let ed25519PublicKey: Data?
    let now: @Sendable () -> Date

    init(
        repository: SourceAtlasPublicPackCacheFileRepository = .defaultAppCacheRepository(),
        verifier: SourceAtlasPublicReferenceVerifiedArtifactProvider = SourceAtlasPublicReferenceVerifiedArtifactProvider(),
        ed25519PublicKey: Data?,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.repository = repository
        self.verifier = verifier
        self.ed25519PublicKey = ed25519PublicKey
        self.now = now
    }

    func verifiedSourceAtlasArtifact(
        matching pointer: PublicReferenceVerifiedReleasePointer?
    ) async -> SourceAtlasPublicReferenceVerifiedArtifact? {
        guard let result = try? verifier.verifiedArtifact(
            in: repository,
            checkedAt: now(),
            ed25519PublicKey: ed25519PublicKey,
            matching: pointer
        ),
        result.isVerified,
        let verified = result.artifact
        else {
            return nil
        }
        return verified
    }
}

/// Reads only an explicitly bundled, signed public-reference artifact. The
/// production bundle intentionally contains no synthetic fallback: absence of
/// any required resource keeps the repository honestly unavailable.
protocol SourceAtlasPublicReferenceBundleResourceLoading: Sendable {
    func data(forResource name: String, withExtension resourceExtension: String) -> Data?
}

struct SourceAtlasPublicReferenceBundleResourceLoader: @unchecked Sendable,
    SourceAtlasPublicReferenceBundleResourceLoading {
    let bundle: Bundle

    func data(forResource name: String, withExtension resourceExtension: String) -> Data? {
        guard let url = bundle.url(forResource: name, withExtension: resourceExtension) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }
}

struct SourceAtlasBundlePublicReferenceVerifiedPackProvider: PublicReferenceVerifiedPackProviding {
    private static let manifestResourceName = "onet-30.3-manifest"
    private static let packResourceName = "onet-30.3-pack"

    let verifier: SourceAtlasPublicReferenceVerifiedArtifactProvider
    let resourceLoaders: [any SourceAtlasPublicReferenceBundleResourceLoading]
    let now: @Sendable () -> Date

    init(
        verifier: SourceAtlasPublicReferenceVerifiedArtifactProvider = SourceAtlasPublicReferenceVerifiedArtifactProvider(),
        resourceLoaders: [any SourceAtlasPublicReferenceBundleResourceLoading] = [
            SourceAtlasPublicReferenceBundleResourceLoader(bundle: .main)
        ],
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.verifier = verifier
        self.resourceLoaders = resourceLoaders
        self.now = now
    }

    func verifiedSourceAtlasArtifact(
        matching pointer: PublicReferenceVerifiedReleasePointer?
    ) async -> SourceAtlasPublicReferenceVerifiedArtifact? {
        for loader in resourceLoaders {
            guard let manifestData = loader.data(
                forResource: Self.manifestResourceName,
                withExtension: "json"
            ),
            let packData = loader.data(
                forResource: Self.packResourceName,
                withExtension: "json"
            ),
            let encodedKey = loader.data(
                forResource: SourceAtlasPublicReferenceTrustRoot.resourceName,
                withExtension: SourceAtlasPublicReferenceTrustRoot.resourceExtension
            ),
            let encodedKeyString = String(data: encodedKey, encoding: .utf8),
            let publicKey = Data(
                base64Encoded: encodedKeyString.trimmingCharacters(in: .whitespacesAndNewlines)
            ),
            publicKey.count == 32
            else {
                continue
            }
            let result = verifier.verify(SourceAtlasPublicReferenceArtifactVerificationInput(
                manifestData: manifestData,
                expectedManifestSHA256: SourceAtlasStore.sha256Hex(for: manifestData),
                packPayload: SourceAtlasStorePayload(
                    source: .bundled,
                    data: packData,
                    declaredSHA256: SourceAtlasStore.sha256Hex(for: packData)
                ),
                checkedAt: now(),
                ed25519PublicKey: publicKey
            ))
            guard result.isVerified,
                  let artifact = result.artifact,
                  pointerMatches(pointer, artifact: artifact)
            else {
                continue
            }
            return artifact
        }
        return nil
    }
}

private extension SourceAtlasBundlePublicReferenceVerifiedPackProvider {
    func pointerMatches(
        _ pointer: PublicReferenceVerifiedReleasePointer?,
        artifact: SourceAtlasPublicReferenceVerifiedArtifact
    ) -> Bool {
        guard let pointer else { return true }
        return pointer.packSource == .bundled &&
            pointer.artifactID == artifact.evidence.artifactID &&
            pointer.manifestVersionID == artifact.evidence.manifestVersionID &&
            pointer.manifestSHA256 == artifact.evidence.manifestSHA256 &&
            pointer.packSHA256 == artifact.evidence.packSHA256
    }
}

extension PublicReferenceRepository {
    static let defaultApp = PublicReferenceRepository(
        provider: SourceAtlasCachePublicReferenceVerifiedPackProvider(
            ed25519PublicKey: SourceAtlasPublicReferenceTrustRoot.defaultAppKey()
        ),
        bundledProvider: SourceAtlasBundlePublicReferenceVerifiedPackProvider(),
        stateStore: PublicReferenceFilePointerStateStore.defaultAppStore()
    )
}
