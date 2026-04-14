import { buildGoalDraftFromIntake } from "../../domain/models/goalEngineIntake";
import { GoalPlanner } from "../../domain/models/goalEnginePlanner";
import { GoalEngineOrchestrator } from "./GoalEngineOrchestrator";
import { findGoalEngineOrchestratorFixture } from "./goalEngineOrchestratorFixtures";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function runGoalEngineOrchestratorTests(): void {
  const timed = findGoalEngineOrchestratorFixture("clear-timed-self-goal")?.result;
  assert(timed?.kind === "planned", "clear timed self goal should produce a full orchestration plan.");
  assert(
    timed.metadata.input.normalizedInput === "Submit my conference talk proposal by 2026-05-15",
    "timed goal should preserve normalized input metadata.",
  );
  assert(
    timed.metadata.inference.mode.value === timed.draft.mode,
    "timed goal metadata should preserve the inferred mode.",
  );

  const learning = findGoalEngineOrchestratorFixture("untimed-learning-goal")?.result;
  assert(
    learning?.kind === "planned" || learning?.kind === "starter_planned",
    "untimed learning goal should compile into a plan-shaped result.",
  );
  assert(
    learning.metadata.inference.tempo.value === learning.draft.timing.tempo,
    "learning result should preserve inferred timing metadata.",
  );

  const exploratory = findGoalEngineOrchestratorFixture("exploratory-vague-goal")?.result;
  assert(
    exploratory?.kind === "starter_planned",
    "broad exploratory business goal should become a starter plan when safe defaults are allowed.",
  );
  assert(
    exploratory.assumptions.length > 0,
    "starter planned results should carry assumptions forward from intake gaps.",
  );
  assert(
    exploratory.metadata.reasoning.assumptions.length === exploratory.assumptions.length,
    "starter plan assumptions should pass through metadata unchanged.",
  );

  const delegated = findGoalEngineOrchestratorFixture("delegated-child-support-goal")?.result;
  assert(
    delegated?.kind === "planned",
    "delegated child support goal should become a full plan when support context resolves ambiguity.",
  );
  assert(
    delegated.draft.actor.displayName === "Maya",
    "delegated support plan should respect the actor name from orchestration context.",
  );
  assert(
    delegated.plan.sections.some((section) => section.title === "Support Actions"),
    "delegated support plan should keep support framing in the generated plan.",
  );

  const blocked = findGoalEngineOrchestratorFixture("blocked-requiring-clarification")?.result;
  assert(blocked?.kind === "clarification_required", "hard blocked input should return clarification_required.");
  assert(
    blocked.clarification.questions.some((question) => question.field === "executor_identity"),
    "blocked clarification should surface the missing executor question.",
  );

  const draftBuild = buildGoalDraftFromIntake("Learn how to mix vocals");
  const blockedPlanner = {
    plan: () => ({
      kind: "blocked" as const,
      draft: draftBuild.draft,
      blockers: [
        {
          code: "planner_blocked_for_test",
          reason: "Synthetic blocked result for orchestration verification.",
          suggestedQuestion: "What constraint should the planner honor first?",
        },
      ],
      clarification: draftBuild.clarification,
    }),
  } as unknown as GoalPlanner;
  const blockedOrchestrator = new GoalEngineOrchestrator(blockedPlanner);
  const plannerBlocked = blockedOrchestrator.compileGoal("Learn how to mix vocals", {
    referenceNow: "2026-04-14T12:00:00.000Z",
  });
  assert(
    plannerBlocked.kind === "blocked",
    "orchestrator should surface a typed blocked result when the planner blocks after intake.",
  );
  assert(
    plannerBlocked.blockers[0]?.code === "planner_blocked_for_test",
    "blocked orchestrator result should preserve planner blockers.",
  );

  const contradictory = findGoalEngineOrchestratorFixture("contradictory-input")?.result;
  assert(
    contradictory?.kind === "clarification_required",
    "contradictory timing input should require clarification instead of planning with false certainty.",
  );
  assert(
    contradictory.clarification.contradictions.length > 0,
    "contradictory input should surface a structured contradiction record.",
  );

  const unknownStart = findGoalEngineOrchestratorFixture("dont-know-where-to-start")?.result;
  assert(
    unknownStart?.kind === "clarification_required",
    "I don't know where to start should require clarification before planning.",
  );
  assert(
    unknownStart.metadata.reasoning.missingFields.some((field) => field.field === "goal_subject"),
    "unknown-start result should preserve the missing goal subject metadata.",
  );
}

runGoalEngineOrchestratorTests();
