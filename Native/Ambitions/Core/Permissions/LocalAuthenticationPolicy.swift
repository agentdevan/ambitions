import Foundation
import LocalAuthentication

enum LocalAuthenticationAvailability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case available
    case passcodeUnavailable = "passcode_unavailable"
    case biometryUnavailable = "biometry_unavailable"
    case denied
    case unknownFailure = "unknown_failure"
}

struct LocalAuthenticationPolicy: Sendable {
    func state(for availability: LocalAuthenticationAvailability) -> PermissionState {
        let available = availability == .available
        return PermissionState(
            kind: .localAuthentication,
            availability: available ? .available : .unavailable,
            canRead: available,
            canWrite: false,
            canRequest: available,
            requestTiming: available ? .userInitiated : .blocked,
            fallbackSummary: available
                ? "Private areas may ask for local device authentication at the moment of access."
                : "Private areas fall back to local device settings and do not block core planning.",
            inspectionSummary: "Local authentication protects user-controlled inspection areas and never sends private graph data off-device. State: \(availability)."
        )
    }

    func evaluateAvailability(context: LAContext = LAContext()) -> PermissionState {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            return state(for: .available)
        }
        return state(for: availability(from: error))
    }

    private func availability(from error: NSError?) -> LocalAuthenticationAvailability {
        guard let code = error.map({ LAError.Code(rawValue: $0.code) }) else {
            return .unknownFailure
        }
        switch code {
        case .passcodeNotSet:
            return .passcodeUnavailable
        case .biometryNotAvailable, .biometryNotEnrolled:
            return .biometryUnavailable
        case .appCancel, .systemCancel, .userCancel, .userFallback, .authenticationFailed:
            return .denied
        default:
            return .unknownFailure
        }
    }
}
