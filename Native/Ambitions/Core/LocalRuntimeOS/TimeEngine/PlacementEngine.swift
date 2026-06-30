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
        self.commandID = TimeEngineStableID.required(commandID)
        self.now = now
        self.stepID = TimeEngineStableID.required(stepID)
        self.title = TimeEngineStableID.required(title)
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
        guard command.kind.timeEngineProposesPlacement,
              let stepID = command.timeEngineStepID,
              let proposedWindow = command.timeEngineWindow(
                startKeys: ["proposedStartAt", "startAt", "start", "windowStart", "destinationStartAt"],
                endKeys: ["proposedEndAt", "endAt", "end", "windowEnd", "destinationEndAt"],
                durationKeys: ["approvedDurationMinutes", "durationMinutes"]
              ) else {
            return nil
        }
        let commandTitle = TimeEngineStableID.optional(command.payload.title) ?? stepID
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
    let runtimeTrace: TimeEngineRuntimeTrace

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
            runtimeTrace: TimeEngineRuntimeTrace.make(owner: "PlacementEngine", sourceID: source, localOnly: request.localOnly && graph.localOnly)
        )
    }
}

private extension AmbitionsCommandKind {
    var timeEngineProposesPlacement: Bool {
        switch self {
        case .placeStepInTime, .scheduleItem, .delayAction, .recoverAction:
            true
        default:
            false
        }
    }
}

private extension AmbitionsCommand {
    var timeEngineStepID: String? {
        target.stepID
            ?? payload.metadata["stepID"]
            ?? payload.metadata["destinationStepID"]
            ?? payload.metadata["originalStepID"]
    }

    var timeEngineTrigger: ProtectedStepPlacementTrigger {
        if payload.metadata["missedRecoveryMoveIt"] == "true" ||
            payload.metadata["recoveryAction"] == "move_it" {
            return .missedRecoveryMoveIt
        }
        if let raw = payload.metadata["placementTrigger"],
           let trigger = ProtectedStepPlacementTrigger(rawValue: raw) {
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
        for key in ["explicitUserApproval", "userConfirmed", "approvalState"] {
            guard let value = payload.metadata[key]?.lowercased() else { continue }
            if ["true", "confirmed", "approved"].contains(value) {
                return true
            }
            if ["false", "unconfirmed", "pending", "denied", "declined", "rejected"].contains(value) {
                return false
            }
        }
        switch timeEngineTrigger {
        case .userInitiated, .missedRecoveryMoveIt:
            return actor == .user
        case .automatic, .externalSurface:
            return false
        }
    }

    var timeEngineAutomationPolicy: ProtectedStepPlacementAutomationPolicy {
        let raw = payload.metadata["protectedPlacementAutomationPolicy"]
            ?? payload.metadata["automaticPlacementPolicy"]
            ?? payload.metadata["automationPolicy"]
        return raw.flatMap(ProtectedStepPlacementAutomationPolicy.init(rawValue:)) ?? .notMature
    }

    var timeEngineContextQuality: ProtectedStepPlacementContextQuality {
        let raw = payload.metadata["protectedPlacementContextQuality"]
            ?? payload.metadata["contextQuality"]
        return raw.flatMap(ProtectedStepPlacementContextQuality.init(rawValue:)) ?? .sufficient
    }

    func timeEngineWindow(startKeys: [String], endKeys: [String], durationKeys: [String]) -> ProtectedStepPlacementWindow? {
        guard let start = timeEngineDateValue(for: startKeys) else { return nil }
        let end = timeEngineDateValue(for: endKeys) ?? timeEngineDurationValue(for: durationKeys).map {
            TemporalMath.end(start: start, durationMinutes: $0)
        }
        guard let end else { return nil }
        return ProtectedStepPlacementWindow(start: start, end: end)
    }

    func timeEngineDateValue(for keys: [String]) -> Date? {
        for key in keys {
            if let value = payload.metadata[key], let date = TemporalMath.date(from: value) {
                return date
            }
        }
        return nil
    }

    func timeEngineDurationValue(for keys: [String]) -> Int? {
        for key in keys {
            if let value = payload.metadata[key], let duration = Int(value), duration > 0 {
                return duration
            }
        }
        return nil
    }
}
