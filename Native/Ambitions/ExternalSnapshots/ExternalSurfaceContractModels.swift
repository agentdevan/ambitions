import Foundation

enum ExternalSurfaceKind: String, CaseIterable, Codable, Sendable, Equatable {
    case notifications
    case widgets
    case liveActivities = "live_activities"
    case appIntents = "app_intents"
    case shortcuts
    case focusFilters = "focus_filters"
}

enum ExternalSurfacePrivacyDefault: String, Codable, Sendable, Equatable {
    case sparse
    case detailsHidden = "details_hidden"
    case glanceablePrivate = "glanceable_private"
    case minimalPayload = "minimal_payload"
    case conservative
    case optIn = "opt_in"
}

struct ExternalSurfacePrivacySnapshotPolicy: Codable, Sendable, Equatable {
    static let safeDefault = ExternalSurfacePrivacySnapshotPolicy(
        defaultVisibility: .detailsHidden,
        sensitiveDetailLabel: "Details stay private until you open Ambitions.",
        unavailableLabel: "Open Ambitions to confirm the latest local state.",
        staleLabel: "This may be behind. Open Ambitions to refresh."
    )

    let defaultVisibility: ExternalSurfacePrivacyDefault
    let sensitiveDetailLabel: String
    let unavailableLabel: String
    let staleLabel: String
}

struct ExternalSurfaceContract: Codable, Sendable, Equatable {
    let kind: ExternalSurfaceKind
    let allowedContent: [String]
    let forbiddenContent: [String]
    let privacyDefault: ExternalSurfacePrivacyDefault
    let hidesSensitiveDetailsByDefault: Bool
    let allowedActions: [String]
    let fallbackRoute: ExternalSurfacePayloadSurface
    let fallbackTab: String?
    let snapshotRule: String
    let degradedStateLabel: String
    let requiresSharedCommandPipeline: Bool
    let requiresReceiptForMutation: Bool
    let requiresConfirmationForSensitiveExternalDestructiveEffects: Bool
    let accessibilityRequirement: String
}

enum ExternalSurfaceContractRegistry {
    static let contracts: [ExternalSurfaceContract] = [
        ExternalSurfaceContract(
            kind: .notifications,
            allowedContent: ["Now", "Next Step", "protected block", "plan adjustment", "receipt-safe result"],
            forbiddenContent: ["spam", "guilt", "full goal details by default", "raw calendar data"],
            privacyDefault: .sparse,
            hidesSensitiveDetailsByDefault: true,
            allowedActions: ["Start", "Move", "Park", "Mark Done", "Open Time"],
            fallbackRoute: .tab,
            fallbackTab: "today",
            snapshotRule: "Lightweight payloads only; no heavy recompute.",
            degradedStateLabel: "Unavailable or stale. Open Ambitions to confirm.",
            requiresSharedCommandPipeline: true,
            requiresReceiptForMutation: true,
            requiresConfirmationForSensitiveExternalDestructiveEffects: true,
            accessibilityRequirement: "Concise labels, action names, and no sensitive speech by default."
        ),
        ExternalSurfaceContract(
            kind: .widgets,
            allowedContent: ["Now", "Recommended step", "Today pressure", "protected time", "capture entry", "recovery state", "stale state"],
            forbiddenContent: ["full control panels", "every goal", "private details by default"],
            privacyDefault: .detailsHidden,
            hidesSensitiveDetailsByDefault: true,
            allowedActions: ["Open app", "Open object", "Start where safe"],
            fallbackRoute: .tab,
            fallbackTab: "today",
            snapshotRule: "Lightweight snapshots only.",
            degradedStateLabel: "Stale or locally unavailable. Open Ambitions to refresh.",
            requiresSharedCommandPipeline: true,
            requiresReceiptForMutation: true,
            requiresConfirmationForSensitiveExternalDestructiveEffects: true,
            accessibilityRequirement: "Dynamic Type by family, contrast, and clear labels."
        ),
        ExternalSurfaceContract(
            kind: .liveActivities,
            allowedContent: ["current window", "elapsed/remaining", "safe next action"],
            forbiddenContent: ["sensitive goal names by default", "indefinite activities"],
            privacyDefault: .glanceablePrivate,
            hidesSensitiveDetailsByDefault: true,
            allowedActions: ["Open Time", "Mark Done where safe", "Park where safe"],
            fallbackRoute: .tab,
            fallbackTab: "time",
            snapshotRule: "Defined beginning/end; no heavy updates.",
            degradedStateLabel: "Ended or stale. Open Ambitions to confirm.",
            requiresSharedCommandPipeline: true,
            requiresReceiptForMutation: true,
            requiresConfirmationForSensitiveExternalDestructiveEffects: true,
            accessibilityRequirement: "System contrast and concise spoken summary."
        ),
        ExternalSurfaceContract(
            kind: .appIntents,
            allowedContent: ["Capture", "Start Next Step", "Mark Done", "Save the Day", "Open Time"],
            forbiddenContent: ["destructive actions without confirmation", "external writes without confirmation", "sensitive actions without confirmation"],
            privacyDefault: .minimalPayload,
            hidesSensitiveDetailsByDefault: true,
            allowedActions: ["Capture", "Start Next Step", "Mark Done", "Save the Day", "Open Time"],
            fallbackRoute: .tab,
            fallbackTab: "today",
            snapshotRule: "Use Command Pipeline; no duplicate work.",
            degradedStateLabel: "Safe failure with receipt.",
            requiresSharedCommandPipeline: true,
            requiresReceiptForMutation: true,
            requiresConfirmationForSensitiveExternalDestructiveEffects: true,
            accessibilityRequirement: "Clear parameter labels and confirmation."
        ),
        ExternalSurfaceContract(
            kind: .shortcuts,
            allowedContent: ["Capture", "Open Time", "Save the Day", "safe status"],
            forbiddenContent: ["silent destructive automations"],
            privacyDefault: .conservative,
            hidesSensitiveDetailsByDefault: true,
            allowedActions: ["Capture", "Open Time", "Save the Day", "safe status"],
            fallbackRoute: .tab,
            fallbackTab: "today",
            snapshotRule: "Lightweight shared commands.",
            degradedStateLabel: "Safe failure.",
            requiresSharedCommandPipeline: true,
            requiresReceiptForMutation: true,
            requiresConfirmationForSensitiveExternalDestructiveEffects: true,
            accessibilityRequirement: "Clear names and result summaries."
        ),
        ExternalSurfaceContract(
            kind: .focusFilters,
            allowedContent: ["mode/context preference", "privacy-safe state"],
            forbiddenContent: ["hidden navigation", "data mutation"],
            privacyDefault: .optIn,
            hidesSensitiveDetailsByDefault: true,
            allowedActions: ["Change emphasis only"],
            fallbackRoute: .tab,
            fallbackTab: "today",
            snapshotRule: "No heavy projection.",
            degradedStateLabel: "Ignore safely if unavailable.",
            requiresSharedCommandPipeline: false,
            requiresReceiptForMutation: false,
            requiresConfirmationForSensitiveExternalDestructiveEffects: true,
            accessibilityRequirement: "User-visible alternatives and labels."
        )
    ]

    static func contract(for kind: ExternalSurfaceKind) -> ExternalSurfaceContract {
        guard let contract = contracts.first(where: { $0.kind == kind }) else {
            preconditionFailure("Missing external surface contract for \(kind.rawValue)")
        }
        return contract
    }
}
