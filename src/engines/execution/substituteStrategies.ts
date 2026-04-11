import { RecoveryTaskCandidate, Task, TaskDifficulty } from "../../domain/models";
import { buildRecoveryTaskBase, createTimestampedId, deriveWorkType, nextDifficulty } from "./helpers";

function substituteTitle(task: Task) {
  const lower = task.title.toLowerCase();
  const workType = deriveWorkType(task);

  if (lower.includes("budget")) {
    return "Open the budget and identify the largest category";
  }

  if (lower.includes("resume")) {
    return "Tailor the resume for one strong-fit role";
  }

  if (lower.includes("train") || lower.includes("session") || lower.includes("workout")) {
    return "Complete the easiest starting session";
  }

  if (workType === "research") {
    return `Pull one key input for ${lower}`;
  }

  if (workType === "admin") {
    return `Complete the smallest meaningful admin step for ${lower}`;
  }

  if (workType === "deep_work") {
    return `Create the first rough piece of ${lower}`;
  }

  return `Take the lowest-friction next step for ${lower}`;
}

function substituteSummary(task: Task) {
  return `Lower-friction substitute for "${task.title}" that keeps the same goal and milestone in motion.`;
}

export function buildSubstituteCandidate(task: Task, occurredAt: string): RecoveryTaskCandidate | null {
  const workType = deriveWorkType(task);
  const eligibleWorkTypes = new Set(["research", "admin", "deep_work", "routine_action"]);

  if (!eligibleWorkTypes.has(workType) && task.estimatedMinutes < 25) {
    return null;
  }

  const estimatedMinutes = Math.max(10, Math.min(25, Math.floor(task.estimatedMinutes * 0.5)));
  const substituteTask = buildRecoveryTaskBase({
    sourceTask: task,
    id: createTimestampedId("task-substitute", task.id, occurredAt),
    title: substituteTitle(task),
    summary: substituteSummary(task),
    estimatedMinutes,
    difficulty: nextDifficulty(task.difficulty) === TaskDifficulty.Light ? TaskDifficulty.Light : TaskDifficulty.Moderate,
    strategy: "substitute",
    occurredAt,
  });

  return {
    task: substituteTask,
    strategy: "substitute",
    explanation: "Swap the missed task for a lower-friction action that preserves continuity.",
  };
}
