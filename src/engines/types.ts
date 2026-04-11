import {
  AdaptationProfile,
  DailyPlan,
  Goal,
  GoalMilestone,
  ReplanSuggestion,
  ScheduleConstraint,
  Task,
  TimeBlock,
  UserPreferences,
} from "../domain/models";

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
}

export interface GoalDecompositionOutput {
  milestones: GoalMilestone[];
  tasks: Task[];
}

export interface TimeCapacityRequest {
  date: string;
  constraints: ScheduleConstraint[];
  preferences: UserPreferences;
  adaptationProfile: AdaptationProfile | null;
}

export interface TimeCapacityOutput {
  focusMinutes: number;
  adminMinutes: number;
  recoveryMinutes: number;
  usableWindows: Array<{ start: string; end: string; minutes: number }>;
}

export interface SchedulingRequest extends PlanningContext {
  existingPlan: DailyPlan | null;
}

export interface SchedulingOutput {
  dailyPlan: DailyPlan;
  timeBlocks: TimeBlock[];
}

export interface ExecutionRequest {
  date: string;
  dailyPlan: DailyPlan;
  timeBlocks: TimeBlock[];
  tasks: Task[];
}

export interface ExecutionOutput {
  activeTaskIds: string[];
  rolloverCandidates: string[];
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
  completedTasks: Task[];
  deferredTasks: Task[];
  priorProfile: AdaptationProfile | null;
  preferences: UserPreferences;
}

export interface AdaptationOutput {
  profile: AdaptationProfile;
}
