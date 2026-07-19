import Foundation

enum SourceAtlasAccountSessionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noAccount = "no_account"
    case signedOut = "signed_out"
    case signedIn = "signed_in"
    case expired
    case restricted
    case unknown
}

enum SourceAtlasReferenceEntitlementState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case bundledOnly = "bundled_only"
    case entitled
    case expired
    case denied
    case restricted
    case unknown
}

enum SourceAtlasNetworkReachability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case online
    case offline
    case constrained
}

enum SourceAtlasReferenceArtifactTier: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case bundledCore = "bundled_core"
    case publicFreshness = "public_freshness"
    case entitlementReferencePack = "entitlement_reference_pack"
}

enum SourceAtlasAccessRoute: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case bundledLocal = "bundled_local"
    case cachedPublic = "cached_public"
    case lastKnownGood = "last_known_good"
    case remotePublicReference = "remote_public_reference"
    case unavailable
}

enum SourceAtlasAccessIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noAccount = "no_account"
    case signedOut = "signed_out"
    case accountExpired = "account_expired"
    case accountRestricted = "account_restricted"
    case entitlementExpired = "entitlement_expired"
    case entitlementDenied = "entitlement_denied"
    case entitlementRestricted = "entitlement_restricted"
    case entitlementUnknown = "entitlement_unknown"
    case offline
    case noCachedPublicReference = "no_cached_public_reference"
}

struct SourceAtlasAccessRequest: Codable, Sendable, Equatable, Hashable {
    let artifactTier: SourceAtlasReferenceArtifactTier
    let accountSessionState: SourceAtlasAccountSessionState
    let entitlementState: SourceAtlasReferenceEntitlementState
    let networkReachability: SourceAtlasNetworkReachability
    let cachedPublicArtifactAvailable: Bool
    let lastKnownGoodAvailable: Bool
    let bundledPublicArtifactAvailable: Bool

    init(
        artifactTier: SourceAtlasReferenceArtifactTier,
        accountSessionState: SourceAtlasAccountSessionState = .noAccount,
        entitlementState: SourceAtlasReferenceEntitlementState = .bundledOnly,
        networkReachability: SourceAtlasNetworkReachability = .offline,
        cachedPublicArtifactAvailable: Bool = false,
        lastKnownGoodAvailable: Bool = false,
        bundledPublicArtifactAvailable: Bool = true
    ) {
        self.artifactTier = artifactTier
        self.accountSessionState = accountSessionState
        self.entitlementState = entitlementState
        self.networkReachability = networkReachability
        self.cachedPublicArtifactAvailable = cachedPublicArtifactAvailable
        self.lastKnownGoodAvailable = lastKnownGoodAvailable
        self.bundledPublicArtifactAvailable = bundledPublicArtifactAvailable
    }
}

struct SourceAtlasAccessDecision: Codable, Sendable, Equatable, Hashable {
    let route: SourceAtlasAccessRoute
    let issues: [SourceAtlasAccessIssue]
    let permitsRemotePublicReference: Bool
    let permitsPublicCacheRead: Bool
    let coreLocalPlanningBlocked: Bool
    let privateRuntimeDataTouched: Bool
    let unavailableStateTitle: String
    let unavailableStateDetail: String
}

struct SourceAtlasBoundary: Sendable, Equatable, Hashable {
    func resolve(_ request: SourceAtlasAccessRequest) -> SourceAtlasAccessDecision {
        var issues: [SourceAtlasAccessIssue] = []
        let route: SourceAtlasAccessRoute
        let permitsRemote: Bool

        switch request.artifactTier {
        case .bundledCore:
            route = request.bundledPublicArtifactAvailable ? .bundledLocal : .unavailable
            permitsRemote = false
            if route == .unavailable {
                issues.append(.noCachedPublicReference)
            }

        case .publicFreshness:
            if request.networkReachability == .online || request.networkReachability == .constrained {
                route = .remotePublicReference
                permitsRemote = true
            } else {
                issues.append(.offline)
                route = Self.localFallbackRoute(request)
                permitsRemote = false
                if route == .unavailable {
                    issues.append(.noCachedPublicReference)
                }
            }

        case .entitlementReferencePack:
            issues.append(contentsOf: Self.accountIssues(request.accountSessionState))
            issues.append(contentsOf: Self.entitlementIssues(request.entitlementState))

            if issues.isEmpty && (request.networkReachability == .online || request.networkReachability == .constrained) {
                route = .remotePublicReference
                permitsRemote = true
            } else {
                if request.networkReachability == .offline {
                    issues.append(.offline)
                }
                route = Self.localFallbackRoute(request)
                permitsRemote = false
                if route == .unavailable {
                    issues.append(.noCachedPublicReference)
                }
            }
        }

        return SourceAtlasAccessDecision(
            route: route,
            issues: SourceAtlasAccessIssue.allCases.filter { issues.contains($0) },
            permitsRemotePublicReference: permitsRemote,
            permitsPublicCacheRead: route == .bundledLocal || route == .cachedPublic || route == .lastKnownGood,
            coreLocalPlanningBlocked: false,
            privateRuntimeDataTouched: false,
            unavailableStateTitle: route == .unavailable ? "Reference update unavailable" : "",
            unavailableStateDetail: route == .unavailable
                ? "Ambitions can keep local planning available without an account or live Source Atlas update."
                : ""
        )
    }

    private static func localFallbackRoute(_ request: SourceAtlasAccessRequest) -> SourceAtlasAccessRoute {
        if request.cachedPublicArtifactAvailable {
            return .cachedPublic
        }
        if request.lastKnownGoodAvailable {
            return .lastKnownGood
        }
        if request.bundledPublicArtifactAvailable {
            return .bundledLocal
        }
        return .unavailable
    }

    private static func accountIssues(_ state: SourceAtlasAccountSessionState) -> [SourceAtlasAccessIssue] {
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
            return [.signedOut]
        }
    }

    private static func entitlementIssues(_ state: SourceAtlasReferenceEntitlementState) -> [SourceAtlasAccessIssue] {
        switch state {
        case .entitled:
            return []
        case .bundledOnly:
            return [.entitlementDenied]
        case .expired:
            return [.entitlementExpired]
        case .denied:
            return [.entitlementDenied]
        case .restricted:
            return [.entitlementRestricted]
        case .unknown:
            return [.entitlementUnknown]
        }
    }
}
