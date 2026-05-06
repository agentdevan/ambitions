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
    case userProvided = "user_provided"
    case userConfirmed = "user_confirmed"
    case imported
    case inferred
    case ocrDerived = "ocr_derived"
    case stale
    case staleCritical = "stale_critical"
    case sourceChanged = "source_changed"
    case disputed
    case revoked
    case unsupported
    case privateClaim = "private"
    case unknown
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

    private static func orderedUnique(_ values: [String]) -> [String] {
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

struct SourceAtlasClaim: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let text: String
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let sourceIDs: [String]
    let reviewRequired: Bool

    init(
        id: String,
        text: String,
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        sourceIDs: [String] = [],
        reviewRequired: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.sourceIDs = Self.orderedUnique(sourceIDs)
        self.reviewRequired = reviewRequired
    }

    var canDriveCurrentRecommendation: Bool {
        state == .official &&
            freshness == .current &&
            reviewRequired == false &&
            riskClass.requiresStrictReview == false
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct SourceAtlasRequirement: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let claimID: String
    let title: String
    let kind: String
    let required: Bool
}

struct SourceAtlasStarterItem: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let stepCandidateSeed: String
    let storesFinalSchedule: Bool
}

struct SourceAtlasProofMapEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let requirementID: String
    let proofDescription: String
    let privacyClass: HumanProgressPrivacyClass
}

struct SourceAtlasFreshnessPolicy: Codable, Sendable, Equatable, Hashable {
    let reviewIntervalDays: Int
    let staleBlocksHighRiskUse: Bool
}

struct SourceAtlasRiskPolicy: Codable, Sendable, Equatable, Hashable {
    let strictReviewRiskClasses: [SourceAtlasRiskClass]
}

struct SourceAtlasDisclosureCopy: Codable, Sendable, Equatable, Hashable {
    let sourceNeeded: String
    let reviewRequired: String
    let notProfessionalAdvice: String
}

struct SourceAtlasRuntimeBoundary: Codable, Sendable, Equatable, Hashable {
    let storesUserData: Bool
    let performsNetworkFetches: Bool
    let mutatesPlans: Bool
    let writesPersistence: Bool

    static let valueModelOnly = SourceAtlasRuntimeBoundary(
        storesUserData: false,
        performsNetworkFetches: false,
        mutatesPlans: false,
        writesPersistence: false
    )

    var isValueModelOnly: Bool {
        storesUserData == false &&
            performsNetworkFetches == false &&
            mutatesPlans == false &&
            writesPersistence == false
    }
}

struct SourceAtlasCompositionContract: Codable, Sendable, Equatable, Hashable {
    let dependencyPackIDs: [String]
    let reusableNodeIDs: [String]
    let overlayDependencyIDs: [String]
    let projectionRecipeIDs: [String]
    let ownsIndividualGoalPhrase: Bool
}

struct SourceAtlasProjectionRecipe: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalIntent: String
    let requiredPackIDs: [String]
    let producesPersonalPathInstance: Bool
    let producesProjectionReceipt: Bool
}

struct SourceAtlasPack: Codable, Sendable, Equatable, Hashable, Identifiable {
    var id: String { manifest.id }

    let manifest: SourceAtlasPackManifest
    let sources: [SourceAtlasSourceRecord]
    let claims: [SourceAtlasClaim]
    let requirements: [SourceAtlasRequirement]
    let starterItems: [SourceAtlasStarterItem]
    let proofMap: [SourceAtlasProofMapEntry]
    let projectionRecipes: [SourceAtlasProjectionRecipe]
    let freshnessPolicy: SourceAtlasFreshnessPolicy
    let riskPolicy: SourceAtlasRiskPolicy
    let disclosureCopy: SourceAtlasDisclosureCopy
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let composition: SourceAtlasCompositionContract

    var validationIssues: [SourceAtlasValidationIssue] {
        SourceAtlasPackValidator().validate(self)
    }

    var isValidForRuntimeUse: Bool {
        validationIssues.isEmpty
    }

    func validatedForUse() throws -> SourceAtlasPack {
        try SourceAtlasPackValidator().validated(self)
    }
}

struct SourceAtlasPackValidator: Sendable, Equatable, Hashable {
    struct ValidationError: Error, Equatable {
        let issues: [SourceAtlasValidationIssue]
    }

    func validate(_ pack: SourceAtlasPack) -> [SourceAtlasValidationIssue] {
        var issues: Set<SourceAtlasValidationIssue> = []

        if pack.manifest.schemaVersion != sourceAtlasPackSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if pack.manifest.id.isEmpty || pack.manifest.title.isEmpty || pack.manifest.domainID.isEmpty {
            issues.insert(.missingManifestIdentity)
        }
        if pack.manifest.canonDocumentIDs.contains("docs/codex/SOURCE_ATLAS_GATE_MATRIX.md") == false ||
            pack.manifest.canonDocumentIDs.contains("docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md") == false {
            issues.insert(.missingCanonIntegration)
        }
        if pack.composition.reusableNodeIDs.isEmpty || pack.composition.projectionRecipeIDs.isEmpty {
            issues.insert(.missingCompositionContract)
        }
        if pack.composition.ownsIndividualGoalPhrase {
            issues.insert(.onePackPerGoalRisk)
        }
        if pack.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }

        let approvedSourceIDs = Set(
            pack.sources
                .filter { $0.approvedForOfficialClaims && $0.kind == .official }
                .map(\.id)
        )

        for claim in pack.claims {
            if claim.state == .official && approvedSourceIDs.isDisjoint(with: claim.sourceIDs) {
                issues.insert(.officialClaimWithoutApprovedSource)
            }
            if claim.riskClass.requiresStrictReview && claim.reviewRequired == false {
                issues.insert(.highRiskClaimWithoutReview)
            }
        }

        if pack.starterItems.contains(where: \.storesFinalSchedule) {
            issues.insert(.universalScheduledStep)
        }

        if pack.projectionRecipes.contains(where: { $0.producesProjectionReceipt == false }) {
            issues.insert(.projectionRecipeMissingReceipt)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func validated(_ pack: SourceAtlasPack) throws -> SourceAtlasPack {
        let issues = validate(pack)
        guard issues.isEmpty else {
            throw ValidationError(issues: issues)
        }
        return pack
    }
}
