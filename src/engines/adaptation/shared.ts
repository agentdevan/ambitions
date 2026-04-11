import {
  AdaptationWorkType,
  DurationBand,
  Task,
  TaskStatus,
  TimeOfDayWindow,
} from "../../domain/models";

export type ObservedOutcome =
  | "completed"
  | "missed"
  | "deferred"
  | "split"
  | "substituted";

export interface ObservedTaskRecord {
  task: Task;
  outcome: ObservedOutcome;
  observedAt: string;
  observedDate: string;
  observedTime: string | null;
  durationBand: DurationBand;
  workType: AdaptationWorkType;
  timeWindow: TimeOfDayWindow;
  domainKey: string;
  actualMinutes: number | null;
  estimatedMinutes: number;
  isEntryTask: boolean;
  isRecoveryTask: boolean;
}

export function clamp(value: number, min: number, max: number) {
  return Math.min(max, Math.max(min, value));
}

export function roundToFive(value: number) {
  return Math.round(value / 5) * 5;
}

export function rate(numerator: number, denominator: number) {
  if (denominator <= 0) {
    return 0;
  }

  return numerator / denominator;
}

export function observedOutcomeForTask(task: Task): ObservedOutcome | null {
  switch (task.status) {
    case TaskStatus.Completed:
      return "completed";
    case TaskStatus.Missed:
    case TaskStatus.Skipped:
      return "missed";
    case TaskStatus.Deferred:
      return "deferred";
    case TaskStatus.Split:
      return "split";
    case TaskStatus.Substituted:
      return "substituted";
    default:
      return null;
  }
}

export function durationBandForMinutes(minutes: number): DurationBand {
  if (minutes <= 20) {
    return "short";
  }

  if (minutes <= 35) {
    return "medium";
  }

  return "long";
}

export function workTypeForTask(task: Task): AdaptationWorkType {
  const workType = String(task.metadata.planningWorkType ?? "").trim();

  if (
    workType === "admin" ||
    workType === "research" ||
    workType === "communication" ||
    workType === "deep_work" ||
    workType === "routine_action"
  ) {
    return workType;
  }

  return "unknown";
}

export function preferredDomainKey(task: Task) {
  return String(task.tags[0] ?? task.metadata.domainKey ?? "general");
}

export function representativeTimestamp(task: Task) {
  return (
    task.completedAt ??
    task.earliestStartAt ??
    task.latestFinishAt ??
    task.updatedAt
  );
}

export function timeStringFromTask(task: Task) {
  const candidate =
    task.completedAt ?? task.earliestStartAt ?? task.latestFinishAt ?? null;

  if (!candidate || candidate.length < 16) {
    return null;
  }

  return candidate.slice(11, 16);
}

export function bucketForTime(time: string | null): TimeOfDayWindow {
  const hour = time ? Number(time.slice(0, 2)) : 12;

  if (hour < 10) {
    return "morning";
  }

  if (hour < 14) {
    return "midday";
  }

  if (hour < 18) {
    return "afternoon";
  }

  return "evening";
}

export function preferredWindowStart(window: TimeOfDayWindow) {
  switch (window) {
    case "morning":
      return "08:30";
    case "midday":
      return "11:30";
    case "afternoon":
      return "14:00";
    case "evening":
      return "18:30";
  }
}

export function isEntryTask(task: Task) {
  const title = task.title.toLowerCase();
  const workType = workTypeForTask(task);

  if (task.estimatedMinutes <= 20 && (workType === "admin" || workType === "routine_action")) {
    return true;
  }

  return [
    "choose",
    "pick",
    "set up",
    "start ",
    "open ",
    "minimum",
    "easiest",
    "first step",
  ].some((token) => title.includes(token));
}

export function toObservedRecord(task: Task): ObservedTaskRecord | null {
  const outcome = observedOutcomeForTask(task);

  if (!outcome) {
    return null;
  }

  const observedAt = representativeTimestamp(task);
  const observedTime = timeStringFromTask(task);

  return {
    task,
    outcome,
    observedAt,
    observedDate: observedAt.slice(0, 10),
    observedTime,
    durationBand: durationBandForMinutes(task.estimatedMinutes),
    workType: workTypeForTask(task),
    timeWindow: bucketForTime(observedTime),
    domainKey: preferredDomainKey(task),
    actualMinutes: task.actualMinutes,
    estimatedMinutes: task.estimatedMinutes,
    isEntryTask: isEntryTask(task),
    isRecoveryTask: Boolean(task.metadata.recoverySourceTaskId),
  };
}
