import Foundation

enum ShellOverlayKind: String, Hashable, Identifiable, Sendable, Codable {
    case quietCommandSheet = "quiet-command-sheet"
    case memoryLens = "memory-lens"
    case createGoal = "create-goal"

    var id: String { rawValue }
}

enum ShellCommandIntent: String, CaseIterable, Hashable, Identifiable, Sendable, Codable {
    case quickCapture = "quick_capture"
    case newGoal = "new_goal"
    case quickTimePatch = "quick_plan_patch"
    case quickRecovery = "quick_recovery"
    case quickFocus = "quick_focus"
    case openGoal = "open_goal"
    case openWeek = "open_week"
    case openCapture = "open_capture"
    case memoryLens = "memory_lens"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quickCapture: "Capture"
        case .newGoal: "New goal"
        case .quickTimePatch: "Patch Time"
        case .quickRecovery: "Recover"
        case .quickFocus: "Focus"
        case .openGoal: "Open goal"
        case .openWeek: "Open week"
        case .openCapture: "Open capture"
        case .memoryLens: "What Ambitions knows"
        }
    }

    var subtitle: String {
        switch self {
        case .quickCapture: "Save what needs a place with a suggested route and a receipt you can change."
        case .newGoal: "Open the existing create-goal flow inside the shell-owned compose path."
        case .quickTimePatch: "Land in Time to reshape the current week."
        case .quickRecovery: "Return to Today with recovery posture in view."
        case .quickFocus: "Return to Today and center the next step."
        case .openGoal: "Find and open one goal in its canonical destination."
        case .openWeek: "Open Time as the canonical week surface."
        case .openCapture: "Open Capture."
        case .memoryLens: "Search goals, captures, and recent changes."
        }
    }

    var systemImage: String {
        switch self {
        case .quickCapture: "square.and.pencil"
        case .newGoal: "plus"
        case .quickTimePatch: "calendar.badge.clock"
        case .quickRecovery: "arrow.uturn.left.circle"
        case .quickFocus: "scope"
        case .openGoal: "target"
        case .openWeek: "calendar"
        case .openCapture: "tray.full"
        case .memoryLens: "magnifyingglass"
        }
    }

    var overlayKind: ShellOverlayKind {
        switch self {
        case .openGoal, .openCapture, .openWeek, .memoryLens:
            return .memoryLens
        case .newGoal:
            return .createGoal
        case .quickCapture, .quickTimePatch, .quickRecovery, .quickFocus:
            return .quietCommandSheet
        }
    }

    var externalBrainCommandContract: ShellExternalBrainCommandContract {
        switch self {
        case .quickCapture:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: .quickCapture,
                destination: .timeRoute(.captureInbox),
                sourceOfTruth: "Capture",
                safetySummary: "Creates a local capture with source context and a receipt.",
                fallbackSummary: "If capture persistence is unavailable, leave the command blocked.",
                touchesUserText: true
            )
        case .newGoal:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: nil,
                destination: .overlay(.createGoal(entrySource: .shellCompose)),
                sourceOfTruth: "Goals",
                safetySummary: "Opens the existing goal setup surface without silently creating a goal.",
                fallbackSummary: "If seeded context is missing, open goal setup empty.",
                touchesUserText: true
            )
        case .quickTimePatch, .openWeek:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: .openDestination,
                destination: .tab(.time),
                sourceOfTruth: "Time",
                safetySummary: "Routes to Time without writing calendar or reshaping the week.",
                fallbackSummary: "If route context is missing, open Time root."
            )
        case .quickRecovery, .quickFocus:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: .openDestination,
                destination: .tab(.today),
                sourceOfTruth: "Today",
                safetySummary: "Routes to Today with posture context only.",
                fallbackSummary: "If posture context is unavailable, open Today normally."
            )
        case .openGoal:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: .openDestination,
                destination: nil,
                sourceOfTruth: "Goals",
                safetySummary: "Opens a known goal or asks Memory Lens for a source-grounded target.",
                fallbackSummary: "If no goal identifier is present, open Memory Lens."
            )
        case .openCapture:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: .openDestination,
                destination: .timeRoute(.captureInbox),
                sourceOfTruth: "Capture",
                safetySummary: "Opens Capture without mutating saved captures.",
                fallbackSummary: "If capture context is missing, open Capture root."
            )
        case .memoryLens:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: nil,
                destination: .overlay(.memoryLens(entrySource: .shellUtility)),
                sourceOfTruth: "Life Memory",
                safetySummary: "Searches source-grounded context without creating durable memory.",
                fallbackSummary: "If query context is empty, open Memory Lens in recall mode.",
                touchesUserText: true
            )
        }
    }
}

struct ShellExternalBrainCommandContract: Hashable, Sendable {
    let intent: ShellCommandIntent
    let commandKind: AmbitionsCommandKind?
    let destination: ShellCommandDestination?
    let sourceOfTruth: String
    let safetySummary: String
    let fallbackSummary: String
    let requiresUserConfirmation: Bool
    let writesCalendar: Bool
    let createsDurableMemory: Bool
    let touchesUserText: Bool

    init(
        intent: ShellCommandIntent,
        commandKind: AmbitionsCommandKind?,
        destination: ShellCommandDestination?,
        sourceOfTruth: String,
        safetySummary: String,
        fallbackSummary: String,
        requiresUserConfirmation: Bool = false,
        writesCalendar: Bool = false,
        createsDurableMemory: Bool = false,
        touchesUserText: Bool = false
    ) {
        self.intent = intent
        self.commandKind = commandKind
        self.destination = destination
        self.sourceOfTruth = sourceOfTruth
        self.safetySummary = safetySummary
        self.fallbackSummary = fallbackSummary
        self.requiresUserConfirmation = requiresUserConfirmation
        self.writesCalendar = writesCalendar
        self.createsDurableMemory = createsDurableMemory
        self.touchesUserText = touchesUserText
    }

    var isSafeForExternalBrainCommandSurface: Bool {
        writesCalendar == false && createsDurableMemory == false
    }
}

enum ShellCommandEntrySource: String, Hashable, Sendable, Codable {
    case shellCompose
    case shellUtility
    case goalsCreate
    case todayQuickCapture
    case goalsQuickCapture
    case timeQuickCapture
    case motionQuickCapture
    case youQuickCapture
    case capturesScreen
    case deepLink
    case appIntent
    case notification
    case widget
    case shareExtension
    case external

    var displayTitle: String {
        switch self {
        case .shellCompose: "Quiet Command"
        case .shellUtility: "Shell"
        case .goalsCreate: "Goals"
        case .todayQuickCapture: "Today"
        case .goalsQuickCapture: "Goals"
        case .timeQuickCapture: "Time"
        case .motionQuickCapture: "Motion"
        case .youQuickCapture: "You"
        case .capturesScreen: "Capture"
        case .deepLink: "Deep link"
        case .appIntent: "Shortcut"
        case .notification: "Notification"
        case .widget: "Widget"
        case .shareExtension: "Share"
        case .external: "External surface"
        }
    }
}

enum AppShellCaptureAccessModel {
    static let toolbarTitle = "Capture"
    static let toolbarAccessibilityLabel = "Capture"
    static let toolbarAccessibilityHint = "Opens the Capture composer for this surface/context."
    static let activatedSeamAccessibilityLabel = "Capture composer"
    static let activatedSeamAccessibilityHint = "Capture is active for this surface/context."

    static func source(for tab: AppTab) -> ShellCommandEntrySource {
        switch tab.canonicalTopLevelTab {
        case .today:
            .todayQuickCapture
        case .goals:
            .goalsQuickCapture
        case .time:
            .timeQuickCapture
        case .motion:
            .motionQuickCapture
        case .you:
            .youQuickCapture
        case .capture:
            .todayQuickCapture
        }
    }

    static func toolbarAccessibilityIdentifier(for tab: AppTab) -> String {
        "shell.\(tab.canonicalTopLevelTab.rawValue).capture-button"
    }
}

enum ShellCommandPresentationContext: String, Hashable, Sendable, Codable {
    case neutral
    case quickCapture
    case createGoal
    case recall
    case recovery
    case focus
    case time
}

struct ShellOverlayState: Hashable, Identifiable, Sendable, Codable {
    let kind: ShellOverlayKind
    let intent: ShellCommandIntent?
    let entrySource: ShellCommandEntrySource
    let presentationContext: ShellCommandPresentationContext
    let query: String
    let goalID: String?
    let captureID: String?

    init(
        kind: ShellOverlayKind,
        intent: ShellCommandIntent? = nil,
        entrySource: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .neutral,
        query: String = "",
        goalID: String? = nil,
        captureID: String? = nil
    ) {
        self.kind = kind
        self.intent = intent
        self.entrySource = entrySource
        self.presentationContext = presentationContext
        self.query = query
        self.goalID = goalID
        self.captureID = captureID
    }

    var id: String {
        [
            kind.rawValue,
            intent?.rawValue ?? "intent:none",
            entrySource.rawValue,
            presentationContext.rawValue,
            query,
            goalID ?? "goal:none",
            captureID ?? "capture:none"
        ].joined(separator: "|")
    }

    var isActivatedCaptureComposer: Bool {
        kind == .quietCommandSheet && (intent == .quickCapture || presentationContext == .quickCapture)
    }

    static func commandSheet(
        intent: ShellCommandIntent? = nil,
        entrySource: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .neutral
    ) -> ShellOverlayState {
        ShellOverlayState(
            kind: .quietCommandSheet,
            intent: intent,
            entrySource: entrySource,
            presentationContext: presentationContext
        )
    }

    static func memoryLens(
        intent: ShellCommandIntent? = .memoryLens,
        entrySource: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .recall,
        query: String = "",
        goalID: String? = nil,
        captureID: String? = nil
    ) -> ShellOverlayState {
        ShellOverlayState(
            kind: .memoryLens,
            intent: intent,
            entrySource: entrySource,
            presentationContext: presentationContext,
            query: query,
            goalID: goalID,
            captureID: captureID
        )
    }

    static func createGoal(
        entrySource: ShellCommandEntrySource,
        query: String = "",
        captureID: String? = nil
    ) -> ShellOverlayState {
        ShellOverlayState(
            kind: .createGoal,
            intent: .newGoal,
            entrySource: entrySource,
            presentationContext: .createGoal,
            query: query,
            captureID: captureID
        )
    }
}

struct ShellCommandHistoryEntry: Hashable, Identifiable, Sendable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let source: ShellCommandEntrySource
    let presentationContext: ShellCommandPresentationContext
    let destinationLabel: String
    let recordedAt: String

    init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext,
        destinationLabel: String,
        recordedAt: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.source = source
        self.presentationContext = presentationContext
        self.destinationLabel = destinationLabel
        self.recordedAt = recordedAt
    }

    var sourceLabel: String { source.displayTitle }
}

struct ShellContinuityReceipt: Hashable, Identifiable, Sendable, Codable {
    let id: String
    let title: String
    let body: String
    let source: ShellCommandEntrySource
    let destinationLabel: String

    init(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        source: ShellCommandEntrySource,
        destinationLabel: String
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.source = source
        self.destinationLabel = destinationLabel
    }

    var sourceLabel: String { source.displayTitle }
}

enum ShellCommandDestination: Hashable, Sendable {
    case tab(AppTab)
    case goal(String)
    case timeRoute(TimeRouteTarget)
    case youRoute(YouRouteTarget)
    case overlay(ShellOverlayState)

    var displayLabel: String {
        switch self {
        case let .tab(tab):
            tab.title
        case .goal:
            "Goal Detail"
        case let .timeRoute(target):
            switch target {
            case .captureInbox: "Capture"
            case .habits: "Rituals"
            case .weeklyReview: "Weekly Review"
            }
        case let .youRoute(target):
            switch target {
            case .monthlyReview: "Monthly Review"
            case .history: "History"
            }
        case let .overlay(overlay):
            switch overlay.kind {
            case .quietCommandSheet: "Quiet Command Sheet"
            case .memoryLens: "What Ambitions knows"
            case .createGoal: "Create Goal"
            }
        }
    }
}
