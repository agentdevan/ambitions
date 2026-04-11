import {
  DomainExecutionPattern,
  DurationExecutionPattern,
  ExecutionHistorySummary,
  TaskTypeFrictionPattern,
  TimeOfDayExecutionPattern,
  Task,
} from "../../domain/models";
import {
  ObservedTaskRecord,
  clamp,
  rate,
  roundToFive,
  toObservedRecord,
} from "./shared";

interface DaySummary {
  date: string;
  tasks: ObservedTaskRecord[];
  completedCount: number;
  disruptedCount: number;
  totalEstimatedMinutes: number;
  firstTask: ObservedTaskRecord | null;
}

function average(values: number[]) {
  if (values.length === 0) {
    return null;
  }

  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

function buildDomainPatterns(records: ObservedTaskRecord[]): DomainExecutionPattern[] {
  const grouped = new Map<string, ObservedTaskRecord[]>();

  for (const record of records) {
    const existing = grouped.get(record.domainKey) ?? [];
    existing.push(record);
    grouped.set(record.domainKey, existing);
  }

  return [...grouped.entries()]
    .map(([domainKey, items]) => {
      const completed = items.filter((item) => item.outcome === "completed");
      const successRate = rate(completed.length, items.length);
      const avgCompleted = average(
        completed.map((item) => item.actualMinutes ?? item.estimatedMinutes),
      );

      return {
        domainKey,
        sampleSize: items.length,
        successRate: Number(successRate.toFixed(2)),
        averageCompletedMinutes:
          avgCompleted === null ? null : roundToFive(avgCompleted),
        explanation:
          successRate >= 0.7
            ? `${domainKey} work has been following through reliably enough to trust a little more.`
            : `${domainKey} work still needs protective sizing and cleaner setup.`,
      } satisfies DomainExecutionPattern;
    })
    .sort((left, right) => right.sampleSize - left.sampleSize);
}

function buildTimePatterns(records: ObservedTaskRecord[]): TimeOfDayExecutionPattern[] {
  const windows: ObservedTaskRecord["timeWindow"][] = [
    "morning",
    "midday",
    "afternoon",
    "evening",
  ];

  return windows.map((window) => {
    const items = records.filter((record) => record.timeWindow === window);
    const completed = items.filter((item) => item.outcome === "completed");
    const successRate = rate(completed.length, items.length);
    const adminItems = items.filter((item) => item.workType === "admin");
    const deepItems = items.filter((item) => item.workType === "deep_work");
    const adminSuccess = rate(
      adminItems.filter((item) => item.outcome === "completed").length,
      adminItems.length,
    );
    const deepSuccess = rate(
      deepItems.filter((item) => item.outcome === "completed").length,
      deepItems.length,
    );

    return {
      window,
      sampleSize: items.length,
      successRate: Number(successRate.toFixed(2)),
      preferredForAdmin: adminItems.length >= 2 && adminSuccess >= 0.65,
      preferredForDeepWork: deepItems.length >= 2 && deepSuccess >= 0.65,
      explanation:
        items.length === 0
          ? `No stable ${window} pattern yet.`
          : successRate >= 0.65
            ? `${window} execution has been relatively stable.`
            : `${window} execution has been less reliable and should stay conservative.`,
    } satisfies TimeOfDayExecutionPattern;
  });
}

function buildDurationPatterns(records: ObservedTaskRecord[]): DurationExecutionPattern[] {
  const bands: ObservedTaskRecord["durationBand"][] = ["short", "medium", "long"];

  return bands.map((band) => {
    const items = records.filter((record) => record.durationBand === band);
    const completed = items.filter((item) => item.outcome === "completed");
    const completionRate = rate(completed.length, items.length);
    const confidence = clamp(
      completionRate - (band === "long" && completionRate < 0.55 ? 0.15 : 0),
      0,
      1,
    );

    return {
      band,
      sampleSize: items.length,
      completionRate: Number(completionRate.toFixed(2)),
      confidence: Number(confidence.toFixed(2)),
      explanation:
        band === "long" && completionRate < 0.55
          ? "Longer tasks are still carrying too much execution risk."
          : `${band} tasks are behaving predictably enough for deterministic planning.`,
    } satisfies DurationExecutionPattern;
  });
}

function buildTaskTypeFriction(records: ObservedTaskRecord[]): TaskTypeFrictionPattern[] {
  const workTypes: ObservedTaskRecord["workType"][] = [
    "admin",
    "research",
    "communication",
    "deep_work",
    "routine_action",
    "unknown",
  ];

  return workTypes.map((workType) => {
    const items = records.filter((record) => record.workType === workType);
    const missedOrDeferred = items.filter((item) =>
      ["missed", "deferred", "split", "substituted"].includes(item.outcome),
    ).length;
    const slowCompletions = items.filter(
      (item) =>
        item.outcome === "completed" &&
        item.actualMinutes !== null &&
        item.actualMinutes > item.estimatedMinutes * 1.2,
    ).length;
    const frictionScore = clamp(
      rate(missedOrDeferred + slowCompletions * 0.5, Math.max(1, items.length)),
      0,
      1,
    );
    const markers: string[] = [];

    if (items.some((item) => item.durationBand === "long") && frictionScore >= 0.45) {
      markers.push("large_sessions_break");
    }
    if (rate(
      items.filter((item) => item.outcome === "deferred").length,
      Math.max(1, items.length),
    ) >= 0.25) {
      markers.push("startup_friction");
    }
    if (rate(
      items.filter((item) => ["split", "substituted"].includes(item.outcome)).length,
      Math.max(1, items.length),
    ) >= 0.2) {
      markers.push("needs_smaller_recovery");
    }
    if (slowCompletions > 0) {
      markers.push("underestimated_duration");
    }

    return {
      workType,
      sampleSize: items.length,
      frictionScore: Number(frictionScore.toFixed(2)),
      markers,
      explanation:
        frictionScore >= 0.45
          ? `${workType} work shows repeated drag and should be sized more conservatively.`
          : `${workType} work is not showing major friction beyond normal variation.`,
    } satisfies TaskTypeFrictionPattern;
  });
}

function buildDaySummaries(records: ObservedTaskRecord[]): DaySummary[] {
  const grouped = new Map<string, ObservedTaskRecord[]>();

  for (const record of records) {
    const existing = grouped.get(record.observedDate) ?? [];
    existing.push(record);
    grouped.set(record.observedDate, existing);
  }

  return [...grouped.entries()]
    .map(([date, items]) => {
      const sorted = [...items].sort((left, right) =>
        (left.observedTime ?? "12:00").localeCompare(right.observedTime ?? "12:00"),
      );

      return {
        date,
        tasks: sorted,
        completedCount: sorted.filter((item) => item.outcome === "completed").length,
        disruptedCount: sorted.filter((item) =>
          ["missed", "deferred", "split", "substituted"].includes(item.outcome),
        ).length,
        totalEstimatedMinutes: sorted.reduce(
          (sum, item) => sum + item.estimatedMinutes,
          0,
        ),
        firstTask: sorted[0] ?? null,
      } satisfies DaySummary;
    })
    .sort((left, right) => right.date.localeCompare(left.date));
}

function consecutiveCompletionStreak(daySummaries: DaySummary[]) {
  let streak = 0;

  for (const day of daySummaries) {
    if (day.completedCount > 0) {
      streak += 1;
      continue;
    }

    break;
  }

  return streak;
}

export interface InterpretedExecutionHistory {
  summary: ExecutionHistorySummary;
  records: ObservedTaskRecord[];
  recentRecords: ObservedTaskRecord[];
  baselineRecords: ObservedTaskRecord[];
  daySummaries: DaySummary[];
  streakDays: number;
}

export function interpretExecutionHistory(tasks: Task[]): InterpretedExecutionHistory {
  const records = tasks
    .map((task) => toObservedRecord(task))
    .filter((record): record is ObservedTaskRecord => record !== null)
    .sort((left, right) => right.observedAt.localeCompare(left.observedAt));
  const recentRecords = records.slice(0, 12);
  const baselineRecords = records.slice(0, 30);
  const daySummaries = buildDaySummaries(records);
  const completedRecords = records.filter((record) => record.outcome === "completed");
  const completedMinutes = completedRecords.map(
    (record) => record.actualMinutes ?? record.estimatedMinutes,
  );
  const averageCompletedMinutes = average(completedMinutes);
  const averageCompletedDurationBand =
    averageCompletedMinutes === null
      ? null
      : averageCompletedMinutes <= 20
        ? "short"
        : averageCompletedMinutes <= 35
          ? "medium"
          : "long";
  const carryoverPressureRate = rate(
    records.filter((record) =>
      ["deferred", "split", "substituted"].includes(record.outcome),
    ).length,
    Math.max(1, records.length),
  );
  const splitRecoveryTasks = records.filter(
    (record) => record.task.metadata.recoveryStrategy === "split",
  );
  const substituteRecoveryTasks = records.filter(
    (record) => record.task.metadata.recoveryStrategy === "substitute",
  );
  const missedStartCollapseDays = daySummaries.filter(
    (day) =>
      day.firstTask &&
      ["missed", "deferred", "split", "substituted"].includes(day.firstTask.outcome) &&
      day.completedCount === 0,
  ).length;
  const entrySuccessDays = daySummaries.filter((day) =>
    day.tasks.some((task) => task.isEntryTask && task.outcome === "completed"),
  );
  const liftedEntryDays = entrySuccessDays.filter((day) => day.completedCount >= 2).length;
  const overloadedDays = daySummaries.filter(
    (day) => day.totalEstimatedMinutes >= 180 || (day.disruptedCount >= 2 && day.tasks.length >= 4),
  ).length;
  const streakDays = consecutiveCompletionStreak(daySummaries);

  return {
    summary: {
      sampleSize: records.length,
      recentWindowSize: recentRecords.length,
      recentCompletionRate: Number(
        rate(
          recentRecords.filter((record) => record.outcome === "completed").length,
          Math.max(1, recentRecords.length),
        ).toFixed(2),
      ),
      baselineCompletionRate: Number(
        rate(
          baselineRecords.filter((record) => record.outcome === "completed").length,
          Math.max(1, baselineRecords.length),
        ).toFixed(2),
      ),
      averageCompletedMinutes:
        averageCompletedMinutes === null ? null : roundToFive(averageCompletedMinutes),
      averageCompletedDurationBand,
      carryoverPressureRate: Number(carryoverPressureRate.toFixed(2)),
      recoveryRelianceRate: Number(
        rate(
          records.filter((record) => record.isRecoveryTask).length,
          Math.max(1, records.length),
        ).toFixed(2),
      ),
      splitRecoverySuccessRate:
        splitRecoveryTasks.length === 0
          ? null
          : Number(
              rate(
                splitRecoveryTasks.filter((record) => record.outcome === "completed").length,
                splitRecoveryTasks.length,
              ).toFixed(2),
            ),
      substituteRecoverySuccessRate:
        substituteRecoveryTasks.length === 0
          ? null
          : Number(
              rate(
                substituteRecoveryTasks.filter((record) => record.outcome === "completed").length,
                substituteRecoveryTasks.length,
              ).toFixed(2),
            ),
      missedStartCollapseRate: Number(
        rate(missedStartCollapseDays, Math.max(1, daySummaries.length)).toFixed(2),
      ),
      entryTaskLiftRate: Number(
        rate(liftedEntryDays, Math.max(1, entrySuccessDays.length)).toFixed(2),
      ),
      overloadedDayRate: Number(
        rate(overloadedDays, Math.max(1, daySummaries.length)).toFixed(2),
      ),
      domainPatterns: buildDomainPatterns(records),
      timeOfDayPatterns: buildTimePatterns(records),
      durationPatterns: buildDurationPatterns(records),
      taskTypeFriction: buildTaskTypeFriction(records),
    },
    records,
    recentRecords,
    baselineRecords,
    daySummaries,
    streakDays,
  };
}
