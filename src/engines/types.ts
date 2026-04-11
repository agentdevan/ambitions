import {
  AdaptationProfile,
  DailyPlan,
  ExecutionAuditTrail,
  ExecutionMutationSet,
  PlanPressureSnapshot,
  Goal,
  GoalMilestone,
  GoalPlanningAnalysis,
  ReplanSuggestion,
  ScheduleConstraint,
  TaskActionEvent,
  Task,
  TimeBlock,
  UserPreferences,
} from "../domain/models";
import { StrategyStrictness } from "../domain/models/adaptation";

export interface PlanningContext {
  date: string;
  goals: Goal[];
  milestones: GoalMilestone[];
  tasks: Task[];
  constraints: ScheduleConstraint[];
  preferences: UserPreferences;
  adaptationProfile: AdaptationProfile | null;
}

export interface EngineResult<TPayload> {
  generatedAt: string;
  payload: TPayload;
  warnings: string[];
}

export interface GoalDecompositionRequest {
  goal: Goal;
  milestones: GoalMilestone[];
  existingTasks: Task[];
  preferences: UserPreferences;
  adaptationProfile?: AdaptationProfile | null;
  referenceDate?: string;
}

export interface GoalDecompositionOutput {
  analysis: GoalPlanningAnalysis;
  milestones: GoalMilestone[];
  tasks: Task[];
}

export interface TimeCapacityRequest {
  date: string;
  constraints: ScheduleConstraint[];
  preferences: UserPreferences;
  adaptationProfile: AdaptationProfile | null;
}

export type ConstraintDisposition =
  | "hard_constraint"
  | "soft_constraint"
  | "usable_within_window"
  | "informational";

export type ConstraintKind =
  | "sleep"
  | "prep"
  | "commute"
  | "work"
  | "lunch"
  | "meeting"
  | "routine"
  | "relationship"
  | "personal"
  | "administrative"
  | "buffer"
  | "other";

export interface InterpretedConstraint {
  id: string;
  sourceConstraintId: string | null;
  title: string;
  source: ScheduleConstraint["source"];
  kind: ConstraintKind;
  disposition: ConstraintDisposition;
  startsAt: string;
  endsAt: string;
  startsAtTime: string;
  endsAtTime: string;
  minutes: number;
  isAllDay: boolean;
  confidence: number;
  reason: string;
  metadata: Record<string, string | number | boolean | null>;
}

export interface UsableTimeWindow {
  id: string;
  start: string;
  end: string;
  startTime: string;
  endTime: string;
  minutes: number;
  kind: "core" | "lunch" | "gap" | "recovery";
  sourceConstraintIds: string[];
  confidence: number;
  label: string;
}

export interface CapacitySummary {
  totalDayMinutes: number;
  totalUnavailableMinutes: number;
  totalUsableMinutes: number;
  scheduledMinutes: number;
  unscheduledDemandMinutes: number;
  unusedCapacityMinutes: number;
  overloadMinutes: number;
  confidence: number;
}

export interface TimeCapacityOutput {
  focusMinutes: number;
  adminMinutes: number;
  recoveryMinutes: number;
  capacitySummary: CapacitySummary;
  interpretedConstraints: InterpretedConstraint[];
  usableWindows: UsableTimeWindow[];
}

export type UnscheduledReasonCode =
  | "insufficient_capacity"
  | "window_too_short"
  | "window_too_fragmented"
  | "protected_from_overload"
  | "deprioritized_for_realism";

export interface ScheduledTaskWindow {
  taskId: string;
  goalId: string | null;
  title: string;
  startsAt: string;
  endsAt: string;
  startsAtTime: string;
  endsAtTime: string;
  durationMinutes: number;
  windowId: string;
  confidence: number;
  reason: string;
}

export interface UnscheduledTask {
  taskId: string;
  goalId: string | null;
  title: string;
  estimatedMinutes: number;
  reasonCode: UnscheduledReasonCode;
  reason: string;
}

export interface SchedulingSignals {
  planPressure: "low" | "moderate" | "high";
  rolloverPressure: "low" | "moderate" | "high";
  schedulingConfidence: number;
  unusedCapacityMinutes: number;
  overloadWarning: boolean;
  protectiveMode: boolean;
}

export interface SchedulingContextSnapshot {
  strictness: StrategyStrictness;
  workdayLabel: string | null;
  usableWindowCount: number;
  hardConstraintCount: number;
  softConstraintCount: number;
  warnings: string[];
}

export interface SchedulingRequest extends PlanningContext {
  existingPlan: DailyPlan | null;
}

export interface SchedulingOutput {
  dailyPlan: DailyPlan;
  timeBlocks: TimeBlock[];
  scheduledTasks: ScheduledTaskWindow[];
  unscheduledTasks: UnscheduledTask[];
  capacitySummary: CapacitySummary;
  interpretedConstraints: InterpretedConstraint[];
  usableWindows: UsableTimeWindow[];
  signals: SchedulingSignals;
  context: SchedulingContextSnapshot;
}

export interface ExecutionRequest {
  date: string;
  dailyPlan: DailyPlan;
  timeBlocks: TimeBlock[];
  tasks: Task[];
  adaptationProfile: AdaptationProfile | null;
  event: TaskActionEvent;
}

export interface ExecutionOutput {
  mutation: ExecutionMutationSet;
  audit: ExecutionAuditTrail;
  createdTaskIds: string[];
  preservedTaskIds: string[];
  replanSuggestions: ReplanSuggestion[];
  pressure: PlanPressureSnapshot;
}

export interface ReplanningRequest extends PlanningContext {
  dailyPlan: DailyPlan;
  timeBlocks: TimeBlock[];
}

export interface ReplanningOutput {
  suggestions: ReplanSuggestion[];
}

export interface AdaptationRequest {
  date: string;
  tasks: Task[];
  priorProfile: AdaptationProfile | null;
  preferences: UserPreferences;
}

export interface AdaptationOutput {
  profile: AdaptationProfile;
}
