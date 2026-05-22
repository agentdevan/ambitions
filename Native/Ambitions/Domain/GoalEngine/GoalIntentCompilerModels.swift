import Foundation

let goalIntentCompilerSchemaVersion = "goal_intent_compiler.native.v1"
let goalIntentDayCompilerSchemaVersion = "goal_intent_day_compiler.native.v1"

enum GoalIntentDayCompilerStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case clear
    case ambiguous
    case blocked

    var allowsExecution: Bool {
        self != .blocked
    }
}

enum GoalIntentSourceSurface: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case capture
    case goals
    case time
    case today
    case you
    case manual
    case command
    case path
    case plan
}

enum GoalPrivacyClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localOnly = "local_only"
    case privateLife = "private_life"
    case sensitive
    case shared
}

enum GoalSourceState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case rawInput = "raw_input"
    case draft
    case path
    case plan
    case blocked
}

enum GoalContextSignalKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case age
    case currentSkill = "current_skill"
    case currentAccess = "current_access"
    case timeline
    case budget
    case capacity
    case healthSensitiveSignal = "health_sensitive_signal"
    case relationshipSensitiveSignal = "relationship_sensitive_signal"
    case financialRiskSignal = "financial_risk_signal"
    case legalSourceSignal = "legal_source_signal"
    case professionalReviewSignal = "professional_review_signal"
    case custom
}

enum GoalIntentBlockedReasonKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingContext = "missing_context"
    case clarificationNeeded = "clarification_needed"
    case blockedPath = "blocked_path"
    case proofGap = "proof_gap"
    case runtimeBoundary = "runtime_boundary"
    case other
}

struct GoalContextSignal: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let kind: GoalContextSignalKind
    let summary: String
    let detail: String?
    let isKnown: Bool

    init(
        id: String,
        kind: GoalContextSignalKind,
        summary: String,
        detail: String? = nil,
        isKnown: Bool = true
    ) {
        self.id = normalizedRequired(id)
        self.kind = kind
        self.summary = normalizedRequired(summary)
        self.detail = normalizedOptional(detail)
        self.isKnown = isKnown
    }
}

struct GoalIntent: Codable, Sendable, Equatable, Identifiable, Hashable {
    let schemaVersion: String
    let id: String
    let rawStatement: String
    let createdAt: String
    let sourceSurface: GoalIntentSourceSurface
    let userKnownContext: [GoalContextSignal]
    let privacyClass: GoalPrivacyClass
    let sourceState: GoalSourceState

    init(
        schemaVersion: String = goalIntentCompilerSchemaVersion,
        id: String,
        rawStatement: String,
        createdAt: String,
        sourceSurface: GoalIntentSourceSurface,
        userKnownContext: [GoalContextSignal] = [],
        privacyClass: GoalPrivacyClass = .localOnly,
        sourceState: GoalSourceState = .rawInput
    ) {
        self.schemaVersion = schemaVersion
        self.id = normalizedRequired(id)
        self.rawStatement = normalizedRequired(rawStatement)
        self.createdAt = normalizedRequired(createdAt)
        self.sourceSurface = sourceSurface
        self.userKnownContext = userKnownContext
        self.privacyClass = privacyClass
        self.sourceState = sourceState
    }

    var isLocalOnly: Bool {
        privacyClass == .localOnly
    }
}

struct GoalIntentMissingField: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let fieldRawValue: String?
    let reason: String
    let blocksCompilation: Bool

    init(
        id: String,
        field: MissingFieldKey? = nil,
        reason: String,
        blocksCompilation: Bool
    ) {
        self.id = normalizedRequired(id)
        self.fieldRawValue = field?.rawValue
        self.reason = normalizedRequired(reason)
        self.blocksCompilation = blocksCompilation
    }

    var field: MissingFieldKey? {
        fieldRawValue.flatMap(MissingFieldKey.init(rawValue:))
    }
}

struct GoalIntentClarificationQuestion: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let prompt: String
    let rationale: String
    let targetFieldRawValue: String?
    let severity: GoalClarificationSeverity
    let blocking: Bool
    let skipSafeDefault: String

    init(
        id: String,
        prompt: String,
        rationale: String,
        targetField: MissingFieldKey? = nil,
        severity: GoalClarificationSeverity,
        blocking: Bool,
        skipSafeDefault: String
    ) {
        self.id = normalizedRequired(id)
        self.prompt = normalizedRequired(prompt)
        self.rationale = normalizedRequired(rationale)
        self.targetFieldRawValue = targetField?.rawValue
        self.severity = severity
        self.blocking = blocking
        self.skipSafeDefault = normalizedRequired(skipSafeDefault)
    }

    var targetField: MissingFieldKey? {
        targetFieldRawValue.flatMap(MissingFieldKey.init(rawValue:))
    }
}

struct GoalIntentAssumption: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let rationale: String
    let confidenceRawValue: String
    let sourceRawValue: String
    let relatedFieldRawValue: String?
    let safeForCompilation: Bool

    init(
        id: String,
        summary: String,
        rationale: String,
        confidence: AssumptionConfidence,
        source: ContractValueSource,
        relatedField: MissingFieldKey? = nil,
        safeForCompilation: Bool
    ) {
        self.id = normalizedRequired(id)
        self.summary = normalizedRequired(summary)
        self.rationale = normalizedRequired(rationale)
        self.confidenceRawValue = confidence.rawValue
        self.sourceRawValue = source.rawValue
        self.relatedFieldRawValue = relatedField?.rawValue
        self.safeForCompilation = safeForCompilation
    }

    var confidence: AssumptionConfidence {
        AssumptionConfidence(rawValue: confidenceRawValue) ?? .medium
    }

    var source: ContractValueSource {
        ContractValueSource(rawValue: sourceRawValue) ?? .manual
    }

    var relatedField: MissingFieldKey? {
        relatedFieldRawValue.flatMap(MissingFieldKey.init(rawValue:))
    }
}

struct GoalIntentBlockedReason: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let kind: GoalIntentBlockedReasonKind
    let summary: String
    let fieldRawValue: String?
    let severity: GoalClarificationSeverity

    init(
        id: String,
        kind: GoalIntentBlockedReasonKind,
        summary: String,
        field: MissingFieldKey? = nil,
        severity: GoalClarificationSeverity = .blocking
    ) {
        self.id = normalizedRequired(id)
        self.kind = kind
        self.summary = normalizedRequired(summary)
        self.fieldRawValue = field?.rawValue
        self.severity = severity
    }

    var field: MissingFieldKey? {
        fieldRawValue.flatMap(MissingFieldKey.init(rawValue:))
    }
}

struct GoalIntentClarification: Codable, Sendable, Equatable, Hashable {
    let status: GoalIntentDayCompilerStatus
    let readinessRawValue: String
    let questions: [GoalIntentClarificationQuestion]
    let missingFields: [GoalIntentMissingField]

    init(
        status: GoalIntentDayCompilerStatus,
        readiness: PlanningReadiness,
        questions: [GoalIntentClarificationQuestion] = [],
        missingFields: [GoalIntentMissingField] = []
    ) {
        self.status = status
        self.readinessRawValue = readiness.rawValue
        self.questions = questions
        self.missingFields = missingFields
    }

    var readiness: PlanningReadiness {
        PlanningReadiness(rawValue: readinessRawValue) ?? .canPlanWithDefaults
    }
}

struct GoalIntentCapacityWindow: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let availableMinutes: Int
    let isProtected: Bool
    let reasonCodes: [GoalEnergyFitReasonCode]

    init(
        id: String,
        title: String,
        summary: String,
        availableMinutes: Int,
        isProtected: Bool,
        reasonCodes: [GoalEnergyFitReasonCode] = []
    ) {
        self.id = normalizedRequired(id)
        self.title = normalizedRequired(title)
        self.summary = normalizedRequired(summary)
        self.availableMinutes = max(0, availableMinutes)
        self.isProtected = isProtected
        self.reasonCodes = reasonCodes
    }
}

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

extension GoalDraft {
    func makeGoalIntent(
        id: String,
        rawStatement: String? = nil,
        createdAt: String,
        sourceSurface: GoalIntentSourceSurface = .goals,
        userKnownContext: [GoalContextSignal] = [],
        privacyClass: GoalPrivacyClass = .localOnly,
        sourceState: GoalSourceState = .draft
    ) -> GoalIntent {
        GoalIntent(
            id: id,
            rawStatement: rawStatement ?? title,
            createdAt: createdAt,
            sourceSurface: sourceSurface,
            userKnownContext: userKnownContext,
            privacyClass: privacyClass,
            sourceState: sourceState
        )
    }
}

extension GoalCompiledPath {
    func makeGoalIntentDayCompilerInput(
        intent: GoalIntent,
        capacityEnvelope: GoalIntentCapacityEnvelope? = nil,
        localOnly: Bool = true
    ) -> GoalIntentDayCompilerInput {
        let candidate = candidates.first
        let status = compiledStatus
        let assumptions = candidate?.assumptions.map {
            GoalIntentAssumption(
                id: $0.id,
                summary: $0.summary,
                rationale: $0.rationale,
                confidence: $0.confidence,
                source: $0.source,
                relatedField: $0.relatedField,
                safeForCompilation: $0.safeForCompilation
            )
        } ?? []
        let blockedReasons = compiledBlockedReasons
        let clarification = GoalIntentClarification(
            status: status,
            readiness: compiledReadiness(for: status),
            questions: compiledQuestions(for: status),
            missingFields: compiledMissingFields(for: status)
        )

        return GoalIntentDayCompilerInput(
            intent: intent,
            status: status,
            assumptions: assumptions,
            clarification: clarification,
            blockedReasons: blockedReasons,
            capacityEnvelope: capacityEnvelope,
            localOnly: localOnly
        )
    }

    func makeCompiledSteps(intentID: String) -> [CompiledStep] {
        guard statusForGoalIntentCompiler != .blocked, let candidate = candidates.first else {
            return []
        }

        return candidate.stages.map { stage in
            CompiledStep(
                id: "compiled-step-\(stage.id)",
                intentID: intentID,
                sourceCandidateID: candidate.id,
                sourceStageID: stage.id,
                title: stage.title,
                summary: stage.summary,
                orderIndex: stage.orderIndex,
                stepType: stepType(for: stage.kind),
                pace: pace(for: stage.kind, posture: candidate.posture),
                evidenceHint: stage.readinessHints.first ?? stage.prerequisiteHints.first,
                contextRequirements: stage.prerequisiteHints,
                isOptional: candidate.safeForStarterPlanning == false,
                isRepeatable: stage.kind == .reviewFinish,
                isExecutable: candidate.posture != .blocked,
                blockingReasonIDs: candidate.blockingReasons.map(\.id),
                assumptionIDs: candidate.assumptions.map(\.id),
                clarificationQuestionIDs: compiledQuestions(for: compiledStatus).map(\.id)
            )
        }
    }

    private var compiledStatus: GoalIntentDayCompilerStatus {
        statusForGoalIntentCompiler
    }

    private var statusForGoalIntentCompiler: GoalIntentDayCompilerStatus {
        guard safeForStarterPlanning else {
            return .blocked
        }
        if overallPosture == .blocked {
            return .blocked
        }
        if overallPosture == .provisional || uncertainty.ambiguityActive {
            return .ambiguous
        }
        return .clear
    }

    private var compiledBlockedReasons: [GoalIntentBlockedReason] {
        let candidate = candidates.first
        let reasons = candidate?.blockingReasons ?? []
        if reasons.isEmpty, statusForGoalIntentCompiler == .blocked {
            return [
                GoalIntentBlockedReason(
                    id: "blocked-\(sourceUnderstandingSchemaVersion)",
                    kind: .blockedPath,
                    summary: "The compiled path is blocked until more source truth is available.",
                    severity: .blocking
                )
            ]
        }

        return reasons.map {
            GoalIntentBlockedReason(
                id: $0.id,
                kind: $0.field == nil ? .other : .missingContext,
                summary: $0.summary,
                field: $0.field,
                severity: .blocking
            )
        }
    }

    private func compiledQuestions(for status: GoalIntentDayCompilerStatus) -> [GoalIntentClarificationQuestion] {
        let missingFields = uncertainty.missingContextFields
        if missingFields.isEmpty == false {
            return missingFields.enumerated().map { index, field in
                GoalIntentClarificationQuestion(
                    id: "question-\(field.rawValue)-\(index)",
                    prompt: "Clarify \(field.displayName).",
                    rationale: "The compiled path still carries this missing field.",
                    targetField: field,
                    severity: status == .blocked ? .blocking : .important,
                    blocking: status == .blocked,
                    skipSafeDefault: "Keep the conservative interpretation."
                )
            }
        }

        guard status == .ambiguous || uncertainty.alternateInterpretationsActive else {
            return []
        }

        return [
            GoalIntentClarificationQuestion(
                id: "question-ambiguity-\(sourceUnderstandingSchemaVersion)",
                prompt: "Clarify which interpretation should drive today.",
                rationale: "The compiled path still has active ambiguity.",
                severity: .important,
                blocking: false,
                skipSafeDefault: "Use the conservative primary interpretation."
            )
        ]
    }

    private func compiledMissingFields(for status: GoalIntentDayCompilerStatus) -> [GoalIntentMissingField] {
        let missingFields = uncertainty.missingContextFields
        guard missingFields.isEmpty == false else {
            return status == .blocked ? [
                GoalIntentMissingField(
                    id: "missing-\(sourceUnderstandingSchemaVersion)",
                    reason: "Compilation is blocked until more source truth is available.",
                    blocksCompilation: true
                )
            ] : []
        }

        return missingFields.map { field in
            GoalIntentMissingField(
                id: "missing-\(field.rawValue)",
                field: field,
                reason: "The compiled path still needs \(field.displayName).",
                blocksCompilation: status == .blocked
            )
        }
    }

    private func compiledReadiness(for status: GoalIntentDayCompilerStatus) -> PlanningReadiness {
        switch status {
        case .clear:
            return .readyForPlanning
        case .ambiguous:
            return .canPlanWithDefaults
        case .blocked:
            return .needsClarification
        }
    }

    private func stepType(for stageKind: GoalCompiledPathStageKind) -> StepType {
        switch stageKind {
        case .setup, .readiness, .firstProof, .advancement:
            return .actionUnit
        case .reviewFinish:
            return .reflectionPrompt
        }
    }

    private func pace(
        for stageKind: GoalCompiledPathStageKind,
        posture: GoalPathCompilePosture
    ) -> PlanningPace {
        switch stageKind {
        case .setup, .readiness, .advancement:
            return .untimed
        case .firstProof:
            return posture == .stronger ? .targeted : .untimed
        case .reviewFinish:
            return .ongoing
        }
    }
}

extension PlanStep {
    var compiledStep: CompiledStep {
        CompiledStep(
            id: id,
            intentID: "plan-step-\(id)",
            title: title,
            summary: summary,
            orderIndex: 0,
            stepType: type,
            pace: pace,
            targetDate: targetDate,
            repeatEveryDays: repeatEveryDays,
            evidenceHint: evidenceHint,
            contextRequirements: contextRequirements,
            isOptional: isOptional,
            isRepeatable: isRepeatable,
            isExecutable: true
        )
    }
}

extension Step {
    var compiledStep: CompiledStep {
        CompiledStep(
            id: id,
            intentID: "step-\(id)",
            sourceStageID: sectionID,
            title: title,
            summary: summary,
            orderIndex: 0,
            stepType: type,
            pace: PlanningPace(goalTempo: timing.tempo),
            targetDate: timing.dueAt ?? timing.targetBy ?? timing.suggestedNextAt,
            repeatEveryDays: timing.repeatEveryDays,
            evidenceHint: actionability.completionDefinition,
            contextRequirements: actionability.contextRequirements,
            isOptional: isOptional,
            isRepeatable: isRepeatable,
            isExecutable: state != .blocked && state != .cancelled
        )
    }
}

extension GoalIntentDayCompilerInput {
    func makeOutput(
        compiledSteps: [CompiledStep],
        compiledAt: String,
        receipts: [CompiledStepReceipt]? = nil
    ) -> GoalIntentDayCompilerOutput {
        let resolvedCompiledSteps = adjustedCompiledSteps(compiledSteps)
        let resolvedStatus = status == .blocked || resolvedCompiledSteps.isEmpty ? .blocked : status
        let resolvedReceipts = receipts ?? Self.defaultReceipts(
            intent: intent,
            compiledSteps: resolvedCompiledSteps,
            compiledAt: compiledAt,
            status: resolvedStatus,
            sourceSurface: intent.sourceSurface,
            assumptionIDs: assumptions.map(\.id),
            clarificationQuestionIDs: clarification.questions.map(\.id),
            blockedReasons: blockedReasons,
            capacityEnvelope: capacityEnvelope,
            localOnly: localOnly
        )

        return GoalIntentDayCompilerOutput(
            intent: intent,
            compiledAt: compiledAt,
            status: resolvedStatus,
            assumptions: assumptions,
            clarification: clarification,
            blockedReasons: blockedReasons,
            capacityEnvelope: capacityEnvelope,
            compiledSteps: resolvedCompiledSteps,
            receipts: resolvedReceipts,
            localOnly: localOnly
        )
    }

    private static func defaultReceipts(
        intent: GoalIntent,
        compiledSteps: [CompiledStep],
        compiledAt: String,
        status: GoalIntentDayCompilerStatus,
        sourceSurface: GoalIntentSourceSurface,
        assumptionIDs: [String],
        clarificationQuestionIDs: [String],
        blockedReasons: [GoalIntentBlockedReason],
        capacityEnvelope: GoalIntentCapacityEnvelope?,
        localOnly: Bool
    ) -> [CompiledStepReceipt] {
        if compiledSteps.isEmpty {
            let blockedSummary = blockedReasons.isEmpty
                ? "The compiler kept the output blocked to preserve local-only truth."
                : blockedReasons.map(\.summary).joined(separator: ", ")
            let capacitySummary = capacityEnvelope.map { " Capacity context: \($0.summary)" } ?? ""
            return [
                CompiledStepReceipt(
                    id: "receipt-\(intent.id)-blocked",
                    compiledStepID: "blocked",
                    intentID: intent.id,
                    generatedAt: compiledAt,
                    status: status,
                    summary: "No executable daily step was emitted.",
                    reason: "\(blockedSummary)\(capacitySummary)",
                    sourceSurface: sourceSurface,
                    assumptionIDs: assumptionIDs,
                    clarificationQuestionIDs: clarificationQuestionIDs,
                    blockedReasonIDs: blockedReasons.map(\.id),
                    localOnly: localOnly
                )
            ]
        }

        return compiledSteps.map { step in
            let capacityReason = capacityEnvelope.map { " Capacity context: \($0.summary)" } ?? ""
            return CompiledStepReceipt(
                id: "receipt-\(step.id)",
                compiledStepID: step.id,
                intentID: intent.id,
                generatedAt: compiledAt,
                status: status,
                summary: "Compiled daily step candidate \(step.title).",
                reason: step.isExecutable
                    ? "Deterministic local-first compilation.\(capacityReason)"
                    : "Step remains blocked by the compiled path.\(capacityReason)",
                sourceSurface: sourceSurface,
                assumptionIDs: step.assumptionIDs,
                clarificationQuestionIDs: step.clarificationQuestionIDs,
                blockedReasonIDs: step.blockingReasonIDs,
                localOnly: localOnly
            )
        }
    }

    private func adjustedCompiledSteps(_ compiledSteps: [CompiledStep]) -> [CompiledStep] {
        guard let capacityEnvelope else {
            return compiledSteps
        }

        if capacityEnvelope.mode == .normal {
            return compiledSteps
        }

        guard let stepLimit = capacityEnvelope.stepLimit else {
            return compiledSteps
        }

        guard stepLimit > 0 else {
            return []
        }

        return compiledSteps.prefix(stepLimit).enumerated().map { index, step in
            adjustedCompiledStep(step, capacityEnvelope: capacityEnvelope, isPrimary: index == 0)
        }
    }

    private func adjustedCompiledStep(
        _ step: CompiledStep,
        capacityEnvelope: GoalIntentCapacityEnvelope,
        isPrimary: Bool
    ) -> CompiledStep {
        let capacityReasonIDs = capacityEnvelope.localReasonIDs
        let adjustedPace: PlanningPace
        switch capacityEnvelope.mode {
        case .normal:
            adjustedPace = step.pace
        default:
            adjustedPace = .untimed
        }

        let adjustedContextRequirements = isPrimary && capacityEnvelope.mode != .normal
            ? step.contextRequirements + [capacityEnvelope.summary]
            : step.contextRequirements
        let adjustedEvidenceHint = isPrimary && capacityEnvelope.mode != .normal
            ? [step.evidenceHint, capacityEnvelope.summary].compactMap { $0 }.joined(separator: " ")
            : step.evidenceHint
        let adjustedBlockingReasonIDs = (step.blockingReasonIDs + capacityReasonIDs).removingDuplicates()
        let adjustedIsOptional = capacityEnvelope.mode == .recovery ? true : step.isOptional
        let adjustedIsExecutable = step.isExecutable && capacityEnvelope.mode != .protectedConflict

        return CompiledStep(
            schemaVersion: step.schemaVersion,
            id: step.id,
            intentID: step.intentID,
            sourceCandidateID: step.sourceCandidateID,
            sourceStageID: step.sourceStageID,
            title: step.title,
            summary: step.summary,
            orderIndex: step.orderIndex,
            stepType: step.stepType,
            pace: adjustedPace,
            targetDate: step.targetDate,
            repeatEveryDays: step.repeatEveryDays,
            evidenceHint: adjustedEvidenceHint,
            contextRequirements: adjustedContextRequirements,
            isOptional: adjustedIsOptional,
            isRepeatable: step.isRepeatable,
            isExecutable: adjustedIsExecutable,
            blockingReasonIDs: adjustedBlockingReasonIDs,
            assumptionIDs: step.assumptionIDs,
            clarificationQuestionIDs: step.clarificationQuestionIDs
        )
    }
}

extension MissingFieldKey {
    var displayName: String {
        switch self {
        case .goalSubject:
            return "goal subject"
        case .goalShape:
            return "goal shape"
        case .executorIdentity:
            return "executor identity"
        case .supportScope:
            return "support scope"
        case .successDefinition:
            return "success definition"
        case .timeHorizon:
            return "time horizon"
        }
    }
}

private func normalizedRequired(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
}

private func normalizedOptional(_ value: String?) -> String? {
    guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
          trimmed.isEmpty == false else {
        return nil
    }
    return trimmed
}

private extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
