import Foundation

enum StageAction {
    case selectSurface(AmbitionsSurface)
    case selectToday(TodayEntryContext)
    case selectRootSurfaceFromDock(AmbitionsSurface, now: Date)
    case handleCurrentSurfaceReselection(now: Date)
    case openGoalDetail(GoalRouteTarget)
    case popFocusedRoute
    case resetGoalsPath
    case openTimeRoute(TimeRouteTarget)
    case resetTimePath
    case openYouRoute(YouRouteTarget)
    case resetYouPath
    case presentOverlay(ShellOverlayState)
    case presentCommandSheet(
        intent: ShellCommandIntent?,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext
    )
    case presentMemoryLens(
        intent: ShellCommandIntent?,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext,
        query: String,
        goalID: String?,
        captureID: String?
    )
    case presentCreateGoal(source: ShellCommandEntrySource, seedText: String, captureID: String?)
    case queueTodaySelectionAfterOverlayDismiss(TodayEntryContext)
    case dismissOverlay
    case recordRoute(
        title: String,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext,
        destination: ShellCommandDestination,
        receiptBody: String?
    )
    case fallbackExternalLanding
    case noteExternalRoute(AppExternalRoute, AppExternalRouteSource)
    case clearContinuityReceipt
    case consumeTodayEntryContext
    case consumePendingTodayEntryContext
}
