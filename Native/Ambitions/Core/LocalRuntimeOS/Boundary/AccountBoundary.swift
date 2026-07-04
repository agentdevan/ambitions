import Foundation

enum AccountBoundaryCapability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case offlineCoreRuntime = "offline_core_runtime"
    case accountIdentity = "account_identity"
    case entitlementRefresh = "entitlement_refresh"
    case publicReferenceAccess = "public_reference_access"
    case privateGraphSync = "private_graph_sync"
    case accountRecovery = "account_recovery"
}

enum AccountBoundaryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noAccount = "no_account"
    case signedOut = "signed_out"
    case accountExpired = "account_expired"
    case accountRestricted = "account_restricted"
    case accountUnknown = "account_unknown"
    case hostedPrivateGraphForbidden = "hosted_private_graph_forbidden"
    case privateGraphSyncForbidden = "private_graph_sync_forbidden"
}

struct AccountBoundaryRequest: Codable, Sendable, Equatable, Hashable {
    let capability: AccountBoundaryCapability
    let sessionState: SourceAtlasAccountSessionState

    init(
        capability: AccountBoundaryCapability,
        sessionState: SourceAtlasAccountSessionState = .noAccount
    ) {
        self.capability = capability
        self.sessionState = sessionState
    }
}

struct AccountBoundaryDecision: Codable, Sendable, Equatable, Hashable {
    let capability: AccountBoundaryCapability
    let permitted: Bool
    let offlineCoreAvailable: Bool
    let requiresAccountProviderFlow: Bool
    let touchesPrivateLifeGraph: Bool
    let issues: [AccountBoundaryIssue]
    let explanation: String
}

struct AccountBoundary: Sendable, Equatable {
    let runtimeBoundary: PrivateLifeRuntimeBoundary

    init(runtimeBoundary: PrivateLifeRuntimeBoundary = .localOnly) {
        self.runtimeBoundary = runtimeBoundary
    }

    func resolve(_ request: AccountBoundaryRequest) -> AccountBoundaryDecision {
        switch request.capability {
        case .offlineCoreRuntime:
            return AccountBoundaryDecision(
                capability: request.capability,
                permitted: runtimeBoundary.isLocalOnly,
                offlineCoreAvailable: runtimeBoundary.isLocalOnly,
                requiresAccountProviderFlow: false,
                touchesPrivateLifeGraph: false,
                issues: runtimeBoundary.isLocalOnly ? [] : [.hostedPrivateGraphForbidden],
                explanation: "Offline core runtime must remain available without an Ambitions account."
            )

        case .accountIdentity, .entitlementRefresh, .accountRecovery:
            let accountIssues = Self.accountIssues(request.sessionState)
            return AccountBoundaryDecision(
                capability: request.capability,
                permitted: accountIssues.isEmpty,
                offlineCoreAvailable: runtimeBoundary.isLocalOnly,
                requiresAccountProviderFlow: true,
                touchesPrivateLifeGraph: false,
                issues: accountIssues,
                explanation: "Account features may use provider identity or entitlement state without becoming private graph storage."
            )

        case .publicReferenceAccess:
            return AccountBoundaryDecision(
                capability: request.capability,
                permitted: true,
                offlineCoreAvailable: runtimeBoundary.isLocalOnly,
                requiresAccountProviderFlow: false,
                touchesPrivateLifeGraph: false,
                issues: [],
                explanation: "Bundled and cached public reference access remains available without an account."
            )

        case .privateGraphSync:
            return AccountBoundaryDecision(
                capability: request.capability,
                permitted: false,
                offlineCoreAvailable: runtimeBoundary.isLocalOnly,
                requiresAccountProviderFlow: false,
                touchesPrivateLifeGraph: true,
                issues: [.privateGraphSyncForbidden, .hostedPrivateGraphForbidden],
                explanation: "The account boundary does not permit hosted private life graph sync."
            )
        }
    }

    private static func accountIssues(_ state: SourceAtlasAccountSessionState) -> [AccountBoundaryIssue] {
        switch state {
        case .signedIn:
            return []
        case .noAccount:
            return [.noAccount]
        case .signedOut:
            return [.signedOut]
        case .expired:
            return [.accountExpired]
        case .restricted:
            return [.accountRestricted]
        case .unknown:
            return [.accountUnknown]
        }
    }
}
