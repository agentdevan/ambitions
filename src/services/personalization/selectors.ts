import { AdaptationProfile, Goal, Task, TaskDifficulty, TaskStatus } from "../../domain/models";

function average(values: number[]) {
  if (values.length === 0) {
    return null;
  }

  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

export function buildPlanningStyleSummary(profile: AdaptationProfile | null, adaptiveEnabled = true) {
  if (!adaptiveEnabled || !profile?.personalization.active) {
    return null;
  }

  return {
    title: "Planning style",
    summary: profile.personalization.summary.planningStyle,
    notes: profile.personalization.signals.slice(0, 3).map((signal) => signal.value),
  };
}

export function buildGoalPersonalization(params: {
  goal: Goal;
  tasks: Task[];
  profile: AdaptationProfile | null;
  adaptiveEnabled?: boolean;
}) {
  const { tasks, profile, adaptiveEnabled = true } = params;
  const activeTasks = tasks.filter((task) =>
    [
      TaskStatus.Ready,
      TaskStatus.Scheduled,
      TaskStatus.InProgress,
      TaskStatus.Deferred,
      TaskStatus.Split,
      TaskStatus.Substituted,
      TaskStatus.Missed,
    ].includes(task.status),
  );
  const carryoverCount = tasks.filter((task) =>
    [TaskStatus.Deferred, TaskStatus.Missed, TaskStatus.Split, TaskStatus.Substituted].includes(
      task.status,
    ),
  ).length;
  const averageTaskSize = average(activeTasks.map((task) => task.estimatedMinutes)) ?? 0;
  const deepTaskShare =
    activeTasks.length > 0
      ? activeTasks.filter((task) => task.difficulty === TaskDifficulty.Deep).length /
        activeTasks.length
      : 0;
  const personalization =
    adaptiveEnabled && profile?.personalization.active ? profile.personalization : null;

  const momentumStyle =
    averageTaskSize > 0 && averageTaskSize <= 25
      ? "This goal is moving best in smaller steps."
      : deepTaskShare >= 0.45
        ? "This goal can justify a more deliberate session when the window is real."
        : "This goal is moving best with steady medium effort.";
  const nextMove =
    carryoverCount >= 3
      ? "Keep the next move narrower so this goal stops carrying forward."
      : personalization?.lateDayStyle === "avoid_late_heavy" && deepTaskShare >= 0.4
        ? "Protect the next meaningful session earlier in the day if you can."
        : averageTaskSize <= 25
          ? "Pick one visible next step and let that be enough."
          : "Protect one clean session instead of scattering work across the day.";

  return {
    momentumStyle,
    nextMove,
  };
}

export function buildInsightHighlights(profile: AdaptationProfile | null, adaptiveEnabled = true) {
  const personalization =
    adaptiveEnabled && profile?.personalization.active ? profile.personalization : null;

  if (!personalization) {
    return [];
  }

  const highlights = [personalization.summary.insights];

  if (personalization.taskSizingStyle === "shorter_tasks") {
    highlights.push("Most progress is coming from shorter focused blocks.");
  } else if (personalization.taskSizingStyle === "deeper_blocks") {
    highlights.push("Longer focused sessions are holding well enough to keep using them.");
  }

  if (personalization.carryoverStyle === "high") {
    highlights.push("Carryover tends to rise after fuller days.");
  }

  if (personalization.planStability === "stable") {
    highlights.push("Plan changes have stayed relatively low lately.");
  }

  if (personalization.openWindowStyle === "short_bursts") {
    highlights.push("Open windows are working best when kept short and useful.");
  }

  return highlights.slice(0, 4);
}
