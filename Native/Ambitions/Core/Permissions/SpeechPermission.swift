import Foundation

enum SpeechPermissionStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notDetermined = "not_determined"
    case authorized
    case denied
    case restricted
    case unavailable
}

struct SpeechPermission: Sendable {
    func state(for status: SpeechPermissionStatus) -> PermissionState {
        PermissionState(
            kind: .speechRecognition,
            availability: availability(for: status),
            canRead: status == .authorized,
            canWrite: false,
            canRequest: status == .notDetermined,
            requestTiming: status == .notDetermined ? .userInitiated : .blocked,
            fallbackSummary: fallbackSummary(for: status),
            inspectionSummary: "Speech recognition is optional for Capture and must not become a cloud-first input path. State: \(status)."
        )
    }

    func requestDecision(
        current status: SpeechPermissionStatus,
        context: PermissionRequestContext
    ) -> PermissionRequestDecision {
        let permissionState = state(for: status)
        guard context.isContextual else {
            return .blocked(
                state: permissionState,
                reason: "Speech prompts require an explicit Capture action."
            )
        }
        guard status == .notDetermined else {
            return .blocked(
                state: permissionState,
                reason: "Speech authorization is already determined."
            )
        }
        return .request(
            state: permissionState,
            reason: "Speech recognition can be requested only from an explicit Capture dictation action."
        )
    }

    private func availability(for status: SpeechPermissionStatus) -> PermissionAvailability {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .available
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .unavailable:
            return .unavailable
        }
    }

    private func fallbackSummary(for status: SpeechPermissionStatus) -> String {
        status == .authorized
            ? "Speech input can support explicit Capture dictation."
            : "Capture remains fully available through typing and local review when speech access is unavailable."
    }
}
