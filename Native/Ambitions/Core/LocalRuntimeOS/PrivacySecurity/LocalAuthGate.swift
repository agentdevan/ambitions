import Foundation

enum LocalAuthGateIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case authenticationUnavailable = "authentication_unavailable"
    case authenticationNotSatisfied = "authentication_not_satisfied"
}

struct LocalAuthGateRequest: Codable, Sendable, Equatable, Hashable {
    let id: String
    let object: PrivacyClassifiedObject
    let surface: SensitiveSurface
    let availability: LocalAuthenticationAvailability
    let authenticationSatisfied: Bool

    init(
        id: String,
        object: PrivacyClassifiedObject,
        surface: SensitiveSurface,
        availability: LocalAuthenticationAvailability,
        authenticationSatisfied: Bool
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.object = object
        self.surface = surface
        self.availability = availability
        self.authenticationSatisfied = authenticationSatisfied
    }
}

struct LocalAuthGateDecision: Codable, Sendable, Equatable, Hashable {
    let requestID: String
    let required: Bool
    let permitted: Bool
    let permissionState: PermissionState
    let issues: [LocalAuthGateIssue]
    let receipt: PrivacySecurityReceipt
}

struct LocalAuthGate: Sendable {
    let policy: LocalAuthenticationPolicy

    init(policy: LocalAuthenticationPolicy = LocalAuthenticationPolicy()) {
        self.policy = policy
    }

    func evaluate(_ request: LocalAuthGateRequest) -> LocalAuthGateDecision {
        let permissionState = policy.state(for: request.availability)
        let required = request.object.privacyClass.requiresLocalAuthentication && request.surface == .localInspection
        var issues: [LocalAuthGateIssue] = []

        if required && permissionState.canRead == false {
            issues.append(.authenticationUnavailable)
        }
        if required && request.authenticationSatisfied == false {
            issues.append(.authenticationNotSatisfied)
        }

        let permitted = issues.isEmpty
        return LocalAuthGateDecision(
            requestID: request.id,
            required: required,
            permitted: permitted,
            permissionState: permissionState,
            issues: issues,
            receipt: PrivacySecurityReceipt(
                id: "privacy_receipt.local_auth.\(request.id)",
                action: .localAuth,
                objectID: request.object.id,
                surface: request.surface,
                permitted: permitted,
                redactionApplied: false,
                localOnlyInspectionPath: "You / Privacy / Local authentication / \(request.object.id)",
                issueCodes: issues.map(\.rawValue),
                summary: permitted
                    ? "Local authentication gate permits local inspection."
                    : "Local authentication gate blocks local inspection until device authentication is available and satisfied."
            )
        )
    }
}
