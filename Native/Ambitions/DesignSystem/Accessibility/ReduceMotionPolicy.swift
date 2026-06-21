import Foundation

struct ReduceMotionPolicy: Equatable, Sendable {
    enum MotionMode: String, Equatable, Sendable {
        case morph
        case fade
        case staticState
    }

    let normalMode: MotionMode
    let reducedMode: MotionMode
    let preservesMutationAnnouncement: Bool
    let preservesProofTiming: Bool

    func mode(reduceMotion: Bool) -> MotionMode {
        reduceMotion ? reducedMode : normalMode
    }

    static let calmStage = ReduceMotionPolicy(
        normalMode: .fade,
        reducedMode: .staticState,
        preservesMutationAnnouncement: true,
        preservesProofTiming: true
    )

    static let objectMorph = ReduceMotionPolicy(
        normalMode: .morph,
        reducedMode: .fade,
        preservesMutationAnnouncement: true,
        preservesProofTiming: true
    )
}
