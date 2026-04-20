import Foundation

enum RuntimeGoalIntelligenceError: Error, Equatable {
    case notFound
    case notActionable
}

struct RuntimeGoalIntelligenceRequest: Sendable, Equatable {
    let target: GoalRouteTarget
    let primaryStepID: String?
    let includeWhyNow: Bool

    init(
        target: GoalRouteTarget,
        primaryStepID: String? = nil,
        includeWhyNow: Bool = false
    ) {
        self.target = target
        self.primaryStepID = primaryStepID
        self.includeWhyNow = includeWhyNow
    }
}

struct RuntimeGoalIntelligenceContext: Sendable {
    let goalID: String?
    let draftID: String?
    let primaryStepID: String?
    let metadata: GoalOrchestrationMetadata
    let applicableSignals: GoalTeachingApplicableSet?
    let explainability: GoalExplainabilityState
    let whyNow: WhyNowExplanationMetadata?
}

protocol RuntimeGoalIntelligenceServicing: Sendable {
    func loadContext(_ request: RuntimeGoalIntelligenceRequest, now: Date) async throws -> RuntimeGoalIntelligenceContext?
    func captureCorrection(
        target: GoalRouteTarget,
        control: GoalCorrectionControlState,
        now: Date
    ) async throws -> GoalTeachingSignal
}

struct RepositoryBackedRuntimeGoalIntelligenceService: RuntimeGoalIntelligenceServicing {
    let repositories: AppRepositories
    let explainabilityProjector: any GoalExplainabilityProjecting
    let teachingReader: any GoalTeachingSignalReading
    let teachingCaptureService: any GoalTeachingSignalCapturing
    let learningService: LearningAnticipationService

    init(
        repositories: AppRepositories,
        explainabilityProjector: any GoalExplainabilityProjecting = DefaultGoalExplainabilityProjector(),
        teachingReader: (any GoalTeachingSignalReading)? = nil,
        teachingCaptureService: (any GoalTeachingSignalCapturing)? = nil,
        learningService: LearningAnticipationService = LearningAnticipationService()
    ) {
        let sharedTeachingService = DefaultGoalTeachingSignalService(repository: repositories.teaching)
        self.repositories = repositories
        self.explainabilityProjector = explainabilityProjector
        self.teachingReader = teachingReader ?? sharedTeachingService
        self.teachingCaptureService = teachingCaptureService ?? sharedTeachingService
        self.learningService = learningService
    }

    func loadContext(_ request: RuntimeGoalIntelligenceRequest, now: Date) async throws -> RuntimeGoalIntelligenceContext? {
        guard let resolved = try await resolve(target: request.target) else {
            return nil
        }
        guard let metadata = resolved.draft?.metadata else {
            return nil
        }

        let goalID = resolved.goal?.id ?? resolved.draft?.plannedGoalID ?? metadata.context.goalID
        let whyNow = request.includeWhyNow
            ? buildWhyNow(goal: resolved.goal, stepID: request.primaryStepID, evidence: resolved.evidence, feedback: resolved.feedback, now: now)
            : nil
        let applicableSignals: GoalTeachingApplicableSet?
        if let goalID {
            applicableSignals = try await teachingReader.applicableSignals(goalID: goalID, metadata: metadata)
        } else {
            applicableSignals = nil
        }
        let explainability = explainabilityProjector.makeState(
            metadata: metadata,
            applicableSignals: applicableSignals,
            primaryStepID: request.primaryStepID,
            whyNow: whyNow
        )

        return RuntimeGoalIntelligenceContext(
            goalID: goalID,
            draftID: resolved.draft?.id,
            primaryStepID: request.primaryStepID,
            metadata: metadata,
            applicableSignals: applicableSignals,
            explainability: explainability,
            whyNow: whyNow
        )
    }

    func captureCorrection(
        target: GoalRouteTarget,
        control: GoalCorrectionControlState,
        now: Date
    ) async throws -> GoalTeachingSignal {
        guard let context = try await loadContext(
            RuntimeGoalIntelligenceRequest(
                target: target,
                primaryStepID: nil,
                includeWhyNow: false
            ),
            now: now
        ) else {
            throw RuntimeGoalIntelligenceError.notFound
        }
        guard let goalID = context.goalID else {
            throw RuntimeGoalIntelligenceError.notActionable
        }

        return try await teachingCaptureService.capture(
            GoalTeachingCaptureRequest(
                goalID: goalID,
                capturedAt: DomainTimestamp.string(from: now),
                kind: control.teachingSignalKind,
                payload: control.payload,
                target: control.target,
                userNote: control.subtitle
            ),
            metadata: context.metadata
        )
    }
}

private extension RepositoryBackedRuntimeGoalIntelligenceService {
    struct ResolvedGoalContext {
        let goal: Goal?
        let draft: PersistedGoalDraft?
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
    }

    func resolve(target: GoalRouteTarget) async throws -> ResolvedGoalContext? {
        let explicitDraft: PersistedGoalDraft?
        if let draftID = target.draftID {
            explicitDraft = try await repositories.drafts.draft(id: draftID)
        } else {
            explicitDraft = nil
        }

        let explicitGoal: Goal?
        if let goalID = target.goalID {
            explicitGoal = try await repositories.goals.goal(id: goalID)
        } else {
            explicitGoal = nil
        }

        let draft: PersistedGoalDraft?
        if let explicitDraft {
            draft = explicitDraft
        } else if let goalID = target.goalID {
            draft = try await repositories.drafts.listDrafts().first(where: { $0.plannedGoalID == goalID })
        } else {
            draft = nil
        }

        let resolvedGoalID = explicitGoal?.id ?? target.goalID ?? draft?.plannedGoalID
        let goal: Goal?
        if let explicitGoal {
            goal = explicitGoal
        } else if let resolvedGoalID {
            goal = try await repositories.goals.goal(id: resolvedGoalID)
        } else {
            goal = nil
        }
        guard goal != nil || draft != nil else {
            return nil
        }

        let evidence = try await repositories.evidence.listEvidence(goalID: resolvedGoalID)
        let feedback = try await repositories.feedback.listEvents(goalID: resolvedGoalID)
        return ResolvedGoalContext(goal: goal, draft: draft, evidence: evidence, feedback: feedback)
    }

    func buildWhyNow(
        goal: Goal?,
        stepID: String?,
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        now: Date
    ) -> WhyNowExplanationMetadata? {
        guard let goal, let stepID else { return nil }
        guard let step = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }) else {
            return nil
        }
        let snapshot = learningService.buildSnapshot(
            goals: [goal],
            evidence: evidence,
            feedback: feedback,
            now: now
        )
        return learningService.learnedStepInsight(
            goal: goal,
            step: step,
            snapshot: snapshot,
            now: now
        ).whyNow
    }
}
