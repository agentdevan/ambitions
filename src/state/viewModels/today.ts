import {
  AdaptationProfile,
  CapacityLoad,
  DailyPlan,
  ReplanSuggestion,
  ScheduleConstraint,
  Task,
  TimeBlock,
  TimeBlockState,
} from "../../domain/models";
import { SchedulingOutput } from "../../engines";

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
  blocks: TimeBlock[];
  unscheduled: SchedulingOutput["unscheduledTasks"];
  scheduleContext: Array<{ label: string; value: string }>;
  adaptiveGuidance: string[];
  progress: {
    completed: number;
    scheduled: number;
    rolled: number;
  };
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
  const completed = params.blocks.filter((block) => block.state === TimeBlockState.Complete).length;
  const scheduled = params.blocks.filter((block) =>
    [TimeBlockState.Scheduled, TimeBlockState.Active].includes(block.state),
  ).length;
  const rolled = params.tasks.filter((task) => task.schedulingState === "rolled").length;
  const latestFinish = params.blocks
    .map((block) => block.endsAt)
    .sort((left, right) => left.localeCompare(right))
    .at(-1);

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
    blocks: params.blocks,
    unscheduled: params.schedule?.unscheduledTasks ?? [],
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
      params.schedule && params.schedule.unscheduledTasks.length > 0
        ? params.schedule.unscheduledTasks.slice(0, 3).map((task) => task.reason)
        : params.suggestions.length > 0
          ? params.suggestions.map((suggestion) => suggestion.rationale)
          : params.tasks
              .filter((task) => task.schedulingState === "rolled")
              .map(
                (task) =>
                  `Keep rollover visible without letting ${task.title.toLowerCase()} take over the day.`,
              ),
    progress: {
      completed,
      scheduled,
      rolled,
    },
  };
}
