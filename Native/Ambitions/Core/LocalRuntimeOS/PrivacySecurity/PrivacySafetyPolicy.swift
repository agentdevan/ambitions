import Foundation

let ambitionsOSPrivacySafetySchemaVersion = "ambitionsos_privacy_safety.native.v1"

enum AmbitionsOSPrivacySensitiveArea: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case medical
    case legal
    case financial
    case immigration
    case education
    case careerSensitive = "career_sensitive"
    case identity
    case family
    case relationship
    case minorsStudentData = "minors_student_data"
    case location
    case publicReputation = "public_reputation"
    case safetyCrisis = "safety_crisis"
    case politicalCivic = "political_civic"
    case thirdPartyPersonalData = "third_party_personal_data"
    case privateAttachment = "private_attachment"
}

enum AmbitionsOSPrivacyPermissionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case remember
    case privateOnly = "private"
    case hide
    case askLater = "ask_later"
    case reject
    case forget
    case correct
    case stale
    case sourceBacked = "source_backed"
    case inferredNeedsReview = "inferred_needs_review"
    case localOnly = "local_only"
    case externalBlocked = "external_blocked"
    case deletePending = "delete_pending"

    var blocksProjection: Bool {
        switch self {
        case .hide, .reject, .forget, .inferredNeedsReview, .externalBlocked, .deletePending:
            return true
        case .remember, .privateOnly, .askLater, .correct, .stale, .sourceBacked, .localOnly:
            return false
        }
    }
}

enum AmbitionsOSPrivacyProjectionPolicy: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fullLocal = "full_local"
    case redactedLocal = "redacted_local"
    case reviewOnly = "review_only"
    case externalRedacted = "external_redacted"
    case externalBlocked = "external_blocked"
    case hidden
}

enum AmbitionsOSPrivacyToolIntent: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case readLocalSummary = "read_local_summary"
    case proposeMemoryChange = "propose_memory_change"
    case prepareExport = "prepare_export"
    case projectExternally = "project_externally"
    case invokeAdapter = "invoke_adapter"
    case mutateGraph = "mutate_graph"
}

enum AmbitionsOSPrivacySafetyIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedPolicy = "malformed_policy"
    case inferredMemoryTreatedAsFact = "inferred_memory_treated_as_fact"
    case sensitiveAreaNeedsReview = "sensitive_area_needs_review"
    case externalProjectionBlocked = "external_projection_blocked"
    case rawSensitiveExternalProjection = "raw_sensitive_external_projection"
    case missingRedactionSummary = "missing_redaction_summary"
    case deletePendingProjection = "delete_pending_projection"
    case toolApprovalRequired = "tool_approval_required"
    case deterministicFallbackMissing = "deterministic_fallback_missing"
    case privacyReceiptMissing = "privacy_receipt_missing"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSPrivacyReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
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

struct AmbitionsOSPrivacySafetyPolicy: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let objectID: String
    let surface: AmbitionsOSControlPlaneSurface
    let permissionState: AmbitionsOSPrivacyPermissionState
    let privacyClass: HumanProgressPrivacyClass
    let sensitiveAreas: [AmbitionsOSPrivacySensitiveArea]
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let projectionPolicy: AmbitionsOSPrivacyProjectionPolicy
    let toolIntent: AmbitionsOSPrivacyToolIntent
    let toolApprovalState: LocalLanguageToolApprovalState
    let deterministicFallbackAvailable: Bool
    let redactionSummary: String
    let receipts: [AmbitionsOSPrivacyReceipt]
    let changesAppState: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        objectID: String,
        surface: AmbitionsOSControlPlaneSurface,
        permissionState: AmbitionsOSPrivacyPermissionState,
        privacyClass: HumanProgressPrivacyClass,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = [],
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        projectionPolicy: AmbitionsOSPrivacyProjectionPolicy = .redactedLocal,
        toolIntent: AmbitionsOSPrivacyToolIntent = .readLocalSummary,
        toolApprovalState: LocalLanguageToolApprovalState = .reviewOnly,
        deterministicFallbackAvailable: Bool = true,
        redactionSummary: String,
        receipts: [AmbitionsOSPrivacyReceipt],
        changesAppState: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSPrivacySafetySchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.objectID = objectID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.surface = surface
        self.permissionState = permissionState
        self.privacyClass = privacyClass
        self.sensitiveAreas = Array(Set(sensitiveAreas)).sorted { $0.rawValue < $1.rawValue }
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.projectionPolicy = projectionPolicy
        self.toolIntent = toolIntent
        self.toolApprovalState = toolApprovalState
        self.deterministicFallbackAvailable = deterministicFallbackAvailable
        self.redactionSummary = redactionSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.receipts = receipts.sorted { $0.id < $1.id }
        self.changesAppState = changesAppState
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            objectID.isEmpty == false &&
            schemaVersion == ambitionsOSPrivacySafetySchemaVersion &&
            receipts.allSatisfy(\.isWellFormed)
    }

    var isSensitive: Bool {
        privacyClass == .sensitive ||
            privacyClass == .deletePending ||
            sensitiveAreas.isEmpty == false
    }

    var projectsExternally: Bool {
        surface == .externalProjection ||
            projectionPolicy == .externalRedacted ||
            projectionPolicy == .externalBlocked
    }

    var hasReviewReadySource: Bool {
        sourceState.canDriveSourceSensitiveRecommendation &&
            freshnessState.blocksHighRiskUse == false &&
            reviewState == .ready
    }
}
