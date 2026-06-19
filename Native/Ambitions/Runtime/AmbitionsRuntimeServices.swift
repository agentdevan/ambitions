import AmbitionsDesignSystem
import Foundation

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
                return RuntimeActionResult(outcome: .missingTarget)
            }
            return RuntimeActionResult(outcome: .routed, routeRequest: .openGoalDetail(goalID: goalID))
        case .openToday:
            return RuntimeActionResult(outcome: .routed, routeRequest: .openToday)
        case .openCaptureComposer:
            return RuntimeActionResult(outcome: .routed, routeRequest: .openCaptureComposer)
        case .openMemoryLens:
            return RuntimeActionResult(outcome: .routed, routeRequest: .openMemoryLens)
        case .unsupported:
            return RuntimeActionResult(outcome: .unsupported)
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
            return RuntimeActionResult(outcome: .missingTarget)
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
            return RuntimeActionResult(outcome: .performed, messageTitle: response.message?.title)
        } catch {
            return RuntimeActionResult(outcome: .failed)
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
