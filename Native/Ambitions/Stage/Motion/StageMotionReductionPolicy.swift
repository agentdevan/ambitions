import Foundation

struct StageMotionReductionPolicy: Equatable, Sendable {
    let reduceMotionEnabled: Bool

    var displayStyle: StageMotionDisplayStyle {
        reduceMotionEnabled ? .calm : .active
    }

    var allowsAmbientMovement: Bool {
        reduceMotionEnabled == false
    }

    var proofThreadTextureDescription: String {
        reduceMotionEnabled
            ? "Static proof-thread marks preserve source, proof, receipt, and re-entry meaning."
            : "Subtle proof-thread motion may mark source, proof, receipt, and re-entry continuity."
    }

    var rhythmSpacingDescription: String {
        reduceMotionEnabled
            ? "Rhythm spacing stays calmer and static."
            : "Rhythm spacing can compress for motion continuity."
    }

    func motionQuery(label: String, action: MotionCurrentAction) -> String {
        guard let id = action.identifier else {
            return reduceMotionEnabled ? label : "\(label) continuity"
        }
        return "\(label):\(id)"
    }

    static func current(reduceMotionEnabled: Bool) -> StageMotionReductionPolicy {
        StageMotionReductionPolicy(reduceMotionEnabled: reduceMotionEnabled)
    }
}
