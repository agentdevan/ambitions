import Foundation

struct RuntimeValidationReport: Sendable, Equatable {
    let commandID: String
    let commandValidation: AmbitionsCommandValidationState
    let privacyBoundary: PrivacyBoundary
    let canMutate: Bool
    let blockedReasons: [String]

    var validationState: AmbitionsCommandValidationState {
        if commandValidation != .valid {
            return commandValidation
        }
        return canMutate ? .valid : .blockedByMissingFoundation
    }
}

struct RuntimeValidator: Sendable {
    let commandValidator: AmbitionsCommandValidator

    init(commandValidator: AmbitionsCommandValidator = AmbitionsCommandValidator()) {
        self.commandValidator = commandValidator
    }

    func validate(
        _ command: AmbitionsCommand,
        boundary: PrivateLifeRuntimeBoundary = .localOnly
    ) -> RuntimeValidationReport {
        let commandValidation = commandValidator.validate(command)
        let privacyBoundary = PrivacyBoundary.forCommand(command, boundary: boundary)
        let blockedReasons = blockedReasons(
            commandValidation: commandValidation,
            privacyBoundary: privacyBoundary
        )

        return RuntimeValidationReport(
            commandID: command.id,
            commandValidation: commandValidation,
            privacyBoundary: privacyBoundary,
            canMutate: commandValidation == .valid && privacyBoundary.isSatisfied,
            blockedReasons: blockedReasons
        )
    }

    private func blockedReasons(
        commandValidation: AmbitionsCommandValidationState,
        privacyBoundary: PrivacyBoundary
    ) -> [String] {
        let validationReasons = commandValidation == .valid ? [] : [commandValidation.rawValue]
        let privacyReasons = privacyBoundary.issues.map(\.rawValue)
        return Array(Set(validationReasons + privacyReasons)).sorted()
    }
}
