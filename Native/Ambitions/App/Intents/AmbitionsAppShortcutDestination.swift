import AmbitionsExternalContracts
import AppIntents
import Foundation

enum AmbitionsAppShortcutDestination: String, CaseIterable, AppEnum {
    case today
    case goals
    case time = "time"
    case capture
    case you
    case command
    case memoryLens = "memory_lens"
    case quickCapture = "quick_capture"
    case startNextStep = "start_next_step"
    case markDone = "mark_done"
    case saveTheDay = "save_the_day"
    case quickRecovery = "quick_recovery"
    case quickFocus = "quick_focus"
    case quickTimePatch = "quick_time_patch"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Destination"
    static let typeDisplayName: LocalizedStringResource = "Destination"

    static var caseDisplayRepresentations: [AmbitionsAppShortcutDestination: DisplayRepresentation] {
        [
            .today: DisplayRepresentation(title: "Today"),
            .goals: DisplayRepresentation(title: "Goals"),
            .time: DisplayRepresentation(title: "Time"),
            .capture: DisplayRepresentation(title: "Capture"),
            .you: DisplayRepresentation(title: "You"),
            .command: DisplayRepresentation(title: "Add something"),
            .memoryLens: DisplayRepresentation(title: "What Ambitions Knows"),
            .quickCapture: DisplayRepresentation(title: "Capture"),
            .startNextStep: DisplayRepresentation(title: "Start here"),
            .markDone: DisplayRepresentation(title: "Close the loop"),
            .saveTheDay: DisplayRepresentation(title: "Make today doable"),
            .quickRecovery: DisplayRepresentation(title: "Make today doable"),
            .quickFocus: DisplayRepresentation(title: "Start now"),
            .quickTimePatch: DisplayRepresentation(title: "Shape Time")
        ]
    }

    var appRoute: AppExternalRoute {
        switch self {
        case .today:
            return .openTab(.today)
        case .goals:
            return .openTab(.goals)
        case .time:
            return .openTab(.time)
        case .capture:
            return .openCaptureComposer
        case .you:
            return .openTab(.you)
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
        case .quickTimePatch:
            return .openTab(.time)
        }
    }

    var displayTitle: String {
        switch self {
        case .today:
            return "Today"
        case .goals:
            return "Goals"
        case .time:
            return "Time"
        case .capture:
            return "Capture"
        case .you:
            return "You"
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
        case .quickTimePatch:
            return "Shape Time"
        }
    }

    var routeURL: URL? {
        d25CommandDescriptor.routeURL
    }

    var isPFC18PublicLaunchCandidate: Bool {
        switch self {
        case .today, .goals, .time, .capture, .you, .command, .memoryLens, .startNextStep, .markDone, .saveTheDay:
            return true
        case .quickCapture, .quickRecovery, .quickFocus, .quickTimePatch:
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
        case .goals:
            return descriptor(
                title: "Goals",
                dialog: "Opening Goals in Ambitions.",
                commandKind: .openDestination,
                actionName: .open,
                routeURL: routeURL
            )
        case .time, .quickTimePatch:
            return descriptor(
                title: displayTitle,
                dialog: "Opening Time in Ambitions.",
                commandKind: .openDestination,
                actionName: .open,
                routeURL: routeURL
            )
        case .capture:
            return descriptor(
                title: "Capture",
                dialog: "Opening Capture in Ambitions.",
                commandKind: .openDestination,
                actionName: .openCaptureComposer,
                routeURL: routeURL
            )
        case .you:
            return descriptor(
                title: "You",
                dialog: "Opening You in Ambitions.",
                commandKind: .openDestination,
                actionName: .open,
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
                actionName: .openCaptureComposer,
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
