import Foundation

/// Integration status map for OS-facing surfaces that still need dedicated
/// bootstrap or routing seams.
///
/// This file is intentionally non-functional. It keeps the remaining future
/// integration work centralized without pretending that unshipped surfaces
/// like Share Extension or App Intents are already wired.
enum FutureIntegrationSurface: String, CaseIterable, Sendable {
    case notifications
    case calendarReminders = "calendar_reminders"
    case widgetsLiveActivities = "widgets_live_activities"
    case shareExtension = "share_extension"
    case appIntents = "app_intents"
}

struct FutureIntegrationPlaceholderContext: Sendable {
    let surface: FutureIntegrationSurface
    let notes: String
}

enum FutureIntegrationPlaceholders {
    static let notifications = FutureIntegrationPlaceholderContext(
        surface: .notifications,
        notes: "Local notification runtime and scheduling are already shipped; use this seam only for future bootstrap refinements or expanded routing."
    )

    static let calendarReminders = FutureIntegrationPlaceholderContext(
        surface: .calendarReminders,
        notes: "EventKit calendar and reminder actions are already shipped; use this seam only for future permission-flow refinement or additional routing."
    )

    static let widgetsLiveActivities = FutureIntegrationPlaceholderContext(
        surface: .widgetsLiveActivities,
        notes: "Widgets and Live Activities are already shipped; use this seam only if future work expands shared snapshot bootstrap or deep-link handling."
    )

    static let shareExtension = FutureIntegrationPlaceholderContext(
        surface: .shareExtension,
        notes: "Wire share-extension intake and any App Group handoff here after the extension target is added."
    )

    static let appIntents = FutureIntegrationPlaceholderContext(
        surface: .appIntents,
        notes: "Wire App Intent definitions and action routing here only after the underlying in-app action is stable."
    )
}
