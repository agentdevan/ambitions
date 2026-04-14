import { GoalMode, GoalTempo, PlanSectionKind, PlanLintIssueCode, TimingType } from "./goalEngine";
import { GoalEngineIntakeFixtures } from "./index";
import { GoalPlanner, createPlannerDraft } from "./goalEnginePlanner";
import { goalEnginePlannerFixtures, findGoalEnginePlannerFixture } from "./goalEnginePlannerFixtures";
import { PlanLinter } from "./goalEnginePlannerLinter";
import { StepRewriter } from "./goalEngineStepRewriter";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function runGoalEnginePlannerTests(): void {
  const timed = findGoalEnginePlannerFixture("timed-achievement-goal")?.result;
  assert(timed?.kind === "plan", "timed achievement goal should produce a full plan.");
  assert(
    timed.plan.sections.some((section) => section.title === "Milestones"),
    "timed achievement plan should include milestone structure.",
  );
  assert(
    timed.plan.sections.some((section) => section.title === "Workstreams"),
    "timed achievement plan should include workstreams.",
  );
  assert(
    timed.plan.sections.flatMap((section) => section.steps).every((step) => step.actionability.evidenceOfCompletion.length > 0),
    "timed achievement steps should include evidence of completion.",
  );
  assert(
    timed.plan.sections.flatMap((section) => section.steps).some((step) => step.timing.timingType === TimingType.TargetBy),
    "timed achievement plan should use target timing when the draft carries a deadline.",
  );

  const learning = findGoalEnginePlannerFixture("untimed-learning-goal")?.result;
  assert(learning?.kind === "plan", "untimed learning goal should produce a full plan.");
  assert(
    learning.plan.sections.some((section) => section.title === "Skill Map"),
    "learning plan should include a skill map section.",
  );
  assert(
    learning.plan.sections.some((section) => section.title === "Practice Sessions"),
    "learning plan should include practice sessions.",
  );
  assert(
    learning.plan.sections.flatMap((section) => section.steps).every((step) => step.timing.timingType !== TimingType.DueAt),
    "untimed learning goals should not receive due_at pressure.",
  );

  const exploration = findGoalEnginePlannerFixture("exploration-goal-with-ambiguity")?.result;
  assert(exploration?.kind === "plan", "exploration goal should still produce a plan when the goal is safely explorable.");
  assert(
    exploration.plan.sections.some((section) => section.title === "Key Questions"),
    "exploration plan should include key questions.",
  );
  assert(
    exploration.plan.sections.some((section) => section.title === "Experiments"),
    "exploration plan should include experiments.",
  );
  assert(
    exploration.plan.sections.some((section) => section.title === "Reflections"),
    "exploration plan should include reflections.",
  );

  const maintenance = findGoalEnginePlannerFixture("maintenance-goal")?.result;
  assert(maintenance?.kind === "plan", "maintenance goal should produce a full plan.");
  assert(
    maintenance.plan.sections.map((section) => section.title).join("|") === "Cue|Routine|Minimum Version|Recovery Logic",
    "maintenance plan should expose cue, routine, minimum version, and recovery logic sections.",
  );
  assert(
    maintenance.plan.sections.flatMap((section) => section.steps).some((step) => step.timing.timingType === TimingType.RepeatWithinWindow),
    "maintenance plan should include a repeatable routine step.",
  );

  const recovery = findGoalEnginePlannerFixture("recovery-goal")?.result;
  assert(recovery?.kind === "plan", "recovery goal should produce a full plan.");
  assert(
    recovery.plan.sections[0]?.title === "Stabilization First",
    "recovery plan should begin with stabilization-first sequencing.",
  );
  assert(
    recovery.plan.sections.flatMap((section) => section.steps).every((step) => step.timing.timingType !== TimingType.DueAt),
    "recovery plan should avoid deadline timing.",
  );

  const delegated = findGoalEnginePlannerFixture("delegated-child-support-goal")?.result;
  assert(delegated?.kind === "plan", "delegated support goal should produce a full plan.");
  assert(
    delegated.plan.sections.some((section) => section.title === "Support Actions"),
    "delegated support plan should include support actions.",
  );
  assert(
    delegated.plan.sections.some((section) => section.title === "Observation Prompts"),
    "delegated support plan should include observation prompts.",
  );
  assert(
    delegated.plan.sections.some((section) => section.title === "Milestone Signs"),
    "delegated support plan should include milestone signs.",
  );
  assert(
    delegated.lint.issues.every((issue) => issue.code !== PlanLintIssueCode.WrongSupportTone),
    "delegated support plan should avoid punitive tone.",
  );

  const starter = findGoalEnginePlannerFixture("vague-safe-starter-plan")?.result;
  assert(starter?.kind === "starter_plan", "vague but safe input should produce a starter plan.");
  assert(starter.assumptions.length > 0, "starter plans should carry explicit assumptions.");
  assert(
    starter.plan.sections.some((section) => section.title === "Starter Focus"),
    "starter plans should use the lightweight tracking structure.",
  );

  const blocked = findGoalEnginePlannerFixture("blocked-planning-case")?.result;
  assert(blocked?.kind === "blocked", "blocked intake should return a blocked planning result.");
  assert(blocked.blockers.length > 0, "blocked planning result should explain why planning was blocked.");

  const rewriter = new StepRewriter();
  const linter = new PlanLinter();
  const vagueDraft = createPlannerDraft({
    title: "Learn product analytics",
    mode: GoalMode.Learning,
    tempo: GoalTempo.Untimed,
    tags: ["learning_path"],
  });
  const planner = new GoalPlanner();
  const planned = planner.plan({ draft: vagueDraft }, { goalId: "vague-draft", now: "2026-04-14T12:00:00.000Z" });
  assert(planned.kind === "plan", "direct planner draft should create a plan.");

  const firstStep = planned.plan.sections.find((section) => section.kind === PlanSectionKind.Overview)?.steps[0];
  assert(firstStep, "expected at least one overview step.");
  const rewritten = rewriter.rewrite(
    {
      ...firstStep,
      title: "Continue with analytics",
      actionability: {
        ...firstStep.actionability,
        action: "Continue with analytics",
        completionDefinition: "Make progress on analytics",
        fallbackMicroStep: "Work on analytics",
      },
    },
    vagueDraft,
  );
  assert(!rewriter.isVague(rewritten), "step rewriter should remove vague phrasing.");

  const linted = linter.lint(
    {
      ...planned.plan,
      sections: [
        {
          ...planned.plan.sections[0]!,
          steps: [{ ...rewritten, actionability: { ...rewritten.actionability, evidenceOfCompletion: [] } }],
        },
      ],
    },
    vagueDraft,
  );
  assert(
    linted.issues.some((issue) => issue.code === PlanLintIssueCode.MissingStepEvidence),
    "plan linter should flag missing evidence.",
  );

  const intakeFixture = GoalEngineIntakeFixtures.findGoalEngineIntakeFixture("untimed-goal");
  assert(intakeFixture?.result.classification.readiness === "can_plan_with_defaults", "intake fixture sanity check failed.");
}

runGoalEnginePlannerTests();
