import {
  DomainKey,
  GoalHorizon,
  GoalType,
} from "../domain/models";
import { classifyGoal } from "../engines/decomposition/planning/goalClassifier";
import { mapGoalDomain } from "../engines/decomposition/planning/domainMapper";
import { GoalDraftInference } from "./types";

function titleCase(input: string) {
  const normalized = input.trim().replace(/\s+/g, " ");
  if (!normalized) {
    return "New goal";
  }

  const withCapital = normalized.charAt(0).toUpperCase() + normalized.slice(1);
  return withCapital.endsWith(".") ? withCapital.slice(0, -1) : withCapital;
}

function inferTargetDate(text: string, today: string) {
  const lower = text.toLowerCase();
  const base = new Date(`${today}T12:00:00.000Z`);

  if (/\bthis week\b/.test(lower)) {
    const day = base.getUTCDay();
    const diff = 7 - day || 7;
    base.setUTCDate(base.getUTCDate() + diff);
    return base.toISOString().slice(0, 10);
  }

  if (/\bthis month\b/.test(lower)) {
    const monthEnd = new Date(Date.UTC(base.getUTCFullYear(), base.getUTCMonth() + 1, 0));
    return monthEnd.toISOString().slice(0, 10);
  }

  const relativeMatch = lower.match(/\bin (\d+)\s+(day|days|week|weeks|month|months)\b/);
  if (relativeMatch) {
    const amount = Number(relativeMatch[1]);
    const unit = relativeMatch[2];
    const next = new Date(base);

    if (unit.startsWith("day")) {
      next.setUTCDate(next.getUTCDate() + amount);
    } else if (unit.startsWith("week")) {
      next.setUTCDate(next.getUTCDate() + amount * 7);
    } else {
      next.setUTCMonth(next.getUTCMonth() + amount);
    }

    return next.toISOString().slice(0, 10);
  }

  const isoMatch = text.match(/\b(20\d{2}-\d{2}-\d{2})\b/);
  return isoMatch?.[1] ?? null;
}

function inferWeeklyMinutes(domainKey: DomainKey, type: GoalType) {
  if (type === GoalType.Habit || type === GoalType.System) {
    return 90;
  }

  if (domainKey === DomainKey.Fitness || domainKey === DomainKey.Career) {
    return 150;
  }

  if (domainKey === DomainKey.SkillBuilding) {
    return 120;
  }

  return 75;
}

export function inferGoalDraft(naturalLanguage: string, today: string): GoalDraftInference {
  const normalized = naturalLanguage.trim();
  const title = titleCase(
    normalized
      .replace(/^i want to\s+/i, "")
      .replace(/^help me\s+/i, "")
      .replace(/^my goal is to\s+/i, ""),
  );
  const targetDate = inferTargetDate(normalized, today);
  const draft = {
    title,
    summary: normalized.length > 20 ? normalized : null,
    successMetric: null,
    notes: normalized,
    startDate: today,
    targetDate,
    desiredWeeklyMinutes: null,
    estimatedTotalMinutes: null,
    domainKey: null,
    type: null,
    horizon: null,
    tags: [],
  };

  const domainCandidates = mapGoalDomain(draft);
  const classification = classifyGoal(draft);
  const domainKey = domainCandidates[0]?.domainKey ?? DomainKey.Personal;
  const typeMap: Record<typeof classification.kind, GoalType> = {
    outcome_goal: GoalType.Outcome,
    process_goal: GoalType.System,
    project_goal: GoalType.Project,
  };
  const horizonMap: Record<typeof classification.timeframe, GoalHorizon> = {
    immediate: GoalHorizon.Weekly,
    short: GoalHorizon.Weekly,
    medium: GoalHorizon.Monthly,
    long: GoalHorizon.Yearly,
  };
  const desiredWeeklyMinutes = inferWeeklyMinutes(domainKey, typeMap[classification.kind]);
  const estimatedTotalMinutes =
    classification.timeframe === "long"
      ? desiredWeeklyMinutes * 12
      : classification.timeframe === "medium"
        ? desiredWeeklyMinutes * 6
        : desiredWeeklyMinutes * 3;

  return {
    title,
    naturalLanguage: normalized,
    summary: normalized.length > 24 ? normalized : null,
    domainKey,
    targetDate,
    horizon: horizonMap[classification.timeframe],
    type: typeMap[classification.kind],
    desiredWeeklyMinutes,
    estimatedTotalMinutes,
    successMetric:
      classification.measurable || targetDate
        ? null
        : `Make visible progress on ${title.toLowerCase()}.`,
    notes: normalized,
    focusDomains: domainCandidates.slice(0, 3).map((candidate) => candidate.domainKey),
  };
}
