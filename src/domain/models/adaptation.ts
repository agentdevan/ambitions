import { EntityRecord, ISODateString, ISODateTimeString, JsonMap } from "./shared";

export enum CapacityLoad {
  Low = "low",
  Balanced = "balanced",
  Strained = "strained",
}

export enum StrategyStrictness {
  Protective = "protective",
  Balanced = "balanced",
  Flexible = "flexible",
}

export enum ReplanningStyle {
  Guided = "guided",
  Direct = "direct",
}

export enum ReplanSuggestionType {
  ShiftBlock = "shift_block",
  ShortenTask = "shorten_task",
  ProtectFocus = "protect_focus",
  AddRecovery = "add_recovery",
  DeferTask = "defer_task",
  RetrySmaller = "retry_smaller",
  SubstituteLowerFriction = "substitute_lower_friction",
  RescheduleDifferentWindow = "reschedule_different_window",
  PreserveAndDefer = "preserve_and_defer",
  DropFromCurrentDay = "drop_from_current_day",
}

export type DurationBand = "short" | "medium" | "long";
export type TimeOfDayWindow = "morning" | "midday" | "afternoon" | "evening";
export type AdaptationWorkType =
  | "admin"
  | "research"
  | "communication"
  | "deep_work"
  | "routine_action"
  | "unknown";
export type RegressionSeverity = "none" | "watch" | "active";
export type RegressionTrigger =
  | "miss_rate_spike"
  | "recovery_reliance"
  | "completion_slide"
  | "overpacked_days"
  | "missed_start_collapse";
export type PersonalTaskSizingStyle = "shorter_tasks" | "mixed_tasks" | "deeper_blocks";
export type PersonalOpenWindowStyle = "short_bursts" | "medium_blocks" | "deep_windows" | "mixed";
export type PersonalLateDayStyle = "steady" | "lighter_late" | "avoid_late_heavy";
export type PersonalCarryoverStyle = "low" | "moderate" | "high";
export type PersonalPlanStability = "stable" | "adjusting" | "volatile";
export type PersonalIntensityStyle = "light" | "balanced" | "high";
export type PersonalRecoveryStyle = "low" | "moderate" | "high";

export interface PersonalizationSignal {
  key:
    | "task_sizing"
    | "open_window_fit"
    | "late_day_pattern"
    | "carryover_tendency"
    | "plan_stability"
    | "intensity_tolerance"
    | "focus_window";
  label: string;
  value: string;
  confidence: number;
  sampleSize: number;
  explanation: string;
}

export interface PersonalizationSummary {
  planningStyle: string;
  todayApproach: string;
  insights: string;
}

export interface PersonalizationProfile {
  active: boolean;
  sampleSize: number;
  taskSizingStyle: PersonalTaskSizingStyle;
  openWindowStyle: PersonalOpenWindowStyle;
  lateDayStyle: PersonalLateDayStyle;
  carryoverStyle: PersonalCarryoverStyle;
  planStability: PersonalPlanStability;
  intensityStyle: PersonalIntensityStyle;
  recoveryStyle: PersonalRecoveryStyle;
  bestFocusWindow: TimeOfDayWindow | null;
  signals: PersonalizationSignal[];
  summary: PersonalizationSummary;
  explanation: string;
}

export interface DomainExecutionPattern {
  domainKey: string;
  sampleSize: number;
  successRate: number;
  averageCompletedMinutes: number | null;
  explanation: string;
}

export interface TimeOfDayExecutionPattern {
  window: TimeOfDayWindow;
  sampleSize: number;
  successRate: number;
  preferredForAdmin: boolean;
  preferredForDeepWork: boolean;
  explanation: string;
}

export interface DurationExecutionPattern {
  band: DurationBand;
  sampleSize: number;
  completionRate: number;
  confidence: number;
  explanation: string;
}

export interface TaskTypeFrictionPattern {
  workType: AdaptationWorkType;
  sampleSize: number;
  frictionScore: number;
  markers: string[];
  explanation: string;
}

export interface ExecutionHistorySummary {
  sampleSize: number;
  recentWindowSize: number;
  recentCompletionRate: number;
  baselineCompletionRate: number;
  averageCompletedMinutes: number | null;
  averageCompletedDurationBand: DurationBand | null;
  carryoverPressureRate: number;
  recoveryRelianceRate: number;
  splitRecoverySuccessRate: number | null;
  substituteRecoverySuccessRate: number | null;
  missedStartCollapseRate: number;
  entryTaskLiftRate: number;
  overloadedDayRate: number;
  domainPatterns: DomainExecutionPattern[];
  timeOfDayPatterns: TimeOfDayExecutionPattern[];
  durationPatterns: DurationExecutionPattern[];
  taskTypeFriction: TaskTypeFrictionPattern[];
}

export interface RegressionSignal {
  severity: RegressionSeverity;
  isRegressing: boolean;
  trigger: RegressionTrigger;
  metric: number;
  threshold: number;
  explanation: string;
}

export interface RegressionState {
  severity: RegressionSeverity;
  isRegressing: boolean;
  triggers: RegressionSignal[];
  explanation: string;
}

export interface DurationRefinementRule {
  workType: AdaptationWorkType;
  sampleSize: number;
  averageEstimatedMinutes: number;
  averageActualMinutes: number;
  multiplier: number;
  suggestedAdjustmentMinutes: number;
  confidence: number;
  explanation: string;
}

export interface TimeWindowConfidence {
  window: TimeOfDayWindow;
  confidence: number;
  explanation: string;
}

export interface WorkTypeSchedulingPreference {
  workType: AdaptationWorkType;
  window: TimeOfDayWindow;
  confidence: number;
  explanation: string;
}

export interface AdaptationPlanningDirectives {
  preferredTaskDurationMin: number;
  preferredTaskDurationMax: number;
  dailyTaskSoftCap: number;
  dailyPlannedMinutesTarget: number;
  underpackMinutes: number;
  schedulingConfidenceFloor: number;
  earlyWinBias: boolean;
  preserveMomentumBias: boolean;
  preferSmallerEntryTasks: boolean;
  timeWindowConfidences: TimeWindowConfidence[];
  workTypeSchedulingPreferences: WorkTypeSchedulingPreference[];
  explanation: string;
}

export interface AdaptationProfile extends EntityRecord {
  effectiveDate: ISODateString;
  source: "bootstrap" | "manual" | "observed";
  capacity: {
    mentalLoad: CapacityLoad;
    focusBudgetMinutes: number;
    meetingLoadMinutes: number;
    recoveryBudgetMinutes: number;
  };
  completion: {
    consistencyScore: number;
    rolloverRate: number;
    averageTaskCompletionMinutes: number | null;
  };
  friction: {
    switchingPenaltyMinutes: number;
    preferredStartWindow: string;
    commonBlockers: string[];
  };
  momentum: {
    currentStreakDays: number;
    recentWinPattern: string;
    confidenceScore: number;
  };
  strategy: {
    strictness: StrategyStrictness;
    replanningStyle: ReplanningStyle;
    progressionScore: number;
    balancedReadiness: number;
  };
  history: ExecutionHistorySummary;
  regression: RegressionState;
  personalization: PersonalizationProfile;
  durationRefinements: DurationRefinementRule[];
  planningDirectives: AdaptationPlanningDirectives;
  metadata: JsonMap;
}

export interface ReplanSuggestion extends EntityRecord {
  planDate: ISODateString;
  type: ReplanSuggestionType;
  title: string;
  rationale: string;
  taskId: string | null;
  timeBlockId: string | null;
  confidence: number;
  suggestedStartAt: ISODateTimeString | null;
  suggestedEndAt: ISODateTimeString | null;
  metadata: JsonMap;
}
