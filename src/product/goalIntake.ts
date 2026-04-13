import {
  DomainKey,
  GoalHorizon,
  GoalType,
} from "../domain/models";
import { classifyGoal } from "../engines/decomposition/planning/goalClassifier";
import { mapGoalDomain } from "../engines/decomposition/planning/domainMapper";
import { GoalInterpretation, GoalPaceMode, GoalDraftInference } from "./types";

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
  const monthIndex: Record<string, number> = {
    january: 0,
    february: 1,
    march: 2,
    april: 3,
    may: 4,
    june: 5,
    july: 6,
    august: 7,
    september: 8,
    october: 9,
    november: 10,
    december: 11,
  };

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
  if (isoMatch?.[1]) {
    return isoMatch[1];
  }

  const monthDateMatch = lower.match(
    /\b(january|february|march|april|may|june|july|august|september|october|november|december)\s+(\d{1,2})(?:,\s*(20\d{2}))?\b/,
  );
  if (monthDateMatch) {
    const [, monthName, dayText, yearText] = monthDateMatch;
    const month = monthIndex[monthName];
    const day = Number(dayText);
    const year = yearText ? Number(yearText) : base.getUTCFullYear();
    const parsed = new Date(Date.UTC(year, month, day));
    if (!Number.isNaN(parsed.getTime())) {
      if (!yearText && parsed < base) {
        parsed.setUTCFullYear(parsed.getUTCFullYear() + 1);
      }
      return parsed.toISOString().slice(0, 10);
    }
  }

  const seasonMatch = lower.match(/\b(this summer|this fall|this autumn|this winter|this spring)\b/);
  if (seasonMatch) {
    const label = seasonMatch[1];
    const seasonDate =
      label === "this spring"
        ? new Date(Date.UTC(base.getUTCFullYear(), 4, 31))
        : label === "this summer"
          ? new Date(Date.UTC(base.getUTCFullYear(), 7, 31))
          : label === "this fall" || label === "this autumn"
            ? new Date(Date.UTC(base.getUTCFullYear(), 10, 30))
            : new Date(Date.UTC(base.getUTCFullYear(), 1, 28));

    if (seasonDate < base) {
      seasonDate.setUTCFullYear(seasonDate.getUTCFullYear() + 1);
    }

    return seasonDate.toISOString().slice(0, 10);
  }

  return null;
}

function inferWeeklyMinutes(
  domainKey: DomainKey,
  type: GoalType,
  naturalLanguage: string,
  targetDate: string | null,
  today: string,
) {
  const lower = naturalLanguage.toLowerCase();

  if (type === GoalType.Habit || type === GoalType.System) {
    return /\bdaily\b/.test(lower) ? 140 : 100;
  }

  if (domainKey === DomainKey.Fitness || domainKey === DomainKey.Career) {
    return 180;
  }

  if (domainKey === DomainKey.SkillBuilding) {
    return 150;
  }

  if (domainKey === DomainKey.Finance || domainKey === DomainKey.Credit) {
    return 90;
  }

  const daysUntilTarget =
    targetDate === null
      ? null
      : Math.max(
          1,
          Math.ceil(
            (Date.parse(`${targetDate}T12:00:00.000Z`) - Date.parse(`${today}T12:00:00.000Z`)) /
              86400000,
          ),
        );
  if (daysUntilTarget !== null && daysUntilTarget <= 21) {
    return 210;
  }

  return 120;
}

function inferWorkPattern(domainKey: DomainKey, type: GoalType, lower: string) {
  if (/\brelease|launch|publish|ship\b/.test(lower)) {
    return /\bsong|songs|music|album\b/.test(lower)
      ? "Creative production and release"
      : "Build, review, and ship";
  }

  if (domainKey === DomainKey.Career && /\bjob|apply|application|resume|portfolio\b/.test(lower)) {
    return "Application cycle";
  }

  if (domainKey === DomainKey.SkillBuilding || /\blearn|study|practice|course\b/.test(lower)) {
    return "Curriculum and practice";
  }

  if (domainKey === DomainKey.Fitness || /\blose|weight|train|workout|run\b/.test(lower)) {
    return type === GoalType.System ? "Consistency and repetition" : "Training progression";
  }

  if (domainKey === DomainKey.Finance || domainKey === DomainKey.Credit) {
    return /\bdebt|pay off|score\b/.test(lower)
      ? "Step-down progress with review points"
      : "Steady financial clean-up";
  }
  return type === GoalType.System ? "Consistency and repetition" : "Milestone-based project path";
}

function inferTaskCategories(domainKey: DomainKey, lower: string) {
  if (/\bsong|songs|music|album\b/.test(lower)) {
    return ["Creation", "Review", "Release prep"];
  }

  if (domainKey === DomainKey.Career) {
    return ["Research", "Application materials", "Outreach"];
  }

  if (domainKey === DomainKey.SkillBuilding) {
    return ["Study", "Practice", "Applied work"];
  }

  if (domainKey === DomainKey.Fitness) {
    return ["Sessions", "Setup", "Tracking"];
  }

  if (domainKey === DomainKey.Finance || domainKey === DomainKey.Credit) {
    return ["Review", "Action steps", "Follow-through"];
  }

  if (/\brelease|launch|publish|ship\b/.test(lower)) {
    return ["Production", "Review", "Delivery"];
  }

  return ["Setup", "Focused work", "Review"];
}

function inferMilestoneStructure(domainKey: DomainKey, lower: string) {
  if (/\bsong|songs|music|album\b/.test(lower)) {
    return ["Drafts", "Finishing", "Release"];
  }

  if (domainKey === DomainKey.Career) {
    return ["Baseline", "Strong-fit targets", "Submission rhythm"];
  }

  if (domainKey === DomainKey.SkillBuilding) {
    return ["Foundation", "Deliberate practice", "Applied proof"];
  }

  if (domainKey === DomainKey.Fitness) {
    return ["Baseline", "Consistency block", "Measured checkpoint"];
  }

  if (domainKey === DomainKey.Finance || domainKey === DomainKey.Credit) {
    return ["Current baseline", "First reduction", "Stability check"];
  }

  if (/\brelease|launch|publish|ship\b/.test(lower)) {
    return ["Preparation", "Build", "Release"];
  }

  return ["Baseline", "Build-up", "Finish line"];
}

function workloadShape(
  classification: ReturnType<typeof classifyGoal>,
  targetDate: string | null,
  today: string,
) {
  const daysUntilTarget =
    targetDate === null
      ? 45
      : Math.max(
          1,
          Math.ceil(
            (Date.parse(`${targetDate}T12:00:00.000Z`) - Date.parse(`${today}T12:00:00.000Z`)) /
              86400000,
          ),
        );

  if (classification.complexity === "high" || daysUntilTarget <= 28) {
    return { label: "Heavier lift", workload: "High effort with narrow slack" };
  }

  if (classification.complexity === "moderate" || daysUntilTarget <= 70) {
    return { label: "Steady build", workload: "Moderate effort across a few checkpoints" };
  }

  return { label: "Manageable build", workload: "Lighter ongoing effort with room to adjust" };
}

function buildInterpretation(params: {
  domainKey: DomainKey;
  type: GoalType;
  lower: string;
  classification: ReturnType<typeof classifyGoal>;
  targetDate: string | null;
  today: string;
}): GoalInterpretation {
  const work = workloadShape(params.classification, params.targetDate, params.today);

  return {
    domainLabel: params.domainKey.replaceAll("_", " "),
    categoryLabel: params.type.replaceAll("_", " "),
    workPattern: inferWorkPattern(params.domainKey, params.type, params.lower),
    timingLabel: params.targetDate ? `Target ${params.targetDate}` : "Timing still flexible",
    workloadShape: work.workload,
    workloadLabel: work.label,
    earlyMilestoneStructure: inferMilestoneStructure(params.domainKey, params.lower),
    earlyTaskCategories: inferTaskCategories(params.domainKey, params.lower),
  };
}

export function inferGoalDraft(naturalLanguage: string, today: string): GoalDraftInference {
  const normalized = naturalLanguage.trim();
  const lower = normalized.toLowerCase();
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
  const desiredWeeklyMinutes = inferWeeklyMinutes(
    domainKey,
    typeMap[classification.kind],
    normalized,
    targetDate,
    today,
  );
  const estimatedTotalMinutes =
    classification.timeframe === "long"
      ? desiredWeeklyMinutes * 16
      : classification.timeframe === "medium"
        ? desiredWeeklyMinutes * 8
        : desiredWeeklyMinutes * 4;
  const interpretation = buildInterpretation({
    domainKey,
    type: typeMap[classification.kind],
    lower,
    classification,
    targetDate,
    today,
  });

  return {
    ambitionId: null,
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
    paceMode: "balanced" as GoalPaceMode,
    interpretation,
  };
}
