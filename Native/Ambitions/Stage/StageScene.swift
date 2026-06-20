import Foundation

struct StageScene: Equatable {
    let surface: AmbitionsSurface
    let routeDepth: StageRouteDepth
    let overlay: StageOverlay
    let primaryObject: StageObject

    var rootDockIsAllowed: Bool {
        DockBehaviorPolicy.showsRootDock(
            routeDepth: routeDepth,
            overlayPresentation: overlay.presentation
        )
    }

    static func current(state: StageState) -> StageScene {
        let routeDepth = StagePathStore.routeDepth(
            goalsPath: state.goalsPath,
            timePath: state.timePath,
            youPath: state.youPath
        )
        return StageScene(
            surface: state.selectedSurface,
            routeDepth: routeDepth,
            overlay: StageOverlay.current(state.activeOverlay),
            primaryObject: StageObject.primary(for: state.selectedSurface)
        )
    }
}
