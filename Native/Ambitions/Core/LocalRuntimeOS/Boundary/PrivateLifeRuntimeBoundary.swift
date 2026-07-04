import Foundation

enum AmbitionsRuntimeClientKind: String, Codable, CaseIterable, Sendable, Equatable {
    case iphoneApp = "iphone_app"
    case bedsideRitualCompanion = "bedside_ritual_companion"
}

struct PrivateLifeRuntimeBoundary: Codable, Sendable, Equatable {
    let usesSwiftDataPersistence: Bool
    let usesRepositoryBackedMemory: Bool
    let syncBackendKind: SyncBackendKind
    let hasHostedBackend: Bool
    let hasRemoteIntelligenceBackend: Bool
    let hasExternalCloudLLMDependency: Bool
    let allowsExternalSideEffectsInsideUnitOfWorkBoundaries: Bool

    static let localOnly = PrivateLifeRuntimeBoundary(
        usesSwiftDataPersistence: true,
        usesRepositoryBackedMemory: true,
        syncBackendKind: .localOnly,
        hasHostedBackend: false,
        hasRemoteIntelligenceBackend: false,
        hasExternalCloudLLMDependency: false,
        allowsExternalSideEffectsInsideUnitOfWorkBoundaries: false
    )

    var isLocalOnly: Bool {
        usesSwiftDataPersistence &&
            usesRepositoryBackedMemory &&
            syncBackendKind == .localOnly &&
            hasHostedBackend == false &&
            hasRemoteIntelligenceBackend == false &&
            hasExternalCloudLLMDependency == false &&
            allowsExternalSideEffectsInsideUnitOfWorkBoundaries == false
    }

    var localOnlyMode: LocalOnlyMode {
        LocalOnlyMode(boundary: self)
    }
}

struct AmbitionsRuntimeClientContext: Codable, Sendable, Equatable {
    let kind: AmbitionsRuntimeClientKind
    let displayName: String
    let isConstrainedPrototype: Bool

    static let iphoneApp = AmbitionsRuntimeClientContext(
        kind: .iphoneApp,
        displayName: "iPhone app",
        isConstrainedPrototype: false
    )

    static let bedsideRitualCompanion = AmbitionsRuntimeClientContext(
        kind: .bedsideRitualCompanion,
        displayName: "Bedside ritual companion",
        isConstrainedPrototype: true
    )
}

struct AmbitionsRuntimeCapabilities: Sendable, Equatable {
    let privateLifeRuntimeBoundary: PrivateLifeRuntimeBoundary
    let syncBackendKind: SyncBackendKind
    let trustPosture: PortableTrustPosture
    let usesRepositoryBackedMemory: Bool
    let supportsExternalSurfaceSnapshots: Bool
    let supportsExternalActionCommands: Bool
    let supportsCalendarReminderIntegration: Bool
    let supportsNotificationScheduling: Bool
    let hasRemoteIntelligenceBackend: Bool

    static let currentLocalRuntime = AmbitionsRuntimeCapabilities(
        privateLifeRuntimeBoundary: .localOnly,
        syncBackendKind: .localOnly,
        trustPosture: .localOnly,
        usesRepositoryBackedMemory: true,
        supportsExternalSurfaceSnapshots: true,
        supportsExternalActionCommands: true,
        supportsCalendarReminderIntegration: true,
        supportsNotificationScheduling: true,
        hasRemoteIntelligenceBackend: false
    )

    var capabilityMatrix: CapabilityMatrix {
        CapabilityMatrix(capabilities: self)
    }
}
