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
  Task,
  TaskSchedulingState,
  TaskStatus,
  TimeBlock,
  UserPreferences,
} from "../domain/models";
import { appServices } from "../bootstrap/runtime/appServices";
import { GoalDraftInference, ProductPreferences } from "./types";
import { mergeProductPreferences } from "./preferences";

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
      intakeSource: "phase8_onboarding",
      naturalLanguage: inference.naturalLanguage,
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
  const goal = createGoalRecord(
    params.inference,
    mergedPreferences.metadata.focusDomains
      ? String(mergedPreferences.metadata.focusDomains)
          .split(",")
          .filter((entry): entry is DomainKey =>
            Object.values(DomainKey).includes(entry as DomainKey),
          )
      : params.inference.focusDomains,
    params.today,
  );
  const decomposition = await appServices.engines.decomposition.decompose({
    goal,
    milestones: [],
    existingTasks: [],
    preferences: mergedPreferences,
    adaptationProfile: params.adaptationProfile,
    referenceDate: params.today,
  });
  const milestones = adjustMilestones(goal, decomposition.payload.milestones, params.today);
  const tasks = adjustTasks(goal, milestones, decomposition.payload.tasks, params.today);

  return {
    goal,
    milestones,
    tasks,
    mergedPreferences,
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
  const { goal, milestones, tasks, mergedPreferences } = await createGoalArtifacts(params);
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
    dailyPlan: schedule.payload.dailyPlan,
    timeBlocks: schedule.payload.timeBlocks,
    suggestions,
    calendarConnectionState,
  };
}
