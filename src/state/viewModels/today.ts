import {
  AdaptationProfile,
  CalendarConnectionState,
  CalendarPermissionState,
  CalendarSyncState,
  CapacityLoad,
  DailyPlan,
  Goal,
  GoalStatus,
  ReplanSuggestionType,
  TaskActionType,
  ReplanSuggestion,
  ScheduleConstraint,
  Task,
  TaskDifficulty,
  TaskStatus,
  TimeBlock,
  TimeBlockState,
} from "../../domain/models";
import { SchedulingOutput } from "../../engines";
import { formatTimeLabel, getCurrentLocalDateString } from "../../utils/date";

export interface TodayTaskBlock {
  id: string;
  taskId: string | null;
  title: string;
  startsAt: string;
  endsAt: string;
  startsAtDateTime: string;
  endsAtDateTime: string;
  state: TimeBlock["state"];
  note: string | null;
  taskStatus: TaskStatus | null;
  type: TimeBlock["type"];
  energyLabel: TimeBlock["energyLabel"];
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

export type TodayFreeWindowBucket = "tiny" | "short" | "meaningful" | "spacious";
export type TodayStatusMode =
  | "in_block"
  | "short_window"
  | "surplus_window"
  | "light_day"
  | "overloaded_day"
  | "no_next";

export interface TodayOpportunityOption {
  taskId: string;
  title: string;
  goalId: string | null;
  goalTitle: string | null;
  status: TaskStatus;
  difficulty: TaskDifficulty;
  estimatedMinutes: number;
  reason: string;
  fitLabel: string;
  suggestedAction: TaskActionType;
  actionLabel: string;
}

export interface TodayOpenWindow {
  availableMinutes: number;
  bucket: TodayFreeWindowBucket;
  label: string;
  detail: string;
  nextStartsAt: string | null;
  nextStartsInMinutes: number | null;
  opensUntilLabel: string | null;
}

export interface TodayRecommendation {
  kind:
    | "stay_on_current_block"
    | "quick_win"
    | "meaningful_session"
    | "continue_in_progress"
    | "protect_recovery"
    | "no_fit";
  title: string;
  summary: string;
  emphasis: string;
  primaryLabel: string;
  secondaryLabel: string | null;
  taskId: string | null;
  blockId: string | null;
  suggestedAction: TaskActionType | null;
  options: TodayOpportunityOption[];
}

export interface TodayStatusSnapshot {
  mode: TodayStatusMode;
  eyebrow: string;
  title: string;
  detail: string;
  warmth: string;
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
  now: TodayTaskBlock | null;
  next: TodayTaskBlock | null;
  status: TodayStatusSnapshot;
  openWindow: TodayOpenWindow | null;
  recommendation: TodayRecommendation;
  timelinePreview: TodayTaskBlock[];
  unscheduled: TodayRecoveryTask[];
  replanSuggestions: TodaySuggestion[];
  scheduleContext: Array<{ label: string; value: string }>;
  adaptiveGuidance: string[];
  progress: {
    completed: number;
    scheduled: number;
    recovery: number;
  };
  integration: {
    usingLiveCalendar: boolean;
    calendarStatusLabel: string;
    calendarDetail: string;
  };
}

function calendarStatus(connectionState: CalendarConnectionState | null, constraintCount: number) {
  if (!connectionState || connectionState.permissionState === CalendarPermissionState.NotAsked) {
    return {
      usingLiveCalendar: false,
      calendarStatusLabel: "Calendar not connected",
      calendarDetail: "Today is using fallback schedule context until calendar access is granted.",
    };
  }

  if (connectionState.permissionState === CalendarPermissionState.Denied) {
    return {
      usingLiveCalendar: false,
      calendarStatusLabel: "Calendar access denied",
      calendarDetail: "The planner stayed on fallback context because calendar access is off.",
    };
  }

  if (connectionState.connectionStatus === CalendarSyncState.NoUsableCalendars) {
    return {
      usingLiveCalendar: false,
      calendarStatusLabel: "No usable calendars",
      calendarDetail: "Permission is granted, but there were no visible calendars to read from.",
    };
  }

  if (connectionState.connectionStatus === CalendarSyncState.Ready) {
    return {
      usingLiveCalendar: true,
      calendarStatusLabel: "Live calendar context",
      calendarDetail:
        constraintCount > 0
          ? `Today is using ${constraintCount} live calendar-derived constraints.`
          : "Today is using live calendar context and found no blocking events.",
    };
  }

  if (connectionState.connectionStatus === CalendarSyncState.Stale) {
    return {
      usingLiveCalendar: false,
      calendarStatusLabel: "Calendar read is stale",
      calendarDetail: "The latest calendar read failed, so the planner kept the safer fallback context.",
    };
  }

  return {
    usingLiveCalendar: false,
    calendarStatusLabel: "Calendar temporarily unavailable",
    calendarDetail: "The latest calendar read failed, so the planner stayed conservative.",
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

function minutesBetween(start: string, end: string) {
  const startMs = Date.parse(start);
  const endMs = Date.parse(end);

  if (Number.isNaN(startMs) || Number.isNaN(endMs)) {
    return 0;
  }

  return Math.max(0, Math.round((endMs - startMs) / 60000));
}

function formatMinutesLabel(minutes: number) {
  if (minutes <= 0) {
    return "No open time";
  }

  if (minutes < 60) {
    return `${minutes} min`;
  }

  const hours = Math.floor(minutes / 60);
  const remaining = minutes % 60;

  if (remaining === 0) {
    return `${hours} hr`;
  }

  return `${hours} hr ${remaining} min`;
}

function bucketOpenWindow(minutes: number): TodayFreeWindowBucket {
  if (minutes < 10) {
    return "tiny";
  }

  if (minutes < 25) {
    return "short";
  }

  if (minutes < 50) {
    return "meaningful";
  }

  return "spacious";
}

function buildOpenWindow(params: {
  availableMinutes: number;
  nextBlock: TimeBlock | null;
}): TodayOpenWindow | null {
  if (params.availableMinutes <= 0) {
    return null;
  }

  const bucket = bucketOpenWindow(params.availableMinutes);
  const detailByBucket: Record<TodayFreeWindowBucket, string> = {
    tiny: "Tiny gap. Keep it light or reset.",
    short: "Short, usable gap before the next block.",
    meaningful: "Enough room for a real useful step.",
    spacious: "A wide open stretch is available.",
  };

  return {
    availableMinutes: params.availableMinutes,
    bucket,
    label:
      bucket === "spacious"
        ? `${formatMinutesLabel(params.availableMinutes)} open`
        : `${params.availableMinutes} quiet min`,
    detail: detailByBucket[bucket],
    nextStartsAt: params.nextBlock?.startsAt ?? null,
    nextStartsInMinutes: params.nextBlock
      ? minutesBetween(new Date().toISOString(), params.nextBlock.startsAtDateTime)
      : null,
    opensUntilLabel: params.nextBlock ? formatTimeLabel(params.nextBlock.startsAt) : null,
  };
}

function actionForOpportunity(task: Task): {
  suggestedAction: TaskActionType;
  actionLabel: string;
} {
  if (task.status === TaskStatus.InProgress) {
    return {
      suggestedAction: TaskActionType.Complete,
      actionLabel: "Finish this step",
    };
  }

  return {
    suggestedAction: TaskActionType.Start,
    actionLabel: "Start this task",
  };
}

function rankOpportunity(params: {
  task: Task;
  goal: Goal | null;
  nextBlock: TimeBlock | null;
  availableMinutes: number;
  overloaded: boolean;
  bucket: TodayFreeWindowBucket | null;
}) {
  const { task, goal, nextBlock, availableMinutes, overloaded, bucket } = params;
  const baseByStatus: Record<TaskStatus, number> = {
    [TaskStatus.Inbox]: 15,
    [TaskStatus.Ready]: 88,
    [TaskStatus.Unscheduled]: 66,
    [TaskStatus.Scheduled]: 82,
    [TaskStatus.InProgress]: 112,
    [TaskStatus.Completed]: -999,
    [TaskStatus.Skipped]: 20,
    [TaskStatus.Missed]: 42,
    [TaskStatus.Deferred]: 54,
    [TaskStatus.Split]: 58,
    [TaskStatus.Substituted]: 56,
    [TaskStatus.Cancelled]: -999,
  };

  let score = baseByStatus[task.status] ?? 0;

  if (goal?.status === GoalStatus.Active) {
    score += 12;
    score += Math.max(0, 8 - goal.sortOrder);
  }

  if (nextBlock?.taskId === task.id) {
    score += 20;
  }

  const closeness = Math.max(0, 26 - Math.abs(availableMinutes - task.estimatedMinutes));
  score += closeness;

  if (availableMinutes < task.estimatedMinutes) {
    score -= 120;
  }

  if (bucket === "tiny" && task.estimatedMinutes > 8) {
    score -= 80;
  }

  if (bucket === "short" && task.estimatedMinutes > 20) {
    score -= 42;
  }

  if (bucket === "meaningful" && task.estimatedMinutes >= 25) {
    score += 10;
  }

  if (bucket === "spacious" && task.estimatedMinutes >= 35) {
    score += 16;
  }

  if (task.difficulty === TaskDifficulty.Deep) {
    score += bucket === "spacious" ? 12 : bucket === "meaningful" ? 3 : -24;
  } else if (task.difficulty === TaskDifficulty.Light) {
    score += bucket === "tiny" || bucket === "short" ? 14 : 4;
  }

  if (overloaded) {
    score += task.difficulty === TaskDifficulty.Light ? 12 : -18;
  }

  return score;
}

function buildOpportunityReason(params: {
  task: Task;
  nextBlock: TimeBlock | null;
  availableMinutes: number;
  bucket: TodayFreeWindowBucket;
  overloaded: boolean;
}) {
  const { task, nextBlock, availableMinutes, bucket, overloaded } = params;

  if (task.status === TaskStatus.InProgress) {
    return {
      summary: "Already moving. This is the cleanest thing to finish from here.",
      fitLabel: "Already in motion",
    };
  }

  if (nextBlock?.taskId === task.id) {
    return {
      summary: `It is already next in the plan and fits before ${formatTimeLabel(nextBlock.startsAt)}.`,
      fitLabel: "Already next",
    };
  }

  if (overloaded) {
    return {
      summary: "The day is tight, so this is the lightest useful move that still counts.",
      fitLabel: "Keeps the day calm",
    };
  }

  if (bucket === "tiny" || bucket === "short") {
    return {
      summary: `Short enough to finish inside this ${availableMinutes}-minute window.`,
      fitLabel: "Fits cleanly",
    };
  }

  return {
    summary:
      task.difficulty === TaskDifficulty.Deep
        ? "There is enough room here to make real progress without rushing the start."
        : "A strong fit for this opening without turning it into a scramble.",
    fitLabel: task.difficulty === TaskDifficulty.Deep ? "Room for depth" : "Good fit",
  };
}

function buildOpportunityOptions(params: {
  tasks: Task[];
  goals: Goal[];
  blocks: TimeBlock[];
  openWindow: TodayOpenWindow | null;
  overloadWarning: boolean;
}) {
  const { tasks, goals, blocks, openWindow, overloadWarning } = params;
  const nextBlock =
    blocks.find((block) => block.state === TimeBlockState.Scheduled) ??
    blocks.find((block) => block.state === TimeBlockState.Rolled) ??
    null;

  if (!openWindow) {
    return [];
  }

  const goalsById = new Map(goals.map((goal) => [goal.id, goal]));

  return tasks
    .filter((task) =>
      [
        TaskStatus.Ready,
        TaskStatus.Scheduled,
        TaskStatus.InProgress,
        TaskStatus.Unscheduled,
        TaskStatus.Deferred,
        TaskStatus.Split,
        TaskStatus.Substituted,
        TaskStatus.Missed,
      ].includes(task.status),
    )
    .filter((task) => task.estimatedMinutes > 0)
    .map((task) => {
      const goal = task.goalId ? goalsById.get(task.goalId) ?? null : null;
      const { summary, fitLabel } = buildOpportunityReason({
        task,
        nextBlock,
        availableMinutes: openWindow.availableMinutes,
        bucket: openWindow.bucket,
        overloaded: overloadWarning,
      });
      const action = actionForOpportunity(task);

      return {
        taskId: task.id,
        title: task.title,
        goalId: task.goalId,
        goalTitle: goal?.title ?? null,
        status: task.status,
        difficulty: task.difficulty,
        estimatedMinutes: task.estimatedMinutes,
        reason: summary,
        fitLabel,
        suggestedAction: action.suggestedAction,
        actionLabel: action.actionLabel,
        score: rankOpportunity({
          task,
          goal,
          nextBlock,
          availableMinutes: openWindow.availableMinutes,
          overloaded: overloadWarning,
          bucket: openWindow.bucket,
        }),
      };
    })
    .filter((option) => option.score > 0)
    .sort((left, right) => right.score - left.score)
    .slice(0, 3)
    .map(({ score: _score, ...option }) => option);
}

function buildStatusSnapshot(params: {
  activeBlock: TimeBlock | null;
  nextBlock: TimeBlock | null;
  openWindow: TodayOpenWindow | null;
  unusedCapacityMinutes: number;
  overloadWarning: boolean;
  focus: string;
}): TodayStatusSnapshot {
  const { activeBlock, nextBlock, openWindow, unusedCapacityMinutes, overloadWarning } = params;
  const lightDay = unusedCapacityMinutes >= 90;

  if (activeBlock) {
    return {
      mode: "in_block",
      eyebrow: "Now",
      title: "You’re in the middle of the main block.",
      detail: `This session runs until ${formatTimeLabel(activeBlock.endsAt)}.`,
      warmth: nextBlock
        ? `Next up at ${formatTimeLabel(nextBlock.startsAt)}.`
        : "The rest of the day stays fairly open after this.",
    };
  }

  if (overloadWarning && (!openWindow || openWindow.availableMinutes < 12)) {
    return {
      mode: "overloaded_day",
      eyebrow: "Today",
      title: "The day is already carrying enough.",
      detail: "Keep the next move light and avoid forcing extra work in.",
      warmth: nextBlock
        ? `Next block begins at ${formatTimeLabel(nextBlock.startsAt)}.`
        : "There is no strong next commitment yet.",
    };
  }

  if (openWindow && openWindow.availableMinutes > 0) {
    if (lightDay && !nextBlock && openWindow.availableMinutes >= 60) {
      return {
        mode: "light_day",
        eyebrow: "Open day",
        title: "There’s real room in today.",
        detail: `${openWindow.availableMinutes} minutes are still available.`,
        warmth: "Good time to choose one meaningful thing and let it breathe.",
      };
    }

    if (openWindow.bucket === "tiny" || openWindow.bucket === "short") {
      return {
        mode: "short_window",
        eyebrow: "Open time",
        title: `You have ${openWindow.availableMinutes} quiet minutes before the next block.`,
        detail: "Best used for a short useful step or a reset.",
        warmth: nextBlock
          ? `Next up at ${formatTimeLabel(nextBlock.startsAt)}.`
          : "There is no locked next block yet.",
      };
    }

    return {
      mode: lightDay ? "light_day" : "surplus_window",
      eyebrow: "Open time",
      title: `There’s room to make real progress here.`,
      detail: `${openWindow.availableMinutes} minutes are open right now.`,
      warmth: nextBlock
        ? `You still have time before ${formatTimeLabel(nextBlock.startsAt)}.`
        : "No strong next scheduled action yet, so you can choose intentionally.",
    };
  }

  return {
    mode: "no_next",
    eyebrow: "Today",
    title: "No strong next scheduled action yet.",
    detail: "The plan is steady, but this part of the day is still flexible.",
    warmth: lightDay
      ? "That space can stay open or become a meaningful work session."
      : "If nothing sensible fits, protect the gap instead of filling it.",
  };
}

function buildRecommendation(params: {
  activeBlock: TodayTaskBlock | null;
  nextBlock: TodayTaskBlock | null;
  openWindow: TodayOpenWindow | null;
  options: TodayOpportunityOption[];
  overloadWarning: boolean;
}): TodayRecommendation {
  const { activeBlock, nextBlock, openWindow, options, overloadWarning } = params;

  if (activeBlock) {
    return {
      kind: "stay_on_current_block",
      title: "Stay with the block you’re already in.",
      summary: activeBlock.note ?? "Momentum matters more than switching right now.",
      emphasis: nextBlock
        ? `Next up in ${Math.max(0, minutesBetween(new Date().toISOString(), nextBlock.startsAtDateTime))} min.`
        : `This session runs until ${formatTimeLabel(activeBlock.endsAt)}.`,
      primaryLabel: "Open current block",
      secondaryLabel: nextBlock ? "See what’s next" : null,
      taskId: activeBlock.taskId,
      blockId: activeBlock.id,
      suggestedAction: null,
      options: [],
    };
  }

  if (!openWindow) {
    return {
      kind: overloadWarning ? "protect_recovery" : "no_fit",
      title: overloadWarning ? "Nothing urgent fits. Protect the space." : "No clear fit yet.",
      summary: overloadWarning
        ? "A reset is better than squeezing in one more thing."
        : "Use the timeline when you need the next committed move.",
      emphasis: nextBlock
        ? `Next block at ${formatTimeLabel(nextBlock.startsAt)}.`
        : "The next move is still flexible.",
      primaryLabel: nextBlock ? "Open next block" : "View timeline",
      secondaryLabel: null,
      taskId: nextBlock?.taskId ?? null,
      blockId: nextBlock?.id ?? null,
      suggestedAction: null,
      options: [],
    };
  }

  const primary = options[0] ?? null;

  if (!primary) {
    return {
      kind: openWindow.bucket === "tiny" || overloadWarning ? "protect_recovery" : "no_fit",
      title:
        openWindow.bucket === "tiny" || overloadWarning
          ? "Nothing urgent fits. Protect the space and reset."
          : "No sensible fit for this window yet.",
      summary:
        openWindow.bucket === "tiny"
          ? "Keep this opening light instead of forcing a rushed start."
          : "Better to hold the window than start something that will spill.",
      emphasis: nextBlock
        ? `Next block begins at ${formatTimeLabel(nextBlock.startsAt)}.`
        : `${openWindow.availableMinutes} minutes are still open.`,
      primaryLabel: "See options",
      secondaryLabel: nextBlock ? "Open next block" : null,
      taskId: null,
      blockId: null,
      suggestedAction: null,
      options: [],
    };
  }

  return {
    kind:
      primary.status === TaskStatus.InProgress
        ? "continue_in_progress"
        : openWindow.bucket === "meaningful" || openWindow.bucket === "spacious"
          ? "meaningful_session"
          : "quick_win",
    title:
      openWindow.bucket === "meaningful" || openWindow.bucket === "spacious"
        ? "Best use of this window"
        : "This window fits a quick win.",
    summary: primary.title,
    emphasis: primary.reason,
    primaryLabel: primary.actionLabel,
    secondaryLabel: options.length > 1 ? "See options" : nextBlock ? "Open timeline" : null,
    taskId: primary.taskId,
    blockId: null,
    suggestedAction: primary.suggestedAction,
    options,
  };
}

export function buildTodayViewModel(params: {
  date: string;
  dailyPlan: DailyPlan | null;
  goals: Goal[];
  blocks: TimeBlock[];
  schedule: SchedulingOutput | null;
  profile: AdaptationProfile | null;
  suggestions: ReplanSuggestion[];
  constraints: ScheduleConstraint[];
  tasks: Task[];
  calendarConnectionState: CalendarConnectionState | null;
}): TodayViewModel {
  const nowIso = new Date().toISOString();
  const isCurrentDate = params.date === getCurrentLocalDateString();
  const orderedBlocks = [...params.blocks].sort((left, right) =>
    left.startsAtDateTime.localeCompare(right.startsAtDateTime),
  );
  const tasksById = new Map(params.tasks.map((task) => [task.id, task]));
  const rawActiveBlock =
    orderedBlocks.find((block) => block.state === TimeBlockState.Active) ??
    (isCurrentDate
      ? orderedBlocks.find((block) => {
          const startsAt = Date.parse(block.startsAtDateTime);
          const endsAt = Date.parse(block.endsAtDateTime);
          const now = Date.parse(nowIso);
          return !Number.isNaN(startsAt) && !Number.isNaN(endsAt) && now >= startsAt && now < endsAt;
        }) ?? null
      : null);
  const futureBlocks = orderedBlocks.filter(
    (block) =>
      [TimeBlockState.Scheduled, TimeBlockState.Rolled, TimeBlockState.Deferred].includes(block.state) &&
      (!isCurrentDate || Date.parse(block.startsAtDateTime) > Date.parse(nowIso)),
  );
  const rawNextBlock = futureBlocks[0] ?? null;
  const openWindowMinutes =
    !rawActiveBlock && isCurrentDate && rawNextBlock
      ? Math.max(0, minutesBetween(nowIso, rawNextBlock.startsAtDateTime))
      : !rawActiveBlock && isCurrentDate
        ? Math.max(0, params.schedule?.signals.unusedCapacityMinutes ?? params.schedule?.capacitySummary.unusedCapacityMinutes ?? 0)
        : !rawActiveBlock && !isCurrentDate
          ? Math.max(0, params.schedule?.capacitySummary.unusedCapacityMinutes ?? 0)
          : 0;
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
  const adaptationNotes = params.profile
    ? [
        params.profile.regression.isRegressing
          ? "Recent execution has been less stable, so today stays intentionally lighter."
          : params.profile.strategy.strictness === "balanced"
            ? "Recent follow-through supports a slightly fuller plan without pushing the day."
            : "Today stays protective until recent execution supports a fuller day.",
        params.profile.planningDirectives.earlyWinBias
          ? "The plan is biased toward an early, easier win before heavier work."
          : null,
      ].filter((note): note is string => note !== null)
    : [];
  const integration = calendarStatus(
    params.calendarConnectionState,
    params.constraints.filter((constraint) => constraint.source === "calendar").length,
  );
  const openWindow = buildOpenWindow({
    availableMinutes: openWindowMinutes,
    nextBlock: rawNextBlock,
  });
  const opportunityOptions = buildOpportunityOptions({
    tasks: params.tasks,
    goals: params.goals,
    blocks: orderedBlocks,
    openWindow,
    overloadWarning: params.schedule?.signals.overloadWarning ?? false,
  });

  const mappedBlocks = orderedBlocks.map((block) => {
    const linkedTask = block.taskId ? tasksById.get(block.taskId) : undefined;

    return {
      id: block.id,
      taskId: block.taskId,
      title: block.title,
      startsAt: block.startsAt,
      endsAt: block.endsAt,
      startsAtDateTime: block.startsAtDateTime,
      endsAtDateTime: block.endsAtDateTime,
      state: block.state,
      note: linkedTask?.summary ?? block.note,
      taskStatus: linkedTask?.status ?? null,
      type: block.type,
      energyLabel: block.energyLabel,
      estimatedMinutes: linkedTask?.estimatedMinutes ?? null,
      actions: actionsForTask(linkedTask),
    };
  });
  const activeBlock = mappedBlocks.find((block) => block.id === rawActiveBlock?.id) ?? null;
  const nextBlock = mappedBlocks.find((block) => block.id === rawNextBlock?.id) ?? null;
  const timelinePreview = (() => {
    if (activeBlock) {
      const activeIndex = mappedBlocks.findIndex((block) => block.id === activeBlock.id);
      return mappedBlocks.slice(activeIndex, activeIndex + 4);
    }

    if (nextBlock) {
      const nextIndex = mappedBlocks.findIndex((block) => block.id === nextBlock.id);
      return mappedBlocks.slice(Math.max(0, nextIndex - 1), nextIndex + 3);
    }

    return mappedBlocks.slice(0, 4);
  })();
  const status = buildStatusSnapshot({
    activeBlock: rawActiveBlock,
    nextBlock: rawNextBlock,
    openWindow,
    unusedCapacityMinutes: params.schedule?.capacitySummary.unusedCapacityMinutes ?? 0,
    overloadWarning: params.schedule?.signals.overloadWarning ?? false,
    focus:
      params.dailyPlan?.focus ??
      "Hold the shape of the day steady instead of trying to optimize every minute.",
  });
  const recommendation = buildRecommendation({
    activeBlock,
    nextBlock,
    openWindow,
    options: opportunityOptions,
    overloadWarning: params.schedule?.signals.overloadWarning ?? false,
  });

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
    blocks: mappedBlocks,
    now: activeBlock,
    next: nextBlock,
    status,
    openWindow,
    recommendation,
    timelinePreview,
    unscheduled: recoveryTasks,
    replanSuggestions,
    scheduleContext: [
      {
        label: "Calendar context",
        value: integration.usingLiveCalendar ? "Live device calendar" : "Fallback schedule baseline",
      },
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
        value: latestFinish ? `${formatTimeLabel(latestFinish)} without overload` : "Open-ended",
      },
    ],
    adaptiveGuidance:
      adaptationNotes.length > 0
        ? adaptationNotes
        : recoveryTasks.length > 0
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
    integration,
  };
}
