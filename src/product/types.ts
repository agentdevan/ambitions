import { DomainKey } from "../domain/models";

export type TaskSizingPreference = "smaller" | "mixed" | "bigger";
export type DayIntensityPreference = "light" | "balanced" | "ambitious";
export type AppearanceMode = "light" | "dark" | "system";
export type AccentThemeKey =
  | "gold"
  | "sage"
  | "slateBlue"
  | "bronze"
  | "olive"
  | "terracotta";
export type DefaultUnfinishedWorkBehavior =
  | "carry_forward"
  | "send_to_review"
  | "ask_each_time";
export type WeeklyIntensityPreference = "lighter" | "balanced" | "fuller";
export type WeeklyEmphasisPreference =
  | "protect_essentials"
  | "steady_progress"
  | "push_meaningful_area";
export type DefaultWeeklyCarryoverBehavior =
  | "essentials_only"
  | "review_first"
  | "aggressive";
export type MonthlyPosturePreference = "stabilize" | "build_momentum" | "push_output";
export type MonthlyEmphasisPreference =
  | "protect_essentials"
  | "deepen_one_priority_area"
  | "rebalance_neglected_areas";
export type MonthlyPressurePreference = "lighter" | "balanced" | "fuller";
export type MonthlyCarryoverPreference =
  | "prune_aggressively"
  | "review_before_carrying"
  | "tolerate_more_carryover";
export type GoalPaceMode = "conservative" | "balanced" | "aggressive";
export type GoalFeasibilityStatus = "feasible" | "tight" | "unrealistic";

export interface GoalInterpretation {
  domainLabel: string;
  categoryLabel: string;
  workPattern: string;
  timingLabel: string;
  workloadShape: string;
  workloadLabel: string;
  earlyMilestoneStructure: string[];
  earlyTaskCategories: string[];
}

export interface GoalPaceOptionSummary {
  mode: GoalPaceMode;
  label: string;
  summary: string;
  weeklyHours: number;
  sessionCount: number;
  taskSizing: string;
  riskLevel: string;
  deadlineConfidence: string;
  adaptationBehavior: string;
  recommended: boolean;
}

export interface GoalFeasibilityTruth {
  status: GoalFeasibilityStatus;
  summary: string;
  detail: string;
  deadlineConfidence: string;
  weeklyDemandMinutes: number;
  weeklyCapacityMinutes: number;
  totalCapacityMinutes: number;
  revisedDeadlineSuggestion: string | null;
  revisedDeadlineReason: string | null;
  lighterScopeSuggestion: string | null;
  pacingTradeoff: string;
  highestLeverageStep: string;
}

export interface GoalStrategyComposer {
  selectedPaceMode: GoalPaceMode;
  recommendedPaceMode: GoalPaceMode;
  interpretation: GoalInterpretation;
  availableCapacitySummary: string;
  commitmentsSummary: string;
  behaviorSummary: string;
  workloadEstimateMinutes: number;
  workloadEstimateLabel: string;
  paceOptions: GoalPaceOptionSummary[];
  feasibility: GoalFeasibilityTruth;
  firstMilestonePath: Array<{
    title: string;
    summary: string | null;
    targetDate: string | null;
  }>;
  firstWeekActionPreview: Array<{
    title: string;
    summary: string | null;
    targetDate: string | null;
    estimatedMinutes: number;
  }>;
}

export interface ScheduleDefaults {
  sleepStart: string;
  sleepEnd: string;
  morningPrepMinutes: number;
  workdayStart: string;
  workdayEnd: string;
  workdays: number[];
  commuteMinutes: number;
}

export interface ProductPreferences {
  onboardingCompleted: boolean;
  focusDomains: DomainKey[];
  taskSizing: TaskSizingPreference;
  dayIntensity: DayIntensityPreference;
  adaptivePlanningEnabled: boolean;
  appearanceMode: AppearanceMode;
  accentTheme: AccentThemeKey;
  defaultUnfinishedWorkBehavior: DefaultUnfinishedWorkBehavior;
  weeklyReviewDay: number;
  weeklyReviewTime: string;
  autoPromptNextWeekShaping: boolean;
  defaultWeeklyCarryoverBehavior: DefaultWeeklyCarryoverBehavior;
  monthlyReviewDay: number;
  monthlyReviewTime: string;
  autoPromptNextMonthShaping: boolean;
  defaultMonthlyPosture: MonthlyPosturePreference;
  defaultMonthlyEmphasis: MonthlyEmphasisPreference;
  defaultMonthlyPressure: MonthlyPressurePreference;
  defaultMonthlyCarryoverStance: MonthlyCarryoverPreference;
  schedule: ScheduleDefaults;
}

export interface GoalDraftInference {
  ambitionId: string | null;
  title: string;
  naturalLanguage: string;
  summary: string | null;
  domainKey: DomainKey;
  targetDate: string | null;
  horizon: "daily" | "weekly" | "monthly" | "yearly";
  type: "outcome" | "system" | "project" | "habit";
  desiredWeeklyMinutes: number | null;
  estimatedTotalMinutes: number | null;
  successMetric: string | null;
  notes: string | null;
  focusDomains: DomainKey[];
  paceMode: GoalPaceMode;
  interpretation: GoalInterpretation;
}
