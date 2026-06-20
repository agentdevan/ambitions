import Foundation

let ambitionsOSAlternatePathSchemaVersion = "ambitionsos_alternate_path.native.v1"

enum AmbitionsOSAlternatePathKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case activePath = "active_path"
    case alternatePath = "alternate_path"
    case backupPath = "backup_path"
    case pausedPath = "paused_path"
    case futurePath = "future_path"
    case retiredPath = "retired_path"
    case completedPath = "completed_path"
    case supersededPath = "superseded_path"
    case explorationPath = "exploration_path"
    case fallbackPath = "fallback_path"
    case northStarPath = "north_star_path"
    case sourceCheckFirstPath = "source_check_first_path"
    case professionalBoundaryPath = "professional_boundary_path"

    var requiresSourceReview: Bool {
        switch self {
        case .sourceCheckFirstPath, .professionalBoundaryPath, .northStarPath:
            return true
        case .activePath, .alternatePath, .backupPath, .pausedPath, .futurePath,
             .retiredPath, .completedPath, .supersededPath, .explorationPath,
             .fallbackPath:
            return false
        }
    }
}

enum AmbitionsOSAlternatePathReviewState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case draft
    case needsUserReview = "needs_user_review"
    case needsSourceReview = "needs_source_review"
    case reviewReady = "review_ready"
    case blocked
}

enum AmbitionsOSAlternatePathIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedPortfolio = "malformed_portfolio"
    case malformedPath = "malformed_path"
    case missingStartingPosition = "missing_starting_position"
    case missingCompiledGoalCandidate = "missing_compiled_goal_candidate"
    case missingActivePath = "missing_active_path"
    case missingAlternativePath = "missing_alternative_path"
    case sourceReviewRequired = "source_review_required"
    case proofTransferWithoutOverlap = "proof_transfer_without_overlap"
    case professionalBoundaryReviewRequired = "professional_boundary_review_required"
    case shameLanguage = "shame_language"
    case guaranteedOutcomeOverclaim = "guaranteed_outcome_overclaim"
    case missingPathChangeReceipt = "missing_path_change_receipt"
    case externalProjectionRisk = "external_projection_risk"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSAlternatePathCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: AmbitionsOSAlternatePathKind
    let summary: String
    let requirementSlotIDs: [String]
    let transferableProofReceiptIDs: [String]
    let requirementOverlapIDs: [String]
    let sourceClaimIDs: [String]
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let professionalBoundaryApplies: Bool
    let claimsGuaranteedOutcome: Bool
    let externalProjectionRequested: Bool
    let schemaVersion: String

    init(
        id: String,
        title: String,
        kind: AmbitionsOSAlternatePathKind,
        summary: String,
        requirementSlotIDs: [String] = [],
        transferableProofReceiptIDs: [String] = [],
        requirementOverlapIDs: [String] = [],
        sourceClaimIDs: [String] = [],
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        professionalBoundaryApplies: Bool = false,
        claimsGuaranteedOutcome: Bool = false,
        externalProjectionRequested: Bool = false,
        schemaVersion: String = ambitionsOSAlternatePathSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requirementSlotIDs = Self.orderedUnique(requirementSlotIDs)
        self.transferableProofReceiptIDs = Self.orderedUnique(transferableProofReceiptIDs)
        self.requirementOverlapIDs = Self.orderedUnique(requirementOverlapIDs)
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.professionalBoundaryApplies = professionalBoundaryApplies
        self.claimsGuaranteedOutcome = claimsGuaranteedOutcome
        self.externalProjectionRequested = externalProjectionRequested
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            summary.isEmpty == false &&
            schemaVersion == ambitionsOSAlternatePathSchemaVersion
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    var hasProofTransferSupport: Bool {
        transferableProofReceiptIDs.isEmpty ||
            (requirementOverlapIDs.isEmpty == false && sourceClaimIDs.isEmpty == false)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSPathChangeReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let fromPathID: String
    let toPathID: String
    let reason: String
    let stillCountsProofReceiptIDs: [String]
    let requiresUserReview: Bool
    let schemaVersion: String

    init(
        id: String,
        fromPathID: String,
        toPathID: String,
        reason: String,
        stillCountsProofReceiptIDs: [String] = [],
        requiresUserReview: Bool = true,
        schemaVersion: String = ambitionsOSAlternatePathSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fromPathID = fromPathID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.toPathID = toPathID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.stillCountsProofReceiptIDs = Self.orderedUnique(stillCountsProofReceiptIDs)
        self.requiresUserReview = requiresUserReview
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            fromPathID.isEmpty == false &&
            toPathID.isEmpty == false &&
            reason.isEmpty == false &&
            requiresUserReview &&
            schemaVersion == ambitionsOSAlternatePathSchemaVersion
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSPathPortfolio: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let startingPositionSnapshotID: String?
    let compiledGoalCandidateID: String?
    let localGoalPackIDs: [String]
    let paths: [AmbitionsOSAlternatePathCandidate]
    let pathChangeReceipts: [AmbitionsOSPathChangeReceipt]
    let preservesNorthStar: Bool
    let mutatesLifeGraph: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        title: String,
        startingPositionSnapshotID: String?,
        compiledGoalCandidateID: String?,
        localGoalPackIDs: [String],
        paths: [AmbitionsOSAlternatePathCandidate],
        pathChangeReceipts: [AmbitionsOSPathChangeReceipt] = [],
        preservesNorthStar: Bool = true,
        mutatesLifeGraph: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSAlternatePathSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.startingPositionSnapshotID = startingPositionSnapshotID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.compiledGoalCandidateID = compiledGoalCandidateID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localGoalPackIDs = Self.orderedUnique(localGoalPackIDs)
        self.paths = paths
        self.pathChangeReceipts = pathChangeReceipts
        self.preservesNorthStar = preservesNorthStar
        self.mutatesLifeGraph = mutatesLifeGraph
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var validationIssues: [AmbitionsOSAlternatePathIssue] {
        AmbitionsOSAlternatePathValidator().validate(self)
    }

    var reviewState: AmbitionsOSAlternatePathReviewState {
        let issues = validationIssues
        if issues.contains(.hiddenMutationRisk) ||
            issues.contains(.runtimeStoreBehavior) ||
            issues.contains(.guaranteedOutcomeOverclaim) ||
            issues.contains(.shameLanguage) {
            return .blocked
        }
        if issues.contains(.sourceReviewRequired) ||
            issues.contains(.professionalBoundaryReviewRequired) {
            return .needsSourceReview
        }
        if issues.isEmpty {
            return .reviewReady
        }
        return .needsUserReview
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSAlternatePathValidator: Sendable, Equatable, Hashable {
    func validate(_ portfolio: AmbitionsOSPathPortfolio) -> [AmbitionsOSAlternatePathIssue] {
        var issues: Set<AmbitionsOSAlternatePathIssue> = []

        if portfolio.schemaVersion != ambitionsOSAlternatePathSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if portfolio.id.isEmpty || portfolio.title.isEmpty || portfolio.paths.isEmpty {
            issues.insert(.malformedPortfolio)
        }
        if portfolio.startingPositionSnapshotID?.isEmpty != false {
            issues.insert(.missingStartingPosition)
        }
        if portfolio.compiledGoalCandidateID?.isEmpty != false {
            issues.insert(.missingCompiledGoalCandidate)
        }
        if portfolio.paths.contains(where: { $0.kind == .activePath }) == false {
            issues.insert(.missingActivePath)
        }
        if portfolio.paths.contains(where: { $0.kind != .activePath }) == false {
            issues.insert(.missingAlternativePath)
        }
        if portfolio.mutatesLifeGraph {
            issues.insert(.hiddenMutationRisk)
        }
        if portfolio.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }

        let hasChangedPath = portfolio.paths.contains {
            $0.kind == .pausedPath || $0.kind == .retiredPath || $0.kind == .supersededPath
        }
        if hasChangedPath && portfolio.pathChangeReceipts.contains(where: \.isWellFormed) == false {
            issues.insert(.missingPathChangeReceipt)
        }

        for path in portfolio.paths {
            validate(path: path, issues: &issues)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validate(
        path: AmbitionsOSAlternatePathCandidate,
        issues: inout Set<AmbitionsOSAlternatePathIssue>
    ) {
        if path.schemaVersion != ambitionsOSAlternatePathSchemaVersion || path.isWellFormed == false {
            issues.insert(.malformedPath)
        }
        if path.claimsGuaranteedOutcome {
            issues.insert(.guaranteedOutcomeOverclaim)
        }
        if containsForbiddenShameLanguage(path.title) || containsForbiddenShameLanguage(path.summary) {
            issues.insert(.shameLanguage)
        }
        if path.hasProofTransferSupport == false {
            issues.insert(.proofTransferWithoutOverlap)
        }
        if path.kind.requiresSourceReview &&
            (path.sourceState.canDriveSourceSensitiveRecommendation == false ||
             path.freshnessState.blocksHighRiskUse ||
             path.reviewState.blocksAutomaticMutation) {
            issues.insert(.sourceReviewRequired)
        }
        if path.professionalBoundaryApplies &&
            (path.sourceState != .sourceBacked || path.reviewState != .ready) {
            issues.insert(.professionalBoundaryReviewRequired)
        }
        if path.externalProjectionRequested &&
            path.privacyClass == .sensitive &&
            path.isExternalProjectionSafe == false {
            issues.insert(.externalProjectionRisk)
        }
    }

    private func containsForbiddenShameLanguage(_ value: String) -> Bool {
        let normalized = value.lowercased()
        return ["quit", "failed", "wasted", "start over", "gave up"].contains {
            normalized.contains($0)
        }
    }
}
