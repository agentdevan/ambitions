import Foundation

let ambitionsOSLocalLanguageSchemaVersion = "ambitionsos_local_language.native.v1"

enum AmbitionsOSLocalLanguageIntent: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case captureParse = "capture_parse"
    case sourceSummary = "source_summary"
    case questionGeneration = "question_generation"
    case copyRewrite = "copy_rewrite"
    case toolProposal = "tool_proposal"
    case recommendationSupport = "recommendation_support"
}

enum AmbitionsOSLocalLanguageAdapterTier: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case tier0Deterministic = "tier0_deterministic"
    case tier1LocalClassifier = "tier1_local_classifier"
    case tier2PlatformLocalAdapter = "tier2_platform_local_adapter"
    case tier3DownloadableLocalAdapter = "tier3_downloadable_local_adapter"
    case tier4BundledCustomModel = "tier4_bundled_custom_model"
    case tierBlocked = "tier_blocked"

    var isModelTier: Bool {
        switch self {
        case .tier2PlatformLocalAdapter, .tier3DownloadableLocalAdapter, .tier4BundledCustomModel:
            return true
        case .tier0Deterministic, .tier1LocalClassifier, .tierBlocked:
            return false
        }
    }

    var isForbiddenCoreTier: Bool {
        self == .tier4BundledCustomModel || self == .tierBlocked
    }
}

enum AmbitionsOSLocalLanguageFallbackState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case deterministicAvailable = "deterministic_available"
    case clarificationNeeded = "clarification_needed"
    case sourceReviewNeeded = "source_review_needed"
    case privacyReviewNeeded = "privacy_review_needed"
    case adapterUnavailable = "adapter_unavailable"
    case unsupportedDevice = "unsupported_device"
    case blocked
}

enum AmbitionsOSLocalLanguageToolApprovalState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notAllowed = "not_allowed"
    case reviewOnly = "review_only"
    case prepareProposal = "prepare_proposal"
    case userApproved = "user_approved"
    case userRejected = "user_rejected"
    case requiresSourceReview = "requires_source_review"
    case requiresPrivacyReview = "requires_privacy_review"
    case requiresHumanReview = "requires_human_review"
    case blockedBySensitivity = "blocked_by_sensitivity"
    case blockedByFallback = "blocked_by_fallback"
}

enum AmbitionsOSLocalLanguageIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedPlan = "malformed_plan"
    case unsupportedSurface = "unsupported_surface"
    case missingDeterministicFallback = "missing_deterministic_fallback"
    case modelRuntimeNotAllowed = "model_runtime_not_allowed"
    case blockedAdapterTier = "blocked_adapter_tier"
    case sourceReviewRequired = "source_review_required"
    case staleSourceReviewRequired = "stale_source_review_required"
    case privacyReviewRequired = "privacy_review_required"
    case externalProjectionRisk = "external_projection_risk"
    case toolApprovalRequired = "tool_approval_required"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case confidenceLanguage = "confidence_language"
    case performanceBudgetMissing = "performance_budget_missing"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSLocalLanguageField: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let name: String
    let valueSummary: String
    let sourceBoundary: String
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass

    init(
        id: String,
        name: String,
        valueSummary: String,
        sourceBoundary: String,
        reviewState: HumanProgressReviewState = .needsUserReview,
        privacyClass: HumanProgressPrivacyClass = .privateLife
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.valueSummary = valueSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceBoundary = sourceBoundary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reviewState = reviewState
        self.privacyClass = privacyClass
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            name.isEmpty == false &&
            valueSummary.isEmpty == false &&
            sourceBoundary.isEmpty == false
    }
}

struct AmbitionsOSLocalLanguagePlan: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let intent: AmbitionsOSLocalLanguageIntent
    let surface: AmbitionsOSControlPlaneSurface
    let inputSummary: String
    let fields: [AmbitionsOSLocalLanguageField]
    let adapterTier: AmbitionsOSLocalLanguageAdapterTier
    let fallbackState: AmbitionsOSLocalLanguageFallbackState
    let deterministicFallbackAvailable: Bool
    let invokesModelRuntime: Bool
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let sensitiveAreaLabels: [String]
    let projectsExternally: Bool
    let toolApprovalState: AmbitionsOSLocalLanguageToolApprovalState
    let changesAppState: Bool
    let hasPerformanceBudget: Bool
    let exposesConfidenceLanguage: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let surfaceLanguageSamples: [String]
    let schemaVersion: String

    init(
        id: String,
        intent: AmbitionsOSLocalLanguageIntent,
        surface: AmbitionsOSControlPlaneSurface,
        inputSummary: String,
        fields: [AmbitionsOSLocalLanguageField],
        adapterTier: AmbitionsOSLocalLanguageAdapterTier = .tier0Deterministic,
        fallbackState: AmbitionsOSLocalLanguageFallbackState = .deterministicAvailable,
        deterministicFallbackAvailable: Bool = true,
        invokesModelRuntime: Bool = false,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreaLabels: [String] = [],
        projectsExternally: Bool = false,
        toolApprovalState: AmbitionsOSLocalLanguageToolApprovalState = .reviewOnly,
        changesAppState: Bool = false,
        hasPerformanceBudget: Bool = true,
        exposesConfidenceLanguage: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = [],
        schemaVersion: String = ambitionsOSLocalLanguageSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.intent = intent
        self.surface = surface
        self.inputSummary = inputSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fields = fields.sorted { $0.id < $1.id }
        self.adapterTier = adapterTier
        self.fallbackState = fallbackState
        self.deterministicFallbackAvailable = deterministicFallbackAvailable
        self.invokesModelRuntime = invokesModelRuntime
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.sensitiveAreaLabels = Self.orderedUnique(sensitiveAreaLabels)
        self.projectsExternally = projectsExternally
        self.toolApprovalState = toolApprovalState
        self.changesAppState = changesAppState
        self.hasPerformanceBudget = hasPerformanceBudget
        self.exposesConfidenceLanguage = exposesConfidenceLanguage
        self.runtimeBoundary = runtimeBoundary
        self.surfaceLanguageSamples = surfaceLanguageSamples
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            inputSummary.isEmpty == false &&
            fields.isEmpty == false &&
            fields.allSatisfy(\.isWellFormed) &&
            schemaVersion == ambitionsOSLocalLanguageSchemaVersion
    }

    var isOwnedSurface: Bool {
        surface == .capture || surface == .you
    }

    var sourceCanSupportExtraction: Bool {
        sourceState.canDriveSourceSensitiveRecommendation &&
            freshnessState.blocksHighRiskUse == false &&
            reviewState == .ready
    }

    var hasSensitivePrivacyPosture: Bool {
        privacyClass == .sensitive ||
            privacyClass == .deletePending ||
            sensitiveAreaLabels.isEmpty == false
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLocalLanguageValidator: Sendable, Equatable, Hashable {
    func validate(_ plan: AmbitionsOSLocalLanguagePlan) -> [AmbitionsOSLocalLanguageIssue] {
        var issues: Set<AmbitionsOSLocalLanguageIssue> = []

        validateShape(plan, issues: &issues)
        validateAdapterBoundary(plan, issues: &issues)
        validateSourcePrivacyAndTools(plan, issues: &issues)
        validateLanguageAndRuntime(plan, issues: &issues)

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validateShape(
        _ plan: AmbitionsOSLocalLanguagePlan,
        issues: inout Set<AmbitionsOSLocalLanguageIssue>
    ) {
        if plan.schemaVersion != ambitionsOSLocalLanguageSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if plan.isWellFormed == false {
            issues.insert(.malformedPlan)
        }
        if plan.isOwnedSurface == false {
            issues.insert(.unsupportedSurface)
        }
    }

    private func validateAdapterBoundary(
        _ plan: AmbitionsOSLocalLanguagePlan,
        issues: inout Set<AmbitionsOSLocalLanguageIssue>
    ) {
        if plan.deterministicFallbackAvailable == false || plan.fallbackState == .blocked {
            issues.insert(.missingDeterministicFallback)
        }
        if plan.adapterTier.isModelTier && plan.deterministicFallbackAvailable == false {
            issues.insert(.missingDeterministicFallback)
        }
        if plan.invokesModelRuntime {
            issues.insert(.modelRuntimeNotAllowed)
        }
        if plan.adapterTier.isForbiddenCoreTier {
            issues.insert(.blockedAdapterTier)
        }
        if plan.adapterTier.isModelTier && plan.hasPerformanceBudget == false {
            issues.insert(.performanceBudgetMissing)
        }
    }

    private func validateSourcePrivacyAndTools(
        _ plan: AmbitionsOSLocalLanguagePlan,
        issues: inout Set<AmbitionsOSLocalLanguageIssue>
    ) {
        if plan.sourceCanSupportExtraction == false {
            issues.insert(.sourceReviewRequired)
        }
        if plan.freshnessState.blocksHighRiskUse {
            issues.insert(.staleSourceReviewRequired)
        }
        if plan.hasSensitivePrivacyPosture && plan.reviewState != .ready {
            issues.insert(.privacyReviewRequired)
        }
        if plan.projectsExternally && plan.hasSensitivePrivacyPosture {
            issues.insert(.externalProjectionRisk)
        }
        if plan.intent == .toolProposal && plan.toolApprovalState == .notAllowed {
            issues.insert(.toolApprovalRequired)
        }
        if plan.changesAppState {
            issues.insert(.hiddenMutationRisk)
        }
    }

    private func validateLanguageAndRuntime(
        _ plan: AmbitionsOSLocalLanguagePlan,
        issues: inout Set<AmbitionsOSLocalLanguageIssue>
    ) {
        if plan.exposesConfidenceLanguage {
            issues.insert(.confidenceLanguage)
        }
        if plan.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }

        let blocked = [
            "ai " + "confidence",
            "model " + "confidence",
            "confidence " + "score",
            "productivity " + "score",
            "chat" + "bot",
            "guaran" + "teed"
        ]
        if plan.surfaceLanguageSamples.contains(where: { sample in
            let normalized = sample.lowercased()
            return blocked.contains(where: normalized.contains)
        }) {
            issues.insert(.confidenceLanguage)
        }
    }
}
