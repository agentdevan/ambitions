import Foundation

enum StageOverlayPresentation: String, Equatable {
    case none
    case sheet
    case activatedCaptureComposer
    case memoryLens
    case createGoal
}

struct StageOverlay: Equatable {
    let presentation: StageOverlayPresentation
    let activeState: ShellOverlayState?
    let hidesRootDock: Bool
    let restoresFocusAfterDismissal: Bool

    static func current(_ overlay: ShellOverlayState?) -> StageOverlay {
        let presentation = StagePathStore.overlayPresentation(for: overlay)
        return StageOverlay(
            presentation: presentation,
            activeState: overlay,
            hidesRootDock: presentation == .activatedCaptureComposer || presentation == .memoryLens,
            restoresFocusAfterDismissal: presentation != .none
        )
    }
}
