import Foundation
import SwiftUI

struct StageMotionCurrentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let projection: MotionCurrentProjection
    private let onAction: (MotionCurrentAction) -> Void

    init(
        projection: MotionCurrentProjection,
        onAction: @escaping (MotionCurrentAction) -> Void
    ) {
        self.projection = projection
        self.onAction = onAction
    }

    #if DEBUG
        init(
            renderState: MotionCurrentRenderState = .launchArgument,
            onAction: @escaping (MotionCurrentAction) -> Void
        ) {
            self.init(projection: .debugFixture(renderState: renderState), onAction: onAction)
        }
    #endif

    var body: some View {
        let objectStageContract = MotionObjectStagePrimitiveContract.current
        let layer = StageMotionLayer.current(
            projection: projection,
            reduceMotionEnabled: reduceMotion
        )

        StageMotionRenderer(layer: layer, onAction: onAction)
            .accessibilityIdentifier("stage.motion.current.view")
            .accessibilityValue(objectStageContract.firstViewportStructure)
    }
}
