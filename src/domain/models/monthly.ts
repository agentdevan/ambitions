import { EntityRecord, ISODateString, ISODateTimeString, JsonMap } from "./shared";

export enum MonthlyPosture {
  Stabilize = "stabilize",
  BuildMomentum = "build_momentum",
  PushOutput = "push_output",
}

export enum MonthlyEmphasis {
  ProtectEssentials = "protect_essentials",
  DeepenPriorityArea = "deepen_one_priority_area",
  RebalanceNeglectedAreas = "rebalance_neglected_areas",
}

export enum MonthlyPressureLevel {
  Lighter = "lighter",
  Balanced = "balanced",
  Fuller = "fuller",
}

export enum MonthlyCarryoverStance {
  PruneAggressively = "prune_aggressively",
  ReviewBeforeCarrying = "review_before_carrying",
  TolerateMoreCarryover = "tolerate_more_carryover",
}

export interface MonthlyGoalCoverageSummary {
  goalId: string;
  goalTitle: string;
  executionCount: number;
  completionCount: number;
  carryoverCount: number;
  churnCount: number;
  represented: boolean;
  underrepresented: boolean;
  dragSignal: boolean;
}

export interface MonthlyReviewSummary {
  completedCount: number;
  reshapedCount: number;
  deferredCount: number;
  missedCount: number;
  reviewedWeeks: number;
  shapedWeeks: number;
  daysOpened: number;
  daysClosed: number;
  recoveryCount: number;
  carryoverReviewedCount: number;
  carryForwardCount: number;
  sentToReviewCount: number;
  leftVagueCount: number;
  churnRate: number;
  heldSteady: boolean;
  overloaded: boolean;
  goalCoverageCount: number;
  underrepresentedGoalCount: number;
  dragGoalCount: number;
}

export interface MonthlyReviewState extends EntityRecord {
  monthStartDate: ISODateString;
  monthEndDate: ISODateString;
  reviewedAt: ISODateTimeString | null;
  strategySetAt: ISODateTimeString | null;
  monthPosture: MonthlyPosture | null;
  monthlyEmphasis: MonthlyEmphasis | null;
  pressureLevel: MonthlyPressureLevel | null;
  carryoverStance: MonthlyCarryoverStance | null;
  reviewNote: string | null;
  strategyNote: string | null;
  recommitGoalIds: string[];
  reduceGoalIds: string[];
  pauseGoalIds: string[];
  goalCoverage: MonthlyGoalCoverageSummary[];
  summary: MonthlyReviewSummary | null;
  metadata: JsonMap;
}
