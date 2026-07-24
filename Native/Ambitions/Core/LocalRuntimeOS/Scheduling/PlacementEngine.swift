import Foundation

struct TimePlacementRequest: Sendable, Equatable, Hashable {
    let commandID: String
    let now: Date
    let stepID: String
    let title: String
    let originalWindow: ProtectedStepPlacementWindow?
    let proposedWindow: ProtectedStepPlacementWindow?
    let trigger: ProtectedStepPlacementTrigger
    let explicitUserApproval: Bool
    let automationPolicy: ProtectedStepPlacementAutomationPolicy
    let contextQuality: ProtectedStepPlacementContextQuality
    let localOnly: Bool
    let priorityInput: PriorityPlacementInput
    let candidateBlock: TimeBlock?

    init(
        commandID: String,
        now: Date,
        stepID: String,
        title: String,
        originalWindow: ProtectedStepPlacementWindow?,
        proposedWindow: ProtectedStepPlacementWindow?,
        trigger: ProtectedStepPlacementTrigger,
        explicitUserApproval: Bool,
        automationPolicy: ProtectedStepPlacementAutomationPolicy,
        contextQuality: ProtectedStepPlacementContextQuality,
        localOnly: Bool,
        priorityInput: PriorityPlacementInput
    ) {
        self.commandID = SchedulingStableID.required(commandID)
        self.now = now
        self.stepID = SchedulingStableID.required(stepID)
        self.title = SchedulingStableID.required(title)
        self.originalWindow = originalWindow
        self.proposedWindow = proposedWindow
        self.trigger = trigger
        self.explicitUserApproval = explicitUserApproval
        self.automationPolicy = automationPolicy
        self.contextQuality = contextQuality
        self.localOnly = localOnly
        self.priorityInput = priorityInput
        if let proposedWindow {
            candidateBlock = TimeBlock(
                title: self.title,
                start: proposedWindow.start,
                end: proposedWindow.end,
                kind: .scheduledStep,
                source: .command,
                stepID: self.stepID,
                commandID: self.commandID,
                localOnly: localOnly
            )
        } else {
            candidateBlock = nil
        }
    }

    init?(command: AmbitionsCommand, context: CommandExecutionContext) {
        guard case let .schedule(schedule) = command.typedPayload else { return nil }
        switch schedule.action {
        case .schedule, .placeStep, .calendarWrite: break
        case .createItem, .protectWindow, .correctWindow, .undo, .ritual: return nil
        }
        guard let stepID = command.timeEngineStepID,
              let proposedWindow = command.timeEngineWindow(
                startKeys: ["proposedStartAt", "startAt", "start", "windowStart", "destinationStartAt"],
                endKeys: ["proposedEndAt", "endAt", "end", "windowEnd", "destinationEndAt"],
                durationKeys: ["approvedDurationMinutes", "durationMinutes"]
              ) else {
            return nil
        }
        let commandTitle = SchedulingStableID.optional(command.content.title) ?? stepID
        self.init(
            commandID: command.id,
            now: context.now,
            stepID: stepID,
            title: commandTitle,
            originalWindow: command.timeEngineWindow(
                startKeys: ["originalStartAt", "originalStart", "currentStartAt", "currentStart", "previousStartAt", "previousStart", "originalWindowStart"],
                endKeys: ["originalEndAt", "originalEnd", "currentEndAt", "currentEnd", "previousEndAt", "previousEnd", "originalWindowEnd"],
                durationKeys: ["originalDurationMinutes", "currentDurationMinutes", "durationMinutes"]
            ),
            proposedWindow: proposedWindow,
            trigger: command.timeEngineTrigger,
            explicitUserApproval: command.timeEngineExplicitApproval,
            automationPolicy: command.timeEngineAutomationPolicy,
            contextQuality: command.timeEngineContextQuality,
            localOnly: command.localOnly,
            priorityInput: PriorityPlacementInput.fromCommand(command)
        )
    }
}

struct TimePlacementDecision: Sendable, Equatable, Hashable {
    let request: TimePlacementRequest
    let protectedEvaluation: ProtectedTimeEvaluation
    let priorityDecision: PriorityPlacementDecision
    let conflictProposals: [TimeConflictProposal]
    let runtimeTrace: SchedulingRuntimeTrace

    var protectedPlacementDecision: ProtectedStepPlacementDecision {
        protectedEvaluation.protectedPlacementDecision
    }

    var canCommit: Bool {
        protectedPlacementDecision.kind == .allowed &&
            protectedEvaluation.constraintEvaluation.hasBlockingViolation == false &&
            conflictProposals.contains { $0.kind == .commit && $0.canCommit }
    }

    var requiresReviewBeforeMutation: Bool {
        canCommit == false
    }
}

struct PlacementEngine: Sendable {
    private let protectedTimeEngine: ProtectedTimeEngine
    private let priorityPolicy: PriorityPlacementPolicy
    private let conflictProposalEngine: ConflictProposalEngine

    init(
        protectedTimeEngine: ProtectedTimeEngine = ProtectedTimeEngine(),
        priorityPolicy: PriorityPlacementPolicy = PriorityPlacementPolicy(),
        conflictProposalEngine: ConflictProposalEngine = ConflictProposalEngine()
    ) {
        self.protectedTimeEngine = protectedTimeEngine
        self.priorityPolicy = priorityPolicy
        self.conflictProposalEngine = conflictProposalEngine
    }

    func evaluate(command: AmbitionsCommand, context: CommandExecutionContext, graph: TimeBlockGraph = .empty) -> TimePlacementDecision? {
        guard let request = TimePlacementRequest(command: command, context: context) else { return nil }
        return evaluate(request: request, graph: graph)
    }

    func evaluate(request: TimePlacementRequest, graph: TimeBlockGraph = .empty) -> TimePlacementDecision {
        let protectedEvaluation = protectedTimeEngine.evaluate(request: request, graph: graph)
        let priorityDecision = priorityPolicy.evaluate(
            input: request.priorityInput,
            protectedPlacementDecision: protectedEvaluation.protectedPlacementDecision
        )
        let proposals = request.candidateBlock.map {
            conflictProposalEngine.proposals(for: $0, graph: graph)
        } ?? []
        let source = [
            request.commandID,
            protectedEvaluation.runtimeTrace.checksum,
            priorityDecision.schemaVersion,
            proposals.map(\.id).joined(separator: ",")
        ].joined(separator: "|")
        return TimePlacementDecision(
            request: request,
            protectedEvaluation: protectedEvaluation,
            priorityDecision: priorityDecision,
            conflictProposals: proposals,
            runtimeTrace: SchedulingRuntimeTrace.make(owner: "PlacementEngine", sourceID: source, localOnly: request.localOnly && graph.localOnly)
        )
    }
}

private extension AmbitionsCommand {
    var timeEngineStepID: String? {
        target.stepID ?? calendarWriteCommandIntent?.destinationStepID?.rawValue
    }

    var timeEngineTrigger: ProtectedStepPlacementTrigger {
        if let trigger = timePlacementCommandIntent?.trigger ?? calendarWriteCommandIntent?.placement?.trigger {
            return trigger
        }
        if actor == .system || source == .system {
            return .automatic
        }
        if actor == .externalSurface || [.widget, .liveActivity, .appIntent, .notification, .deepLink].contains(source) {
            return .externalSurface
        }
        return .userInitiated
    }

    var timeEngineExplicitApproval: Bool {
        if let explicit = timePlacementCommandIntent?.explicitUserApproval ?? calendarWriteCommandIntent?.placement?.explicitUserApproval {
            return explicit
        }
        switch timeEngineTrigger {
        case .userInitiated, .missedRecoveryMoveIt:
            return actor == .user
        case .automatic, .externalSurface:
            return false
        }
    }

    var timeEngineAutomationPolicy: ProtectedStepPlacementAutomationPolicy {
        timePlacementCommandIntent?.automationPolicy ?? calendarWriteCommandIntent?.placement?.automationPolicy ?? .notMature
    }

    var timeEngineContextQuality: ProtectedStepPlacementContextQuality {
        timePlacementCommandIntent?.contextQuality ?? calendarWriteCommandIntent?.placement?.contextQuality ?? .sufficient
    }

    func timeEngineWindow(startKeys: [String], endKeys: [String], durationKeys: [String]) -> ProtectedStepPlacementWindow? {
        let placement = timePlacementCommandIntent ?? calendarWriteCommandIntent?.placement
        guard let placement else { return nil }
        let original = startKeys.contains(where: { $0.hasPrefix("original") || $0.hasPrefix("current") || $0.hasPrefix("previous") })
        guard let start = TemporalMath.date(from: original ? placement.originalStart ?? "" : placement.start),
              let end = TemporalMath.date(from: original ? placement.originalEnd ?? "" : placement.end) else { return nil }
        return ProtectedStepPlacementWindow(start: start, end: end)
    }
}
