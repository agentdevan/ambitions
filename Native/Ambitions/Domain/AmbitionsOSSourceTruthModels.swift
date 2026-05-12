import Foundation

let ambitionsOSSourceTruthSchemaVersion = "ambitionsos_source_truth.native.v1"

enum AmbitionsOSSourceTruthClaimState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case officialSourceBacked = "official_source_backed"
    case semiOfficialSourceBacked = "semi_official_source_backed"
    case expertSourceBacked = "expert_source_backed"
    case communitySourceBacked = "community_source_backed"
    case sourcedSourceBacked = "sourced_source_backed"
    case userConfirmed = "user_confirmed"
    case userStated = "user_stated"
    case importedNeedsReview = "imported_needs_review"
    case inferredNeedsReview = "inferred_needs_review"
    case verifiedByLocalProof = "verified_by_local_proof"
    case sourceNeeded = "source_needed"
    case stale
    case contradicted
    case changed
    case conflicting
    case disputed
    case unsupported
    case revoked
    case unknown

    var isSourceBacked: Bool {
        switch self {
        case .officialSourceBacked, .semiOfficialSourceBacked, .expertSourceBacked, .communitySourceBacked, .sourcedSourceBacked:
            return true
        default:
            return false
        }
    }

    var isFormalRecommendationCandidate: Bool {
        switch self {
        case .officialSourceBacked, .semiOfficialSourceBacked, .expertSourceBacked, .communitySourceBacked:
            return true
        default:
            return false
        }
    }

    var isBlockingState: Bool {
        switch self {
        case .changed, .conflicting, .disputed, .contradicted, .unsupported, .revoked, .sourceNeeded, .stale, .unknown:
            return true
        default:
            return false
        }
    }

    func canTransition(
        to target: AmbitionsOSSourceTruthClaimState,
        hasProvenanceEvidence: Bool,
        hasLocalProofEvidence: Bool
    ) -> Bool {
        if self == target {
            return true
        }

        let legalTargets: Set<AmbitionsOSSourceTruthClaimState>
        switch self {
        case .sourceNeeded:
            legalTargets = [
                .sourceNeeded,
                .sourcedSourceBacked,
                .importedNeedsReview,
                .inferredNeedsReview,
                .userStated,
                .userConfirmed,
                .unknown,
                .unsupported,
                .stale,
                .disputed,
                .contradicted,
                .revoked
            ]
        case .sourcedSourceBacked:
            legalTargets = [
                .verifiedByLocalProof,
                .officialSourceBacked,
                .semiOfficialSourceBacked,
                .expertSourceBacked,
                .communitySourceBacked,
                .sourceNeeded,
                .unknown,
                .unsupported,
                .stale,
                .disputed,
                .contradicted,
                .revoked
            ]
        case .verifiedByLocalProof:
            legalTargets = [
                .officialSourceBacked,
                .semiOfficialSourceBacked,
                .expertSourceBacked,
                .communitySourceBacked,
                .sourceNeeded,
                .unknown,
                .unsupported,
                .stale,
                .disputed,
                .contradicted,
                .revoked
            ]
        case .officialSourceBacked, .semiOfficialSourceBacked, .expertSourceBacked, .communitySourceBacked:
            legalTargets = [
                .officialSourceBacked,
                .semiOfficialSourceBacked,
                .expertSourceBacked,
                .communitySourceBacked,
                .sourcedSourceBacked,
                .verifiedByLocalProof,
                .sourceNeeded,
                .unknown,
                .unsupported,
                .changed,
                .disputed,
                .revoked
            ]
        case .userConfirmed, .importedNeedsReview, .inferredNeedsReview, .userStated:
            legalTargets = [
                .sourceNeeded,
                .sourcedSourceBacked,
                .verifiedByLocalProof,
                .disputed,
                .contradicted,
                .revoked
            ]
        case .changed, .conflicting, .disputed, .contradicted, .unsupported, .unknown, .stale:
            legalTargets = [.sourceNeeded, .unknown, .unsupported, .disputed, .contradicted, .revoked]
        case .revoked:
            legalTargets = [.sourceNeeded, .unknown, .unsupported]
        }

        guard legalTargets.contains(target) else {
            return false
        }
        if target == .verifiedByLocalProof && hasLocalProofEvidence == false {
            return false
        }
        if target.isSourceBacked && hasProvenanceEvidence == false {
            return false
        }
        if target.isFormalRecommendationCandidate && hasProvenanceEvidence == false {
            return false
        }
        return true
    }
}

enum AmbitionsOSSourceQualityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case official
    case institutional
    case government
    case professionalBody = "professional_body"
    case primaryDocument = "primary_document"
    case secondaryReference = "secondary_reference"
    case expertInterpretation = "expert_interpretation"
    case community
    case userProvided = "user_provided"
    case modelInferred = "model_inferred"
    case unknown

    var canSupportOfficialClaim: Bool {
        switch self {
        case .official, .institutional, .government, .professionalBody, .primaryDocument:
            return true
        case .secondaryReference, .expertInterpretation, .community, .userProvided, .modelInferred, .unknown:
            return false
        }
    }
}

enum AmbitionsOSSourceTruthIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedClaim = "malformed_claim"
    case duplicateClaimID = "duplicate_claim_id"
    case missingSourceEvidence = "missing_source_evidence"
    case officialClaimWithoutApprovedSource = "official_claim_without_approved_source"
    case userProvidedClaimTreatedAsOfficial = "user_provided_claim_treated_as_official"
    case staleHighRiskClaim = "stale_high_risk_claim"
    case unresolvedConflict = "unresolved_conflict"
    case revokedClaimActive = "revoked_claim_active"
    case silentClaimMutation = "silent_claim_mutation"
    case sourceCertificationOverclaim = "source_certification_overclaim"
    case privateExternalProjectionRisk = "private_external_projection_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
    case invalidClaimTransition = "invalid_claim_transition"
}

struct AmbitionsOSSourceReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: SourceAtlasSourceKind
    let qualityState: AmbitionsOSSourceQualityState
    let approvedForOfficialClaims: Bool

    init(
        id: String,
        kind: SourceAtlasSourceKind,
        qualityState: AmbitionsOSSourceQualityState,
        approvedForOfficialClaims: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.qualityState = qualityState
        self.approvedForOfficialClaims = approvedForOfficialClaims
    }

    var canSupportOfficialClaim: Bool {
        kind == .official &&
            qualityState.canSupportOfficialClaim &&
            approvedForOfficialClaims
    }
}

struct AmbitionsOSSourceTruthClaim: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let text: String
    let scopeID: String
    let state: AmbitionsOSSourceTruthClaimState
    let sourceQualityState: AmbitionsOSSourceQualityState
    let freshnessState: HumanProgressFreshnessState
    let riskClass: SourceAtlasRiskClass
    let sourceIDs: [String]
    let sourcePackIDs: [String]
    let supersedesClaimIDs: [String]
    let conflictClaimIDs: [String]
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let lastReviewedAt: String?
    let schemaVersion: String

    init(
        id: String,
        text: String,
        scopeID: String,
        state: AmbitionsOSSourceTruthClaimState,
        sourceQualityState: AmbitionsOSSourceQualityState,
        freshnessState: HumanProgressFreshnessState,
        riskClass: SourceAtlasRiskClass,
        sourceIDs: [String] = [],
        sourcePackIDs: [String] = [],
        supersedesClaimIDs: [String] = [],
        conflictClaimIDs: [String] = [],
        reviewState: HumanProgressReviewState = .needsSourceReview,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        lastReviewedAt: String? = nil,
        schemaVersion: String = ambitionsOSSourceTruthSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.scopeID = scopeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.state = state
        self.sourceQualityState = sourceQualityState
        self.freshnessState = freshnessState
        self.riskClass = riskClass
        self.sourceIDs = Self.orderedUnique(sourceIDs)
        self.sourcePackIDs = Self.orderedUnique(sourcePackIDs)
        self.supersedesClaimIDs = Self.orderedUnique(supersedesClaimIDs)
        self.conflictClaimIDs = Self.orderedUnique(conflictClaimIDs)
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.lastReviewedAt = lastReviewedAt
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            text.isEmpty == false &&
            scopeID.isEmpty == false &&
            schemaVersion == ambitionsOSSourceTruthSchemaVersion
    }

    var requiresHumanReview: Bool {
        reviewState != .ready ||
            state == .sourceNeeded ||
            state == .importedNeedsReview ||
            state == .inferredNeedsReview ||
            state == .sourcedSourceBacked ||
            state == .verifiedByLocalProof ||
            state == .conflicting ||
            state == .disputed ||
            state == .contradicted ||
            state == .unknown ||
            freshnessState.blocksHighRiskUse
    }

    var canBeTreatedAsCurrentOfficial: Bool {
        state == .officialSourceBacked &&
            sourceQualityState.canSupportOfficialClaim &&
            freshnessState == .current &&
            reviewState == .ready &&
            sourceIDs.isEmpty == false
    }

    var canDriveSourceSensitiveRecommendation: Bool {
        switch state {
        case .officialSourceBacked, .semiOfficialSourceBacked, .expertSourceBacked, .userConfirmed:
            return freshnessState.blocksHighRiskUse == false &&
                reviewState == .ready &&
                privacyClass != .deletePending &&
                (state == .userConfirmed || sourceIDs.isEmpty == false)
        case .communitySourceBacked, .userStated, .importedNeedsReview,
             .inferredNeedsReview, .sourceNeeded, .stale, .changed, .conflicting,
             .disputed, .unsupported, .revoked, .unknown, .sourcedSourceBacked,
             .verifiedByLocalProof, .contradicted:
            return false
        }
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSSourceTruthTransition: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let claimID: String
    let fromState: AmbitionsOSSourceTruthClaimState
    let toState: AmbitionsOSSourceTruthClaimState
    let reason: String
    let receiptIDs: [String]
    let changedSourceIDs: [String]
    let userReviewed: Bool
    let localProofEvidenceIDs: [String]

    init(
        claimID: String,
        fromState: AmbitionsOSSourceTruthClaimState,
        toState: AmbitionsOSSourceTruthClaimState,
        reason: String,
        receiptIDs: [String] = [],
        changedSourceIDs: [String] = [],
        userReviewed: Bool,
        localProofEvidenceIDs: [String] = [],
        id: String? = nil
    ) {
        self.claimID = claimID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fromState = fromState
        self.toState = toState
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.changedSourceIDs = Self.orderedUnique(changedSourceIDs)
        self.userReviewed = userReviewed
        self.localProofEvidenceIDs = Self.orderedUnique(localProofEvidenceIDs)
        self.id = id ?? "\(self.claimID):\(fromState.rawValue):\(toState.rawValue)"
    }

    var isReviewable: Bool {
        claimID.isEmpty == false &&
            reason.isEmpty == false &&
            ((receiptIDs.isEmpty == false) || (localProofEvidenceIDs.isEmpty == false)) &&
            userReviewed
    }

    var hasProvenanceEvidence: Bool {
        changedSourceIDs.isEmpty == false
    }

    var hasLocalProofEvidence: Bool {
        localProofEvidenceIDs.isEmpty == false
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSSourceTruthLedger: Codable, Sendable, Equatable, Hashable {
    let claims: [AmbitionsOSSourceTruthClaim]
    let sources: [AmbitionsOSSourceReference]
    let transitions: [AmbitionsOSSourceTruthTransition]
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let claimsSourceCertification: Bool

    init(
        claims: [AmbitionsOSSourceTruthClaim],
        sources: [AmbitionsOSSourceReference],
        transitions: [AmbitionsOSSourceTruthTransition] = [],
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        claimsSourceCertification: Bool = false
    ) {
        self.claims = claims
        self.sources = sources
        self.transitions = transitions
        self.runtimeBoundary = runtimeBoundary
        self.claimsSourceCertification = claimsSourceCertification
    }

    var validationIssues: [AmbitionsOSSourceTruthIssue] {
        AmbitionsOSSourceTruthValidator().validate(self)
    }

    var isValidForReviewUse: Bool {
        validationIssues.isEmpty
    }
}

struct AmbitionsOSSourceTruthValidator: Sendable, Equatable, Hashable {
    func validate(_ ledger: AmbitionsOSSourceTruthLedger) -> [AmbitionsOSSourceTruthIssue] {
        var issues: Set<AmbitionsOSSourceTruthIssue> = []

        if ledger.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }
        if ledger.claimsSourceCertification {
            issues.insert(.sourceCertificationOverclaim)
        }

        let claimIDs = ledger.claims.map(\.id)
        if Set(claimIDs).count != claimIDs.count {
            issues.insert(.duplicateClaimID)
        }
        let claimsByID = ledger.claims.reduce(into: [String: AmbitionsOSSourceTruthClaim]()) { result, claim in
            guard result[claim.id] == nil else { return }
            result[claim.id] = claim
        }

        let officialSourceIDs = Set(
            ledger.sources
                .filter(\.canSupportOfficialClaim)
                .map(\.id)
        )

        for claim in ledger.claims {
            validate(claim: claim, officialSourceIDs: officialSourceIDs, issues: &issues)
        }

        for transition in ledger.transitions {
            guard let claim = claimsByID[transition.claimID] else {
                issues.insert(.silentClaimMutation)
                continue
            }
            if transition.fromState != claim.state {
                issues.insert(.invalidClaimTransition)
                continue
            }
            guard transition.isReviewable else {
                issues.insert(.silentClaimMutation)
                continue
            }
            if transition.fromState.canTransition(
                to: transition.toState,
                hasProvenanceEvidence: transition.hasProvenanceEvidence || claim.sourceIDs.isEmpty == false,
                hasLocalProofEvidence: transition.hasLocalProofEvidence
            ) == false {
                issues.insert(.invalidClaimTransition)
            }
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validate(
        claim: AmbitionsOSSourceTruthClaim,
        officialSourceIDs: Set<String>,
        issues: inout Set<AmbitionsOSSourceTruthIssue>
    ) {
        if claim.schemaVersion != ambitionsOSSourceTruthSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if claim.isWellFormed == false {
            issues.insert(.malformedClaim)
        }
        if claim.sourceIDs.isEmpty && claim.state != .sourceNeeded {
            issues.insert(.missingSourceEvidence)
        }
        if claim.state == .officialSourceBacked && officialSourceIDs.isDisjoint(with: claim.sourceIDs) {
            issues.insert(.officialClaimWithoutApprovedSource)
        }
        if claim.state == .officialSourceBacked && claim.sourceQualityState == .userProvided {
            issues.insert(.userProvidedClaimTreatedAsOfficial)
        }
        if claim.riskClass.requiresStrictReview && claim.freshnessState.blocksHighRiskUse {
            issues.insert(.staleHighRiskClaim)
        }
        if claim.state == .conflicting || claim.state == .disputed || claim.conflictClaimIDs.isEmpty == false {
            issues.insert(.unresolvedConflict)
        }
        if claim.state == .revoked && claim.reviewState != .rejectedByUser {
            issues.insert(.revokedClaimActive)
        }
        if claim.privacyClass == .sensitive && claim.isExternalProjectionSafe == false {
            issues.insert(.privateExternalProjectionRisk)
        }
    }
}
