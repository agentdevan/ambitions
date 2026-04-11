import {
  AdaptationProfile,
  CapacityLoad,
  DailyPlan,
  ReplanSuggestionType,
  TaskActionType,
  ReplanSuggestion,
  ScheduleConstraint,
  Task,
  TaskStatus,
  TimeBlock,
  TimeBlockState,
} from "../../domain/models";
import { SchedulingOutput } from "../../engines";

export interface TodayTaskBlock {
  id: string;
  taskId: string | null;
  title: string;
  startsAt: string;
  endsAt: string;
  state: TimeBlock["state"];
  note: string | null;
  taskStatus: TaskStatus | null;
  estimatedMinutes: number | null;
  actions: TaskActionType[];
}

export interface TodayRecoveryTask {
  taskId: string;
  title: string;
  estimatedMinutes: number;
  reason: string;
  status: TaskStatus;
}

export interface TodaySuggestion {
  id: string;
  type: ReplanSuggestionType;
  title: string;
  rationale: string;
  taskTitle: string | null;
}

export interface TodayViewModel {
  date: string;
  focus: string;
  capacity: {
    mentalLoad: AdaptationProfile["capacity"]["mentalLoad"];
    focusBudgetMinutes: number;
    meetingLoadMinutes: number;
    recoveryBudgetMinutes: number;
    usableMinutes: number;
    unusedCapacityMinutes: number;
    confidence: number;
    planPressure: SchedulingOutput["signals"]["planPressure"];
    overloadWarning: boolean;
  };
  blocks: TodayTaskBlock[];
  unscheduled: TodayRecoveryTask[];
  replanSuggestions: TodaySuggestion[];
  scheduleContext: Array<{ label: string; value: string }>;
  adaptiveGuidance: string[];
  progress: {
    completed: number;
    scheduled: number;
    recovery: number;
  };
}

function actionsForTask(task: Task | undefined): TaskActionType[] {
  if (!task) {
    return [];
  }

  if (task.status === TaskStatus.InProgress) {
    return [TaskActionType.Complete, TaskActionType.Defer];
  }

  if ([TaskStatus.Completed, TaskStatus.Cancelled].includes(task.status)) {
    return [];
  }

  return [TaskActionType.Start, TaskActionType.Complete, TaskActionType.Miss, TaskActionType.Defer];
}

export function buildTodayViewModel(params: {
  date: string;
  dailyPlan: DailyPlan | null;
  blocks: TimeBlock[];
  schedule: SchedulingOutput | null;
  profile: AdaptationProfile | null;
  suggestions: ReplanSuggestion[];
  constraints: ScheduleConstraint[];
  tasks: Task[];
}): TodayViewModel {
  const tasksById = new Map(params.tasks.map((task) => [task.id, task]));
  const completed = params.blocks.filter((block) => block.state === TimeBlockState.Complete).length;
  const scheduled = params.blocks.filter((block) =>
    [TimeBlockState.Scheduled, TimeBlockState.Active].includes(block.state),
  ).length;
  const recovery = params.tasks.filter((task) =>
    [TaskStatus.Missed, TaskStatus.Split, TaskStatus.Substituted, TaskStatus.Deferred].includes(
      task.status,
    ),
  ).length;
  const latestFinish = params.blocks
    .map((block) => block.endsAt)
    .sort((left, right) => left.localeCompare(right))
    .at(-1);
  const plannedTaskIds = new Set(params.blocks.map((block) => block.taskId).filter(Boolean));
  const recoveryTasks = params.tasks
    .filter(
      (task) =>
        !plannedTaskIds.has(task.id) &&
        [
          TaskStatus.Unscheduled,
          TaskStatus.Missed,
          TaskStatus.Deferred,
          TaskStatus.Split,
          TaskStatus.Substituted,
          TaskStatus.Skipped,
        ].includes(task.status),
    )
    .map((task) => ({
      taskId: task.id,
      title: task.title,
      estimatedMinutes: task.estimatedMinutes,
      reason:
        String(task.metadata.recoveryRationale ?? "").trim() ||
        String(task.summary ?? "").trim() ||
        "Held out of the current day pending deliberate review.",
      status: task.status,
    }));
  const replanSuggestions = params.suggestions.map((suggestion) => ({
    id: suggestion.id,
    type: suggestion.type,
    title: suggestion.title,
    rationale: suggestion.rationale,
    taskTitle: suggestion.taskId ? tasksById.get(suggestion.taskId)?.title ?? null : null,
  }));

  return {
    date: params.date,
    focus:
      params.dailyPlan?.focus ??
      "Hold the shape of the day steady instead of trying to optimize every minute.",
    capacity: {
      mentalLoad: params.profile?.capacity.mentalLoad ?? CapacityLoad.Balanced,
      focusBudgetMinutes:
        params.schedule?.capacitySummary.scheduledMinutes ??
        params.profile?.capacity.focusBudgetMinutes ??
        0,
      meetingLoadMinutes:
        params.profile?.capacity.meetingLoadMinutes ??
        params.constraints.reduce((sum, constraint) => {
          const start = new Date(constraint.startsAt).getTime();
          const end = new Date(constraint.endsAt).getTime();
          return sum + Math.max(0, Math.round((end - start) / 60000));
        }, 0),
      recoveryBudgetMinutes:
        params.profile?.capacity.recoveryBudgetMinutes ??
        params.schedule?.usableWindows
          .filter((window) => window.kind === "gap")
          .reduce((sum, window) => sum + Math.min(window.minutes, 20), 0) ??
        0,
      usableMinutes: params.schedule?.capacitySummary.totalUsableMinutes ?? 0,
      unusedCapacityMinutes: params.schedule?.capacitySummary.unusedCapacityMinutes ?? 0,
      confidence: params.schedule?.signals.schedulingConfidence ?? 0.6,
      planPressure: params.schedule?.signals.planPressure ?? "low",
      overloadWarning: params.schedule?.signals.overloadWarning ?? false,
    },
    blocks: params.blocks.map((block) => {
      const linkedTask = block.taskId ? tasksById.get(block.taskId) : undefined;

      return {
        id: block.id,
        taskId: block.taskId,
        title: block.title,
        startsAt: block.startsAt,
        endsAt: block.endsAt,
        state: block.state,
        note: linkedTask?.summary ?? block.note,
        taskStatus: linkedTask?.status ?? null,
        estimatedMinutes: linkedTask?.estimatedMinutes ?? null,
        actions: actionsForTask(linkedTask),
      };
    }),
    unscheduled: recoveryTasks,
    replanSuggestions,
    scheduleContext: [
      {
        label: "Usable windows",
        value: params.schedule
          ? `${params.schedule.usableWindows.length} windows, ${params.schedule.capacitySummary.totalUsableMinutes} min`
          : "Not derived yet",
      },
      {
        label: "Hard constraints",
        value: params.schedule
          ? String(params.schedule.context.hardConstraintCount)
          : String(params.constraints.length),
      },
      {
        label: "Last realistic finish",
        value: latestFinish ? `${latestFinish} without overload` : "Open-ended",
      },
    ],
    adaptiveGuidance:
      recoveryTasks.length > 0
        ? recoveryTasks.slice(0, 3).map((task) => task.reason)
        : replanSuggestions.length > 0
          ? replanSuggestions.map((suggestion) => suggestion.rationale)
          : params.schedule && params.schedule.unscheduledTasks.length > 0
            ? params.schedule.unscheduledTasks.slice(0, 3).map((task) => task.reason)
            : [],
    progress: {
      completed,
      scheduled,
      recovery,
    },
  };
}
