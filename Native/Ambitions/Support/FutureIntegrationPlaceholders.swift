import Foundation

/// Placeholder map for future OS integrations.
///
/// This file is intentionally non-functional. It gives later work a single
/// location to wire capability-specific bootstrap, routing, and dependency
/// injection without implying that any permission is currently enabled.
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
        notes: "Wire UNUserNotificationCenter authorization, categories, and scheduling here only when notifications ship."
    )

    static let calendarReminders = FutureIntegrationPlaceholderContext(
        surface: .calendarReminders,
        notes: "Wire EventKit authorization and calendar/reminder services here only when the feature is shipped."
    )

    static let widgetsLiveActivities = FutureIntegrationPlaceholderContext(
        surface: .widgetsLiveActivities,
        notes: "Wire WidgetKit and ActivityKit shared snapshot or activity state here after the extension targets exist."
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

