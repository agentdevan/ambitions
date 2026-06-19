import Foundation

let ambitionsOSInteroperabilitySchemaVersion = "ambitionsos_interoperability.native.v1"

enum AmbitionsOSInteroperabilitySurface: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case appIntent = "app_intent"
    case shortcut
    case spotlight
    case eventKit = "event_kit"
    case reminder
    case widget
    case liveActivity = "live_activity"
    case shareExtension = "share_extension"
}

enum AmbitionsOSInteroperabilityActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localProjection = "local_projection"
    case prepareIntentPayload = "prepare_intent_payload"
    case prepareCalendarSuggestion = "prepare_calendar_suggestion"
    case prepareReminderSuggestion = "prepare_reminder_suggestion"
    case invokeExternalAction = "invoke_external_action"
    case writeCalendar = "write_calendar"
    case requestPlatformPermission = "request_platform_permission"
    case syncRemote = "sync_remote"
    case backgroundRefresh = "background_refresh"
}

enum AmbitionsOSInteroperabilityCapabilityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case plannedOnly = "planned_only"
    case localProjectionOnly = "local_projection_only"
    case reviewRequired = "review_required"
    case userApprovedTerminal = "user_approved_terminal"
    case blocked

    var blocksPlanningUse: Bool {
        self == .blocked
    }
}

enum AmbitionsOSInteroperabilityIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedPlan = "malformed_plan"
    case blockedCapability = "blocked_capability"
    case implementationBoundaryViolation = "implementation_boundary_violation"
    case platformWriteNotAllowed = "platform_write_not_allowed"
    case permissionPromptNotAllowed = "permission_prompt_not_allowed"
    case sourceConfirmationMissing = "source_confirmation_missing"
    case privacyProjectionMissing = "privacy_projection_missing"
    case rawSensitiveExternalPayload = "raw_sensitive_external_payload"
    case userApprovalMissing = "user_approval_missing"
    case performanceBudgetMissing = "performance_budget_missing"
    case compatibilityReviewMissing = "compatibility_review_missing"
    case releaseClaimWithoutEvidence = "release_claim_without_evidence"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
    case hostedOrRemoteDependency = "hosted_or_remote_dependency"
    case forbiddenLanguage = "forbidden_language"
}

struct AmbitionsOSInteroperabilityReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let action: String
    let occurredAt: String
    let userReviewed: Bool

    init(id: String, action: String, occurredAt: String, userReviewed: Bool = true) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.action = action.trimmingCharacters(in: .whitespacesAndNewlines)
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.userReviewed = userReviewed
    }

    var isWellFormed: Bool {
        id.isEmpty == false && action.isEmpty == false && occurredAt.isEmpty == false
    }
}

struct AmbitionsOSInteroperabilityPlan: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let surface: AmbitionsOSInteroperabilitySurface
    let ownerSurface: AmbitionsOSControlPlaneSurface
    let actionKind: AmbitionsOSInteroperabilityActionKind
    let capabilityState: AmbitionsOSInteroperabilityCapabilityState
    let payloadSummary: String
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let sensitiveAreas: [AmbitionsOSPrivacySensitiveArea]
    let projectionPolicy: AmbitionsOSPrivacyProjectionPolicy
    let redactionSummary: String
    let toolApprovalState: AmbitionsOSLocalLanguageToolApprovalState
    let receipts: [AmbitionsOSInteroperabilityReceipt]
    let hasPerformanceBudget: Bool
    let hasCompatibilityReview: Bool
    let changesAppState: Bool
    let requestsPlatformPermission: Bool
    let writesExternalSystem: Bool
    let dependsOnNetworkOrHostedService: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let surfaceLanguageSamples: [String]
    let schemaVersion: String

    init(
        id: String,
        surface: AmbitionsOSInteroperabilitySurface,
        ownerSurface: AmbitionsOSControlPlaneSurface,
        actionKind: AmbitionsOSInteroperabilityActionKind,
        capabilityState: AmbitionsOSInteroperabilityCapabilityState = .plannedOnly,
        payloadSummary: String,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = [],
        projectionPolicy: AmbitionsOSPrivacyProjectionPolicy = .externalRedacted,
        redactionSummary: String,
        toolApprovalState: AmbitionsOSLocalLanguageToolApprovalState = .reviewOnly,
        receipts: [AmbitionsOSInteroperabilityReceipt],
        hasPerformanceBudget: Bool = true,
        hasCompatibilityReview: Bool = true,
        changesAppState: Bool = false,
        requestsPlatformPermission: Bool = false,
        writesExternalSystem: Bool = false,
        dependsOnNetworkOrHostedService: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = [],
        schemaVersion: String = ambitionsOSInteroperabilitySchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.surface = surface
        self.ownerSurface = ownerSurface
        self.actionKind = actionKind
        self.capabilityState = capabilityState
        self.payloadSummary = payloadSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.sensitiveAreas = Array(Set(sensitiveAreas)).sorted { $0.rawValue < $1.rawValue }
        self.projectionPolicy = projectionPolicy
        self.redactionSummary = redactionSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.toolApprovalState = toolApprovalState
        self.receipts = receipts.sorted { $0.id < $1.id }
        self.hasPerformanceBudget = hasPerformanceBudget
        self.hasCompatibilityReview = hasCompatibilityReview
        self.changesAppState = changesAppState
        self.requestsPlatformPermission = requestsPlatformPermission
        self.writesExternalSystem = writesExternalSystem
        self.dependsOnNetworkOrHostedService = dependsOnNetworkOrHostedService
        self.runtimeBoundary = runtimeBoundary
        self.surfaceLanguageSamples = surfaceLanguageSamples
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            payloadSummary.isEmpty == false &&
            receipts.allSatisfy(\.isWellFormed) &&
            schemaVersion == ambitionsOSInteroperabilitySchemaVersion
    }

    var isSourceSensitive: Bool {
        actionKind == .prepareCalendarSuggestion ||
            actionKind == .prepareReminderSuggestion ||
            actionKind == .invokeExternalAction ||
            actionKind == .writeCalendar
    }

    var hasReviewReadySource: Bool {
        sourceState.canDriveSourceSensitiveRecommendation &&
            freshnessState.blocksHighRiskUse == false &&
            reviewState == .ready
    }

    var isSensitiveProjection: Bool {
        privacyClass == .sensitive ||
            privacyClass == .deletePending ||
            sensitiveAreas.isEmpty == false
    }

    var hasUserReviewedReceipt: Bool {
        receipts.contains { $0.userReviewed }
    }

    var hasForbiddenLanguage: Bool {
        let blocked = [
            "calendar replacement",
            "reminders replacement",
            "app store ready",
            "testflight ready",
            "platform ready",
            "device verified",
            "public accessibility compliant",
            "automatic calendar write"
        ] + ForbiddenTopLevelTerms.terms.map { $0.lowercased() }
        let combined = surfaceLanguageSamples.joined(separator: " ").lowercased()
        return blocked.contains { combined.contains($0) }
    }
}

struct AmbitionsOSInteroperabilityValidator: Sendable, Equatable, Hashable {
    func validate(_ plan: AmbitionsOSInteroperabilityPlan) -> [AmbitionsOSInteroperabilityIssue] {
        var issues: Set<AmbitionsOSInteroperabilityIssue> = []

        validateShape(plan, issues: &issues)
        validatePlanningBoundary(plan, issues: &issues)
        validateSourcePrivacyAndApproval(plan, issues: &issues)
        validateEvidenceAndRuntime(plan, issues: &issues)

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validateShape(
        _ plan: AmbitionsOSInteroperabilityPlan,
        issues: inout Set<AmbitionsOSInteroperabilityIssue>
    ) {
        if plan.schemaVersion != ambitionsOSInteroperabilitySchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if plan.isWellFormed == false {
            issues.insert(.malformedPlan)
        }
        if plan.capabilityState.blocksPlanningUse {
            issues.insert(.blockedCapability)
        }
    }

    private func validatePlanningBoundary(
        _ plan: AmbitionsOSInteroperabilityPlan,
        issues: inout Set<AmbitionsOSInteroperabilityIssue>
    ) {
        if plan.actionKind == .invokeExternalAction ||
            plan.actionKind == .writeCalendar ||
            plan.actionKind == .syncRemote ||
            plan.actionKind == .backgroundRefresh {
            issues.insert(.implementationBoundaryViolation)
        }
        if plan.writesExternalSystem {
            issues.insert(.platformWriteNotAllowed)
        }
        if plan.requestsPlatformPermission || plan.actionKind == .requestPlatformPermission {
            issues.insert(.permissionPromptNotAllowed)
        }
    }

    private func validateSourcePrivacyAndApproval(
        _ plan: AmbitionsOSInteroperabilityPlan,
        issues: inout Set<AmbitionsOSInteroperabilityIssue>
    ) {
        if plan.isSourceSensitive && plan.hasReviewReadySource == false {
            issues.insert(.sourceConfirmationMissing)
        }
        if plan.projectionPolicy != .externalRedacted || plan.redactionSummary.isEmpty {
            issues.insert(.privacyProjectionMissing)
        }
        if plan.isSensitiveProjection && plan.projectionPolicy != .externalRedacted {
            issues.insert(.rawSensitiveExternalPayload)
        }
        if plan.toolApprovalState != .reviewOnly &&
            plan.toolApprovalState != .prepareProposal &&
            plan.toolApprovalState != .userApproved {
            issues.insert(.userApprovalMissing)
        }
        if plan.hasUserReviewedReceipt == false {
            issues.insert(.userApprovalMissing)
        }
    }

    private func validateEvidenceAndRuntime(
        _ plan: AmbitionsOSInteroperabilityPlan,
        issues: inout Set<AmbitionsOSInteroperabilityIssue>
    ) {
        if plan.hasPerformanceBudget == false {
            issues.insert(.performanceBudgetMissing)
        }
        if plan.hasCompatibilityReview == false {
            issues.insert(.compatibilityReviewMissing)
        }
        if plan.hasForbiddenLanguage {
            issues.insert(.forbiddenLanguage)
            issues.insert(.releaseClaimWithoutEvidence)
        }
        if plan.changesAppState {
            issues.insert(.hiddenMutationRisk)
        }
        if plan.runtimeBoundary != .valueModelOnly {
            issues.insert(.runtimeStoreBehavior)
        }
        if plan.dependsOnNetworkOrHostedService {
            issues.insert(.hostedOrRemoteDependency)
        }
    }
}
