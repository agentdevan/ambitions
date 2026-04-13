import { DomainKey } from "./domain";
import { EntityRecord, ISODateString, JsonMap } from "./shared";

export enum GoalHorizon {
  Yearly = "yearly",
  Monthly = "monthly",
  Weekly = "weekly",
  Daily = "daily",
}

export enum GoalType {
  Outcome = "outcome",
  System = "system",
  Project = "project",
  Habit = "habit",
}

export enum GoalStatus {
  Draft = "draft",
  Active = "active",
  Paused = "paused",
  Completed = "completed",
  Archived = "archived",
}

export enum GoalMilestoneStatus {
  Pending = "pending",
  InProgress = "in_progress",
  Completed = "completed",
  Missed = "missed",
  Archived = "archived",
}

export interface Goal extends EntityRecord {
  ambitionId: string | null;
  title: string;
  summary: string | null;
  domainKey: DomainKey;
  horizon: GoalHorizon;
  type: GoalType;
  status: GoalStatus;
  parentGoalId: string | null;
  sortOrder: number;
  startDate: ISODateString | null;
  targetDate: ISODateString | null;
  desiredWeeklyMinutes: number | null;
  estimatedTotalMinutes: number | null;
  successMetric: string | null;
  notes: string | null;
  tags: string[];
  metadata: JsonMap;
}

export interface GoalMilestone extends EntityRecord {
  goalId: string;
  title: string;
  summary: string | null;
  status: GoalMilestoneStatus;
  targetDate: ISODateString | null;
  completedAt: string | null;
  sortOrder: number;
  estimatedMinutes: number | null;
  metadata: JsonMap;
}
