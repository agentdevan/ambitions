import {
  AdaptationProfile,
  ActivityEvent,
  ActivityEventKind,
  CalendarConnectionState,
  CalendarPermissionState,
  CalendarSyncState,
  CapacityLoad,
  DailyPlan,
  DailyRitualCarryDecision,
  DailyRitualOpeningFocus,
  DailyRitualRecoveryMode,
  DailyRitualState,
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

export interface TodayOpeningOption {
  focus: DailyRitualOpeningFocus;
  label: string;
  description: string;
}

export interface TodayRecoveryOption {
  mode: DailyRitualRecoveryMode;
  label: string;
  description: string;
}

export interface TodayCloseSummary {
  completedCount: number;
  carriedCount: number;
  unfinishedCount: number;
  structuralChangeCount: number;
  defaultDecision: DailyRitualCarryDecision;
}

export interface TodayRitualSurface {
  kind: "opening" | "recovery" | "closeout";
  title: string;
  summary: string;
  detail: string;
  keyConstraint: string;
  primaryLabel: string;
  openingOptions?: TodayOpeningOption[];
  recommendedRecoveryMode?: DailyRitualRecoveryMode;
  recoveryOptions?: TodayRecoveryOption[];
  recoveryReasons?: string[];
  closeSummary?: TodayCloseSummary;
}

export interface TodayStatusSnapshot {
  mode: TodayStatusMode;
  eyebrow: string;
  title: string;
  detail: string;
  warmth: string;
}

export interface TodayWorkspaceSlot {
  label: string;
  title: string;
  detail: string;
  tone: "accent" | "neutral" | "quiet";
}

export interface TodayWorkspaceSummary {
  title: string;
  detail: string;
}

export interface TodayRecoverySnapshot {
  title: string;
  detail: string;
  impact: string;
}

export interface TodayWorkspaceDigest {
  now: TodayWorkspaceSlot;
  next: TodayWorkspaceSlot;
  later: TodayWorkspaceSlot;
  fixed: TodayWorkspaceSummary;
  flexible: TodayWorkspaceSummary;
  optional: TodayWorkspaceSummary | null;
  room: TodayWorkspaceSummary;
  changed: TodayWorkspaceSummary | null;
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
  workspace: TodayWorkspaceDigest;
  recoverySnapshot: TodayRecoverySnapshot | null;
  ritual: TodayRitualSurface | null;
}

function calendarStatus(connectionState: CalendarConnectionState | null, constraintCount: number) {
  if (!connectionState || connectionState.permissionState === CalendarPermissionState.NotAsked) {
    return {
      usingLiveCalendar: false,
      calendarStatusLabel: "Using saved defaults",
      calendarDetail: "Live calendar is off, so today's plan is using your saved schedule defaults.",
    };
  }

  if (connectionState.permissionState === CalendarPermissionState.Denied) {
    return {
      usingLiveCalendar: false,
      calendarStatusLabel: "Calendar access is off",
      calendarDetail: "Calendar access is off right now, so the planner stayed on your saved baseline.",
    };
  }

  if (connectionState.connectionStatus === CalendarSyncState.NoUsableCalendars) {
    return {
      usingLiveCalendar: false,
      calendarStatusLabel: "No visible calendars",
      calendarDetail: "Permission is ready, but there were no visible calendars to read from.",
    };
  }

  if (connectionState.connectionStatus === CalendarSyncState.Ready) {
    return {
      usingLiveCalendar: true,
      calendarStatusLabel: "Using live calendar",
      calendarDetail:
        constraintCount > 0
          ? `Today's plan is reacting to ${constraintCount} live calendar block${constraintCount === 1 ? "" : "s"}.`
          : "Live calendar checked in and found no blocking events.",
    };
  }

  if (connectionState.connectionStatus === CalendarSyncState.Stale) {
    return {
      usingLiveCalendar: false,
      calendarStatusLabel: "Calendar context is stale",
      calendarDetail: "The latest calendar refresh failed, so the planner fell back to your saved defaults.",
    };
  }

  return {
    usingLiveCalendar: false,
    calendarStatusLabel: "Connection issue",
    calendarDetail: "Live calendar could not be read right now, so the planner stayed on your safer defaults.",
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

function formatCountLabel(count: number, singular: string, plural = `${singular}s`) {
  return `${count} ${count === 1 ? singular : plural}`;
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
      actionLabel: "Finish step",
    };
  }

  return {
    suggestedAction: TaskActionType.Start,
    actionLabel: "Start next step",
  };
}

function rankOpportunity(params: {
  task: Task;
  goal: Goal | null;
  nextBlock: TimeBlock | null;
  availableMinutes: number;
  overloaded: boolean;
  bucket: TodayFreeWindowBucket | null;
  profile: AdaptationProfile | null;
  adaptiveEnabled: boolean;
}) {
  const {
    task,
    goal,
    nextBlock,
    availableMinutes,
    overloaded,
    bucket,
    profile,
    adaptiveEnabled,
  } = params;
  const personalization =
    adaptiveEnabled && profile?.personalization.active ? profile.personalization : null;
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

  if (personalization?.taskSizingStyle === "shorter_tasks") {
    score += task.estimatedMinutes <= 25 ? 14 : -22;
  } else if (personalization?.taskSizingStyle === "deeper_blocks") {
    score += task.difficulty === TaskDifficulty.Deep && availableMinutes >= task.estimatedMinutes ? 14 : 0;
  }

  if (personalization?.openWindowStyle === "short_bursts") {
    score += bucket === "tiny" || bucket === "short" ? 12 : task.estimatedMinutes <= 25 ? 6 : -8;
  } else if (personalization?.openWindowStyle === "deep_windows") {
    score += bucket === "meaningful" || bucket === "spacious" ? 8 : -10;
  }

  if (
    personalization &&
    personalization.lateDayStyle !== "steady" &&
    (task.difficulty === TaskDifficulty.Deep || task.estimatedMinutes >= 35)
  ) {
    const lateDayStyle = personalization.lateDayStyle;
    const nextWindowHour = Number((nextBlock?.startsAt ?? "18:00").slice(0, 2));

    if (nextWindowHour >= 17) {
      score -= lateDayStyle === "avoid_late_heavy" ? 24 : 12;
    }
  }

  return score;
}

function buildOpportunityReason(params: {
  task: Task;
  nextBlock: TimeBlock | null;
  availableMinutes: number;
  bucket: TodayFreeWindowBucket;
  overloaded: boolean;
  profile: AdaptationProfile | null;
  adaptiveEnabled: boolean;
}) {
  const { task, nextBlock, availableMinutes, bucket, overloaded, profile, adaptiveEnabled } = params;
  const personalization =
    adaptiveEnabled && profile?.personalization.active ? profile.personalization : null;

  if (task.status === TaskStatus.InProgress) {
    return {
      summary: "Already underway. Finishing it is the cleanest move.",
      fitLabel: "In motion",
    };
  }

  if (nextBlock?.taskId === task.id) {
    return {
      summary: `Already next in the plan and still fits before ${formatTimeLabel(nextBlock.startsAt)}.`,
      fitLabel: "Already next",
    };
  }

  if (overloaded) {
    return {
      summary: "A lighter useful move for a tighter day.",
      fitLabel: "Lower lift",
    };
  }

  if (
    personalization &&
    personalization.lateDayStyle !== "steady" &&
    (task.difficulty === TaskDifficulty.Deep || task.estimatedMinutes >= 35)
  ) {
    const lateDayStyle = personalization.lateDayStyle;
    return {
      summary:
        lateDayStyle === "avoid_late_heavy"
          ? "Better saved for an earlier or cleaner window."
          : "More realistic in an earlier, fresher window.",
      fitLabel: "Earlier fit",
    };
  }

  if (bucket === "tiny" || bucket === "short") {
    return {
      summary:
        personalization?.openWindowStyle === "short_bursts"
          ? "Short windows like this have been working well lately."
          : `Fits inside this ${availableMinutes}-minute window.`,
      fitLabel:
        personalization?.openWindowStyle === "short_bursts" ? "Short-window fit" : "Fits cleanly",
    };
  }

  if (personalization?.taskSizingStyle === "deeper_blocks" && task.difficulty === TaskDifficulty.Deep) {
    return {
      summary: "You tend to hold deeper work well when the window is real.",
      fitLabel: "Deeper fit",
    };
  }

  return {
    summary:
      task.difficulty === TaskDifficulty.Deep
        ? "Enough room here for a real work session."
        : "A strong fit for this opening without making it rushed.",
    fitLabel: task.difficulty === TaskDifficulty.Deep ? "Deep work" : "Strong fit",
  };
}

function buildOpportunityOptions(params: {
  tasks: Task[];
  goals: Goal[];
  blocks: TimeBlock[];
  openWindow: TodayOpenWindow | null;
  overloadWarning: boolean;
  profile: AdaptationProfile | null;
  adaptiveEnabled: boolean;
}) {
  const { tasks, goals, blocks, openWindow, overloadWarning, profile, adaptiveEnabled } = params;
  const nextBlock =
    blocks.find((block) => block.state === TimeBlockState.Scheduled) ??
    blocks.find((block) => block.state === TimeBlockState.Rolled) ??
    null;

  if (!openWindow) {
    return [];
  }

  const goalsById = new Map(goals.map((goal) => [goal.id, goal]));

  const rankedOptions = tasks
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
        profile,
        adaptiveEnabled,
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
          profile,
          adaptiveEnabled,
        }),
      };
    })
    .filter((option) => option.score > 0)
    .sort((left, right) => right.score - left.score);

  const seenTaskIds = new Set<string>();
  const seenTitles = new Set<string>();
  const dedupedOptions: TodayOpportunityOption[] = [];

  for (const { score: _score, ...option } of rankedOptions) {
    const normalizedTitle = option.title.trim().toLowerCase();

    if (seenTaskIds.has(option.taskId) || seenTitles.has(normalizedTitle)) {
      continue;
    }

    seenTaskIds.add(option.taskId);
    seenTitles.add(normalizedTitle);
    dedupedOptions.push(option);

    if (dedupedOptions.length === 3) {
      break;
    }
  }

  return dedupedOptions;
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
  profile: AdaptationProfile | null;
  adaptiveEnabled: boolean;
}): TodayRecommendation {
  const { activeBlock, nextBlock, openWindow, options, overloadWarning, profile, adaptiveEnabled } = params;
  const personalization =
    adaptiveEnabled && profile?.personalization.active ? profile.personalization : null;

  if (activeBlock) {
    return {
      kind: "stay_on_current_block",
      title: "Stay with the block you’re already in.",
      summary: activeBlock.title,
      emphasis: nextBlock
        ? `Keep this moving. Next up in ${Math.max(0, minutesBetween(new Date().toISOString(), nextBlock.startsAtDateTime))} min.`
        : activeBlock.note ?? `This session runs until ${formatTimeLabel(activeBlock.endsAt)}.`,
      primaryLabel: "Open current block",
      secondaryLabel: nextBlock ? "Open next block" : "Open timeline",
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
        ? "Hold the gap instead of forcing filler."
        : "Open the next committed move.",
      emphasis: nextBlock
        ? `Next block at ${formatTimeLabel(nextBlock.startsAt)}.`
        : "The next move is still flexible.",
      primaryLabel: nextBlock ? "Open next block" : "Open timeline",
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
          : "Better to hold this window than start something that spills over.",
      emphasis: nextBlock
        ? `Next block begins at ${formatTimeLabel(nextBlock.startsAt)}.`
        : `${openWindow.availableMinutes} minutes are still open.`,
      primaryLabel: "Use this time",
      secondaryLabel: nextBlock ? "Open next block" : "Open timeline",
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
        : personalization?.openWindowStyle === "short_bursts"
          ? "quick_win"
          : openWindow.bucket === "meaningful" || openWindow.bucket === "spacious"
            ? "meaningful_session"
            : "quick_win",
    title:
      personalization?.openWindowStyle === "short_bursts"
        ? "This window fits a short useful win."
        : openWindow.bucket === "meaningful" || openWindow.bucket === "spacious"
          ? "Best use of this window"
          : "This window fits a quick win.",
    summary: primary.title,
    emphasis: primary.reason,
    primaryLabel: primary.actionLabel,
    secondaryLabel: options.length > 1 ? "See options" : nextBlock ? "Open timeline" : "Use this time",
    taskId: primary.taskId,
    blockId: null,
    suggestedAction: primary.suggestedAction,
    options,
  };
}

function buildWorkspaceDigest(params: {
  activeBlock: TodayTaskBlock | null;
  nextBlock: TodayTaskBlock | null;
  futureBlocks: TodayTaskBlock[];
  openWindow: TodayOpenWindow | null;
  recommendation: TodayRecommendation;
  recoveryTasks: TodayRecoveryTask[];
  replanSuggestions: TodaySuggestion[];
  schedule: SchedulingOutput | null;
  progress: TodayViewModel["progress"];
}): TodayWorkspaceDigest {
  const {
    activeBlock,
    nextBlock,
    futureBlocks,
    openWindow,
    recommendation,
    recoveryTasks,
    replanSuggestions,
    schedule,
    progress,
  } = params;
  const now = new Date().toISOString();
  const laterBlocks = futureBlocks.filter((block) => block.id !== nextBlock?.id);
  const upcomingHardConstraints =
    schedule?.interpretedConstraints
      .filter((constraint) => constraint.disposition === "hard_constraint")
      .filter((constraint) => Date.parse(constraint.endsAt) >= Date.parse(now))
      .sort((left, right) => left.startsAt.localeCompare(right.startsAt)) ?? [];
  const nextHardConstraint = upcomingHardConstraints[0] ?? null;
  const unscheduledCount = schedule?.unscheduledTasks.length ?? 0;
  const optionalCount = recoveryTasks.length + unscheduledCount;
  const openMinutes =
    openWindow?.availableMinutes ?? schedule?.capacitySummary.unusedCapacityMinutes ?? 0;

  const nowSlot: TodayWorkspaceSlot = activeBlock
    ? {
        label: "Now",
        title: activeBlock.title,
        detail: `In motion until ${formatTimeLabel(activeBlock.endsAt)}.`,
        tone: "accent",
      }
    : openWindow
      ? {
          label: "Now",
          title:
            recommendation.taskId && recommendation.summary
              ? recommendation.summary
              : openWindow.bucket === "tiny"
                ? "Keep this opening light."
                : "The day is in a flexible window.",
          detail:
            recommendation.taskId && recommendation.emphasis
              ? recommendation.emphasis
              : openWindow.opensUntilLabel
                ? `Open until ${openWindow.opensUntilLabel}.`
                : openWindow.detail,
          tone: "accent",
        }
      : {
          label: "Now",
          title: "Nothing live is running.",
          detail: nextBlock
            ? `The next protected block starts at ${formatTimeLabel(nextBlock.startsAt)}.`
            : "This part of the day is still unsettled.",
          tone: "quiet",
        };

  const nextSlot: TodayWorkspaceSlot = nextBlock
    ? {
        label: "Next",
        title: nextBlock.title,
        detail:
          nextBlock.state === TimeBlockState.Rolled
            ? `Rolled into ${formatTimeLabel(nextBlock.startsAt)} and needs a clean restart.`
            : `Protected at ${formatTimeLabel(nextBlock.startsAt)}.`,
        tone: nextBlock.state === TimeBlockState.Rolled ? "quiet" : "neutral",
      }
    : nextHardConstraint
      ? {
          label: "Next",
          title: nextHardConstraint.title,
          detail: `Hard edge at ${formatTimeLabel(nextHardConstraint.startsAtTime)}.`,
          tone: "neutral",
        }
      : {
          label: "Next",
          title: "No hard next edge yet.",
          detail: "The next move is still yours to place deliberately.",
          tone: "quiet",
        };

  const laterSlot: TodayWorkspaceSlot = laterBlocks[0]
    ? {
        label: "Later",
        title:
          laterBlocks.length === 1
            ? laterBlocks[0].title
            : `${laterBlocks[0].title} and ${laterBlocks.length - 1} more`,
        detail:
          laterBlocks[0].state === TimeBlockState.Deferred
            ? "Later work has already shifted and is still movable."
            : `The later line of the day stays anchored after ${formatTimeLabel(laterBlocks[0].startsAt)}.`,
        tone: laterBlocks[0].state === TimeBlockState.Deferred ? "quiet" : "neutral",
      }
    : optionalCount > 0
      ? {
          label: "Later",
          title: `${formatCountLabel(optionalCount, "item")} stay negotiable`,
          detail:
            recoveryTasks.length > 0
              ? `${formatCountLabel(recoveryTasks.length, "item")} already sit outside the main line of today.`
              : "Optional work is being held back to keep the day believable.",
          tone: "quiet",
        }
      : {
          label: "Later",
          title: "The rest of today is fairly clean.",
          detail:
            progress.completed > 0
              ? `${formatCountLabel(progress.completed, "session")} already moved.`
              : "There is not much loose later work to re-read.",
          tone: "quiet",
        };

  const fixed: TodayWorkspaceSummary = nextBlock
    ? {
        title:
          upcomingHardConstraints.length > 0
            ? `${formatCountLabel(upcomingHardConstraints.length, "hard edge")} are holding today`
            : "The next protected block is the main hard edge",
        detail: `${nextBlock.title} starts at ${formatTimeLabel(nextBlock.startsAt)}.`,
      }
    : nextHardConstraint
      ? {
          title: `${nextHardConstraint.title} is the next hard edge`,
          detail: `It starts at ${formatTimeLabel(nextHardConstraint.startsAtTime)}.`,
        }
      : {
          title: "There is no strong fixed edge yet",
          detail: "The rest of the day is being held with a lighter hand.",
        };

  const flexible: TodayWorkspaceSummary = openWindow
    ? {
        title: `${formatMinutesLabel(openWindow.availableMinutes)} can still move`,
        detail:
          recommendation.taskId && recommendation.summary
            ? `${recommendation.summary} is the cleanest use of that room.`
            : openWindow.detail,
      }
    : laterBlocks.length > 0
      ? {
          title: `${formatCountLabel(laterBlocks.length, "later block")} can still flex`,
          detail: "The later part of today is shaped, but not all of it is locked.",
        }
      : {
          title: "Most of today's work is already placed",
          detail: "Following the next protected block is cleaner than reworking the whole day.",
        };

  const optional =
    optionalCount > 0
      ? {
          title: `${formatCountLabel(optionalCount, "item")} remain negotiable`,
          detail:
            recoveryTasks.length > 0
              ? `${formatCountLabel(recoveryTasks.length, "item")} are already in recovery or carry states.`
              : `${formatCountLabel(unscheduledCount, "item")} stayed out of the main plan on purpose.`,
        }
      : null;

  const room: TodayWorkspaceSummary =
    schedule?.signals.overloadWarning || openMinutes <= 15
      ? {
          title: openMinutes > 0 ? "Room is narrow now" : "The day is basically full",
          detail:
            openMinutes > 0
              ? `${formatMinutesLabel(openMinutes)} remain, so the next move needs restraint.`
              : "Anything extra should come from recovery, not stuffing more in.",
        }
      : openMinutes >= 90
        ? {
            title: "There is real room left",
            detail: `${formatMinutesLabel(openMinutes)} are still believable without stretching the day.`,
          }
        : {
            title: "There is usable room left",
            detail: `${formatMinutesLabel(openMinutes)} remain in the current day shape.`,
          };

  const latestSuggestion = replanSuggestions[0] ?? null;
  const changed: TodayWorkspaceSummary | null =
    latestSuggestion
      ? {
          title:
            replanSuggestions.length > 1
              ? `${formatCountLabel(replanSuggestions.length, "change")} are still asking for attention`
              : "One change is still asking for attention",
          detail: latestSuggestion.rationale,
        }
      : progress.completed > 0
        ? {
            title: `${formatCountLabel(progress.completed, "session")} already moved`,
            detail:
              progress.recovery > 0
                ? `${formatCountLabel(progress.recovery, "item")} still need a cleaner destination.`
                : "You can reopen without rereading the whole day.",
          }
        : null;

  return {
    now: nowSlot,
    next: nextSlot,
    later: laterSlot,
    fixed,
    flexible,
    optional,
    room,
    changed,
  };
}

function buildRecoverySnapshot(params: {
  ritual: TodayRitualSurface | null;
  ritualState: DailyRitualState | null;
  openWindow: TodayOpenWindow | null;
  nextBlock: TodayTaskBlock | null;
  recoveryCount: number;
}): TodayRecoverySnapshot | null {
  const { ritual, ritualState, openWindow, nextBlock, recoveryCount } = params;
  const latestRecovery = ritualState?.recoveryMoments.at(-1) ?? null;

  if (ritual?.kind === "recovery") {
    return {
      title: ritual.title,
      detail: ritual.summary,
      impact:
        ritual.recoveryReasons?.[0] ??
        (nextBlock
          ? `Recovery is trying to protect ${nextBlock.title} at ${formatTimeLabel(nextBlock.startsAt)}.`
          : "Recovery is trying to keep the rest of today believable."),
    };
  }

  if (latestRecovery) {
    return {
      title: "Recovery already happened earlier today.",
      detail: latestRecovery.summary,
      impact: nextBlock
        ? `The remaining line is now rebuilding toward ${nextBlock.title} at ${formatTimeLabel(nextBlock.startsAt)}.`
        : openWindow
          ? `The remaining day now has ${formatMinutesLabel(openWindow.availableMinutes)} of usable room.`
          : "The remaining day is already lighter than the original shape.",
    };
  }

  if (recoveryCount > 0) {
    return {
      title: `${formatCountLabel(recoveryCount, "item")} are slipping out of today's clean line.`,
      detail: "If the rest of the day no longer holds, use recovery once instead of starting over.",
      impact: nextBlock
        ? `The clean target is still ${nextBlock.title} at ${formatTimeLabel(nextBlock.startsAt)}.`
        : "The clean target is a lighter, believable rest of day.",
    };
  }

  return null;
}

const openingOptions: TodayOpeningOption[] = [
  {
    focus: DailyRitualOpeningFocus.ProtectEssentials,
    label: "Protect essentials",
    description: "Keep the day narrower and defensible.",
  },
  {
    focus: DailyRitualOpeningFocus.MeaningfulProgress,
    label: "Move one meaningful thing",
    description: "Bias toward the best substantive move.",
  },
  {
    focus: DailyRitualOpeningFocus.KeepItLight,
    label: "Keep it light",
    description: "Preserve energy and avoid overfilling the day.",
  },
];

const recoveryOptions: TodayRecoveryOption[] = [
  {
    mode: DailyRitualRecoveryMode.SalvageEssentials,
    label: "Salvage essentials",
    description: "Hold only what still deserves today.",
  },
  {
    mode: DailyRitualRecoveryMode.RebalanceToday,
    label: "Rebalance today",
    description: "Rebuild the remaining day around what still fits.",
  },
  {
    mode: DailyRitualRecoveryMode.LightenRest,
    label: "Lighten the rest",
    description: "Reduce pressure and keep the afternoon believable.",
  },
];

function buildKeyConstraint(params: {
  constraints: ScheduleConstraint[];
  schedule: SchedulingOutput | null;
  nextBlock: TimeBlock | null;
}) {
  const calendarConstraint = params.constraints
    .filter((constraint) => constraint.source === "calendar")
    .sort((left, right) => left.startsAt.localeCompare(right.startsAt))[0];

  if (params.schedule?.signals.overloadWarning) {
    return "Capacity is already tighter than the original day shape allows.";
  }

  if (calendarConstraint) {
    return `${calendarConstraint.title} is shaping the available room today.`;
  }

  if (params.nextBlock) {
    return `${params.nextBlock.title} sets the next hard edge at ${formatTimeLabel(params.nextBlock.startsAt)}.`;
  }

  return "The main constraint is staying realistic with the room that's actually left.";
}

function countStructuralChanges(events: ActivityEvent[], date: string, ritualState: DailyRitualState | null) {
  const eventChanges = events.filter(
    (event) =>
      event.date === date &&
      [
        ActivityEventKind.PlanReviewAccepted,
        ActivityEventKind.PlanReviewGenerated,
        ActivityEventKind.PlanReviewReverted,
        ActivityEventKind.GoalUpdated,
        ActivityEventKind.TaskRescheduled,
        ActivityEventKind.DayRecovered,
      ].includes(event.kind),
  ).length;

  return eventChanges + (ritualState?.recoveryMoments.length ?? 0);
}

function buildRitualSurface(params: {
  date: string;
  tasks: Task[];
  blocks: TimeBlock[];
  openWindow: TodayOpenWindow | null;
  recommendation: TodayRecommendation;
  ritualState: DailyRitualState | null;
  constraints: ScheduleConstraint[];
  schedule: SchedulingOutput | null;
  nextBlock: TimeBlock | null;
  activityEvents: ActivityEvent[];
}): TodayRitualSurface | null {
  const now = new Date();
  const currentDate = getCurrentLocalDateString();
  const nowMs = now.getTime();

  if (params.date !== currentDate) {
    return null;
  }

  const keyConstraint = buildKeyConstraint({
    constraints: params.constraints,
    schedule: params.schedule,
    nextBlock: params.nextBlock,
  });

  if (!params.ritualState?.openedAt) {
    return {
      kind: "opening",
      title: "Open the day with a clean read.",
      summary:
        params.recommendation.taskId && params.recommendation.summary
          ? `${params.schedule?.capacitySummary.unusedCapacityMinutes ?? 0} minutes still fit. ${params.recommendation.summary} is the first useful move.`
          : `${params.schedule?.capacitySummary.unusedCapacityMinutes ?? 0} minutes still fit today.`,
      detail: "A quick opening locks the day in without turning it into a setup ritual.",
      keyConstraint,
      primaryLabel: "Start today",
      openingOptions,
    };
  }

  if (params.ritualState.closedAt) {
    return null;
  }

  const overdueBlocks = params.blocks.filter((block) => {
    const startMs = Date.parse(block.startsAtDateTime);
    return (
      block.state === TimeBlockState.Scheduled &&
      !Number.isNaN(startMs) &&
      startMs < nowMs - 20 * 60 * 1000
    );
  });
  const carryTasks = params.tasks.filter((task) =>
    [TaskStatus.Deferred, TaskStatus.Missed, TaskStatus.Split, TaskStatus.Substituted].includes(
      task.status,
    ),
  );
  const latestRecoveryAt = params.ritualState.recoveryMoments.at(-1)?.occurredAt ?? null;
  const recoveredRecently =
    latestRecoveryAt !== null && nowMs - Date.parse(latestRecoveryAt) < 90 * 60 * 1000;

  const recoveryReasons: string[] = [];

  if (overdueBlocks.length > 0) {
    recoveryReasons.push(
      overdueBlocks.length === 1
        ? "The next planned block has already slipped."
        : `${overdueBlocks.length} planned blocks have slipped past their intended window.`,
    );
  }

  if (carryTasks.length >= 2) {
    recoveryReasons.push(
      `${carryTasks.length} pieces of work are already sitting in carryover states.`,
    );
  }

  if ((params.schedule?.signals.overloadWarning ?? false) && (params.openWindow?.availableMinutes ?? 0) >= 25) {
    recoveryReasons.push("There is still usable room left, but the original day shape is no longer believable.");
  }

  if (
    !recoveredRecently &&
    recoveryReasons.length > 0 &&
    (params.openWindow?.availableMinutes ?? 0) >= 15
  ) {
    const recommendedRecoveryMode =
      params.schedule?.signals.overloadWarning || (params.openWindow?.availableMinutes ?? 0) < 25
        ? DailyRitualRecoveryMode.LightenRest
        : carryTasks.length >= 3 || overdueBlocks.length >= 2
          ? DailyRitualRecoveryMode.SalvageEssentials
          : DailyRitualRecoveryMode.RebalanceToday;

    return {
      kind: "recovery",
      title: "The day has drifted. Reset it once, cleanly.",
      summary:
        recommendedRecoveryMode === DailyRitualRecoveryMode.SalvageEssentials
          ? "Keep only what still deserves today."
          : recommendedRecoveryMode === DailyRitualRecoveryMode.LightenRest
            ? "Reduce the rest of the day's pressure."
            : "Rebuild the remaining day around what still fits.",
      detail: "Ambitions can reshape the remaining work without making you rebuild the whole day by hand.",
      keyConstraint,
      primaryLabel: "Apply recovery",
      recommendedRecoveryMode,
      recoveryOptions,
      recoveryReasons,
    };
  }

  const completedCount = params.tasks.filter((task) => task.status === TaskStatus.Completed).length;
  const unfinishedTasks = params.tasks.filter((task) =>
    ![TaskStatus.Completed, TaskStatus.Cancelled].includes(task.status),
  );
  const carriedCount = unfinishedTasks.filter((task) =>
    [TaskStatus.Deferred, TaskStatus.Missed, TaskStatus.Split, TaskStatus.Substituted].includes(
      task.status,
    ),
  ).length;
  const latestBlockEnd = params.blocks
    .map((block) => Date.parse(block.endsAtDateTime))
    .filter((value) => !Number.isNaN(value))
    .sort((left, right) => right - left)[0];
  const showCloseout =
    now.getHours() >= 17 || (latestBlockEnd !== undefined && nowMs >= latestBlockEnd - 20 * 60 * 1000);

  if (!showCloseout) {
    return null;
  }

  return {
    kind: "closeout",
    title: "Close the day while it is still fresh.",
    summary:
      unfinishedTasks.length > 0
        ? `${completedCount} moved. ${unfinishedTasks.length} still need a deliberate next destination.`
        : `${completedCount} moved. The rest of the day is already clear.`,
    detail: "A short closeout captures what changed, what carried, and how the day actually felt.",
    keyConstraint,
    primaryLabel: "Close the day",
    closeSummary: {
      completedCount,
      carriedCount,
      unfinishedCount: unfinishedTasks.length,
      structuralChangeCount: countStructuralChanges(
        params.activityEvents,
        params.date,
        params.ritualState,
      ),
      defaultDecision:
        params.ritualState.carryDecisionSummary?.decision ?? DailyRitualCarryDecision.CarryForward,
    },
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
  adaptiveEnabled: boolean;
  ritualState: DailyRitualState | null;
  activityEvents: ActivityEvent[];
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
        params.adaptiveEnabled && params.profile.personalization.active
          ? params.profile.personalization.summary.todayApproach
          : params.profile.regression.isRegressing
            ? "Recent execution has been less stable, so today stays intentionally lighter."
            : params.profile.strategy.strictness === "balanced"
              ? "Recent follow-through supports a slightly fuller plan without pushing the day."
              : "Today stays protective until recent execution supports a fuller day.",
        params.adaptiveEnabled && params.profile.personalization.active
          ? params.profile.personalization.signals[0]?.value ?? null
          : params.profile.planningDirectives.earlyWinBias
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
    profile: params.profile,
    adaptiveEnabled: params.adaptiveEnabled,
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
  const futureMappedBlocks = mappedBlocks.filter(
    (block) =>
      [TimeBlockState.Scheduled, TimeBlockState.Rolled, TimeBlockState.Deferred].includes(
        block.state,
      ) &&
      (!isCurrentDate || Date.parse(block.startsAtDateTime) > Date.parse(nowIso)),
  );
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
    profile: params.profile,
    adaptiveEnabled: params.adaptiveEnabled,
  });
  const ritual = buildRitualSurface({
    date: params.date,
    tasks: params.tasks,
    blocks: orderedBlocks,
    openWindow,
    recommendation,
    ritualState: params.ritualState,
    constraints: params.constraints,
    schedule: params.schedule,
    nextBlock: rawNextBlock,
    activityEvents: params.activityEvents,
  });
  const progress = {
    completed,
    scheduled,
    recovery,
  };
  const workspace = buildWorkspaceDigest({
    activeBlock,
    nextBlock,
    futureBlocks: futureMappedBlocks,
    openWindow,
    recommendation,
    recoveryTasks,
    replanSuggestions,
    schedule: params.schedule,
    progress,
  });
  const recoverySnapshot = buildRecoverySnapshot({
    ritual,
    ritualState: params.ritualState,
    openWindow,
    nextBlock,
    recoveryCount: recovery,
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
    progress,
    integration,
    workspace,
    recoverySnapshot,
    ritual,
  };
}
