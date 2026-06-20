import Foundation

enum KnowledgeProviderType: String, Codable, Sendable, CaseIterable {
    case officialAPI = "official_api"
    case publicDataset = "public_dataset"
    case webIndex = "web_index"
    case systemFallback = "system_fallback"
}

struct KnowledgeProviderDescriptor: Codable, Sendable, Equatable, Hashable {
    let id: String
    let type: KnowledgeProviderType
    let displayName: String
}

enum KnowledgeProviderAvailability: String, Codable, Sendable, Equatable {
    case available
    case localOnlyMode = "local_only_mode"
    case providerUnavailable = "provider_unavailable"
    case unsupported
}

struct KnowledgeProviderStatus: Codable, Sendable, Equatable {
    let provider: KnowledgeProviderDescriptor
    let availability: KnowledgeProviderAvailability
    let detail: String
    let runtimeTrustPosture: PortableTrustPosture
}

enum KnowledgeProvenanceKind: String, Codable, Sendable, Equatable {
    case official
    case providerReported = "provider_reported"
    case inferred
    case userProvided = "user_provided"
}

struct KnowledgeSourceRecord: Codable, Sendable, Equatable, Hashable {
    let id: String
    let providerID: String
    let entityTitle: String
    let publisher: String?
    let locator: String?
    let provenanceKind: KnowledgeProvenanceKind
    let isOfficial: Bool
}

enum KnowledgeFreshnessState: String, Codable, Sendable, Equatable {
    case fresh
    case stale
    case expired
    case unknown
}

struct KnowledgeFreshnessMetadata: Codable, Sendable, Equatable, Hashable {
    let retrievedAt: String
    let publishedAt: String?
    let staleAfter: String?
    let expiresAt: String?
    let state: KnowledgeFreshnessState
}

enum KnowledgeTrustLevel: String, Codable, Sendable, Equatable {
    case low
    case medium
    case high
}

enum KnowledgeUncertaintyFlag: String, Codable, Sendable, Equatable, Hashable {
    case lowConfidence = "low_confidence"
    case stale
    case conflicting
    case inferred
    case providerUnavailable = "provider_unavailable"
}

struct KnowledgeExplanationMetadata: Codable, Sendable, Equatable, Hashable {
    let summary: String
    let supportingSourceIDs: [String]
    let notes: [String]

    init(summary: String, supportingSourceIDs: [String], notes: [String]) {
        self.summary = summary
        self.supportingSourceIDs = supportingSourceIDs
        self.notes = notes
    }
}

struct KnowledgeClaimPayload: Codable, Sendable, Equatable, Hashable {
    let summary: String
    let detail: String?
}

struct KnowledgeClaim: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let providerID: String
    let subject: String
    let payload: KnowledgeClaimPayload
    let source: KnowledgeSourceRecord
    let freshness: KnowledgeFreshnessMetadata
    let trustLevel: KnowledgeTrustLevel
    let confidence: RecommendationConfidence
    let uncertaintyFlags: Set<KnowledgeUncertaintyFlag>
    let explanation: KnowledgeExplanationMetadata
}

enum KnowledgeConflictState: String, Codable, Sendable, Equatable {
    case none
    case conflictingUnresolved = "conflicting_unresolved"
}

struct KnowledgeClaimSet: Codable, Sendable, Equatable {
    let claims: [KnowledgeClaim]
    let conflictState: KnowledgeConflictState
    let degradationSummary: String?
}
