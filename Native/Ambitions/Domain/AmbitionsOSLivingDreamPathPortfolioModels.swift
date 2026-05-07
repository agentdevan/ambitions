import Foundation

let ambitionsOSLivingDreamPathPortfolioSchemaVersion =
    "ambitionsos_living_dream_path_portfolio.native.v1"

enum AmbitionsOSLivingDreamPathKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case primary
    case conservative
    case aggressive
    case exploration
    case fallback
    case northStar = "north_star"
}

enum AmbitionsOSLivingDreamPathRiskPosture: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case measured
    case stretch
    case unknown
    case blocked
}

enum AmbitionsOSLivingDreamPathPortfolioReadiness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case readyForCapacityBridge = "ready_for_capacity_bridge"
    case needsIntakeReview = "needs_intake_review"
    case needsSourceReview = "needs_source_review"
    case needsProfessionalReview = "needs_professional_review"
    case needsSafetyReview = "needs_safety_review"
    case needsUserReview = "needs_user_review"
    case blocked
}

enum AmbitionsOSLivingDreamPathPortfolioIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedPortfolio = "malformed_portfolio"
    case malformedCandidate = "malformed_candidate"
    case duplicateCandidateID = "duplicate_candidate_id"
    case intakeNotReady = "intake_not_ready"
    case sourceClaimGraphNotReady = "source_claim_graph_not_ready"
    case missingSourceClaim = "missing_source_claim"
    case sourceClaimNotReady = "source_claim_not_ready"
    case unsafeHandlingLane = "unsafe_handling_lane"
    case missingPrimaryPath = "missing_primary_path"
    case missingConservativePath = "missing_conservative_path"
    case missingFallbackPath = "missing_fallback_path"
    case northStarMissing = "north_star_missing"
    case northStarGuaranteeClaim = "north_star_guarantee_claim"
    case professionalBoundaryNeedsReview = "professional_boundary_needs_review"
    case userReviewMissing = "user_review_missing"
    case guaranteeClaim = "guarantee_claim"
    case activationForbidden = "activation_forbidden"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case userDataServerBoundaryBroken = "user_data_server_boundary_broken"
    case runtimeBoundaryBroken = "runtime_boundary_broken"
}

struct AmbitionsOSLivingDreamPathCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: AmbitionsOSLivingDreamPathKind
    let title: String
    let summary: String
    let handlingLane: AmbitionsOSLivingDreamHandlingLane
    let sourceClaimIDs: [String]
    let requirementIDs: [String]
    let firstProofStep: String
    let northStarOutcomeID: String?
    let riskPosture: AmbitionsOSLivingDreamPathRiskPosture
    let requiresUserReview: Bool
    let sourceReviewRequired: Bool
    let safetyReviewRequired: Bool
    let professionalBoundary: Bool
    let claimsGuarantee: Bool
    let activatesPlan: Bool
    let mutatesCommitments: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        kind: AmbitionsOSLivingDreamPathKind,
        title: String,
        summary: String,
        handlingLane: AmbitionsOSLivingDreamHandlingLane,
        sourceClaimIDs: [String],
        requirementIDs: [String],
        firstProofStep: String,
        northStarOutcomeID: String? = nil,
        riskPosture: AmbitionsOSLivingDreamPathRiskPosture,
        requiresUserReview: Bool = true,
        sourceReviewRequired: Bool = false,
        safetyReviewRequired: Bool = false,
        professionalBoundary: Bool = false,
        claimsGuarantee: Bool = false,
        activatesPlan: Bool = false,
        mutatesCommitments: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamPathPortfolioSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.handlingLane = handlingLane
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.requirementIDs = Self.orderedUnique(requirementIDs)
        self.firstProofStep = firstProofStep.trimmingCharacters(in: .whitespacesAndNewlines)
        self.northStarOutcomeID = northStarOutcomeID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.riskPosture = riskPosture
        self.requiresUserReview = requiresUserReview
        self.sourceReviewRequired = sourceReviewRequired
        self.safetyReviewRequired = safetyReviewRequired
        self.professionalBoundary = professionalBoundary
        self.claimsGuarantee = claimsGuarantee
        self.activatesPlan = activatesPlan
        self.mutatesCommitments = mutatesCommitments
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            summary.isEmpty == false &&
            firstProofStep.isEmpty == false &&
            sourceClaimIDs.isEmpty == false &&
            requirementIDs.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamPathPortfolioSchemaVersion
    }

    var canBeReviewedWithoutActivation: Bool {
        activatesPlan == false &&
            mutatesCommitments == false &&
            claimsGuarantee == false &&
            runtimeBoundary.isValueModelOnly
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLivingDreamPathPortfolio: Codable, Sendable, Equatable, Hashable {
    let id: String
    let intakeEvaluation: AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation
    let sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph
    let northStarOutcome: AmbitionsOSLivingDreamNorthStarOutcome?
    let candidates: [AmbitionsOSLivingDreamPathCandidate]
    let allowsActivation: Bool
    let mutatesCommitments: Bool
    let usesUserDataServer: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        intakeEvaluation: AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation,
        sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph,
        northStarOutcome: AmbitionsOSLivingDreamNorthStarOutcome? = nil,
        candidates: [AmbitionsOSLivingDreamPathCandidate],
        allowsActivation: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamPathPortfolioSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.intakeEvaluation = intakeEvaluation
        self.sourceClaimGraph = sourceClaimGraph
        self.northStarOutcome = northStarOutcome
        self.candidates = candidates.sorted { $0.id < $1.id }
        self.allowsActivation = allowsActivation
        self.mutatesCommitments = mutatesCommitments
        self.usesUserDataServer = usesUserDataServer
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            candidates.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamPathPortfolioSchemaVersion
    }
}

struct AmbitionsOSLivingDreamPathPortfolioEvaluation: Codable, Sendable, Equatable, Hashable {
    let portfolioID: String
    let candidateIDsByKind: [AmbitionsOSLivingDreamPathKind: [String]]
    let reviewRequiredCandidateIDs: [String]
    let blockedCandidateIDs: [String]
    let issues: [AmbitionsOSLivingDreamPathPortfolioIssue]
    let activatesPlans: Bool
    let mutatesCommitments: Bool
    let usesUserDataServer: Bool

    var readiness: AmbitionsOSLivingDreamPathPortfolioReadiness {
        if issues.contains(.runtimeBoundaryBroken) ||
            issues.contains(.userDataServerBoundaryBroken) ||
            issues.contains(.hiddenMutationRisk) ||
            issues.contains(.activationForbidden) ||
            issues.contains(.guaranteeClaim) ||
            issues.contains(.northStarGuaranteeClaim) {
            return .blocked
        }
        if issues.contains(.intakeNotReady) {
            return .needsIntakeReview
        }
        if issues.contains(.sourceClaimGraphNotReady) ||
            issues.contains(.missingSourceClaim) ||
            issues.contains(.sourceClaimNotReady) {
            return .needsSourceReview
        }
        if issues.contains(.professionalBoundaryNeedsReview) {
            return .needsProfessionalReview
        }
        if issues.contains(.unsafeHandlingLane) {
            return .needsSafetyReview
        }
        if issues.contains(.userReviewMissing) ||
            issues.contains(.missingPrimaryPath) ||
            issues.contains(.missingConservativePath) ||
            issues.contains(.missingFallbackPath) ||
            issues.contains(.northStarMissing) {
            return .needsUserReview
        }
        return .readyForCapacityBridge
    }
}

struct AmbitionsOSLivingDreamPathPortfolioValidator: Sendable, Equatable, Hashable {
    func validate(
        portfolio: AmbitionsOSLivingDreamPathPortfolio
    ) -> [AmbitionsOSLivingDreamPathPortfolioIssue] {
        var issues: Set<AmbitionsOSLivingDreamPathPortfolioIssue> = []
        let candidateIDs = portfolio.candidates.map(\.id)
        let readyClaimIDs = Set(portfolio.sourceClaimGraph.claimsReadyForConsequentialRecommendation.map(\.id))
        let allClaimIDs = Set(portfolio.sourceClaimGraph.claims.map(\.id))

        validatePortfolioShape(portfolio, candidateIDs: candidateIDs, issues: &issues)
        validateIntake(portfolio.intakeEvaluation, issues: &issues)
        validateSourceGraph(portfolio.sourceClaimGraph, issues: &issues)
        validateRuntime(portfolio, issues: &issues)
        validateRequiredKinds(portfolio, issues: &issues)

        for candidate in portfolio.candidates {
            validate(
                candidate: candidate,
                readyClaimIDs: readyClaimIDs,
                allClaimIDs: allClaimIDs,
                northStarOutcome: portfolio.northStarOutcome,
                issues: &issues
            )
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func evaluate(
        portfolio: AmbitionsOSLivingDreamPathPortfolio
    ) -> AmbitionsOSLivingDreamPathPortfolioEvaluation {
        let issues = validate(portfolio: portfolio)
        let grouped = Dictionary(grouping: portfolio.candidates, by: \.kind).mapValues {
            $0.map(\.id).sorted()
        }

        return AmbitionsOSLivingDreamPathPortfolioEvaluation(
            portfolioID: portfolio.id,
            candidateIDsByKind: grouped,
            reviewRequiredCandidateIDs: portfolio.candidates.filter(\.requiresUserReview).map(\.id).sorted(),
            blockedCandidateIDs: portfolio.candidates.filter {
                $0.canBeReviewedWithoutActivation == false ||
                    $0.handlingLane == .unsafeBlocked ||
                    $0.handlingLane == .crisisSupport
            }.map(\.id).sorted(),
            issues: issues,
            activatesPlans: portfolio.allowsActivation || portfolio.candidates.contains(where: \.activatesPlan),
            mutatesCommitments: portfolio.mutatesCommitments || portfolio.candidates.contains(where: \.mutatesCommitments),
            usesUserDataServer: portfolio.usesUserDataServer
        )
    }

    private func validatePortfolioShape(
        _ portfolio: AmbitionsOSLivingDreamPathPortfolio,
        candidateIDs: [String],
        issues: inout Set<AmbitionsOSLivingDreamPathPortfolioIssue>
    ) {
        if portfolio.schemaVersion != ambitionsOSLivingDreamPathPortfolioSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if portfolio.isWellFormed == false {
            issues.insert(.malformedPortfolio)
        }
        if Set(candidateIDs).count != candidateIDs.count {
            issues.insert(.duplicateCandidateID)
        }
    }

    private func validateIntake(
        _ intakeEvaluation: AmbitionsOSLivingDreamStartingPositionPrivacyIntakeEvaluation,
        issues: inout Set<AmbitionsOSLivingDreamPathPortfolioIssue>
    ) {
        if intakeEvaluation.readiness != .readyForPathPortfolio ||
            intakeEvaluation.storesUserData ||
            intakeEvaluation.mutatesCommitments ||
            intakeEvaluation.projectsExternally {
            issues.insert(.intakeNotReady)
        }
    }

    private func validateSourceGraph(
        _ sourceClaimGraph: AmbitionsOSLivingDreamSourceClaimGraph,
        issues: inout Set<AmbitionsOSLivingDreamPathPortfolioIssue>
    ) {
        if sourceClaimGraph.validationIssues.isEmpty == false ||
            sourceClaimGraph.claimsReadyForConsequentialRecommendation.isEmpty {
            issues.insert(.sourceClaimGraphNotReady)
        }
    }

    private func validateRuntime(
        _ portfolio: AmbitionsOSLivingDreamPathPortfolio,
        issues: inout Set<AmbitionsOSLivingDreamPathPortfolioIssue>
    ) {
        if portfolio.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }
        if portfolio.allowsActivation {
            issues.insert(.activationForbidden)
        }
        if portfolio.mutatesCommitments {
            issues.insert(.hiddenMutationRisk)
        }
        if portfolio.usesUserDataServer {
            issues.insert(.userDataServerBoundaryBroken)
        }
    }

    private func validateRequiredKinds(
        _ portfolio: AmbitionsOSLivingDreamPathPortfolio,
        issues: inout Set<AmbitionsOSLivingDreamPathPortfolioIssue>
    ) {
        let kinds = Set(portfolio.candidates.map(\.kind))
        if kinds.contains(.primary) == false {
            issues.insert(.missingPrimaryPath)
        }
        if kinds.contains(.conservative) == false {
            issues.insert(.missingConservativePath)
        }
        if kinds.contains(.fallback) == false {
            issues.insert(.missingFallbackPath)
        }
        if kinds.contains(.northStar), portfolio.northStarOutcome == nil {
            issues.insert(.northStarMissing)
        }
        if portfolio.northStarOutcome?.claimsLiteralGuarantee == true {
            issues.insert(.northStarGuaranteeClaim)
        }
    }

    private func validate(
        candidate: AmbitionsOSLivingDreamPathCandidate,
        readyClaimIDs: Set<String>,
        allClaimIDs: Set<String>,
        northStarOutcome: AmbitionsOSLivingDreamNorthStarOutcome?,
        issues: inout Set<AmbitionsOSLivingDreamPathPortfolioIssue>
    ) {
        if candidate.schemaVersion != ambitionsOSLivingDreamPathPortfolioSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if candidate.isWellFormed == false {
            issues.insert(.malformedCandidate)
        }
        if candidate.sourceClaimIDs.contains(where: { allClaimIDs.contains($0) == false }) {
            issues.insert(.missingSourceClaim)
        }
        if candidate.sourceClaimIDs.contains(where: { readyClaimIDs.contains($0) == false }) {
            issues.insert(.sourceClaimNotReady)
        }
        if candidate.handlingLane == .unsafeBlocked || candidate.handlingLane == .crisisSupport {
            issues.insert(.unsafeHandlingLane)
        }
        if candidate.kind == .northStar && candidate.northStarOutcomeID != northStarOutcome?.id {
            issues.insert(.northStarMissing)
        }
        if candidate.professionalBoundary && (candidate.requiresUserReview == false || candidate.sourceReviewRequired) {
            issues.insert(.professionalBoundaryNeedsReview)
        }
        if candidate.requiresUserReview == false {
            issues.insert(.userReviewMissing)
        }
        if candidate.claimsGuarantee {
            issues.insert(.guaranteeClaim)
        }
        if candidate.activatesPlan {
            issues.insert(.activationForbidden)
        }
        if candidate.mutatesCommitments {
            issues.insert(.hiddenMutationRisk)
        }
        if candidate.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }
    }
}
