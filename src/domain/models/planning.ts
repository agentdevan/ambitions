import { EntityRecord, ISODateString, ISODateTimeString, JsonMap } from "./shared";

export enum TaskStatus {
  Inbox = "inbox",
  Ready = "ready",
  Scheduled = "scheduled",
  InProgress = "in_progress",
  Completed = "completed",
  Deferred = "deferred",
  Cancelled = "cancelled",
}

export enum TaskSchedulingState {
  Unscheduled = "unscheduled",
  Proposed = "proposed",
  Committed = "committed",
  InFlight = "in_flight",
  Rolled = "rolled",
  Blocked = "blocked",
  Done = "done",
}

export enum TaskDifficulty {
  Light = "light",
  Moderate = "moderate",
  Deep = "deep",
}

export enum TimeBlockType {
  Focus = "focus",
  Admin = "admin",
  Buffer = "buffer",
  Meeting = "meeting",
  Recovery = "recovery",
}

export enum TimeBlockState {
  Scheduled = "scheduled",
  Active = "active",
  Complete = "complete",
  Rolled = "rolled",
  Deferred = "deferred",
  Cancelled = "cancelled",
}

export enum DailyPlanStatus {
  Draft = "draft",
  Ready = "ready",
  InProgress = "in_progress",
  Completed = "completed",
  Archived = "archived",
}

export interface Task extends EntityRecord {
  goalId: string | null;
  milestoneId: string | null;
  parentTaskId: string | null;
  title: string;
  summary: string | null;
  status: TaskStatus;
  schedulingState: TaskSchedulingState;
  difficulty: TaskDifficulty;
  estimatedMinutes: number;
  actualMinutes: number | null;
  effortPoints: number | null;
  targetDate: ISODateString | null;
  scheduledDate: ISODateString | null;
  earliestStartAt: ISODateTimeString | null;
  latestFinishAt: ISODateTimeString | null;
  completedAt: ISODateTimeString | null;
  isRecurringTemplate: boolean;
  tags: string[];
  metadata: JsonMap;
}

export interface TimeBlock extends EntityRecord {
  dailyPlanId: string;
  taskId: string | null;
  goalId: string | null;
  title: string;
  type: TimeBlockType;
  state: TimeBlockState;
  startsAt: string;
  endsAt: string;
  startsAtDateTime: ISODateTimeString;
  endsAtDateTime: ISODateTimeString;
  note: string | null;
  energyLabel: TaskDifficulty;
  sourceConstraintId: string | null;
  metadata: JsonMap;
}

export interface DailyPlan extends EntityRecord {
  date: ISODateString;
  status: DailyPlanStatus;
  focus: string;
  planningNotes: string | null;
  totalPlannedMinutes: number;
  totalCommittedMinutes: number;
  adaptationProfileId: string | null;
  metadata: JsonMap;
}
