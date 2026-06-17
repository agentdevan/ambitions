import Foundation

enum StageMotionDisplayStyle: String, Equatable, Sendable {
    case calm
    case active
}

struct StageMotionProjection: Equatable, Sendable {
    let action: MotionCurrentAction
    let sourceSurface: String
    let reduceMotion: Bool
    let displayStyle: StageMotionDisplayStyle
    let generatedAt: Date

    init(action: MotionCurrentAction, sourceSurface: String = "motion.current", reduceMotion: Bool) {
        self.action = action
        self.sourceSurface = sourceSurface
        self.reduceMotion = reduceMotion
        self.displayStyle = reduceMotion ? .calm : .active
        self.generatedAt = .now
    }

    var continuityLabel: String {
        reduceMotion ? "Stage motion continuity (reduced)" : "Stage motion continuity"
    }
}
