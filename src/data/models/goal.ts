import { DomainKey } from "./domain";

export type GoalHorizon = "yearly" | "monthly" | "weekly";
export type GoalStatus = "active" | "paused" | "completed" | "archived";

export interface Goal {
  id: string;
  title: string;
  horizon: GoalHorizon;
  domain: DomainKey;
  status: GoalStatus;
  summary?: string;
  parentGoalId?: string;
  targetDate?: string;
}
