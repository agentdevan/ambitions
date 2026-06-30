import Foundation

extension SourceAtlasPublishedPackSchemaDecoder {
    func currentPackIsRevoked(
        pointer: SourceAtlasPublishedCurrentPointer,
        manifestData: Data,
        revocationData: Data
    ) throws -> Bool {
        let revocation = try Self.decodeRevocationManifest(from: revocationData)
        let packObjectKey = try? packObjectKey(from: manifestData)
        let revokedKeys = Set(revocation.revokedObjectKeys)
        return revocation.revokedPackIDs.contains(pointer.packID) ||
            revokedKeys.contains(pointer.manifestKey) ||
            packObjectKey.map { revokedKeys.contains($0) } == true
    }

    func markPackRevoked(
        _ manifest: SourceAtlasFreshnessManifest,
        packID: String
    ) -> SourceAtlasFreshnessManifest {
        let packIndex = manifest.packIndex.map { entry in
            guard entry.packID == packID else {
                return entry
            }
            return SourceAtlasFreshnessPackEntry(
                packID: entry.packID,
                currentSHA256: entry.currentSHA256,
                currentSignature: entry.currentSignature,
                rollbackPointers: entry.rollbackPointers,
                changedClaimIDs: entry.changedClaimIDs,
                claimStateBuckets: Self.appending(
                    SourceAtlasFreshnessBrokerClaimStateBucket(
                        state: .revoked,
                        claimIDs: ["source-atlas-pack"]
                    ),
                    to: entry.claimStateBuckets
                )
            )
        }
        return SourceAtlasFreshnessManifest(
            schemaVersion: manifest.schemaVersion,
            versionID: manifest.versionID,
            publishedAt: manifest.publishedAt,
            packIndex: packIndex,
            globalClaimStateBuckets: manifest.globalClaimStateBuckets
        )
    }

    func lastKnownGoodManifestKey(from data: Data) throws -> String {
        let pointer = try Self.decodeLastKnownGoodPointer(from: data)
        guard pointer.rollbackSafe else {
            throw SourceAtlasPublishedPackSchemaIssue.notPublicReference
        }
        guard pointer.manifestKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw SourceAtlasPublishedPackSchemaIssue.packObjectKeyMissing
        }
        return pointer.manifestKey
    }

    func applyingLastKnownGoodPointer(
        _ pointerData: Data,
        manifestData: Data,
        to manifest: SourceAtlasFreshnessManifest
    ) throws -> SourceAtlasFreshnessManifest {
        let pointer = try Self.decodeLastKnownGoodPointer(from: pointerData)
        guard pointer.rollbackSafe,
              SourceAtlasStore.sha256Hex(for: manifestData) == pointer.sha256.lowercased()
        else {
            throw SourceAtlasPublishedPackSchemaIssue.manifestHashMismatch
        }
        let lkgManifest = try Self.decodePackMetadataManifest(from: manifestData)
        guard let lkgPackSHA256 = lkgManifest.sha256?.lowercased(),
              SourceAtlasPublishedCurrentPointerValidator.isSHA256Hex(lkgPackSHA256)
        else {
            throw SourceAtlasPublishedPackSchemaIssue.manifestHashMissing
        }

        let packIndex = manifest.packIndex.map { entry in
            SourceAtlasFreshnessPackEntry(
                packID: entry.packID,
                currentSHA256: entry.currentSHA256,
                currentSignature: entry.currentSignature,
                rollbackPointers: entry.rollbackPointers.merging(
                    ["last_known_good": lkgPackSHA256],
                    uniquingKeysWith: { current, _ in current }
                ),
                changedClaimIDs: entry.changedClaimIDs,
                claimStateBuckets: entry.claimStateBuckets
            )
        }
        return SourceAtlasFreshnessManifest(
            schemaVersion: manifest.schemaVersion,
            versionID: manifest.versionID,
            publishedAt: manifest.publishedAt,
            packIndex: packIndex,
            globalClaimStateBuckets: manifest.globalClaimStateBuckets
        )
    }
}

private extension SourceAtlasPublishedPackSchemaDecoder {
    static func decodeRevocationManifest(from data: Data) throws -> PublishedRevocationMetadata {
        let revocation: PublishedRevocationMetadata
        do {
            revocation = try JSONDecoder().decode(PublishedRevocationMetadata.self, from: data)
        } catch {
            throw SourceAtlasPublishedPackSchemaIssue.manifestDecodeFailed
        }
        guard revocation.publicReferenceOnly,
              revocation.dataClass == "public_freshness"
        else {
            throw SourceAtlasPublishedPackSchemaIssue.notPublicReference
        }
        return revocation
    }

    static func decodeLastKnownGoodPointer(from data: Data) throws -> PublishedLastKnownGoodMetadata {
        let pointer: PublishedLastKnownGoodMetadata
        do {
            pointer = try JSONDecoder().decode(PublishedLastKnownGoodMetadata.self, from: data)
        } catch {
            throw SourceAtlasPublishedPackSchemaIssue.manifestDecodeFailed
        }
        guard pointer.publicReferenceOnly,
              pointer.dataClass == "public_freshness"
        else {
            throw SourceAtlasPublishedPackSchemaIssue.notPublicReference
        }
        return pointer
    }

    static func decodePackMetadataManifest(from data: Data) throws -> PublishedPackMetadataManifest {
        let manifest: PublishedPackMetadataManifest
        do {
            manifest = try JSONDecoder().decode(PublishedPackMetadataManifest.self, from: data)
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
        return manifest
    }

    static func appending(
        _ bucket: SourceAtlasFreshnessBrokerClaimStateBucket,
        to buckets: [SourceAtlasFreshnessBrokerClaimStateBucket]
    ) -> [SourceAtlasFreshnessBrokerClaimStateBucket] {
        buckets.contains(bucket) ? buckets : buckets + [bucket]
    }
}

private struct PublishedRevocationMetadata: Decodable {
    let revokedPackIDs: [String]
    let revokedObjectKeys: [String]
    let publicReferenceOnly: Bool
    let dataClass: String

    enum CodingKeys: String, CodingKey {
        case revokedPackIDs = "revoked_pack_ids"
        case revokedObjectKeys = "revoked_object_keys"
        case publicReferenceOnly
        case dataClass
    }
}

private struct PublishedLastKnownGoodMetadata: Decodable {
    let manifestKey: String
    let sha256: String
    let rollbackSafe: Bool
    let publicReferenceOnly: Bool
    let dataClass: String

    enum CodingKeys: String, CodingKey {
        case manifestKey = "manifest_key"
        case sha256
        case rollbackSafe = "rollback_safe"
        case publicReferenceOnly
        case dataClass
    }
}

private struct PublishedPackMetadataManifest: Decodable {
    let kind: String
    let schemaVersion: String
    let sha256: String?
    let publicReferenceOnly: Bool

    enum CodingKeys: String, CodingKey {
        case kind
        case schemaVersion = "schema_version"
        case sha256
        case publicReferenceOnly
    }
}
