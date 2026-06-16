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
        case .quickTimePatch: "Shape Time"
        case .quickRecovery: "Recover"
        case .quickFocus: "Start here"
        case .openGoal: "Open goal"
        case .openWeek: "Open week"
        case .openCapture: "Open capture"
        case .memoryLens: "Search Ambitions"
        }
    }

    var subtitle: String {
        switch self {
        case .quickCapture: "Capture what changed, then decide where it belongs."
        case .newGoal: "Open Goal setup without leaving the native shell path."
        case .quickTimePatch: "Land in Time to reshape the current week."
        case .quickRecovery: "Return to Today with recovery posture in view."
        case .quickFocus: "Return to Today and center the recommended step."
        case .openGoal: "Find and open one goal in its canonical destination."
        case .openWeek: "Open Time as the canonical week surface."
        case .openCapture: "Open Capture."
        case .memoryLens: "Search goals, captures, steps, settings, and recent changes."
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
                safetySummary: "Creates a local capture with context the user can review.",
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
                safetySummary: "Opens a known goal or asks Search for a source-grounded target.",
                fallbackSummary: "If no goal identifier is present, open Search."
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
                sourceOfTruth: "Personal context",
                safetySummary: "Searches source-grounded context without creating durable memory.",
                fallbackSummary: "If query context is empty, open Search in recall mode.",
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
        case .shellCompose: "Quick action"
        case .shellUtility: "Shell"
        case .goalsCreate: "Goals"
        case .todayQuickCapture: "Today"
        case .goalsQuickCapture: "Goals"
        case .timeQuickCapture: "Time"
        case .motionQuickCapture: "Motion"
        case .youQuickCapture: "You"
        case .capturesScreen: "Capture"
        case .deepLink: "Linked route"
        case .appIntent: "Shortcut"
        case .notification: "Notification"
        case .widget: "Widget"
        case .shareExtension: "Share"
        case .external: "External surface"
        }
    }
}


struct AppShellContextualToolbarAction: Hashable, Identifiable, Sendable {
    enum Kind: String, Hashable, Sendable {
        case surfacePrimary
        case captureFallback
        case inspection
    }

    let id: String
    let kind: Kind
    let title: String
    let systemImage: String
    let accessibilityIdentifier: String
    let accessibilityLabel: String
    let accessibilityHint: String
    let requiresConfirmationBeforeDestructiveEffect: Bool

    init(
        id: String,
        kind: Kind,
        title: String,
        systemImage: String,
        accessibilityIdentifier: String,
        accessibilityLabel: String? = nil,
        accessibilityHint: String,
        requiresConfirmationBeforeDestructiveEffect: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.systemImage = systemImage
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel ?? title
        self.accessibilityHint = accessibilityHint
        self.requiresConfirmationBeforeDestructiveEffect = requiresConfirmationBeforeDestructiveEffect
    }
}

enum AppShellContextualToolbarCatalog {
    static let maxOneViewportActions = 2

    static func actions(for tab: AppTab) -> [AppShellContextualToolbarAction] {
        let canonicalTab = tab.canonicalTopLevelTab
        return [primaryAction(for: canonicalTab), captureAction(for: canonicalTab)]
    }

    static func shouldCompressActions(dynamicTypeIsAccessibilitySize: Bool, actionCount: Int) -> Bool {
        dynamicTypeIsAccessibilitySize && actionCount > 1
    }

    static var canonicalSurfaceCoverage: [String] {
        AppTab.allCases.map(\.title)
    }

    private static func primaryAction(for tab: AppTab) -> AppShellContextualToolbarAction {
        switch tab.canonicalTopLevelTab {
        case .today:
            return AppShellContextualToolbarAction(
                id: "today-start-here",
                kind: .surfacePrimary,
                title: "Start here",
                systemImage: "bolt.fill",
                accessibilityIdentifier: "shell.today.start-here-button",
                accessibilityHint: "Returns Today to the Start here execution object."
            )
        case .goals:
            return AppShellContextualToolbarAction(
                id: "goals-create-goal",
                kind: .surfacePrimary,
                title: "Create goal",
                systemImage: "plus",
                accessibilityIdentifier: "shell.goals.create-goal-button",
                accessibilityHint: "Opens goal creation from Goals."
            )
        case .time:
            return AppShellContextualToolbarAction(
                id: "time-weekly-review",
                kind: .surfacePrimary,
                title: "Review week",
                systemImage: "calendar.badge.clock",
                accessibilityIdentifier: "shell.time.weekly-review-button",
                accessibilityHint: "Opens the Time-owned weekly review surface."
            )
        case .motion:
            return AppShellContextualToolbarAction(
                id: "motion-memory-lens",
                kind: .inspection,
                title: "Inspect proof",
                systemImage: "checkmark.seal",
                accessibilityIdentifier: "shell.motion.inspect-proof-button",
                accessibilityHint: "Opens the proof and search without changing plans."
            )
        case .you:
            return AppShellContextualToolbarAction(
                id: "you-history",
                kind: .inspection,
                title: "History",
                systemImage: "clock.arrow.circlepath",
                accessibilityIdentifier: "shell.you.history-button",
                accessibilityHint: "Opens the You-owned history surface."
            )
        }
    }

    private static func captureAction(for tab: AppTab) -> AppShellContextualToolbarAction {
        AppShellContextualToolbarAction(
            id: "\(tab.canonicalTopLevelTab.rawValue)-capture",
            kind: .captureFallback,
            title: AppShellCaptureAccessModel.toolbarTitle,
            systemImage: "square.and.pencil",
            accessibilityIdentifier: AppShellCaptureAccessModel.toolbarAccessibilityIdentifier(for: tab),
            accessibilityLabel: AppShellCaptureAccessModel.toolbarAccessibilityLabel,
            accessibilityHint: AppShellCaptureAccessModel.toolbarAccessibilityHint
        )
    }
}

enum AppShellCaptureAccessModel {
    static let toolbarTitle = "Capture"
    static let systemImage = "square.and.pencil"
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

enum ShellTrustedSearchHandoffOwner: String, Hashable, Sendable {
    case today
    case goals
    case time
    case motion
    case you
    case globalCapture

    var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .time: "Time"
        case .motion: "Motion"
        case .you: "You"
        case .globalCapture: "Global Capture"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .globalCapture:
            "Global Capture handoff"
        default:
            "\(title) handoff"
        }
    }
}

struct ShellTrustedSearchHandoff: Hashable, Identifiable, Sendable {
    let id: String
    let resultID: String
    let resultTitle: String
    let source: ShellCommandEntrySource
    let destination: ShellCommandDestination
    let owner: ShellTrustedSearchHandoffOwner
    let sourceEvidenceTitle: String
    let trustSummary: String
    let staleDestinationBlockers: [String]

    init(
        resultID: String,
        resultTitle: String,
        source: ShellCommandEntrySource,
        destination: ShellCommandDestination,
        owner: ShellTrustedSearchHandoffOwner,
        sourceEvidenceTitle: String,
        trustSummary: String,
        staleDestinationBlockers: [String]
    ) {
        self.id = [resultID, source.rawValue, destination.displayLabel, owner.rawValue].joined(separator: "|")
        self.resultID = resultID
        self.resultTitle = resultTitle
        self.source = source
        self.destination = destination
        self.owner = owner
        self.sourceEvidenceTitle = sourceEvidenceTitle
        self.trustSummary = trustSummary
        self.staleDestinationBlockers = staleDestinationBlockers
    }

    var isTrusted: Bool { staleDestinationBlockers.isEmpty }

    var body: String {
        guard isTrusted else {
            return "Search result was held because the destination is not an active Ambitions surface."
        }
        return "Opened \(resultTitle) from Search Ambitions into \(owner.title). \(sourceEvidenceTitle); \(trustSummary)."
    }
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
            case .quietCommandSheet: "Quick action Sheet"
            case .memoryLens: "Search Ambitions"
            case .createGoal: "Create Goal"
            }
        }
    }

    var trustedSearchHandoffOwner: ShellTrustedSearchHandoffOwner {
        switch self {
        case let .tab(tab):
            switch tab.canonicalTopLevelTab {
            case .today: .today
            case .goals: .goals
            case .time: .time
            case .motion: .motion
            case .you: .you
            }
        case .goal:
            .goals
        case let .timeRoute(target):
            target == .captureInbox ? .globalCapture : .time
        case .youRoute:
            .you
        case let .overlay(overlay):
            overlay.isActivatedCaptureComposer ? .globalCapture : .today
        }
    }

    var staleIADestinationBlockers: [String] {
        var blockers: [String] = []
        if case let .tab(tab) = self, tab.isCanonicalTopLevel == false {
            blockers.append("Non-canonical tab \(tab.rawValue)")
        }

        let exactStaleRootLabels: Set<String> = ["plan", "pulse", "profile", "calendar", "inbox"]
        let normalizedLabel = displayLabel.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if exactStaleRootLabels.contains(normalizedLabel) {
            blockers.append("Stale IA destination \(displayLabel)")
        }
        return blockers
    }
}

extension MemoryLensResult {
    var trustedSearchHandoffOwner: ShellTrustedSearchHandoffOwner {
        destination.trustedSearchHandoffOwner
    }

    var staleIADestinationBlockers: [String] {
        destination.staleIADestinationBlockers
    }

    func trustedSearchHandoff(source: ShellCommandEntrySource) -> ShellTrustedSearchHandoff {
        ShellTrustedSearchHandoff(
            resultID: id,
            resultTitle: title,
            source: source,
            destination: destination,
            owner: trustedSearchHandoffOwner,
            sourceEvidenceTitle: sourceEvidence.title,
            trustSummary: contextRetrievalSummary,
            staleDestinationBlockers: staleIADestinationBlockers
        )
    }
}
