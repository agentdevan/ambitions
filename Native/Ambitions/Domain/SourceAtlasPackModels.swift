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

extension SourceAtlasRequirementSourceState {
    var blocksCurrentProjection: Bool {
        switch self {
        case .unknown, .sourceNeeded, .stale, .contradicted, .revoked:
            return true
        default:
            return false
        }
    }

    var hasExplicitProvenanceSignal: Bool {
        switch self {
        case .official, .officialCurrent, .current, .locallyProven:
            return true
        default:
            return false
        }
    }
}

extension SourceAtlasRequirementFreshnessState {
    var blocksCurrentProjection: Bool {
        self == .stale || self == .unknown
    }
}

extension SourceAtlasRequirementRiskState {
    var blocksCurrentProjection: Bool {
        self == .high || self == .unknown
    }
}

extension SourceAtlasRequirementReviewState {
    var blocksCurrentProjection: Bool {
        self == .required || self == .blocked || self == .requested
    }
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

enum SourceAtlasCapabilityEdgeKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case prerequisite
    case unlocks
    case reinforces
    case blocks
}

struct SourceAtlasDomainPack: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let domainID: String
    let capabilityGraphIDs: [String]
    let specificDomainPackIDs: [String]
    let reusableNodeIDs: [String]
    let sourceSliceIDs: [String]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool

    init(
        id: String,
        title: String,
        domainID: String,
        capabilityGraphIDs: [String],
        specificDomainPackIDs: [String] = [],
        reusableNodeIDs: [String] = [],
        sourceSliceIDs: [String] = [],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.domainID = domainID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityGraphIDs = Self.orderedUnique(capabilityGraphIDs)
        self.specificDomainPackIDs = Self.orderedUnique(specificDomainPackIDs)
        self.reusableNodeIDs = Self.orderedUnique(reusableNodeIDs)
        self.sourceSliceIDs = Self.orderedUnique(sourceSliceIDs)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
    }

    var hasProvenanceEvidence: Bool {
        sourceSliceIDs.isEmpty == false
    }

    func supports(skillSliceID: String) -> Bool {
        sourceSliceIDs.isEmpty || sourceSliceIDs.contains(skillSliceID)
    }

    func canDriveCurrentProjection(
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        state == .official &&
            hasProvenanceEvidence &&
            reviewRequired == false &&
            state.isBlockingState == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass)
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

struct SourceAtlasSpecificDomainPack: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let domainPackID: String
    let capabilityGraphID: String
    let skillSliceIDs: [String]
    let roleOverlayIDs: [String]
    let pathOverlayIDs: [String]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool
    let sourceSliceIDs: [String]

    init(
        id: String,
        title: String,
        domainPackID: String,
        capabilityGraphID: String,
        skillSliceIDs: [String],
        roleOverlayIDs: [String] = [],
        pathOverlayIDs: [String] = [],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false,
        sourceSliceIDs: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.domainPackID = domainPackID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityGraphID = capabilityGraphID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.skillSliceIDs = Self.orderedUnique(skillSliceIDs)
        self.roleOverlayIDs = Self.orderedUnique(roleOverlayIDs)
        self.pathOverlayIDs = Self.orderedUnique(pathOverlayIDs)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
        self.sourceSliceIDs = Self.orderedUnique(sourceSliceIDs)
    }

    var hasProvenanceEvidence: Bool {
        sourceSliceIDs.isEmpty == false
    }

    func supports(skillSliceID: String) -> Bool {
        guard skillSliceIDs.isEmpty == false else {
            return false
        }
        return skillSliceIDs.contains(where: { supported in
            supported == skillSliceID ||
            skillSliceID.hasPrefix(supported + ".")
        })
    }

    func canDriveCurrentProjection(
        for skillSliceID: String,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        supports(skillSliceID: skillSliceID) &&
            state == .official &&
            hasProvenanceEvidence &&
            reviewRequired == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass) &&
            state.isBlockingState == false
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

struct SourceAtlasRoleOverlay: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let roleID: String
    let skillSliceID: String
    let reusableNodeIDs: [String]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let sourceIDs: [String]
    let reviewRequired: Bool

    init(
        id: String,
        roleID: String,
        skillSliceID: String,
        reusableNodeIDs: [String] = [],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        sourceIDs: [String] = [],
        reviewRequired: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.roleID = roleID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.skillSliceID = skillSliceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reusableNodeIDs = Self.orderedUnique(reusableNodeIDs)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.sourceIDs = Self.orderedUnique(sourceIDs)
        self.reviewRequired = reviewRequired
    }

    var hasProvenanceEvidence: Bool {
        sourceIDs.isEmpty == false
    }

    func supports(skillSliceID: String) -> Bool {
        skillSliceID == self.skillSliceID ||
            skillSliceID.hasPrefix(self.skillSliceID + ".")
    }

    func canDriveCurrentProjection(
        for skillSliceID: String,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        supports(skillSliceID: skillSliceID) &&
            state == .official &&
            hasProvenanceEvidence &&
            reviewRequired == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass) &&
            state.isBlockingState == false
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

struct SourceAtlasPathOverlay: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let skillSliceID: String
    let capabilityNodeIDs: [String]
    let pathPriority: Int
    let roleID: String?
    let claimIDs: [String]
    let sourceRecordIDs: [String]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool

    init(
        id: String,
        title: String,
        skillSliceID: String,
        capabilityNodeIDs: [String] = [],
        pathPriority: Int,
        roleID: String? = nil,
        claimIDs: [String] = [],
        sourceRecordIDs: [String] = [],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.skillSliceID = skillSliceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityNodeIDs = Self.orderedUnique(capabilityNodeIDs)
        self.pathPriority = pathPriority
        self.roleID = roleID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.claimIDs = Self.orderedUnique(claimIDs)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
    }

    var hasProvenanceEvidence: Bool {
        sourceRecordIDs.isEmpty == false
    }

    func matches(skillSliceID: String, roleID: String?) -> Bool {
        let supportsSkillSlice = skillSliceID.isEmpty == false ? (
            self.skillSliceID == skillSliceID ||
            skillSliceID.hasPrefix(self.skillSliceID + ".")
        ) : false

        let roleIsMatched = self.roleID == nil || self.roleID == roleID
        return supportsSkillSlice && roleIsMatched
    }

    func specificityScore(for skillSliceID: String, roleID: String? = nil) -> Int {
        guard matches(skillSliceID: skillSliceID, roleID: roleID) else {
            return -1
        }
        let requestedDepth = skillSliceID.split(separator: ".").count
        let overlayDepth = self.skillSliceID.split(separator: ".").count
        if self.skillSliceID == skillSliceID {
            return max(requestedDepth, overlayDepth) + 1
        }
        if skillSliceID.hasPrefix(self.skillSliceID + ".") {
            return overlayDepth
        }
        return -1
    }

    func canDriveCurrentProjection(
        for skillSliceID: String,
        roleID: String?,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        matches(skillSliceID: skillSliceID, roleID: roleID) &&
            state == .official &&
            hasProvenanceEvidence &&
            reviewRequired == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass) &&
            state.isBlockingState == false
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

struct SourceAtlasLevelLadder: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let capabilityGraphID: String
    let pathOverlays: [SourceAtlasPathOverlay]
    let levelLabels: [String]

    init(
        id: String,
        title: String,
        capabilityGraphID: String,
        pathOverlays: [SourceAtlasPathOverlay],
        levelLabels: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityGraphID = capabilityGraphID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.pathOverlays = pathOverlays
        self.levelLabels = Self.orderedUnique(levelLabels)
    }

    func canReusePathOverlay(_ pathID: String) -> Bool {
        pathOverlays.contains { $0.id == pathID }
    }

    func highestReusablePathID(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy = .conservativeFreshness,
        riskPolicy: SourceAtlasRiskPolicy = .conservative
    ) -> String? {
        bestReusablePath(
            for: skillSliceID,
            roleID: roleID,
            using: freshnessPolicy,
            riskPolicy: riskPolicy
        )?.id
    }

    func bestReusablePath(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> SourceAtlasPathOverlay? {
        reusablePaths(for: skillSliceID, roleID: roleID, using: freshnessPolicy, riskPolicy: riskPolicy)
            .max {
                if $0.pathPriority != $1.pathPriority {
                    return $0.pathPriority < $1.pathPriority
                }
                let lhsSpecificity = $0.specificityScore(for: skillSliceID, roleID: roleID)
                let rhsSpecificity = $1.specificityScore(for: skillSliceID, roleID: roleID)
                if lhsSpecificity != rhsSpecificity {
                    return lhsSpecificity < rhsSpecificity
                }
                return $0.id < $1.id
            }
    }

    func reusablePaths(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> [SourceAtlasPathOverlay] {
        pathOverlays.filter {
            $0.canDriveCurrentProjection(
                for: skillSliceID,
                roleID: roleID,
                using: freshnessPolicy,
                riskPolicy: riskPolicy
            )
        }
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

struct SourceAtlasCapabilityNode: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let capabilityGraphID: String
    let title: String
    let summary: String
    let sourceRecordIDs: [String]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool
    let linkedClaimIDs: [String]

    init(
        id: String,
        capabilityGraphID: String,
        title: String,
        summary: String,
        sourceRecordIDs: [String] = [],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false,
        linkedClaimIDs: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityGraphID = capabilityGraphID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
        self.linkedClaimIDs = Self.orderedUnique(linkedClaimIDs)
    }

    var hasProvenanceEvidence: Bool {
        sourceRecordIDs.isEmpty == false
    }

    func canDriveCurrentProjection(
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        state == .official &&
            hasProvenanceEvidence &&
            reviewRequired == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass) &&
            state.isBlockingState == false
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

struct SourceAtlasCapabilityEdge: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let capabilityGraphID: String
    let sourceNodeID: String
    let targetNodeID: String
    let kind: SourceAtlasCapabilityEdgeKind
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool
    let roleOverlayIDs: [String]
    let pathOverlayIDs: [String]
    let sourceRecordIDs: [String]

    init(
        id: String,
        capabilityGraphID: String,
        sourceNodeID: String,
        targetNodeID: String,
        kind: SourceAtlasCapabilityEdgeKind,
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false,
        roleOverlayIDs: [String] = [],
        pathOverlayIDs: [String] = [],
        sourceRecordIDs: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityGraphID = capabilityGraphID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceNodeID = sourceNodeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.targetNodeID = targetNodeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
        self.roleOverlayIDs = Self.orderedUnique(roleOverlayIDs)
        self.pathOverlayIDs = Self.orderedUnique(pathOverlayIDs)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
    }

    var hasProvenanceEvidence: Bool {
        sourceRecordIDs.isEmpty == false
    }

    func canTraverse(
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        state == .official &&
            hasProvenanceEvidence &&
            reviewRequired == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass) &&
            state.isBlockingState == false
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

struct SourceAtlasCapabilityGraph: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let domainPackID: String
    let capabilityNodeIDs: [String]
    let capabilityEdgeIDs: [String]
    let levelLadderIDs: [String]
    let roleOverlayIDs: [String]
    let nodes: [SourceAtlasCapabilityNode]
    let edges: [SourceAtlasCapabilityEdge]
    let ladders: [SourceAtlasLevelLadder]
    let roleOverlays: [SourceAtlasRoleOverlay]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool

    init(
        id: String,
        title: String,
        domainPackID: String,
        capabilityNodeIDs: [String],
        capabilityEdgeIDs: [String],
        levelLadderIDs: [String],
        roleOverlayIDs: [String],
        nodes: [SourceAtlasCapabilityNode],
        edges: [SourceAtlasCapabilityEdge],
        ladders: [SourceAtlasLevelLadder],
        roleOverlays: [SourceAtlasRoleOverlay],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.domainPackID = domainPackID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityNodeIDs = Self.orderedUnique(capabilityNodeIDs)
        self.capabilityEdgeIDs = Self.orderedUnique(capabilityEdgeIDs)
        self.levelLadderIDs = Self.orderedUnique(levelLadderIDs)
        self.roleOverlayIDs = Self.orderedUnique(roleOverlayIDs)
        self.nodes = nodes
        self.edges = edges
        self.ladders = ladders
        self.roleOverlays = roleOverlays
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
    }

    var hasProvenanceEvidence: Bool {
        nodes.contains(where: { $0.hasProvenanceEvidence }) ||
        edges.contains(where: { $0.hasProvenanceEvidence })
    }

    func highestReusablePathID(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy = .conservativeFreshness,
        riskPolicy: SourceAtlasRiskPolicy = .conservative
    ) -> String? {
        bestReusablePath(
            for: skillSliceID,
            roleID: roleID,
            using: freshnessPolicy,
            riskPolicy: riskPolicy
        )?.id
    }

    func bestReusablePath(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> SourceAtlasPathOverlay? {
        ladders
            .flatMap { $0.reusablePaths(for: skillSliceID, roleID: roleID, using: freshnessPolicy, riskPolicy: riskPolicy) }
            .max {
                if $0.pathPriority != $1.pathPriority {
                    return $0.pathPriority < $1.pathPriority
                }
                let lhsSpecificity = $0.specificityScore(for: skillSliceID, roleID: roleID)
                let rhsSpecificity = $1.specificityScore(for: skillSliceID, roleID: roleID)
                if lhsSpecificity != rhsSpecificity {
                    return lhsSpecificity < rhsSpecificity
                }
                return $0.id < $1.id
            }
    }

    func canDriveCurrentProjection(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        bestReusablePath(for: skillSliceID, roleID: roleID, using: freshnessPolicy, riskPolicy: riskPolicy) != nil &&
            state == .official &&
            hasProvenanceEvidence &&
            reviewRequired == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass) &&
            state.isBlockingState == false
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

struct SourceAtlasGoalProjection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalIntent: String
    let requiredPackIDs: [String]
    let projectionProfiles: [SourceAtlasProjectionProfile]

    init(
        id: String,
        goalIntent: String,
        requiredPackIDs: [String],
        projectionProfiles: [SourceAtlasProjectionProfile] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.goalIntent = goalIntent.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requiredPackIDs = Self.orderedUnique(requiredPackIDs)
        self.projectionProfiles = projectionProfiles
    }

    var canDriveCurrentProjection: Bool {
        projectionProfiles.contains(where: { $0.canDriveCurrentProjection })
    }

    var hasProjectionReceipts: Bool {
        projectionProfiles.isEmpty == false &&
            projectionProfiles.allSatisfy(\.producesProjectionReceipt)
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

struct SourceAtlasProjectionProfile: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let profileTitle: String
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let riskState: SourceAtlasRequirementRiskState
    let reviewState: SourceAtlasRequirementReviewState
    let producesPersonalPathInstance: Bool
    let producesProjectionReceipt: Bool
    let optionValueMap: SourceAtlasOptionValueMap
    let personalPathInstances: [SourceAtlasPersonalPathInstance]
    let alternativePathSet: SourceAtlasAlternativePathSet?

    init(
        id: String,
        profileTitle: String,
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        riskState: SourceAtlasRequirementRiskState,
        reviewState: SourceAtlasRequirementReviewState,
        producesPersonalPathInstance: Bool,
        producesProjectionReceipt: Bool,
        optionValueMap: SourceAtlasOptionValueMap,
        personalPathInstances: [SourceAtlasPersonalPathInstance] = [],
        alternativePathSet: SourceAtlasAlternativePathSet? = nil
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.profileTitle = profileTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.riskState = riskState
        self.reviewState = reviewState
        self.producesPersonalPathInstance = producesPersonalPathInstance
        self.producesProjectionReceipt = producesProjectionReceipt
        self.optionValueMap = optionValueMap
        self.personalPathInstances = personalPathInstances
        self.alternativePathSet = alternativePathSet
    }

    var canDriveCurrentProjection: Bool {
        sourceState.blocksCurrentProjection == false &&
            freshnessState.blocksCurrentProjection == false &&
            reviewState.blocksCurrentProjection == false &&
            riskState.blocksCurrentProjection == false &&
            producesProjectionReceipt &&
            producesPersonalPathInstance &&
            optionValueMap.canDriveCurrentProjection &&
            personalPathInstances.contains(where: { $0.canDriveCurrentProjection }) &&
            alternativePathSet?.canDriveCurrentProjection != false
    }
}

struct SourceAtlasPersonalPathInstance: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let personalPathTemplateID: String
    let stepCandidateSeeds: [SourceAtlasStepCandidateSeed]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let reviewState: SourceAtlasRequirementReviewState
    let riskState: SourceAtlasRequirementRiskState
    let sourceRecordIDs: [String]

    init(
        id: String,
        personalPathTemplateID: String,
        stepCandidateSeeds: [SourceAtlasStepCandidateSeed] = [],
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        reviewState: SourceAtlasRequirementReviewState,
        riskState: SourceAtlasRequirementRiskState,
        sourceRecordIDs: [String]
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.personalPathTemplateID = personalPathTemplateID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.stepCandidateSeeds = stepCandidateSeeds
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.riskState = riskState
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
    }

    var hasProvenanceEvidence: Bool {
        sourceRecordIDs.isEmpty == false
    }

    var canDriveCurrentProjection: Bool {
        sourceState.blocksCurrentProjection == false &&
            freshnessState.blocksCurrentProjection == false &&
            reviewState.blocksCurrentProjection == false &&
            riskState.blocksCurrentProjection == false &&
            hasProvenanceEvidence
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

struct SourceAtlasStepCandidateSeed: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let stepCandidate: String
    let storesFinalSchedule: Bool

    init(
        id: String,
        stepCandidate: String,
        storesFinalSchedule: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.stepCandidate = stepCandidate.trimmingCharacters(in: .whitespacesAndNewlines)
        self.storesFinalSchedule = storesFinalSchedule
    }
}

struct SourceAtlasAlternativePathSet: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let personalPathInstanceIDs: [String]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let reviewState: SourceAtlasRequirementReviewState
    let riskState: SourceAtlasRequirementRiskState

    init(
        id: String,
        personalPathInstanceIDs: [String],
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        reviewState: SourceAtlasRequirementReviewState,
        riskState: SourceAtlasRequirementRiskState
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.personalPathInstanceIDs = Self.orderedUnique(personalPathInstanceIDs)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.riskState = riskState
    }

    var canDriveCurrentProjection: Bool {
        personalPathInstanceIDs.isEmpty == false &&
            sourceState.blocksCurrentProjection == false &&
            freshnessState.blocksCurrentProjection == false &&
            reviewState.blocksCurrentProjection == false &&
            riskState.blocksCurrentProjection == false
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

struct SourceAtlasOptionValueMap: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let values: [String: String]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let reviewState: SourceAtlasRequirementReviewState
    let riskState: SourceAtlasRequirementRiskState

    init(
        id: String,
        values: [String: String],
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        reviewState: SourceAtlasRequirementReviewState,
        riskState: SourceAtlasRequirementRiskState
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.values = values
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.riskState = riskState
    }

    var canDriveCurrentProjection: Bool {
        sourceState.blocksCurrentProjection == false &&
            freshnessState.blocksCurrentProjection == false &&
            reviewState.blocksCurrentProjection == false &&
            riskState.blocksCurrentProjection == false
    }
}

struct SourceAtlasPack: Codable, Sendable, Equatable, Hashable, Identifiable {
    var id: String { manifest.id }

    let manifest: SourceAtlasPackManifest
    let sources: [SourceAtlasSourceRecord]
    let claims: [SourceAtlasClaim]
    let requirements: [SourceAtlasRequirement]
    let starterItems: [SourceAtlasStarterItem]
    let proofMap: [SourceAtlasProofMapEntry]
    let projections: [SourceAtlasGoalProjection]
    let freshnessPolicy: SourceAtlasFreshnessPolicy
    let riskPolicy: SourceAtlasRiskPolicy
    let disclosureCopy: SourceAtlasDisclosureCopy
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let composition: SourceAtlasCompositionContract
    let domainPacks: [SourceAtlasDomainPack]
    let specificDomainPacks: [SourceAtlasSpecificDomainPack]
    let capabilityGraphs: [SourceAtlasCapabilityGraph]

    init(
        manifest: SourceAtlasPackManifest,
        sources: [SourceAtlasSourceRecord],
        claims: [SourceAtlasClaim],
        requirements: [SourceAtlasRequirement],
        starterItems: [SourceAtlasStarterItem],
        proofMap: [SourceAtlasProofMapEntry],
        projections: [SourceAtlasGoalProjection],
        freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy,
        disclosureCopy: SourceAtlasDisclosureCopy,
        runtimeBoundary: SourceAtlasRuntimeBoundary,
        composition: SourceAtlasCompositionContract,
        domainPacks: [SourceAtlasDomainPack] = [],
        specificDomainPacks: [SourceAtlasSpecificDomainPack] = [],
        capabilityGraphs: [SourceAtlasCapabilityGraph] = []
    ) {
        self.manifest = manifest
        self.sources = sources
        self.claims = claims
        self.requirements = requirements
        self.starterItems = starterItems
        self.proofMap = proofMap
        self.projections = projections
        self.freshnessPolicy = freshnessPolicy
        self.riskPolicy = riskPolicy
        self.disclosureCopy = disclosureCopy
        self.runtimeBoundary = runtimeBoundary
        self.composition = composition
        self.domainPacks = domainPacks
        self.specificDomainPacks = specificDomainPacks
        self.capabilityGraphs = capabilityGraphs
    }

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
            if let requirement = requirementsByID[entry.requirementID],
               requirement.canDriveCurrentRecommendation,
               entry.canSupportCurrentRequirement(claimsByID) == false {
                issues.insert(.proofCannotSupportCurrentRequirement)
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

        for projection in pack.projections {
            if projection.projectionProfiles.isEmpty || projection.projectionProfiles.contains(where: { $0.personalPathInstances.isEmpty }) {
                issues.insert(.invalidRequirementOverlay)
            }
            if projection.hasProjectionReceipts == false {
                issues.insert(.projectionRecipeMissingReceipt)
            }
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

enum PlanSkeletonFeasibilityBand: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case comfortablyOnTrack = "comfortably_on_track"
    case onTrack = "on_track"
    case tightButPossible = "tight_but_possible"
    case atRisk = "at_risk"
    case unrealisticWithoutChangingScopeTimeCapacity = "unrealistic_without_changing_scope_time_capacity"
    case impossibleUnderCurrentConstraints = "impossible_under_current_constraints"

    var accessibilityLabel: String {
        switch self {
        case .comfortablyOnTrack:
            return "Comfortably on track"
        case .onTrack:
            return "On track"
        case .tightButPossible:
            return "Tight but possible"
        case .atRisk:
            return "At risk"
        case .unrealisticWithoutChangingScopeTimeCapacity:
            return "Unrealistic without changing scope, time, or capacity"
        case .impossibleUnderCurrentConstraints:
            return "Impossible under current constraints"
        }
    }
}

struct SourceAtlasRequirementProjection: Codable, Sendable, Equatable, Hashable {
    let requirementIDs: [String]
    let hardRequirements: [SourceAtlasRequirement]
    let softRequirements: [SourceAtlasRequirement]
    let prerequisites: [SourceAtlasRequirement]
    let equipment: [SourceAtlasRequirement]
    let skills: [SourceAtlasRequirement]
    let proofNeeds: [SourceAtlasRequirement]
    let blockers: [SourceAtlasRequirement]
    let accelerators: [SourceAtlasRequirement]
    let deadlineSensitiveItems: [SourceAtlasRequirement]
    let sourceFreshnessSummary: [LifeContextSourceFreshnessSummary]

    init(
        requirements: [SourceAtlasRequirement],
        sourceFreshnessSummary: [LifeContextSourceFreshnessSummary]
    ) {
        self.requirementIDs = Self.normalized(requirements.map(\.id))
        self.hardRequirements = Self.sorted(requirements.filter { $0.kind == .hard })
        self.softRequirements = Self.sorted(requirements.filter { $0.kind == .soft })
        self.prerequisites = Self.sorted(requirements.filter { $0.kind == .prerequisite })
        self.equipment = Self.sorted(requirements.filter { $0.kind == .equipment })
        self.skills = Self.sorted(requirements.filter { $0.kind == .skill })
        self.proofNeeds = Self.sorted(requirements.filter { $0.kind == .proof })
        self.blockers = Self.sorted(requirements.filter { $0.kind == .blocker || $0.sourceState.blocksCurrentProjection || $0.freshnessState.blocksCurrentProjection || $0.riskState.blocksCurrentProjection || $0.reviewState.blocksCurrentProjection })
        self.accelerators = Self.sorted(requirements.filter { $0.kind == .accelerator })
        self.deadlineSensitiveItems = Self.sorted(requirements.filter { $0.kind == .deadline })
        self.sourceFreshnessSummary = sourceFreshnessSummary.sorted { $0.id < $1.id }
    }

    var allRequirements: [SourceAtlasRequirement] {
        Self.sorted(hardRequirements + softRequirements + prerequisites + equipment + skills + proofNeeds + blockers + accelerators + deadlineSensitiveItems)
    }

    var hasBlockedItems: Bool {
        blockers.isEmpty == false
    }

    private static func sorted(_ requirements: [SourceAtlasRequirement]) -> [SourceAtlasRequirement] {
        requirements.sorted { lhs, rhs in
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            return lhs.id < rhs.id
        }
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct PlanSkeletonMilestone: Codable, Sendable, Equatable, Hashable, Identifiable {
    enum MilestoneKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
        case setup
        case access
        case execution
        case proof
        case review
        case recovery
    }

    let id: String
    let title: String
    let detail: String
    let orderIndex: Int
    let kind: MilestoneKind
    let requirementIDs: [String]
    let nodeIDs: [String]
    let proofRequired: Bool
    let reviewRequired: Bool
}

struct PlanSkeletonPhase: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let orderIndex: Int
    let milestoneIDs: [String]
    let pathNodeIDs: [String]
    let riskFlagIDs: [String]
}

struct PlanSkeletonWeeklyCadence: Codable, Sendable, Equatable, Hashable {
    let summary: String
    let anchorDays: [String]
    let proofTouchpoints: [String]
    let reviewTouchpoints: [String]
}

struct PlanSkeletonProofMoment: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let orderIndex: Int
    let requirementIDs: [String]
    let nodeIDs: [String]
}

struct PlanSkeletonReviewMoment: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let orderIndex: Int
    let requirementIDs: [String]
    let reason: String
}

struct PlanSkeletonRecoveryWindow: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let orderIndex: Int
    let protectsRecovery: Bool
    let relatedNodeIDs: [String]
}

struct PlanSkeletonRiskFlag: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let severity: Int
    let relatedNodeIDs: [String]
    let relatedRequirementIDs: [String]
}

struct PlanSkeleton: Codable, Sendable, Equatable, Hashable {
    let milestones: [PlanSkeletonMilestone]
    let phases: [PlanSkeletonPhase]
    let weeklyCadence: PlanSkeletonWeeklyCadence
    let proofMoments: [PlanSkeletonProofMoment]
    let reviewMoments: [PlanSkeletonReviewMoment]
    let recoveryWindows: [PlanSkeletonRecoveryWindow]
    let riskFlags: [PlanSkeletonRiskFlag]
    let feasibilityBand: PlanSkeletonFeasibilityBand
}

struct SourceAtlasPathCompositionExplanationProjection: Codable, Sendable, Equatable, Hashable {
    let summary: String
    let sourceLabels: [String]
    let whyThisChangesPlans: [String]
    let confidenceLabel: String
}

struct SourceAtlasPathTradeoff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let pathID: String
    let summary: String
    let advantages: [String]
    let drawbacks: [String]
}

struct SourceAtlasCapabilityPath: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let capabilityGraphID: String
    let selectedNodeIDs: [String]
    let selectedEdgeIDs: [String]
    let selectedPathOverlayIDs: [String]
    let selectedRoleOverlayIDs: [String]
    let traversalTrace: [String]
    let blockedNodes: [String]
    let staleNodes: [String]
    let missingSourceNodes: [String]
    let requirementProjection: SourceAtlasRequirementProjection
    let score: Double
    let pathSummary: String
    let planSkeleton: PlanSkeleton
}

struct PersonalPathComposition: Codable, Sendable, Equatable, Hashable {
    let goalID: String
    let userContextVersion: String
    let sourceAtlasProjectionID: String
    let pathInstances: [SourceAtlasCapabilityPath]
    let alternativePathSet: SourceAtlasAlternativePathSet?
    let selectedPath: SourceAtlasCapabilityPath
    let rejectedPaths: [SourceAtlasCapabilityPath]
    let pathTradeoffs: [SourceAtlasPathTradeoff]
    let explanationProjection: SourceAtlasPathCompositionExplanationProjection

    var planSkeleton: PlanSkeleton {
        selectedPath.planSkeleton
    }
}

struct SourceAtlasCapabilityPathComposer: Sendable, Equatable {
    let goalID: String
    let userContextVersion: String
    let sourceAtlasProjectionID: String
    let packs: [SourceAtlasPack]
    let match: SourceAtlasIntentMatch
    let selection: SourceAtlasPackSelection
    let lifeContextProjection: LifeContextRuntimeProjection
    let factorLedger: PersonalizationFactorLedger?

    init(
        goalID: String,
        userContextVersion: String,
        sourceAtlasProjectionID: String,
        packs: [SourceAtlasPack],
        match: SourceAtlasIntentMatch,
        selection: SourceAtlasPackSelection,
        lifeContextProjection: LifeContextRuntimeProjection,
        factorLedger: PersonalizationFactorLedger? = nil
    ) {
        self.goalID = goalID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.userContextVersion = userContextVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceAtlasProjectionID = sourceAtlasProjectionID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.packs = packs
        self.match = match
        self.selection = selection
        self.lifeContextProjection = lifeContextProjection
        self.factorLedger = factorLedger
    }

    func compose() -> PersonalPathComposition {
        let selectedPacks = self.selectedPacks
        let candidatePaths = selectedPacks.flatMap { pack in
            pack.capabilityGraphs.flatMap { graph in
                composePaths(in: graph, pack: pack)
            }
        }
        .sorted { lhs, rhs in
            if lhs.score != rhs.score {
                return lhs.score > rhs.score
            }
            return lhs.id < rhs.id
        }

        let fallbackPath = SourceAtlasCapabilityPath(
            id: "source-atlas-path.\(goalID.isEmpty ? "goal" : goalID).fallback",
            capabilityGraphID: "source-atlas.graph.fallback",
            selectedNodeIDs: [],
            selectedEdgeIDs: [],
            selectedPathOverlayIDs: [],
            selectedRoleOverlayIDs: [],
            traversalTrace: ["No selected capability graph was available for composition."],
            blockedNodes: selection.rejectedPackIDs,
            staleNodes: [],
            missingSourceNodes: [],
            requirementProjection: SourceAtlasRequirementProjection(requirements: [], sourceFreshnessSummary: lifeContextProjection.sourceFreshnessSummary),
            score: 0,
            pathSummary: "Fallback path with no selected graph.",
            planSkeleton: buildPlanSkeleton(
                pathID: "source-atlas-path.\(goalID.isEmpty ? "goal" : goalID).fallback",
                pathSummary: "Fallback path with no selected graph.",
                requirementProjection: SourceAtlasRequirementProjection(requirements: [], sourceFreshnessSummary: lifeContextProjection.sourceFreshnessSummary),
                selectedNodeIDs: [],
                blockedNodes: selection.rejectedPackIDs,
                staleNodes: [],
                missingSourceNodes: [],
                score: 0
            )
        )

        let selectedPath = candidatePaths.first ?? fallbackPath
        let rejectedPaths = candidatePaths.dropFirst().map { $0 }
        let pathTradeoffs = rejectedPaths.map { rejectedPath in
            tradeoff(from: rejectedPath, against: selectedPath)
        }

        let alternativePathSet = candidatePaths.count > 1
            ? SourceAtlasAlternativePathSet(
                id: "source-atlas-alternatives.\(sourceAtlasProjectionID.isEmpty ? goalID : sourceAtlasProjectionID)",
                personalPathInstanceIDs: candidatePaths.map(\.id),
                sourceState: selectedPath.requirementProjection.hasBlockedItems ? .sourceNeeded : .officialCurrent,
                freshnessState: selectedPath.staleNodes.isEmpty ? .current : .stale,
                reviewState: selectedPath.planSkeleton.reviewMoments.isEmpty ? .approved : .required,
                riskState: selectedPath.planSkeleton.riskFlags.isEmpty ? .low : .high
            )
            : nil

        let explanationProjection = SourceAtlasPathCompositionExplanationProjection(
            summary: explanationSummary(for: selectedPath, alternatives: pathTradeoffs),
            sourceLabels: selectedPacks.map { "\($0.manifest.title) / \($0.manifest.id)" }.sorted(),
            whyThisChangesPlans: explanationReasons(for: selectedPath, alternatives: pathTradeoffs),
            confidenceLabel: selectedPath.planSkeleton.feasibilityBand.accessibilityLabel
        )

        return PersonalPathComposition(
            goalID: goalID.isEmpty ? match.normalizedGoalIntent : goalID,
            userContextVersion: userContextVersion,
            sourceAtlasProjectionID: sourceAtlasProjectionID.isEmpty ? selectedPath.id : sourceAtlasProjectionID,
            pathInstances: candidatePaths,
            alternativePathSet: alternativePathSet,
            selectedPath: selectedPath,
            rejectedPaths: rejectedPaths,
            pathTradeoffs: pathTradeoffs,
            explanationProjection: explanationProjection
        )
    }

    private var selectedPacks: [SourceAtlasPack] {
        let selectedIDs = Set(selection.selectedPackIDs)
        let selected = packs.filter { selectedIDs.isEmpty || selectedIDs.contains($0.id) }
        return selected.isEmpty ? packs.filter { match.sourceAtlasPackIDs.contains($0.id) } : selected
    }

    private func composePaths(in graph: SourceAtlasCapabilityGraph, pack: SourceAtlasPack) -> [SourceAtlasCapabilityPath] {
        let overlays = graph.ladders.flatMap(\.pathOverlays)
        let matchingOverlays = overlays.filter { overlay in
            overlayMatches(overlay, graph: graph)
        }
        let effectiveOverlays = matchingOverlays.isEmpty ? overlays.sorted { lhs, rhs in
            if lhs.pathPriority != rhs.pathPriority {
                return lhs.pathPriority > rhs.pathPriority
            }
            return lhs.id < rhs.id
        } : matchingOverlays.sorted { lhs, rhs in
            if lhs.pathPriority != rhs.pathPriority {
                return lhs.pathPriority > rhs.pathPriority
            }
            return lhs.id < rhs.id
        }

        let roleOverlays = graph.roleOverlays.filter { roleOverlay in
            roleOverlayMatches(roleOverlay, graph: graph)
        }

        if effectiveOverlays.isEmpty {
            return [buildPath(
                graph: graph,
                pack: pack,
                overlay: nil,
                roleOverlays: roleOverlays
            )]
        }

        return effectiveOverlays.map { overlay in
            buildPath(graph: graph, pack: pack, overlay: overlay, roleOverlays: roleOverlays)
        }
    }

    private func overlayMatches(_ overlay: SourceAtlasPathOverlay, graph: SourceAtlasCapabilityGraph) -> Bool {
        let skillSliceIDs = match.matchedSkillSliceIDs.isEmpty ? graph.nodes.map(\.id) : match.matchedSkillSliceIDs
        let roleIDs = match.matchedRoleIDs.isEmpty ? [overlay.roleID].compactMap { $0 } : match.matchedRoleIDs

        for skillSliceID in skillSliceIDs {
            for roleID in roleIDs {
                if overlay.matches(skillSliceID: skillSliceID, roleID: roleID) {
                    return true
                }
            }
        }

        if overlay.capabilityNodeIDs.isEmpty == false && overlay.skillSliceID.isEmpty == false {
            return true
        }

        return match.matchedSkillSliceIDs.isEmpty && match.matchedRoleIDs.isEmpty
    }

    private func roleOverlayMatches(_ roleOverlay: SourceAtlasRoleOverlay, graph: SourceAtlasCapabilityGraph) -> Bool {
        let skillSliceIDs = match.matchedSkillSliceIDs.isEmpty ? graph.nodes.map(\.id) : match.matchedSkillSliceIDs
        let roleIDs = match.matchedRoleIDs.isEmpty ? [roleOverlay.roleID] : match.matchedRoleIDs

        for skillSliceID in skillSliceIDs {
            for roleID in roleIDs {
                if roleOverlay.supports(skillSliceID: skillSliceID) && roleOverlay.roleID == roleID {
                    return true
                }
            }
        }

        return match.matchedSkillSliceIDs.isEmpty && match.matchedRoleIDs.isEmpty
    }

    private func buildPath(
        graph: SourceAtlasCapabilityGraph,
        pack: SourceAtlasPack,
        overlay: SourceAtlasPathOverlay?,
        roleOverlays: [SourceAtlasRoleOverlay]
    ) -> SourceAtlasCapabilityPath {
        let nodesByID = Dictionary(uniqueKeysWithValues: graph.nodes.map { ($0.id, $0) })
        let edgesBySourceID = Dictionary(grouping: graph.edges, by: \.sourceNodeID)
        let overlayNodeIDs = overlay?.capabilityNodeIDs ?? []
        let seedNodeIDs = overlayNodeIDs.isEmpty
            ? Self.normalized(graph.capabilityNodeIDs + roleOverlays.flatMap(\.reusableNodeIDs))
            : overlayNodeIDs
        let allowedNodeIDs = overlayNodeIDs.isEmpty ? nil : Set(overlayNodeIDs)
        let traversal = traverse(
            graphID: graph.id,
            nodesByID: nodesByID,
            edgesBySourceID: edgesBySourceID,
            seedNodeIDs: seedNodeIDs,
            allowedNodeIDs: allowedNodeIDs
        )
        let requirementProjection = SourceAtlasRequirementProjection(
            requirements: pack.requirements,
            sourceFreshnessSummary: lifeContextProjection.sourceFreshnessSummary
        )
        let pathText = candidateText(
            graph: graph,
            pack: pack,
            overlay: overlay,
            roleOverlays: roleOverlays,
            traversal: traversal,
            requirementProjection: requirementProjection
        )
        let score = scorePath(
            graph: graph,
            packID: pack.id,
            overlay: overlay,
            roleOverlays: roleOverlays,
            traversal: traversal,
            requirementProjection: requirementProjection,
            pathText: pathText
        )
        let planSkeleton = buildPlanSkeleton(
            pathID: pathID(for: graph, overlay: overlay, roleOverlays: roleOverlays),
            pathSummary: pathSummary(for: graph, overlay: overlay, traversal: traversal),
            requirementProjection: requirementProjection,
            selectedNodeIDs: traversal.selectedNodeIDs,
            blockedNodes: traversal.blockedNodes,
            staleNodes: traversal.staleNodes,
            missingSourceNodes: traversal.missingSourceNodes,
            score: score
        )

        return SourceAtlasCapabilityPath(
            id: pathID(for: graph, overlay: overlay, roleOverlays: roleOverlays),
            capabilityGraphID: graph.id,
            selectedNodeIDs: traversal.selectedNodeIDs,
            selectedEdgeIDs: traversal.selectedEdgeIDs,
            selectedPathOverlayIDs: overlay.map { [$0.id] } ?? [],
            selectedRoleOverlayIDs: roleOverlays.map(\.id),
            traversalTrace: traversal.traversalTrace,
            blockedNodes: traversal.blockedNodes,
            staleNodes: traversal.staleNodes,
            missingSourceNodes: traversal.missingSourceNodes,
            requirementProjection: requirementProjection,
            score: score,
            pathSummary: pathSummary(for: graph, overlay: overlay, traversal: traversal),
            planSkeleton: planSkeleton
        )
    }

    private func traverse(
        graphID: String,
        nodesByID: [String: SourceAtlasCapabilityNode],
        edgesBySourceID: [String: [SourceAtlasCapabilityEdge]],
        seedNodeIDs: [String],
        allowedNodeIDs: Set<String>?
    ) -> TraversalSnapshot {
        var selectedNodeIDs: [String] = []
        var selectedEdgeIDs: [String] = []
        var traversalTrace: [String] = []
        var blockedNodes: Set<String> = []
        var staleNodes: Set<String> = []
        var missingSourceNodes: Set<String> = []
        var visited: Set<String> = []
        var queue = seedNodeIDs

        if queue.isEmpty {
            queue = roots(in: nodesByID, edgesBySourceID: edgesBySourceID)
        }

        while queue.isEmpty == false {
            let currentNodeID = queue.removeFirst()
            guard visited.insert(currentNodeID).inserted else {
                continue
            }

            guard let node = nodesByID[currentNodeID] else {
                missingSourceNodes.insert(currentNodeID)
                traversalTrace.append("\(graphID): missing node \(currentNodeID)")
                continue
            }

            selectedNodeIDs.append(node.id)
            traversalTrace.append("\(graphID): node \(node.id) \(node.title)")
            if node.freshness != .current {
                staleNodes.insert(node.id)
            }
            if node.state.isBlockingState || node.reviewRequired {
                blockedNodes.insert(node.id)
            }

            for edge in edgesBySourceID[currentNodeID] ?? [] {
                if let allowedNodeIDs, allowedNodeIDs.contains(edge.targetNodeID) == false {
                    traversalTrace.append("\(graphID): skipped edge \(edge.id) \(edge.sourceNodeID)->\(edge.targetNodeID) outside selected path overlay")
                    continue
                }

                if nodesByID[edge.targetNodeID] == nil {
                    missingSourceNodes.insert(edge.targetNodeID)
                }
                if edge.freshness != .current {
                    staleNodes.insert(edge.id)
                }

                if edge.canTraverse(using: .conservativeFreshness, riskPolicy: .conservative) == false {
                    blockedNodes.insert(edge.targetNodeID)
                    traversalTrace.append("\(graphID): blocked edge \(edge.id) \(edge.sourceNodeID)->\(edge.targetNodeID)")
                    continue
                }

                selectedEdgeIDs.append(edge.id)
                traversalTrace.append("\(graphID): edge \(edge.id) \(edge.sourceNodeID)->\(edge.targetNodeID)")
                queue.append(edge.targetNodeID)
            }
        }

        let orderedNodeIDs = Self.orderedUniquePreservingOrder(selectedNodeIDs)
        let orderedEdgeIDs = Self.orderedUniquePreservingOrder(selectedEdgeIDs)
        let orderedTrace = Self.orderedUniquePreservingOrder(traversalTrace)
        return TraversalSnapshot(
            selectedNodeIDs: orderedNodeIDs,
            selectedEdgeIDs: orderedEdgeIDs,
            traversalTrace: orderedTrace,
            blockedNodes: Self.orderedUniquePreservingOrder(Array(blockedNodes)),
            staleNodes: Self.orderedUniquePreservingOrder(Array(staleNodes)),
            missingSourceNodes: Self.orderedUniquePreservingOrder(Array(missingSourceNodes))
        )
    }

    private func roots(
        in nodesByID: [String: SourceAtlasCapabilityNode],
        edgesBySourceID: [String: [SourceAtlasCapabilityEdge]]
    ) -> [String] {
        let allTargetIDs = Set(edgesBySourceID.values.flatMap { $0.map(\.targetNodeID) })
        return nodesByID.values
            .filter { allTargetIDs.contains($0.id) == false }
            .sorted { lhs, rhs in
                if lhs.id != rhs.id {
                    return lhs.id < rhs.id
                }
                return lhs.title < rhs.title
            }
            .map(\.id)
    }

    private func scorePath(
        graph: SourceAtlasCapabilityGraph,
        packID: String,
        overlay: SourceAtlasPathOverlay?,
        roleOverlays: [SourceAtlasRoleOverlay],
        traversal: TraversalSnapshot,
        requirementProjection: SourceAtlasRequirementProjection,
        pathText: String
    ) -> Double {
        var score = 0.12
        score += min(0.18, Double(traversal.selectedNodeIDs.count) * 0.03)
        score += min(0.08, Double(traversal.selectedEdgeIDs.count) * 0.02)
        score += overlay.map { min(0.18, Double(max(0, $0.pathPriority)) * 0.03) } ?? 0.03
        score += match.matchedRoleIDs.isEmpty == false ? 0.04 : 0.0
        score += match.matchedSkillSliceIDs.isEmpty == false ? 0.04 : 0.0
        score += contextAlignmentScore(pathText: pathText, overlay: overlay, roleOverlays: roleOverlays)
        score += factorLedgerScore(pathText: pathText)
        score += requirementScore(requirementProjection: requirementProjection)
        score -= min(0.30, Double(traversal.blockedNodes.count) * 0.07)
        score -= min(0.12, Double(traversal.staleNodes.count) * 0.03)
        score -= min(0.18, Double(traversal.missingSourceNodes.count) * 0.06)
        score -= selection.rejectedPackIDs.contains(packID) ? 0.03 : 0.0
        return Self.clamp(score)
    }

    private func candidateText(
        graph: SourceAtlasCapabilityGraph,
        pack: SourceAtlasPack,
        overlay: SourceAtlasPathOverlay?,
        roleOverlays: [SourceAtlasRoleOverlay],
        traversal: TraversalSnapshot,
        requirementProjection: SourceAtlasRequirementProjection
    ) -> String {
        let nodesByID = Dictionary(uniqueKeysWithValues: graph.nodes.map { ($0.id, $0) })
        let nodeText = traversal.selectedNodeIDs.compactMap { nodeID -> String? in
            guard let node = nodesByID[nodeID] else { return nil }
            return [node.title, node.summary].joined(separator: " ")
        }
        let overlayText = [
            graph.title,
            pack.manifest.title,
            overlay?.title ?? "",
            overlay?.skillSliceID ?? ""
        ]
        .filter { $0.isEmpty == false }

        return [
            overlayText.joined(separator: " "),
            roleOverlays.map { "\($0.roleID) \($0.skillSliceID)" }.joined(separator: " "),
            nodeText.joined(separator: " "),
            traversal.traversalTrace.joined(separator: " ")
        ]
        .joined(separator: " ")
    }

    private func contextAlignmentScore(
        pathText: String,
        overlay: SourceAtlasPathOverlay?,
        roleOverlays: [SourceAtlasRoleOverlay]
    ) -> Double {
        let candidateTokens = Self.tokens(pathText)
        let opportunityTokens = Self.tokens(lifeContextProjection.availableOpportunityAnchors.map(\.detail).joined(separator: " "))
        let hardConstraintTokens = Self.tokens(lifeContextProjection.hardConstraints.map(\.detail).joined(separator: " "))
        let softConstraintTokens = Self.tokens(lifeContextProjection.softConstraints.map(\.detail).joined(separator: " "))
        let eligibilityTokens = Self.tokens(
            lifeContextProjection.eligibilityModel.map { pathway in
                [
                    pathway.pathwayType.rawValue,
                    pathway.eligibilityRulesSummary,
                    pathway.gradeWindow ?? "",
                    pathway.sexLeaguePathway ?? "",
                    pathway.locationDependent ? "location dependent" : ""
                ].joined(separator: " ")
            }
            .joined(separator: " ")
        )

        let opportunityOverlap = Double(candidateTokens.intersection(opportunityTokens).count) * 0.025
        let constraintOverlap = Double(candidateTokens.intersection(hardConstraintTokens.union(softConstraintTokens)).count) * 0.02
        let eligibilityOverlap = Double(candidateTokens.intersection(eligibilityTokens).count) * 0.035
        let roleOverlap = Double(candidateTokens.intersection(Self.tokens(roleOverlays.map(\.roleID).joined(separator: " "))).count) * 0.02
        let overlayBonus = overlay.map { Self.tokens($0.title + " " + $0.skillSliceID).isDisjoint(with: candidateTokens) ? 0.0 : 0.05 } ?? 0.0

        var score = opportunityOverlap + constraintOverlap + eligibilityOverlap + roleOverlap + overlayBonus
        let opportunityText = lifeContextProjection.availableOpportunityAnchors
            .map { "\($0.title) \($0.detail)" }
            .joined(separator: " ")
            .lowercased()
        if opportunityText.contains("field") &&
            candidateTokens.contains("field") {
            score += 0.08
        }
        if opportunityText.contains("home") &&
            candidateTokens.contains("home") {
            score += 0.80
        }
        if lifeContextProjection.eligibilityModel.isEmpty == false && candidateTokens.contains("eligibility") {
            score += 0.1
        }
        if lifeContextProjection.eligibilityModel.isEmpty && candidateTokens.contains("eligibility") {
            score -= 0.35
        }
        if opportunityText.contains("field") == false &&
            (candidateTokens.contains("field") || candidateTokens.contains("travel")) {
            score -= 1.0
        }
        if lifeContextProjection.travelModel.transportationAccess == .car && candidateTokens.contains("travel") {
            score += 0.04
        }
        if lifeContextProjection.travelModel.transportationAccess == .parentGuardian || lifeContextProjection.travelModel.transportationAccess == .limited {
            if candidateTokens.contains("setup") || candidateTokens.contains("home") {
                score += 0.30
            }
            if candidateTokens.contains("field") || candidateTokens.contains("travel") {
                score -= 0.06
            }
        }
        if lifeContextProjection.hardConstraints.isEmpty == false && candidateTokens.contains("recovery") {
            score += 0.03
        }
        return score
    }

    private func factorLedgerScore(pathText: String) -> Double {
        guard let factorLedger else {
            return 0.0
        }

        let candidateTokens = Self.tokens(pathText)
        var score = 0.0
        for factor in factorLedger.factors where factor.active && factor.allowedForRuntimeUse {
            let factorTokens = Self.tokens([
                factor.humanReadableReason,
                factor.affectedRecommendationArea,
                factor.freshness.lastAffectedLabel,
                factor.fallbackBehaviorIfRemoved,
                factor.source.sourceLabel
            ].joined(separator: " "))

            let overlap = Double(candidateTokens.intersection(factorTokens).count)
            if overlap > 0 {
                score += min(0.08, overlap * (0.015 + factor.runtimeWeight * 0.03))
            }
            switch factor.factorType {
            case .facilityAccess, .equipmentAccess:
                if candidateTokens.contains("facility") || candidateTokens.contains("equipment") || candidateTokens.contains("access") {
                    score += min(0.08, factor.runtimeWeight * 0.04)
                }
            case .eligibilityPathway:
                if candidateTokens.contains("eligibility") {
                    score += min(0.08, factor.runtimeWeight * 0.05)
                }
            case .recoveryConstraint:
                if candidateTokens.contains("recovery") {
                    score += min(0.06, factor.runtimeWeight * 0.04)
                }
            case .travelFit, .transportationConstraint:
                if candidateTokens.contains("travel") || candidateTokens.contains("field") {
                    score += min(0.06, factor.runtimeWeight * 0.035)
                }
            case .recentProof:
                if candidateTokens.contains("proof") || candidateTokens.contains("review") {
                    score += min(0.05, factor.runtimeWeight * 0.03)
                }
            default:
                break
            }
        }

        return score
    }

    private func requirementScore(requirementProjection: SourceAtlasRequirementProjection) -> Double {
        var score = 0.0
        score += requirementProjection.hardRequirements.isEmpty == false ? 0.03 : 0.0
        score += requirementProjection.prerequisites.isEmpty == false ? 0.03 : 0.0
        score += requirementProjection.proofNeeds.isEmpty == false ? 0.03 : 0.0
        score -= requirementProjection.blockers.isEmpty == false ? 0.15 : 0.0
        score += requirementProjection.accelerators.isEmpty == false ? 0.02 : 0.0
        score += requirementProjection.deadlineSensitiveItems.isEmpty == false ? 0.02 : 0.0
        return score
    }

    private func pathSummary(
        for graph: SourceAtlasCapabilityGraph,
        overlay: SourceAtlasPathOverlay?,
        traversal: TraversalSnapshot
    ) -> String {
        let overlayTitle = overlay?.title ?? graph.title
        let nodeCount = traversal.selectedNodeIDs.count
        let blockerCount = traversal.blockedNodes.count
        let staleCount = traversal.staleNodes.count
        let missingCount = traversal.missingSourceNodes.count
        return "\(overlayTitle) with \(nodeCount) nodes, \(blockerCount) blockers, \(staleCount) stale nodes, and \(missingCount) missing sources."
    }

    private func pathID(
        for graph: SourceAtlasCapabilityGraph,
        overlay: SourceAtlasPathOverlay?,
        roleOverlays: [SourceAtlasRoleOverlay]
    ) -> String {
        let overlayPart = overlay?.id ?? "graph-root"
        let rolePart = roleOverlays.map(\.id).joined(separator: ".")
        return Self.normalized(
            ["source-atlas-path", goalID.isEmpty ? match.normalizedGoalIntent : goalID, graph.id, overlayPart, rolePart]
        )
        .joined(separator: ".")
    }

    private func buildPlanSkeleton(
        pathID: String,
        pathSummary: String,
        requirementProjection: SourceAtlasRequirementProjection,
        selectedNodeIDs: [String],
        blockedNodes: [String],
        staleNodes: [String],
        missingSourceNodes: [String],
        score: Double
    ) -> PlanSkeleton {
        let opportunityTokens = Self.tokens(
            lifeContextProjection.availableOpportunityAnchors
                .map { "\($0.title) \($0.detail)" }
                .joined(separator: " ")
        )
        let equipmentNeedsSetup = requirementProjection.equipment.contains { requirement in
            let requirementTokens = Self.tokens(requirement.title)
            return requirementTokens.isEmpty == false && requirementTokens.isSubset(of: opportunityTokens) == false
        }
        let setupNeeded = equipmentNeedsSetup || blockedNodes.isEmpty == false || missingSourceNodes.isEmpty == false
        let proofNeeded = requirementProjection.proofNeeds.isEmpty == false
        let reviewNeeded = staleNodes.isEmpty == false || requirementProjection.blockers.isEmpty == false
        let recoveryConstraintSummaries = lifeContextProjection.hardConstraints.filter {
            $0.title.localizedCaseInsensitiveContains("recovery") || $0.detail.localizedCaseInsensitiveContains("recovery")
        }
        let recoveryNeeded = recoveryConstraintSummaries.isEmpty == false || requirementProjection.blockers.isEmpty == false

        var milestones: [PlanSkeletonMilestone] = []
        var phases: [PlanSkeletonPhase] = []
        var proofMoments: [PlanSkeletonProofMoment] = []
        var reviewMoments: [PlanSkeletonReviewMoment] = []
        var recoveryWindows: [PlanSkeletonRecoveryWindow] = []
        var riskFlags: [PlanSkeletonRiskFlag] = []

        if setupNeeded {
            milestones.append(PlanSkeletonMilestone(
                id: "\(pathID).milestone.setup",
                title: "Set up access and equipment",
                detail: requirementProjection.equipment.isEmpty ? "Make the path usable before execution." : requirementProjection.equipment.map(\.title).joined(separator: ", "),
                orderIndex: milestones.count,
                kind: .setup,
                requirementIDs: requirementProjection.equipment.map(\.id),
                nodeIDs: blockedNodes + missingSourceNodes,
                proofRequired: false,
                reviewRequired: false
            ))
            phases.append(PlanSkeletonPhase(
                id: "\(pathID).phase.setup",
                title: "Setup",
                detail: "Resolve setup work before the main path starts.",
                orderIndex: phases.count,
                milestoneIDs: [milestones.last!.id],
                pathNodeIDs: blockedNodes + missingSourceNodes,
                riskFlagIDs: []
            ))
            riskFlags.append(PlanSkeletonRiskFlag(
                id: "\(pathID).risk.setup",
                title: "Setup risk",
                detail: "The current context does not fully support the path without setup work.",
                severity: 2,
                relatedNodeIDs: blockedNodes + missingSourceNodes,
                relatedRequirementIDs: requirementProjection.equipment.map(\.id)
            ))
        }

        milestones.append(PlanSkeletonMilestone(
            id: "\(pathID).milestone.execution",
            title: "Execute the selected path",
            detail: pathSummary,
            orderIndex: milestones.count,
            kind: .execution,
            requirementIDs: requirementProjection.skills.map(\.id) + requirementProjection.prerequisites.map(\.id) + requirementProjection.accelerators.map(\.id),
            nodeIDs: selectedNodeIDs,
            proofRequired: proofNeeded,
            reviewRequired: reviewNeeded
        ))
        phases.append(PlanSkeletonPhase(
            id: "\(pathID).phase.execution",
            title: "Execution",
            detail: "Follow the selected capability path.",
            orderIndex: phases.count,
            milestoneIDs: [milestones.last!.id],
            pathNodeIDs: selectedNodeIDs,
            riskFlagIDs: []
        ))

        if proofNeeded {
            let proofMoment = PlanSkeletonProofMoment(
                id: "\(pathID).proof",
                title: "Collect proof",
                detail: requirementProjection.proofNeeds.map(\.title).joined(separator: ", "),
                orderIndex: proofMoments.count,
                requirementIDs: requirementProjection.proofNeeds.map(\.id),
                nodeIDs: selectedNodeIDs
            )
            proofMoments.append(proofMoment)
            milestones.append(PlanSkeletonMilestone(
                id: "\(pathID).milestone.proof",
                title: "Capture proof",
                detail: proofMoment.detail,
                orderIndex: milestones.count,
                kind: .proof,
                requirementIDs: proofMoment.requirementIDs,
                nodeIDs: proofMoment.nodeIDs,
                proofRequired: true,
                reviewRequired: reviewNeeded
            ))
            phases.append(PlanSkeletonPhase(
                id: "\(pathID).phase.proof",
                title: "Proof",
                detail: "Collect and preserve proof for the composed path.",
                orderIndex: phases.count,
                milestoneIDs: [milestones.last!.id],
                pathNodeIDs: selectedNodeIDs,
                riskFlagIDs: []
            ))
        }

        if reviewNeeded {
            let reviewReason = staleNodes.isEmpty == false ? "Stale source needs review." : "A blocker or freshness issue needs review."
            let reviewMoment = PlanSkeletonReviewMoment(
                id: "\(pathID).review",
                title: "Review path freshness",
                detail: reviewReason,
                orderIndex: reviewMoments.count,
                requirementIDs: requirementProjection.blockers.map(\.id) + requirementProjection.proofNeeds.map(\.id),
                reason: reviewReason
            )
            reviewMoments.append(reviewMoment)
            milestones.append(PlanSkeletonMilestone(
                id: "\(pathID).milestone.review",
                title: "Review the plan",
                detail: reviewMoment.detail,
                orderIndex: milestones.count,
                kind: .review,
                requirementIDs: reviewMoment.requirementIDs,
                nodeIDs: staleNodes,
                proofRequired: proofNeeded,
                reviewRequired: true
            ))
            phases.append(PlanSkeletonPhase(
                id: "\(pathID).phase.review",
                title: "Review",
                detail: "Review the path after setup or execution.",
                orderIndex: phases.count,
                milestoneIDs: [milestones.last!.id],
                pathNodeIDs: staleNodes,
                riskFlagIDs: []
            ))
            riskFlags.append(PlanSkeletonRiskFlag(
                id: "\(pathID).risk.review",
                title: "Review risk",
                detail: reviewReason,
                severity: 1,
                relatedNodeIDs: staleNodes,
                relatedRequirementIDs: requirementProjection.blockers.map(\.id)
            ))
        }

        if recoveryNeeded {
            let recoveryWindow = PlanSkeletonRecoveryWindow(
                id: "\(pathID).recovery",
                title: "Protect recovery",
                detail: recoveryConstraintSummaries.isEmpty ? "Leave room for recovery." : recoveryConstraintSummaries.map { $0.detail }.joined(separator: ", "),
                orderIndex: recoveryWindows.count,
                protectsRecovery: true,
                relatedNodeIDs: selectedNodeIDs
            )
            recoveryWindows.append(recoveryWindow)
            milestones.append(PlanSkeletonMilestone(
                id: "\(pathID).milestone.recovery",
                title: "Protect recovery",
                detail: recoveryWindow.detail,
                orderIndex: milestones.count,
                kind: .recovery,
                requirementIDs: requirementProjection.blockers.map(\.id),
                nodeIDs: selectedNodeIDs,
                proofRequired: false,
                reviewRequired: reviewNeeded
            ))
            phases.append(PlanSkeletonPhase(
                id: "\(pathID).phase.recovery",
                title: "Recovery",
                detail: "Preserve recovery after path work.",
                orderIndex: phases.count,
                milestoneIDs: [milestones.last!.id],
                pathNodeIDs: selectedNodeIDs,
                riskFlagIDs: []
            ))
        }

        let focusDayLabels = lifeContextProjection.availableOpportunityAnchors.isEmpty
            ? ["midweek"]
            : lifeContextProjection.availableOpportunityAnchors.prefix(2).map(\.title)
        let weeklyCadence = PlanSkeletonWeeklyCadence(
            summary: weeklyCadenceSummary(pathSummary: pathSummary, score: score, setupNeeded: setupNeeded, proofNeeded: proofNeeded, reviewNeeded: reviewNeeded),
            anchorDays: focusDayLabels,
            proofTouchpoints: proofMoments.map(\.title),
            reviewTouchpoints: reviewMoments.map(\.title)
        )

        let feasibilityBand = feasibilityBand(
            score: score,
            blockedNodes: blockedNodes,
            staleNodes: staleNodes,
            missingSourceNodes: missingSourceNodes,
            setupNeeded: setupNeeded
        )

        if riskFlags.isEmpty {
            riskFlags.append(PlanSkeletonRiskFlag(
                id: "\(pathID).risk.base",
                title: "Path risk",
                detail: feasibilityBand.accessibilityLabel,
                severity: feasibilityBand == .impossibleUnderCurrentConstraints ? 3 : (feasibilityBand == .atRisk ? 2 : 0),
                relatedNodeIDs: selectedNodeIDs,
                relatedRequirementIDs: requirementProjection.requirementIDs
            ))
        }

        return PlanSkeleton(
            milestones: milestones,
            phases: phases,
            weeklyCadence: weeklyCadence,
            proofMoments: proofMoments,
            reviewMoments: reviewMoments,
            recoveryWindows: recoveryWindows,
            riskFlags: riskFlags.sorted { lhs, rhs in
                if lhs.severity != rhs.severity {
                    return lhs.severity > rhs.severity
                }
                return lhs.id < rhs.id
            },
            feasibilityBand: feasibilityBand
        )
    }

    private func weeklyCadenceSummary(
        pathSummary: String,
        score: Double,
        setupNeeded: Bool,
        proofNeeded: Bool,
        reviewNeeded: Bool
    ) -> String {
        var parts: [String] = []
        parts.append(score >= 0.75 ? "Weekly cadence can stay steady." : "Weekly cadence should stay compact.")
        if setupNeeded {
            parts.append("Start with access or equipment setup.")
        }
        if proofNeeded {
            parts.append("Keep one proof touchpoint each week.")
        }
        if reviewNeeded {
            parts.append("Add a freshness review before the next sprint.")
        }
        return parts.joined(separator: " ")
    }

    private func feasibilityBand(
        score: Double,
        blockedNodes: [String],
        staleNodes: [String],
        missingSourceNodes: [String],
        setupNeeded: Bool
    ) -> PlanSkeletonFeasibilityBand {
        let hardProblems = blockedNodes.count + missingSourceNodes.count
        if hardProblems >= 4 {
            return .impossibleUnderCurrentConstraints
        }
        if hardProblems >= 2 {
            return .unrealisticWithoutChangingScopeTimeCapacity
        }
        if score >= 0.82 && setupNeeded == false && staleNodes.isEmpty {
            return .comfortablyOnTrack
        }
        if score >= 0.66 && setupNeeded == false && staleNodes.count <= 1 {
            return .onTrack
        }
        if score >= 0.48 {
            return .tightButPossible
        }
        if score >= 0.32 {
            return .atRisk
        }
        return .unrealisticWithoutChangingScopeTimeCapacity
    }

    private func tradeoff(
        from rejectedPath: SourceAtlasCapabilityPath,
        against selectedPath: SourceAtlasCapabilityPath
    ) -> SourceAtlasPathTradeoff {
        let scoreDelta = selectedPath.score - rejectedPath.score
        var advantages: [String] = []
        var drawbacks: [String] = []

        if rejectedPath.selectedPathOverlayIDs != selectedPath.selectedPathOverlayIDs {
            drawbacks.append("Different overlay path.")
        }
        if rejectedPath.blockedNodes.count > selectedPath.blockedNodes.count {
            drawbacks.append("Needs more blocker cleanup.")
        }
        if rejectedPath.staleNodes.count > selectedPath.staleNodes.count {
            drawbacks.append("Carries more stale source.")
        }
        if rejectedPath.missingSourceNodes.count > selectedPath.missingSourceNodes.count {
            drawbacks.append("Depends on more missing source nodes.")
        }
        if rejectedPath.planSkeleton.feasibilityBand != selectedPath.planSkeleton.feasibilityBand {
            drawbacks.append("Different feasibility band: \(rejectedPath.planSkeleton.feasibilityBand.accessibilityLabel).")
        }
        if rejectedPath.score > selectedPath.score {
            advantages.append("Scores higher than the selected path.")
        } else if rejectedPath.score < selectedPath.score {
            drawbacks.append("Scores lower than the selected path by \(String(format: "%.2f", scoreDelta)).")
        }

        if advantages.isEmpty {
            advantages.append("Provides an alternate route if the selected path becomes unavailable.")
        }
        if drawbacks.isEmpty {
            drawbacks.append("No clear advantage over the selected path.")
        }

        return SourceAtlasPathTradeoff(
            id: "\(rejectedPath.id).tradeoff",
            pathID: rejectedPath.id,
            summary: "Rejected in favor of \(selectedPath.id).",
            advantages: advantages,
            drawbacks: drawbacks
        )
    }

    private func explanationSummary(
        for selectedPath: SourceAtlasCapabilityPath,
        alternatives: [SourceAtlasPathTradeoff]
    ) -> String {
        var parts = [selectedPath.pathSummary]
        if alternatives.isEmpty == false {
            parts.append("Compared against \(alternatives.count) alternative path\(alternatives.count == 1 ? "" : "s").")
        }
        if selectedPath.planSkeleton.feasibilityBand != .comfortablyOnTrack {
            parts.append("Feasibility is \(selectedPath.planSkeleton.feasibilityBand.accessibilityLabel.lowercased()).")
        }
        return parts.joined(separator: " ")
    }

    private func explanationReasons(
        for selectedPath: SourceAtlasCapabilityPath,
        alternatives: [SourceAtlasPathTradeoff]
    ) -> [String] {
        var reasons: [String] = []
        if selectedPath.blockedNodes.isEmpty == false {
            reasons.append("Blocked nodes stay visible in the trace: \(selectedPath.blockedNodes.joined(separator: ", ")).")
        }
        if selectedPath.staleNodes.isEmpty == false {
            reasons.append("Stale nodes are preserved for review: \(selectedPath.staleNodes.joined(separator: ", ")).")
        }
        if selectedPath.missingSourceNodes.isEmpty == false {
            reasons.append("Missing source nodes are retained in the trace: \(selectedPath.missingSourceNodes.joined(separator: ", ")).")
        }
        reasons.append("Plan skeleton uses \(selectedPath.planSkeleton.feasibilityBand.accessibilityLabel.lowercased()).")
        reasons.append(contentsOf: alternatives.prefix(2).flatMap(\.drawbacks))
        return reasons
    }

    private struct TraversalSnapshot {
        let selectedNodeIDs: [String]
        let selectedEdgeIDs: [String]
        let traversalTrace: [String]
        let blockedNodes: [String]
        let staleNodes: [String]
        let missingSourceNodes: [String]
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    private static func orderedUniquePreservingOrder(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        var ordered: [String] = []
        for value in values {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.isEmpty == false, seen.insert(trimmed).inserted else {
                continue
            }
            ordered.append(trimmed)
        }
        return ordered
    }

    private static func tokens(_ text: String) -> Set<String> {
        Set(
            text
                .lowercased()
                .unicodeScalars
                .map { CharacterSet.alphanumerics.contains($0) ? String($0) : " " }
                .joined()
                .split(whereSeparator: \.isWhitespace)
                .map(String.init)
                .filter { $0.isEmpty == false }
        )
    }

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}
