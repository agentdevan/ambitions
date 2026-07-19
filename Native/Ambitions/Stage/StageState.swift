import Foundation

struct StageState {
    var selectedSurface: AmbitionsSurface
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
    var lastReselectedSurface: AmbitionsSurface?
    var lastSurfaceReselectionDate: Date?

    init(selectedSurface: AmbitionsSurface) {
        self.selectedSurface = selectedSurface.canonicalTopLevelTab
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
        lastReselectedSurface = nil
        lastSurfaceReselectionDate = nil
    }
}
