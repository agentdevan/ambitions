import Foundation

struct GoalPathPlan: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalID: String
    let generatedAt: String
    let planningGraph: PlanningGraph
    let candidateField: StepCandidateField
    let selectedCandidate: StepCandidate?
    let dependencyResolution: DependencyResolution
    let progressPreservation: ProgressPreservationReport
    let repairTrace: PlanRepairTrace
    let runtimeTrace: PlanningEngineRuntimeTrace
    let localOnly: Bool

    var isReplayReady: Bool {
        localOnly &&
            runtimeTrace.satisfiesCommandEventProjectionReceiptReplay &&
            planningGraph.runtimeTrace.satisfiesCommandEventProjectionReceiptReplay &&
            dependencyResolution.runtimeTrace.satisfiesCommandEventProjectionReceiptReplay &&
            progressPreservation.runtimeTrace.satisfiesCommandEventProjectionReceiptReplay &&
            repairTrace.runtimeTrace.satisfiesCommandEventProjectionReceiptReplay
    }
}

struct GoalPathPlanner: Sendable {
    private let candidateGenerator: StepCandidateFieldGenerator
    private let dependencyResolver: DependencyResolver
    private let preservationEngine: ProgressPreservationEngine
    private let repairEngine: PlanRepairEngine

    init(
        candidateGenerator: StepCandidateFieldGenerator = StepCandidateFieldGenerator(),
        dependencyResolver: DependencyResolver = DependencyResolver(),
        preservationEngine: ProgressPreservationEngine = ProgressPreservationEngine(),
        repairEngine: PlanRepairEngine = PlanRepairEngine()
    ) {
        self.candidateGenerator = candidateGenerator
        self.dependencyResolver = dependencyResolver
        self.preservationEngine = preservationEngine
        self.repairEngine = repairEngine
    }

    func plan(
        goalID: String,
        title: String,
        steps: [PlanStep],
        generatedAt: String,
        deadlineTargetDate: String? = nil,
        completedStepIDs: [String] = [],
        proofBearingStepIDs: [String] = [],
        activeStepIDs: [String] = [],
        rejectionHistory: [StepCandidateRejectionRecord] = [],
        localOnly: Bool = true
    ) -> GoalPathPlan {
        let graph = PlanningGraph.make(
            goalID: goalID,
            generatedAt: generatedAt,
            steps: steps,
            localOnly: localOnly
        )
        let compilerOutput = compilerOutput(
            goalID: goalID,
            title: title,
            steps: steps,
            generatedAt: generatedAt,
            localOnly: localOnly
        )
        let context = CandidateGenerationContext(
            goalID: goalID,
            deadlineTargetDate: deadlineTargetDate,
            compilerOutput: compilerOutput,
            rejectionHistory: rejectionHistory,
            generatedAt: generatedAt,
            candidateLimit: max(steps.count * StepCandidateKind.allCases.count, 1),
            localOnly: localOnly
        )
        return plan(context: context, graph: graph)
    }

    func plan(
        context: CandidateGenerationContext,
        graph: PlanningGraph
    ) -> GoalPathPlan {
        let field = candidateGenerator.generate(context)
        let dependencyResolution = dependencyResolver.resolve(graph)
        let preservation = preservationEngine.preserve(graph: graph)
        let repair = repairEngine.repair(
            field: field,
            dependencyResolution: dependencyResolution,
            preservationReport: preservation
        )
        let goalID = context.goalID ?? graph.goalID ?? "unscoped-goal"
        let trace = PlanningEngineRuntimeTrace.make(
            owner: "GoalPathPlanner",
            generatedAt: context.generatedAt,
            components: [
                goalID,
                graph.id,
                field.id,
                dependencyResolution.runtimeTrace.id,
                preservation.runtimeTrace.id,
                repair.runtimeTrace.id
            ],
            localOnly: context.localOnly && graph.localOnly && field.localOnly
        )
        return GoalPathPlan(
            id: CandidateSource.stableIdentifier(prefix: "goal-path-plan", components: [goalID, graph.id, field.id, repair.id]),
            goalID: goalID,
            generatedAt: context.generatedAt,
            planningGraph: graph,
            candidateField: field,
            selectedCandidate: field.selectedCandidate,
            dependencyResolution: dependencyResolution,
            progressPreservation: preservation,
            repairTrace: repair,
            runtimeTrace: trace,
            localOnly: context.localOnly && graph.localOnly && field.localOnly
        )
    }

    private func compilerOutput(
        goalID: String,
        title: String,
        steps: [PlanStep],
        generatedAt: String,
        localOnly: Bool
    ) -> GoalIntentDayCompilerOutput {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let intent = GoalIntent(
            id: CandidateSource.stableIdentifier(prefix: "goal-path-planner.intent", components: [goalID, normalizedTitle, generatedAt]),
            rawStatement: normalizedTitle.isEmpty ? goalID : normalizedTitle,
            createdAt: generatedAt,
            sourceSurface: .goals,
            privacyClass: .localOnly,
            sourceState: .plan
        )
        let compiledSteps = steps.enumerated().map { index, step in
            CompiledStep(
                id: step.id,
                intentID: intent.id,
                title: step.title,
                summary: step.summary,
                orderIndex: index,
                stepType: step.type,
                pace: step.pace,
                targetDate: step.targetDate,
                repeatEveryDays: step.repeatEveryDays,
                evidenceHint: step.evidenceHint,
                contextRequirements: step.contextRequirements,
                isOptional: step.isOptional,
                isRepeatable: step.isRepeatable,
                isExecutable: true
            )
        }
        return GoalIntentDayCompilerOutput(
            intent: intent,
            compiledAt: generatedAt,
            status: compiledSteps.isEmpty ? .blocked : .clear,
            clarification: GoalIntentClarification(
                status: compiledSteps.isEmpty ? .blocked : .clear,
                readiness: compiledSteps.isEmpty ? .needsClarification : .canPlanWithDefaults
            ),
            compiledSteps: compiledSteps,
            localOnly: localOnly
        )
    }
}
