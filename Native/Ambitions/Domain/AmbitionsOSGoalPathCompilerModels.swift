import Foundation

let ambitionsOSGoalPathCompilerSchemaVersion = "ambitionsos_goal_path_compiler.native.v1"

enum AmbitionsOSGoalPathClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case quickTask = "quick_task"
    case oneStepGoal = "one_step_goal"
    case projectGoal = "project_goal"
    case longRangeGoal = "long_range_goal"
    case regulatedGoal = "regulated_goal"
    case lifeDefiningGoal = "life_defining_goal"

    var requiresSourceReviewForRequirements: Bool {
        self == .regulatedGoal || self == .lifeDefiningGoal || self == .longRangeGoal
    }
}

enum AmbitionsOSGoalPathRequirementKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case hardRequirement = "hard_requirement"
    case softRequirement = "soft_requirement"
    case blocker
    case assumption
    case proofNeeded = "proof_needed"
    case sourceNeeded = "source_needed"
}

enum AmbitionsOSGoalPathActivationReview: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case draft
    case needsUserReview = "needs_user_review"
    case needsSourceReview = "needs_source_review"
    case reviewReady = "review_ready"
    case blocked
}

enum AmbitionsOSGoalPathCompilerIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedCandidate = "malformed_candidate"
    case malformedStage = "malformed_stage"
    case malformedRequirement = "malformed_requirement"
    case missingStartingPosition = "missing_starting_position"
    case sourceReviewRequired = "source_review_required"
    case proofReviewRequired = "proof_review_required"
    case privacyReviewRequired = "privacy_review_required"
    case autoActivationRisk = "auto_activation_risk"
    case officialRequirementOverclaim = "official_requirement_overclaim"
    case professionalBoundaryReviewRequired = "professional_boundary_review_required"
    case runtimeMutationBehavior = "runtime_mutation_behavior"
    case externalProjectionRisk = "external_projection_risk"
}

struct AmbitionsOSGoalPathRequirementSlot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: AmbitionsOSGoalPathRequirementKind
    let blocking: Bool
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let sourceClaimIDs: [String]
    let proofReceiptIDs: [String]
    let schemaVersion: String

    init(
        id: String,
        title: String,
        kind: AmbitionsOSGoalPathRequirementKind,
        blocking: Bool,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .current,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sourceClaimIDs: [String] = [],
        proofReceiptIDs: [String] = [],
        schemaVersion: String = ambitionsOSGoalPathCompilerSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.blocking = blocking
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.proofReceiptIDs = Self.orderedUnique(proofReceiptIDs)
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            schemaVersion == ambitionsOSGoalPathCompilerSchemaVersion
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    var canDriveCompiledRequirement: Bool {
        isWellFormed &&
            reviewState == .ready &&
            privacyClass != .deletePending &&
            freshnessState.blocksHighRiskUse == false &&
            (kind == .sourceNeeded || sourceState.canDriveSourceSensitiveRecommendation)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSGoalPathStageContract: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let orderIndex: Int
    let requirementIDs: [String]
    let proofNeededIDs: [String]
    let schemaVersion: String

    init(
        id: String,
        title: String,
        orderIndex: Int,
        requirementIDs: [String],
        proofNeededIDs: [String] = [],
        schemaVersion: String = ambitionsOSGoalPathCompilerSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.orderIndex = orderIndex
        self.requirementIDs = Self.orderedUnique(requirementIDs)
        self.proofNeededIDs = Self.orderedUnique(proofNeededIDs)
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            orderIndex >= 0 &&
            schemaVersion == ambitionsOSGoalPathCompilerSchemaVersion
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSGoalPathCompiledCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let goalClass: AmbitionsOSGoalPathClass
    let startingPositionSnapshotID: String?
    let stages: [AmbitionsOSGoalPathStageContract]
    let requirements: [AmbitionsOSGoalPathRequirementSlot]
    let activationReview: AmbitionsOSGoalPathActivationReview
    let autoActivates: Bool
    let claimsOfficialRequirements: Bool
    let professionalBoundaryApplies: Bool
    let externalProjectionRequested: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        title: String,
        goalClass: AmbitionsOSGoalPathClass,
        startingPositionSnapshotID: String?,
        stages: [AmbitionsOSGoalPathStageContract],
        requirements: [AmbitionsOSGoalPathRequirementSlot],
        activationReview: AmbitionsOSGoalPathActivationReview = .draft,
        autoActivates: Bool = false,
        claimsOfficialRequirements: Bool = false,
        professionalBoundaryApplies: Bool = false,
        externalProjectionRequested: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSGoalPathCompilerSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.goalClass = goalClass
        self.startingPositionSnapshotID = startingPositionSnapshotID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.stages = stages
        self.requirements = requirements
        self.activationReview = activationReview
        self.autoActivates = autoActivates
        self.claimsOfficialRequirements = claimsOfficialRequirements
        self.professionalBoundaryApplies = professionalBoundaryApplies
        self.externalProjectionRequested = externalProjectionRequested
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            stages.isEmpty == false &&
            schemaVersion == ambitionsOSGoalPathCompilerSchemaVersion
    }

    var reviewProjection: AmbitionsOSGoalPathActivationReview {
        let issues = AmbitionsOSGoalPathCompilerValidator().validate(self)
        if issues.contains(.runtimeMutationBehavior) ||
            issues.contains(.autoActivationRisk) ||
            issues.contains(.officialRequirementOverclaim) {
            return .blocked
        }
        if issues.contains(.sourceReviewRequired) ||
            issues.contains(.professionalBoundaryReviewRequired) {
            return .needsSourceReview
        }
        if issues.contains(.privacyReviewRequired) ||
            issues.contains(.proofReviewRequired) ||
            issues.contains(.missingStartingPosition) {
            return .needsUserReview
        }
        return .reviewReady
    }
}

struct AmbitionsOSGoalPathCompilerValidator: Sendable, Equatable, Hashable {
    func validate(_ candidate: AmbitionsOSGoalPathCompiledCandidate) -> [AmbitionsOSGoalPathCompilerIssue] {
        var issues: Set<AmbitionsOSGoalPathCompilerIssue> = []

        if candidate.schemaVersion != ambitionsOSGoalPathCompilerSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if candidate.isWellFormed == false {
            issues.insert(.malformedCandidate)
        }
        if candidate.startingPositionSnapshotID?.isEmpty != false {
            issues.insert(.missingStartingPosition)
        }
        if candidate.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeMutationBehavior)
        }
        if candidate.autoActivates || candidate.activationReview == .reviewReady && candidate.autoActivates {
            issues.insert(.autoActivationRisk)
        }
        if candidate.claimsOfficialRequirements {
            issues.insert(.officialRequirementOverclaim)
        }
        if candidate.professionalBoundaryApplies &&
            candidate.requirements.contains(where: { $0.sourceState != .sourceBacked || $0.reviewState != .ready }) {
            issues.insert(.professionalBoundaryReviewRequired)
        }

        for stage in candidate.stages {
            validate(stage: stage, issues: &issues)
        }
        for requirement in candidate.requirements {
            validate(requirement: requirement, candidate: candidate, issues: &issues)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validate(
        stage: AmbitionsOSGoalPathStageContract,
        issues: inout Set<AmbitionsOSGoalPathCompilerIssue>
    ) {
        if stage.schemaVersion != ambitionsOSGoalPathCompilerSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if stage.isWellFormed == false {
            issues.insert(.malformedStage)
        }
    }

    private func validate(
        requirement: AmbitionsOSGoalPathRequirementSlot,
        candidate: AmbitionsOSGoalPathCompiledCandidate,
        issues: inout Set<AmbitionsOSGoalPathCompilerIssue>
    ) {
        if requirement.schemaVersion != ambitionsOSGoalPathCompilerSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if requirement.isWellFormed == false {
            issues.insert(.malformedRequirement)
        }
        if requirement.kind == .proofNeeded && requirement.proofReceiptIDs.isEmpty {
            issues.insert(.proofReviewRequired)
        }
        if requirement.reviewState.blocksAutomaticMutation {
            issues.insert(.privacyReviewRequired)
        }
        if candidate.goalClass.requiresSourceReviewForRequirements &&
            requirement.kind != .sourceNeeded &&
            (requirement.sourceState.canDriveSourceSensitiveRecommendation == false ||
             requirement.freshnessState.blocksHighRiskUse) {
            issues.insert(.sourceReviewRequired)
        }
        if candidate.externalProjectionRequested &&
            requirement.privacyClass == .sensitive &&
            requirement.isExternalProjectionSafe == false {
            issues.insert(.externalProjectionRisk)
        }
    }
}
