import Foundation

@MainActor
@Observable
final class StageOwner {
    private var motionCoordinator: StageMotionCoordinator
    private(set) var lastMotionProjection: StageMotionProjection?
    private(set) var lastMotionCoordination: StageMotionCoordination?

    var reduceMotionEnabled: Bool

    init(reduceMotionEnabled: Bool = false) {
        self.reduceMotionEnabled = reduceMotionEnabled
        motionCoordinator = StageMotionCoordinator(reduceMotionEnabled: reduceMotionEnabled)
    }

    func setReduceMotionEnabled(_ isEnabled: Bool) {
        reduceMotionEnabled = isEnabled
        motionCoordinator.reduceMotionEnabled = isEnabled
    }

    func route(for action: MotionCurrentAction, source: String = "motion.current") -> StageMotionRoute {
        let coordination = motionCoordinator.coordinate(action: action, source: source)
        lastMotionCoordination = coordination
        lastMotionProjection = coordination.projection
        return coordination.route
    }
}
