import Foundation

let ambitionsOSLivingDreamNorthStarSchemaVersion = "ambitionsos_living_dream_north_star.native.v1"

enum AmbitionsOSLivingDreamNorthStarInputKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fantasyImpossible = "fantasy_impossible"
    case symbolicIdentity = "symbolic_identity"
    case unsafeLiteral = "unsafe_literal"
    case impossibleTimeline = "impossible_timeline"
    case abandonedDream = "abandoned_dream"
    case ambiguousMeaning = "ambiguous_meaning"
}

enum AmbitionsOSLivingDreamNorthStarMeaningDimension: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case capability
    case protection
    case justice
    case belonging
    case mastery
    case freedom
    case continuity
    case curiosity
    case care
    case creativity
    case resilience
    case impact
}

enum AmbitionsOSLivingDreamNorthStarLiteralHandling: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case meaningOnly = "meaning_only"
    case neverOperationalize = "never_operationalize"
    case realityCheckRequired = "reality_check_required"
    case clarifyFirst = "clarify_first"
    case safeCandidateReview = "safe_candidate_review"

    var allowsLiteralPlan: Bool {
        self == .safeCandidateReview
    }
}

enum AmbitionsOSLivingDreamNorthStarIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedRequest = "malformed_request"
    case malformedOutcome = "malformed_outcome"
    case wrongHandlingLane = "wrong_handling_lane"
    case missingMeaning = "missing_meaning"
    case missingSafeAlternatives = "missing_safe_alternatives"
    case unsafeLiteralOperationalized = "unsafe_literal_operationalized"
    case sourceReviewMissing = "source_review_missing"
    case privacyReviewMissing = "privacy_review_missing"
    case userReviewMissing = "user_review_missing"
    case literalGuaranteeClaim = "literal_guarantee_claim"
    case professionalBoundaryClaim = "professional_boundary_claim"
    case runtimeBoundaryBroken = "runtime_boundary_broken"
}

struct AmbitionsOSLivingDreamNorthStarRequest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let dreamSummary: String
    let literalPhrase: String
    let inputKind: AmbitionsOSLivingDreamNorthStarInputKind
    let safetyConcerns: [AmbitionsOSLivingDreamSafetyConcern]
    let safetyLane: AmbitionsOSLivingDreamHandlingLane
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let schemaVersion: String

    init(
        id: String,
        dreamSummary: String,
        literalPhrase: String,
        inputKind: AmbitionsOSLivingDreamNorthStarInputKind,
        safetyConcerns: [AmbitionsOSLivingDreamSafetyConcern] = [],
        safetyLane: AmbitionsOSLivingDreamHandlingLane = .northStarExtraction,
        sourceState: HumanProgressSourceState = .userStated,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .needsUserReview,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        schemaVersion: String = ambitionsOSLivingDreamNorthStarSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dreamSummary = dreamSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.literalPhrase = literalPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        self.inputKind = inputKind
        self.safetyConcerns = Array(Set(safetyConcerns)).sorted { $0.rawValue < $1.rawValue }
        self.safetyLane = safetyLane
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            dreamSummary.isEmpty == false &&
            literalPhrase.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamNorthStarSchemaVersion
    }

    var containsUnsafeLiteral: Bool {
        inputKind == .unsafeLiteral ||
            safetyLane == .unsafeBlocked ||
            safetyLane == .crisisSupport ||
            safetyConcerns.contains { $0.isHardBlock }
    }

    var requiresSourceReview: Bool {
        sourceState.canDriveSourceSensitiveRecommendation == false ||
            freshnessState.blocksHighRiskUse
    }

    var requiresPrivacyReview: Bool {
        privacyClass == .sensitive || privacyClass == .externalRedacted
    }
}

struct AmbitionsOSLivingDreamNorthStarOutcome: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let requestID: String
    let primaryLane: AmbitionsOSLivingDreamHandlingLane
    let literalHandling: AmbitionsOSLivingDreamNorthStarLiteralHandling
    let meaningStatement: String
    let dimensions: [AmbitionsOSLivingDreamNorthStarMeaningDimension]
    let safeAlternativeSeeds: [String]
    let blockedLiteralSummary: String
    let preservesIdentityContinuity: Bool
    let requiresUserReview: Bool
    let sourceReviewRequired: Bool
    let privacyReviewRequired: Bool
    let claimsLiteralGuarantee: Bool
    let claimsProfessionalGuidance: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        requestID: String,
        primaryLane: AmbitionsOSLivingDreamHandlingLane = .northStarExtraction,
        literalHandling: AmbitionsOSLivingDreamNorthStarLiteralHandling,
        meaningStatement: String,
        dimensions: [AmbitionsOSLivingDreamNorthStarMeaningDimension],
        safeAlternativeSeeds: [String],
        blockedLiteralSummary: String,
        preservesIdentityContinuity: Bool = true,
        requiresUserReview: Bool = true,
        sourceReviewRequired: Bool = false,
        privacyReviewRequired: Bool = false,
        claimsLiteralGuarantee: Bool = false,
        claimsProfessionalGuidance: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamNorthStarSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requestID = requestID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.primaryLane = primaryLane
        self.literalHandling = literalHandling
        self.meaningStatement = meaningStatement.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dimensions = Array(Set(dimensions)).sorted { $0.rawValue < $1.rawValue }
        self.safeAlternativeSeeds = Self.orderedUnique(safeAlternativeSeeds)
        self.blockedLiteralSummary = blockedLiteralSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.preservesIdentityContinuity = preservesIdentityContinuity
        self.requiresUserReview = requiresUserReview
        self.sourceReviewRequired = sourceReviewRequired
        self.privacyReviewRequired = privacyReviewRequired
        self.claimsLiteralGuarantee = claimsLiteralGuarantee
        self.claimsProfessionalGuidance = claimsProfessionalGuidance
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            requestID.isEmpty == false &&
            meaningStatement.isEmpty == false &&
            dimensions.isEmpty == false &&
            safeAlternativeSeeds.isEmpty == false &&
            blockedLiteralSummary.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamNorthStarSchemaVersion
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLivingDreamNorthStarExtractor: Sendable, Equatable, Hashable {
    func extract(_ request: AmbitionsOSLivingDreamNorthStarRequest) -> AmbitionsOSLivingDreamNorthStarOutcome {
        let dimensions = meaningDimensions(for: request)
        let literalHandling = literalHandling(for: request)

        return AmbitionsOSLivingDreamNorthStarOutcome(
            id: "\(request.id).north-star",
            requestID: request.id,
            literalHandling: literalHandling,
            meaningStatement: meaningStatement(for: dimensions),
            dimensions: dimensions,
            safeAlternativeSeeds: safeAlternativeSeeds(for: request, dimensions: dimensions),
            blockedLiteralSummary: blockedLiteralSummary(for: request, literalHandling: literalHandling),
            sourceReviewRequired: request.requiresSourceReview,
            privacyReviewRequired: request.requiresPrivacyReview
        )
    }

    private func literalHandling(
        for request: AmbitionsOSLivingDreamNorthStarRequest
    ) -> AmbitionsOSLivingDreamNorthStarLiteralHandling {
        if request.containsUnsafeLiteral {
            return .neverOperationalize
        }
        switch request.inputKind {
        case .fantasyImpossible, .symbolicIdentity, .abandonedDream:
            return .meaningOnly
        case .unsafeLiteral:
            return .neverOperationalize
        case .impossibleTimeline:
            return .realityCheckRequired
        case .ambiguousMeaning:
            return .clarifyFirst
        }
    }

    private func meaningDimensions(
        for request: AmbitionsOSLivingDreamNorthStarRequest
    ) -> [AmbitionsOSLivingDreamNorthStarMeaningDimension] {
        let text = "\(request.dreamSummary) \(request.literalPhrase)".lowercased()
        var dimensions: Set<AmbitionsOSLivingDreamNorthStarMeaningDimension> = []

        if text.contains("batman") || text.contains("protect") || text.contains("defend") {
            dimensions.formUnion([.protection, .justice, .capability])
        }
        if text.contains("immortal") || text.contains("forever") || text.contains("lineage") {
            dimensions.formUnion([.continuity, .care, .resilience])
        }
        if text.contains("cult") || text.contains("followers") || text.contains("belong") {
            dimensions.formUnion([.belonging, .impact, .creativity])
        }
        if text.contains("time travel") || text.contains("teleport") || text.contains("space") {
            dimensions.formUnion([.curiosity, .creativity, .freedom])
        }
        if text.contains("master") || text.contains("best") || text.contains("elite") {
            dimensions.formUnion([.mastery, .capability])
        }
        if dimensions.isEmpty {
            dimensions.formUnion([.impact, .resilience])
        }

        return dimensions.sorted { $0.rawValue < $1.rawValue }
    }

    private func meaningStatement(for dimensions: [AmbitionsOSLivingDreamNorthStarMeaningDimension]) -> String {
        let labels = dimensions.map(\.rawValue).joined(separator: ", ")
        return "Treat the literal dream as a signal for \(labels), then review safe ways to honor that direction."
    }

    private func safeAlternativeSeeds(
        for request: AmbitionsOSLivingDreamNorthStarRequest,
        dimensions: [AmbitionsOSLivingDreamNorthStarMeaningDimension]
    ) -> [String] {
        var seeds: Set<String> = []
        if dimensions.contains(.protection) || dimensions.contains(.justice) {
            seeds.formUnion(["community safety training", "emergency preparedness", "lawful service path"])
        }
        if dimensions.contains(.continuity) || dimensions.contains(.care) {
            seeds.formUnion(["health-supporting routine", "family continuity project", "creative body of work"])
        }
        if dimensions.contains(.belonging) || dimensions.contains(.impact) {
            seeds.formUnion(["ethical community building", "nonprofit exploration", "club or local group"])
        }
        if dimensions.contains(.curiosity) || dimensions.contains(.freedom) {
            seeds.formUnion(["science learning path", "engineering project", "story or game design"])
        }
        if request.inputKind == .impossibleTimeline {
            seeds.insert("realistic proof step")
        }
        if seeds.isEmpty {
            seeds.formUnion(["values review", "small proof step", "safe exploration path"])
        }
        return seeds.sorted()
    }

    private func blockedLiteralSummary(
        for request: AmbitionsOSLivingDreamNorthStarRequest,
        literalHandling: AmbitionsOSLivingDreamNorthStarLiteralHandling
    ) -> String {
        switch literalHandling {
        case .neverOperationalize:
            return "The literal request is not turned into steps; only safe redirect meaning is retained."
        case .realityCheckRequired:
            return "The literal timeline needs realism review before any candidate path."
        case .meaningOnly:
            return "The literal version is held as symbolic meaning, not a guarantee or plan."
        case .clarifyFirst:
            return "One clarification is needed before meaning extraction can finish."
        case .safeCandidateReview:
            return "A safe literal candidate still requires user review before activation."
        }
    }
}

struct AmbitionsOSLivingDreamNorthStarValidator: Sendable, Equatable, Hashable {
    func validate(
        request: AmbitionsOSLivingDreamNorthStarRequest,
        outcome: AmbitionsOSLivingDreamNorthStarOutcome
    ) -> [AmbitionsOSLivingDreamNorthStarIssue] {
        var issues: Set<AmbitionsOSLivingDreamNorthStarIssue> = []

        if request.schemaVersion != ambitionsOSLivingDreamNorthStarSchemaVersion ||
            outcome.schemaVersion != ambitionsOSLivingDreamNorthStarSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if request.isWellFormed == false {
            issues.insert(.malformedRequest)
        }
        if outcome.isWellFormed == false || outcome.requestID != request.id {
            issues.insert(.malformedOutcome)
        }
        if outcome.primaryLane != .northStarExtraction {
            issues.insert(.wrongHandlingLane)
        }
        if outcome.meaningStatement.isEmpty || outcome.dimensions.isEmpty {
            issues.insert(.missingMeaning)
        }
        if outcome.safeAlternativeSeeds.isEmpty {
            issues.insert(.missingSafeAlternatives)
        }
        if request.containsUnsafeLiteral && outcome.literalHandling.allowsLiteralPlan {
            issues.insert(.unsafeLiteralOperationalized)
        }
        if request.requiresSourceReview && outcome.sourceReviewRequired == false {
            issues.insert(.sourceReviewMissing)
        }
        if request.requiresPrivacyReview && outcome.privacyReviewRequired == false {
            issues.insert(.privacyReviewMissing)
        }
        if outcome.requiresUserReview == false {
            issues.insert(.userReviewMissing)
        }
        if outcome.claimsLiteralGuarantee {
            issues.insert(.literalGuaranteeClaim)
        }
        if outcome.claimsProfessionalGuidance {
            issues.insert(.professionalBoundaryClaim)
        }
        if outcome.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }
}
