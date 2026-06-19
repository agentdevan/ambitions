import AmbitionsDesignSystem
import Foundation
import SwiftUI

struct StageMotionCurrentView: View {
    @Environment(\.ambitionTheme) private var theme
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
        self.projection = projection ?? .fixture(renderState: .launchArgument)
        self.onAction = onAction
    }

    var body: some View {
        let objectStageContract = MotionObjectStagePrimitiveContract.current

        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                MotionContextCrown(state: projection.crown)
                MotionCurrentField(
                    state: projection.field,
                    lanes: projection.lanes,
                    reduceMotion: reduceMotion,
                    onAction: onAction
                )
                MotionReentryPrompt()
                MotionLaneCluster(lanes: projection.lanes)
                MotionSourceReceiptAffordance(state: projection.affordance)
                MotionContinuityDock(actions: projection.dockActions, onAction: onAction)
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("motion.current.scroll")
        .accessibilityIdentifier("stage.motion.current.view")
        .accessibilityValue(objectStageContract.firstViewportStructure)
    }
}
