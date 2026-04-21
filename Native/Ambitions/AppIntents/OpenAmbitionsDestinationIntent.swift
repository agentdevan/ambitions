import AppIntents
import Foundation

enum AmbitionsAppShortcutDestination: String, CaseIterable, AppEnum {
    case today
    case plan
    case capturesInbox = "captures_inbox"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Destination"
    static var typeDisplayName: LocalizedStringResource = "Destination"

    static var caseDisplayRepresentations: [AmbitionsAppShortcutDestination: DisplayRepresentation] {
        [
            .today: DisplayRepresentation(title: "Today"),
            .plan: DisplayRepresentation(title: "Plan"),
            .capturesInbox: DisplayRepresentation(title: "Captures inbox"),
        ]
    }

    var appRoute: AppExternalRoute {
        switch self {
        case .today:
            return .openTab(.today)
        case .plan:
            return .openTab(.plan)
        case .capturesInbox:
            return .openPlanRoute(.capturesInbox)
        }
    }

    var displayTitle: String {
        switch self {
        case .today:
            return "Today"
        case .plan:
            return "Plan"
        case .capturesInbox:
            return "Captures inbox"
        }
    }

    var routeURL: URL? {
        AppExternalRouteTranslator().deepLinkURL(for: appRoute)
    }
}

struct OpenAmbitionsDestinationIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Ambitions destination"
    static let description = IntentDescription("Open Today, Plan, or the Captures inbox in Ambitions.")
    static let openAppWhenRun = true

    @Parameter(title: "Destination")
    var destination: AmbitionsAppShortcutDestination

    init() {}

    init(destination: AmbitionsAppShortcutDestination) {
        self.destination = destination
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let url = destination.routeURL else {
            return .result(dialog: "Ambitions could not open that destination.")
        }

        await MainActor.run {
            AppIntentLaunchRouter.shared.queue(url)
        }
        return .result(dialog: IntentDialog("Opening \(destination.displayTitle) in Ambitions."))
    }
}

struct AmbitionsShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .today),
            phrases: [
                "Open Today in \(.applicationName)",
                "Show Today in \(.applicationName)",
            ],
            shortTitle: "Open Today",
            systemImageName: "sun.max"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .plan),
            phrases: [
                "Open Plan in \(.applicationName)",
                "Show Plan in \(.applicationName)",
            ],
            shortTitle: "Open Plan",
            systemImageName: "calendar.badge.clock"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .capturesInbox),
            phrases: [
                "Open Captures in \(.applicationName)",
                "Show Captures inbox in \(.applicationName)",
            ],
            shortTitle: "Open Captures",
            systemImageName: "tray.full"
        )
    }

    static var shortcutTileColor: ShortcutTileColor {
        .teal
    }
}
