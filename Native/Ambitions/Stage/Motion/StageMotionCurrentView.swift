import Foundation
import SwiftUI

struct StageMotionCurrentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let projection: MotionCurrentProjection
    private let onAction: (MotionCurrentAction) -> Void

    init(
        projection: MotionCurrentProjection? = nil,
        onAction: @escaping (MotionCurrentAction) -> Void = { action in
            NotificationCenter.default.post(
                name: MotionCurrentAction.notificationName,
                object: nil,
                userInfo: action.toNotificationPayload()
            )
        }
    ) {
        self.projection = projection ?? .objectConsequence(renderState: .launchArgument)
        self.onAction = onAction
    }

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
