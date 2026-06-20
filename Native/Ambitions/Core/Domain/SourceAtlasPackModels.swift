import Foundation

let sourceAtlasPackSchemaVersion = "source_atlas_pack.native.v1"

enum SourceAtlasPackKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case domainPack = "domain_pack"
    case specificDomainPack = "specific_domain_pack"
    case capabilityGraph = "capability_graph"
    case requirementOverlay = "requirement_overlay"
    case roleOverlay = "role_overlay"
    case pathOverlay = "path_overlay"
    case proofMap = "proof_map"
    case alternativePathSet = "alternative_path_set"
    case optionValueMap = "option_value_map"
    case projectionRecipe = "projection_recipe"
    case starterKit = "starter_kit"
    case userMiniPack = "user_mini_pack"
}

enum SourceAtlasSourceKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case official
    case semiOfficial = "semi_official"
    case expert
    case community
    case maintainerCurated = "maintainer_curated"
    case userProvided = "user_provided"
    case candidate
    case internalMarker = "internal_marker"
    case unknown
}

enum SourceAtlasClaimState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case official
    case semiOfficial = "semi_official"
    case expert
    case community
    case maintainerCurated = "maintainer_curated"
    case sourceNeeded = "source_needed"
    case sourced
    case userProvided = "user_provided"
    case userConfirmed = "user_confirmed"
    case imported
    case inferred
    case ocrDerived = "ocr_derived"
    case verifiedByLocalProof = "verified_by_local_proof"
    case stale
    case staleCritical = "stale_critical"
    case sourceChanged = "source_changed"
    case disputed
    case contradicted
    case revoked
    case unsupported
    case privateClaim = "private"
    case unknown

    var isSourceBackedConfidenceState: Bool {
        switch self {
        case .official, .semiOfficial, .expert, .community, .maintainerCurated:
            return true
        default:
            return false
        }
    }

    var isBlockingState: Bool {
        switch self {
        case .disputed, .contradicted, .revoked, .sourceChanged, .stale, .staleCritical, .unsupported, .unknown:
            return true
        case .sourceNeeded, .sourced:
            return false
        default:
            return false
        }
    }

    func canTransition(
        to target: SourceAtlasClaimState,
        hasProvenanceEvidence: Bool,
        hasLocalProofEvidence: Bool
    ) -> Bool {
        if self == target {
            return true
        }

        let baselineTargets: Set<SourceAtlasClaimState>
        switch self {
        case .sourceNeeded:
            baselineTargets = [
                .sourceNeeded,
                .sourced,
                .unknown,
                .unsupported,
                .userProvided,
                .imported,
                .inferred,
                .ocrDerived,
                .stale,
                .staleCritical,
                .disputed,
                .contradicted,
                .revoked
            ]
        case .sourced:
            baselineTargets = [
                .official, .semiOfficial, .expert, .community, .maintainerCurated,
                .verifiedByLocalProof,
                .sourceNeeded,
                .unknown,
                .unsupported,
                .stale,
                .staleCritical,
                .disputed,
                .contradicted,
                .revoked
            ]
        case .official, .semiOfficial, .expert, .community, .maintainerCurated:
            baselineTargets = [
                .official, .semiOfficial, .expert, .community, .maintainerCurated,
                .sourceNeeded,
                .sourced,
                .disputed,
                .contradicted,
                .revoked,
                .stale,
                .staleCritical,
                .unsupported,
                .unknown,
                .verifiedByLocalProof
            ]
        case .stale, .staleCritical, .disputed, .contradicted, .revoked, .unsupported, .unknown:
            baselineTargets = [
                .sourceNeeded,
                .unknown,
                .unsupported,
                .disputed,
                .contradicted,
                .revoked
            ]
        case .userConfirmed, .imported, .inferred, .ocrDerived:
            baselineTargets = [
                .sourceNeeded,
                .disputed,
                .contradicted,
                .revoked,
                .stale,
                .sourced,
                .verifiedByLocalProof
            ]
        case .userProvided:
            baselineTargets = [
                .sourceNeeded,
                .userProvided,
                .imported,
                .inferred,
                .ocrDerived,
                .disputed,
                .contradicted,
                .revoked,
                .sourced
            ]
        case .verifiedByLocalProof:
            baselineTargets = [
                .official, .semiOfficial, .expert, .community, .maintainerCurated,
                .stale,
                .disputed,
                .contradicted,
                .revoked,
                .sourceNeeded
            ]
        case .privateClaim, .sourceChanged:
            baselineTargets = [.sourceNeeded, .revoked, .unknown, .unsupported]
        }

        guard baselineTargets.contains(target) else {
            return false
        }

        if target.isSourceBackedConfidenceState && hasProvenanceEvidence == false {
            return false
        }
        if target == .verifiedByLocalProof && hasLocalProofEvidence == false {
            return false
        }
        return true
    }
}

enum SourceAtlasFreshnessState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case aging
    case stale
    case staleCritical = "stale_critical"
    case sourceChanged = "source_changed"
    case disputed
    case revoked
    case unknown
    case userProvided = "user_provided"
    case needsReview = "needs_review"
}

enum SourceAtlasRiskClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case lowRiskSkill = "low_risk_skill"
    case hobby
    case sportRules = "sport_rules"
    case careerContext = "career_context"
    case educationEligibility = "education_eligibility"
    case certificationEligibility = "certification_eligibility"
    case legalCivic = "legal_civic"
    case financial
    case healthMedical = "health_medical"
    case crisisSafety = "crisis_safety"
    case minorStudentData = "minor_student_data"
    case professionalBoundary = "professional_boundary"
    case deadlineSensitive = "deadline_sensitive"
    case sensitivePrivate = "sensitive_private"

    var requiresStrictReview: Bool {
        switch self {
        case .educationEligibility, .certificationEligibility, .legalCivic,
             .financial, .healthMedical, .crisisSafety, .minorStudentData,
             .professionalBoundary, .deadlineSensitive, .sensitivePrivate:
            return true
        case .lowRiskSkill, .hobby, .sportRules, .careerContext:
            return false
        }
    }
}

enum SourceAtlasValidationIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case missingManifestIdentity = "missing_manifest_identity"
    case missingCanonIntegration = "missing_canon_integration"
    case missingCompositionContract = "missing_composition_contract"
    case onePackPerGoalRisk = "one_pack_per_goal_risk"
    case officialClaimWithoutApprovedSource = "official_claim_without_approved_source"
    case highRiskClaimWithoutReview = "high_risk_claim_without_review"
    case universalScheduledStep = "universal_scheduled_step"
    case projectionRecipeMissingReceipt = "projection_recipe_missing_receipt"
    case runtimeStoreBehavior = "runtime_store_behavior"
    case proofRequiresSourceOrClaimBinding = "proof_requires_source_or_claim_binding"
    case proofCannotSupportCurrentRequirement = "proof_cannot_support_current_requirement"
    case sensitiveProofProjectionRisk = "sensitive_proof_projection_risk"
    case invalidRequirementOverlay = "invalid_requirement_overlay"
}

struct SourceAtlasPackManifest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: SourceAtlasPackKind
    let version: String
    let domainID: String
    let specificDomainID: String?
    let schemaVersion: String
    let classification: String
    let productionUse: Bool
    let canonDocumentIDs: [String]

    init(
        id: String,
        title: String,
        kind: SourceAtlasPackKind,
        version: String,
        domainID: String,
        specificDomainID: String? = nil,
        schemaVersion: String = sourceAtlasPackSchemaVersion,
        classification: String = "source_pack",
        productionUse: Bool = false,
        canonDocumentIDs: [String] = [
            "docs/canon/Ambitions_Source_Atlas.md",
            "docs/codex/SOURCE_ATLAS_GATE_MATRIX.md",
            "docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md"
        ]
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.version = version.trimmingCharacters(in: .whitespacesAndNewlines)
        self.domainID = domainID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.specificDomainID = specificDomainID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.schemaVersion = schemaVersion
        self.classification = classification
        self.productionUse = productionUse
        self.canonDocumentIDs = Self.orderedUnique(canonDocumentIDs)
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct SourceAtlasSourceRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: SourceAtlasSourceKind
    let locator: String
    let retrievedAt: String?
    let contentHash: String?
    let approvedForOfficialClaims: Bool

    init(
        id: String,
        title: String,
        kind: SourceAtlasSourceKind,
        locator: String,
        retrievedAt: String? = nil,
        contentHash: String? = nil,
        approvedForOfficialClaims: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.locator = locator.trimmingCharacters(in: .whitespacesAndNewlines)
        self.retrievedAt = retrievedAt
        self.contentHash = contentHash
        self.approvedForOfficialClaims = approvedForOfficialClaims
    }
}
