import Foundation

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
                if transition.isReviewable == false {
                    issues.insert(.silentClaimMutation)
                }
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
