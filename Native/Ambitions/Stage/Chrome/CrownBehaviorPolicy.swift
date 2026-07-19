import Foundation

enum CrownBehaviorPolicy {
    static func showsContextCrown(routeDepth: StageRouteDepth, overlayPresentation: StageOverlayPresentation) -> Bool {
        routeDepth == .root && overlayPresentation == .none
    }

    static func collapsesForDrilldown(routeDepth: StageRouteDepth) -> Bool {
        routeDepth == .drilldown
    }
}
