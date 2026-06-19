import Foundation
import Observation

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
    var isActivatedCaptureComposerVisible: Bool {
        activeOverlay?.isActivatedCaptureComposer == true
    }

    var stageRouteDepth: StageRouteDepth {
        StagePathStore.routeDepth(
            goalsPath: goalsPath,
            timePath: timePath,
            youPath: youPath
        )
    }

    var stageOverlayPresentation: StageOverlayPresentation {
        StagePathStore.overlayPresentation(for: activeOverlay)
    }

    var isInFocusedDrilldown: Bool {
        stageRouteDepth == .drilldown
    }

    var hasRootNavigationChrome: Bool {
        StagePathStore.rootDockIsVisible(
            routeDepth: stageRouteDepth,
            overlayPresentation: stageOverlayPresentation
        )
    }
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
    }

    func selectTab(_ tab: AppTab) {
        dismissOverlay()
        selectedTab = tab.canonicalTopLevelTab
        if selectedTab != .today {
            todayEntryContext = .standard
        }
    }

    @discardableResult
    func selectRootSurfaceFromDock(_ tab: AppTab, now: Date = .now) -> TopLevelTabReselectionAction? {
        let canonicalTab = tab.canonicalTopLevelTab
        let hadOverlay = activeOverlay != nil
        if hadOverlay {
            dismissOverlay()
        }

        guard selectedTab == canonicalTab else {
            selectTab(canonicalTab)
            return nil
        }

        guard hadOverlay == false else {
            return nil
        }

        return handleCurrentTabReselection(now: now)
    }

    func stageChromePolicy(dynamicTypeIsAccessibilitySize: Bool) -> StageChromePolicy {
        StagePathStore.chromePolicy(
            goalsPath: goalsPath,
            timePath: timePath,
            youPath: youPath,
            activeOverlay: activeOverlay,
            dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize
        )
    }

    func handleCurrentTabReselection(now: Date = .now) -> TopLevelTabReselectionAction {
        let tab = selectedTab

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

    func openCaptureComposer() {
        presentGlobalCaptureComposer(source: .globalCaptureComposer)
    }

    func openCaptureComposer(source: ShellCommandEntrySource) {
        presentGlobalCaptureComposer(source: source)
        timePath = []
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
            destinationLabel: presentationContext == .quickCapture || intent == .quickCapture ? "Capture" : "Add something"
        )
    }

    func presentSurfaceCapture(for tab: AppTab) {
        presentCommandSheet(
            intent: .quickCapture,
            source: AppShellCaptureAccessModel.source(for: tab),
            presentationContext: .quickCapture
        )
    }

    func presentGlobalCaptureComposer(source: ShellCommandEntrySource) {
        presentCommandSheet(
            intent: .quickCapture,
            source: source,
            presentationContext: .quickCapture
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
            title: intent?.title ?? "Search Ambitions",
            subtitle: query.isEmpty ? presentationContext.historySubtitle : "Looked up \"\(query)\".",
            source: source,
            presentationContext: presentationContext,
            destinationLabel: "Search Ambitions"
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
        switch tab {
        case .today:
            todayEntryContext = .standard
        case .goals:
            goalsPath = []
        case .time:
            timePath = []
        case .you:
            youPath = []
        }
    }
}
