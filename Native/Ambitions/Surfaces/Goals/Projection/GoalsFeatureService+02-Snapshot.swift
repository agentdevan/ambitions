import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let captures: [Capture]
        let goalThreadHierarchies: [AmbitionGraphGoalThreadHierarchy]
        let appState: AppStateSnapshot
    }


    struct DetailContext {
        let target: GoalRouteTarget
        let goal: Goal?
        let draft: PersistedGoalDraft?
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]

        var primaryStep: Step? {
            if let goal {
                return goal.plan?.sections
                    .flatMap(\.steps)
                    .first(where: { $0.state != .completed && $0.state != .cancelled })
            }

            return draft?.stagedPlan?.sections
                .flatMap(\.steps)
                .first(where: { $0.state != .completed && $0.state != .cancelled })
        }

        var actorName: String {
            goal?.actor.displayName ?? draft?.draft.actor.displayName ?? "someone else"
        }

        var supportModeActive: Bool {
            if goal?.mode == .delegatedSupport || draft?.draft.mode == .delegatedSupport {
                return true
            }
            if goal?.relationshipKind == .support || draft?.draft.relationshipKind == .support {
                return true
            }
            return goal?.actor.ownership != .self || draft?.draft.actor.ownership != .self
        }
    }


    func goal(
        from draft: GoalDraft,
        plan: GoalPlan,
        id: String,
        createdAt: String,
        updatedAt: String
    ) -> Goal {
        Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: createdAt,
            updatedAt: updatedAt,
            state: .active,
            title: draft.title,
            summary: draft.summary,
            mode: draft.mode,
            relationshipKind: draft.relationshipKind,
            actor: draft.actor,
            parentGoalID: draft.parentGoalID,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: draft.tags,
            timing: draft.timing,
            planningStrategy: draft.planningStrategy,
            progressStrategy: draft.progressStrategy,
            plan: plan,
            lifeGraph: draft.lifeGraph
        )
    }


    func storedDraft(
        id: String,
        createdAt: String,
        updatedAt: String,
        draft: GoalDraft,
        clarification: GoalOrchestrationClarification? = nil,
        stagedPlan: GoalPlan?,
        assumptions: [PlanAssumption],
        blockers: [GoalPlanningBlocker],
        metadata: GoalOrchestrationMetadata?,
        plannedGoalID: String?,
        resultKind: GoalOrchestrationResultKind
    ) -> PersistedGoalDraft {
        PersistedGoalDraft(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            draft: draft,
            classification: nil,
            clarification: clarification,
            stagedPlan: stagedPlan,
            assumptions: assumptions,
            blockers: blockers,
            metadata: metadata,
            plannedGoalID: plannedGoalID,
            latestResultKind: resultKind
        )
    }


    func blueprint(from draft: GoalDraft) -> GoalBlueprint {
        GoalBlueprint(
            title: draft.title,
            summary: draft.summary,
            mode: draft.mode,
            relationshipKind: draft.relationshipKind,
            actor: draft.actor,
            parentGoalID: draft.parentGoalID,
            tags: draft.tags,
            pace: PlanningPace(goalTempo: draft.timing.tempo),
            targetDate: draft.timing.dueAt ?? draft.timing.targetBy ?? draft.timing.windowEnd,
            repeatEveryDays: draft.timing.repeatEveryDays,
            source: draft.source,
            lifeGraph: draft.lifeGraph
        )
    }


    func makeInitialPlan(goalID: String, seed: DeterministicGoalPlanSeed, generatedAt: String) -> GoalPlan {
        let planID = "plan-\(goalID)"
        let sectionID = "section-\(goalID)-active"
        let steps = seed.steps.enumerated().map { index, template in
            template.makeStep(
                sectionID: sectionID,
                owner: seed.blueprint.actor,
                dependencyStepIDs: index == 0 ? [] : [goalScopedStepID(goalID: goalID, templateID: seed.steps[index - 1].id)]
            )
        }.enumerated().map { index, step in
            Step(
                id: goalScopedStepID(goalID: goalID, templateID: seed.steps[index].id),
                sectionID: step.sectionID,
                title: step.title,
                summary: step.summary,
                type: step.type,
                state: step.state,
                owner: step.owner,
                timing: step.timing,
                dependencyStepIDs: step.dependencyStepIDs,
                isOptional: step.isOptional,
                isRepeatable: step.isRepeatable,
                evidenceRequired: step.evidenceRequired,
                successSignals: step.successSignals,
                actionability: step.actionability
            )
        }

        let section = PlanSection(
            id: sectionID,
            goalID: goalID,
            title: "Initial micro-plan",
            summary: "Deterministic local first-pass planning.",
            kind: .activeSteps,
            orderIndex: 0,
            steps: steps
        )
        let provisional = GoalPlan(
            id: planID,
            goalID: goalID,
            version: goalEnginePlanVersion,
            generatedAt: generatedAt,
            summary: "Three conservative first steps generated locally.",
            strategy: seed.blueprint.makeDraft().planningStrategy,
            sections: [section],
            assumptions: [],
            lint: PlanLintResult(goalID: goalID, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        )

        return GoalPlan(
            id: provisional.id,
            goalID: provisional.goalID,
            version: provisional.version,
            generatedAt: provisional.generatedAt,
            summary: provisional.summary,
            strategy: provisional.strategy,
            sections: provisional.sections,
            assumptions: provisional.assumptions,
            lint: GoalContractValidator.lint(plan: provisional)
        )
    }


    func goalScopedStepID(goalID: String, templateID: String) -> String {
        "\(goalID)-\(templateID)"
    }


    func saveGoalCreation(goal: Goal?, draft: PersistedGoalDraft, now: Date) async throws -> AppUnitOfWorkReceipt? {
        guard let unitOfWork = repositories.goalCreationUnitOfWork else {
            if let goal {
                try await repositories.goals.saveGoals([goal])
            }
            try await repositories.drafts.saveDrafts([draft])
            return nil
        }

        let result = try await unitOfWork.saveGoalCreation(
            GoalCreationUnitOfWorkPayload(goal: goal, draft: draft),
            id: "goal-creation.\(goal?.id ?? "draft-only").\(draft.id)",
            timestampProvider: { DomainTimestamp.string(from: now) }
        )
        return result.receipt
    }


    func saveClarificationMaterialization(goal: Goal?, draft: PersistedGoalDraft, now: Date) async throws -> AppUnitOfWorkReceipt? {
        guard let unitOfWork = repositories.goalCreationUnitOfWork else {
            if let goal {
                try await repositories.goals.saveGoals([goal])
            }
            try await repositories.drafts.saveDrafts([draft])
            return nil
        }

        let result = try await unitOfWork.saveGoalCreation(
            GoalCreationUnitOfWorkPayload(goal: goal, draft: draft),
            id: "goal-materialization.\(goal?.id ?? "draft-only").\(draft.id)",
            timestampProvider: { DomainTimestamp.string(from: now) }
        )
        return result.receipt
    }


    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let captures = repositories.captures.listCaptures()
        async let appState = repositories.appState.loadState()

        let loadedGoals = try await goals
        return try await Snapshot(
            goals: loadedGoals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures,
            goalThreadHierarchies: makeGoalThreadHierarchies(from: loadedGoals),
            appState: appState
        )
    }


    func makeGoalThreadHierarchies(from goals: [Goal]) -> [AmbitionGraphGoalThreadHierarchy] {
        goals.compactMap { goal in
            guard let lifeAreaID = LifeGraphResolver.primaryDomain(for: goal).map(\.rawValue) else {
                return nil
            }
            let pathSummary = LifeGraphResolver.pathStateSummary(for: goal)
            let activeThreadName = activeStageTitle(for: pathSummary)
                ?? nextMilestoneTitle(for: pathSummary)
                ?? goal.title
            let ambition = Ambition(
                id: "goal.\(goal.id).ambition",
                title: goal.title,
                identityStatement: goal.summary ?? goal.title,
                lifeAreaID: lifeAreaID,
                desiredOutcome: goal.summary ?? goal.title,
                desiredProofDescription: "Progress remains attached to this goal thread.",
                activeGoalThreadID: "goal.\(goal.id).thread",
                activeCommitmentID: nil,
                knownConstraintIDs: [],
                recoveryPolicy: "Keep the smallest useful continuation visible.",
                createdAt: goal.createdAt,
                updatedAt: goal.updatedAt
            )
            let thread = GoalThread(
                id: "goal.\(goal.id).thread",
                ambitionID: ambition.id,
                lifeAreaID: lifeAreaID,
                name: activeThreadName,
                goalIDs: [goal.id],
                isActive: goal.state == .active,
                createdAt: goal.createdAt,
                updatedAt: goal.updatedAt
            )
            return AmbitionGraphGoalThreadHierarchy(goalThread: thread, ambition: ambition)
        }
    }


    func makeDetail(target: GoalRouteTarget, snapshot: Snapshot) async throws -> GoalDetailPresentation {
        let context = try resolveDetailContext(target: target, snapshot: snapshot)
        let applicableSignals = try await explainabilitySignals(for: context)
        let runtimeIntelligenceContext = try await goalIntelligenceContext(
            for: context,
            primaryStepID: context.primaryStep?.id,
            includeWhyNow: true,
            now: .now
        )

        if let goalID = context.goal?.id {
            var appState = snapshot.appState
            if appState.lastOpenedGoalID != goalID {
                appState.lastOpenedGoalID = goalID
                try await repositories.appState.saveState(appState)
            }
        }

        return buildDetailPresentation(
            from: context,
            appState: snapshot.appState,
            priorityOrder: normalizedPriorityOrder(snapshot: snapshot),
            applicableSignals: applicableSignals,
            runtimeIntelligenceContext: runtimeIntelligenceContext
        )
    }
}
