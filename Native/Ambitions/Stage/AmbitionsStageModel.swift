import Foundation

struct AmbitionsStageModel: Equatable {
    let scene: StageScene
    let chromePolicy: StageChromePolicy

    var selectedSurface: AmbitionsSurface {
        scene.surface
    }

    var primaryObject: StageObject {
        scene.primaryObject
    }

    static func current(state: StageState, dynamicTypeIsAccessibilitySize: Bool) -> AmbitionsStageModel {
        let scene = StageScene.current(state: state)
        return AmbitionsStageModel(
            scene: scene,
            chromePolicy: StagePathStore.chromePolicy(
                routeDepth: scene.routeDepth,
                overlayPresentation: scene.overlay.presentation,
                dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize
            )
        )
    }
}
