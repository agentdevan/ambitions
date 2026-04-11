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

export interface TodayViewModel {
  date: string;
  focus: string;
  capacity: AdaptationProfile["capacity"];
  blocks: TimeBlock[];
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
  profile: AdaptationProfile | null;
  suggestions: ReplanSuggestion[];
  constraints: ScheduleConstraint[];
  tasks: Task[];
}): TodayViewModel {
  const completed = params.blocks.filter((block) => block.state === TimeBlockState.Complete).length;
  const scheduled = params.blocks.filter((block) =>
    [TimeBlockState.Scheduled, TimeBlockState.Active].includes(block.state),
  ).length;
  const rolled = params.blocks.filter((block) => block.state === TimeBlockState.Rolled).length;
  const totalConstraintMinutes = params.constraints.reduce((sum, constraint) => {
    const start = new Date(constraint.startsAt).getTime();
    const end = new Date(constraint.endsAt).getTime();
    return sum + Math.max(0, Math.round((end - start) / 60000));
  }, 0);
  const deepBlock = params.blocks.find((block) => block.energyLabel === "deep");
  const latestFinish = params.blocks
    .map((block) => block.endsAt)
    .sort((left, right) => left.localeCompare(right))
    .at(-1);

  return {
    date: params.date,
    focus:
      params.dailyPlan?.focus ??
      "Hold the shape of the day steady instead of trying to optimize every minute.",
    capacity:
      params.profile?.capacity ?? {
        mentalLoad: CapacityLoad.Balanced,
        focusBudgetMinutes: 0,
        meetingLoadMinutes: 0,
        recoveryBudgetMinutes: 0,
      },
    blocks: params.blocks,
    scheduleContext: [
      {
        label: "Existing events",
        value:
          params.constraints.length > 0
            ? `${params.constraints.length} events, ${totalConstraintMinutes} min total`
            : "No imported events yet",
      },
      {
        label: "Best deep work window",
        value: deepBlock ? `${deepBlock.startsAt}-${deepBlock.endsAt}` : "Not planned yet",
      },
      {
        label: "Last realistic finish",
        value: latestFinish ? `${latestFinish} without overload` : "Open-ended",
      },
    ],
    adaptiveGuidance:
      params.suggestions.map((suggestion) => suggestion.rationale) ??
      params.tasks
        .filter((task) => task.schedulingState === "rolled")
        .map((task) => `Keep rollover visible without letting ${task.title.toLowerCase()} take over the day.`),
    progress: {
      completed,
      scheduled,
      rolled,
    },
  };
}
