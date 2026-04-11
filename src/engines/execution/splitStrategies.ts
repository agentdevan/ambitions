import { RecoveryTaskCandidate, Task, TaskDifficulty } from "../../domain/models";
import {
  buildRecoveryTaskBase,
  createTimestampedId,
  deriveProtectiveMode,
  deriveWorkType,
  fallbackTaskTitle,
  nextDifficulty,
  parseBooleanMetadata,
} from "./helpers";

function splitMinutes(task: Task) {
  const protective = deriveProtectiveMode(task);
  const first = protective ? Math.min(20, Math.max(10, Math.floor(task.estimatedMinutes * 0.4))) : Math.min(25, Math.max(15, Math.floor(task.estimatedMinutes * 0.45)));
  const second = Math.max(10, task.estimatedMinutes - first);
  return [first, second];
}

function setupTitle(task: Task) {
  const workType = deriveWorkType(task);

  if (workType === "research") {
    return `Set up the first step for ${task.title.toLowerCase()}`;
  }

  if (workType === "admin") {
    return fallbackTaskTitle(task);
  }

  if (workType === "deep_work") {
    return `Outline the first pass for ${task.title.toLowerCase()}`;
  }

  if (workType === "routine_action") {
    return `Do the minimum version of ${task.title.toLowerCase()}`;
  }

  return fallbackTaskTitle(task);
}

function followThroughTitle(task: Task) {
  const workType = deriveWorkType(task);

  if (workType === "research") {
    return `Capture the main finding from ${task.title.toLowerCase()}`;
  }

  if (workType === "admin") {
    return `Finish the next concrete step for ${task.title.toLowerCase()}`;
  }

  if (workType === "deep_work") {
    return `Finish the smallest shippable version of ${task.title.toLowerCase()}`;
  }

  if (workType === "routine_action") {
    return `Repeat the easiest follow-through for ${task.title.toLowerCase()}`;
  }

  return `Finish ${task.title.toLowerCase()} in one smaller pass`;
}

export function buildSplitCandidates(task: Task, occurredAt: string): RecoveryTaskCandidate[] {
  const splitEligible = parseBooleanMetadata(task.metadata.planningSplitEligible);

  if (!splitEligible || task.estimatedMinutes < 20) {
    return [];
  }

  const [firstMinutes, secondMinutes] = splitMinutes(task);
  const smallerDifficulty = nextDifficulty(task.difficulty);

  const first = buildRecoveryTaskBase({
    sourceTask: task,
    id: createTimestampedId("task-split", `${task.id}-1`, occurredAt),
    title: setupTitle(task),
    summary: "Smaller first-step recovery generated after a missed or overloaded task.",
    estimatedMinutes: firstMinutes,
    difficulty: smallerDifficulty,
    strategy: "split",
    occurredAt,
  });
  const second = buildRecoveryTaskBase({
    sourceTask: task,
    id: createTimestampedId("task-split", `${task.id}-2`, occurredAt),
    title: followThroughTitle(task),
    summary: "Second smaller recovery step that preserves the original milestone intent.",
    estimatedMinutes: secondMinutes,
    difficulty: smallerDifficulty === TaskDifficulty.Light ? TaskDifficulty.Light : task.difficulty,
    strategy: "split",
    occurredAt,
  });

  return [
    {
      task: first,
      strategy: "split",
      explanation: "Retry smaller by turning the missed task into a first step plus a finish pass.",
    },
    {
      task: second,
      strategy: "split",
      explanation: "Keep milestone continuity with a second bounded follow-up instead of a full repeat.",
    },
  ];
}
