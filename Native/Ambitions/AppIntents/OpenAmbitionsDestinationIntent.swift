import AppIntents
import Foundation

enum AmbitionsAppShortcutDestination: String, CaseIterable, AppEnum {
    case today
    case plan
    case capturesInbox = "captures_inbox"
    case command
    case memoryLens = "memory_lens"
    case quickCapture = "quick_capture"
    case quickRecovery = "quick_recovery"
    case quickFocus = "quick_focus"
    case quickPlanPatch = "quick_plan_patch"

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
            .quickRecovery: DisplayRepresentation(title: "Quick recovery"),
            .quickFocus: DisplayRepresentation(title: "Quick focus"),
            .quickPlanPatch: DisplayRepresentation(title: "Quick plan"),
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
        case .quickRecovery:
            return .openToday(.recovery)
        case .quickFocus:
            return .openToday(.focus)
        case .quickPlanPatch:
            return .openTab(.plan)
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
        case .quickRecovery:
            return "Quick recovery"
        case .quickFocus:
            return "Quick focus"
        case .quickPlanPatch:
            return "Quick plan"
        }
    }

    var routeURL: URL? {
        guard var components = AppExternalRouteTranslator().deepLinkURL(for: appRoute).flatMap({
            URLComponents(url: $0, resolvingAgainstBaseURL: false)
        }) else {
            return nil
        }
        var queryItems = components.queryItems ?? []
        if queryItems.contains(where: { $0.name == "origin" }) == false {
            queryItems.append(URLQueryItem(name: "origin", value: ExternalSurfaceOrigin.appIntent.rawValue))
        }
        components.queryItems = queryItems
        return components.url
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

struct CreateAmbitionsCaptureIntent: AppIntent {
    static let title: LocalizedStringResource = "Capture in Ambitions"
    static let description = IntentDescription("Save a thought into the canonical Ambitions captures inbox.")
    static let openAppWhenRun = true

    @Parameter(title: "Capture")
    var text: String

    init() {}

    init(text: String) {
        self.text = text
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return .result(dialog: "Capture needs text.")
        }

        let request = ExternalCreationRequest(
            id: "intent-\(UUID().uuidString)",
            createdAt: ISO8601DateFormatter().string(from: Date()),
            text: trimmed,
            source: .appIntent,
            landing: .capturesInbox
        )
        try SharedExternalCreationStore().append(request)

        await MainActor.run {
            if let url = ExternalSurfaceActionPayload.deepLinkURL(
                surface: .capturesInbox,
                origin: .appIntent
            ) {
                AppIntentLaunchRouter.shared.queue(url)
            }
        }

        return .result(dialog: IntentDialog("Saved to Ambitions captures."))
    }
}

struct AmbitionsShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateAmbitionsCaptureIntent(),
            phrases: [
                "Capture in \(.applicationName)",
                "Add to \(.applicationName)",
            ],
            shortTitle: "Capture",
            systemImageName: "square.and.pencil"
        )
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
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .quickFocus),
            phrases: [
                "Quick Focus in \(.applicationName)",
                "Focus in \(.applicationName)",
            ],
            shortTitle: "Quick Focus",
            systemImageName: "scope"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .quickRecovery),
            phrases: [
                "Quick Recovery in \(.applicationName)",
                "Recover in \(.applicationName)",
            ],
            shortTitle: "Recover",
            systemImageName: "arrow.uturn.left.circle"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .quickPlanPatch),
            phrases: [
                "Quick Plan in \(.applicationName)",
                "Patch Plan in \(.applicationName)",
            ],
            shortTitle: "Quick Plan",
            systemImageName: "calendar.badge.clock"
        )
    }

    static var shortcutTileColor: ShortcutTileColor {
        .teal
    }
}
