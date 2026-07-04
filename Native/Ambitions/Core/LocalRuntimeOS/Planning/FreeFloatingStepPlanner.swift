import Foundation

struct FreeFloatingStepPlan: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let generatedAt: String
    let planningGraph: PlanningGraph
    let candidateField: StepCandidateField
    let selectedCandidate: StepCandidate?
    let repairTrace: PlanRepairTrace
    let runtimeTrace: PlanningRuntimeTrace
    let localOnly: Bool
}

struct FreeFloatingStepPlanner: Sendable {
    private let goalPathPlanner: GoalPathPlanner

    init(goalPathPlanner: GoalPathPlanner = GoalPathPlanner()) {
        self.goalPathPlanner = goalPathPlanner
    }

    func plan(
        title: String,
        summary: String? = nil,
        generatedAt: String,
        estimatedMinutes: Int = 10,
        contextRequirements: [String] = [],
        localOnly: Bool = true
    ) -> FreeFloatingStepPlan {
        let stepID = CandidateSource.stableIdentifier(
            prefix: "free-floating-step",
            components: [title, summary ?? "no-summary", generatedAt]
        )
        let step = PlanStep(
            id: stepID,
            title: title,
            summary: summary,
            type: .actionUnit,
            pace: .untimed,
            repeatEveryDays: max(1, estimatedMinutes),
            evidenceHint: summary ?? "\(title) has a visible completion signal.",
            contextRequirements: contextRequirements
        )
        let graph = PlanningGraph.make(
            goalID: nil,
            generatedAt: generatedAt,
            steps: [step],
            localOnly: localOnly
        )
        let intent = GoalIntent(
            id: CandidateSource.stableIdentifier(prefix: "free-floating.intent", components: [stepID, generatedAt]),
            rawStatement: title,
            createdAt: generatedAt,
            sourceSurface: .manual,
            privacyClass: .localOnly,
            sourceState: .plan
        )
        let compilerOutput = GoalIntentDayCompilerOutput(
            intent: intent,
            compiledAt: generatedAt,
            status: .clear,
            clarification: GoalIntentClarification(
                status: .clear,
                readiness: .canPlanWithDefaults
            ),
            compiledSteps: [
                CompiledStep(
                    id: step.id,
                    intentID: intent.id,
                    title: step.title,
                    summary: step.summary,
                    orderIndex: 0,
                    stepType: step.type,
                    pace: step.pace,
                    repeatEveryDays: step.repeatEveryDays,
                    evidenceHint: step.evidenceHint,
                    contextRequirements: step.contextRequirements,
                    isExecutable: true
                )
            ],
            localOnly: localOnly
        )
        let context = CandidateGenerationContext(
            compilerOutput: compilerOutput,
            generatedAt: generatedAt,
            candidateLimit: StepCandidateKind.allCases.count,
            localOnly: localOnly
        )
        let plan = goalPathPlanner.plan(
            context: context,
            graph: graph
        )
        let trace = PlanningRuntimeTrace.make(
            owner: "FreeFloatingStepPlanner",
            generatedAt: generatedAt,
            components: [stepID, plan.candidateField.id, plan.repairTrace.id],
            localOnly: localOnly
        )
        return FreeFloatingStepPlan(
            id: CandidateSource.stableIdentifier(prefix: "free-floating-step-plan", components: [stepID, plan.candidateField.id, trace.checksum]),
            generatedAt: generatedAt,
            planningGraph: plan.planningGraph,
            candidateField: plan.candidateField,
            selectedCandidate: plan.selectedCandidate,
            repairTrace: plan.repairTrace,
            runtimeTrace: trace,
            localOnly: localOnly && plan.localOnly
        )
    }
}
