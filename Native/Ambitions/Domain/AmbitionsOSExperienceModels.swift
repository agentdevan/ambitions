import Foundation

let ambitionsOSExperienceSchemaVersion = "ambitionsos_experience.native.v1"

enum AmbitionsOSExperiencePrimaryObject: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case startHere = "start_here"
    case realityRail = "reality_rail"
    case captureComposer = "capture_composer"
    case missionControl = "mission_control"
    case planReview = "plan_review"
    case personalSystemCenter = "personal_system_center"
    case proofReview = "proof_review"
    case none
}

enum AmbitionsOSExperienceWayfindingState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case oriented
    case needsLabel = "needs_label"
    case ambiguous
    case overloaded
}

enum AmbitionsOSExperienceDensityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case calm
    case focused
    case reviewDense = "review_dense"
    case overloaded
    case dashboardDrift = "dashboard_drift"
}

enum AmbitionsOSExperienceIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedContract = "malformed_contract"
    case nonCanonicalSurface = "non_canonical_surface"
    case missingPrimaryObject = "missing_primary_object"
    case tooManyPrimaryDecisions = "too_many_primary_decisions"
    case tooManyVisibleSections = "too_many_visible_sections"
    case ambiguousWayfinding = "ambiguous_wayfinding"
    case todayFullPathDepth = "today_full_path_depth"
    case genericDashboardDrift = "generic_dashboard_drift"
    case forbiddenLanguage = "forbidden_language"
    case accessibilityReviewMissing = "accessibility_review_missing"
    case privacySafeLabelMissing = "privacy_safe_label_missing"
    case recoveryLanguageMissing = "recovery_language_missing"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSExperienceAccessibilityContract: Codable, Sendable, Equatable, Hashable {
    let voiceOverReady: Bool
    let dynamicTypeReady: Bool
    let reduceMotionReady: Bool
    let nonColorMeaningReady: Bool
    let hitTargetsReady: Bool
    let cognitiveLoadReviewReady: Bool
    let privacySafeLabelsReady: Bool

    init(
        voiceOverReady: Bool,
        dynamicTypeReady: Bool,
        reduceMotionReady: Bool,
        nonColorMeaningReady: Bool,
        hitTargetsReady: Bool,
        cognitiveLoadReviewReady: Bool,
        privacySafeLabelsReady: Bool
    ) {
        self.voiceOverReady = voiceOverReady
        self.dynamicTypeReady = dynamicTypeReady
        self.reduceMotionReady = reduceMotionReady
        self.nonColorMeaningReady = nonColorMeaningReady
        self.hitTargetsReady = hitTargetsReady
        self.cognitiveLoadReviewReady = cognitiveLoadReviewReady
        self.privacySafeLabelsReady = privacySafeLabelsReady
    }

    var isReviewReady: Bool {
        voiceOverReady &&
            dynamicTypeReady &&
            reduceMotionReady &&
            nonColorMeaningReady &&
            hitTargetsReady &&
            cognitiveLoadReviewReady
    }

    static let ready = AmbitionsOSExperienceAccessibilityContract(
        voiceOverReady: true,
        dynamicTypeReady: true,
        reduceMotionReady: true,
        nonColorMeaningReady: true,
        hitTargetsReady: true,
        cognitiveLoadReviewReady: true,
        privacySafeLabelsReady: true
    )
}

struct AmbitionsOSExperienceContract: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let surface: AmbitionsOSControlPlaneSurface
    let primaryObject: AmbitionsOSExperiencePrimaryObject
    let wayfindingState: AmbitionsOSExperienceWayfindingState
    let densityState: AmbitionsOSExperienceDensityState
    let primaryDecisionCount: Int
    let visibleSectionCount: Int
    let permitsFullPathDepth: Bool
    let preservesTopLevelIADestination: Bool
    let copySamples: [String]
    let recoveryLanguageSamples: [String]
    let accessibility: AmbitionsOSExperienceAccessibilityContract
    let privacyClass: HumanProgressPrivacyClass
    let changesAppState: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        surface: AmbitionsOSControlPlaneSurface,
        primaryObject: AmbitionsOSExperiencePrimaryObject,
        wayfindingState: AmbitionsOSExperienceWayfindingState = .oriented,
        densityState: AmbitionsOSExperienceDensityState = .focused,
        primaryDecisionCount: Int,
        visibleSectionCount: Int,
        permitsFullPathDepth: Bool = false,
        preservesTopLevelIADestination: Bool = true,
        copySamples: [String],
        recoveryLanguageSamples: [String],
        accessibility: AmbitionsOSExperienceAccessibilityContract = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        changesAppState: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSExperienceSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.surface = surface
        self.primaryObject = primaryObject
        self.wayfindingState = wayfindingState
        self.densityState = densityState
        self.primaryDecisionCount = primaryDecisionCount
        self.visibleSectionCount = visibleSectionCount
        self.permitsFullPathDepth = permitsFullPathDepth
        self.preservesTopLevelIADestination = preservesTopLevelIADestination
        self.copySamples = Self.orderedUnique(copySamples)
        self.recoveryLanguageSamples = Self.orderedUnique(recoveryLanguageSamples)
        self.accessibility = accessibility
        self.privacyClass = privacyClass
        self.changesAppState = changesAppState
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            copySamples.isEmpty == false &&
            recoveryLanguageSamples.isEmpty == false &&
            primaryDecisionCount >= 0 &&
            visibleSectionCount > 0 &&
            schemaVersion == ambitionsOSExperienceSchemaVersion
    }

    var isCanonicalUserSurface: Bool {
        switch surface {
        case .today, .goals, .capture, .plan, .you:
            return true
        case .externalProjection, .runtimeContract:
            return false
        }
    }

    var containsForbiddenExperienceLanguage: Bool {
        let forbiddenPhrases = [
            "ai confidence",
            "confidence percentage",
            "productivity score",
            "streak",
            "trophy",
            "task dashboard",
            "source dashboard",
            "inbox",
            "feed",
            "calendar clone",
            "chatbot",
            "guaranteed outcome",
            "app store ready",
            "testflight ready",
            "device verified"
        ]
        let combined = (copySamples + recoveryLanguageSamples)
            .joined(separator: " ")
            .lowercased()
        return forbiddenPhrases.contains { combined.contains($0) }
    }

    var hasNonShamingRecoveryLanguage: Bool {
        let combined = recoveryLanguageSamples.joined(separator: " ").lowercased()
        return combined.isEmpty == false &&
            combined.contains("failed") == false &&
            combined.contains("overdue") == false &&
            combined.contains("behind again") == false
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSExperienceValidator: Sendable, Equatable, Hashable {
    func validate(_ contract: AmbitionsOSExperienceContract) -> [AmbitionsOSExperienceIssue] {
        var issues: Set<AmbitionsOSExperienceIssue> = []

        if contract.schemaVersion != ambitionsOSExperienceSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if contract.isWellFormed == false {
            issues.insert(.malformedContract)
        }
        if contract.isCanonicalUserSurface == false {
            issues.insert(.nonCanonicalSurface)
        }
        if contract.primaryObject == .none {
            issues.insert(.missingPrimaryObject)
        }
        if contract.primaryDecisionCount > 2 {
            issues.insert(.tooManyPrimaryDecisions)
        }
        if contract.visibleSectionCount > 7 {
            issues.insert(.tooManyVisibleSections)
        }
        if contract.wayfindingState == .ambiguous || contract.wayfindingState == .overloaded {
            issues.insert(.ambiguousWayfinding)
        }
        if contract.surface == .today && contract.permitsFullPathDepth {
            issues.insert(.todayFullPathDepth)
        }
        if contract.densityState == .dashboardDrift || contract.densityState == .overloaded {
            issues.insert(.genericDashboardDrift)
        }
        if contract.preservesTopLevelIADestination == false {
            issues.insert(.nonCanonicalSurface)
        }
        if contract.containsForbiddenExperienceLanguage {
            issues.insert(.forbiddenLanguage)
        }
        if contract.accessibility.isReviewReady == false {
            issues.insert(.accessibilityReviewMissing)
        }
        if contract.privacyClass == .sensitive && contract.accessibility.privacySafeLabelsReady == false {
            issues.insert(.privacySafeLabelMissing)
        }
        if contract.hasNonShamingRecoveryLanguage == false {
            issues.insert(.recoveryLanguageMissing)
        }
        if contract.changesAppState {
            issues.insert(.hiddenMutationRisk)
        }
        if contract.runtimeBoundary != .valueModelOnly {
            issues.insert(.runtimeStoreBehavior)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }
}
