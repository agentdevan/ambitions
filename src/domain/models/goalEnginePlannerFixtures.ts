import { ExecutionOwnership, GoalMode, GoalTempo, TimingType } from "./goalEngine";
import { buildGoalDraftFromIntake } from "./goalEngineIntake";
import {
  GoalPlanner,
  GoalPlannerInput,
  GoalPlannerResult,
  createPlannerDraft,
} from "./goalEnginePlanner";

export interface GoalEnginePlannerFixture {
  id: string;
  input: GoalPlannerInput;
  result: GoalPlannerResult;
}

const planner = new GoalPlanner();
const fixedNow = "2026-04-14T12:00:00.000Z";

function runFixture(id: string, input: GoalPlannerInput): GoalEnginePlannerFixture {
  return {
    id,
    input,
    result: planner.plan(input, { goalId: id, now: fixedNow }),
  };
}

const timedAchievementDraft = createPlannerDraft({
  title: "Submit the conference talk proposal",
  summary: "Turn the rough idea into a submitted proposal before the call closes.",
  mode: GoalMode.Achievement,
  tempo: GoalTempo.DeadlineBased,
  timingType: TimingType.DueAt,
  dueAt: "2026-05-15T23:59:00.000Z",
  tags: ["milestone_plan"],
});

const untimedLearningDraft = createPlannerDraft({
  title: "Learn enough SQL to analyze product questions",
  summary: "Build practical SQL skill through deliberate practice and explanation.",
  mode: GoalMode.Learning,
  tempo: GoalTempo.Untimed,
  timingType: TimingType.LogWhenDone,
  tags: ["learning_path"],
});

const maintenanceDraft = createPlannerDraft({
  title: "Keep the apartment reset each evening",
  summary: "Maintain a low-friction evening reset routine.",
  mode: GoalMode.Maintenance,
  tempo: GoalTempo.Ongoing,
  timingType: TimingType.RepeatWithinWindow,
  repeatEveryDays: 1,
  tags: ["routine_builder"],
});

const recoveryDraft = createPlannerDraft({
  title: "Recover from sleep debt",
  summary: "Stabilize bedtime and wake-up energy before pushing harder habits.",
  mode: GoalMode.Recovery,
  tempo: GoalTempo.Untimed,
  timingType: TimingType.SuggestedNext,
  tags: ["stabilization_path"],
});

const delegatedSupportDraft = createPlannerDraft({
  title: "Support Maya's reading confidence",
  summary: "Offer support while Maya stays the owner of the reading work.",
  mode: GoalMode.DelegatedSupport,
  tempo: GoalTempo.Ongoing,
  timingType: TimingType.RepeatWithinWindow,
  repeatEveryDays: 7,
  actorOwnership: ExecutionOwnership.Child,
  actorDisplayName: "Maya",
  tags: ["guided_support"],
});

const explorationDraftBuild = buildGoalDraftFromIntake("Figure out if I want to pivot into data visualization work");
const starterDraftBuild = buildGoalDraftFromIntake("Get healthier");
const blockedDraftBuild = buildGoalDraftFromIntake("Break this down for someone else");

export const goalEnginePlannerFixtures: GoalEnginePlannerFixture[] = [
  runFixture("timed-achievement-goal", { draft: timedAchievementDraft }),
  runFixture("untimed-learning-goal", { draft: untimedLearningDraft }),
  runFixture("exploration-goal-with-ambiguity", {
    draft: explorationDraftBuild.draft,
    classification: explorationDraftBuild.classification,
    clarification: explorationDraftBuild.clarification,
  }),
  runFixture("maintenance-goal", { draft: maintenanceDraft }),
  runFixture("recovery-goal", { draft: recoveryDraft }),
  runFixture("delegated-child-support-goal", { draft: delegatedSupportDraft }),
  runFixture("vague-safe-starter-plan", {
    draft: starterDraftBuild.draft,
    classification: starterDraftBuild.classification,
    clarification: starterDraftBuild.clarification,
  }),
  runFixture("blocked-planning-case", {
    draft: blockedDraftBuild.draft,
    classification: blockedDraftBuild.classification,
    clarification: blockedDraftBuild.clarification,
  }),
];

export function findGoalEnginePlannerFixture(id: string): GoalEnginePlannerFixture | undefined {
  return goalEnginePlannerFixtures.find((fixture) => fixture.id === id);
}
