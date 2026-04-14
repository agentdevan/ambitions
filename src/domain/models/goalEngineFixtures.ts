import {
  createDefaultGoalActor,
  createDefaultPlanningStrategy,
  createDefaultProgressStrategy,
  createGoalTiming,
  EvidenceSource,
  ExecutionOwnership,
  Goal,
  GoalDraft,
  GoalLifecycleState,
  GoalMode,
  GoalRelationshipKind,
  GoalPlan,
  GoalTempo,
  GoalTiming,
  GOAL_ENGINE_SCHEMA_VERSION,
  lintGoal,
  PlanSection,
  PlanSectionKind,
  Step,
  StepLifecycleState,
  StepType,
  TimingType,
} from "./goalEngine";

const fixtureTimestamp = "2026-04-14T12:00:00.000Z";

function makeStep(params: {
  goalId: string;
  sectionId: string;
  suffix: string;
  title: string;
  type: StepType;
  timing: GoalTiming;
  ownership?: ExecutionOwnership;
  displayName?: string;
  summary?: string | null;
  state?: StepLifecycleState;
  dependencyStepIds?: string[];
  isRepeatable?: boolean;
}): Step {
  return {
    id: `${params.goalId}-${params.suffix}`,
    sectionId: params.sectionId,
    title: params.title,
    summary: params.summary ?? null,
    type: params.type,
    state: params.state ?? StepLifecycleState.Planned,
    owner: createDefaultGoalActor(params.ownership ?? ExecutionOwnership.Self, params.displayName ?? "You"),
    timing: params.timing,
    dependencyStepIds: params.dependencyStepIds ?? [],
    isOptional: false,
    isRepeatable: params.isRepeatable ?? false,
    evidenceRequired: true,
    successSignals: [params.summary ?? `${params.title} is complete.`],
  };
}

function makePlan(goalId: string, mode: GoalMode, sections: PlanSection[]): GoalPlan {
  return {
    id: `${goalId}-plan`,
    goalId,
    version: 1,
    generatedAt: fixtureTimestamp,
    summary: `Fixture plan for ${mode}.`,
    strategy: createDefaultPlanningStrategy(mode),
    sections,
    lint: {
      goalId,
      planVersion: 1,
      isValid: true,
      issueCount: 0,
      issues: [],
    },
  };
}

function makeGoalFixture(params: {
  id: string;
  title: string;
  summary: string;
  mode: GoalMode;
  tempo: GoalTempo;
  relationshipKind?: GoalRelationshipKind;
  ownership?: ExecutionOwnership;
  parentGoalId?: string | null;
  tags?: string[];
  planSections: Omit<PlanSection, "goalId" | "orderIndex">[];
  timing: GoalTiming;
}): Goal {
  const planningStrategy = createDefaultPlanningStrategy(params.mode);
  const progressStrategy = createDefaultProgressStrategy(params.mode, params.tempo);
  const plan = makePlan(
    params.id,
    params.mode,
    params.planSections.map((section, index) => ({
      ...section,
      goalId: params.id,
      orderIndex: index,
    })),
  );

  const goal: Goal = {
    schemaVersion: GOAL_ENGINE_SCHEMA_VERSION,
    id: params.id,
    revision: 1,
    createdAt: fixtureTimestamp,
    updatedAt: fixtureTimestamp,
    state: GoalLifecycleState.Active,
    title: params.title,
    summary: params.summary,
    mode: params.mode,
    relationshipKind: params.relationshipKind ?? GoalRelationshipKind.Independent,
    actor: createDefaultGoalActor(params.ownership ?? ExecutionOwnership.Self, "You"),
    parentGoalId: params.parentGoalId ?? null,
    childGoalIds: [],
    supportGoalIds: [],
    tags: params.tags ?? [params.mode],
    timing: params.timing,
    planningStrategy,
    progressStrategy,
    plan,
  };
  goal.plan = { ...plan, lint: lintGoal(goal) };
  return goal;
}

export const goalModeFixtures: Record<GoalMode, Goal> = {
  [GoalMode.Achievement]: makeGoalFixture({
    id: "fixture-achievement",
    title: "Finish the half marathon strong",
    summary: "A deadline-based personal performance goal with a hard event date.",
    mode: GoalMode.Achievement,
    tempo: GoalTempo.DeadlineBased,
    timing: createGoalTiming({
      tempo: GoalTempo.DeadlineBased,
      timingType: TimingType.DueAt,
      dueAt: "2026-10-03T14:00:00.000Z",
      startsOn: "2026-04-14",
      progressReviewCadenceDays: 7,
    }),
    planSections: [
      {
        id: "achievement-overview",
        title: "Race readiness",
        summary: "Keep the work centered on the next block that improves readiness.",
        kind: PlanSectionKind.Overview,
        steps: [
          makeStep({
            goalId: "fixture-achievement",
            sectionId: "achievement-overview",
            suffix: "benchmark-run",
            title: "Complete a benchmark 10K",
            type: StepType.ActionUnit,
            timing: createGoalTiming({
              tempo: GoalTempo.TargetWindow,
              timingType: TimingType.TargetBy,
              targetBy: "2026-05-15",
            }),
            summary: "Use the split data to reset the remaining training pace.",
          }),
        ],
      },
      {
        id: "achievement-active",
        title: "Current training block",
        summary: "Immediate work that moves the next performance checkpoint.",
        kind: PlanSectionKind.ActiveSteps,
        steps: [
          makeStep({
            goalId: "fixture-achievement",
            sectionId: "achievement-active",
            suffix: "speed-session",
            title: "Run the Tuesday speed session",
            type: StepType.ActionUnit,
            timing: createGoalTiming({
              tempo: GoalTempo.Ongoing,
              timingType: TimingType.RepeatWithinWindow,
              repeatEveryDays: 7,
            }),
            summary: "Maintain one quality speed session each week.",
            isRepeatable: true,
          }),
        ],
      },
    ],
  }),
  [GoalMode.Project]: makeGoalFixture({
    id: "fixture-project",
    title: "Launch the family travel archive",
    summary: "A target-window project with visible phases and no single hard deadline.",
    mode: GoalMode.Project,
    tempo: GoalTempo.TargetWindow,
    timing: createGoalTiming({
      tempo: GoalTempo.TargetWindow,
      timingType: TimingType.TargetBy,
      startsOn: "2026-04-14",
      targetBy: "2026-07-01",
      windowStart: "2026-06-15",
      windowEnd: "2026-07-15",
      progressReviewCadenceDays: 7,
    }),
    planSections: [
      {
        id: "project-active",
        title: "Current build",
        summary: "Parallel work streams for assets and structure.",
        kind: PlanSectionKind.ActiveSteps,
        steps: [
          makeStep({
            goalId: "fixture-project",
            sectionId: "project-active",
            suffix: "organize-media",
            title: "Sort the raw media into year-based folders",
            type: StepType.ActionUnit,
            timing: createGoalTiming({
              tempo: GoalTempo.TargetWindow,
              timingType: TimingType.TargetBy,
              targetBy: "2026-05-05",
            }),
          }),
          makeStep({
            goalId: "fixture-project",
            sectionId: "project-active",
            suffix: "draft-navigation",
            title: "Draft the archive navigation structure",
            type: StepType.ActionUnit,
            timing: createGoalTiming({
              tempo: GoalTempo.TargetWindow,
              timingType: TimingType.SuggestedNext,
              suggestedNextAt: "2026-04-16T18:00:00.000Z",
            }),
            dependencyStepIds: ["fixture-project-organize-media"],
          }),
        ],
      },
    ],
  }),
  [GoalMode.Habit]: makeGoalFixture({
    id: "fixture-habit",
    title: "Maintain morning mobility",
    summary: "An ongoing routine with progress tracked through consistency rather than a finish line.",
    mode: GoalMode.Habit,
    tempo: GoalTempo.Ongoing,
    timing: createGoalTiming({
      tempo: GoalTempo.Ongoing,
      timingType: TimingType.RepeatWithinWindow,
      startsOn: "2026-04-14",
      repeatEveryDays: 1,
      progressReviewCadenceDays: 7,
    }),
    planSections: [
      {
        id: "habit-routine",
        title: "Daily rhythm",
        summary: "The minimum effective routine that keeps the habit alive.",
        kind: PlanSectionKind.ActiveSteps,
        steps: [
          makeStep({
            goalId: "fixture-habit",
            sectionId: "habit-routine",
            suffix: "mobility-flow",
            title: "Complete the 12-minute mobility flow",
            type: StepType.RecurringRoutine,
            timing: createGoalTiming({
              tempo: GoalTempo.Ongoing,
              timingType: TimingType.RepeatWithinWindow,
              repeatEveryDays: 1,
            }),
            isRepeatable: true,
          }),
        ],
      },
      {
        id: "habit-review",
        title: "Weekly review",
        summary: "Check adherence before increasing difficulty.",
        kind: PlanSectionKind.Review,
        steps: [
          makeStep({
            goalId: "fixture-habit",
            sectionId: "habit-review",
            suffix: "habit-reflection",
            title: "Log whether the routine still fits the morning energy",
            type: StepType.ReflectionPrompt,
            timing: createGoalTiming({
              tempo: GoalTempo.Ongoing,
              timingType: TimingType.SuggestedNext,
              suggestedNextAt: "2026-04-20T12:00:00.000Z",
            }),
          }),
        ],
      },
    ],
  }),
  [GoalMode.Learning]: makeGoalFixture({
    id: "fixture-learning",
    title: "Learn conversational Spanish for travel",
    summary: "A learning goal with untimed progress based on checkpoints and reflections.",
    mode: GoalMode.Learning,
    tempo: GoalTempo.Untimed,
    timing: createGoalTiming({
      tempo: GoalTempo.Untimed,
      timingType: TimingType.LogWhenDone,
      startsOn: "2026-04-14",
      progressReviewCadenceDays: 7,
    }),
    planSections: [
      {
        id: "learning-active",
        title: "Current study loop",
        summary: "Keep the next study actions concrete and reviewable.",
        kind: PlanSectionKind.ActiveSteps,
        steps: [
          makeStep({
            goalId: "fixture-learning",
            sectionId: "learning-active",
            suffix: "lesson-block",
            title: "Complete one focused lesson block",
            type: StepType.LearningCheckpoint,
            timing: createGoalTiming({
              tempo: GoalTempo.Untimed,
              timingType: TimingType.LogWhenDone,
            }),
          }),
          makeStep({
            goalId: "fixture-learning",
            sectionId: "learning-active",
            suffix: "speaking-check",
            title: "Record a short speaking check-in",
            type: StepType.ReflectionPrompt,
            timing: createGoalTiming({
              tempo: GoalTempo.Untimed,
              timingType: TimingType.SuggestedNext,
              suggestedNextAt: "2026-04-17T19:00:00.000Z",
            }),
          }),
        ],
      },
      {
        id: "learning-resources",
        title: "Resources",
        summary: "Materials that support the loop without pretending to be progress on their own.",
        kind: PlanSectionKind.Resources,
        steps: [
          makeStep({
            goalId: "fixture-learning",
            sectionId: "learning-resources",
            suffix: "resource-list",
            title: "Keep one curated list of phrases and listening clips",
            type: StepType.Resource,
            timing: createGoalTiming({
              tempo: GoalTempo.Untimed,
              timingType: TimingType.LogWhenDone,
            }),
            summary: "Reference material only; it does not count as learning evidence by itself.",
          }),
        ],
      },
    ],
  }),
  [GoalMode.Exploration]: makeGoalFixture({
    id: "fixture-exploration",
    title: "Explore adjacent product roles",
    summary: "An exploration goal that values experiments and observations over direct completion.",
    mode: GoalMode.Exploration,
    tempo: GoalTempo.TargetWindow,
    timing: createGoalTiming({
      tempo: GoalTempo.TargetWindow,
      timingType: TimingType.TargetBy,
      startsOn: "2026-04-14",
      targetBy: "2026-06-01",
      progressReviewCadenceDays: 5,
    }),
    planSections: [
      {
        id: "exploration-active",
        title: "Experiments",
        summary: "Small tests that clarify interest and fit.",
        kind: PlanSectionKind.ActiveSteps,
        steps: [
          makeStep({
            goalId: "fixture-exploration",
            sectionId: "exploration-active",
            suffix: "interview",
            title: "Run one informational interview",
            type: StepType.ExplorationExperiment,
            timing: createGoalTiming({
              tempo: GoalTempo.TargetWindow,
              timingType: TimingType.TargetBy,
              targetBy: "2026-04-25",
            }),
          }),
          makeStep({
            goalId: "fixture-exploration",
            sectionId: "exploration-active",
            suffix: "retro",
            title: "Capture what energized or drained you after the interview",
            type: StepType.ObservationPrompt,
            timing: createGoalTiming({
              tempo: GoalTempo.TargetWindow,
              timingType: TimingType.LogWhenDone,
            }),
            dependencyStepIds: ["fixture-exploration-interview"],
          }),
        ],
      },
    ],
  }),
  [GoalMode.Maintenance]: makeGoalFixture({
    id: "fixture-maintenance",
    title: "Keep home finances current",
    summary: "An ongoing maintenance goal with recurring upkeep steps and no terminal finish.",
    mode: GoalMode.Maintenance,
    tempo: GoalTempo.Ongoing,
    timing: createGoalTiming({
      tempo: GoalTempo.Ongoing,
      timingType: TimingType.RepeatWithinWindow,
      repeatEveryDays: 7,
      progressReviewCadenceDays: 14,
    }),
    planSections: [
      {
        id: "maintenance-active",
        title: "Recurring upkeep",
        summary: "Repeatable work that prevents drift.",
        kind: PlanSectionKind.ActiveSteps,
        steps: [
          makeStep({
            goalId: "fixture-maintenance",
            sectionId: "maintenance-active",
            suffix: "reconcile",
            title: "Reconcile the household expense tracker",
            type: StepType.RecurringRoutine,
            timing: createGoalTiming({
              tempo: GoalTempo.Ongoing,
              timingType: TimingType.RepeatWithinWindow,
              repeatEveryDays: 7,
            }),
            isRepeatable: true,
          }),
        ],
      },
    ],
  }),
  [GoalMode.Recovery]: makeGoalFixture({
    id: "fixture-recovery",
    title: "Recover from two months of poor sleep",
    summary: "A recovery goal that tracks confidence and observation without a fixed end date.",
    mode: GoalMode.Recovery,
    tempo: GoalTempo.Ongoing,
    timing: createGoalTiming({
      tempo: GoalTempo.Ongoing,
      timingType: TimingType.SuggestedNext,
      suggestedNextAt: "2026-04-15T21:00:00.000Z",
      progressReviewCadenceDays: 3,
    }),
    planSections: [
      {
        id: "recovery-active",
        title: "Recovery actions",
        summary: "Keep the actions narrow enough to be safe during a low-capacity period.",
        kind: PlanSectionKind.ActiveSteps,
        steps: [
          makeStep({
            goalId: "fixture-recovery",
            sectionId: "recovery-active",
            suffix: "bedtime",
            title: "Start the bedtime shutdown 30 minutes earlier",
            type: StepType.ActionUnit,
            timing: createGoalTiming({
              tempo: GoalTempo.Ongoing,
              timingType: TimingType.SuggestedNext,
              suggestedNextAt: "2026-04-14T21:30:00.000Z",
            }),
          }),
          makeStep({
            goalId: "fixture-recovery",
            sectionId: "recovery-active",
            suffix: "sleep-log",
            title: "Log how rested you feel on wake-up",
            type: StepType.ObservationPrompt,
            timing: createGoalTiming({
              tempo: GoalTempo.Ongoing,
              timingType: TimingType.LogWhenDone,
            }),
            isRepeatable: true,
          }),
        ],
      },
    ],
  }),
  [GoalMode.DelegatedSupport]: makeGoalFixture({
    id: "fixture-delegated-support",
    title: "Support Maya's science fair build",
    summary: "A support goal for someone else, with progress tracked by delegated updates and support actions.",
    mode: GoalMode.DelegatedSupport,
    tempo: GoalTempo.Ongoing,
    relationshipKind: GoalRelationshipKind.Support,
    ownership: ExecutionOwnership.Child,
    parentGoalId: "family-learning-direction",
    timing: createGoalTiming({
      tempo: GoalTempo.Ongoing,
      timingType: TimingType.RepeatWithinWindow,
      repeatEveryDays: 7,
      progressReviewCadenceDays: 7,
    }),
    planSections: [
      {
        id: "support-actions",
        title: "Support actions",
        summary: "Work done by the supporting adult without taking ownership away from the child.",
        kind: PlanSectionKind.SupportingWork,
        steps: [
          makeStep({
            goalId: "fixture-delegated-support",
            sectionId: "support-actions",
            suffix: "materials",
            title: "Order the missing display-board materials",
            type: StepType.SupportAction,
            timing: createGoalTiming({
              tempo: GoalTempo.TargetWindow,
              timingType: TimingType.TargetBy,
              targetBy: "2026-04-20",
            }),
            ownership: ExecutionOwnership.Partner,
            displayName: "Parent support",
          }),
          makeStep({
            goalId: "fixture-delegated-support",
            sectionId: "support-actions",
            suffix: "checkin",
            title: "Ask Maya what still feels unclear before the next build session",
            type: StepType.ObservationPrompt,
            timing: createGoalTiming({
              tempo: GoalTempo.Ongoing,
              timingType: TimingType.SuggestedNext,
              suggestedNextAt: "2026-04-18T17:00:00.000Z",
            }),
            ownership: ExecutionOwnership.Child,
            displayName: "Maya",
          }),
        ],
      },
    ],
  }),
};

export const goalModeDraftFixtures: Record<GoalMode, GoalDraft> = Object.fromEntries(
  Object.entries(goalModeFixtures).map(([mode, goal]) => [
    mode,
    {
      schemaVersion: GOAL_ENGINE_SCHEMA_VERSION,
      source: EvidenceSource.Manual,
      title: goal.title,
      summary: goal.summary,
      mode: goal.mode,
      relationshipKind: goal.relationshipKind,
      actor: goal.actor,
      parentGoalId: goal.parentGoalId,
      tags: goal.tags,
      timing: goal.timing,
      planningStrategy: goal.planningStrategy,
      progressStrategy: goal.progressStrategy,
    } satisfies GoalDraft,
  ]),
) as Record<GoalMode, GoalDraft>;
