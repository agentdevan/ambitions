import {
  AdaptationProfile,
  DailyPlan,
  DomainKey,
  EntitySyncState,
  Goal,
  GoalHorizon,
  GoalMilestone,
  GoalStatus,
  GoalType,
  ReplanSuggestion,
  ScheduleConstraint,
  Task,
  TaskSchedulingState,
  TaskStatus,
  TimeBlock,
  UserPreferences,
} from "../domain/models";
import { appServices } from "../bootstrap/runtime/appServices";
import {
  GoalDraftInference,
  GoalFeasibilityStatus,
  GoalPaceMode,
  GoalPaceOptionSummary,
  GoalStrategyComposer,
  ProductPreferences,
} from "./types";
import { mergeProductPreferences } from "./preferences";
import {
  buildGoalIntelligenceSnapshot,
  setGoalIntelligenceSnapshot,
} from "../services/goals/goalIntelligence";

function createId(prefix: string) {
  return `${prefix}-${Math.random().toString(36).slice(2, 10)}`;
}

function nowIso() {
  return new Date().toISOString();
}

function bindToAccount<
  T extends { ownerUserId: string | null; remoteId: string | null; syncState: string },
>(record: T, accountId: string | null) {
  if (!accountId) {
    return record;
  }

  return {
    ...record,
    ownerUserId: accountId,
    syncState: EntitySyncState.PendingSync,
  };
}

const paceModes: GoalPaceMode[] = ["conservative", "balanced", "aggressive"];

const recommendationTieBreak: Record<GoalPaceMode, number> = {
  balanced: 0,
  conservative: 1,
  aggressive: 2,
};

function formatHours(minutes: number) {
  const hours = minutes / 60;
  const rounded = hours >= 10 ? Math.round(hours) : Math.round(hours * 10) / 10;
  return `${rounded} hr/week`;
}

function clamp(value: number, min: number, max: number) {
  return Math.min(max, Math.max(min, value));
}

function daysUntil(date: string, targetDate: string | null) {
  if (!targetDate) {
    return 56;
  }

  return Math.max(
    1,
    Math.ceil(
      (Date.parse(`${targetDate}T12:00:00.000Z`) - Date.parse(`${date}T12:00:00.000Z`)) / 86400000,
    ),
  );
}

function weeksUntil(date: string, targetDate: string | null) {
  return Math.max(1, Math.ceil(daysUntil(date, targetDate) / 7));
}

function addDays(date: string, amount: number) {
  return new Date(Date.parse(`${date}T12:00:00.000Z`) + amount * 86400000)
    .toISOString()
    .slice(0, 10);
}

function describeConsistencyProfile(adaptationProfile: AdaptationProfile | null) {
  if (adaptationProfile?.regression.isRegressing) {
    return "Recent follow-through has been uneven, so the model protects against overpromising.";
  }

  const consistency = adaptationProfile?.completion.consistencyScore ?? 0.5;
  if (consistency >= 0.72) {
    return "Recent execution supports leaning on believable capacity instead of best-case energy.";
  }

  if (consistency >= 0.5) {
    return "Recent execution is mixed, so the capacity read keeps some guardrails in place.";
  }

  return "Recent execution has been stop-start, so the model treats consistency as a real constraint.";
}

function getConstraintMinutes(constraint: ScheduleConstraint) {
  const start = Date.parse(constraint.startsAt);
  const end = Date.parse(constraint.endsAt);
  return Math.max(0, Math.round((end - start) / 60000));
}

function buildWeeklyCapacityEstimate(params: {
  today: string;
  targetDate: string | null;
  productPreferences: ProductPreferences;
  goals: Goal[];
  scheduleConstraints: ScheduleConstraint[];
  adaptationProfile: AdaptationProfile | null;
}) {
  const daysRemaining = daysUntil(params.today, params.targetDate);
  const horizonWeeks = Math.max(1, daysRemaining / 7);
  const visibleWindowDays = Math.max(
    7,
    Math.min(daysRemaining, Math.max(7, params.scheduleConstraints.length > 0 ? 14 : 7)),
  );
  const visibleWeeks = Math.max(1, visibleWindowDays / 7);
  const workdayCount = params.productPreferences.schedule.workdays.length;
  const baseDailyTarget =
    params.adaptationProfile?.planningDirectives.dailyPlannedMinutesTarget ??
    params.adaptationProfile?.capacity.focusBudgetMinutes ??
    90;
  const consistencyScore = params.adaptationProfile?.completion.consistencyScore ?? 0.5;
  const readinessScore = params.adaptationProfile?.strategy.balancedReadiness ?? 0.3;
  const regressionPenalty = params.adaptationProfile?.regression.isRegressing ? 0.12 : 0;
  const behaviorMultiplier = clamp(
    0.72 + consistencyScore * 0.3 + readinessScore * 0.12 - regressionPenalty,
    0.55,
    1.12,
  );
  const visibleCommitmentMinutes = params.scheduleConstraints.reduce(
    (sum, constraint) => sum + getConstraintMinutes(constraint),
    0,
  );
  const visibleWeeklyCommitmentMinutes = Math.round(visibleCommitmentMinutes / visibleWeeks);
  const activeGoalLoadMinutes = params.goals
    .filter((goal) => goal.status === GoalStatus.Active)
    .reduce((sum, goal) => sum + (goal.desiredWeeklyMinutes ?? 0), 0);
  const nearDeadlinePenalty = daysRemaining <= 10 ? 0.18 : daysRemaining <= 21 ? 0.08 : 0;
  const longHorizonPenalty = daysRemaining >= 140 ? 0.1 : daysRemaining >= 84 ? 0.05 : 0;
  const weeklyCapacityMinutes = Math.max(
    90,
    Math.round(
      baseDailyTarget * workdayCount * behaviorMultiplier -
        visibleWeeklyCommitmentMinutes * 0.45 -
        activeGoalLoadMinutes * 0.35 -
        baseDailyTarget * workdayCount * (nearDeadlinePenalty + longHorizonPenalty),
    ),
  );
  const totalCapacityMinutes = Math.round(
    weeklyCapacityMinutes *
      horizonWeeks *
      clamp(daysRemaining <= 21 ? 0.9 : daysRemaining >= 140 ? 0.88 : 0.95, 0.82, 1),
  );

  return {
    daysRemaining,
    visibleWindowDays,
    visibleCommitmentMinutes,
    visibleWeeklyCommitmentMinutes,
    activeGoalLoadMinutes,
    consistencyScore,
    readinessScore,
    weeklyCapacityMinutes,
    totalCapacityMinutes,
    availableCapacitySummary: `About ${formatHours(weeklyCapacityMinutes)} looks believable after visible commitments and active goals.`,
    commitmentsSummary:
      visibleCommitmentMinutes > 0
        ? `${Math.round(visibleWeeklyCommitmentMinutes / 60)} hr/week of visible fixed commitments and ${Math.round(activeGoalLoadMinutes / 60)} hr/week of active-goal load are already spoken for.`
        : `${Math.round(activeGoalLoadMinutes / 60)} hr/week is already committed to active goals before this one is added.`,
    behaviorSummary: describeConsistencyProfile(params.adaptationProfile),
  };
}

function workloadEstimateForGoal(goal: Goal, tasks: Task[], milestones: GoalMilestone[], today: string) {
  const taskMinutes = tasks.reduce((sum, task) => sum + task.estimatedMinutes, 0);
  const milestoneMinutes = milestones.reduce((sum, milestone) => sum + (milestone.estimatedMinutes ?? 0), 0);
  const deadlineWeeks = weeksUntil(today, goal.targetDate);
  const inferredBaseline =
    goal.estimatedTotalMinutes ?? Math.max(goal.desiredWeeklyMinutes ?? 0, taskMinutes);

  return Math.max(
    inferredBaseline,
    taskMinutes + milestoneMinutes,
    Math.round((goal.desiredWeeklyMinutes ?? 90) * Math.min(6, deadlineWeeks)),
  );
}

function paceConfig(mode: GoalPaceMode, adaptationProfile: AdaptationProfile | null) {
  const aggressiveReliability = clamp(
    0.84 + (adaptationProfile?.strategy.balancedReadiness ?? 0.3) * 0.08,
    0.84,
    0.92,
  );

  switch (mode) {
    case "conservative":
      return {
        label: "Conservative",
        plannedDemandMultiplier: 0.84,
        requiredWeeklyBias: 0.82,
        sustainableCapacityShare: 0.72,
        reliabilityMultiplier: 0.97,
        scopeOverheadMultiplier: 1.04,
        targetBufferWeeks: 1.4,
        sessionMinutes: 20,
        taskSizing: "Smaller steps",
        riskLevel: "Lower pressure",
        adaptationBehavior: "Cuts volume earlier and protects recovery before the week gets noisy.",
      };
    case "aggressive":
      return {
        label: "Aggressive",
        plannedDemandMultiplier: 1.24,
        requiredWeeklyBias: 1.16,
        sustainableCapacityShare: 0.98,
        reliabilityMultiplier: aggressiveReliability,
        scopeOverheadMultiplier: 1.03,
        targetBufferWeeks: 0.25,
        sessionMinutes: 50,
        taskSizing: "Longer pushes",
        riskLevel: "Higher pressure",
        adaptationBehavior: "Front-loads bigger sessions and only eases back after consistency drops.",
      };
    default:
      return {
        label: "Balanced",
        plannedDemandMultiplier: 1,
        requiredWeeklyBias: 1,
        sustainableCapacityShare: 0.84,
        reliabilityMultiplier: 0.92,
        scopeOverheadMultiplier: 1,
        targetBufferWeeks: 0.8,
        sessionMinutes: 35,
        taskSizing: "Mixed session sizes",
        riskLevel: "Moderate pressure",
        adaptationBehavior: "Trades some slack for steady movement, then trims back when drift starts.",
      };
  }
}

function joinLabels(labels: string[]) {
  if (labels.length <= 1) {
    return labels[0] ?? "";
  }

  if (labels.length === 2) {
    return `${labels[0]} and ${labels[1]}`;
  }

  return `${labels.slice(0, -1).join(", ")}, and ${labels.at(-1)}`;
}

function lighterScopeSuggestion(
  goal: Goal,
  milestones: GoalMilestone[],
  tasks: Task[],
  paceMode: GoalPaceMode,
) {
  if (goal.domainKey === DomainKey.Career) {
    return paceMode === "aggressive"
      ? "A calmer fallback is to keep the strongest-fit roles and delay the broader search spread."
      : "A lighter version is to focus the first pass on your strongest-fit roles instead of the full search spread.";
  }

  if (goal.domainKey === DomainKey.Fitness) {
    return paceMode === "conservative"
      ? "Keep the consistency block and let intensity wait until the routine feels stable."
      : "A lighter version is to protect the consistency block first, then add intensity later.";
  }

  if (goal.domainKey === DomainKey.Finance || goal.domainKey === DomainKey.Credit) {
    return "A lighter version is to keep the baseline and first reduction step, then delay the rest of the cleanup.";
  }

  const keptMilestones = milestones.slice(0, Math.max(1, Math.min(2, milestones.length - 1)));
  const delayedMilestone = milestones.at(-1);
  if (keptMilestones.length > 0 && delayedMilestone && delayedMilestone.id !== keptMilestones.at(-1)?.id) {
    return `A lighter version is to hold ${joinLabels(keptMilestones.map((milestone) => milestone.title.toLowerCase()))} first, and move ${delayedMilestone.title.toLowerCase()} into the next cycle.`;
  }

  const trimmedTasks = Math.max(3, Math.round(tasks.length * 0.7));
  return `A lighter version is to keep the first pass to about ${trimmedTasks} tasks and leave the rest for later.`;
}

function buildNoDeadlineTruth(params: {
  paceMode: GoalPaceMode;
  plannedWeeklyMinutes: number;
  sustainableWeeklyMinutes: number;
  visibleWeeklyCommitmentMinutes: number;
}) {
  const summaryByMode: Record<GoalPaceMode, string> = {
    conservative: "Conservative pacing keeps this goal steady while the target date stays flexible.",
    balanced: "Balanced pacing can move this goal forward without forcing the timeline yet.",
    aggressive: "Aggressive pacing can accelerate this goal, but the timeline is still yours to set.",
  };
  const detail = `Without a target date, this pace asks for about ${formatHours(params.plannedWeeklyMinutes)} against ${formatHours(params.sustainableWeeklyMinutes)} of believable room once visible commitments are accounted for.`;

  return {
    status: (params.plannedWeeklyMinutes <= params.sustainableWeeklyMinutes ? "feasible" : "tight") as GoalFeasibilityStatus,
    summary: summaryByMode[params.paceMode],
    detail,
    deadlineConfidence: "Flexible date",
    revisedDeadlineSuggestion: null,
    revisedDeadlineReason: null,
  };
}

function buildFeasibilityCopy(params: {
  paceMode: GoalPaceMode;
  status: GoalFeasibilityStatus;
  plannedWeeklyMinutes: number;
  sustainableWeeklyMinutes: number;
  daysRemaining: number;
  visibleWeeklyCommitmentMinutes: number;
  activeGoalLoadMinutes: number;
}) {
  const summaryByMode: Record<GoalPaceMode, Record<GoalFeasibilityStatus, string>> = {
    conservative: {
      feasible: "Conservative pacing keeps this date believable with room to recover.",
      tight: "Conservative pacing lowers pressure, but the current date is getting harder to hold.",
      unrealistic: "Conservative pacing makes the current date unlikely to hold.",
    },
    balanced: {
      feasible: "Balanced pacing keeps this date believable.",
      tight: "Still possible at this pace, but the buffer is getting thin.",
      unrealistic: "This deadline is unlikely to hold at a balanced pace.",
    },
    aggressive: {
      feasible: "Aggressive pacing can still hold this date if your follow-through stays steady.",
      tight: "Aggressive pacing can still protect the date, but it leaves little room for drift.",
      unrealistic: "Even aggressive pacing does not make this date believable yet.",
    },
  };
  const commitmentHours = Math.round(params.visibleWeeklyCommitmentMinutes / 60);
  const goalLoadHours = Math.round(params.activeGoalLoadMinutes / 60);
  const detail =
    params.status === "feasible"
      ? `With ${params.daysRemaining} days left, this pace asks for about ${formatHours(params.plannedWeeklyMinutes)} against ${formatHours(params.sustainableWeeklyMinutes)} of believable room. Visible commitments already take about ${commitmentHours} hr/week, and other active goals take about ${goalLoadHours} hr/week.`
      : params.status === "tight"
        ? `With ${params.daysRemaining} days left, this pace is asking for about ${formatHours(params.plannedWeeklyMinutes)} against ${formatHours(params.sustainableWeeklyMinutes)} of believable room. Visible commitments already take about ${commitmentHours} hr/week, so there is not much slack.`
        : `With ${params.daysRemaining} days left, this pace is asking for about ${formatHours(params.plannedWeeklyMinutes)} against ${formatHours(params.sustainableWeeklyMinutes)} of believable room. Visible commitments and active-goal load are already using roughly ${commitmentHours + goalLoadHours} hr/week before this goal fully fits.`;

  return {
    summary: summaryByMode[params.paceMode][params.status],
    detail,
  };
}

function deadlineConfidenceLabel(mode: GoalPaceMode, status: GoalFeasibilityStatus) {
  if (status === "unrealistic") {
    return "Low confidence";
  }

  if (status === "tight") {
    if (mode === "conservative") {
      return "Date needs more room";
    }

    if (mode === "aggressive") {
      return "Holding, but exposed";
    }

    return "Lower buffer";
  }

  if (mode === "conservative") {
    return "Believable with room";
  }

  if (mode === "aggressive") {
    return "Believable if steady";
  }

  return "Believable";
}

function revisedDeadlineReason(mode: GoalPaceMode) {
  if (mode === "conservative") {
    return "A later target would make the calmer pace believable.";
  }

  if (mode === "aggressive") {
    return "Even with a heavier pace, a later target would make the deadline credible.";
  }

  return "A later target would be more believable.";
}

function buildHighestLeverageStep(params: {
  goal: Goal;
  tasks: Task[];
  paceMode: GoalPaceMode;
  revisedDeadlineSuggestion: string | null;
}) {
  if (params.tasks[0]?.title) {
    return `Protect the next step: ${params.tasks[0].title}.`;
  }

  if (params.revisedDeadlineSuggestion) {
    return params.paceMode === "conservative"
      ? `Protect the first milestone and consider moving the target to ${params.revisedDeadlineSuggestion}.`
      : `Protect the first milestone before deciding whether to move the target to ${params.revisedDeadlineSuggestion}.`;
  }

  return "Protect the first milestone before adding more scope.";
}

function buildFeasibilityTruth(params: {
  goal: Goal;
  tasks: Task[];
  milestones: GoalMilestone[];
  today: string;
  paceMode: GoalPaceMode;
  capacity: ReturnType<typeof buildWeeklyCapacityEstimate>;
  adaptationProfile: AdaptationProfile | null;
}) {
  const baseWorkEstimateMinutes = workloadEstimateForGoal(
    params.goal,
    params.tasks,
    params.milestones,
    params.today,
  );
  const config = paceConfig(params.paceMode, params.adaptationProfile);
  const totalWorkEstimateMinutes = Math.round(
    baseWorkEstimateMinutes * config.scopeOverheadMultiplier,
  );
  const deadlineWeeks = Math.max(1, params.capacity.daysRemaining / 7);
  const baselineWeeklyMinutes = Math.max(
    60,
    params.goal.desiredWeeklyMinutes ?? Math.round(totalWorkEstimateMinutes / Math.max(4, Math.min(10, deadlineWeeks))),
  );
  const requiredWeeklyMinutes = Math.max(
    60,
    Math.ceil(totalWorkEstimateMinutes / deadlineWeeks),
  );
  const plannedWeeklyMinutes = Math.round(
    Math.max(
      baselineWeeklyMinutes * config.plannedDemandMultiplier,
      requiredWeeklyMinutes * config.requiredWeeklyBias,
    ),
  );
  const sustainableWeeklyMinutes = Math.round(
    params.capacity.weeklyCapacityMinutes * config.sustainableCapacityShare,
  );
  const overloadRatio = plannedWeeklyMinutes / Math.max(60, sustainableWeeklyMinutes);
  const overloadPenalty =
    overloadRatio <= 1 ? 1 : 1 / (1 + (overloadRatio - 1) * 0.55);
  const urgencyPenalty =
    params.capacity.daysRemaining <= 10 ? 0.86 : params.capacity.daysRemaining <= 21 ? 0.93 : 1;
  const horizonPenalty =
    params.capacity.daysRemaining >= 140 ? 0.91 : params.capacity.daysRemaining >= 84 ? 0.96 : 1;
  const effectiveWeeklyProgress = Math.round(
    Math.max(
      60,
      Math.min(plannedWeeklyMinutes, sustainableWeeklyMinutes) *
        config.reliabilityMultiplier *
        overloadPenalty *
        urgencyPenalty *
        horizonPenalty,
    ),
  );
  const projectedWeeks = totalWorkEstimateMinutes / Math.max(60, effectiveWeeklyProgress);
  const projectedBufferWeeks = deadlineWeeks - projectedWeeks;
  const projectedFinishDate =
    params.goal.targetDate === null ? null : addDays(params.today, Math.ceil(projectedWeeks * 7));

  if (params.goal.targetDate === null) {
    const noDeadlineTruth = buildNoDeadlineTruth({
      paceMode: params.paceMode,
      plannedWeeklyMinutes,
      sustainableWeeklyMinutes,
      visibleWeeklyCommitmentMinutes: params.capacity.visibleWeeklyCommitmentMinutes,
    });

    return {
      totalWorkEstimateMinutes,
      projectedBufferWeeks: 0,
      projectedFinishDate,
      loadRatio: overloadRatio,
      truth: {
        status: noDeadlineTruth.status,
        summary: noDeadlineTruth.summary,
        detail: noDeadlineTruth.detail,
        deadlineConfidence: noDeadlineTruth.deadlineConfidence,
        weeklyDemandMinutes: plannedWeeklyMinutes,
        weeklyCapacityMinutes: sustainableWeeklyMinutes,
        totalCapacityMinutes: params.capacity.totalCapacityMinutes,
        revisedDeadlineSuggestion: noDeadlineTruth.revisedDeadlineSuggestion,
        revisedDeadlineReason: noDeadlineTruth.revisedDeadlineReason,
        lighterScopeSuggestion: null,
        pacingTradeoff:
          params.paceMode === "conservative"
            ? "Conservative pacing keeps the week lighter and protects recovery first."
            : params.paceMode === "aggressive"
              ? "Aggressive pacing asks for bigger sessions now so the goal moves sooner."
              : "Balanced pacing keeps the work moving without forcing a hard date yet.",
        highestLeverageStep: buildHighestLeverageStep({
          goal: params.goal,
          tasks: params.tasks,
          paceMode: params.paceMode,
          revisedDeadlineSuggestion: null,
        }),
      },
    };
  }

  const status: GoalFeasibilityStatus =
    projectedBufferWeeks >= config.targetBufferWeeks && overloadRatio <= 1.04
      ? "feasible"
      : projectedBufferWeeks >= -0.4 && overloadRatio <= 1.18
        ? "tight"
        : "unrealistic";
  const suggestedWeeks = Math.max(
    Math.ceil(projectedWeeks + config.targetBufferWeeks),
    Math.ceil(deadlineWeeks) + 1,
  );
  const revisedDeadlineSuggestion =
    status === "unrealistic" ? addDays(params.today, suggestedWeeks * 7) : null;
  const copy = buildFeasibilityCopy({
    paceMode: params.paceMode,
    status,
    plannedWeeklyMinutes,
    sustainableWeeklyMinutes,
    daysRemaining: params.capacity.daysRemaining,
    visibleWeeklyCommitmentMinutes: params.capacity.visibleWeeklyCommitmentMinutes,
    activeGoalLoadMinutes: params.capacity.activeGoalLoadMinutes,
  });

  return {
    totalWorkEstimateMinutes,
    projectedBufferWeeks,
    projectedFinishDate,
    loadRatio: overloadRatio,
    truth: {
      status,
      summary: copy.summary,
      detail: copy.detail,
      deadlineConfidence: deadlineConfidenceLabel(params.paceMode, status),
      weeklyDemandMinutes: plannedWeeklyMinutes,
      weeklyCapacityMinutes: sustainableWeeklyMinutes,
      totalCapacityMinutes: params.capacity.totalCapacityMinutes,
      revisedDeadlineSuggestion,
      revisedDeadlineReason:
        revisedDeadlineSuggestion !== null ? revisedDeadlineReason(params.paceMode) : null,
      lighterScopeSuggestion:
        status === "unrealistic"
          ? lighterScopeSuggestion(params.goal, params.milestones, params.tasks, params.paceMode)
          : null,
      pacingTradeoff:
        params.paceMode === "conservative"
          ? "Conservative pacing lowers weekly pressure, but it gives up deadline protection sooner."
          : params.paceMode === "aggressive"
            ? "Aggressive pacing protects the date longer, but it asks for stronger consistency and larger pushes."
            : "Balanced pacing keeps the workload honest without leaning on perfect consistency.",
      highestLeverageStep: buildHighestLeverageStep({
        goal: params.goal,
        tasks: params.tasks,
        paceMode: params.paceMode,
        revisedDeadlineSuggestion,
      }),
    },
  };
}

function chooseRecommendedPace(
  drafts: Array<{
    paceOption: GoalPaceOptionSummary;
    feasibility: {
      status: GoalFeasibilityStatus;
      projectedBufferWeeks: number;
      loadRatio: number;
    };
  }>,
  adaptationProfile: AdaptationProfile | null,
  today: string,
  targetDate: string | null,
) {
  const daysRemaining = targetDate ? daysUntil(today, targetDate) : null;
  const ranked = drafts
    .map((draft) => {
      const baseScore =
        draft.feasibility.status === "feasible"
          ? 6
          : draft.feasibility.status === "tight"
            ? 3
            : -2;
      let score =
        baseScore +
        clamp(draft.feasibility.projectedBufferWeeks, -2, 2) -
        Math.max(0, draft.feasibility.loadRatio - 1) * 4;

      if (adaptationProfile?.regression.isRegressing) {
        score +=
          draft.paceOption.mode === "conservative"
            ? 2
            : draft.paceOption.mode === "balanced"
              ? 1
              : -2;
      }

      if ((adaptationProfile?.strategy.balancedReadiness ?? 0.3) >= 0.7) {
        score += draft.paceOption.mode === "aggressive" ? 1.2 : 0;
      }

      if (daysRemaining !== null && daysRemaining <= 21) {
        score += draft.paceOption.mode === "aggressive" ? 1.3 : draft.paceOption.mode === "conservative" ? -1 : 0.6;
      }

      if (daysRemaining !== null && daysRemaining >= 84) {
        score += draft.paceOption.mode === "conservative" ? 1 : draft.paceOption.mode === "balanced" ? 0.5 : -0.4;
      }

      if (draft.feasibility.status === "feasible" && draft.paceOption.mode === "balanced") {
        score += 0.75;
      }

      return {
        mode: draft.paceOption.mode,
        score,
      };
    })
    .sort((left, right) => {
      if (right.score !== left.score) {
        return right.score - left.score;
      }

      return recommendationTieBreak[left.mode] - recommendationTieBreak[right.mode];
    });

  return ranked[0]?.mode ?? "balanced";
}

function createGoalRecord(inference: GoalDraftInference, focusDomains: DomainKey[], today: string): Goal {
  const timestamp = nowIso();

  return {
    id: createId("goal"),
    ownerUserId: null,
    remoteId: null,
    syncState: EntitySyncState.LocalOnly,
    version: 1,
    lastSyncedAt: null,
    createdAt: timestamp,
    updatedAt: timestamp,
    ambitionId: inference.ambitionId,
    title: inference.title,
    summary: inference.summary,
    domainKey: inference.domainKey,
    horizon: inference.horizon as GoalHorizon,
    type: inference.type as GoalType,
    status: GoalStatus.Active,
    parentGoalId: null,
    sortOrder: 1,
    startDate: today,
    targetDate: inference.targetDate,
    desiredWeeklyMinutes: inference.desiredWeeklyMinutes,
    estimatedTotalMinutes: inference.estimatedTotalMinutes,
    successMetric: inference.successMetric,
    notes: inference.notes,
    tags: Array.from(new Set([inference.domainKey, ...focusDomains])),
    metadata: {
      intakeSource: "phase22_goal_strategy_composer",
      naturalLanguage: inference.naturalLanguage,
      phase22SelectedPaceMode: inference.paceMode,
    },
  };
}

function adjustMilestones(
  goal: Goal,
  milestones: GoalMilestone[],
  today: string,
) {
  return milestones.map((milestone, index) => ({
    ...milestone,
    goalId: goal.id,
    id: `${goal.id}-milestone-${index + 1}`,
    targetDate:
      index === 0
        ? today
        : milestone.targetDate ?? new Date(Date.parse(`${today}T12:00:00.000Z`) + index * 7 * 86400000)
            .toISOString()
            .slice(0, 10),
    updatedAt: nowIso(),
  }));
}

function adjustTasks(
  goal: Goal,
  milestones: GoalMilestone[],
  tasks: Task[],
  today: string,
) {
  const milestoneById = new Map(milestones.map((milestone) => [milestone.id, milestone]));

  return tasks.map((task, index) => {
    const milestone = task.milestoneId ? milestoneById.get(task.milestoneId) : null;
    const targetDate = index < 3 ? today : milestone?.targetDate ?? goal.targetDate ?? today;

    return {
      ...task,
      id: `${task.id}-${goal.id}`,
      goalId: goal.id,
      milestoneId: milestone?.id ?? task.milestoneId,
      targetDate,
      scheduledDate: null,
      earliestStartAt: null,
      latestFinishAt: null,
      status: TaskStatus.Ready,
      schedulingState: TaskSchedulingState.Unscheduled,
      updatedAt: nowIso(),
      metadata: {
        ...task.metadata,
        generatedForFirstPlan: index < 3,
      },
    };
  });
}

function assignScheduledTaskState(tasks: Task[], blocks: TimeBlock[], today: string) {
  const blocksByTaskId = new Map(
    blocks.filter((block) => block.taskId).map((block) => [block.taskId as string, block]),
  );

  return tasks.map((task) => {
    const block = blocksByTaskId.get(task.id);
    if (!block) {
      return {
        ...task,
        status: task.targetDate === today ? TaskStatus.Unscheduled : task.status,
        schedulingState:
          task.targetDate === today ? TaskSchedulingState.Unscheduled : task.schedulingState,
      };
    }

    return {
      ...task,
      status: TaskStatus.Scheduled,
      schedulingState: TaskSchedulingState.Committed,
      scheduledDate: today,
      earliestStartAt: block.startsAtDateTime,
      latestFinishAt: block.endsAtDateTime,
    };
  });
}

export interface FirstPlanResult {
  goal: Goal;
  milestones: GoalMilestone[];
  tasks: Task[];
  dailyPlan: DailyPlan;
  timeBlocks: TimeBlock[];
  suggestions: ReplanSuggestion[];
}

export interface GoalArtifactDraft {
  goal: Goal;
  milestones: GoalMilestone[];
  tasks: Task[];
}

async function buildArtifactDraft(params: {
  inference: GoalDraftInference;
  mergedPreferences: UserPreferences;
  focusDomains: DomainKey[];
  today: string;
  adaptationProfile: AdaptationProfile | null;
}) {
  const goal = createGoalRecord(params.inference, params.focusDomains, params.today);
  const decomposition = await appServices.engines.decomposition.decompose({
    goal,
    milestones: [],
    existingTasks: [],
    preferences: params.mergedPreferences,
    adaptationProfile: params.adaptationProfile,
    referenceDate: params.today,
  });
  const milestones = adjustMilestones(goal, decomposition.payload.milestones, params.today);
  const tasks = adjustTasks(goal, milestones, decomposition.payload.tasks, params.today);

  return {
    goal,
    milestones,
    tasks,
  } satisfies GoalArtifactDraft;
}

async function buildGoalStrategyComposer(params: {
  inference: GoalDraftInference;
  productPreferences: ProductPreferences;
  mergedPreferences: UserPreferences;
  goals: Goal[];
  today: string;
  adaptationProfile: AdaptationProfile | null;
}) {
  const visibleConstraintDays = Array.from(
    { length: Math.max(7, Math.min(daysUntil(params.today, params.inference.targetDate), 14)) },
    (_, index) => addDays(params.today, index),
  );
  const scheduleConstraints = (
    await Promise.all(
      visibleConstraintDays.map((date) =>
        appServices.repositories.integration.listScheduleConstraintsForDate(date),
      ),
    )
  )
    .flat()
    .filter(
      (constraint, index, list) =>
        list.findIndex((candidate) => candidate.id === constraint.id) === index,
    );
  const focusDomains =
    params.mergedPreferences.metadata.focusDomains
      ? String(params.mergedPreferences.metadata.focusDomains)
          .split(",")
          .filter((entry): entry is DomainKey => Object.values(DomainKey).includes(entry as DomainKey))
      : params.inference.focusDomains;
  const capacity = buildWeeklyCapacityEstimate({
    today: params.today,
    targetDate: params.inference.targetDate,
    productPreferences: params.productPreferences,
    goals: params.goals,
    scheduleConstraints,
    adaptationProfile: params.adaptationProfile,
  });
  const drafts = await Promise.all(
    paceModes.map(async (paceMode) => {
      const paceInference: GoalDraftInference = { ...params.inference, paceMode };
      const artifact = await buildArtifactDraft({
        inference: paceInference,
        mergedPreferences: params.mergedPreferences,
        focusDomains,
        today: params.today,
        adaptationProfile: params.adaptationProfile,
      });
      const feasibility = buildFeasibilityTruth({
        goal: artifact.goal,
        tasks: artifact.tasks,
        milestones: artifact.milestones,
        today: params.today,
        paceMode,
        capacity,
        adaptationProfile: params.adaptationProfile,
      });
      const config = paceConfig(paceMode, params.adaptationProfile);
      const paceOption: GoalPaceOptionSummary = {
        mode: paceMode,
        label: config.label,
        summary:
          paceMode === "conservative"
            ? "Lower weekly pressure, smaller steps, and earlier adaptation."
            : paceMode === "aggressive"
              ? "Higher weekly output that protects the date longer at higher risk."
              : "Steady weekly output with a cleaner balance between pace and realism.",
        weeklyHours: Math.max(1, Math.round(feasibility.truth.weeklyDemandMinutes / 60)),
        sessionCount: Math.max(
          2,
          Math.ceil(feasibility.truth.weeklyDemandMinutes / config.sessionMinutes),
        ),
        taskSizing: config.taskSizing,
        riskLevel: config.riskLevel,
        deadlineConfidence: feasibility.truth.deadlineConfidence,
        adaptationBehavior: config.adaptationBehavior,
        recommended: false,
      };

      return {
        ...artifact,
        feasibility: feasibility.truth,
        feasibilityMetrics: {
          status: feasibility.truth.status,
          projectedBufferWeeks: feasibility.projectedBufferWeeks,
          loadRatio: feasibility.loadRatio,
        },
        totalWorkEstimateMinutes: feasibility.totalWorkEstimateMinutes,
        paceOption,
      };
    }),
  );
  const recommendedPaceMode = chooseRecommendedPace(
    drafts.map((draft) => ({
      paceOption: draft.paceOption,
      feasibility: draft.feasibilityMetrics,
    })),
    params.adaptationProfile,
    params.today,
    params.inference.targetDate,
  );
  const selectedDraft =
    drafts.find((draft) => draft.paceOption.mode === params.inference.paceMode) ?? drafts[1];
  const paceOptions = drafts.map((draft) => ({
    ...draft.paceOption,
    recommended: draft.paceOption.mode === recommendedPaceMode,
  }));
  const composer: GoalStrategyComposer = {
    selectedPaceMode: selectedDraft.paceOption.mode,
    recommendedPaceMode,
    interpretation: params.inference.interpretation,
    availableCapacitySummary: capacity.availableCapacitySummary,
    commitmentsSummary: capacity.commitmentsSummary,
    behaviorSummary: capacity.behaviorSummary,
    workloadEstimateMinutes: selectedDraft.totalWorkEstimateMinutes,
    workloadEstimateLabel: `${Math.round(selectedDraft.totalWorkEstimateMinutes / 60)} hours of likely work`,
    paceOptions,
    feasibility: selectedDraft.feasibility,
    firstMilestonePath: selectedDraft.milestones.slice(0, 3).map((milestone) => ({
      title: milestone.title,
      summary: milestone.summary,
      targetDate: milestone.targetDate,
    })),
    firstWeekActionPreview: selectedDraft.tasks.slice(0, 4).map((task) => ({
      title: task.title,
      summary: task.summary,
      targetDate: task.targetDate,
      estimatedMinutes: task.estimatedMinutes,
    })),
  };
  const selectedGoal = {
    ...selectedDraft.goal,
    desiredWeeklyMinutes: selectedDraft.feasibility.weeklyDemandMinutes,
    estimatedTotalMinutes: selectedDraft.totalWorkEstimateMinutes,
    metadata: {
      ...selectedDraft.goal.metadata,
      phase22SelectedPaceMode: selectedDraft.paceOption.mode,
      phase22RecommendedPaceMode: recommendedPaceMode,
    },
  };

  return {
    composer,
    draft: {
      goal: setGoalIntelligenceSnapshot(
        selectedGoal,
        buildGoalIntelligenceSnapshot(composer),
      ),
      milestones: selectedDraft.milestones,
      tasks: selectedDraft.tasks,
    },
  };
}

export async function createGoalArtifacts(params: {
  inference: GoalDraftInference;
  productPreferences: ProductPreferences;
  currentPreferences: UserPreferences;
  today: string;
  adaptationProfile: AdaptationProfile | null;
}) {
  const mergedPreferences = mergeProductPreferences(params.currentPreferences, {
    ...params.productPreferences,
    onboardingCompleted: true,
    focusDomains:
      params.productPreferences.focusDomains.length > 0
        ? params.productPreferences.focusDomains
        : params.inference.focusDomains,
  });
  const existingGoals = await appServices.repositories.goals.listGoals();
  const strategy = await buildGoalStrategyComposer({
    inference: params.inference,
    productPreferences: params.productPreferences,
    mergedPreferences,
    goals: existingGoals,
    today: params.today,
    adaptationProfile: params.adaptationProfile,
  });

  return {
    goal: strategy.draft.goal,
    milestones: strategy.draft.milestones,
    tasks: strategy.draft.tasks,
    mergedPreferences,
    composer: strategy.composer,
  };
}

export async function createGoalAndFirstPlan(params: {
  inference: GoalDraftInference;
  productPreferences: ProductPreferences;
  currentPreferences: UserPreferences;
  today: string;
  adaptationProfile: AdaptationProfile | null;
  accountId?: string | null;
}) {
  const { goal, milestones, tasks, mergedPreferences, composer } = await createGoalArtifacts(params);
  const goals = await appServices.repositories.goals.listGoals();
  const existingMilestones = await appServices.repositories.goals.listMilestones();
  const calendarConnectionState =
    await appServices.repositories.integration.getCalendarConnectionState();
  const scheduleConstraints =
    await appServices.repositories.integration.listScheduleConstraintsForDate(params.today);
  const schedule = await appServices.engines.scheduling.buildSchedule({
    date: params.today,
    goals: [...goals, goal],
    milestones: [...existingMilestones, ...milestones],
    tasks: tasks.filter((task) => task.targetDate === params.today),
    constraints: scheduleConstraints,
    preferences: mergedPreferences,
    adaptationProfile: params.adaptationProfile,
    existingPlan: null,
  });
  const persistedTasks = assignScheduledTaskState(tasks, schedule.payload.timeBlocks, params.today);
  const suggestions =
    (
      await appServices.engines.replanning.suggestAdjustments({
        date: params.today,
        goals: [...goals, goal],
        milestones: [...existingMilestones, ...milestones],
        tasks: persistedTasks.filter((task) => task.targetDate === params.today),
        constraints: scheduleConstraints,
        preferences: mergedPreferences,
        adaptationProfile: params.adaptationProfile,
        dailyPlan: schedule.payload.dailyPlan,
        timeBlocks: schedule.payload.timeBlocks,
      })
    ).payload.suggestions ?? [];

  await appServices.repositories.preferences.saveUserPreferences(
    bindToAccount(mergedPreferences, params.accountId ?? null),
  );
  await appServices.repositories.goals.saveGoals([
    bindToAccount(goal, params.accountId ?? null),
    ...goals.map((entry, index) => ({ ...entry, sortOrder: index + 2 })),
  ]);
  await appServices.repositories.goals.saveMilestones(
    milestones.map((milestone) => bindToAccount(milestone, params.accountId ?? null)),
  );
  await appServices.repositories.tasks.saveTasks(
    persistedTasks.map((task) => bindToAccount(task, params.accountId ?? null)),
  );
  await appServices.repositories.planning.saveDailyPlans([
    bindToAccount(schedule.payload.dailyPlan, params.accountId ?? null),
  ]);
  await appServices.repositories.planning.saveTimeBlocks(
    schedule.payload.timeBlocks.map((block) => bindToAccount(block, params.accountId ?? null)),
  );
  await appServices.repositories.adaptation.replaceReplanSuggestions(params.today, suggestions);

  return {
    goal,
    milestones,
    tasks: persistedTasks,
    composer,
    dailyPlan: schedule.payload.dailyPlan,
    timeBlocks: schedule.payload.timeBlocks,
    suggestions,
    calendarConnectionState,
  };
}
