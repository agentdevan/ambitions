import { EntityRecord, ISODateString, ISODateTimeString, JsonMap } from "./shared";

export enum DailyRitualOpeningFocus {
  ProtectEssentials = "protect_essentials",
  MeaningfulProgress = "meaningful_progress",
  KeepItLight = "keep_it_light",
}

export enum DailyRitualRecoveryMode {
  SalvageEssentials = "salvage_essentials",
  RebalanceToday = "rebalance_today",
  LightenRest = "lighten_rest",
}

export enum DailyRitualDayLoadRating {
  Light = "light",
  Balanced = "balanced",
  Overloaded = "overloaded",
}

export enum DailyRitualEnergyRating {
  Low = "low",
  Normal = "normal",
  High = "high",
}

export enum DailyRitualClarityRating {
  Clear = "clear",
  Crowded = "crowded",
  Unrealistic = "unrealistic",
}

export enum DailyRitualCarryDecision {
  CarryForward = "carry_forward",
  SendToReview = "send_to_review",
  DeferDecision = "defer_decision",
  AskEachTime = "ask_each_time",
}

export interface DailyRitualRecoveryMoment {
  occurredAt: ISODateTimeString;
  mode: DailyRitualRecoveryMode;
  summary: string;
  changedTaskCount: number;
  changedBlockCount: number;
  triggerLabels: string[];
}

export interface DailyRitualCarryDecisionSummary {
  decidedAt: ISODateTimeString;
  decision: DailyRitualCarryDecision;
  unfinishedTaskCount: number;
  carriedTaskCount: number;
  sentToReviewCount: number;
  deferredDecisionCount: number;
}

export interface DailyRitualState extends EntityRecord {
  date: ISODateString;
  openedAt: ISODateTimeString | null;
  openingFocus: DailyRitualOpeningFocus | null;
  recoveryMoments: DailyRitualRecoveryMoment[];
  closedAt: ISODateTimeString | null;
  dayLoadRating: DailyRitualDayLoadRating | null;
  energyRating: DailyRitualEnergyRating | null;
  clarityRating: DailyRitualClarityRating | null;
  reflectionNote: string | null;
  carryDecisionSummary: DailyRitualCarryDecisionSummary | null;
  metadata: JsonMap;
}
