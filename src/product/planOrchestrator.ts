import {
  AdaptationProfile,
  DailyPlan,
  DomainKey,
  EntitySyncState,
  Goal,
  GoalHorizon,
  GoalMilestone,
  GoalStatus,
  GoalType,
  ReplanSuggestion,
  ScheduleConstraint,
  Task,
  TaskSchedulingState,
  TaskStatus,
  TimeBlock,
  UserPreferences,
} from "../domain/models";
import { appServices } from "../bootstrap/runtime/appServices";
import {
  GoalDraftInference,
  GoalFeasibilityStatus,
  GoalPaceMode,
  GoalPaceOptionSummary,
  GoalStrategyComposer,
  ProductPreferences,
} from "./types";
import { mergeProductPreferences } from "./preferences";
import {
  buildGoalIntelligenceSnapshot,
  setGoalIntelligenceSnapshot,
} from "../services/goals/goalIntelligence";

function createId(prefix: string) {
  return `${prefix}-${Math.random().toString(36).slice(2, 10)}`;
}

function nowIso() {
  return new Date().toISOString();
}

function bindToAccount<
  T extends { ownerUserId: string | null; remoteId: string | null; syncState: string },
>(record: T, accountId: string | null) {
  if (!accountId) {
    return record;
  }

  return {
    ...record,
    ownerUserId: accountId,
    syncState: EntitySyncState.PendingSync,
  };
}

const paceModes: GoalPaceMode[] = ["conservative", "balanced", "aggressive"];

function formatHours(minutes: number) {
  const hours = minutes / 60;
  const rounded = hours >= 10 ? Math.round(hours) : Math.round(hours * 10) / 10;
  return `${rounded} hr/week`;
}

function daysUntil(date: string, targetDate: string | null) {
  if (!targetDate) {
    return 56;
  }

  return Math.max(
    1,
    Math.ceil(
      (Date.parse(`${targetDate}T12:00:00.000Z`) - Date.parse(`${date}T12:00:00.000Z`)) / 86400000,
    ),
  );
}

function weeksUntil(date: string, targetDate: string | null) {
  return Math.max(1, Math.ceil(daysUntil(date, targetDate) / 7));
}

function addDays(date: string, amount: number) {
  return new Date(Date.parse(`${date}T12:00:00.000Z`) + amount * 86400000)
    .toISOString()
    .slice(0, 10);
}

function timeToMinutes(value: string) {
  const [hours, minutes] = value.split(":").map(Number);
  return hours * 60 + minutes;
}

function buildWeeklyCapacityEstimate(params: {
  today: string;
  targetDate: string | null;
  productPreferences: ProductPreferences;
  goals: Goal[];
  scheduleConstraints: ScheduleConstraint[];
  adaptationProfile: AdaptationProfile | null;
}) {
  const workdayCount = params.productPreferences.schedule.workdays.length;
  const baseDailyTarget =
    params.adaptationProfile?.planningDirectives.dailyPlannedMinutesTarget ??
    params.adaptationProfile?.capacity.focusBudgetMinutes ??
    90;
  const behaviorMultiplier = Math.max(
    0.55,
    Math.min(
      1.15,
      0.72 +
        (params.adaptationProfile?.completion.consistencyScore ?? 0.5) * 0.35 +
        (params.adaptationProfile?.strategy.balancedReadiness ?? 0.3) * 0.12 -
        ((params.adaptationProfile?.regression.isRegressing ?? false) ? 0.12 : 0),
    ),
  );
  const fixedCommitmentMinutes = params.scheduleConstraints.reduce((sum, constraint) => {
    const start = Date.parse(constraint.startsAt);
    const end = Date.parse(constraint.endsAt);
    return sum + Math.max(0, Math.round((end - start) / 60000));
  }, 0);
  const otherGoalsDemand = params.goals
    .filter((goal) => goal.status === GoalStatus.Active)
    .reduce((sum, goal) => sum + (goal.desiredWeeklyMinutes ?? 0), 0);
  const weeklyCapacityMinutes = Math.max(
    90,
    Math.round(baseDailyTarget * workdayCount * behaviorMultiplier - fixedCommitmentMinutes * 0.2 - otherGoalsDemand * 0.3),
  );
  const totalCapacityMinutes = weeklyCapacityMinutes * weeksUntil(params.today, params.targetDate);

  return {
    weeklyCapacityMinutes,
    totalCapacityMinutes,
    availableCapacitySummary: `${formatHours(weeklyCapacityMinutes)} available after current commitments and active-goal load.`,
    commitmentsSummary:
      fixedCommitmentMinutes > 0
        ? `${Math.round(fixedCommitmentMinutes / 60)} hr of visible fixed commitments are already shaping the week.`
        : "Fixed commitments are still light in the current planning view.",
    behaviorSummary:
      params.adaptationProfile?.regression.isRegressing
        ? "Recent follow-through has been less stable, so the capacity read stays conservative."
        : "Recent execution supports a believable weekly capacity instead of a fantasy maximum.",
  };
}

function workloadEstimateForGoal(goal: Goal, tasks: Task[], milestones: GoalMilestone[], today: string) {
  const taskMinutes = tasks.reduce((sum, task) => sum + task.estimatedMinutes, 0);
  const milestoneMinutes = milestones.reduce((sum, milestone) => sum + (milestone.estimatedMinutes ?? 0), 0);
  const deadlineWeeks = weeksUntil(today, goal.targetDate);
  const inferredBaseline =
    goal.estimatedTotalMinutes ?? Math.max(goal.desiredWeeklyMinutes ?? 0, taskMinutes);

  return Math.max(
    inferredBaseline,
    taskMinutes + milestoneMinutes,
    Math.round((goal.desiredWeeklyMinutes ?? 90) * Math.min(6, deadlineWeeks)),
  );
}

function paceConfig(mode: GoalPaceMode, adaptationProfile: AdaptationProfile | null) {
  const aggressiveLift = Math.min(
    1.18,
    1.08 + (adaptationProfile?.strategy.balancedReadiness ?? 0.3) * 0.1,
  );

  switch (mode) {
    case "conservative":
      return {
        label: "Conservative",
        demandMultiplier: 0.88,
        sustainableMultiplier: 0.9,
        sessionMinutes: 25,
        taskSizing: "Shorter sessions",
        riskLevel: "Lower risk",
        adaptationBehavior: "Protects the plan sooner when life gets crowded.",
      };
    case "aggressive":
      return {
        label: "Aggressive",
        demandMultiplier: 1.12,
        sustainableMultiplier: aggressiveLift,
        sessionMinutes: 45,
        taskSizing: "Longer pushes",
        riskLevel: "Higher risk",
        adaptationBehavior: "Holds a fuller load longer before trimming it back.",
      };
    default:
      return {
        label: "Balanced",
        demandMultiplier: 1,
        sustainableMultiplier: 1,
        sessionMinutes: 35,
        taskSizing: "Mixed session sizes",
        riskLevel: "Moderate risk",
        adaptationBehavior: "Protects realism while still keeping momentum visible.",
      };
  }
}

function lighterScopeSuggestion(goal: Goal, milestones: GoalMilestone[], tasks: Task[]) {
  if (goal.domainKey === DomainKey.Career) {
    return "One lighter version still fits: focus the first pass on your best-fit targets instead of the full search spread.";
  }

  if (goal.domainKey === DomainKey.Fitness) {
    return "One lighter version still fits: protect the consistency block first, then add intensity later.";
  }

  if (goal.domainKey === DomainKey.Finance || goal.domainKey === DomainKey.Credit) {
    return "One lighter version still fits: keep the baseline and first reduction milestone, then delay the rest.";
  }

  const trimmedMilestones = Math.max(1, milestones.length - 1);
  const trimmedTasks = Math.max(3, Math.round(tasks.length * 0.75));
  return `One lighter version still fits: keep the first ${trimmedMilestones} milestone${trimmedMilestones === 1 ? "" : "s"} and trim the first pass to about ${trimmedTasks} tasks.`;
}

function buildFeasibilityTruth(params: {
  goal: Goal;
  tasks: Task[];
  milestones: GoalMilestone[];
  today: string;
  paceMode: GoalPaceMode;
  weeklyCapacityMinutes: number;
  totalCapacityMinutes: number;
  adaptationProfile: AdaptationProfile | null;
}) {
  const totalWorkEstimateMinutes = workloadEstimateForGoal(
    params.goal,
    params.tasks,
    params.milestones,
    params.today,
  );
  const deadlineWeeks = weeksUntil(params.today, params.goal.targetDate);
  const config = paceConfig(params.paceMode, params.adaptationProfile);
  const requiredWeeklyMinutes = Math.max(
    params.goal.desiredWeeklyMinutes ?? 0,
    Math.ceil(totalWorkEstimateMinutes / deadlineWeeks),
  );
  const weeklyDemandMinutes = Math.round(requiredWeeklyMinutes * config.demandMultiplier);
  const sustainableWeeklyMinutes = Math.round(params.weeklyCapacityMinutes * config.sustainableMultiplier);
  const loadRatio = weeklyDemandMinutes / Math.max(60, sustainableWeeklyMinutes);
  const status: GoalFeasibilityStatus =
    loadRatio <= 0.85 ? "feasible" : loadRatio <= 1 ? "tight" : "unrealistic";
  const deadlineConfidence =
    status === "feasible" ? "Believable" : status === "tight" ? "Lower buffer" : "Low confidence";
  const revisedWeeks = Math.ceil(totalWorkEstimateMinutes / Math.max(60, sustainableWeeklyMinutes));
  const revisedDeadlineSuggestion =
    status === "unrealistic" ? addDays(params.today, revisedWeeks * 7) : null;
  const highestLeverageStep =
    params.tasks[0]?.title
      ? `Protect the next step: ${params.tasks[0].title}.`
      : "Protect the first milestone before adding more scope.";

  return {
    totalWorkEstimateMinutes,
    truth: {
      status,
      summary:
        status === "feasible"
          ? "Balanced pacing keeps this goal believable."
          : status === "tight"
            ? "Still possible, but tighter than before."
            : "This deadline is unlikely to hold at the current pace.",
      detail:
        status === "feasible"
          ? `This plan asks for about ${formatHours(weeklyDemandMinutes)} against ${formatHours(sustainableWeeklyMinutes)} of believable room.`
          : status === "tight"
            ? `This plan is asking for about ${formatHours(weeklyDemandMinutes)} against ${formatHours(sustainableWeeklyMinutes)} of believable room. There is not much slack.`
            : `This plan is asking for about ${formatHours(weeklyDemandMinutes)} against ${formatHours(sustainableWeeklyMinutes)} of believable room.`,
      deadlineConfidence,
      weeklyDemandMinutes,
      weeklyCapacityMinutes: sustainableWeeklyMinutes,
      totalCapacityMinutes: params.totalCapacityMinutes,
      revisedDeadlineSuggestion,
      revisedDeadlineReason:
        revisedDeadlineSuggestion !== null ? "A later target would be more believable." : null,
      lighterScopeSuggestion:
        status === "unrealistic"
          ? lighterScopeSuggestion(params.goal, params.milestones, params.tasks)
          : null,
      pacingTradeoff:
        params.paceMode === "conservative"
          ? "Conservative pacing lowers daily pressure, but it is more likely to ask for a later finish."
          : params.paceMode === "aggressive"
            ? "Aggressive pacing keeps the date alive longer, but it asks for stronger consistency and larger sessions."
            : "Balanced pacing keeps the workload demanding without leaning on perfect consistency.",
      highestLeverageStep,
    },
  };
}

function chooseRecommendedPace(options: GoalPaceOptionSummary[]) {
  const feasibleBalanced = options.find((option) => option.mode === "balanced" && option.deadlineConfidence === "Believable");
  if (feasibleBalanced) {
    return feasibleBalanced.mode;
  }

  const feasibleConservative = options.find((option) => option.mode === "conservative" && option.deadlineConfidence !== "Low confidence");
  if (feasibleConservative) {
    return feasibleConservative.mode;
  }

  return "balanced" as GoalPaceMode;
}

function createGoalRecord(inference: GoalDraftInference, focusDomains: DomainKey[], today: string): Goal {
  const timestamp = nowIso();

  return {
    id: createId("goal"),
    ownerUserId: null,
    remoteId: null,
    syncState: EntitySyncState.LocalOnly,
    version: 1,
    lastSyncedAt: null,
    createdAt: timestamp,
    updatedAt: timestamp,
    title: inference.title,
    summary: inference.summary,
    domainKey: inference.domainKey,
    horizon: inference.horizon as GoalHorizon,
    type: inference.type as GoalType,
    status: GoalStatus.Active,
    parentGoalId: null,
    sortOrder: 1,
    startDate: today,
    targetDate: inference.targetDate,
    desiredWeeklyMinutes: inference.desiredWeeklyMinutes,
    estimatedTotalMinutes: inference.estimatedTotalMinutes,
    successMetric: inference.successMetric,
    notes: inference.notes,
    tags: Array.from(new Set([inference.domainKey, ...focusDomains])),
    metadata: {
      intakeSource: "phase22_goal_strategy_composer",
      naturalLanguage: inference.naturalLanguage,
      phase22SelectedPaceMode: inference.paceMode,
    },
  };
}

function adjustMilestones(
  goal: Goal,
  milestones: GoalMilestone[],
  today: string,
) {
  return milestones.map((milestone, index) => ({
    ...milestone,
    goalId: goal.id,
    id: `${goal.id}-milestone-${index + 1}`,
    targetDate:
      index === 0
        ? today
        : milestone.targetDate ?? new Date(Date.parse(`${today}T12:00:00.000Z`) + index * 7 * 86400000)
            .toISOString()
            .slice(0, 10),
    updatedAt: nowIso(),
  }));
}

function adjustTasks(
  goal: Goal,
  milestones: GoalMilestone[],
  tasks: Task[],
  today: string,
) {
  const milestoneById = new Map(milestones.map((milestone) => [milestone.id, milestone]));

  return tasks.map((task, index) => {
    const milestone = task.milestoneId ? milestoneById.get(task.milestoneId) : null;
    const targetDate = index < 3 ? today : milestone?.targetDate ?? goal.targetDate ?? today;

    return {
      ...task,
      id: `${task.id}-${goal.id}`,
      goalId: goal.id,
      milestoneId: milestone?.id ?? task.milestoneId,
      targetDate,
      scheduledDate: null,
      earliestStartAt: null,
      latestFinishAt: null,
      status: TaskStatus.Ready,
      schedulingState: TaskSchedulingState.Unscheduled,
      updatedAt: nowIso(),
      metadata: {
        ...task.metadata,
        generatedForFirstPlan: index < 3,
      },
    };
  });
}

function assignScheduledTaskState(tasks: Task[], blocks: TimeBlock[], today: string) {
  const blocksByTaskId = new Map(
    blocks.filter((block) => block.taskId).map((block) => [block.taskId as string, block]),
  );

  return tasks.map((task) => {
    const block = blocksByTaskId.get(task.id);
    if (!block) {
      return {
        ...task,
        status: task.targetDate === today ? TaskStatus.Unscheduled : task.status,
        schedulingState:
          task.targetDate === today ? TaskSchedulingState.Unscheduled : task.schedulingState,
      };
    }

    return {
      ...task,
      status: TaskStatus.Scheduled,
      schedulingState: TaskSchedulingState.Committed,
      scheduledDate: today,
      earliestStartAt: block.startsAtDateTime,
      latestFinishAt: block.endsAtDateTime,
    };
  });
}

export interface FirstPlanResult {
  goal: Goal;
  milestones: GoalMilestone[];
  tasks: Task[];
  dailyPlan: DailyPlan;
  timeBlocks: TimeBlock[];
  suggestions: ReplanSuggestion[];
}

export interface GoalArtifactDraft {
  goal: Goal;
  milestones: GoalMilestone[];
  tasks: Task[];
}

async function buildArtifactDraft(params: {
  inference: GoalDraftInference;
  mergedPreferences: UserPreferences;
  focusDomains: DomainKey[];
  today: string;
  adaptationProfile: AdaptationProfile | null;
}) {
  const goal = createGoalRecord(params.inference, params.focusDomains, params.today);
  const decomposition = await appServices.engines.decomposition.decompose({
    goal,
    milestones: [],
    existingTasks: [],
    preferences: params.mergedPreferences,
    adaptationProfile: params.adaptationProfile,
    referenceDate: params.today,
  });
  const milestones = adjustMilestones(goal, decomposition.payload.milestones, params.today);
  const tasks = adjustTasks(goal, milestones, decomposition.payload.tasks, params.today);

  return {
    goal,
    milestones,
    tasks,
  } satisfies GoalArtifactDraft;
}

async function buildGoalStrategyComposer(params: {
  inference: GoalDraftInference;
  productPreferences: ProductPreferences;
  mergedPreferences: UserPreferences;
  goals: Goal[];
  today: string;
  adaptationProfile: AdaptationProfile | null;
}) {
  const scheduleConstraints =
    await appServices.repositories.integration.listScheduleConstraintsForDate(params.today);
  const focusDomains =
    params.mergedPreferences.metadata.focusDomains
      ? String(params.mergedPreferences.metadata.focusDomains)
          .split(",")
          .filter((entry): entry is DomainKey => Object.values(DomainKey).includes(entry as DomainKey))
      : params.inference.focusDomains;
  const capacity = buildWeeklyCapacityEstimate({
    today: params.today,
    targetDate: params.inference.targetDate,
    productPreferences: params.productPreferences,
    goals: params.goals,
    scheduleConstraints,
    adaptationProfile: params.adaptationProfile,
  });
  const drafts = await Promise.all(
    paceModes.map(async (paceMode) => {
      const paceInference: GoalDraftInference = { ...params.inference, paceMode };
      const artifact = await buildArtifactDraft({
        inference: paceInference,
        mergedPreferences: params.mergedPreferences,
        focusDomains,
        today: params.today,
        adaptationProfile: params.adaptationProfile,
      });
      const feasibility = buildFeasibilityTruth({
        goal: artifact.goal,
        tasks: artifact.tasks,
        milestones: artifact.milestones,
        today: params.today,
        paceMode,
        weeklyCapacityMinutes: capacity.weeklyCapacityMinutes,
        totalCapacityMinutes: capacity.totalCapacityMinutes,
        adaptationProfile: params.adaptationProfile,
      });
      const config = paceConfig(paceMode, params.adaptationProfile);
      const paceOption: GoalPaceOptionSummary = {
        mode: paceMode,
        label: config.label,
        summary:
          paceMode === "conservative"
            ? "Calmer pace with more room to recover."
            : paceMode === "aggressive"
              ? "Fuller pace that protects the date at higher risk."
              : "Steady pace that keeps the goal realistic.",
        weeklyHours: Math.max(1, Math.round(feasibility.truth.weeklyDemandMinutes / 60)),
        sessionCount: Math.max(2, Math.ceil(feasibility.truth.weeklyDemandMinutes / config.sessionMinutes)),
        taskSizing: config.taskSizing,
        riskLevel: config.riskLevel,
        deadlineConfidence: feasibility.truth.deadlineConfidence,
        adaptationBehavior: config.adaptationBehavior,
        recommended: false,
      };

      return {
        ...artifact,
        feasibility: feasibility.truth,
        totalWorkEstimateMinutes: feasibility.totalWorkEstimateMinutes,
        paceOption,
      };
    }),
  );
  const recommendedPaceMode = chooseRecommendedPace(drafts.map((draft) => draft.paceOption));
  const selectedDraft =
    drafts.find((draft) => draft.paceOption.mode === params.inference.paceMode) ?? drafts[1];
  const paceOptions = drafts.map((draft) => ({
    ...draft.paceOption,
    recommended: draft.paceOption.mode === recommendedPaceMode,
  }));
  const composer: GoalStrategyComposer = {
    selectedPaceMode: selectedDraft.paceOption.mode,
    recommendedPaceMode,
    interpretation: params.inference.interpretation,
    availableCapacitySummary: capacity.availableCapacitySummary,
    commitmentsSummary: capacity.commitmentsSummary,
    behaviorSummary: capacity.behaviorSummary,
    workloadEstimateMinutes: selectedDraft.totalWorkEstimateMinutes,
    workloadEstimateLabel: `${Math.round(selectedDraft.totalWorkEstimateMinutes / 60)} hours of likely work`,
    paceOptions,
    feasibility: selectedDraft.feasibility,
    firstMilestonePath: selectedDraft.milestones.slice(0, 3).map((milestone) => ({
      title: milestone.title,
      summary: milestone.summary,
      targetDate: milestone.targetDate,
    })),
    firstWeekActionPreview: selectedDraft.tasks.slice(0, 4).map((task) => ({
      title: task.title,
      summary: task.summary,
      targetDate: task.targetDate,
      estimatedMinutes: task.estimatedMinutes,
    })),
  };

  return {
    composer,
    draft: {
      goal: setGoalIntelligenceSnapshot(
        selectedDraft.goal,
        buildGoalIntelligenceSnapshot(composer),
      ),
      milestones: selectedDraft.milestones,
      tasks: selectedDraft.tasks,
    },
  };
}

export async function createGoalArtifacts(params: {
  inference: GoalDraftInference;
  productPreferences: ProductPreferences;
  currentPreferences: UserPreferences;
  today: string;
  adaptationProfile: AdaptationProfile | null;
}) {
  const mergedPreferences = mergeProductPreferences(params.currentPreferences, {
    ...params.productPreferences,
    onboardingCompleted: true,
    focusDomains:
      params.productPreferences.focusDomains.length > 0
        ? params.productPreferences.focusDomains
        : params.inference.focusDomains,
  });
  const existingGoals = await appServices.repositories.goals.listGoals();
  const strategy = await buildGoalStrategyComposer({
    inference: params.inference,
    productPreferences: params.productPreferences,
    mergedPreferences,
    goals: existingGoals,
    today: params.today,
    adaptationProfile: params.adaptationProfile,
  });

  return {
    goal: strategy.draft.goal,
    milestones: strategy.draft.milestones,
    tasks: strategy.draft.tasks,
    mergedPreferences,
    composer: strategy.composer,
  };
}

export async function createGoalAndFirstPlan(params: {
  inference: GoalDraftInference;
  productPreferences: ProductPreferences;
  currentPreferences: UserPreferences;
  today: string;
  adaptationProfile: AdaptationProfile | null;
  accountId?: string | null;
}) {
  const { goal, milestones, tasks, mergedPreferences, composer } = await createGoalArtifacts(params);
  const goals = await appServices.repositories.goals.listGoals();
  const existingMilestones = await appServices.repositories.goals.listMilestones();
  const calendarConnectionState =
    await appServices.repositories.integration.getCalendarConnectionState();
  const scheduleConstraints =
    await appServices.repositories.integration.listScheduleConstraintsForDate(params.today);
  const schedule = await appServices.engines.scheduling.buildSchedule({
    date: params.today,
    goals: [...goals, goal],
    milestones: [...existingMilestones, ...milestones],
    tasks: tasks.filter((task) => task.targetDate === params.today),
    constraints: scheduleConstraints,
    preferences: mergedPreferences,
    adaptationProfile: params.adaptationProfile,
    existingPlan: null,
  });
  const persistedTasks = assignScheduledTaskState(tasks, schedule.payload.timeBlocks, params.today);
  const suggestions =
    (
      await appServices.engines.replanning.suggestAdjustments({
        date: params.today,
        goals: [...goals, goal],
        milestones: [...existingMilestones, ...milestones],
        tasks: persistedTasks.filter((task) => task.targetDate === params.today),
        constraints: scheduleConstraints,
        preferences: mergedPreferences,
        adaptationProfile: params.adaptationProfile,
        dailyPlan: schedule.payload.dailyPlan,
        timeBlocks: schedule.payload.timeBlocks,
      })
    ).payload.suggestions ?? [];

  await appServices.repositories.preferences.saveUserPreferences(
    bindToAccount(mergedPreferences, params.accountId ?? null),
  );
  await appServices.repositories.goals.saveGoals([
    bindToAccount(goal, params.accountId ?? null),
    ...goals.map((entry, index) => ({ ...entry, sortOrder: index + 2 })),
  ]);
  await appServices.repositories.goals.saveMilestones(
    milestones.map((milestone) => bindToAccount(milestone, params.accountId ?? null)),
  );
  await appServices.repositories.tasks.saveTasks(
    persistedTasks.map((task) => bindToAccount(task, params.accountId ?? null)),
  );
  await appServices.repositories.planning.saveDailyPlans([
    bindToAccount(schedule.payload.dailyPlan, params.accountId ?? null),
  ]);
  await appServices.repositories.planning.saveTimeBlocks(
    schedule.payload.timeBlocks.map((block) => bindToAccount(block, params.accountId ?? null)),
  );
  await appServices.repositories.adaptation.replaceReplanSuggestions(params.today, suggestions);

  return {
    goal,
    milestones,
    tasks: persistedTasks,
    composer,
    dailyPlan: schedule.payload.dailyPlan,
    timeBlocks: schedule.payload.timeBlocks,
    suggestions,
    calendarConnectionState,
  };
}
