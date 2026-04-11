export interface CapacityProfile {
  mentalLoad: "low" | "balanced" | "strained";
  focusBudgetMinutes: number;
  meetingLoadMinutes: number;
}

export interface CompletionProfile {
  consistencyScore: number;
  rolloverRate: number;
}

export interface FrictionProfile {
  switchingPenalty: number;
  preferredStartWindow: string;
}

export interface MomentumProfile {
  currentStreakDays: number;
  recentWinPattern: string;
}

export interface StrategyProfile {
  strictness: "protective" | "balanced" | "flexible";
  replanningStyle: "guided" | "direct";
}
