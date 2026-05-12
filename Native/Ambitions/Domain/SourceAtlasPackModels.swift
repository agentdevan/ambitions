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
        canDriveCurrentRecommendation(
            using: .conservativeFreshness,
            riskPolicy: .conservative
        )
    }

    func canDriveCurrentRecommendation(
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        state == .official &&
            sourceIDs.isEmpty == false &&
            reviewRequired == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass)
    }

    var hasProvenanceEvidence: Bool {
        sourceIDs.isEmpty == false
    }

    func canTransition(
        to target: SourceAtlasClaimState,
        hasProvenanceEvidence: Bool? = nil,
        hasLocalProofEvidence: Bool = false
    ) -> Bool {
        state.canTransition(
            to: target,
            hasProvenanceEvidence: hasProvenanceEvidence ?? self.hasProvenanceEvidence,
            hasLocalProofEvidence: hasLocalProofEvidence
        )
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct SourceAtlasRequirement: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let claimID: String
    let title: String
    let kind: SourceAtlasRequirementKind
    let required: Bool
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let riskState: SourceAtlasRequirementRiskState
    let reviewState: SourceAtlasRequirementReviewState

    init(
        id: String,
        claimID: String,
        title: String,
        kind: SourceAtlasRequirementKind,
        required: Bool,
        sourceState: SourceAtlasRequirementSourceState = .unknown,
        freshnessState: SourceAtlasRequirementFreshnessState = .unknown,
        riskState: SourceAtlasRequirementRiskState = .unknown,
        reviewState: SourceAtlasRequirementReviewState = .required
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.claimID = claimID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.required = required
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.riskState = riskState
        self.reviewState = reviewState
    }
}

enum SourceAtlasRequirementKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case hard
    case soft
    case prerequisite
    case equipment
    case skill
    case proof
    case deadline
    case blocker
    case accelerator
    case reviewRequired = "review-required"
}

enum SourceAtlasRequirementSourceState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unknown
    case sourceNeeded = "source-needed"
    case stale
    case contradicted
    case revoked
    case locallyProven = "locally-proven"
    case official
    case officialCurrent = "official_current"
    case current
}

enum SourceAtlasRequirementFreshnessState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case stale
    case unknown
}

enum SourceAtlasRequirementRiskState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case medium
    case high
    case unknown
}

enum SourceAtlasRequirementReviewState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case requested
    case required
    case approved
    case blocked
}

extension SourceAtlasRequirement {
    var canDriveCurrentRecommendation: Bool {
        (sourceState == .officialCurrent || sourceState == .current)
            && freshnessState == .current
            && reviewState == .approved
            && riskState != .high
            && riskState != .unknown
    }
}

struct SourceAtlasStarterItem: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let stepCandidateSeed: String
    let storesFinalSchedule: Bool
}

enum SourceAtlasProofCandidate: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sourceEvidence = "source_evidence"
    case localObservation = "local_observation"
    case userProvided = "user_provided"
    case correctionArtifact = "correction_artifact"
    case revocationArtifact = "revocation_artifact"
    case unknown
}

enum SourceAtlasProofStrength: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case moderate
    case high
    case officialCertified = "official_certified"
    case localOnly = "local_only"
}

struct SourceAtlasProofMapEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let proofCandidate: SourceAtlasProofCandidate
    let proofStrength: SourceAtlasProofStrength
    let id: String
    let requirementID: String
    let capabilityNodeID: String?
    let sourceRecordIDs: [String]
    let sourceClaimIDs: [String]
    let proofDescription: String
    let correctionHookIDs: [String]
    let revocationHookIDs: [String]
    let privacyClass: HumanProgressPrivacyClass
    let evidenceLedgerBridgeIDs: [String]

    init(
        id: String,
        requirementID: String,
        proofDescription: String,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        proofCandidate: SourceAtlasProofCandidate = .sourceEvidence,
        proofStrength: SourceAtlasProofStrength = .moderate,
        capabilityNodeID: String? = nil,
        sourceRecordIDs: [String] = [],
        sourceClaimIDs: [String] = [],
        correctionHookIDs: [String] = [],
        revocationHookIDs: [String] = [],
        evidenceLedgerBridgeIDs: [String] = []
    ) {
        self.proofCandidate = proofCandidate
        self.proofStrength = proofStrength
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requirementID = requirementID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityNodeID = capabilityNodeID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.proofDescription = proofDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        self.correctionHookIDs = Self.orderedUnique(correctionHookIDs)
        self.revocationHookIDs = Self.orderedUnique(revocationHookIDs)
        self.privacyClass = privacyClass
        self.evidenceLedgerBridgeIDs = Self.orderedUnique(evidenceLedgerBridgeIDs)
    }

    var isSourceBound: Bool {
        sourceRecordIDs.isEmpty == false
    }

    var isClaimBound: Bool {
        sourceClaimIDs.isEmpty == false
    }

    var isLocalProofOnly: Bool {
        proofCandidate == .localObservation && proofStrength == .localOnly
    }

    var isSourceProofEligible: Bool {
        isSourceBound && isClaimBound
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    var canCertifySourceTruth: Bool {
        proofCandidate == .sourceEvidence &&
            proofStrength == .officialCertified &&
            isSourceProofEligible
    }

    func canSupportCurrentRequirement(_ claimsByID: [String: SourceAtlasClaim]) -> Bool {
        let boundClaims = sourceClaimIDs.compactMap { claimsByID[$0] }
        guard boundClaims.isEmpty == false else {
            return false
        }
        guard boundClaims.count == sourceClaimIDs.count else {
            return false
        }
        if boundClaims.contains(where: { $0.canDriveCurrentRecommendation == false }) {
            return false
        }
        if boundClaims.contains(where: \.state.isBlockingState) {
            return false
        }
        if boundClaims.contains(where: { $0.freshness == .stale || $0.freshness == .staleCritical }) {
            return false
        }
        if isLocalProofOnly {
            return false
        }
        return isSourceProofEligible && (proofStrength == .officialCertified || proofStrength == .high || proofStrength == .moderate)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct SourceAtlasFreshnessPolicy: Codable, Sendable, Equatable, Hashable {
    let reviewIntervalDays: Int
    let staleBlocksHighRiskUse: Bool

    static let conservativeFreshness = SourceAtlasFreshnessPolicy(
        reviewIntervalDays: 180,
        staleBlocksHighRiskUse: true
    )

    func canSupportCurrentRecommendation(
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass
    ) -> Bool {
        switch freshness {
        case .current:
            return true
        case .aging:
            return staleBlocksHighRiskUse == false ||
                riskClass.requiresStrictReview == false &&
                reviewIntervalDays >= 0
        case .stale, .staleCritical, .sourceChanged, .disputed, .revoked, .unknown:
            return false
        case .userProvided, .needsReview:
            return false
        }
    }
}

struct SourceAtlasRiskPolicy: Codable, Sendable, Equatable, Hashable {
    let strictReviewRiskClasses: [SourceAtlasRiskClass]

    static let conservative = SourceAtlasRiskPolicy(
        strictReviewRiskClasses: SourceAtlasRiskClass.allCases.filter(\.requiresStrictReview)
    )

    func allowsCurrentRecommendation(_ riskClass: SourceAtlasRiskClass) -> Bool {
        strictReviewRiskClasses.contains(riskClass) == false && riskClass.requiresStrictReview == false
    }
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
    let requirementOverlays: [SourceAtlasRequirementOverlay]

    init(
        dependencyPackIDs: [String],
        reusableNodeIDs: [String],
        overlayDependencyIDs: [String],
        projectionRecipeIDs: [String],
        ownsIndividualGoalPhrase: Bool,
        requirementOverlays: [SourceAtlasRequirementOverlay] = []
    ) {
        self.dependencyPackIDs = dependencyPackIDs
        self.reusableNodeIDs = reusableNodeIDs
        self.overlayDependencyIDs = overlayDependencyIDs
        self.projectionRecipeIDs = projectionRecipeIDs
        self.ownsIndividualGoalPhrase = ownsIndividualGoalPhrase
        self.requirementOverlays = requirementOverlays
    }
}

struct SourceAtlasRequirementOverlay: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceAtlasRequirementID: String
    let requirementIDs: [String]
    let summary: String
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let riskState: SourceAtlasRequirementRiskState
    let reviewState: SourceAtlasRequirementReviewState

    var isWellFormed: Bool {
        id.isEmpty == false &&
            sourceAtlasRequirementID.isEmpty == false &&
            summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
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

        let requirementIDs = Set(pack.requirements.map(\.id))
        let claimsByID = Dictionary(uniqueKeysWithValues: pack.claims.map { ($0.id, $0) })
        let requirementsByID = Dictionary(uniqueKeysWithValues: pack.requirements.map { ($0.id, $0) })
        var requirementSupportsCurrentProof: [String: Bool] = [:]
        var requirementHasProofEntries: [String: Bool] = [:]

        for entry in pack.proofMap {
            if entry.requirementID.isEmpty || requirementsByID[entry.requirementID] == nil {
                issues.insert(.proofCannotSupportCurrentRequirement)
                continue
            }
            if entry.capabilityNodeID == "" {
                issues.insert(.invalidRequirementOverlay)
            }
            if entry.proofStrength == .officialCertified && entry.isSourceProofEligible == false {
                issues.insert(.proofRequiresSourceOrClaimBinding)
            }
            if entry.privacyClass == .sensitive && entry.isExternalProjectionSafe == false {
                issues.insert(.sensitiveProofProjectionRisk)
            }
            if entry.proofCandidate == .correctionArtifact && entry.correctionHookIDs.isEmpty {
                issues.insert(.invalidRequirementOverlay)
            }
            if entry.proofCandidate == .revocationArtifact && entry.revocationHookIDs.isEmpty {
                issues.insert(.invalidRequirementOverlay)
            }
            if entry.canSupportCurrentRequirement(claimsByID) {
                requirementSupportsCurrentProof[entry.requirementID] = true
            }
            requirementHasProofEntries[entry.requirementID] = true
        }

        for requirement in pack.requirements {
            guard let claim = claimsByID[requirement.claimID] else {
                issues.insert(.invalidRequirementOverlay)
                continue
            }
            if requirement.canDriveCurrentRecommendation && claim.canDriveCurrentRecommendation == false {
                issues.insert(.invalidRequirementOverlay)
            }
            if [
                .unknown, .sourceNeeded, .stale, .contradicted, .revoked, .locallyProven
            ].contains(requirement.sourceState) {
                issues.insert(.invalidRequirementOverlay)
            }
            if requirement.freshnessState == .stale || requirement.freshnessState == .unknown {
                issues.insert(.invalidRequirementOverlay)
            }
            if requirement.reviewState == .required || requirement.reviewState == .blocked || requirement.reviewState == .requested {
                issues.insert(.invalidRequirementOverlay)
            }
            if requirement.riskState == .unknown || requirement.riskState == .high {
                issues.insert(.invalidRequirementOverlay)
            }
            if requirement.canDriveCurrentRecommendation && (requirementHasProofEntries[requirement.id] == false ||
                requirementSupportsCurrentProof[requirement.id] == false) {
                issues.insert(.proofCannotSupportCurrentRequirement)
            }
        }

        for overlay in pack.composition.requirementOverlays {
            if overlay.isWellFormed == false {
                issues.insert(.invalidRequirementOverlay)
            }
            if requirementIDs.contains(overlay.sourceAtlasRequirementID) == false {
                issues.insert(.invalidRequirementOverlay)
            }
            if overlay.requirementIDs.contains(where: { requirementIDs.contains($0) == false }) {
                issues.insert(.invalidRequirementOverlay)
            }
            if overlay.sourceState == .unknown || overlay.sourceState == .sourceNeeded || overlay.sourceState == .stale ||
                overlay.freshnessState == .stale || overlay.freshnessState == .unknown ||
                overlay.reviewState == .required || overlay.reviewState == .blocked || overlay.reviewState == .requested ||
                overlay.riskState == .unknown || overlay.riskState == .high {
                issues.insert(.invalidRequirementOverlay)
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
