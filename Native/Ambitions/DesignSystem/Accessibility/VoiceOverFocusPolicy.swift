import Foundation

struct VoiceOverFocusPolicy: Equatable, Sendable {
    enum Target: String, Equatable, Sendable {
        case stageTitle
        case primaryObject
        case primaryAction
        case composerInput
        case proofReceipt
    }

    let initialTarget: Target
    let mutationTarget: Target
    let recoveryTarget: Target
    let restoresAfterOverlayDismissal: Bool

    var proofSummary: String {
        "Initial \(initialTarget.rawValue), mutation \(mutationTarget.rawValue), recovery \(recoveryTarget.rawValue)."
    }

    static let composer = VoiceOverFocusPolicy(
        initialTarget: .composerInput,
        mutationTarget: .proofReceipt,
        recoveryTarget: .composerInput,
        restoresAfterOverlayDismissal: true
    )

    static let primaryObject = VoiceOverFocusPolicy(
        initialTarget: .primaryObject,
        mutationTarget: .primaryAction,
        recoveryTarget: .primaryObject,
        restoresAfterOverlayDismissal: true
    )
}
