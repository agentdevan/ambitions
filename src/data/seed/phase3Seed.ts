import {
  AdaptationProfile,
  CalendarConnectionState,
  CalendarPermissionState,
  CalendarSyncState,
  CapacityLoad,
  ConstraintSource,
  DailyPlan,
  DailyPlanStatus,
  Domain,
  DomainKey,
  EntitySyncState,
  Goal,
  GoalHorizon,
  GoalStatus,
  GoalType,
  NotificationChannel,
  NotificationPreference,
  PlanningCadence,
  ReminderType,
  ReplanSuggestion,
  ReplanSuggestionType,
  ReplanningStyle,
  ScheduleConstraint,
  ScheduleConstraintType,
  StrategyStrictness,
  Task,
  TaskDifficulty,
  TaskSchedulingState,
  TaskStatus,
  TimeBlock,
  TimeBlockState,
  TimeBlockType,
  UserPreferences,
} from "../../domain/models";
import { buildGoalPlan } from "../../engines/decomposition/planning/planner";

const seedDate = "2026-04-11";
const createdAt = "2026-04-11T09:00:00.000Z";
const updatedAt = "2026-04-11T09:00:00.000Z";

function recordBase(id: string) {
  return {
    id,
    ownerUserId: null,
    remoteId: null,
    syncState: EntitySyncState.LocalOnly,
    version: 1,
    lastSyncedAt: null,
    createdAt,
    updatedAt,
  };
}

function createGoal(
  goal: Omit<Goal, keyof ReturnType<typeof recordBase>> & { id: string },
) {
  return {
    ...recordBase(goal.id),
    ...goal,
  };
}

function scheduleTask(task: Task, config: {
  scheduledDate: string;
  earliestStartAt: string;
  latestFinishAt: string;
  state: TaskSchedulingState;
}) {
  return {
    ...task,
    status: TaskStatus.Scheduled,
    scheduledDate: config.scheduledDate,
    targetDate: config.scheduledDate,
    earliestStartAt: config.earliestStartAt,
    latestFinishAt: config.latestFinishAt,
    schedulingState: config.state,
    updatedAt,
  };
}

const goals: Goal[] = [
  createGoal({
    id: "goal-credit-720",
    title: "Raise my credit score above 720",
    summary: "Improve revolving utilization and payment reliability without building a brittle debt sprint.",
    domainKey: DomainKey.Credit,
    horizon: GoalHorizon.Yearly,
    type: GoalType.Outcome,
    status: GoalStatus.Active,
    parentGoalId: null,
    sortOrder: 1,
    startDate: seedDate,
    targetDate: "2026-10-31",
    desiredWeeklyMinutes: 45,
    estimatedTotalMinutes: 720,
    successMetric: "Credit score above 720 with utilization below 30%.",
    notes: "Focus on the highest-utilization card first and avoid missed payments.",
    tags: ["credit", "score", "payments"],
    metadata: { seedPhase: "phase3" },
  }),
  createGoal({
    id: "goal-fitness-consistency",
    title: "Train three times per week and rebuild conditioning",
    summary: "Return to a repeatable lifting and conditioning rhythm without overloading the first month.",
    domainKey: DomainKey.Fitness,
    horizon: GoalHorizon.Monthly,
    type: GoalType.System,
    status: GoalStatus.Active,
    parentGoalId: null,
    sortOrder: 2,
    startDate: seedDate,
    targetDate: "2026-05-31",
    desiredWeeklyMinutes: 120,
    estimatedTotalMinutes: 960,
    successMetric: "Three training sessions per week for four weeks.",
    notes: "Recovery and ease of starting matter more than intensity right now.",
    tags: ["fitness", "conditioning", "routine"],
    metadata: { seedPhase: "phase3" },
  }),
  createGoal({
    id: "goal-career-applications",
    title: "Submit six strong-fit product engineering applications this month",
    summary: "Use a targeted application process with better fit and cleaner follow-through.",
    domainKey: DomainKey.Career,
    horizon: GoalHorizon.Monthly,
    type: GoalType.Project,
    status: GoalStatus.Active,
    parentGoalId: null,
    sortOrder: 3,
    startDate: seedDate,
    targetDate: "2026-05-09",
    desiredWeeklyMinutes: 180,
    estimatedTotalMinutes: 900,
    successMetric: "Six submitted applications with tailored materials and tracked follow-up dates.",
    notes: "Portfolio packaging and application quality matter more than raw volume.",
    tags: ["career", "applications", "portfolio"],
    metadata: { seedPhase: "phase3" },
  }),
  createGoal({
    id: "goal-skill-typescript",
    title: "Build a focused TypeScript systems study plan",
    summary: "Turn scattered reading into a compact curriculum with applied practice.",
    domainKey: DomainKey.SkillBuilding,
    horizon: GoalHorizon.Monthly,
    type: GoalType.Project,
    status: GoalStatus.Active,
    parentGoalId: null,
    sortOrder: 4,
    startDate: seedDate,
    targetDate: "2026-05-15",
    desiredWeeklyMinutes: 90,
    estimatedTotalMinutes: 480,
    successMetric: "A sequenced study plan plus two applied practice artifacts.",
    notes: "Stay narrow and finish a small curriculum instead of bouncing between topics.",
    tags: ["skill", "typescript", "curriculum"],
    metadata: { seedPhase: "phase3" },
  }),
];

const plannedGoals = goals.map((goal) => ({
  goal,
  ...buildGoalPlan(goal),
}));

const allMilestones = plannedGoals.flatMap((entry) => entry.milestones);
const allTasks = plannedGoals.flatMap((entry) => entry.tasks);

const scheduledTasks: Task[] = [];

function schedulePlannedTask(goalId: string, phaseKey: string, start: string, end: string) {
  const milestone = allMilestones.find(
    (item) => item.goalId === goalId && item.metadata.planningPhaseKey === phaseKey,
  );
  const task = milestone ? allTasks.find((item) => item.milestoneId === milestone.id) : undefined;

  if (!task) {
    return;
  }

  scheduledTasks.push(
    scheduleTask(task, {
      scheduledDate: seedDate,
      earliestStartAt: `${seedDate}T${start}:00.000Z`,
      latestFinishAt: `${seedDate}T${end}:00.000Z`,
      state: TaskSchedulingState.Committed,
    }),
  );
}

schedulePlannedTask("goal-credit-720", "audit", "08:30", "08:55");
schedulePlannedTask("goal-career-applications", "customize", "09:20", "09:50");
schedulePlannedTask("goal-fitness-consistency", "entry", "10:15", "10:35");

export const seedDomains: Domain[] = [
  {
    ...recordBase("domain-fitness"),
    key: DomainKey.Fitness,
    name: "Fitness",
    description: "Training, conditioning, recovery, and physical consistency.",
    accentColor: "#87654F",
    isArchived: false,
    sortOrder: 1,
  },
  {
    ...recordBase("domain-finance"),
    key: DomainKey.Finance,
    name: "Finance",
    description: "Cash flow, savings, debt, and financial stability.",
    accentColor: "#5F7B61",
    isArchived: false,
    sortOrder: 2,
  },
  {
    ...recordBase("domain-credit"),
    key: DomainKey.Credit,
    name: "Credit",
    description: "Credit score health, utilization, and report cleanup.",
    accentColor: "#6D7B8A",
    isArchived: false,
    sortOrder: 3,
  },
  {
    ...recordBase("domain-career"),
    key: DomainKey.Career,
    name: "Career",
    description: "Applications, output, networking, and professional leverage.",
    accentColor: "#5C6B79",
    isArchived: false,
    sortOrder: 4,
  },
  {
    ...recordBase("domain-skill-building"),
    key: DomainKey.SkillBuilding,
    name: "Skill Building",
    description: "Curriculum, practice, and applied learning.",
    accentColor: "#7D6956",
    isArchived: false,
    sortOrder: 5,
  },
  {
    ...recordBase("domain-relationship"),
    key: DomainKey.Relationship,
    name: "Relationship",
    description: "Connection, communication, and follow-through with people.",
    accentColor: "#8B6B7B",
    isArchived: false,
    sortOrder: 6,
  },
  {
    ...recordBase("domain-personal"),
    key: DomainKey.Personal,
    name: "Personal",
    description: "Routines, environment, and personal stability.",
    accentColor: "#6A6B64",
    isArchived: false,
    sortOrder: 7,
  },
];

export const seedPreferences: UserPreferences = {
  ...recordBase("preferences-default"),
  timezone: "America/New_York",
  weekStartsOn: 1,
  defaultFocusSessionMinutes: 45,
  defaultBreakMinutes: 10,
  planningCadence: PlanningCadence.Intentional,
  dailyPlanningTime: "08:00",
  weeklyPlanningDay: 0,
  monthlyPlanningDay: 1,
  allowWeekendPlanning: true,
  preferredDeepWorkWindows: ["08:30-10:30", "14:00-15:30"],
  metadata: {
    seedPhase: "phase4",
    sleepWindowStart: "23:00",
    sleepWindowEnd: "07:00",
    workdayStart: "09:00",
    workdayEnd: "17:00",
    workdays: "1,2,3,4,5",
    morningPrepMinutes: 35,
    commuteMinutes: 30,
    lunchWindowStart: "12:00",
    lunchWindowEnd: "12:45",
    recurringRoutineWindows: "Dinner reset,18:30,19:00,soft",
  },
};

export const seedNotificationPreferences: NotificationPreference[] = [
  {
    ...recordBase("notification-block-start"),
    channel: NotificationChannel.Push,
    reminderType: ReminderType.TimeBlockStart,
    enabled: true,
    leadTimeMinutes: 5,
    quietHoursStart: "21:30",
    quietHoursEnd: "07:00",
    metadata: { seedPhase: "phase3" },
  },
  {
    ...recordBase("notification-plan-review"),
    channel: NotificationChannel.InApp,
    reminderType: ReminderType.PlanReview,
    enabled: true,
    leadTimeMinutes: 0,
    quietHoursStart: null,
    quietHoursEnd: null,
    metadata: { seedPhase: "phase3" },
  },
];

export const seedGoals = goals;
export const seedPlanningAnalyses = plannedGoals.map((entry) => ({
  goalId: entry.goal.id,
  analysis: entry.analysis,
}));
export const seedMilestones = allMilestones;
export const seedTasks = allTasks.map((task) => scheduledTasks.find((item) => item.id === task.id) ?? task);

export const seedAdaptationProfile: AdaptationProfile = {
  ...recordBase("adaptation-2026-04-11"),
  effectiveDate: seedDate,
  source: "bootstrap",
  capacity: {
    mentalLoad: CapacityLoad.Balanced,
    focusBudgetMinutes: 110,
    meetingLoadMinutes: 60,
    recoveryBudgetMinutes: 35,
  },
  completion: {
    consistencyScore: 0.74,
    rolloverRate: 0.22,
    averageTaskCompletionMinutes: 24,
  },
  friction: {
    switchingPenaltyMinutes: 10,
    preferredStartWindow: "08:30",
    commonBlockers: ["over-scoping", "task startup friction"],
  },
  momentum: {
    currentStreakDays: 3,
    recentWinPattern: "Small, concrete first tasks make follow-through much more likely.",
    confidenceScore: 0.71,
  },
  strategy: {
    strictness: StrategyStrictness.Protective,
    replanningStyle: ReplanningStyle.Guided,
    progressionScore: 0.42,
    balancedReadiness: 0.46,
  },
  history: {
    sampleSize: 10,
    recentWindowSize: 8,
    recentCompletionRate: 0.63,
    baselineCompletionRate: 0.66,
    averageCompletedMinutes: 24,
    averageCompletedDurationBand: "medium",
    carryoverPressureRate: 0.22,
    recoveryRelianceRate: 0.18,
    splitRecoverySuccessRate: 0.5,
    substituteRecoverySuccessRate: 0.67,
    missedStartCollapseRate: 0.25,
    entryTaskLiftRate: 0.6,
    overloadedDayRate: 0.2,
    domainPatterns: [
      {
        domainKey: DomainKey.Credit,
        sampleSize: 3,
        successRate: 0.67,
        averageCompletedMinutes: 25,
        explanation: "Credit work is holding up when it stays bounded.",
      },
      {
        domainKey: DomainKey.Career,
        sampleSize: 3,
        successRate: 0.5,
        averageCompletedMinutes: 30,
        explanation: "Career work still benefits from smaller, tailored sessions.",
      },
    ],
    timeOfDayPatterns: [
      {
        window: "morning",
        sampleSize: 4,
        successRate: 0.75,
        preferredForAdmin: false,
        preferredForDeepWork: true,
        explanation: "Morning work has been the most reliable start window.",
      },
      {
        window: "evening",
        sampleSize: 2,
        successRate: 0.5,
        preferredForAdmin: true,
        preferredForDeepWork: false,
        explanation: "Evening is better for short admin cleanup than heavier work.",
      },
    ],
    durationPatterns: [
      {
        band: "short",
        sampleSize: 4,
        completionRate: 0.75,
        confidence: 0.74,
        explanation: "Short tasks are completing most reliably.",
      },
      {
        band: "medium",
        sampleSize: 4,
        completionRate: 0.63,
        confidence: 0.62,
        explanation: "Medium tasks are workable when the day is not crowded.",
      },
      {
        band: "long",
        sampleSize: 2,
        completionRate: 0.4,
        confidence: 0.35,
        explanation: "Longer tasks still carry more execution risk than the system should assume away.",
      },
    ],
    taskTypeFriction: [
      {
        workType: "research",
        sampleSize: 3,
        frictionScore: 0.42,
        markers: ["underestimated_duration"],
        explanation: "Research tasks tend to run longer than planned.",
      },
      {
        workType: "admin",
        sampleSize: 3,
        frictionScore: 0.2,
        markers: [],
        explanation: "Admin work is relatively stable when kept short.",
      },
    ],
  },
  regression: {
    severity: "none",
    isRegressing: false,
    triggers: [],
    explanation: "Seed profile starts protective without an active regression state.",
  },
  personalization: {
    active: true,
    sampleSize: 10,
    taskSizingStyle: "shorter_tasks",
    openWindowStyle: "short_bursts",
    lateDayStyle: "lighter_late",
    carryoverStyle: "moderate",
    planStability: "adjusting",
    intensityStyle: "balanced",
    recoveryStyle: "moderate",
    bestFocusWindow: "morning",
    signals: [
      {
        key: "task_sizing",
        label: "Task sizing",
        value: "Shorter tasks are landing better.",
        confidence: 0.74,
        sampleSize: 4,
        explanation: "Recent completions are clustering in shorter sessions.",
      },
      {
        key: "late_day_pattern",
        label: "Late-day pattern",
        value: "Late work lands better when lighter.",
        confidence: 0.6,
        sampleSize: 2,
        explanation: "Evening is more reliable for lighter admin cleanup than heavier work.",
      },
    ],
    summary: {
      planningStyle: "Shorter blocks are working better lately.",
      todayApproach: "Open time should lean toward smaller useful wins.",
      insights: "Carryover rises a bit when the day gets too full.",
    },
    explanation: "Seed profile reflects a user who does better with shorter, earlier work.",
  },
  durationRefinements: [
    {
      workType: "research",
      sampleSize: 3,
      averageEstimatedMinutes: 20,
      averageActualMinutes: 25,
      multiplier: 1.15,
      suggestedAdjustmentMinutes: 5,
      confidence: 0.65,
      explanation: "Research tasks have been taking slightly longer than estimated.",
    },
    {
      workType: "routine_action",
      sampleSize: 2,
      averageEstimatedMinutes: 15,
      averageActualMinutes: 10,
      multiplier: 0.85,
      suggestedAdjustmentMinutes: -5,
      confidence: 0.55,
      explanation: "Routine actions have been finishing a bit faster than estimated.",
    },
  ],
  planningDirectives: {
    preferredTaskDurationMin: 10,
    preferredTaskDurationMax: 30,
    dailyTaskSoftCap: 4,
    dailyPlannedMinutesTarget: 110,
    underpackMinutes: 45,
    schedulingConfidenceFloor: 0.52,
    earlyWinBias: true,
    preserveMomentumBias: true,
    preferSmallerEntryTasks: true,
    timeWindowConfidences: [
      {
        window: "morning",
        confidence: 0.78,
        explanation: "Morning execution has been strongest.",
      },
      {
        window: "evening",
        confidence: 0.58,
        explanation: "Evening is acceptable for short cleanup work only.",
      },
    ],
    workTypeSchedulingPreferences: [
      {
        workType: "deep_work",
        window: "morning",
        confidence: 0.75,
        explanation: "Deep work behaves best in the morning.",
      },
      {
        workType: "admin",
        window: "evening",
        confidence: 0.7,
        explanation: "Short admin follow-through works well in the evening.",
      },
    ],
    explanation:
      "Protective planning is still active, with a strong preference for smaller early wins and lighter day packing.",
  },
  metadata: { seedPhase: "phase6" },
};

export const seedDailyPlan: DailyPlan = {
  ...recordBase("daily-plan-2026-04-11"),
  date: seedDate,
  status: DailyPlanStatus.Ready,
  focus: "Protect one career block, one credit step, and one low-friction fitness entry task.",
  planningNotes:
    "This is a protective-first day plan: three believable tasks, one meeting load, and recovery space instead of an aggressive stack.",
  totalPlannedMinutes: scheduledTasks.reduce((sum, task) => sum + task.estimatedMinutes, 0) + 20,
  totalCommittedMinutes: scheduledTasks.reduce((sum, task) => sum + task.estimatedMinutes, 0),
  adaptationProfileId: "adaptation-2026-04-11",
  metadata: { seedPhase: "phase4" },
};

export const seedTimeBlocks: TimeBlock[] = scheduledTasks.map((task, index) => ({
  ...recordBase(`block-${index + 1}`),
  dailyPlanId: seedDailyPlan.id,
  taskId: task.id,
  goalId: task.goalId,
  title: task.title,
  type:
    String(task.metadata.planningWorkType) === "deep_work"
      ? TimeBlockType.Focus
      : String(task.metadata.planningWorkType) === "admin"
        ? TimeBlockType.Admin
        : TimeBlockType.Focus,
  state: TimeBlockState.Scheduled,
  startsAt: task.earliestStartAt?.slice(11, 16) ?? "08:30",
  endsAt: task.latestFinishAt?.slice(11, 16) ?? "09:00",
  startsAtDateTime: task.earliestStartAt ?? `${seedDate}T08:30:00.000Z`,
  endsAtDateTime: task.latestFinishAt ?? `${seedDate}T09:00:00.000Z`,
  note: task.summary,
  energyLabel: task.difficulty,
  sourceConstraintId: null,
  metadata: { seedPhase: "phase4" },
}));

seedTimeBlocks.push({
  ...recordBase("block-4"),
  dailyPlanId: seedDailyPlan.id,
  taskId: null,
  goalId: null,
  title: "Leave recovery space after the meeting block",
  type: TimeBlockType.Recovery,
  state: TimeBlockState.Scheduled,
  startsAt: "14:30",
  endsAt: "14:50",
  startsAtDateTime: `${seedDate}T14:30:00.000Z`,
  endsAtDateTime: `${seedDate}T14:50:00.000Z`,
  note: "Protective mode keeps a small buffer instead of blindly rolling more work into the afternoon.",
  energyLabel: TaskDifficulty.Light,
  sourceConstraintId: null,
  metadata: { seedPhase: "phase4" },
});

export const seedReplanSuggestions: ReplanSuggestion[] = [
  {
    ...recordBase("replan-protect-career"),
    planDate: seedDate,
    type: ReplanSuggestionType.RescheduleDifferentWindow,
    title: "Reschedule the tailored application block if the afternoon compresses",
    rationale: "Keep the task, but move it deliberately instead of letting it absorb the rest of the day.",
    taskId: scheduledTasks[1]?.id ?? null,
    timeBlockId: "block-2",
    confidence: 0.84,
    suggestedStartAt: null,
    suggestedEndAt: null,
    metadata: { seedPhase: "phase3" },
  },
  {
    ...recordBase("replan-shorten-credit"),
    planDate: seedDate,
    type: ReplanSuggestionType.RetrySmaller,
    title: "Retry the credit task in a smaller pass",
    rationale: "If time gets tight, capture balances and limits first, then leave the rest unscheduled pending review.",
    taskId: scheduledTasks[0]?.id ?? null,
    timeBlockId: "block-1",
    confidence: 0.78,
    suggestedStartAt: null,
    suggestedEndAt: null,
    metadata: { seedPhase: "phase3" },
  },
];

export const seedCalendarConnectionState: CalendarConnectionState = {
  ...recordBase("calendar-state-default"),
  permissionState: CalendarPermissionState.NotAsked,
  connectionStatus: CalendarSyncState.Idle,
  selectedCalendarIds: [],
  lastSuccessfulSyncAt: null,
  metadata: { seedPhase: "phase7" },
};

export const seedScheduleConstraints: ScheduleConstraint[] = [
  {
    ...recordBase("constraint-1"),
    source: ConstraintSource.System,
    type: ScheduleConstraintType.Hard,
    title: "Midday meeting block",
    startsAt: `${seedDate}T12:30:00.000Z`,
    endsAt: `${seedDate}T13:30:00.000Z`,
    isAllDay: false,
    externalEventId: "calendar-event-1",
    location: null,
    notes: "Fixed meeting load keeps the rest of the day intentionally light.",
    metadata: { classification: "meeting", seedPhase: "phase7", fallback: true },
  },
  {
    ...recordBase("constraint-2"),
    source: ConstraintSource.Manual,
    type: ScheduleConstraintType.Soft,
    title: "Family call window",
    startsAt: `${seedDate}T19:30:00.000Z`,
    endsAt: `${seedDate}T20:15:00.000Z`,
    isAllDay: false,
    externalEventId: null,
    location: null,
    notes: "Can flex a bit, but should not be silently consumed by work.",
    metadata: { classification: "relationship", flexible: true, seedPhase: "phase7", fallback: true },
  },
];
