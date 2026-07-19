import Foundation

enum NativeChromePolicy {
    static func preservesPlatformBack(routeDepth: StageRouteDepth) -> Bool {
        routeDepth == .drilldown
    }

    static func presentsOverlayAsSheet(_ overlay: StageOverlayPresentation) -> Bool {
        switch overlay {
        case .sheet, .memoryLens, .createGoal:
            true
        case .none, .activatedCaptureComposer:
            false
        }
    }
}
