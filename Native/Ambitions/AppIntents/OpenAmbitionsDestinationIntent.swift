import AppIntents
import Foundation

enum AmbitionsAppShortcutDestination: String, CaseIterable, AppEnum {
    case today
    case plan
    case capturesInbox = "captures_inbox"
    case command
    case memoryLens = "memory_lens"
    case quickCapture = "quick_capture"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Destination"
    static var typeDisplayName: LocalizedStringResource = "Destination"

    static var caseDisplayRepresentations: [AmbitionsAppShortcutDestination: DisplayRepresentation] {
        [
            .today: DisplayRepresentation(title: "Today"),
            .plan: DisplayRepresentation(title: "Plan"),
            .capturesInbox: DisplayRepresentation(title: "Captures inbox"),
            .command: DisplayRepresentation(title: "Command"),
            .memoryLens: DisplayRepresentation(title: "Memory Lens"),
            .quickCapture: DisplayRepresentation(title: "Quick capture"),
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
        case .command:
            return .presentOverlay(.commandSheet(entrySource: .appIntent))
        case .memoryLens:
            return .presentOverlay(.memoryLens(entrySource: .appIntent))
        case .quickCapture:
            return .presentOverlay(.commandSheet(intent: .quickCapture, entrySource: .appIntent, presentationContext: .quickCapture))
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
        case .command:
            return "Command"
        case .memoryLens:
            return "Memory Lens"
        case .quickCapture:
            return "Quick capture"
        }
    }

    var routeURL: URL? {
        AppExternalRouteTranslator().deepLinkURL(for: appRoute)
    }
}

struct OpenAmbitionsDestinationIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Ambitions destination"
    static let description = IntentDescription("Open canonical Ambitions destinations or shell-owned command surfaces.")
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
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .command),
            phrases: [
                "Open Command in \(.applicationName)",
                "Show Command in \(.applicationName)",
            ],
            shortTitle: "Open Command",
            systemImageName: "plus.circle"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .memoryLens),
            phrases: [
                "Open Memory Lens in \(.applicationName)",
                "Show Memory Lens in \(.applicationName)",
            ],
            shortTitle: "Memory Lens",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .quickCapture),
            phrases: [
                "Quick Capture in \(.applicationName)",
                "Capture in \(.applicationName)",
            ],
            shortTitle: "Quick Capture",
            systemImageName: "square.and.pencil"
        )
    }

    static var shortcutTileColor: ShortcutTileColor {
        .teal
    }
}
