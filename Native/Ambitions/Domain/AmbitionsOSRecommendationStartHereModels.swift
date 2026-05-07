import Foundation

let ambitionsOSRecommendationStartHereSchemaVersion = "ambitionsos_recommendation_start_here.native.v1"

enum AmbitionsOSStartHereRecommendationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case startHere = "start_here"
    case recommendedStep = "recommended_step"
    case sourceCheck = "source_check"
    case proofReview = "proof_review"
    case clarification
    case recovery
    case stillCounts = "still_counts"
    case reviewLater = "review_later"
}

enum AmbitionsOSStartHereControlAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case start
    case open
    case adjust
    case makeSmaller = "make_smaller"
    case reviewLater = "review_later"
    case notNow = "not_now"
    case explainMore = "explain_more"
}

enum AmbitionsOSRecommendationFitState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fits
    case reviewable
    case sourceNeeded = "source_needed"
    case proofNeeded = "proof_needed"
    case blocked
}

enum AmbitionsOSRecommendationStartHereIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedRecommendation = "malformed_recommendation"
    case missingSourceLabel = "missing_source_label"
    case sourceReviewRequired = "source_review_required"
    case staleSourceReviewRequired = "stale_source_review_required"
    case proofTrustReviewRequired = "proof_trust_review_required"
    case controlPlaneBlocksRecommendation = "control_plane_blocks_recommendation"
    case missingExplanation = "missing_explanation"
    case missingUserControl = "missing_user_control"
    case genericPriorityOnly = "generic_priority_only"
    case confidenceScoreExposed = "confidence_score_exposed"
    case guaranteedOutcomeLanguage = "guaranteed_outcome_language"
    case harmfulRecommendationLanguage = "harmful_recommendation_language"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case privateExternalProjectionRisk = "private_external_projection_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSStartHereRecommendation: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: AmbitionsOSStartHereRecommendationKind
    let surface: AmbitionsOSControlPlaneSurface
    let recommendedObjectID: String
    let sourceLabel: String
    let sourceClaims: [AmbitionsOSSourceTruthClaim]
    let proofTrustReceipts: [AmbitionsOSProofTrustReceipt]
    let controlClassification: AmbitionsOSControlPlaneClassification
    let fitState: AmbitionsOSRecommendationFitState
    let whyNow: [String]
    let advances: [String]
    let protects: [String]
    let assumptions: [String]
    let notChosen: [String]
    let controlActions: [AmbitionsOSStartHereControlAction]
    let exposesConfidenceScore: Bool
    let usesGenericPriorityOnly: Bool
    let claimsGuaranteedOutcome: Bool
    let mutatesPlansAutomatically: Bool
    let privacyClass: HumanProgressPrivacyClass
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let surfaceLanguageSamples: [String]
    let schemaVersion: String

    init(
        id: String,
        title: String,
        kind: AmbitionsOSStartHereRecommendationKind,
        surface: AmbitionsOSControlPlaneSurface,
        recommendedObjectID: String,
        sourceLabel: String,
        sourceClaims: [AmbitionsOSSourceTruthClaim],
        proofTrustReceipts: [AmbitionsOSProofTrustReceipt],
        controlClassification: AmbitionsOSControlPlaneClassification,
        fitState: AmbitionsOSRecommendationFitState,
        whyNow: [String],
        advances: [String] = [],
        protects: [String] = [],
        assumptions: [String] = [],
        notChosen: [String] = [],
        controlActions: [AmbitionsOSStartHereControlAction],
        exposesConfidenceScore: Bool = false,
        usesGenericPriorityOnly: Bool = false,
        claimsGuaranteedOutcome: Bool = false,
        mutatesPlansAutomatically: Bool = false,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = [],
        schemaVersion: String = ambitionsOSRecommendationStartHereSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.surface = surface
        self.recommendedObjectID = recommendedObjectID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceLabel = sourceLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceClaims = sourceClaims
        self.proofTrustReceipts = proofTrustReceipts
        self.controlClassification = controlClassification
        self.fitState = fitState
        self.whyNow = Self.orderedUnique(whyNow)
        self.advances = Self.orderedUnique(advances)
        self.protects = Self.orderedUnique(protects)
        self.assumptions = Self.orderedUnique(assumptions)
        self.notChosen = Self.orderedUnique(notChosen)
        self.controlActions = Array(Set(controlActions)).sorted { $0.rawValue < $1.rawValue }
        self.exposesConfidenceScore = exposesConfidenceScore
        self.usesGenericPriorityOnly = usesGenericPriorityOnly
        self.claimsGuaranteedOutcome = claimsGuaranteedOutcome
        self.mutatesPlansAutomatically = mutatesPlansAutomatically
        self.privacyClass = privacyClass
        self.runtimeBoundary = runtimeBoundary
        self.surfaceLanguageSamples = surfaceLanguageSamples
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            recommendedObjectID.isEmpty == false &&
            schemaVersion == ambitionsOSRecommendationStartHereSchemaVersion
    }

    var hasPlainExplanation: Bool {
        whyNow.isEmpty == false &&
            (advances.isEmpty == false || protects.isEmpty == false || assumptions.isEmpty == false)
    }

    var hasUserControl: Bool {
        controlActions.isEmpty == false
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSStartHereRecommendationValidator: Sendable, Equatable, Hashable {
    func validate(_ recommendation: AmbitionsOSStartHereRecommendation) -> [AmbitionsOSRecommendationStartHereIssue] {
        var issues: Set<AmbitionsOSRecommendationStartHereIssue> = []

        validateSchemaAndShape(recommendation, issues: &issues)
        validateSourceClaims(recommendation.sourceClaims, issues: &issues)
        validateProofReceipts(recommendation.proofTrustReceipts, issues: &issues)
        validateControlAndExplanation(recommendation, issues: &issues)
        validateRuntimeAndPrivacy(recommendation, issues: &issues)
        validateLanguage(recommendation, issues: &issues)

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validateSchemaAndShape(
        _ recommendation: AmbitionsOSStartHereRecommendation,
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        if recommendation.schemaVersion != ambitionsOSRecommendationStartHereSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if recommendation.isWellFormed == false {
            issues.insert(.malformedRecommendation)
        }
        if recommendation.sourceLabel.isEmpty || recommendation.sourceClaims.isEmpty {
            issues.insert(.missingSourceLabel)
        }
    }

    private func validateSourceClaims(
        _ claims: [AmbitionsOSSourceTruthClaim],
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        for claim in claims {
            if claim.canDriveSourceSensitiveRecommendation == false {
                issues.insert(.sourceReviewRequired)
            }
            if claim.freshnessState.blocksHighRiskUse {
                issues.insert(.staleSourceReviewRequired)
            }
        }
    }

    private func validateProofReceipts(
        _ receipts: [AmbitionsOSProofTrustReceipt],
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        let proofValidator = AmbitionsOSProofTrustValidator()
        for receipt in receipts {
            if proofValidator.validate(receipt: receipt).isEmpty == false {
                issues.insert(.proofTrustReviewRequired)
            }
        }
    }

    private func validateControlAndExplanation(
        _ recommendation: AmbitionsOSStartHereRecommendation,
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        if recommendation.controlClassification.blocksRecommendation {
            issues.insert(.controlPlaneBlocksRecommendation)
        }
        if recommendation.hasPlainExplanation == false {
            issues.insert(.missingExplanation)
        }
        if recommendation.hasUserControl == false {
            issues.insert(.missingUserControl)
        }
        if recommendation.usesGenericPriorityOnly {
            issues.insert(.genericPriorityOnly)
        }
    }

    private func validateRuntimeAndPrivacy(
        _ recommendation: AmbitionsOSStartHereRecommendation,
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        if recommendation.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }
        if recommendation.mutatesPlansAutomatically {
            issues.insert(.hiddenMutationRisk)
        }
        if recommendation.privacyClass == .sensitive && recommendation.isExternalProjectionSafe == false {
            issues.insert(.privateExternalProjectionRisk)
        }
    }

    private func validateLanguage(
        _ recommendation: AmbitionsOSStartHereRecommendation,
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        if recommendation.exposesConfidenceScore {
            issues.insert(.confidenceScoreExposed)
        }
        if recommendation.claimsGuaranteedOutcome {
            issues.insert(.guaranteedOutcomeLanguage)
        }

        let blocked = [
            "ai " + "confidence",
            "model " + "confidence",
            "productivity " + "score",
            "best " + "possible",
            "next " + "best " + "move",
            "guaranteed",
            "you " + "failed",
            "over" + "due"
        ]
        if recommendation.surfaceLanguageSamples.contains(where: { sample in
            let normalized = sample.lowercased()
            return blocked.contains(where: normalized.contains)
        }) {
            issues.insert(.harmfulRecommendationLanguage)
        }
    }
}
