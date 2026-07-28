import AmbitionsDesignSystem
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

enum RuntimeRouteIntent: Codable, Sendable, Equatable {
    case openGoal(id: String)
    case openCapture(id: String)
    case openReceipt(id: String)
    case returnToToday
    case composeCapture
    case openMemoryLens
}

struct RuntimeActionResult: Sendable, Equatable {
    let outcome: ExternalActionOutcome
    let routeIntent: RuntimeRouteIntent?
    let messageTitle: String?
    let pipelineTrace: StageActionPipelineTrace?

    init(
        outcome: ExternalActionOutcome,
        routeIntent: RuntimeRouteIntent? = nil,
        messageTitle: String? = nil,
        pipelineTrace: StageActionPipelineTrace? = nil
    ) {
        self.outcome = outcome
        self.routeIntent = routeIntent
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
        privateLifeRuntimeKernel: PrivateLifeRuntimeKernel
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
    }
}

struct RepositoryBackedRuntimeMemoryService: RuntimeMemoryServicing {
    let repositories: AppRepositories

    func loadMemory() async throws -> RuntimeMemorySnapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let captures = repositories.captures.listCaptures()
        async let appState = repositories.appState.loadState()

        return try await RuntimeMemorySnapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures,
            appState: appState
        )
    }
}

struct RepositoryBackedRuntimeContextService: RuntimeContextServicing {
    let clientContext: AmbitionsRuntimeClientContext
    let capabilities: AmbitionsRuntimeCapabilities
    let memoryService: any RuntimeMemoryServicing
    let syncCapability: any SyncCapability
    let externalSnapshotReader: any RuntimeExternalSurfaceSnapshotReading
    let knowledgeProvider: any KnowledgeProviding

    func loadContext(now: Date) async throws -> RuntimeContextSnapshot {
        async let memory = memoryService.loadMemory()
        async let syncStatus = syncCapability.status()
        async let externalSnapshot = externalSnapshotReader.loadSnapshot()
        async let knowledgeStatus = knowledgeProvider.status(now: now)

        let resolvedMemory = try await memory
        return try await RuntimeContextSnapshot(
            clientContext: clientContext,
            capabilities: capabilities,
            syncStatus: syncStatus,
            knowledgeProviderStatuses: [knowledgeStatus],
            memorySummary: RuntimeMemorySummary(memory: resolvedMemory),
            externalSurfaceSnapshot: externalSnapshot
        )
    }
}

struct FileRuntimeExternalSurfaceSnapshotReader: RuntimeExternalSurfaceSnapshotReading {
    private let reader: any ExternalSurfaceSnapshotReading

    init(reader: any ExternalSurfaceSnapshotReading = FileExternalSurfaceSnapshotReader()) {
        self.reader = reader
    }

    func loadSnapshot() async throws -> ExternalSurfaceSnapshot? {
        try await reader.loadSnapshot()
    }
}

@MainActor
final class DefaultRuntimeActionCommandExecutor: RuntimeActionCommandExecuting {
    private let todayService: any TodayServicing

    init(todayService: any TodayServicing) {
        self.todayService = todayService
    }

    func execute(_ command: ExternalActionCommand, now: Date) async -> RuntimeActionResult {
        switch command.kind {
        case .complete:
            return await performTodayCommand(.complete, command: command, now: now)
        case .delay, .snooze:
            return await performTodayCommand(.defer, command: command, now: now)
        case .askForSmallerStep:
            return await performTodayCommand(.split, command: command, now: now)
        case .openGoal:
            guard let goalID = command.target.goalID, goalID.isEmpty == false else {
                return RuntimeActionResult(
                    outcome: .missingTarget,
                    pipelineTrace: command.productRuntimePipelineTrace(
                        commandValidation: .blocked("Open goal requires a concrete goal target."),
                        runtimeMutation: .blocked("No runtime action runs without a target."),
                        visibleMutation: .blocked("No product mutation is shown for a missing target."),
                        proofReceipt: .unavailable("No proof or receipt is created for a blocked action."),
                        accessibility: .satisfied("Missing target returns a safe fallback state."),
                        fallbackUndo: .satisfied("The previous stage state remains unchanged.")
                    )
                )
            }
            return RuntimeActionResult(
                outcome: .routed,
                routeIntent: .openGoal(id: goalID),
                pipelineTrace: command.shellPipelineTrace()
            )
        case .openToday:
            return RuntimeActionResult(outcome: .routed, routeIntent: .returnToToday, pipelineTrace: command.shellPipelineTrace())
        case .openCaptureComposer:
            return RuntimeActionResult(outcome: .routed, routeIntent: .composeCapture, pipelineTrace: command.shellPipelineTrace())
        case .openMemoryLens:
            return RuntimeActionResult(outcome: .routed, routeIntent: .openMemoryLens, pipelineTrace: command.shellPipelineTrace())
        case .unsupported:
            return RuntimeActionResult(
                outcome: .unsupported,
                pipelineTrace: command.productRuntimePipelineTrace(
                    commandValidation: .blocked("Unsupported external action is rejected at command validation."),
                    runtimeMutation: .blocked("Unsupported action cannot mutate runtime."),
                    visibleMutation: .blocked("No visible product mutation is claimed."),
                    proofReceipt: .unavailable("No proof or receipt is created for unsupported action."),
                    accessibility: .satisfied("Unsupported action returns a safe unavailable state."),
                    fallbackUndo: .satisfied("The previous stage state remains unchanged.")
                )
            )
        }
    }

    private func performTodayCommand(
        _ kind: TodayActionKind,
        command: ExternalActionCommand,
        now: Date
    ) async -> RuntimeActionResult {
        guard let goalID = command.target.goalID,
              let stepID = command.target.stepID,
              goalID.isEmpty == false,
              stepID.isEmpty == false else {
            return RuntimeActionResult(
                outcome: .missingTarget,
                pipelineTrace: command.productRuntimePipelineTrace(
                    commandValidation: .blocked("Step action requires goal and step targets."),
                    runtimeMutation: .blocked("Today runtime action is not called without required targets."),
                    visibleMutation: .blocked("No Step mutation is shown for a missing target."),
                    proofReceipt: .unavailable("No proof or receipt is created for a blocked Step action."),
                    accessibility: .satisfied("Missing target returns a safe fallback state."),
                    fallbackUndo: .satisfied("The previous Step state remains unchanged.")
                )
            )
        }

        do {
            let response = try await todayService.performAction(
                TodayInlineAction(
                    kind: kind,
                    title: title(for: kind),
                    systemImage: systemImage(for: kind),
                    state: visualState(for: kind),
                    target: TodayActionTarget(
                        goalID: goalID,
                        stepID: stepID,
                        draftID: command.target.draftID
                    )
                ),
                now: now
            )
            return RuntimeActionResult(
                outcome: .performed,
                messageTitle: response.message?.title,
                pipelineTrace: command.productRuntimePipelineTrace(
                    commandValidation: .satisfied("Step action has goal and step targets."),
                    runtimeMutation: .satisfied("Today service accepted the Step action."),
                    visibleMutation: .satisfied("Today service returned after the Step action path."),
                    proofReceipt: .unavailable("Generic TodayServicing does not expose typed proof or receipt IDs at this runtime boundary."),
                    accessibility: .satisfied(TodayInteractions.accessibilityAnnouncement(for: TodayInteractions.intent(for: TodayInlineAction(kind: kind, title: title(for: kind), systemImage: systemImage(for: kind), state: visualState(for: kind), target: TodayActionTarget(goalID: goalID, stepID: stepID))))),
                    fallbackUndo: .satisfied("Failure keeps previous Step state; undo proof is owned by the Today command handler where available.")
                )
            )
        } catch {
            return RuntimeActionResult(
                outcome: .failed,
                pipelineTrace: command.productRuntimePipelineTrace(
                    commandValidation: .satisfied("Step action has goal and step targets."),
                    runtimeMutation: .blocked("Today service rejected the Step action."),
                    visibleMutation: .blocked("No Step mutation is claimed after service failure."),
                    proofReceipt: .unavailable("No proof or receipt is created when the runtime action fails."),
                    accessibility: .satisfied("Failure returns a safe unavailable state."),
                    fallbackUndo: .satisfied("The previous Step state remains unchanged.")
                )
            )
        }
    }

    private func title(for kind: TodayActionKind) -> String {
        switch kind {
        case .complete:
            return "Complete"
        case .defer:
            return "Snooze"
        case .split:
            return "Split"
        default:
            return "External action"
        }
    }

    private func systemImage(for kind: TodayActionKind) -> String {
        switch kind {
        case .complete:
            return "checkmark"
        case .defer:
            return "clock.badge"
        case .split:
            return "scissors"
        default:
            return "arrow.right.circle"
        }
    }

    private func visualState(for kind: TodayActionKind) -> AmbitionVisualState {
        switch kind {
        case .complete:
            return .success
        case .defer, .split:
            return .selected
        default:
            return .default
        }
    }
}
