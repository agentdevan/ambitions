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

enum PlanRouteTarget: String, Hashable, Identifiable, Sendable {
    case capturesInbox
    case habits
    case weeklyReview

    var id: String { rawValue }
}

enum InsightsRouteTarget: String, Hashable, Identifiable, Sendable {
    case monthlyReview
    case history

    var id: String { rawValue }
}

@MainActor
@Observable
final class AppNavigationModel {
    var selectedTab: AppTab
    var goalsPath: [GoalRouteTarget]
    var planPath: [PlanRouteTarget]
    var insightsPath: [InsightsRouteTarget]
    var todayEntryContext: TodayEntryContext
    var pendingTodayEntryContext: TodayEntryContext?
    var activeOverlay: ShellOverlayState?
    var lastExternalRoute: AppExternalRoute?
    var lastExternalRouteSource: AppExternalRouteSource?
    var recentCommandHistory: [ShellCommandHistoryEntry]
    var continuityReceipt: ShellContinuityReceipt?

    init(selectedTab: AppTab) {
        self.selectedTab = selectedTab.canonicalTopLevelTab
        goalsPath = []
        planPath = []
        insightsPath = []
        todayEntryContext = .standard
        pendingTodayEntryContext = nil
        activeOverlay = nil
        lastExternalRoute = nil
        lastExternalRouteSource = nil
        recentCommandHistory = []
        continuityReceipt = nil

        switch selectedTab {
        case .habits:
            planPath = [.habits]
        case .insights:
            insightsPath = [.history]
        case .today, .captures, .goals, .plan, .profile:
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

    func openPlanRoute(_ target: PlanRouteTarget) {
        dismissOverlay()
        if target == .capturesInbox {
            selectedTab = .captures
            planPath = []
            return
        }
        selectedTab = .plan
        planPath = [target]
    }

    func resetPlanPath() {
        planPath = []
    }

    func openInsightsRoute(_ target: InsightsRouteTarget) {
        dismissOverlay()
        selectedTab = .profile
        insightsPath = [target]
    }

    func resetInsightsPath() {
        insightsPath = []
    }

    func openCapturesInbox() {
        openPlanRoute(.capturesInbox)
    }

    func openHabits() {
        openPlanRoute(.habits)
    }

    func openWeeklyReview() {
        openPlanRoute(.weeklyReview)
    }

    func openMonthlyReview() {
        openInsightsRoute(.monthlyReview)
    }

    func openHistory() {
        openInsightsRoute(.history)
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
            title: intent?.title ?? "Command",
            subtitle: presentationContext.historySubtitle,
            source: source,
            presentationContext: presentationContext,
            destinationLabel: "Command"
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
            title: intent?.title ?? "Memory Lens",
            subtitle: query.isEmpty ? presentationContext.historySubtitle : "Recalled \"\(query)\".",
            source: source,
            presentationContext: presentationContext,
            destinationLabel: "Memory Lens"
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
            subtitle: seedText.isEmpty ? "Opened Strategy Composer from \(source.displayTitle)." : "Started from saved context.",
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
}

private extension ShellCommandPresentationContext {
    var historySubtitle: String {
        switch self {
        case .neutral: "Opened from the shared shell command surface."
        case .quickCapture: "Captured without leaving the shared command language."
        case .createGoal: "Started from the shell-owned goal creation path."
        case .recall: "Recalled context without opening a raw history log."
        case .recovery: "Returned to a calmer recovery posture."
        case .focus: "Returned to the current focus posture."
        case .plan: "Opened the week-shaping context."
        }
    }
}
