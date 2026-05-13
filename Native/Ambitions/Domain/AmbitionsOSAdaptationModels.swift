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

struct AmbitionsOSAdaptationProfile: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let surface: AmbitionsOSControlPlaneSurface
    let objectID: String
    let dimensions: [AmbitionsOSAdaptationDimension]
    let permissionState: AmbitionsOSAdaptationPermissionState
    let assumptions: [AmbitionsOSAdaptationAssumption]
    let receipts: [AmbitionsOSAdaptationReceipt]
    let userControls: [String]
    let changesSeriousness: Bool
    let deterministicFallbackAvailable: Bool
    let requiresModelToApply: Bool
    let privacyClass: HumanProgressPrivacyClass
    let reviewState: HumanProgressReviewState
    let mutatesAutomatically: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let surfaceLanguageSamples: [String]
    let schemaVersion: String

    init(
        id: String,
        surface: AmbitionsOSControlPlaneSurface,
        objectID: String,
        dimensions: [AmbitionsOSAdaptationDimension],
        permissionState: AmbitionsOSAdaptationPermissionState,
        assumptions: [AmbitionsOSAdaptationAssumption],
        receipts: [AmbitionsOSAdaptationReceipt],
        userControls: [String],
        changesSeriousness: Bool = false,
        deterministicFallbackAvailable: Bool = true,
        requiresModelToApply: Bool = false,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        reviewState: HumanProgressReviewState = .ready,
        mutatesAutomatically: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = [],
        schemaVersion: String = ambitionsOSAdaptationSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.surface = surface
        self.objectID = objectID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dimensions = Array(Set(dimensions)).sorted { $0.rawValue < $1.rawValue }
        self.permissionState = permissionState
        self.assumptions = assumptions.sorted { $0.id < $1.id }
        self.receipts = receipts.sorted { $0.id < $1.id }
        self.userControls = Array(Set(userControls.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
        self.changesSeriousness = changesSeriousness
        self.deterministicFallbackAvailable = deterministicFallbackAvailable
        self.requiresModelToApply = requiresModelToApply
        self.privacyClass = privacyClass
        self.reviewState = reviewState
        self.mutatesAutomatically = mutatesAutomatically
        self.runtimeBoundary = runtimeBoundary
        self.surfaceLanguageSamples = surfaceLanguageSamples
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            objectID.isEmpty == false &&
            dimensions.isEmpty == false &&
            assumptions.allSatisfy(\.isWellFormed) &&
            receipts.allSatisfy(\.isWellFormed) &&
            schemaVersion == ambitionsOSAdaptationSchemaVersion
    }

    var hasUserControl: Bool {
        userControls.isEmpty == false
    }

    var hasUserReviewedReceipt: Bool {
        receipts.contains { $0.userReviewed }
    }

    var hasSeriousnessChangeReceipt: Bool {
        receipts.contains { $0.kind == .seriousnessChange && $0.userReviewed }
    }

    var containsForbiddenLanguage: Bool {
        AmbitionsOSAdaptationForbiddenLanguage.containsBlockedTerm(in: surfaceLanguageSamples)
    }
}

struct AmbitionsOSAdaptationValidator: Sendable, Equatable, Hashable {
    func validate(_ profile: AmbitionsOSAdaptationProfile) -> [AmbitionsOSAdaptationIssue] {
        var issues: Set<AmbitionsOSAdaptationIssue> = []

        if profile.schemaVersion != ambitionsOSAdaptationSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if profile.isWellFormed == false {
            issues.insert(.malformedProfile)
        }
        if profile.hasUserControl == false {
            issues.insert(.missingUserControl)
        }
        if profile.permissionState.blocksUse {
            issues.insert(.hiddenPersonalization)
        }
        if profile.assumptions.contains(where: { $0.state == .rejected }) {
            issues.insert(.rejectedAssumptionStillActive)
        }
        if profile.assumptions.contains(where: { $0.state == .needsReview || $0.userVisible == false }) {
            issues.insert(.unreviewedAssumption)
        }
        if profile.changesSeriousness && profile.hasSeriousnessChangeReceipt == false {
            issues.insert(.seriousnessChangeMissingReceipt)
        }
        if profile.privacyClass == .sensitive && (profile.reviewState != .ready || profile.hasUserReviewedReceipt == false) {
            issues.insert(.sensitiveAdaptationNeedsPrivacyReview)
        }
        if profile.deterministicFallbackAvailable == false {
            issues.insert(.deterministicFallbackMissing)
        }
        if profile.requiresModelToApply {
            issues.insert(.modelRequiredPath)
        }
        if profile.containsForbiddenLanguage {
            issues.insert(.forbiddenLanguage)
        }
        if profile.mutatesAutomatically {
            issues.insert(.hiddenMutationRisk)
        }
        if profile.runtimeBoundary != .valueModelOnly {
            issues.insert(.runtimeStoreBehavior)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func validate(_ record: AmbitionsOSReflectionAdaptationRecord) -> [AmbitionsOSAdaptationIssue] {
        var issues: Set<AmbitionsOSAdaptationIssue> = []

        if record.schemaVersion != ambitionsOSAdaptationSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if record.isWellFormed == false {
            issues.insert(.malformedReflectionRecord)
        }
        if record.userVisible == false || record.localOnly == false || record.deterministic == false {
            issues.insert(.hiddenReflection)
        }
        if record.controlActions.isEmpty {
            issues.insert(.missingControlAction)
        }
        if record.receiptIDs.isEmpty {
            issues.insert(.reflectionMissingReceipt)
        }
        if record.privacyClass == .sensitive && record.reviewState != .ready {
            issues.insert(.sensitiveAdaptationNeedsPrivacyReview)
        }
        if record.deterministicFallbackAvailable == false {
            issues.insert(.deterministicFallbackMissing)
        }
        if record.requiresModelToApply {
            issues.insert(.modelRequiredPath)
        }
        if record.containsForbiddenLanguage {
            issues.insert(.forbiddenLanguage)
        }
        if record.intent == .privateDiary {
            issues.insert(.diaryBehavior)
        }
        if record.intent == .chatbotConversation {
            issues.insert(.chatbotBehavior)
        }
        if record.mutatesAutomatically {
            issues.insert(.hiddenMutationRisk)
        }
        if record.runtimeBoundary != .valueModelOnly {
            issues.insert(.runtimeStoreBehavior)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }
}

private enum AmbitionsOSAdaptationForbiddenLanguage {
    static func containsBlockedTerm(in samples: [String]) -> Bool {
        let blocked = [
            "ai confidence",
            "confidence percentage",
            "productivity score",
            "streak",
            "trophy",
            "autopersonalized",
            "we learned you",
            "always knows",
            "guaranteed fit",
            "device verified",
            "app store ready",
            "testflight ready",
            "diary",
            "chatbot",
            "chat transcript",
            "assistant says"
        ]
        let combined = samples.joined(separator: " ").lowercased()
        return blocked.contains { combined.contains($0) }
    }
}
