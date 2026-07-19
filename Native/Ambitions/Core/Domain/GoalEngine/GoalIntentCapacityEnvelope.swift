import Foundation

struct GoalIntentCapacityEnvelope: Codable, Sendable, Equatable, Hashable {
    let capacityLevel: EnergyCapacityLevel
    let recoveryState: EnergyRecoveryState
    let availableWindows: [GoalIntentCapacityWindow]
    let localReasonCodes: [GoalEnergyFitReasonCode]

    init(
        capacityLevel: EnergyCapacityLevel,
        recoveryState: EnergyRecoveryState,
        availableWindows: [GoalIntentCapacityWindow] = [],
        localReasonCodes: [GoalEnergyFitReasonCode] = []
    ) {
        self.capacityLevel = capacityLevel
        self.recoveryState = recoveryState
        self.availableWindows = availableWindows
        self.localReasonCodes = localReasonCodes
    }

    var openWindowCount: Int {
        availableWindows.filter { $0.isProtected == false }.count
    }

    var protectedWindowCount: Int {
        availableWindows.filter { $0.isProtected }.count
    }

    var mode: Mode {
        if recoveryState == .needsRecovery || recoveryState == .stretch {
            return .recovery
        }
        if protectedWindowCount > 0 && openWindowCount == 0 {
            return .protectedConflict
        }
        if capacityLevel == .low {
            return .lowCapacity
        }
        return .normal
    }

    var stepLimit: Int? {
        switch mode {
        case .normal:
            return nil
        case .lowCapacity:
            return openWindowCount == 0 ? 0 : 1
        case .protectedConflict:
            return 0
        case .recovery:
            return openWindowCount == 0 ? 0 : 1
        }
    }

    var localReasonIDs: [String] {
        var identifiers = localReasonCodes.map(\.rawValue)
        identifiers.append(contentsOf: availableWindows.flatMap { $0.reasonCodes }.map(\.rawValue))
        switch mode {
        case .normal:
            if openWindowCount > 0 {
                identifiers.append("capacity.open_windows")
            }
        case .lowCapacity:
            identifiers.append("capacity.low_capacity")
        case .protectedConflict:
            identifiers.append("capacity.protected_time_conflict")
            if openWindowCount == 0 {
                identifiers.append("capacity.no_open_window")
            }
        case .recovery:
            identifiers.append(recoveryState == .needsRecovery ? "capacity.needs_recovery" : "capacity.stretched_recovery")
        }
        if protectedWindowCount > 0 {
            identifiers.append("capacity.protected_windows")
        }
        return identifiers.removingDuplicates()
    }

    var summary: String {
        switch mode {
        case .normal:
            if openWindowCount == 0 {
                return "No open window is marked, but capacity stays steady."
            }
            return openWindowCount == 1
                ? "One open window keeps the day steady."
                : "\(openWindowCount) open windows keep the day steady."
        case .lowCapacity:
            if openWindowCount == 0 {
                return "Capacity is low and no open window is marked."
            }
            return openWindowCount == 1
                ? "Capacity is low and one open window keeps the day smaller."
                : "Capacity is low and \(openWindowCount) open windows keep the day smaller."
        case .protectedConflict:
            return protectedWindowCount == 1
                ? "Protected time leaves no open window for this intent."
                : "Protected time leaves no open window for this intent."
        case .recovery:
            return recoveryState == .needsRecovery
                ? "Recovery is needed, so the next step stays gentle."
                : "Recovery is stretched, so the next step stays gentle."
        }
    }

    enum Mode: Sendable, Equatable {
        case normal
        case lowCapacity
        case protectedConflict
        case recovery
    }
}

struct GoalIntentDayCompilerInput: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let intent: GoalIntent
    let status: GoalIntentDayCompilerStatus
    let assumptions: [GoalIntentAssumption]
    let clarification: GoalIntentClarification
    let blockedReasons: [GoalIntentBlockedReason]
    let capacityEnvelope: GoalIntentCapacityEnvelope?
    let localOnly: Bool

    init(
        schemaVersion: String = goalIntentDayCompilerSchemaVersion,
        intent: GoalIntent,
        status: GoalIntentDayCompilerStatus,
        assumptions: [GoalIntentAssumption] = [],
        clarification: GoalIntentClarification,
        blockedReasons: [GoalIntentBlockedReason] = [],
        capacityEnvelope: GoalIntentCapacityEnvelope? = nil,
        localOnly: Bool = true
    ) {
        self.schemaVersion = schemaVersion
        self.intent = intent
        self.status = status
        self.assumptions = assumptions
        self.clarification = clarification
        self.blockedReasons = blockedReasons
        self.capacityEnvelope = capacityEnvelope
        self.localOnly = localOnly
    }
}

struct CompiledStep: Codable, Sendable, Equatable, Identifiable, Hashable {
    let schemaVersion: String
    let id: String
    let intentID: String
    let sourceCandidateID: String?
    let sourceStageID: String?
    let title: String
    let summary: String?
    let orderIndex: Int
    let stepTypeRawValue: String
    let paceRawValue: String
    let targetDate: String?
    let repeatEveryDays: Int?
    let evidenceHint: String?
    let contextRequirements: [String]
    let isOptional: Bool
    let isRepeatable: Bool
    let isExecutable: Bool
    let blockingReasonIDs: [String]
    let assumptionIDs: [String]
    let clarificationQuestionIDs: [String]

    init(
        schemaVersion: String = goalIntentDayCompilerSchemaVersion,
        id: String,
        intentID: String,
        sourceCandidateID: String? = nil,
        sourceStageID: String? = nil,
        title: String,
        summary: String? = nil,
        orderIndex: Int,
        stepType: StepType = .actionUnit,
        pace: PlanningPace = .untimed,
        targetDate: String? = nil,
        repeatEveryDays: Int? = nil,
        evidenceHint: String? = nil,
        contextRequirements: [String] = [],
        isOptional: Bool = false,
        isRepeatable: Bool = false,
        isExecutable: Bool = true,
        blockingReasonIDs: [String] = [],
        assumptionIDs: [String] = [],
        clarificationQuestionIDs: [String] = []
    ) {
        self.schemaVersion = schemaVersion
        self.id = normalizedRequired(id)
        self.intentID = normalizedRequired(intentID)
        self.sourceCandidateID = normalizedOptional(sourceCandidateID)
        self.sourceStageID = normalizedOptional(sourceStageID)
        self.title = normalizedRequired(title)
        self.summary = normalizedOptional(summary)
        self.orderIndex = orderIndex
        self.stepTypeRawValue = stepType.rawValue
        self.paceRawValue = pace.rawValue
        self.targetDate = normalizedOptional(targetDate)
        self.repeatEveryDays = repeatEveryDays
        self.evidenceHint = normalizedOptional(evidenceHint)
        self.contextRequirements = contextRequirements.map(normalizedRequired)
        self.isOptional = isOptional
        self.isRepeatable = isRepeatable
        self.isExecutable = isExecutable
        self.blockingReasonIDs = blockingReasonIDs.map(normalizedRequired)
        self.assumptionIDs = assumptionIDs.map(normalizedRequired)
        self.clarificationQuestionIDs = clarificationQuestionIDs.map(normalizedRequired)
    }

    var stepType: StepType {
        StepType(rawValue: stepTypeRawValue) ?? .actionUnit
    }

    var pace: PlanningPace {
        PlanningPace(rawValue: paceRawValue) ?? .untimed
    }

    func makePlanStep() -> PlanStep {
        PlanStep(
            id: id,
            title: title,
            summary: summary,
            type: stepType,
            pace: pace,
            targetDate: targetDate,
            repeatEveryDays: repeatEveryDays,
            evidenceHint: evidenceHint,
            contextRequirements: contextRequirements,
            isOptional: isOptional,
            isRepeatable: isRepeatable
        )
    }

    func makeStep(
        sectionID: String,
        owner: GoalActor = .localOwner,
        state: StepLifecycleState = .planned,
        dependencyStepIDs: [String] = []
    ) -> Step {
        makePlanStep().makeStep(
            sectionID: sectionID,
            owner: owner,
            state: state,
            dependencyStepIDs: dependencyStepIDs
        )
    }
}

struct CompiledStepReceipt: Codable, Sendable, Equatable, Identifiable, Hashable {
    let schemaVersion: String
    let id: String
    let compiledStepID: String
    let intentID: String
    let generatedAt: String
    let status: GoalIntentDayCompilerStatus
    let summary: String
    let reason: String
    let sourceSurface: GoalIntentSourceSurface
    let assumptionIDs: [String]
    let clarificationQuestionIDs: [String]
    let blockedReasonIDs: [String]
    let localOnly: Bool

    init(
        schemaVersion: String = goalIntentDayCompilerSchemaVersion,
        id: String,
        compiledStepID: String,
        intentID: String,
        generatedAt: String,
        status: GoalIntentDayCompilerStatus,
        summary: String,
        reason: String,
        sourceSurface: GoalIntentSourceSurface,
        assumptionIDs: [String] = [],
        clarificationQuestionIDs: [String] = [],
        blockedReasonIDs: [String] = [],
        localOnly: Bool = true
    ) {
        self.schemaVersion = schemaVersion
        self.id = normalizedRequired(id)
        self.compiledStepID = normalizedRequired(compiledStepID)
        self.intentID = normalizedRequired(intentID)
        self.generatedAt = normalizedRequired(generatedAt)
        self.status = status
        self.summary = normalizedRequired(summary)
        self.reason = normalizedRequired(reason)
        self.sourceSurface = sourceSurface
        self.assumptionIDs = assumptionIDs.map(normalizedRequired)
        self.clarificationQuestionIDs = clarificationQuestionIDs.map(normalizedRequired)
        self.blockedReasonIDs = blockedReasonIDs.map(normalizedRequired)
        self.localOnly = localOnly
    }
}

struct GoalIntentDayCompilerOutput: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let intent: GoalIntent
    let compiledAt: String
    let status: GoalIntentDayCompilerStatus
    let assumptions: [GoalIntentAssumption]
    let clarification: GoalIntentClarification
    let blockedReasons: [GoalIntentBlockedReason]
    let capacityEnvelope: GoalIntentCapacityEnvelope?
    let compiledSteps: [CompiledStep]
    let receipts: [CompiledStepReceipt]
    let localOnly: Bool

    init(
        schemaVersion: String = goalIntentDayCompilerSchemaVersion,
        intent: GoalIntent,
        compiledAt: String,
        status: GoalIntentDayCompilerStatus,
        assumptions: [GoalIntentAssumption] = [],
        clarification: GoalIntentClarification,
        blockedReasons: [GoalIntentBlockedReason] = [],
        capacityEnvelope: GoalIntentCapacityEnvelope? = nil,
        compiledSteps: [CompiledStep] = [],
        receipts: [CompiledStepReceipt] = [],
        localOnly: Bool = true
    ) {
        self.schemaVersion = schemaVersion
        self.intent = intent
        self.compiledAt = normalizedRequired(compiledAt)
        self.status = status
        self.assumptions = assumptions
        self.clarification = clarification
        self.blockedReasons = blockedReasons
        self.capacityEnvelope = capacityEnvelope
        self.compiledSteps = compiledSteps
        self.receipts = receipts
        self.localOnly = localOnly
    }

    var planSteps: [PlanStep] {
        compiledSteps.map { $0.makePlanStep() }
    }

    func makeSteps(
        sectionID: String = "today",
        owner: GoalActor = .localOwner,
        state: StepLifecycleState = .planned
    ) -> [Step] {
        compiledSteps.map {
            $0.makeStep(sectionID: sectionID, owner: owner, state: state)
        }
    }
}
