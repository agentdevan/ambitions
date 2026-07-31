import Foundation

public struct CaptureNativeCalibrationProposal: Equatable, Sendable {
    public let identity: String
    public let destination: String
    public let relatedIdentity: String
    public let relatedTruth: String
    public let currentState: String
    public let consequence: String
    public let primaryAction: String
}

public enum CaptureNativeCalibrationInterpretation: Equatable, Sendable {
    case proposed(CaptureNativeCalibrationProposal)
    case clarification(question: String)
    case unsupported
}

public struct CaptureNativeCalibrationFixture: Equatable, Sendable {
    public static let fixtureID = "capture-flagship/bounded-adaptive-meaning-passage/v1"
    public static let primaryExpression =
        "I need to prepare questions for tomorrow’s dentist appointment."
    public static let ambiguousExpression = "Prepare for tomorrow’s appointment."
    public static let clarificationQuestion = "What do you want to prepare?"
    public static let clarificationAnswer = "Questions to ask the dentist"

    public let proposal: CaptureNativeCalibrationProposal

    public func interpretation(for expression: String) -> CaptureNativeCalibrationInterpretation {
        switch Self.normalized(expression) {
        case Self.normalized(Self.primaryExpression):
            return .proposed(proposal)
        case Self.normalized(Self.ambiguousExpression):
            return .clarification(question: Self.clarificationQuestion)
        default:
            return .unsupported
        }
    }

    public func proposal(
        for expression: String,
        clarification: String
    ) -> CaptureNativeCalibrationProposal? {
        switch interpretation(for: expression) {
        case let .proposed(proposal):
            return proposal
        case .clarification:
            guard Self.normalized(clarification) == Self.normalized(Self.clarificationAnswer) else {
                return nil
            }
            return proposal
        case .unsupported:
            return nil
        }
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

public extension CaptureNativeCalibrationFixture {
    static let flagship = CaptureNativeCalibrationFixture(
        proposal: CaptureNativeCalibrationProposal(
            identity: "Prepare questions for the dentist appointment",
            destination: "Goals",
            relatedIdentity: "Dentist appointment",
            relatedTruth: "Tomorrow · 9:30 AM",
            currentState: "Nothing has changed.",
            consequence: "Goals will review this proposal. The appointment time remains unchanged.",
            primaryAction: "Continue to Goals"
        )
    )
}
