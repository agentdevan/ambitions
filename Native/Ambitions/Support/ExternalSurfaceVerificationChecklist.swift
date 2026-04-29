import Foundation

enum ExternalSurfaceVerificationSurface: String, CaseIterable, Codable, Sendable, Equatable {
    case notifications
    case widgets
    case liveActivities = "live_activities"
    case appIntents = "app_intents"
    case shortcuts
    case sharedSnapshotContainer = "shared_snapshot_container"
}

struct ExternalSurfaceVerificationRecord: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let surface: ExternalSurfaceVerificationSurface
    let contractKind: ExternalSurfaceKind?
    let automatedEvidence: [String]
    let manualVerificationRequired: [String]
    let privacyRequirements: [String]
    let staleFailureRequirements: [String]
    let routingRequirements: [String]
    let receiptRequirements: [String]
    let activeLimitations: [String]
    let readinessClaim: String

    var requiresDeviceEvidenceBeforeReadinessClaim: Bool {
        manualVerificationRequired.isEmpty == false
    }
}

enum ExternalSurfaceVerificationChecklist {
    static let records: [ExternalSurfaceVerificationRecord] = [
        ExternalSurfaceVerificationRecord(
            id: "m04.notifications",
            surface: .notifications,
            contractKind: .notifications,
            automatedEvidence: [
                "LocalNotificationFoundationTests",
                "NotificationResponsePayloadParserTests",
                "ExternalActionCommandServiceTests"
            ],
            manualVerificationRequired: [
                "Notification authorization prompt and delivery on a real device",
                "Notification actions from lock screen and Notification Center"
            ],
            privacyRequirements: [
                "Use sparse payloads",
                "Hide full goal details and raw calendar data by default"
            ],
            staleFailureRequirements: [
                "Carry continuity and lease fields",
                "Open Ambitions when local state may be behind"
            ],
            routingRequirements: [
                "Open canonical Today or Goal routes through AppExternalRouteTranslator",
                "Preserve notification origin on routed actions"
            ],
            receiptRequirements: [
                "Mutation-capable actions must run through shared command policy and produce receipts where mutation occurs"
            ],
            activeLimitations: [
                "Simulator tests do not prove real notification delivery"
            ],
            readinessClaim: "Not platform-ready until real notification delivery and actions are verified."
        ),
        ExternalSurfaceVerificationRecord(
            id: "m04.widgets",
            surface: .widgets,
            contractKind: .widgets,
            automatedEvidence: [
                "ExternalWidgetProjectionTests",
                "ExternalSurfaceSnapshotTests",
                "Ambitions widget extension simulator build"
            ],
            manualVerificationRequired: [
                "Rendered widget gallery and supported families on device",
                "Lock Screen/accessory rendering where available"
            ],
            privacyRequirements: [
                "Hide sensitive goal details by default",
                "Use safe widget projection labels"
            ],
            staleFailureRequirements: [
                "Show stale or unavailable labels from the shared privacy policy",
                "Fallback to Today when a goal route is unavailable"
            ],
            routingRequirements: [
                "Use ambitions:// links with widget origin",
                "Fallback route must remain canonical Today"
            ],
            receiptRequirements: [
                "Widget mutations remain routed through shared commands; rendered widget is not a separate mutation engine"
            ],
            activeLimitations: [
                "Simulator build proves compilation and embedding, not rendered gallery behavior"
            ],
            readinessClaim: "Not platform-ready until rendered widget behavior is verified on device."
        ),
        ExternalSurfaceVerificationRecord(
            id: "m04.live-activities",
            surface: .liveActivities,
            contractKind: .liveActivities,
            automatedEvidence: [
                "ExternalSurfaceSnapshotTests",
                "NextStepLiveActivityWidget simulator build"
            ],
            manualVerificationRequired: [
                "ActivityKit start, update, end, Lock Screen, and Dynamic Island behavior on device"
            ],
            privacyRequirements: [
                "No sensitive goal names by default",
                "Glanceable private labels only"
            ],
            staleFailureRequirements: [
                "Show stale or unavailable state labels",
                "Use bounded endsAt instead of indefinite activity windows"
            ],
            routingRequirements: [
                "Use ambitions:// links with live_activity origin",
                "Fallback route must remain Plan"
            ],
            receiptRequirements: [
                "Mutation-capable Live Activity actions remain confirmation/receipt bound through shared command policy"
            ],
            activeLimitations: [
                "Simulator/unit proof does not verify ActivityKit lifecycle delivery"
            ],
            readinessClaim: "Not platform-ready until ActivityKit lifecycle behavior is verified on device."
        ),
        ExternalSurfaceVerificationRecord(
            id: "m04.app-intents",
            surface: .appIntents,
            contractKind: .appIntents,
            automatedEvidence: [
                "AppIntentRoutingTests",
                "ExternalActionCommandServiceTests",
                "App Intents metadata simulator build"
            ],
            manualVerificationRequired: [
                "Shortcuts app discovery",
                "Siri/App Intent invocation on device"
            ],
            privacyRequirements: [
                "Use minimal payloads",
                "Keep privacy-safe dialogs"
            ],
            staleFailureRequirements: [
                "Safe failure when required local targets are missing",
                "Open Ambitions for confirmation when state may be behind"
            ],
            routingRequirements: [
                "Route App Intent origin separately from widget fallback",
                "Use canonical destinations for Capture, Start Next Step, Mark Done, Save the Day, and Open Plan"
            ],
            receiptRequirements: [
                "Mark Done and Save the Day require confirmation and receipts where mutation occurs"
            ],
            activeLimitations: [
                "Metadata build does not prove real Shortcuts/Siri invocation"
            ],
            readinessClaim: "Not platform-ready until Shortcuts/Siri invocation is verified on device."
        ),
        ExternalSurfaceVerificationRecord(
            id: "m04.shortcuts",
            surface: .shortcuts,
            contractKind: .shortcuts,
            automatedEvidence: [
                "AppIntentRoutingTests",
                "SafeAutomationPolicyModelsTests"
            ],
            manualVerificationRequired: [
                "Shortcuts app presentation and parameter dialogs on device"
            ],
            privacyRequirements: [
                "Use conservative status summaries",
                "Avoid silent destructive automation"
            ],
            staleFailureRequirements: [
                "Safe failure with calm copy when local targets are missing"
            ],
            routingRequirements: [
                "Use shared shortcut command descriptors",
                "Open canonical app routes instead of duplicate shortcut-only routes"
            ],
            receiptRequirements: [
                "Mutation-capable shortcuts require confirmation and receipts where mutation occurs"
            ],
            activeLimitations: [
                "Unit tests do not prove Shortcuts app presentation"
            ],
            readinessClaim: "Not platform-ready until Shortcuts presentation and dialogs are verified on device."
        ),
        ExternalSurfaceVerificationRecord(
            id: "m04.shared-snapshot-container",
            surface: .sharedSnapshotContainer,
            contractKind: nil,
            automatedEvidence: [
                "SharedExternalSnapshotStore app group contract",
                "App and widget extension entitlements"
            ],
            manualVerificationRequired: [
                "Shared container read/write behavior across installed app and extension on device"
            ],
            privacyRequirements: [
                "Store lightweight privacy-safe snapshots only",
                "Do not store rendered widget or Live Activity state as user data"
            ],
            staleFailureRequirements: [
                "Missing snapshot falls back to safe unavailable labels",
                "External surfaces must open Ambitions to refresh uncertain state"
            ],
            routingRequirements: [
                "Shared snapshots feed existing external payload and deep-link helpers"
            ],
            receiptRequirements: [
                "Shared container does not create a separate mutation or receipt store"
            ],
            activeLimitations: [
                "Simulator build and entitlements do not prove installed-device app-group I/O"
            ],
            readinessClaim: "Not platform-ready until shared-container behavior is verified on device."
        )
    ]

    static func record(for surface: ExternalSurfaceVerificationSurface) -> ExternalSurfaceVerificationRecord {
        guard let record = records.first(where: { $0.surface == surface }) else {
            preconditionFailure("Missing M04 external surface verification record for \(surface.rawValue)")
        }
        return record
    }
}
