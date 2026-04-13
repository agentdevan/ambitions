import { EntityRecord, ISODateString, ISODateTimeString, JsonMap } from "./shared";

export enum ActivityEventKind {
  TaskStarted = "task_started",
  TaskCompleted = "task_completed",
  TaskDeferred = "task_deferred",
  TaskSkipped = "task_skipped",
  TaskMissed = "task_missed",
  TaskRescheduled = "task_rescheduled",
  PlanReviewGenerated = "plan_review_generated",
  PlanReviewAccepted = "plan_review_accepted",
  PlanReviewReverted = "plan_review_reverted",
  GoalStatusChanged = "goal_status_changed",
  GoalUpdated = "goal_updated",
  MilestoneCompleted = "milestone_completed",
  DayOpened = "day_opened",
  DayRecovered = "day_recovered",
  DayClosed = "day_closed",
  ReflectionLogged = "reflection_logged",
  CarryoverReviewed = "carryover_reviewed",
  WeekReviewed = "week_reviewed",
  NextWeekShaped = "next_week_shaped",
  WeeklyCarryoverReviewed = "weekly_carryover_reviewed",
  MonthReviewed = "month_reviewed",
  NextMonthShaped = "next_month_shaped",
  MonthlyRecommitmentUpdated = "monthly_recommitment_updated",
  MonthlyCoverageReviewed = "monthly_coverage_reviewed",
}

export interface ActivityEvent extends EntityRecord {
  kind: ActivityEventKind;
  occurredAt: ISODateTimeString;
  date: ISODateString;
  title: string;
  detail: string | null;
  outcomeLabel: string | null;
  goalId: string | null;
  milestoneId: string | null;
  taskId: string | null;
  dailyPlanId: string | null;
  timeBlockId: string | null;
  metadata: JsonMap;
}
