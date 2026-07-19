import SwiftUI

struct MotionCurrentView: View {
    let state: MotionCurrentFieldState
    let lanes: [MotionLaneState]
    let reduceMotion: Bool
    let onAction: (MotionCurrentAction) -> Void

    var body: some View {
        MotionCurrentField(
            state: state,
            lanes: lanes,
            reduceMotion: reduceMotion,
            onAction: onAction
        )
        .accessibilityIdentifier("product.motion-current")
    }
}
