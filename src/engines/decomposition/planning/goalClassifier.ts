import { GoalHorizon, GoalType } from "../../../domain/models";
import {
  GoalClassification,
  GoalClassificationKind,
  GoalComplexity,
  GoalDraftInput,
  GoalPathShape,
  GoalTimeframe,
} from "../../../domain/models/planningBrain";
import { daysBetween } from "./date";

function normalizeText(input: GoalDraftInput) {
  return [input.title, input.summary, input.successMetric, input.notes, ...(input.tags ?? [])]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();
}

function inferKind(input: GoalDraftInput, text: string, reasons: string[]) {
  if (input.type === GoalType.Project) {
    reasons.push("Existing goal type marks this as a project.");
    return GoalClassificationKind.ProjectGoal;
  }

  if (input.type === GoalType.System || input.type === GoalType.Habit) {
    reasons.push("Existing goal type emphasizes repeated process behavior.");
    return GoalClassificationKind.ProcessGoal;
  }

  if (input.type === GoalType.Outcome) {
    reasons.push("Existing goal type emphasizes an end-state outcome.");
    return GoalClassificationKind.OutcomeGoal;
  }

  if (/(build|create|launch|ship|complete|finish|organize|pay down|raise|land)/.test(text)) {
    reasons.push("The title reads like a finite deliverable or target.");
    return GoalClassificationKind.ProjectGoal;
  }

  if (/(every|per week|weekly|daily|consisten|routine|habit|practice|train)/.test(text)) {
    reasons.push("The language emphasizes a repeatable cadence.");
    return GoalClassificationKind.ProcessGoal;
  }

  reasons.push("The goal reads like a target state rather than a repeated routine.");
  return GoalClassificationKind.OutcomeGoal;
}

function inferTimeframe(input: GoalDraftInput, daysToTarget: number | null, reasons: string[]) {
  if (input.horizon === GoalHorizon.Daily || (daysToTarget !== null && daysToTarget <= 7)) {
    reasons.push("The target sits in an immediate window.");
    return GoalTimeframe.Immediate;
  }

  if (input.horizon === GoalHorizon.Weekly || (daysToTarget !== null && daysToTarget <= 31)) {
    reasons.push("The target sits in a short execution window.");
    return GoalTimeframe.Short;
  }

  if (input.horizon === GoalHorizon.Monthly || (daysToTarget !== null && daysToTarget <= 120)) {
    reasons.push("The target spans multiple weeks but not a long arc.");
    return GoalTimeframe.Medium;
  }

  reasons.push("The goal requires a long planning horizon.");
  return GoalTimeframe.Long;
}

function inferMeasurable(input: GoalDraftInput, text: string, reasons: string[]) {
  const hasMetricText = Boolean(input.successMetric && input.successMetric.trim().length > 0);
  const hasNumericSignal = /\b\d+(\.\d+)?\b/.test(text);
  const hasMinuteTarget =
    typeof input.desiredWeeklyMinutes === "number" || typeof input.estimatedTotalMinutes === "number";

  if (hasMetricText || hasNumericSignal || hasMinuteTarget) {
    reasons.push("The goal includes a concrete metric or numeric signal.");
    return true;
  }

  reasons.push("The goal lacks a clear quantitative marker.");
  return false;
}

function inferComplexity(
  input: GoalDraftInput,
  kind: GoalClassificationKind,
  timeframe: GoalTimeframe,
  text: string,
  reasons: string[],
) {
  let score = 0;

  if (kind === GoalClassificationKind.ProjectGoal) {
    score += 2;
  }

  if (timeframe === GoalTimeframe.Long) {
    score += 2;
  } else if (timeframe === GoalTimeframe.Medium) {
    score += 1;
  }

  if (typeof input.estimatedTotalMinutes === "number" && input.estimatedTotalMinutes >= 1200) {
    score += 2;
  } else if (typeof input.estimatedTotalMinutes === "number" && input.estimatedTotalMinutes >= 300) {
    score += 1;
  }

  if (/(multiple|several|portfolio|system|foundation|rebuild|improve|raise)/.test(text)) {
    score += 1;
  }

  if (score >= 4) {
    reasons.push("Longer horizon plus broader scope suggests high complexity.");
    return GoalComplexity.High;
  }

  if (score >= 2) {
    reasons.push("The goal needs a moderate amount of staged work.");
    return GoalComplexity.Moderate;
  }

  reasons.push("The goal can likely be advanced through a lighter plan.");
  return GoalComplexity.Low;
}

function inferPathShape(
  kind: GoalClassificationKind,
  complexity: GoalComplexity,
  text: string,
  reasons: string[],
) {
  if (
    kind === GoalClassificationKind.ProjectGoal ||
    complexity === GoalComplexity.High ||
    /(foundation|portfolio|score|career|finance|credit|rebuild|learn)/.test(text)
  ) {
    reasons.push("The goal likely requires multiple staged moves.");
    return GoalPathShape.MultiStep;
  }

  reasons.push("The goal can likely progress through a single dominant path.");
  return GoalPathShape.SinglePath;
}

export function classifyGoal(input: GoalDraftInput): GoalClassification {
  const reasons: string[] = [];
  const text = normalizeText(input);
  const daysToTarget =
    input.targetDate && input.startDate ? daysBetween(input.startDate, input.targetDate) : null;
  const kind = inferKind(input, text, reasons);
  const timeframe = inferTimeframe(input, daysToTarget, reasons);
  const measurable = inferMeasurable(input, text, reasons);
  const complexity = inferComplexity(input, kind, timeframe, text, reasons);
  const pathShape = inferPathShape(kind, complexity, text, reasons);

  return {
    kind,
    timeframe,
    measurable,
    complexity,
    domainConfidence: input.domainKey ? 0.8 : 0.4,
    pathShape,
    reasons,
  };
}
