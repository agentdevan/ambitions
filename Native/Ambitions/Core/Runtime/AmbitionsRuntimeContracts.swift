import Foundation

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
    case openCaptureComposer
    case openMemoryLens
    case presentOverlay(ShellOverlayState)
}

struct RuntimeActionResult: Sendable, Equatable {
    let outcome: ExternalActionOutcome
    let routeRequest: RuntimeRouteRequest?
    let messageTitle: String?
    let pipelineTrace: StageActionPipelineTrace?

    init(
        outcome: ExternalActionOutcome,
        routeRequest: RuntimeRouteRequest? = nil,
        messageTitle: String? = nil,
        pipelineTrace: StageActionPipelineTrace? = nil
    ) {
        self.outcome = outcome
        self.routeRequest = routeRequest
        self.messageTitle = messageTitle
        self.pipelineTrace = pipelineTrace
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
    let timeRitualsService: any TimeRitualsServicing
    let timeService: any TimeServicing
    let insightsService: any InsightsServicing
    let youService: any YouServicing
    let notificationService: any NotificationServicing
    let calendarRemindersService: any CalendarRemindersServicing
    let privateLifeRuntimeKernel: PrivateLifeRuntimeKernel
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
        timeRitualsService: any TimeRitualsServicing,
        timeService: any TimeServicing,
        insightsService: any InsightsServicing,
        youService: any YouServicing,
        notificationService: any NotificationServicing,
        calendarRemindersService: any CalendarRemindersServicing,
        privateLifeRuntimeKernel: PrivateLifeRuntimeKernel,
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
        self.timeRitualsService = timeRitualsService
        self.timeService = timeService
        self.insightsService = insightsService
        self.youService = youService
        self.notificationService = notificationService
        self.calendarRemindersService = calendarRemindersService
        self.privateLifeRuntimeKernel = privateLifeRuntimeKernel
        self.dedicatedDevicePrototypeRuntime = dedicatedDevicePrototypeRuntime
    }
}
