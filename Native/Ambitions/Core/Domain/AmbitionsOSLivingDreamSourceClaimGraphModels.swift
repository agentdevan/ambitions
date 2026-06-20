import Foundation

let ambitionsOSLivingDreamSourceClaimGraphSchemaVersion = "ambitionsos_living_dream_source_claim_graph.native.v1"

enum AmbitionsOSLivingDreamClaimType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case eligibility
    case requirement
    case deadline
    case cost
    case risk
    case safetyBoundary = "safety_boundary"
    case professionalBoundary = "professional_boundary"
    case jurisdictionRule = "jurisdiction_rule"
    case freshnessMarker = "freshness_marker"
    case userContext = "user_context"
}

enum AmbitionsOSLivingDreamClaimAuthorityLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case official
    case institutional
    case expert
    case maintainerCurated = "maintainer_curated"
    case community
    case userProvided = "user_provided"
    case modelInferred = "model_inferred"
    case unknown

    var requiresApprovedSource: Bool {
        switch self {
        case .official, .institutional:
            return true
        case .expert, .maintainerCurated, .community, .userProvided, .modelInferred, .unknown:
            return false
        }
    }
}

enum AmbitionsOSLivingDreamSourceConflictState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case possible
    case confirmed
    case disputed
    case superseded
    case revoked

    var blocksConsequentialUse: Bool {
        switch self {
        case .none:
            return false
        case .possible, .confirmed, .disputed, .superseded, .revoked:
            return true
        }
    }
}

enum AmbitionsOSLivingDreamClaimQualityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case draft
    case sourceAttached = "source_attached"
    case schemaValid = "schema_valid"
    case reviewed
    case officialSourceBacked = "official_source_backed"
    case stale
    case conflict
    case withdrawn
    case professionalReviewRequired = "professional_review_required"
    case localOnly = "local_only"
    case verifiedByLocalProof = "verified_by_local_proof"

    var isSourceBacked: Bool {
        switch self {
        case .officialSourceBacked, .reviewed:
            return true
        default:
            return false
        }
    }

    var allowsConsequentialUse: Bool {
        switch self {
        case .officialSourceBacked, .reviewed:
            return true
        case .draft, .sourceAttached, .schemaValid, .stale, .conflict,
             .withdrawn, .professionalReviewRequired, .localOnly, .verifiedByLocalProof:
            return false
        }
    }

    func canTransition(to target: AmbitionsOSLivingDreamClaimQualityState, hasProvenanceEvidence: Bool, hasLocalProofEvidence: Bool) -> Bool {
        if self == target {
            return true
        }

        let legalTargets: Set<AmbitionsOSLivingDreamClaimQualityState>
        switch self {
        case .draft:
            legalTargets = [.sourceAttached, .schemaValid, .localOnly, .withdrawn]
        case .sourceAttached:
            legalTargets = [.schemaValid, .stale, .conflict, .withdrawn, .localOnly]
        case .schemaValid:
            legalTargets = [.reviewed, .conflict, .withdrawn, .stale, .verifiedByLocalProof]
        case .reviewed:
            legalTargets = [.officialSourceBacked, .withdrawn, .professionalReviewRequired, .conflict]
        case .officialSourceBacked:
            legalTargets = [.officialSourceBacked, .stale, .conflict, .withdrawn]
        case .stale:
            legalTargets = [.conflict, .withdrawn]
        case .conflict:
            legalTargets = [.withdrawn, .verifiedByLocalProof]
        case .withdrawn:
            legalTargets = [.verifiedByLocalProof, .professionalReviewRequired, .draft]
        case .professionalReviewRequired:
            legalTargets = [.withdrawn, .verifiedByLocalProof]
        case .localOnly:
            legalTargets = [.draft, .withdrawn, .verifiedByLocalProof]
        case .verifiedByLocalProof:
            legalTargets = [.officialSourceBacked, .withdrawn, .conflict]
        }

        guard legalTargets.contains(target) else {
            return false
        }
        if target == .verifiedByLocalProof && hasLocalProofEvidence == false {
            return false
        }
        if target == .officialSourceBacked && hasProvenanceEvidence == false {
            return false
        }
        return true
    }

    var isReviewedEnoughForConsequentialUse: Bool {
        switch self {
        case .reviewed, .officialSourceBacked:
            return true
        case .draft, .sourceAttached, .schemaValid, .stale, .conflict,
             .withdrawn, .professionalReviewRequired, .localOnly, .verifiedByLocalProof:
            return false
        }
    }
}

enum AmbitionsOSLivingDreamSourceClaimGraphIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedSourceReference = "malformed_source_reference"
    case malformedClaim = "malformed_claim"
    case duplicateClaimID = "duplicate_claim_id"
    case missingSourceReference = "missing_source_reference"
    case officialClaimWithoutApprovedSource = "official_claim_without_approved_source"
    case highRiskClaimNotReviewReady = "high_risk_claim_not_review_ready"
    case staleConsequentialClaim = "stale_consequential_claim"
    case unresolvedConflict = "unresolved_conflict"
    case supersededClaimActive = "superseded_claim_active"
    case professionalBoundaryMissing = "professional_boundary_missing"
    case professionalAdviceClaim = "professional_advice_claim"
    case sourceCertificationOverclaim = "source_certification_overclaim"
    case userDataServerBoundaryBroken = "user_data_server_boundary_broken"
    case runtimeBoundaryBroken = "runtime_boundary_broken"
}

struct AmbitionsOSLivingDreamSourceClaimReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: SourceAtlasSourceKind
    let locator: String
    let retrievedAt: String?
    let approvedForOfficialClaims: Bool
    let reviewState: HumanProgressReviewState

    init(
        id: String,
        title: String,
        kind: SourceAtlasSourceKind,
        locator: String,
        retrievedAt: String? = nil,
        approvedForOfficialClaims: Bool = false,
        reviewState: HumanProgressReviewState = .needsSourceReview
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.locator = locator.trimmingCharacters(in: .whitespacesAndNewlines)
        self.retrievedAt = retrievedAt
        self.approvedForOfficialClaims = approvedForOfficialClaims
        self.reviewState = reviewState
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            locator.isEmpty == false
    }

    var canSupportOfficialClaim: Bool {
        kind == .official &&
            approvedForOfficialClaims &&
            reviewState == .ready
    }
}

struct AmbitionsOSLivingDreamFreshnessPolicy: Codable, Sendable, Equatable, Hashable {
    let reviewIntervalDays: Int
    let staleBlocksConsequentialUse: Bool
    let expiresBlocksConsequentialUse: Bool

    init(
        reviewIntervalDays: Int,
        staleBlocksConsequentialUse: Bool = true,
        expiresBlocksConsequentialUse: Bool = true
    ) {
        self.reviewIntervalDays = reviewIntervalDays
        self.staleBlocksConsequentialUse = staleBlocksConsequentialUse
        self.expiresBlocksConsequentialUse = expiresBlocksConsequentialUse
    }

    var isWellFormed: Bool {
        reviewIntervalDays > 0
    }
}

struct AmbitionsOSLivingDreamSourceClaim: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let claimType: AmbitionsOSLivingDreamClaimType
    let value: String
    let unit: String?
    let jurisdiction: String
    let authorityLevel: AmbitionsOSLivingDreamClaimAuthorityLevel
    let sourceRefIDs: [String]
    let sourceState: HumanProgressSourceState
    let freshnessPolicy: AmbitionsOSLivingDreamFreshnessPolicy
    let freshnessState: HumanProgressFreshnessState
    let lastVerified: String?
    let effectiveDate: String?
    let expiresAt: String?
    let supersededByClaimID: String?
    let professionalBoundary: Bool
    let sourceConflictState: AmbitionsOSLivingDreamSourceConflictState
    let claimQualityState: AmbitionsOSLivingDreamClaimQualityState
    let riskClass: SourceAtlasRiskClass
    let reviewState: HumanProgressReviewState
    let claimsProfessionalAdvice: Bool
    let schemaVersion: String

    init(
        id: String,
        claimType: AmbitionsOSLivingDreamClaimType,
        value: String,
        unit: String? = nil,
        jurisdiction: String,
        authorityLevel: AmbitionsOSLivingDreamClaimAuthorityLevel,
        sourceRefIDs: [String],
        sourceState: HumanProgressSourceState,
        freshnessPolicy: AmbitionsOSLivingDreamFreshnessPolicy,
        freshnessState: HumanProgressFreshnessState,
        lastVerified: String?,
        effectiveDate: String?,
        expiresAt: String? = nil,
        supersededByClaimID: String? = nil,
        professionalBoundary: Bool = false,
        sourceConflictState: AmbitionsOSLivingDreamSourceConflictState = .none,
        claimQualityState: AmbitionsOSLivingDreamClaimQualityState,
        riskClass: SourceAtlasRiskClass,
        reviewState: HumanProgressReviewState = .needsSourceReview,
        claimsProfessionalAdvice: Bool = false,
        schemaVersion: String = ambitionsOSLivingDreamSourceClaimGraphSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.claimType = claimType
        self.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        self.unit = unit?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.jurisdiction = jurisdiction.trimmingCharacters(in: .whitespacesAndNewlines)
        self.authorityLevel = authorityLevel
        self.sourceRefIDs = Self.orderedUnique(sourceRefIDs)
        self.sourceState = sourceState
        self.freshnessPolicy = freshnessPolicy
        self.freshnessState = freshnessState
        self.lastVerified = lastVerified
        self.effectiveDate = effectiveDate
        self.expiresAt = expiresAt
        self.supersededByClaimID = supersededByClaimID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.professionalBoundary = professionalBoundary
        self.sourceConflictState = sourceConflictState
        self.claimQualityState = claimQualityState
        self.riskClass = riskClass
        self.reviewState = reviewState
        self.claimsProfessionalAdvice = claimsProfessionalAdvice
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            value.isEmpty == false &&
            jurisdiction.isEmpty == false &&
            sourceRefIDs.isEmpty == false &&
            freshnessPolicy.isWellFormed &&
            schemaVersion == ambitionsOSLivingDreamSourceClaimGraphSchemaVersion
    }

    var requiresProfessionalBoundary: Bool {
        riskClass.requiresStrictReview ||
            claimType == .professionalBoundary ||
            authorityLevel == .official ||
            authorityLevel == .institutional
    }

    var canDriveConsequentialRecommendation: Bool {
        sourceState.canDriveSourceSensitiveRecommendation &&
            freshnessState.blocksHighRiskUse == false &&
            sourceConflictState.blocksConsequentialUse == false &&
            claimQualityState.isReviewedEnoughForConsequentialUse &&
            reviewState == .ready &&
            claimsProfessionalAdvice == false &&
            (requiresProfessionalBoundary == false || professionalBoundary)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLivingDreamSourceClaimGraph: Codable, Sendable, Equatable, Hashable {
    let claims: [AmbitionsOSLivingDreamSourceClaim]
    let sourceRefs: [AmbitionsOSLivingDreamSourceClaimReference]
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let claimsOfficialVerification: Bool
    let usesUserDataServer: Bool

    init(
        claims: [AmbitionsOSLivingDreamSourceClaim],
        sourceRefs: [AmbitionsOSLivingDreamSourceClaimReference],
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        claimsOfficialVerification: Bool = false,
        usesUserDataServer: Bool = false
    ) {
        self.claims = claims
        self.sourceRefs = sourceRefs
        self.runtimeBoundary = runtimeBoundary
        self.claimsOfficialVerification = claimsOfficialVerification
        self.usesUserDataServer = usesUserDataServer
    }

    var validationIssues: [AmbitionsOSLivingDreamSourceClaimGraphIssue] {
        AmbitionsOSLivingDreamSourceClaimGraphValidator().validate(self)
    }

    var claimsReadyForConsequentialRecommendation: [AmbitionsOSLivingDreamSourceClaim] {
        guard validationIssues.isEmpty else { return [] }
        return claims.filter(\.canDriveConsequentialRecommendation)
    }
}

struct AmbitionsOSLivingDreamSourceClaimGraphValidator: Sendable, Equatable, Hashable {
    func validate(
        _ graph: AmbitionsOSLivingDreamSourceClaimGraph
    ) -> [AmbitionsOSLivingDreamSourceClaimGraphIssue] {
        var issues: Set<AmbitionsOSLivingDreamSourceClaimGraphIssue> = []

        if graph.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }
        if graph.usesUserDataServer {
            issues.insert(.userDataServerBoundaryBroken)
        }
        if graph.claimsOfficialVerification {
            issues.insert(.sourceCertificationOverclaim)
        }

        let sourceRefIDs = graph.sourceRefs.map(\.id)
        let sourceRefsByID = graph.sourceRefs.reduce(into: [String: AmbitionsOSLivingDreamSourceClaimReference]()) { result, sourceRef in
            guard result[sourceRef.id] == nil else { return }
            result[sourceRef.id] = sourceRef
        }
        if graph.sourceRefs.contains(where: { $0.isWellFormed == false }) ||
            Set(sourceRefIDs).count != sourceRefIDs.count {
            issues.insert(.malformedSourceReference)
        }

        let claimIDs = graph.claims.map(\.id)
        if Set(claimIDs).count != claimIDs.count {
            issues.insert(.duplicateClaimID)
        }

        for claim in graph.claims {
            validate(claim: claim, sourceRefsByID: sourceRefsByID, issues: &issues)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validate(
        claim: AmbitionsOSLivingDreamSourceClaim,
        sourceRefsByID: [String: AmbitionsOSLivingDreamSourceClaimReference],
        issues: inout Set<AmbitionsOSLivingDreamSourceClaimGraphIssue>
    ) {
        if claim.schemaVersion != ambitionsOSLivingDreamSourceClaimGraphSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if claim.isWellFormed == false {
            issues.insert(.malformedClaim)
        }
        if claim.sourceRefIDs.contains(where: { sourceRefsByID[$0] == nil }) {
            issues.insert(.missingSourceReference)
        }
        if claim.authorityLevel.requiresApprovedSource {
            let approvedRefs = claim.sourceRefIDs.compactMap { sourceRefsByID[$0] }.filter(\.canSupportOfficialClaim)
            if approvedRefs.isEmpty {
                issues.insert(.officialClaimWithoutApprovedSource)
            }
        }
        if claim.riskClass.requiresStrictReview &&
            (claim.reviewState != .ready || claim.claimQualityState.isReviewedEnoughForConsequentialUse == false) {
            issues.insert(.highRiskClaimNotReviewReady)
        }
        if claim.freshnessPolicy.staleBlocksConsequentialUse && claim.freshnessState.blocksHighRiskUse {
            issues.insert(.staleConsequentialClaim)
        }
        if claim.sourceConflictState.blocksConsequentialUse {
            issues.insert(.unresolvedConflict)
        }
        if claim.sourceConflictState == .superseded && claim.supersededByClaimID == nil {
            issues.insert(.supersededClaimActive)
        }
        if claim.requiresProfessionalBoundary && claim.professionalBoundary == false {
            issues.insert(.professionalBoundaryMissing)
        }
        if claim.claimsProfessionalAdvice {
            issues.insert(.professionalAdviceClaim)
        }
    }
}
