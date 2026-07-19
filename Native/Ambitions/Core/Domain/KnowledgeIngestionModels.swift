import Foundation

struct KnowledgeProviderSourceInput: Codable, Sendable, Equatable, Hashable {
    let providerSourceKey: String?
    let entityTitle: String
    let publisher: String?
    let locator: String?
    let provenanceKind: KnowledgeProvenanceKind
    let isOfficial: Bool
}

struct KnowledgeProviderClaimInput: Codable, Sendable, Equatable, Hashable {
    let providerClaimKey: String?
    let providerID: String
    let subject: String
    let summary: String
    let detail: String?
    let source: KnowledgeProviderSourceInput
    let freshness: KnowledgeFreshnessMetadata
    let trustLevel: KnowledgeTrustLevel
    let confidence: RecommendationConfidence
    let uncertaintyFlags: Set<KnowledgeUncertaintyFlag>
}

enum KnowledgeDegradationState: String, Codable, Sendable, Equatable, Hashable {
    case localOnlyMode = "local_only_mode"
    case providerUnavailable = "provider_unavailable"
    case staleInformation = "stale_information"
    case lowTrustInformation = "low_trust_information"
    case conflictingClaims = "conflicting_claims"
}

struct KnowledgeConflictGroup: Codable, Sendable, Equatable, Hashable {
    let subject: String
    let claimIDs: [String]
    let sourceIDs: [String]
    let reason: String
}

struct KnowledgeIngestionResult: Codable, Sendable, Equatable {
    let claimSet: KnowledgeClaimSet
    let sources: [KnowledgeSourceRecord]
    let conflictGroups: [KnowledgeConflictGroup]
    let degradationStates: [KnowledgeDegradationState]
    let providerStatuses: [KnowledgeProviderStatus]
}

extension KnowledgeIngestionResult {
    func goalUnderstandingKnowledgeContext() -> GoalUnderstandingKnowledgeContext {
        GoalUnderstandingKnowledgeContext(
            claims: claimSet.claims,
            sources: sources,
            providerStatuses: providerStatuses
        )
    }
}
