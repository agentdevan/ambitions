import Foundation

let ambitionsOSAdaptationSchemaVersion = "ambitionsos_adaptation.native.v1"

enum AmbitionsOSAdaptationDimension: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case timeOfDay = "time_of_day"
    case energy
    case focus
    case capacity
    case sensitivity
    case interruption
    case recovery
    case seriousness
}

enum AmbitionsOSAdaptationPermissionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userApproved = "user_approved"
    case reviewOnly = "review_only"
    case inferredNeedsReview = "inferred_needs_review"
    case rejected
    case hidden
    case deletePending = "delete_pending"

    var blocksUse: Bool {
        switch self {
        case .rejected, .hidden, .deletePending, .inferredNeedsReview:
            return true
        case .userApproved, .reviewOnly:
            return false
        }
    }
}

enum AmbitionsOSAdaptationAssumptionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userConfirmed = "user_confirmed"
    case needsReview = "needs_review"
    case rejected
}

enum AmbitionsOSAdaptationReceiptKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case approval
    case rejection
    case correction
    case seriousnessChange = "seriousness_change"
    case reset
}

enum AmbitionsOSAdaptationIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedProfile = "malformed_profile"
    case malformedReflectionRecord = "malformed_reflection_record"
    case missingUserControl = "missing_user_control"
    case missingControlAction = "missing_control_action"
    case hiddenPersonalization = "hidden_personalization"
    case hiddenReflection = "hidden_reflection"
    case rejectedAssumptionStillActive = "rejected_assumption_still_active"
    case unreviewedAssumption = "unreviewed_assumption"
    case seriousnessChangeMissingReceipt = "seriousness_change_missing_receipt"
    case reflectionMissingReceipt = "reflection_missing_receipt"
    case sensitiveAdaptationNeedsPrivacyReview = "sensitive_adaptation_needs_privacy_review"
    case deterministicFallbackMissing = "deterministic_fallback_missing"
    case modelRequiredPath = "model_required_path"
    case forbiddenLanguage = "forbidden_language"
    case diaryBehavior = "diary_behavior"
    case chatbotBehavior = "chatbot_behavior"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

enum AmbitionsOSReflectionAdaptationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case closureReflection = "closure_reflection"
    case recoveryLearning = "recovery_learning"
    case correctionFold = "correction_fold"
    case preferenceCalibration = "preference_calibration"
}

enum AmbitionsOSReflectionAdaptationIntent: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case futureRecommendationInput = "future_recommendation_input"
    case reviewOnly = "review_only"
    case disabled = "disabled"
    case privateDiary = "private_diary"
    case chatbotConversation = "chatbot_conversation"
}

struct AmbitionsOSAdaptationAssumption: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let summary: String
    let dimension: AmbitionsOSAdaptationDimension
    let state: AmbitionsOSAdaptationAssumptionState
    let userVisible: Bool

    init(
        id: String,
        summary: String,
        dimension: AmbitionsOSAdaptationDimension,
        state: AmbitionsOSAdaptationAssumptionState,
        userVisible: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dimension = dimension
        self.state = state
        self.userVisible = userVisible
    }

    var isWellFormed: Bool {
        id.isEmpty == false && summary.isEmpty == false
    }

    var blocksAdaptationUse: Bool {
        state == .rejected || state == .needsReview || userVisible == false
    }
}

struct AmbitionsOSAdaptationReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: AmbitionsOSAdaptationReceiptKind
    let occurredAt: String
    let assumptionIDs: [String]
    let userReviewed: Bool

    init(
        id: String,
        kind: AmbitionsOSAdaptationReceiptKind,
        occurredAt: String,
        assumptionIDs: [String],
        userReviewed: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.assumptionIDs = Array(Set(assumptionIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
        self.userReviewed = userReviewed
    }

    var isWellFormed: Bool {
        id.isEmpty == false && occurredAt.isEmpty == false
    }
}

struct AmbitionsOSReflectionAdaptationRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceObjectID: String
    let surface: AmbitionsOSControlPlaneSurface
    let kind: AmbitionsOSReflectionAdaptationKind
    let intent: AmbitionsOSReflectionAdaptationIntent
    let summary: String
    let recommendationInfluenceSummary: String
    let dimensions: [AmbitionsOSAdaptationDimension]
    let userVisible: Bool
    let localOnly: Bool
    let deterministic: Bool
    let deterministicFallbackAvailable: Bool
    let requiresModelToApply: Bool
    let mutatesAutomatically: Bool
    let receiptIDs: [String]
    let controlActions: [String]
    let privacyClass: HumanProgressPrivacyClass
    let reviewState: HumanProgressReviewState
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let surfaceLanguageSamples: [String]
    let schemaVersion: String

    init(
        id: String,
        sourceObjectID: String,
        surface: AmbitionsOSControlPlaneSurface,
        kind: AmbitionsOSReflectionAdaptationKind,
        intent: AmbitionsOSReflectionAdaptationIntent,
        summary: String,
        recommendationInfluenceSummary: String,
        dimensions: [AmbitionsOSAdaptationDimension],
        userVisible: Bool = true,
        localOnly: Bool = true,
        deterministic: Bool = true,
        deterministicFallbackAvailable: Bool = true,
        requiresModelToApply: Bool = false,
        mutatesAutomatically: Bool = false,
        receiptIDs: [String],
        controlActions: [String],
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        reviewState: HumanProgressReviewState = .ready,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = [],
        schemaVersion: String = ambitionsOSAdaptationSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceObjectID = sourceObjectID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.surface = surface
        self.kind = kind
        self.intent = intent
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recommendationInfluenceSummary = recommendationInfluenceSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dimensions = Array(Set(dimensions)).sorted { $0.rawValue < $1.rawValue }
        self.userVisible = userVisible
        self.localOnly = localOnly
        self.deterministic = deterministic
        self.deterministicFallbackAvailable = deterministicFallbackAvailable
        self.requiresModelToApply = requiresModelToApply
        self.mutatesAutomatically = mutatesAutomatically
        self.receiptIDs = Array(Set(receiptIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
        self.controlActions = Array(Set(controlActions.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
        self.privacyClass = privacyClass
        self.reviewState = reviewState
        self.runtimeBoundary = runtimeBoundary
        self.surfaceLanguageSamples = surfaceLanguageSamples
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            sourceObjectID.isEmpty == false &&
            summary.isEmpty == false &&
            recommendationInfluenceSummary.isEmpty == false &&
            dimensions.isEmpty == false &&
            schemaVersion == ambitionsOSAdaptationSchemaVersion
    }

    var canInformFutureRecommendations: Bool {
        switch intent {
        case .futureRecommendationInput:
            return isWellFormed &&
                userVisible &&
                localOnly &&
                deterministic &&
                deterministicFallbackAvailable &&
                requiresModelToApply == false &&
                mutatesAutomatically == false &&
                receiptIDs.isEmpty == false &&
                controlActions.isEmpty == false &&
                reviewState == .ready &&
                runtimeBoundary == .valueModelOnly &&
                containsForbiddenLanguage == false
        case .reviewOnly, .disabled, .privateDiary, .chatbotConversation:
            return false
        }
    }

    var containsForbiddenLanguage: Bool {
        AmbitionsOSAdaptationForbiddenLanguage.containsBlockedTerm(in: surfaceLanguageSamples)
    }
}
