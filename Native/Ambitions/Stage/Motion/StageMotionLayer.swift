import Foundation

struct StageMotionLayer {
    let projection: MotionCurrentProjection
    let reductionPolicy: StageMotionReductionPolicy
    let accessibilityPlan: StageMotionAccessibilityPlan
    let rendererIdentifier: String

    var reduceMotion: Bool {
        reductionPolicy.reduceMotionEnabled
    }

    static func current(
        projection: MotionCurrentProjection,
        reduceMotionEnabled: Bool
    ) -> StageMotionLayer {
        let policy = StageMotionReductionPolicy.current(reduceMotionEnabled: reduceMotionEnabled)
        return StageMotionLayer(
            projection: projection,
            reductionPolicy: policy,
            accessibilityPlan: StageMotionAccessibilityPlan.current(
                projection: projection,
                reductionPolicy: policy
            ),
            rendererIdentifier: "stage.motion.renderer.current"
        )
    }
}
