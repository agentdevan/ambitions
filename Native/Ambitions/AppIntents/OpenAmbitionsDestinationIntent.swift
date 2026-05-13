import AppIntents
import Foundation

enum AmbitionsAppShortcutDestination: String, CaseIterable, AppEnum {
    case today
    case plan
    case captureInbox = "captures_inbox"
    case command
    case memoryLens = "memory_lens"
    case quickCapture = "quick_capture"
    case startNextStep = "start_next_step"
    case markDone = "mark_done"
    case saveTheDay = "save_the_day"
    case quickRecovery = "quick_recovery"
    case quickFocus = "quick_focus"
    case quickPlanPatch = "quick_plan_patch"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Destination"
    static let typeDisplayName: LocalizedStringResource = "Destination"

    static var caseDisplayRepresentations: [AmbitionsAppShortcutDestination: DisplayRepresentation] {
        [
            .today: DisplayRepresentation(title: "Today"),
            .plan: DisplayRepresentation(title: "Time"),
            .captureInbox: DisplayRepresentation(title: "Capture"),
            .command: DisplayRepresentation(title: "Add something"),
            .memoryLens: DisplayRepresentation(title: "What Ambitions Knows"),
            .quickCapture: DisplayRepresentation(title: "Capture"),
            .startNextStep: DisplayRepresentation(title: "Start here"),
            .markDone: DisplayRepresentation(title: "Close the loop"),
            .saveTheDay: DisplayRepresentation(title: "Make today doable"),
            .quickRecovery: DisplayRepresentation(title: "Make today doable"),
            .quickFocus: DisplayRepresentation(title: "Start now"),
            .quickPlanPatch: DisplayRepresentation(title: "Shape Time"),
        ]
    }

    var appRoute: AppExternalRoute {
        switch self {
        case .today:
            return .openTab(.today)
        case .plan:
            return .openTab(.plan)
        case .captureInbox:
            return .openPlanRoute(.captureInbox)
        case .command:
            return .presentOverlay(.commandSheet(entrySource: .appIntent))
        case .memoryLens:
            return .presentOverlay(.memoryLens(entrySource: .appIntent))
        case .quickCapture:
            return .presentOverlay(.commandSheet(intent: .quickCapture, entrySource: .appIntent, presentationContext: .quickCapture))
        case .startNextStep:
            return .openToday(.focus)
        case .markDone:
            return .openToday(.focus)
        case .saveTheDay:
            return .openToday(.recovery)
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
            return "Time"
        case .captureInbox:
            return "Capture"
        case .command:
            return "Add something"
        case .memoryLens:
            return "What Ambitions Knows"
        case .quickCapture:
            return "Capture"
        case .startNextStep:
            return "Start here"
        case .markDone:
            return "Close the loop"
        case .saveTheDay:
            return "Make today doable"
        case .quickRecovery:
            return "Make today doable"
        case .quickFocus:
            return "Start now"
        case .quickPlanPatch:
            return "Shape Time"
        }
    }

    var routeURL: URL? {
        d25CommandDescriptor.routeURL
    }

    var isPFC18PublicLaunchCandidate: Bool {
        switch self {
        case .today, .plan, .captureInbox, .command, .memoryLens, .startNextStep, .markDone, .saveTheDay:
            return true
        case .quickCapture, .quickRecovery, .quickFocus, .quickPlanPatch:
            return false
        }
    }
}

enum AmbitionsShortcutExecutionPosture: String, Sendable, Equatable {
    case opensAppOnly
    case queuesLocalCapture
    case requiresInAppConfirmation
}

struct AmbitionsShortcutCommandDescriptor: Sendable, Equatable {
    let destination: AmbitionsAppShortcutDestination
    let title: String
    let dialog: String
    let commandKind: AmbitionsCommandKind
    let actionName: ExternalSurfaceActionName
    let contractKind: ExternalSurfaceKind
    let executionPosture: AmbitionsShortcutExecutionPosture
    let producesReceipt: Bool
    let privacySummary: String
    let routeURL: URL?

    var requiresConfirmation: Bool {
        executionPosture == .requiresInAppConfirmation
    }
}

extension AmbitionsAppShortcutDestination {
    var d25CommandDescriptor: AmbitionsShortcutCommandDescriptor {
        let routeURL = Self.url(for: appRoute)
        switch self {
        case .today:
            return descriptor(
                title: "Today",
                dialog: "Opening Today in Ambitions.",
                commandKind: .openDestination,
                actionName: .openToday,
                routeURL: routeURL
            )
        case .plan, .quickPlanPatch:
            return descriptor(
                title: displayTitle,
                dialog: "Opening Time in Ambitions.",
                commandKind: .openDestination,
                actionName: .open,
                routeURL: routeURL
            )
        case .captureInbox:
            return descriptor(
                title: "Capture",
                dialog: "Opening Capture in Ambitions.",
                commandKind: .openDestination,
                actionName: .openCapturesInbox,
                routeURL: routeURL
            )
        case .command:
            return descriptor(
                title: "Add something",
                dialog: "Opening the quiet add sheet in Ambitions.",
                commandKind: .openDestination,
                actionName: .open,
                routeURL: routeURL
            )
        case .memoryLens:
            return descriptor(
                title: "What Ambitions Knows",
                dialog: "Opening What Ambitions Knows.",
                commandKind: .openDestination,
                actionName: .openMemoryLens,
                routeURL: routeURL
            )
        case .quickCapture:
            return descriptor(
                title: "Capture",
                dialog: "Opening Capture in Ambitions.",
                commandKind: .quickCapture,
                actionName: .openCapturesInbox,
                executionPosture: .queuesLocalCapture,
                producesReceipt: true,
                routeURL: routeURL
            )
        case .startNextStep, .quickFocus:
            return descriptor(
                title: displayTitle,
                dialog: "Opening the recommended step in Ambitions.",
                commandKind: .startStepSession,
                actionName: .openToday,
                routeURL: routeURL
            )
        case .markDone:
            return descriptor(
                title: "Close the loop",
                dialog: "Open Ambitions to close the loop.",
                commandKind: .completeAction,
                actionName: .complete,
                executionPosture: .requiresInAppConfirmation,
                producesReceipt: true,
                routeURL: routeURL
            )
        case .saveTheDay, .quickRecovery:
            return descriptor(
                title: displayTitle,
                dialog: "Open Ambitions to make today doable.",
                commandKind: .recoverAction,
                actionName: .openToday,
                executionPosture: .requiresInAppConfirmation,
                producesReceipt: true,
                routeURL: routeURL
            )
        }
    }

    private func descriptor(
        title: String,
        dialog: String,
        commandKind: AmbitionsCommandKind,
        actionName: ExternalSurfaceActionName,
        executionPosture: AmbitionsShortcutExecutionPosture = .opensAppOnly,
        producesReceipt: Bool = false,
        routeURL: URL?
    ) -> AmbitionsShortcutCommandDescriptor {
        let contract = ExternalSurfaceContractRegistry.contract(for: .appIntents)
        return AmbitionsShortcutCommandDescriptor(
            destination: self,
            title: title,
            dialog: dialog,
            commandKind: commandKind,
            actionName: actionName,
            contractKind: contract.kind,
            executionPosture: executionPosture,
            producesReceipt: producesReceipt,
            privacySummary: contract.hidesSensitiveDetailsByDefault
                ? ExternalSurfacePrivacySnapshotPolicy.safeDefault.sensitiveDetailLabel
                : "Shortcut details follow your Ambitions privacy settings.",
            routeURL: routeURL
        )
    }

    private static func url(for appRoute: AppExternalRoute) -> URL? {
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
    static let title: LocalizedStringResource = "Open Ambitions"
    static let description = IntentDescription("Open Today, Time, Capture, or another Ambitions surface.")
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
        return .result(dialog: IntentDialog(stringLiteral: destination.d25CommandDescriptor.dialog))
    }
}

struct CreateAmbitionsCaptureIntent: AppIntent {
    static let title: LocalizedStringResource = "Capture in Ambitions"
    static let description = IntentDescription("Save something to Ambitions so it has a place.")
    static let openAppWhenRun = true

    @Parameter(title: "Capture")
    var text: String

    init() {}

    init(text: String) {
        self.text = text
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let request: ExternalCreationRequest
        do {
            request = try Self.makeCaptureRequest(text: text, now: Date(), id: "intent-\(UUID().uuidString)")
        } catch {
            return .result(dialog: "Capture needs text.")
        }

        try SharedExternalCreationStore().append(request)

        await MainActor.run {
            if let url = ExternalSurfaceActionPayload.deepLinkURL(
                surface: .captureInbox,
                origin: .appIntent
            ) {
                AppIntentLaunchRouter.shared.queue(url)
            }
        }

        return .result(dialog: IntentDialog("Saved locally to Capture. Open Ambitions to review the receipt."))
    }

    static func makeCaptureRequest(text: String, now: Date, id: String) throws -> ExternalCreationRequest {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw SharedExternalCreationStoreError.emptyText
        }

        return ExternalCreationRequest(
            id: id,
            createdAt: ISO8601DateFormatter().string(from: now),
            text: trimmed,
            source: .appIntent,
            landing: .captureInbox
        )
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
                "Open Time in \(.applicationName)",
                "Show Time in \(.applicationName)",
            ],
            shortTitle: "Open Time",
            systemImageName: "calendar.badge.clock"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .captureInbox),
            phrases: [
                "Open Capture in \(.applicationName)",
                "Show Capture in \(.applicationName)",
            ],
            shortTitle: "Open Capture",
            systemImageName: "tray.full"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .command),
            phrases: [
                "Add something in \(.applicationName)",
                "Open add sheet in \(.applicationName)",
            ],
            shortTitle: "Add Something",
            systemImageName: "plus.circle"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .memoryLens),
            phrases: [
                "Open what \(.applicationName) knows",
                "Show what \(.applicationName) knows",
            ],
            shortTitle: "What Ambitions Knows",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .startNextStep),
            phrases: [
                "Start here in \(.applicationName)",
                "Start my recommended step in \(.applicationName)",
            ],
            shortTitle: "Start Here",
            systemImageName: "scope"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .markDone),
            phrases: [
                "Close the loop in \(.applicationName)",
                "Close my step in \(.applicationName)",
            ],
            shortTitle: "Close Loop",
            systemImageName: "checkmark.circle"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .saveTheDay),
            phrases: [
                "Make today doable in \(.applicationName)",
                "Open recovery in \(.applicationName)",
            ],
            shortTitle: "Make Doable",
            systemImageName: "arrow.uturn.left.circle"
        )
    }

    static var shortcutTileColor: ShortcutTileColor {
        .teal
    }
}
