import { RecoveryStrategy, Task } from "../../domain/models";
import { buildSplitCandidates } from "./splitStrategies";
import { buildSubstituteCandidate } from "./substituteStrategies";

export interface RolloverDecision {
  strategy: RecoveryStrategy;
  rationale: string;
}

function continuityScore(task: Task) {
  let score = 0;

  if (task.goalId) score += 2;
  if (task.milestoneId) score += 2;
  if (task.targetDate) score += 1;
  if (task.metadata.planningContinuityToken) score += 1;

  return score;
}

function frictionScore(task: Task) {
  let score = 0;

  if (task.estimatedMinutes >= 40) score += 2;
  if (task.difficulty === "deep") score += 2;
  if (String(task.metadata.planningWorkType ?? "") === "research") score += 1;
  if (String(task.metadata.planningWorkType ?? "") === "deep_work") score += 1;

  return score;
}

export function evaluateRollover(task: Task, occurredAt: string): RolloverDecision {
  const splitCandidates = buildSplitCandidates(task, occurredAt);
  const substituteCandidate = buildSubstituteCandidate(task, occurredAt);
  const continuity = continuityScore(task);
  const friction = frictionScore(task);

  if (splitCandidates.length > 0 && friction >= 3) {
    return {
      strategy: "split",
      rationale: "The task looks too large for a clean retry, so a smaller recovery path is safer.",
    };
  }

  if (substituteCandidate && continuity >= 3) {
    return {
      strategy: "substitute",
      rationale: "A lower-friction substitute keeps the milestone moving better than repeating the same task unchanged.",
    };
  }

  if (continuity >= 4) {
    return {
      strategy: "defer",
      rationale: "The task still matters, but it should leave today without being auto-rolled into another crowded window.",
    };
  }

  return {
    strategy: "unscheduled",
    rationale: "This task should drop out of the current day and wait for deliberate review instead of endless rollover.",
  };
}
