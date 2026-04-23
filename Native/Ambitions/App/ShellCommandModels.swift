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
    case quickPlanPatch = "quick_plan_patch"
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
        case .quickPlanPatch: "Patch plan"
        case .quickRecovery: "Recover"
        case .quickFocus: "Focus"
        case .openGoal: "Open goal"
        case .openWeek: "Open week"
        case .openCapture: "Open capture"
        case .memoryLens: "Memory Lens"
        }
    }

    var subtitle: String {
        switch self {
        case .quickCapture: "Save an idea into the canonical captures inbox."
        case .newGoal: "Open the existing create-goal flow inside the shell-owned compose path."
        case .quickPlanPatch: "Land in Plan to reshape the current week."
        case .quickRecovery: "Return to Today with recovery posture in view."
        case .quickFocus: "Return to Today and center the next move."
        case .openGoal: "Find and open one goal in its canonical destination."
        case .openWeek: "Open Plan as the canonical week surface."
        case .openCapture: "Open Plan-owned captures."
        case .memoryLens: "Search goals, captures, and recent changes."
        }
    }

    var systemImage: String {
        switch self {
        case .quickCapture: "square.and.pencil"
        case .newGoal: "plus"
        case .quickPlanPatch: "calendar.badge.clock"
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
        case .quickCapture, .quickPlanPatch, .quickRecovery, .quickFocus:
            return .quietCommandSheet
        }
    }
}

enum ShellCommandEntrySource: String, Hashable, Sendable, Codable {
    case shellCompose
    case shellUtility
    case goalsCreate
    case todayQuickCapture
    case capturesScreen
    case deepLink
    case appIntent
    case notification
    case widget
    case external
}

enum ShellCommandPresentationContext: String, Hashable, Sendable, Codable {
    case neutral
    case quickCapture
    case createGoal
    case recall
    case recovery
    case focus
    case plan
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

enum ShellCommandDestination: Hashable, Sendable {
    case tab(AppTab)
    case goal(String)
    case planRoute(PlanRouteTarget)
    case insightsRoute(InsightsRouteTarget)
    case overlay(ShellOverlayState)
}
