import { EntityRecord, ISODateString, ISODateTimeString, JsonMap } from "./shared";

export enum WeeklyIntensity {
  Lighter = "lighter",
  Balanced = "balanced",
  Fuller = "fuller",
}

export enum WeeklyEmphasis {
  ProtectEssentials = "protect_essentials",
  SteadyProgress = "steady_progress",
  PushMeaningfulArea = "push_meaningful_area",
}

export enum WeeklyCarryoverPosture {
  EssentialsOnly = "essentials_only",
  ReviewFirst = "review_first",
  Aggressive = "aggressive",
}

export interface WeeklyReviewSummary {
  completedCount: number;
  reshapedCount: number;
  deferredCount: number;
  missedCount: number;
  daysOpened: number;
  daysClosed: number;
  recoveryCount: number;
  carryoverReviewedCount: number;
  carryForwardCount: number;
  sentToReviewCount: number;
  leftVagueCount: number;
  openedLateWeekCount: number;
  closedLateWeekCount: number;
  nextDayStabilityDelta: number | null;
  churnRate: number;
  heldSteady: boolean;
  overloaded: boolean;
}

export interface WeeklyReviewState extends EntityRecord {
  weekStartDate: ISODateString;
  weekEndDate: ISODateString;
  reviewedAt: ISODateTimeString | null;
  nextWeekShapedAt: ISODateTimeString | null;
  weeklyEmphasis: WeeklyEmphasis | null;
  targetWeekIntensity: WeeklyIntensity | null;
  carryoverPosture: WeeklyCarryoverPosture | null;
  note: string | null;
  carryoverTaskIds: string[];
  reviewTaskIds: string[];
  releasedTaskIds: string[];
  summary: WeeklyReviewSummary | null;
  metadata: JsonMap;
}
