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
        notes: "\(ExternalSurfaceTruth.availableButNeedsManualVerification). Local notification runtime and scheduling already exist; keep future work on the existing bootstrap and routing seam."
    )

    static let calendarReminders = FutureIntegrationPlaceholderContext(
        surface: .calendarReminders,
        notes: "EventKit calendar and reminder actions are already shipped; use this seam only for future permission-flow refinement or additional routing."
    )

    static let widgetsLiveActivities = FutureIntegrationPlaceholderContext(
        surface: .widgetsLiveActivities,
        notes: "\(ExternalSurfaceTruth.productizedNeedsPlatformReview). Widgets and Live Activity now consume shared external snapshot and continuity state; future work should stay on that seam."
    )

    static let shareExtension = FutureIntegrationPlaceholderContext(
        surface: .shareExtension,
        notes: "\(ExternalSurfaceTruth.notShippedInThisBuild). Wire share-extension intake here only after a dedicated extension target and explicit handoff path are intentionally added."
    )

    static let appIntents = FutureIntegrationPlaceholderContext(
        surface: .appIntents,
        notes: "\(ExternalSurfaceTruth.availableButNeedsManualVerification). App Intents stay navigation-only and must continue to route through the canonical app-entry seam."
    )
}
