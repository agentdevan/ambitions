import Foundation

enum SyncBackendKind: String, Codable, Sendable {
    case localOnly = "local_only"
}

enum SyncCapabilityAvailability: String, Codable, Sendable {
    case unavailable
}

struct SyncCapabilityStatus: Codable, Sendable, Equatable {
    let backendKind: SyncBackendKind
    let trustPosture: PortableTrustPosture
    let availability: SyncCapabilityAvailability
    let detail: String
}

protocol SyncCapability: Sendable {
    func status() async -> SyncCapabilityStatus
}

struct LocalOnlySyncCapability: SyncCapability {
    func status() async -> SyncCapabilityStatus {
        SyncCapabilityStatus(
            backendKind: .localOnly,
            trustPosture: .localOnly,
            availability: .unavailable,
            detail: "Ambitions is running in explicit local-only mode."
        )
    }
}
