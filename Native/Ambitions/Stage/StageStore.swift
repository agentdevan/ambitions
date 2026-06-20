import Foundation
import Observation

@MainActor
@Observable
final class StageStore {
    private var state: StageState
    private let effectRunner = StageEffectRunner()
    private(set) var lastEffects: [StageEffect]
    private(set) var lastEffectRun: StageEffectRun

    init(selectedSurface: AmbitionsSurface) {
        state = StageState(selectedSurface: selectedSurface)
        lastEffects = []
        lastEffectRun = StageEffectRun(
            effects: [],
            visibleMutationIDs: [],
            accessibilityAnnouncements: [],
            proofArtifactIDs: []
        )
    }

    var selectedTab: AmbitionsSurface {
        get { state.selectedSurface }
        set { state.selectedSurface = newValue.canonicalTopLevelTab }
    }

    var selectedSurface: AmbitionsSurface {
        get { state.selectedSurface }
        set { state.selectedSurface = newValue.canonicalTopLevelTab }
    }

    var goalsPath: [GoalRouteTarget] {
        get { state.goalsPath }
        set { state.goalsPath = newValue }
    }

    var timePath: [TimeRouteTarget] {
        get { state.timePath }
        set { state.timePath = newValue }
    }

    var youPath: [YouRouteTarget] {
        get { state.youPath }
        set { state.youPath = newValue }
    }

    var todayEntryContext: TodayEntryContext {
        get { state.todayEntryContext }
        set { state.todayEntryContext = newValue }
    }

    var pendingTodayEntryContext: TodayEntryContext? {
        get { state.pendingTodayEntryContext }
        set { state.pendingTodayEntryContext = newValue }
    }

    var activeOverlay: ShellOverlayState? {
        get { state.activeOverlay }
        set { state.activeOverlay = newValue }
    }

    var lastExternalRoute: AppExternalRoute? {
        get { state.lastExternalRoute }
        set { state.lastExternalRoute = newValue }
    }

    var lastExternalRouteSource: AppExternalRouteSource? {
        get { state.lastExternalRouteSource }
        set { state.lastExternalRouteSource = newValue }
    }

    var recentCommandHistory: [ShellCommandHistoryEntry] {
        get { state.recentCommandHistory }
        set { state.recentCommandHistory = newValue }
    }

    var continuityReceipt: ShellContinuityReceipt? {
        get { state.continuityReceipt }
        set { state.continuityReceipt = newValue }
    }

    var isActivatedCaptureComposerVisible: Bool {
        state.activeOverlay?.isActivatedCaptureComposer == true
    }

    var stageRouteDepth: StageRouteDepth {
        StagePathStore.routeDepth(
            goalsPath: state.goalsPath,
            timePath: state.timePath,
            youPath: state.youPath
        )
    }

    var stageOverlayPresentation: StageOverlayPresentation {
        StagePathStore.overlayPresentation(for: state.activeOverlay)
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

    @discardableResult
    func dispatch(_ action: StageAction) -> StageReduction {
        let reduction = StageReducer.reduce(action, state: &state)
        let effectRun = effectRunner.run(reduction.effects)
        lastEffectRun = effectRun
        lastEffects = effectRun.effects
        return reduction
    }

    func stageModel(dynamicTypeIsAccessibilitySize: Bool) -> AmbitionsStageModel {
        AmbitionsStageModel.current(
            state: state,
            dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize
        )
    }

    func selectTab(_ tab: AmbitionsSurface) {
        dispatch(.selectSurface(tab))
    }

    @discardableResult
    func selectRootSurfaceFromDock(
        _ surface: AmbitionsSurface,
        now: Date = .now
    ) -> StageSurfaceReselectionAction? {
        dispatch(.selectRootSurfaceFromDock(surface, now: now)).reselectionAction
    }

    func stageChromePolicy(dynamicTypeIsAccessibilitySize: Bool) -> StageChromePolicy {
        StagePathStore.chromePolicy(
            goalsPath: state.goalsPath,
            timePath: state.timePath,
            youPath: state.youPath,
            activeOverlay: state.activeOverlay,
            dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize
        )
    }

    func handleCurrentTabReselection(now: Date = .now) -> StageSurfaceReselectionAction {
        dispatch(.handleCurrentSurfaceReselection(now: now)).reselectionAction ?? .scrollToTop
    }

    func selectToday(entryContext: TodayEntryContext = .standard) {
        dispatch(.selectToday(entryContext))
    }

    func openGoalDetail(_ target: GoalRouteTarget) {
        dispatch(.openGoalDetail(target))
    }

    func openGoalDetail(
        goalID: String? = nil,
        draftID: String? = nil,
        launchContext: GoalDetailLaunchContext = .standard
    ) {
        openGoalDetail(GoalRouteTarget(goalID: goalID, draftID: draftID, launchContext: launchContext))
    }

    func resetGoalsPath() {
        dispatch(.resetGoalsPath)
    }

    func openTimeRoute(_ target: TimeRouteTarget) {
        dispatch(.openTimeRoute(target))
    }

    func resetTimePath() {
        dispatch(.resetTimePath)
    }

    func openYouRoute(_ target: YouRouteTarget) {
        dispatch(.openYouRoute(target))
    }

    func resetYouPath() {
        dispatch(.resetYouPath)
    }

    func openCaptureComposer() {
        presentGlobalCaptureComposer(source: .globalCaptureComposer)
    }

    func openCaptureComposer(source: ShellCommandEntrySource) {
        presentGlobalCaptureComposer(source: source)
        state.timePath = []
    }

    func openRituals() {
        openTimeRoute(.rituals)
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
        dispatch(.presentOverlay(route))
    }

    func presentCommandSheet(
        intent: ShellCommandIntent? = nil,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .neutral
    ) {
        dispatch(.presentCommandSheet(intent: intent, source: source, presentationContext: presentationContext))
    }

    func presentSurfaceCapture(for surface: AmbitionsSurface) {
        presentCommandSheet(
            intent: .quickCapture,
            source: AppShellCaptureAccessModel.source(for: surface),
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
        dispatch(
            .presentMemoryLens(
                intent: intent,
                source: source,
                presentationContext: presentationContext,
                query: query,
                goalID: goalID,
                captureID: captureID
            )
        )
    }

    func presentCreateGoal(
        source: ShellCommandEntrySource,
        seedText: String = "",
        captureID: String? = nil
    ) {
        dispatch(.presentCreateGoal(source: source, seedText: seedText, captureID: captureID))
    }

    func queueTodaySelectionAfterOverlayDismiss(entryContext: TodayEntryContext) {
        dispatch(.queueTodaySelectionAfterOverlayDismiss(entryContext))
    }

    func takePendingTodayEntryContext() -> TodayEntryContext? {
        dispatch(.consumePendingTodayEntryContext).consumedPendingTodayEntryContext
    }

    func dismissOverlay() {
        dispatch(.dismissOverlay)
    }

    func recordRoute(
        title: String,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext,
        destination: ShellCommandDestination,
        receiptBody: String? = nil
    ) {
        dispatch(
            .recordRoute(
                title: title,
                source: source,
                presentationContext: presentationContext,
                destination: destination,
                receiptBody: receiptBody
            )
        )
    }

    func noteExternalRoute(_ route: AppExternalRoute, source: AppExternalRouteSource) {
        dispatch(.noteExternalRoute(route, source))
    }

    func takeContinuityReceipt() -> ShellContinuityReceipt? {
        dispatch(.clearContinuityReceipt).consumedContinuityReceipt
    }

    func fallbackExternalLanding() {
        dispatch(.fallbackExternalLanding)
    }

    func takeTodayEntryContext() -> TodayEntryContext {
        dispatch(.consumeTodayEntryContext).consumedTodayEntryContext ?? .standard
    }
}
