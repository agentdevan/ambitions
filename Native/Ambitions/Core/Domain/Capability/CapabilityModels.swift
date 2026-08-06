import Foundation

let capabilitySchemaVersion = "capability.native.v1"

/// The user-owned identity of a Capability. It is intentionally independent of
/// any Goal, Proof, public taxonomy, credential, or destination.
struct CapabilityID: Codable, Sendable, Equatable, Hashable, Identifiable {
    let rawValue: String

    var id: String { rawValue }

    init(_ rawValue: String) {
        self.rawValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum CapabilityCreationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case manual
    case confirmedProposal = "confirmed_proposal"
}

enum CapabilityLifecycle: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case active
    case archived
    case trashed
    case permanentlyDeleted = "permanently_deleted"

    var canInfluenceFutureUse: Bool {
        self == .active
    }
}

/// These facets are independent explanations, never an ordered strength scale.
enum CapabilityProvenanceFacet: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userStated = "user_stated"
    case practiced
    case proofLinked = "proof_linked"
}

enum CapabilityFutureUseState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case off
    case eligible
    case lockedForProtectedContent = "locked_for_protected_content"

    var isEnabled: Bool {
        self == .eligible
    }
}

enum CapabilityPrivacyClassification: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case privateLocal = "private_local"
    case protectedLocal = "protected_local"
    case unknown

    var permitsFutureUse: Bool {
        self == .privateLocal
    }
}

/// Claim ceilings prevent this foundation from representing scores, levels,
/// recommendation fit, acceptance, or an external qualification decision.
enum CapabilityClaimCeiling: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case descriptiveLifeCapital = "descriptive_life_capital"
    case noScore = "no_score"
    case noLevel = "no_level"
    case noRecommendationFit = "no_recommendation_fit"
    case noCredentialAcceptance = "no_credential_acceptance"
    case noExternalAuthority = "no_external_authority"
}

struct CapabilityRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: CapabilityID
    let schemaVersion: String
    let revision: Int
    let createdAt: String
    let updatedAt: String
    let name: String
    let meaning: String
    let relevantContext: String?
    let lifecycle: CapabilityLifecycle
    let priorValidLifecycle: CapabilityLifecycle?
    let privacyClassification: CapabilityPrivacyClassification
    let futureUseState: CapabilityFutureUseState
    let creationKind: CapabilityCreationKind
    let evidenceRelationshipIDs: [String]
    let consumerBindings: [String]
    let claimCeilings: Set<CapabilityClaimCeiling>

    init(
        id: CapabilityID,
        revision: Int = 1,
        createdAt: String,
        updatedAt: String,
        name: String,
        meaning: String,
        relevantContext: String? = nil,
        lifecycle: CapabilityLifecycle = .active,
        priorValidLifecycle: CapabilityLifecycle? = nil,
        privacyClassification: CapabilityPrivacyClassification = .privateLocal,
        futureUseState: CapabilityFutureUseState = .off,
        creationKind: CapabilityCreationKind,
        evidenceRelationshipIDs: [String] = [],
        consumerBindings: [String] = [],
        claimCeilings: Set<CapabilityClaimCeiling> = Set(CapabilityClaimCeiling.allCases),
        schemaVersion: String = capabilitySchemaVersion
    ) {
        self.id = id
        self.schemaVersion = schemaVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.revision = max(1, revision)
        self.createdAt = createdAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.updatedAt = updatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.meaning = meaning.trimmingCharacters(in: .whitespacesAndNewlines)
        self.relevantContext = relevantContext?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lifecycle = lifecycle
        self.priorValidLifecycle = priorValidLifecycle
        self.privacyClassification = privacyClassification
        self.futureUseState = privacyClassification.permitsFutureUse ? futureUseState : .lockedForProtectedContent
        self.creationKind = creationKind
        self.evidenceRelationshipIDs = Self.orderedUnique(evidenceRelationshipIDs)
        self.consumerBindings = Self.orderedUnique(consumerBindings)
        self.claimCeilings = claimCeilings.union(CapabilityClaimCeiling.allCases)
    }

    var isWellFormed: Bool {
        id.rawValue.isEmpty == false &&
            schemaVersion == capabilitySchemaVersion &&
            name.isEmpty == false &&
            meaning.isEmpty == false &&
            createdAt.isEmpty == false &&
            updatedAt.isEmpty == false
    }

    var canInfluenceFuturePlanning: Bool {
        lifecycle.canInfluenceFutureUse && futureUseState.isEnabled && consumerBindings.isEmpty == false
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct CapabilityDeletionTombstone: Codable, Sendable, Equatable, Hashable {
    let capabilityID: CapabilityID
    let deletedAt: String
    let revision: Int
    let schemaVersion: String

    init(capabilityID: CapabilityID, deletedAt: String, revision: Int, schemaVersion: String = capabilitySchemaVersion) {
        self.capabilityID = capabilityID
        self.deletedAt = deletedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.revision = max(1, revision)
        self.schemaVersion = schemaVersion.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
