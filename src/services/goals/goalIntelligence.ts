import { Goal, JsonMap } from "../../domain/models";
import {
  GoalFeasibilityTruth,
  GoalPaceMode,
  GoalStrategyComposer,
} from "../../product/types";

const goalIntelligenceMetadataKey = "phase22GoalIntelligence";

function isJsonObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isPaceMode(value: unknown): value is GoalPaceMode {
  return value === "conservative" || value === "balanced" || value === "aggressive";
}

export interface GoalIntelligenceSnapshot {
  selectedPaceMode: GoalPaceMode;
  recommendedPaceMode: GoalPaceMode;
  feasibility: GoalFeasibilityTruth;
  availableCapacitySummary: string;
  commitmentsSummary: string;
  behaviorSummary: string;
  workloadEstimateMinutes: number;
  workloadEstimateLabel: string;
  interpretation: GoalStrategyComposer["interpretation"];
  paceOptions: GoalStrategyComposer["paceOptions"];
  firstMilestonePath: GoalStrategyComposer["firstMilestonePath"];
  firstWeekActionPreview: GoalStrategyComposer["firstWeekActionPreview"];
  createdAt: string;
}

function cloneJson<T>(value: T): T {
  return JSON.parse(JSON.stringify(value)) as T;
}

export function buildGoalIntelligenceSnapshot(
  composer: GoalStrategyComposer,
): GoalIntelligenceSnapshot {
  return {
    selectedPaceMode: composer.selectedPaceMode,
    recommendedPaceMode: composer.recommendedPaceMode,
    feasibility: cloneJson(composer.feasibility),
    availableCapacitySummary: composer.availableCapacitySummary,
    commitmentsSummary: composer.commitmentsSummary,
    behaviorSummary: composer.behaviorSummary,
    workloadEstimateMinutes: composer.workloadEstimateMinutes,
    workloadEstimateLabel: composer.workloadEstimateLabel,
    interpretation: cloneJson(composer.interpretation),
    paceOptions: cloneJson(composer.paceOptions),
    firstMilestonePath: cloneJson(composer.firstMilestonePath),
    firstWeekActionPreview: cloneJson(composer.firstWeekActionPreview),
    createdAt: new Date().toISOString(),
  };
}

export function getGoalIntelligenceSnapshot(goal: Goal): GoalIntelligenceSnapshot | null {
  const raw = goal.metadata[goalIntelligenceMetadataKey];
  if (!isJsonObject(raw) || !isPaceMode(raw.selectedPaceMode) || !isPaceMode(raw.recommendedPaceMode)) {
    return null;
  }

  const feasibility = isJsonObject(raw.feasibility) ? raw.feasibility : null;
  const interpretation = isJsonObject(raw.interpretation) ? raw.interpretation : null;
  if (!feasibility || !interpretation) {
    return null;
  }

  return raw as unknown as GoalIntelligenceSnapshot;
}

export function setGoalIntelligenceSnapshot(
  goal: Goal,
  snapshot: GoalIntelligenceSnapshot | null,
): Goal {
  const metadata: JsonMap = cloneJson(goal.metadata);

  if (snapshot) {
    metadata[goalIntelligenceMetadataKey] = cloneJson(snapshot) as unknown as JsonMap;
  } else {
    delete metadata[goalIntelligenceMetadataKey];
  }

  return {
    ...goal,
    metadata,
  };
}

export function getGoalPaceMode(goal: Goal): GoalPaceMode {
  return getGoalIntelligenceSnapshot(goal)?.selectedPaceMode ?? "balanced";
}

export function describeGoalPaceMode(mode: GoalPaceMode) {
  switch (mode) {
    case "conservative":
      return "Conservative";
    case "aggressive":
      return "Aggressive";
    default:
      return "Balanced";
  }
}

export function describeGoalFeasibility(goal: Goal) {
  const snapshot = getGoalIntelligenceSnapshot(goal);
  if (!snapshot) {
    return null;
  }

  const statusLabel =
    snapshot.feasibility.status === "feasible"
      ? "Believable"
      : snapshot.feasibility.status === "tight"
        ? "Tight"
        : "Unlikely";

  return {
    statusLabel,
    summary: snapshot.feasibility.summary,
    detail: snapshot.feasibility.detail,
    deadlineConfidence: snapshot.feasibility.deadlineConfidence,
  };
}

export function buildGoalPressureNote(goal: Goal) {
  const snapshot = getGoalIntelligenceSnapshot(goal);
  if (!snapshot || snapshot.feasibility.status === "feasible") {
    return null;
  }

  return snapshot.feasibility.status === "tight"
    ? `${goal.title} is still possible, but tighter than before. ${snapshot.feasibility.highestLeverageStep}`
    : `${goal.title} is unlikely to hold on the current path. ${snapshot.feasibility.highestLeverageStep}`;
}
