import Foundation

let ambitionsOSOptionValueSchemaVersion = "ambitionsos_option_value.native.v1"

enum AmbitionsOSOptionValueFamily: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case optionValueEntry = "option_value_entry"
    case pathTransfer = "path_transfer"
    case transferProofLink = "transfer_proof_link"
    case requirementOverlap = "requirement_overlap"
    case adjacentPathSignal = "adjacent_path_signal"
    case northStarContinuity = "north_star_continuity"
    case parkedDream = "parked_dream"
    case revivalPrompt = "revival_prompt"
    case stillCountsReceipt = "still_counts_receipt"
    case pivotReviewReceipt = "pivot_review_receipt"
}

enum AmbitionsOSOptionValueTransferState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case directlyReusable = "directly_reusable"
    case partiallyReusable = "partially_reusable"
    case supportsNarrative = "supports_narrative"
    case inspirationOnly = "inspiration_only"
    case needsSourceReview = "needs_source_review"
    case needsMoreProof = "needs_more_proof"
    case needsRequirementReview = "needs_requirement_review"
    case stale
    case conflicting
    case notTransferable = "not_transferable"
    case unknown
}

enum AmbitionsOSRequirementOverlapState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sameRequirement = "same_requirement"
    case adjacentRequirement = "adjacent_requirement"
    case supportingSkill = "supporting_skill"
    case supportingProof = "supporting_proof"
    case narrativeOnly = "narrative_only"
    case sourceNeeded = "source_needed"
    case freshnessNeeded = "freshness_needed"
    case humanReviewNeeded = "human_review_needed"
    case conflicting
    case notApplicable = "not_applicable"
    case unknown

    var supportsProofTransfer: Bool {
        switch self {
        case .sameRequirement, .adjacentRequirement, .supportingSkill, .supportingProof:
            return true
        case .narrativeOnly, .sourceNeeded, .freshnessNeeded, .humanReviewNeeded,
             .conflicting, .notApplicable, .unknown:
            return false
        }
    }
}

enum AmbitionsOSOptionValueIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedEntry = "malformed_entry"
    case missingPathReferences = "missing_path_references"
    case sourceReviewRequired = "source_review_required"
    case proofTransferWithoutOverlap = "proof_transfer_without_overlap"
    case privacyReviewRequired = "privacy_review_required"
    case silentMutationRisk = "silent_mutation_risk"
    case guaranteedOutcomeOverclaim = "guaranteed_outcome_overclaim"
    case fakeCompletionRisk = "fake_completion_risk"
    case northStarNotUserReviewed = "north_star_not_user_reviewed"
    case harmfulLiteralPlanRisk = "harmful_literal_plan_risk"
    case destinyLanguage = "destiny_language"
    case shameLanguage = "shame_language"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSOptionValueEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourcePathID: String
    let targetPathID: String
    let family: AmbitionsOSOptionValueFamily
    let transferState: AmbitionsOSOptionValueTransferState
    let requirementOverlapState: AmbitionsOSRequirementOverlapState
    let proofReceiptIDs: [String]
    let sourceClaimIDs: [String]
    let northStarContinuity: String
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let mutationPermissionState: AmbitionsOSOptionValueMutationPermission
    let claimsGuaranteedOutcome: Bool
    let claimsCompletion: Bool
    let validatesLiteralUnsafePlan: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let surfaceLanguageSamples: [String]
    let schemaVersion: String

    init(
        id: String,
        sourcePathID: String,
        targetPathID: String,
        family: AmbitionsOSOptionValueFamily,
        transferState: AmbitionsOSOptionValueTransferState,
        requirementOverlapState: AmbitionsOSRequirementOverlapState,
        proofReceiptIDs: [String] = [],
        sourceClaimIDs: [String] = [],
        northStarContinuity: String,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .needsUserReview,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        mutationPermissionState: AmbitionsOSOptionValueMutationPermission = .reviewOnly,
        claimsGuaranteedOutcome: Bool = false,
        claimsCompletion: Bool = false,
        validatesLiteralUnsafePlan: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = ["This still counts as context."],
        schemaVersion: String = ambitionsOSOptionValueSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourcePathID = sourcePathID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.targetPathID = targetPathID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.family = family
        self.transferState = transferState
        self.requirementOverlapState = requirementOverlapState
        self.proofReceiptIDs = Self.orderedUnique(proofReceiptIDs)
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.northStarContinuity = northStarContinuity.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.mutationPermissionState = mutationPermissionState
        self.claimsGuaranteedOutcome = claimsGuaranteedOutcome
        self.claimsCompletion = claimsCompletion
        self.validatesLiteralUnsafePlan = validatesLiteralUnsafePlan
        self.runtimeBoundary = runtimeBoundary
        self.surfaceLanguageSamples = surfaceLanguageSamples.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        self.schemaVersion = schemaVersion
    }

    var validationIssues: [AmbitionsOSOptionValueIssue] {
        AmbitionsOSOptionValueValidator().validate(self)
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            sourcePathID.isEmpty == false &&
            targetPathID.isEmpty == false &&
            northStarContinuity.isEmpty == false &&
            schemaVersion == ambitionsOSOptionValueSchemaVersion
    }

    var hasProofTransferSupport: Bool {
        proofReceiptIDs.isEmpty ||
            (requirementOverlapState.supportsProofTransfer && sourceClaimIDs.isEmpty == false)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

enum AmbitionsOSOptionValueMutationPermission: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case reviewOnly = "review_only"
    case userApproved = "user_approved"
    case userRejected = "user_rejected"
    case deferred
    case needsSourceReview = "needs_source_review"

    var mutatesWithoutReview: Bool {
        self == .userApproved
    }
}

struct AmbitionsOSOptionValueValidator: Sendable, Equatable, Hashable {
    func validate(_ entry: AmbitionsOSOptionValueEntry) -> [AmbitionsOSOptionValueIssue] {
        var issues: Set<AmbitionsOSOptionValueIssue> = []

        if entry.schemaVersion != ambitionsOSOptionValueSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if entry.isWellFormed == false {
            issues.insert(.malformedEntry)
        }
        if entry.sourcePathID.isEmpty || entry.targetPathID.isEmpty {
            issues.insert(.missingPathReferences)
        }
        if entry.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }
        if entry.mutationPermissionState.mutatesWithoutReview {
            issues.insert(.silentMutationRisk)
        }
        if entry.claimsGuaranteedOutcome {
            issues.insert(.guaranteedOutcomeOverclaim)
        }
        if entry.claimsCompletion && entry.family == .stillCountsReceipt {
            issues.insert(.fakeCompletionRisk)
        }
        if entry.family == .northStarContinuity && entry.reviewState != .ready {
            issues.insert(.northStarNotUserReviewed)
        }
        if entry.validatesLiteralUnsafePlan {
            issues.insert(.harmfulLiteralPlanRisk)
        }
        if entry.hasProofTransferSupport == false {
            issues.insert(.proofTransferWithoutOverlap)
        }
        if entry.transferState == .needsSourceReview ||
            entry.requirementOverlapState == .sourceNeeded ||
            entry.freshnessState.blocksHighRiskUse ||
            entry.sourceState.canDriveSourceSensitiveRecommendation == false {
            issues.insert(.sourceReviewRequired)
        }
        if entry.privacyClass == .sensitive && entry.reviewState != .ready {
            issues.insert(.privacyReviewRequired)
        }
        if entry.surfaceLanguageSamples.contains(where: containsDestinyLanguage) {
            issues.insert(.destinyLanguage)
        }
        if entry.surfaceLanguageSamples.contains(where: containsShameLanguage) {
            issues.insert(.shameLanguage)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func containsDestinyLanguage(_ value: String) -> Bool {
        let normalized = value.lowercased()
        return ["destined", "meant to", "guaranteed", "certain"].contains {
            normalized.contains($0)
        }
    }

    private func containsShameLanguage(_ value: String) -> Bool {
        let normalized = value.lowercased()
        return ["wasted", "failed", "gave up", "quit"].contains {
            normalized.contains($0)
        }
    }
}
