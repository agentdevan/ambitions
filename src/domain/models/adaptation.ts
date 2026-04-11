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
  };
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
