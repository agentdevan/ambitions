import Foundation

enum AmbitionsRuntimeClientKind: String, Codable, CaseIterable, Sendable, Equatable {
    case iphoneApp = "iphone_app"
    case bedsideRitualCompanion = "bedside_ritual_companion"
}

struct PrivateLifeRuntimeBoundary: Sendable, Equatable {
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
}

struct RuntimeMemorySnapshot: Sendable, Equatable {
    let goals: [Goal]
    let drafts: [PersistedGoalDraft]
    let evidence: [ProgressEvidence]
    let feedback: [GoalFeedbackEvent]
    let captures: [Capture]
    let appState: AppStateSnapshot
}

struct RuntimeMemorySummary: Sendable, Equatable {
    let goalCount: Int
    let draftCount: Int
    let evidenceCount: Int
    let feedbackCount: Int
    let captureCount: Int

    init(memory: RuntimeMemorySnapshot) {
        goalCount = memory.goals.count
        draftCount = memory.drafts.count
        evidenceCount = memory.evidence.count
        feedbackCount = memory.feedback.count
        captureCount = memory.captures.count
    }
}

struct RuntimeContextSnapshot: Sendable, Equatable {
    let clientContext: AmbitionsRuntimeClientContext
    let capabilities: AmbitionsRuntimeCapabilities
    let syncStatus: SyncCapabilityStatus
    let knowledgeProviderStatuses: [KnowledgeProviderStatus]
    let memorySummary: RuntimeMemorySummary
    let externalSurfaceSnapshot: ExternalSurfaceSnapshot?
}

enum RuntimeRouteRequest: Codable, Sendable, Equatable {
    case openToday
    case openGoalDetail(goalID: String)
    case openCapturesInbox
    case openMemoryLens
    case presentOverlay(ShellOverlayState)
}

struct RuntimeActionResult: Sendable, Equatable {
    let outcome: ExternalActionOutcome
    let routeRequest: RuntimeRouteRequest?
    let messageTitle: String?

    init(
        outcome: ExternalActionOutcome,
        routeRequest: RuntimeRouteRequest? = nil,
        messageTitle: String? = nil
    ) {
        self.outcome = outcome
        self.routeRequest = routeRequest
        self.messageTitle = messageTitle
    }
}

protocol RuntimeMemoryServicing: Sendable {
    func loadMemory() async throws -> RuntimeMemorySnapshot
}

protocol RuntimeContextServicing: Sendable {
    func loadContext(now: Date) async throws -> RuntimeContextSnapshot
}

protocol RuntimeExternalSurfaceSnapshotReading: Sendable {
    func loadSnapshot() async throws -> ExternalSurfaceSnapshot?
}

@MainActor
protocol RuntimeActionCommandExecuting: AnyObject {
    func execute(_ command: ExternalActionCommand, now: Date) async -> RuntimeActionResult
}

@MainActor
final class AmbitionsRuntime {
    let clientContext: AmbitionsRuntimeClientContext
    let capabilities: AmbitionsRuntimeCapabilities
    let repositories: AppRepositories
    let knowledgeProvider: any KnowledgeProviding
    let memoryService: any RuntimeMemoryServicing
    let contextService: any RuntimeContextServicing
    let actionExecutor: any RuntimeActionCommandExecuting
    let goalIntelligenceService: any RuntimeGoalIntelligenceServicing
    let syncCapability: any SyncCapability
    let snapshotWriter: any ExternalSurfaceSnapshotWriting
    let todayService: any TodayServicing
    let goalsService: any GoalsServicing
    let captureService: any CaptureServicing
    let habitsService: any HabitsServicing
    let timeService: any TimeServicing
    let insightsService: any InsightsServicing
    let youService: any YouServicing
    let notificationService: any NotificationServicing
    let calendarRemindersService: any CalendarRemindersServicing
    let dedicatedDevicePrototypeRuntime: DedicatedDevicePrototypeRuntime

    init(
        clientContext: AmbitionsRuntimeClientContext,
        capabilities: AmbitionsRuntimeCapabilities,
        repositories: AppRepositories,
        knowledgeProvider: any KnowledgeProviding,
        memoryService: any RuntimeMemoryServicing,
        contextService: any RuntimeContextServicing,
        actionExecutor: any RuntimeActionCommandExecuting,
        goalIntelligenceService: any RuntimeGoalIntelligenceServicing,
        syncCapability: any SyncCapability,
        snapshotWriter: any ExternalSurfaceSnapshotWriting,
        todayService: any TodayServicing,
        goalsService: any GoalsServicing,
        captureService: any CaptureServicing,
        habitsService: any HabitsServicing,
        timeService: any TimeServicing,
        insightsService: any InsightsServicing,
        youService: any YouServicing,
        notificationService: any NotificationServicing,
        calendarRemindersService: any CalendarRemindersServicing,
        dedicatedDevicePrototypeRuntime: DedicatedDevicePrototypeRuntime
    ) {
        self.clientContext = clientContext
        self.capabilities = capabilities
        self.repositories = repositories
        self.knowledgeProvider = knowledgeProvider
        self.memoryService = memoryService
        self.contextService = contextService
        self.actionExecutor = actionExecutor
        self.goalIntelligenceService = goalIntelligenceService
        self.syncCapability = syncCapability
        self.snapshotWriter = snapshotWriter
        self.todayService = todayService
        self.goalsService = goalsService
        self.captureService = captureService
        self.habitsService = habitsService
        self.timeService = timeService
        self.insightsService = insightsService
        self.youService = youService
        self.notificationService = notificationService
        self.calendarRemindersService = calendarRemindersService
        self.dedicatedDevicePrototypeRuntime = dedicatedDevicePrototypeRuntime
    }
}
