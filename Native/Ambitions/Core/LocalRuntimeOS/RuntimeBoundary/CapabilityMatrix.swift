import Foundation

enum RuntimeCapability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case offlineCoreRuntime = "offline_core_runtime"
    case repositoryBackedMemory = "repository_backed_memory"
    case externalSurfaceSnapshots = "external_surface_snapshots"
    case externalActionCommands = "external_action_commands"
    case calendarReminderIntegration = "calendar_reminder_integration"
    case notificationScheduling = "notification_scheduling"
    case sourceAtlasPublicReference = "source_atlas_public_reference"
    case accountIdentity = "account_identity"
    case hostedPrivateLifeGraph = "hosted_private_life_graph"
    case remoteIntelligenceBackend = "remote_intelligence_backend"
    case externalCloudLLMDependency = "external_cloud_llm_dependency"
    case externalSideEffectsInsideUnitOfWork = "external_side_effects_inside_unit_of_work"
}

struct RuntimeCapabilityDecision: Codable, Sendable, Equatable, Hashable, Identifiable {
    let capability: RuntimeCapability
    let permitted: Bool
    let localOnlyCompatible: Bool
    let requiresAccount: Bool
    let issueCodes: [String]
    let explanation: String

    var id: String {
        capability.rawValue
    }
}

struct CapabilityMatrix: Sendable, Equatable {
    let boundary: PrivateLifeRuntimeBoundary
    let localOnlyMode: LocalOnlyMode
    let decisions: [RuntimeCapabilityDecision]

    init(capabilities: AmbitionsRuntimeCapabilities) {
        let mode = capabilities.privateLifeRuntimeBoundary.localOnlyMode
        self.boundary = capabilities.privateLifeRuntimeBoundary
        self.localOnlyMode = mode
        self.decisions = Self.buildDecisions(capabilities: capabilities, localOnlyMode: mode)
    }

    func decision(for capability: RuntimeCapability) -> RuntimeCapabilityDecision {
        decisions.first { $0.capability == capability } ?? RuntimeCapabilityDecision(
            capability: capability,
            permitted: false,
            localOnlyCompatible: false,
            requiresAccount: false,
            issueCodes: ["capability_not_declared"],
            explanation: "Capability is not declared by the current runtime matrix."
        )
    }

    var isLocalOnlySatisfied: Bool {
        localOnlyMode.isSatisfied &&
            decision(for: .hostedPrivateLifeGraph).permitted == false &&
            decision(for: .remoteIntelligenceBackend).permitted == false &&
            decision(for: .externalCloudLLMDependency).permitted == false &&
            decision(for: .externalSideEffectsInsideUnitOfWork).permitted == false
    }

    private static func buildDecisions(
        capabilities: AmbitionsRuntimeCapabilities,
        localOnlyMode: LocalOnlyMode
    ) -> [RuntimeCapabilityDecision] {
        [
            RuntimeCapabilityDecision(
                capability: .offlineCoreRuntime,
                permitted: localOnlyMode.offlineCoreAvailable,
                localOnlyCompatible: true,
                requiresAccount: false,
                issueCodes: localOnlyMode.issues.map(\.rawValue),
                explanation: "Offline core runtime is available only when local persistence, local sync, and repository-backed memory are intact."
            ),
            RuntimeCapabilityDecision(
                capability: .repositoryBackedMemory,
                permitted: capabilities.usesRepositoryBackedMemory,
                localOnlyCompatible: capabilities.usesRepositoryBackedMemory,
                requiresAccount: false,
                issueCodes: capabilities.usesRepositoryBackedMemory ? [] : [LocalOnlyModeIssue.repositoryBackedMemoryMissing.rawValue],
                explanation: "Runtime memory must be repository-backed and local."
            ),
            RuntimeCapabilityDecision(
                capability: .externalSurfaceSnapshots,
                permitted: capabilities.supportsExternalSurfaceSnapshots,
                localOnlyCompatible: true,
                requiresAccount: false,
                issueCodes: [],
                explanation: "External surface snapshots are permitted only as local/app-group-safe projections."
            ),
            RuntimeCapabilityDecision(
                capability: .externalActionCommands,
                permitted: capabilities.supportsExternalActionCommands,
                localOnlyCompatible: true,
                requiresAccount: false,
                issueCodes: [],
                explanation: "External action commands may request local commands but must not mutate outside the command spine."
            ),
            RuntimeCapabilityDecision(
                capability: .calendarReminderIntegration,
                permitted: capabilities.supportsCalendarReminderIntegration,
                localOnlyCompatible: true,
                requiresAccount: false,
                issueCodes: [],
                explanation: "Calendar/reminder integration remains bounded by local runtime decisions."
            ),
            RuntimeCapabilityDecision(
                capability: .notificationScheduling,
                permitted: capabilities.supportsNotificationScheduling,
                localOnlyCompatible: true,
                requiresAccount: false,
                issueCodes: [],
                explanation: "Notification scheduling is permitted as a side-effect outbox responsibility after local commit."
            ),
            RuntimeCapabilityDecision(
                capability: .sourceAtlasPublicReference,
                permitted: true,
                localOnlyCompatible: true,
                requiresAccount: false,
                issueCodes: [],
                explanation: "Source Atlas may provide bundled, cached, or remote public/reference artifacts without touching the private runtime graph."
            ),
            RuntimeCapabilityDecision(
                capability: .accountIdentity,
                permitted: true,
                localOnlyCompatible: true,
                requiresAccount: false,
                issueCodes: [],
                explanation: "Account identity may unlock identity or entitlement features but must not gate offline core value."
            ),
            RuntimeCapabilityDecision(
                capability: .hostedPrivateLifeGraph,
                permitted: false,
                localOnlyCompatible: false,
                requiresAccount: false,
                issueCodes: [LocalOnlyModeIssue.hostedPrivateLifeBackend.rawValue],
                explanation: "A hosted private life graph is outside the runtime boundary."
            ),
            RuntimeCapabilityDecision(
                capability: .remoteIntelligenceBackend,
                permitted: false,
                localOnlyCompatible: false,
                requiresAccount: false,
                issueCodes: [LocalOnlyModeIssue.remoteIntelligenceBackend.rawValue],
                explanation: "Remote intelligence is not a core runtime dependency."
            ),
            RuntimeCapabilityDecision(
                capability: .externalCloudLLMDependency,
                permitted: false,
                localOnlyCompatible: false,
                requiresAccount: false,
                issueCodes: [LocalOnlyModeIssue.externalCloudLLMDependency.rawValue],
                explanation: "External cloud LLM dependency is not permitted for core runtime behavior."
            ),
            RuntimeCapabilityDecision(
                capability: .externalSideEffectsInsideUnitOfWork,
                permitted: false,
                localOnlyCompatible: false,
                requiresAccount: false,
                issueCodes: [LocalOnlyModeIssue.externalSideEffectInsideUnitOfWork.rawValue],
                explanation: "External effects must happen through side-effect outboxes after local mutation receipts."
            ),
        ]
    }
}
