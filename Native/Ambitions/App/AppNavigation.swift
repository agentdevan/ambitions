import Foundation
import Observation

enum GoalDetailLaunchContext: String, Hashable, Sendable {
    case standard
    case help
}

struct GoalRouteTarget: Hashable, Identifiable, Sendable {
    let goalID: String?
    let draftID: String?
    let launchContext: GoalDetailLaunchContext

    init(goalID: String? = nil, draftID: String? = nil, launchContext: GoalDetailLaunchContext = .standard) {
        self.goalID = goalID
        self.draftID = draftID
        self.launchContext = launchContext
    }

    var id: String {
        "\(goalID ?? "goal:none")|\(draftID ?? "draft:none")|\(launchContext.rawValue)"
    }

    var canonicalGoalID: String? { goalID }

    var hasAddressableContent: Bool { goalID != nil || draftID != nil }
}

enum TimeRouteTarget: String, Hashable, Identifiable, Sendable {
    case captureInbox
    case habits
    case weeklyReview

    var id: String { rawValue }
}

enum YouRouteTarget: String, Hashable, Identifiable, Sendable {
    case monthlyReview
    case history

    var id: String { rawValue }
}

enum TopLevelTabReselectionAction: Equatable, Sendable {
    case scrollToTop
    case returnToRoot
}

@MainActor
@Observable
final class AppNavigationModel {
    private static let tabReselectionRootThreshold: TimeInterval = 0.8

    var selectedTab: AppTab
    var goalsPath: [GoalRouteTarget]
    var timePath: [TimeRouteTarget]
    var youPath: [YouRouteTarget]
    var todayEntryContext: TodayEntryContext
    var pendingTodayEntryContext: TodayEntryContext?
    var activeOverlay: ShellOverlayState?
    var lastExternalRoute: AppExternalRoute?
    var lastExternalRouteSource: AppExternalRouteSource?
    var recentCommandHistory: [ShellCommandHistoryEntry]
    var continuityReceipt: ShellContinuityReceipt?
    private var lastReselectedTopLevelTab: AppTab?
    private var lastTopLevelTabReselectionDate: Date?

    init(selectedTab: AppTab) {
        self.selectedTab = selectedTab.canonicalTopLevelTab
        goalsPath = []
        timePath = []
        youPath = []
        todayEntryContext = .standard
        pendingTodayEntryContext = nil
        activeOverlay = nil
        lastExternalRoute = nil
        lastExternalRouteSource = nil
        recentCommandHistory = []
        continuityReceipt = nil
        lastReselectedTopLevelTab = nil
        lastTopLevelTabReselectionDate = nil

        switch selectedTab {
        case .habits:
            timePath = [.habits]
        case .insights:
            youPath = [.history]
        case .today, .capture, .goals, .time, .you:
            break
        }
    }

    func selectTab(_ tab: AppTab) {
        dismissOverlay()
        selectedTab = tab.canonicalTopLevelTab
        if selectedTab != .today {
            todayEntryContext = .standard
        }
        if tab == .habits {
            openHabits()
        } else if tab == .insights {
            openHistory()
        }
    }

    func handleCurrentTabReselection(now: Date = .now) -> TopLevelTabReselectionAction {
        let tab = selectedTab.canonicalTopLevelTab

        guard
            lastReselectedTopLevelTab == tab,
            let previousDate = lastTopLevelTabReselectionDate,
            now.timeIntervalSince(previousDate) <= Self.tabReselectionRootThreshold
        else {
            lastReselectedTopLevelTab = tab
            lastTopLevelTabReselectionDate = now
            return .scrollToTop
        }

        resetRoot(for: tab)
        lastReselectedTopLevelTab = nil
        lastTopLevelTabReselectionDate = nil
        return .returnToRoot
    }

    func selectToday(entryContext: TodayEntryContext = .standard) {
        dismissOverlay()
        selectedTab = .today
        todayEntryContext = entryContext
    }

    func openGoalDetail(_ target: GoalRouteTarget) {
        guard target.hasAddressableContent else { return }
        dismissOverlay()
        selectedTab = .goals
        goalsPath = [target]
    }

    func openGoalDetail(
        goalID: String? = nil,
        draftID: String? = nil,
        launchContext: GoalDetailLaunchContext = .standard
    ) {
        openGoalDetail(GoalRouteTarget(goalID: goalID, draftID: draftID, launchContext: launchContext))
    }

    func resetGoalsPath() {
        goalsPath = []
    }

    func openTimeRoute(_ target: TimeRouteTarget) {
        dismissOverlay()
        if target == .captureInbox {
            selectedTab = .capture
            timePath = []
            return
        }
        selectedTab = .time
        timePath = [target]
    }

    func resetTimePath() {
        timePath = []
    }

    func openYouRoute(_ target: YouRouteTarget) {
        dismissOverlay()
        selectedTab = .you
        youPath = [target]
    }

    func resetYouPath() {
        youPath = []
    }

    func openCapturesInbox() {
        openTimeRoute(.captureInbox)
    }

    func openHabits() {
        openTimeRoute(.habits)
    }

    func openWeeklyReview() {
        openTimeRoute(.weeklyReview)
    }

    func openMonthlyReview() {
        openYouRoute(.monthlyReview)
    }

    func openHistory() {
        openYouRoute(.history)
    }

    func presentOverlay(_ route: ShellOverlayState) {
        activeOverlay = route
        recordCommandHistory(
            title: route.intent?.title ?? route.kind.id.replacingOccurrences(of: "-", with: " ").capitalized,
            subtitle: route.presentationContext.historySubtitle,
            source: route.entrySource,
            presentationContext: route.presentationContext,
            destinationLabel: ShellCommandDestination.overlay(route).displayLabel
        )
    }

    func presentCommandSheet(
        intent: ShellCommandIntent? = nil,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .neutral
    ) {
        activeOverlay = .commandSheet(
            intent: intent,
            entrySource: source,
            presentationContext: presentationContext
        )
        recordCommandHistory(
            title: intent?.title ?? "Add something",
            subtitle: presentationContext.historySubtitle,
            source: source,
            presentationContext: presentationContext,
            destinationLabel: "Add something"
        )
    }

    func presentMemoryLens(
        intent: ShellCommandIntent? = .memoryLens,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .recall,
        query: String = "",
        goalID: String? = nil,
        captureID: String? = nil
    ) {
        activeOverlay = .memoryLens(
            intent: intent,
            entrySource: source,
            presentationContext: presentationContext,
            query: query,
            goalID: goalID,
            captureID: captureID
        )
        recordCommandHistory(
            title: intent?.title ?? "What Ambitions knows",
            subtitle: query.isEmpty ? presentationContext.historySubtitle : "Looked up \"\(query)\".",
            source: source,
            presentationContext: presentationContext,
            destinationLabel: "What Ambitions knows"
        )
    }

    func presentCreateGoal(
        source: ShellCommandEntrySource,
        seedText: String = "",
        captureID: String? = nil
    ) {
        activeOverlay = .createGoal(
            entrySource: source,
            query: seedText,
            captureID: captureID
        )
        recordCommandHistory(
            title: "New goal",
            subtitle: seedText.isEmpty ? "Opened goal setup from \(source.displayTitle)." : "Started from saved context.",
            source: source,
            presentationContext: .createGoal,
            destinationLabel: "Create Goal"
        )
    }

    func queueTodaySelectionAfterOverlayDismiss(entryContext: TodayEntryContext) {
        pendingTodayEntryContext = entryContext
    }

    func takePendingTodayEntryContext() -> TodayEntryContext? {
        let context = pendingTodayEntryContext
        pendingTodayEntryContext = nil
        return context
    }

    func dismissOverlay() {
        activeOverlay = nil
    }

    func recordRoute(
        title: String,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext,
        destination: ShellCommandDestination,
        receiptBody: String? = nil
    ) {
        recordCommandHistory(
            title: title,
            subtitle: presentationContext.historySubtitle,
            source: source,
            presentationContext: presentationContext,
            destinationLabel: destination.displayLabel
        )
        if let receiptBody {
            continuityReceipt = ShellContinuityReceipt(
                title: "Context carried",
                body: receiptBody,
                source: source,
                destinationLabel: destination.displayLabel
            )
        }
    }

    func takeContinuityReceipt() -> ShellContinuityReceipt? {
        let receipt = continuityReceipt
        continuityReceipt = nil
        return receipt
    }

    func fallbackExternalLanding() {
        dismissOverlay()
        selectToday()
    }

    func takeTodayEntryContext() -> TodayEntryContext {
        let context = todayEntryContext
        todayEntryContext = .standard
        return context
    }

    private func recordCommandHistory(
        title: String,
        subtitle: String,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext,
        destinationLabel: String
    ) {
        let entry = ShellCommandHistoryEntry(
            title: title,
            subtitle: subtitle,
            source: source,
            presentationContext: presentationContext,
            destinationLabel: destinationLabel,
            recordedAt: ISO8601DateFormatter().string(from: Date())
        )
        recentCommandHistory.removeAll { $0.title == entry.title && $0.source == entry.source && $0.destinationLabel == entry.destinationLabel }
        recentCommandHistory.insert(entry, at: 0)
        recentCommandHistory = Array(recentCommandHistory.prefix(4))
    }

    private func resetRoot(for tab: AppTab) {
        switch tab.canonicalTopLevelTab {
        case .today:
            todayEntryContext = .standard
        case .goals:
            goalsPath = []
        case .capture:
            break
        case .time:
            timePath = []
        case .you:
            youPath = []
        case .habits, .insights:
            break
        }
    }
}

private extension ShellCommandPresentationContext {
    var historySubtitle: String {
        switch self {
        case .neutral: "Opened from Add something."
        case .quickCapture: "Saved without leaving the global quick action surface."
        case .createGoal: "Started from the goal setup path."
        case .recall: "Opened what Ambitions knows without showing raw history."
        case .recovery: "Returned to a calmer recovery posture."
        case .focus: "Returned to the current step session posture."
        case .plan: "Opened the week-shaping context."
        }
    }
}
