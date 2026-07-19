import Foundation

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

enum AmbitionsOSAdaptationForbiddenLanguage {
    static func containsBlockedTerm(in samples: [String]) -> Bool {
        let blocked = ForbiddenTopLevelTerms.terms.map { $0.lowercased() } + [
            "confidence percentage",
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
