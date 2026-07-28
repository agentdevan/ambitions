import Foundation

enum RuntimeCanonicalProjectionBuildPhase: String, Codable, Sendable, Equatable, Hashable {
    case clone
    case replay
    case sealProjection = "seal_projection"
    case scrubProjection = "scrub_projection"
    case indexSearch = "index_search"
    case sealSearch = "seal_search"
    case scrubSearch = "scrub_search"
    case ready
    case blocked
}

enum RuntimeCanonicalProjectionRecoveryScope: String, Sendable, Equatable {
    case baseProjection = "base_projection"
    case projection
    case search
}

struct RuntimeCanonicalProjectionUnitBounds: Sendable, Equatable {
    let maximumRows: Int
    let maximumBytes: Int
}

struct RuntimeCanonicalProjectionInvalidation: Sendable, Equatable, Hashable {
    let id: String
    let projectionID: RuntimeCanonicalProjectionID
    let sourceCursor: RuntimeCanonicalReplayCursor
    let lineage: RuntimeAuthorityLineageReference
}

struct RuntimeCanonicalProjectionLease: Sendable, Equatable, Hashable {
    let projectionID: RuntimeCanonicalProjectionID
    let ownerID: String
    let version: UInt64
    let expiresAtMilliseconds: Int64
}

struct RuntimeCanonicalProjectionBaseBinding: Sendable, Equatable, Hashable {
    let generationID: String
    let certificateDigest: String
    let rootDigest: String
    let entryCount: Int
    let scrubCertificateDigest: String
    let scrubCompletedAtMilliseconds: Int64
}

struct RuntimeCanonicalProjectionBuildWork: Sendable, Equatable {
    let projectionID: RuntimeCanonicalProjectionID
    let generationID: String
    let definition: RuntimeCanonicalProjectionDefinition
    let phase: RuntimeCanonicalProjectionBuildPhase
    let targetCursor: RuntimeCanonicalReplayCursor
    let progressCursor: RuntimeCanonicalReplayCursor?
    let sourceChainDigest: String
    let progressSourceDigest: String
    let afterAggregateKind: String
    let afterAggregateID: String
    let shardOrdinal: Int
    let rollingRootDigest: String
    let invalidationIDs: [String]
    let invalidationDigest: String
    let lease: RuntimeCanonicalProjectionLease
    let operationNowMilliseconds: Int64
    let blockedReasonCode: String?
    let baseGenerationID: String?
    let baseCertificateDigest: String?
    let baseRootDigest: String?
    let baseEntryCount: Int?
    let baseScrubCertificateDigest: String?
    let baseScrubCompletedAtMilliseconds: Int64?
    let entryCount: Int
    let sealedEntryCount: Int
    let privacyCounts: [EventLedgerPrivacyClassification: Int]
    let nonlocalEntryCount: Int
    let searchDocumentCount: Int
    let sealedSearchDocumentCount: Int
    let searchPostingCount: Int
    let searchPostingBytes: Int
}

struct RuntimeCanonicalProjectionUnitResult: Sendable, Equatable {
    let nextPhase: RuntimeCanonicalProjectionBuildPhase
    let progressCursor: RuntimeCanonicalReplayCursor
}

struct RuntimeCanonicalProjectionEntryRow: Sendable, Equatable {
    let generationID: String
    let entry: RuntimeCanonicalProjectionEntry
    let digest: String
}

struct RuntimeCanonicalGenerationAuthority: Sendable, Equatable {
    let projectionID: RuntimeCanonicalProjectionID
    let generationID: String
    let definitionDigest: String
    let outputVersion: Int
    let sourceCursor: RuntimeCanonicalReplayCursor
    let sourceChainDigest: String
    let entryCount: Int
    let entryRootDigest: String
    let privacyClasses: [EventLedgerPrivacyClassification]
    let localOnly: Bool
    let certificateDigest: String
    let fingerprint: String
}

struct RuntimeCanonicalProjectionAccessPolicy: Sendable, Equatable, Hashable {
    let allowedPrivacy: Set<EventLedgerPrivacyClassification>
    let requiresLocalOnly: Bool

    var digest: String {
        RuntimeTransactionDigest.digest([
            "runtime.projection.access-policy.v1",
            allowedPrivacy.map(\.rawValue).sorted().joined(separator: ","),
            String(requiresLocalOnly),
        ])
    }
}

struct RuntimeCanonicalProjectionEntryCursor: Sendable, Equatable, Hashable {
    let generationID: String
    let certificateDigest: String
    let accessPolicyDigest: String
    let aggregateKind: RuntimeSemanticAggregateKind
    let aggregateID: RuntimeAggregateID
}

struct RuntimeCanonicalProjectionEntryPage: Sendable, Equatable {
    let authority: RuntimeCanonicalGenerationAuthority
    let entries: [RuntimeCanonicalProjectionEntry]
    let nextCursor: RuntimeCanonicalProjectionEntryCursor?
    let truth: RuntimeCanonicalProjectionTruth

    func actionToken(
        for entry: RuntimeCanonicalProjectionEntry,
        access: RuntimeCanonicalProjectionAccessPolicy
    ) throws -> RuntimeCanonicalProjectionEntryActionToken {
        guard entries.contains(entry), access.allowedPrivacy.contains(entry.privacy),
              access.requiresLocalOnly == false || entry.localOnly else {
            throw RuntimeCanonicalSearchError.actionSourceChanged
        }
        return RuntimeCanonicalProjectionEntryActionToken(
            generationID: authority.generationID,
            certificateDigest: authority.certificateDigest,
            authorityFingerprint: authority.fingerprint, accessPolicy: access,
            aggregate: entry.aggregate, revision: entry.revision,
            entryDigest: CanonicalRuntimeStore.canonicalProjectionEntryDigest(entry),
            sourceCursor: entry.sourceCursor
        )
    }
}

struct RuntimeCanonicalProjectionEntryRead: Sendable, Equatable {
    let entry: RuntimeCanonicalProjectionEntry?
    let truth: RuntimeCanonicalProjectionTruth
}

struct RuntimeCanonicalProjectionEntryActionToken: Sendable, Equatable, Hashable {
    let generationID: String
    let certificateDigest: String
    let authorityFingerprint: String
    let accessPolicy: RuntimeCanonicalProjectionAccessPolicy
    let aggregate: RuntimeSemanticAggregate
    let revision: UInt64
    let entryDigest: String
    let sourceCursor: RuntimeCanonicalReplayCursor
}
