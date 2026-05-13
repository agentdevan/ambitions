import Foundation

let ambitionsOSLivingDreamTodayBridgeSchemaVersion =
    "ambitionsos_living_dream_today_bridge.native.v1"

enum AmbitionsOSLivingDreamTodayStepKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case recommendedStep = "recommended_step"
    case proofStep = "proof_step"
    case sourceReview = "source_review"
    case closureReview = "closure_review"
    case recoveryStep = "recovery_step"
}

enum AmbitionsOSLivingDreamTodayBridgeReadiness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case readyForToday = "ready_for_today"
    case needsCapacityReview = "needs_capacity_review"
    case needsSourceReview = "needs_source_review"
    case needsProofReview = "needs_proof_review"
    case needsClosureReview = "needs_closure_review"
    case needsUserReview = "needs_user_review"
    case blocked
}

enum AmbitionsOSLivingDreamTodayBridgeIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedBridge = "malformed_bridge"
    case capacityBridgeNotReady = "capacity_bridge_not_ready"
    case tooManyTodaySteps = "too_many_today_steps"
    case missingRecommendedStep = "missing_recommended_step"
    case missingProofOrReviewStep = "missing_proof_or_review_step"
    case missingClosurePrompt = "missing_closure_prompt"
    case punitiveClosureLanguage = "punitive_closure_language"
    case sourceReviewRequired = "source_review_required"
    case staleSourceReviewRequired = "stale_source_review_required"
    case proofTrustReviewRequired = "proof_trust_review_required"
    case missingUserControl = "missing_user_control"
    case genericPriorityOnly = "generic_priority_only"
    case confidenceScoreExposed = "confidence_score_exposed"
    case guaranteedOutcomeLanguage = "guaranteed_outcome_language"
    case harmfulRecommendationLanguage = "harmful_recommendation_language"
    case activationForbidden = "activation_forbidden"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case userDataServerBoundaryBroken = "user_data_server_boundary_broken"
    case runtimeBoundaryBroken = "runtime_boundary_broken"
}

struct AmbitionsOSLivingDreamTodayStep: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let candidateID: String
    let commitmentID: String
    let title: String
    let kind: AmbitionsOSLivingDreamTodayStepKind
    let estimatedMinutes: Int
    let sourceClaimIDs: [String]
    let proofReceiptIDs: [String]
    let closurePromptID: String?
    let recommendationID: String?
    let allowsActivation: Bool
    let mutatesCommitments: Bool
    let usesUserDataServer: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        candidateID: String,
        commitmentID: String,
        title: String,
        kind: AmbitionsOSLivingDreamTodayStepKind,
        estimatedMinutes: Int,
        sourceClaimIDs: [String] = [],
        proofReceiptIDs: [String] = [],
        closurePromptID: String? = nil,
        recommendationID: String? = nil,
        allowsActivation: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamTodayBridgeSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.candidateID = candidateID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.commitmentID = commitmentID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.estimatedMinutes = estimatedMinutes
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.proofReceiptIDs = Self.orderedUnique(proofReceiptIDs)
        self.closurePromptID = closurePromptID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recommendationID = recommendationID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.allowsActivation = allowsActivation
        self.mutatesCommitments = mutatesCommitments
        self.usesUserDataServer = usesUserDataServer
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            candidateID.isEmpty == false &&
            commitmentID.isEmpty == false &&
            title.isEmpty == false &&
            estimatedMinutes > 0 &&
            schemaVersion == ambitionsOSLivingDreamTodayBridgeSchemaVersion
    }

    var canCloseLoop: Bool {
        closurePromptID?.isEmpty == false
    }

    var carriesProofOrReview: Bool {
        proofReceiptIDs.isEmpty == false ||
            kind == .proofStep ||
            kind == .sourceReview ||
            kind == .closureReview
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLivingDreamTodayBridge: Codable, Sendable, Equatable, Hashable {
    let id: String
    let capacityBridge: AmbitionsOSLivingDreamCapacityBridge
    let todaySteps: [AmbitionsOSLivingDreamTodayStep]
    let recommendations: [AmbitionsOSStartHereRecommendation]
    let closurePrompts: [AmbitionsOSClosurePromptContract]
    let proofReceipts: [AmbitionsOSProofTrustReceipt]
    let maxTodaySteps: Int
    let allowsActivation: Bool
    let mutatesCommitments: Bool
    let usesUserDataServer: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        capacityBridge: AmbitionsOSLivingDreamCapacityBridge,
        todaySteps: [AmbitionsOSLivingDreamTodayStep],
        recommendations: [AmbitionsOSStartHereRecommendation],
        closurePrompts: [AmbitionsOSClosurePromptContract],
        proofReceipts: [AmbitionsOSProofTrustReceipt],
        maxTodaySteps: Int = 3,
        allowsActivation: Bool = false,
        mutatesCommitments: Bool = false,
        usesUserDataServer: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamTodayBridgeSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capacityBridge = capacityBridge
        self.todaySteps = todaySteps.sorted { $0.id < $1.id }
        self.recommendations = recommendations.sorted { $0.id < $1.id }
        self.closurePrompts = closurePrompts.sorted { $0.promptID < $1.promptID }
        self.proofReceipts = proofReceipts.sorted { $0.id < $1.id }
        self.maxTodaySteps = maxTodaySteps
        self.allowsActivation = allowsActivation
        self.mutatesCommitments = mutatesCommitments
        self.usesUserDataServer = usesUserDataServer
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            todaySteps.isEmpty == false &&
            maxTodaySteps > 0 &&
            schemaVersion == ambitionsOSLivingDreamTodayBridgeSchemaVersion
    }
}

struct AmbitionsOSLivingDreamTodayBridgeEvaluation: Codable, Sendable, Equatable, Hashable {
    let bridgeID: String
    let todayStepIDs: [String]
    let recommendedStepIDs: [String]
    let closurePromptIDs: [String]
    let proofReceiptIDs: [String]
    let issues: [AmbitionsOSLivingDreamTodayBridgeIssue]

    var readiness: AmbitionsOSLivingDreamTodayBridgeReadiness {
        if issues.contains(.runtimeBoundaryBroken) ||
            issues.contains(.userDataServerBoundaryBroken) ||
            issues.contains(.hiddenMutationRisk) ||
            issues.contains(.activationForbidden) ||
            issues.contains(.confidenceScoreExposed) ||
            issues.contains(.guaranteedOutcomeLanguage) ||
            issues.contains(.harmfulRecommendationLanguage) {
            return .blocked
        }
        if issues.contains(.sourceReviewRequired) ||
            issues.contains(.staleSourceReviewRequired) {
            return .needsSourceReview
        }
        if issues.contains(.proofTrustReviewRequired) ||
            issues.contains(.missingProofOrReviewStep) {
            return .needsProofReview
        }
        if issues.contains(.punitiveClosureLanguage) ||
            issues.contains(.missingClosurePrompt) {
            return .needsClosureReview
        }
        if issues.contains(.missingUserControl) ||
            issues.contains(.genericPriorityOnly) {
            return .needsUserReview
        }
        if issues.contains(.capacityBridgeNotReady) ||
            issues.contains(.tooManyTodaySteps) ||
            issues.contains(.missingRecommendedStep) ||
            issues.contains(.malformedBridge) ||
            issues.contains(.unsupportedSchema) {
            return .needsCapacityReview
        }
        return .readyForToday
    }
}

struct AmbitionsOSLivingDreamTodayBridgeValidator: Sendable, Equatable, Hashable {
    func validate(
        bridge: AmbitionsOSLivingDreamTodayBridge
    ) -> [AmbitionsOSLivingDreamTodayBridgeIssue] {
        var issues: Set<AmbitionsOSLivingDreamTodayBridgeIssue> = []

        validateShape(bridge, issues: &issues)
        validateCapacityBridge(bridge.capacityBridge, issues: &issues)
        validateSteps(bridge, issues: &issues)
        validateRecommendations(bridge.recommendations, issues: &issues)
        validateClosurePrompts(bridge.closurePrompts, issues: &issues)
        validateProofReceipts(bridge.proofReceipts, issues: &issues)
        validateRuntime(bridge, issues: &issues)

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func evaluate(
        bridge: AmbitionsOSLivingDreamTodayBridge
    ) -> AmbitionsOSLivingDreamTodayBridgeEvaluation {
        AmbitionsOSLivingDreamTodayBridgeEvaluation(
            bridgeID: bridge.id,
            todayStepIDs: bridge.todaySteps.map(\.id),
            recommendedStepIDs: bridge.todaySteps
                .filter { $0.kind == .recommendedStep }
                .map(\.id),
            closurePromptIDs: bridge.closurePrompts.map(\.promptID),
            proofReceiptIDs: bridge.proofReceipts.map(\.id),
            issues: validate(bridge: bridge)
        )
    }

    private func validateShape(
        _ bridge: AmbitionsOSLivingDreamTodayBridge,
        issues: inout Set<AmbitionsOSLivingDreamTodayBridgeIssue>
    ) {
        if bridge.schemaVersion != ambitionsOSLivingDreamTodayBridgeSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if bridge.isWellFormed == false {
            issues.insert(.malformedBridge)
        }
    }

    private func validateCapacityBridge(
        _ capacityBridge: AmbitionsOSLivingDreamCapacityBridge,
        issues: inout Set<AmbitionsOSLivingDreamTodayBridgeIssue>
    ) {
        let evaluation = AmbitionsOSLivingDreamCapacityBridgeValidator()
            .evaluate(bridge: capacityBridge)
        if evaluation.readiness != .readyForTodayBridge {
            issues.insert(.capacityBridgeNotReady)
        }
    }

    private func validateSteps(
        _ bridge: AmbitionsOSLivingDreamTodayBridge,
        issues: inout Set<AmbitionsOSLivingDreamTodayBridgeIssue>
    ) {
        let closurePromptIDs = Set(bridge.closurePrompts.map(\.promptID))
        let recommendationIDs = Set(bridge.recommendations.map(\.id))

        if bridge.todaySteps.count > bridge.maxTodaySteps {
            issues.insert(.tooManyTodaySteps)
        }
        if bridge.todaySteps.contains(where: { $0.kind == .recommendedStep }) == false {
            issues.insert(.missingRecommendedStep)
        }
        if bridge.todaySteps.contains(where: \.carriesProofOrReview) == false {
            issues.insert(.missingProofOrReviewStep)
        }
        if bridge.todaySteps.contains(where: \.canCloseLoop) == false {
            issues.insert(.missingClosurePrompt)
        }

        for step in bridge.todaySteps {
            if step.schemaVersion != ambitionsOSLivingDreamTodayBridgeSchemaVersion {
                issues.insert(.unsupportedSchema)
            }
            if step.isWellFormed == false {
                issues.insert(.malformedBridge)
            }
            if let promptID = step.closurePromptID,
               promptID.isEmpty == false,
               closurePromptIDs.contains(promptID) == false {
                issues.insert(.missingClosurePrompt)
            }
            if let recommendationID = step.recommendationID,
               recommendationID.isEmpty == false,
               recommendationIDs.contains(recommendationID) == false {
                issues.insert(.missingRecommendedStep)
            }
            if step.allowsActivation {
                issues.insert(.activationForbidden)
            }
            if step.mutatesCommitments {
                issues.insert(.hiddenMutationRisk)
            }
            if step.usesUserDataServer {
                issues.insert(.userDataServerBoundaryBroken)
            }
            if step.runtimeBoundary.isValueModelOnly == false {
                issues.insert(.runtimeBoundaryBroken)
            }
        }
    }

    private func validateRecommendations(
        _ recommendations: [AmbitionsOSStartHereRecommendation],
        issues: inout Set<AmbitionsOSLivingDreamTodayBridgeIssue>
    ) {
        let validator = AmbitionsOSStartHereRecommendationValidator()
        for recommendation in recommendations {
            for issue in validator.validate(recommendation) {
                issues.insert(mapped(issue))
            }
        }
    }

    private func validateClosurePrompts(
        _ prompts: [AmbitionsOSClosurePromptContract],
        issues: inout Set<AmbitionsOSLivingDreamTodayBridgeIssue>
    ) {
        if prompts.isEmpty {
            issues.insert(.missingClosurePrompt)
        }
        if prompts.contains(where: { $0.usesNonPunitiveLanguage == false }) {
            issues.insert(.punitiveClosureLanguage)
        }
    }

    private func validateProofReceipts(
        _ receipts: [AmbitionsOSProofTrustReceipt],
        issues: inout Set<AmbitionsOSLivingDreamTodayBridgeIssue>
    ) {
        let validator = AmbitionsOSProofTrustValidator()
        for receipt in receipts {
            let proofIssues = validator.validate(receipt: receipt)
            if proofIssues.isEmpty == false {
                issues.insert(.proofTrustReviewRequired)
            }
            if proofIssues.contains(.sourceReviewRequired) {
                issues.insert(.sourceReviewRequired)
            }
            if proofIssues.contains(.staleHighRiskSource) {
                issues.insert(.staleSourceReviewRequired)
            }
            if proofIssues.contains(.privateExternalProjectionRisk) {
                issues.insert(.proofTrustReviewRequired)
            }
        }
    }

    private func validateRuntime(
        _ bridge: AmbitionsOSLivingDreamTodayBridge,
        issues: inout Set<AmbitionsOSLivingDreamTodayBridgeIssue>
    ) {
        if bridge.allowsActivation {
            issues.insert(.activationForbidden)
        }
        if bridge.mutatesCommitments {
            issues.insert(.hiddenMutationRisk)
        }
        if bridge.usesUserDataServer {
            issues.insert(.userDataServerBoundaryBroken)
        }
        if bridge.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeBoundaryBroken)
        }
    }

    private func mapped(
        _ issue: AmbitionsOSRecommendationStartHereIssue
    ) -> AmbitionsOSLivingDreamTodayBridgeIssue {
        switch issue {
        case .unsupportedSchema:
            return .unsupportedSchema
        case .malformedRecommendation, .missingSourceLabel, .missingExplanation:
            return .malformedBridge
        case .sourceReviewRequired, .controlPlaneBlocksRecommendation:
            return .sourceReviewRequired
        case .staleSourceReviewRequired:
            return .staleSourceReviewRequired
        case .proofTrustReviewRequired, .missingReceiptBehavior:
            return .proofTrustReviewRequired
        case .missingUserControl:
            return .missingUserControl
        case .genericPriorityOnly:
            return .genericPriorityOnly
        case .confidenceScoreExposed:
            return .confidenceScoreExposed
        case .guaranteedOutcomeLanguage:
            return .guaranteedOutcomeLanguage
        case .harmfulRecommendationLanguage:
            return .harmfulRecommendationLanguage
        case .hiddenMutationRisk:
            return .hiddenMutationRisk
        case .privateExternalProjectionRisk:
            return .proofTrustReviewRequired
        case .runtimeStoreBehavior:
            return .runtimeBoundaryBroken
        }
    }
}
