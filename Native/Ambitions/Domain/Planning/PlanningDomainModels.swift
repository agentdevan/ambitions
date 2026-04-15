import Foundation

enum PlanningPace: String, Codable, Sendable, CaseIterable {
    case untimed
    case targeted
    case deadline
    case ongoing

    var goalTempo: GoalTempo {
        switch self {
        case .untimed:
            return .untimed
        case .targeted:
            return .targetWindow
        case .deadline:
            return .deadlineBased
        case .ongoing:
            return .ongoing
        }
    }

    var defaultTimingType: TimingType {
        switch self {
        case .untimed:
            return .logWhenDone
        case .targeted:
            return .targetBy
        case .deadline:
            return .dueAt
        case .ongoing:
            return .repeatWithinWindow
        }
    }

    var defaultReviewCadenceDays: Int {
        switch self {
        case .untimed:
            return 7
        case .targeted:
            return 7
        case .deadline:
            return 5
        case .ongoing:
            return 7
        }
    }

    init(goalTempo: GoalTempo) {
        switch goalTempo {
        case .untimed:
            self = .untimed
        case .targetWindow:
            self = .targeted
        case .deadlineBased:
            self = .deadline
        case .ongoing:
            self = .ongoing
        }
    }
}

struct GoalBlueprint: Codable, Sendable, Equatable {
    let title: String
    let summary: String?
    let mode: GoalMode
    let relationshipKind: GoalRelationshipKind
    let actor: GoalActor
    let parentGoalID: String?
    let tags: [String]
    let pace: PlanningPace
    let targetDate: String?
    let repeatEveryDays: Int?
    let source: EvidenceSource

    init(
        title: String,
        summary: String? = nil,
        mode: GoalMode = .project,
        relationshipKind: GoalRelationshipKind = .independent,
        actor: GoalActor = .localOwner,
        parentGoalID: String? = nil,
        tags: [String] = [],
        pace: PlanningPace = .untimed,
        targetDate: String? = nil,
        repeatEveryDays: Int? = nil,
        source: EvidenceSource = .manual
    ) {
        self.title = title
        self.summary = summary
        self.mode = mode
        self.relationshipKind = relationshipKind
        self.actor = actor
        self.parentGoalID = parentGoalID
        self.tags = tags
        self.pace = pace
        self.targetDate = targetDate
        self.repeatEveryDays = repeatEveryDays
        self.source = source
    }

    var timing: GoalTiming {
        GoalTiming(
            tempo: pace.goalTempo,
            timingType: pace.defaultTimingType,
            startsOn: nil,
            dueAt: pace == .deadline ? targetDate : nil,
            targetBy: pace == .targeted ? targetDate : nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: pace == .ongoing ? (repeatEveryDays ?? 7) : nil,
            progressReviewCadenceDays: pace.defaultReviewCadenceDays
        )
    }

    // Compatibility note: current repositories persist GoalDraft and GoalPlan,
    // so GoalBlueprint intentionally compiles into the existing draft contract.
    func makeDraft(
        schemaVersion: String = goalEngineSchemaVersion,
        planningStrategy: PlanningStrategy? = nil,
        progressStrategy: ProgressStrategy? = nil
    ) -> GoalDraft {
        GoalDraft(
            schemaVersion: schemaVersion,
            source: source,
            title: title,
            summary: summary,
            mode: mode,
            relationshipKind: relationshipKind,
            actor: actor,
            parentGoalID: parentGoalID,
            tags: tags,
            timing: timing,
            planningStrategy: planningStrategy ?? .blueprintDefault(for: mode, pace: pace),
            progressStrategy: progressStrategy ?? .blueprintDefault(for: mode, pace: pace)
        )
    }
}

struct PlanStep: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let summary: String?
    let type: StepType
    let pace: PlanningPace
    let targetDate: String?
    let repeatEveryDays: Int?
    let evidenceHint: String?
    let contextRequirements: [String]
    let isOptional: Bool
    let isRepeatable: Bool

    init(
        id: String,
        title: String,
        summary: String? = nil,
        type: StepType = .actionUnit,
        pace: PlanningPace = .untimed,
        targetDate: String? = nil,
        repeatEveryDays: Int? = nil,
        evidenceHint: String? = nil,
        contextRequirements: [String] = [],
        isOptional: Bool = false,
        isRepeatable: Bool = false
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.type = type
        self.pace = pace
        self.targetDate = targetDate
        self.repeatEveryDays = repeatEveryDays
        self.evidenceHint = evidenceHint
        self.contextRequirements = contextRequirements
        self.isOptional = isOptional
        self.isRepeatable = isRepeatable
    }

    var timing: GoalTiming {
        GoalTiming(
            tempo: pace.goalTempo,
            timingType: pace.defaultTimingType,
            startsOn: nil,
            dueAt: pace == .deadline ? targetDate : nil,
            targetBy: pace == .targeted ? targetDate : nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: pace == .ongoing ? (repeatEveryDays ?? 7) : nil,
            progressReviewCadenceDays: pace.defaultReviewCadenceDays
        )
    }

    // Compatibility note: repositories already round-trip Step snapshots, so
    // PlanStep maps directly into Step instead of adding new persistence types.
    func makeStep(
        sectionID: String,
        owner: GoalActor = .localOwner,
        state: StepLifecycleState = .planned,
        dependencyStepIDs: [String] = []
    ) -> Step {
        let fallback = summary ?? "Do the smallest visible version of \(title.lowercased())."
        let completion = evidenceHint ?? summary ?? "\(title) is visibly complete."

        return Step(
            id: id,
            sectionID: sectionID,
            title: title,
            summary: summary,
            type: type,
            state: state,
            owner: owner,
            timing: timing,
            dependencyStepIDs: dependencyStepIDs,
            isOptional: isOptional,
            isRepeatable: isRepeatable || pace == .ongoing,
            evidenceRequired: true,
            successSignals: [completion],
            actionability: StepActionability(
                action: title,
                completionDefinition: completion,
                evidenceOfCompletion: [completion],
                fallbackMicroStep: fallback,
                contextRequirements: contextRequirements
            )
        )
    }
}

extension GoalActor {
    static let localOwner = GoalActor(
        actorID: ExecutionOwnership.`self`.rawValue,
        displayName: "You",
        ownership: .self,
        roleLabel: "Primary owner",
        isPrimary: true
    )
}

private extension PlanningStrategy {
    static func blueprintDefault(for mode: GoalMode, pace: PlanningPace) -> PlanningStrategy {
        switch mode {
        case .learning:
            return PlanningStrategy(
                strategyKind: .adaptive,
                allowParallelSteps: true,
                maxActiveSteps: 4,
                preferredSectionOrder: [.overview, .activeSteps, .review],
                defaultStepType: .learningCheckpoint,
                autoGenerateReviewSection: true,
                preferShortSteps: true,
                revisitCadenceDays: pace.defaultReviewCadenceDays
            )
        case .exploration:
            return PlanningStrategy(
                strategyKind: .exploratory,
                allowParallelSteps: true,
                maxActiveSteps: 4,
                preferredSectionOrder: [.overview, .activeSteps, .review],
                defaultStepType: .explorationExperiment,
                autoGenerateReviewSection: true,
                preferShortSteps: true,
                revisitCadenceDays: pace.defaultReviewCadenceDays
            )
        case .maintenance, .habit:
            return PlanningStrategy(
                strategyKind: .cadence,
                allowParallelSteps: true,
                maxActiveSteps: 3,
                preferredSectionOrder: [.overview, .activeSteps, .review],
                defaultStepType: .recurringRoutine,
                autoGenerateReviewSection: true,
                preferShortSteps: true,
                revisitCadenceDays: pace.defaultReviewCadenceDays
            )
        case .delegatedSupport:
            return PlanningStrategy(
                strategyKind: .supportive,
                allowParallelSteps: true,
                maxActiveSteps: 3,
                preferredSectionOrder: [.supportingWork, .activeSteps, .review],
                defaultStepType: .supportAction,
                autoGenerateReviewSection: true,
                preferShortSteps: true,
                revisitCadenceDays: pace.defaultReviewCadenceDays
            )
        case .recovery:
            return PlanningStrategy(
                strategyKind: .adaptive,
                allowParallelSteps: false,
                maxActiveSteps: 2,
                preferredSectionOrder: [.overview, .activeSteps, .review],
                defaultStepType: .observationPrompt,
                autoGenerateReviewSection: true,
                preferShortSteps: true,
                revisitCadenceDays: pace.defaultReviewCadenceDays
            )
        case .achievement, .project:
            return PlanningStrategy(
                strategyKind: pace == .deadline ? .sequential : .adaptive,
                allowParallelSteps: mode == .project,
                maxActiveSteps: mode == .project ? 4 : 3,
                preferredSectionOrder: [.overview, .activeSteps, .review],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: true,
                preferShortSteps: pace != .deadline,
                revisitCadenceDays: pace.defaultReviewCadenceDays
            )
        }
    }
}

private extension ProgressStrategy {
    static func blueprintDefault(for mode: GoalMode, pace: PlanningPace) -> ProgressStrategy {
        switch mode {
        case .learning:
            return ProgressStrategy(metricKind: .evidenceCount, rollupMethod: .weightedRatio, targetStepCount: 4, targetEvidenceCount: 8, targetMinutes: 240, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .exploration:
            return ProgressStrategy(metricKind: .observationLog, rollupMethod: .sum, targetStepCount: 4, targetEvidenceCount: 5, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .maintenance, .habit:
            return ProgressStrategy(metricKind: .streak, rollupMethod: .streakLength, targetStepCount: nil, targetEvidenceCount: 5, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .delegatedSupport:
            return ProgressStrategy(metricKind: .evidenceCount, rollupMethod: .latest, targetStepCount: 3, targetEvidenceCount: 4, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: true, countsSupportGoals: true)
        case .recovery:
            return ProgressStrategy(metricKind: .confidenceGain, rollupMethod: .latest, targetStepCount: 3, targetEvidenceCount: 6, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: true)
        case .achievement, .project:
            return ProgressStrategy(
                metricKind: pace == .deadline ? .stepCompletion : .timeInvested,
                rollupMethod: .ratio,
                targetStepCount: mode == .project ? 6 : 4,
                targetEvidenceCount: nil,
                targetMinutes: pace == .deadline ? 300 : 240,
                supportsUntimedProgress: pace != .deadline,
                countsChildGoals: true,
                countsSupportGoals: true
            )
        }
    }
}
