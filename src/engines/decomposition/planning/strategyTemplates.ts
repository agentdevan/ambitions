import { DomainKey, GoalHorizon } from "../../../domain/models";
import {
  GoalClassificationKind,
  GoalComplexity,
  GoalDraftInput,
  GoalPlanningAnalysis,
  PlanningMode,
  PlanningWorkType,
  StrategyKey,
} from "../../../domain/models/planningBrain";
import { clamp } from "./date";
import { StrategyTemplate } from "./types";

function cadenceCount(horizon: GoalHorizon, protective: boolean) {
  if (horizon === GoalHorizon.Yearly) {
    return protective ? 3 : 4;
  }

  if (horizon === GoalHorizon.Monthly) {
    return protective ? 2 : 3;
  }

  if (horizon === GoalHorizon.Weekly) {
    return protective ? 1 : 2;
  }

  return 1;
}

function buildPhases(
  labels: Array<{ key: string; title: string; summary: string; workTypes: PlanningWorkType[] }>,
  horizon: GoalHorizon,
  targetDate: string | null,
  startDate: string | null,
  protective: boolean,
) {
  const count = clamp(cadenceCount(horizon, protective), 1, labels.length);
  const selected = labels.slice(0, count);
  const anchor = startDate ?? new Date().toISOString().slice(0, 10);
  const totalDays = targetDate ? Math.max(7, Math.round((Date.parse(targetDate) - Date.parse(anchor)) / 86400000)) : 28;
  const step = Math.max(7, Math.round(totalDays / Math.max(1, count)));

  return selected.map((phase, index) => ({
    phaseKey: phase.key,
    title: phase.title,
    summary: phase.summary,
    workTypes: phase.workTypes,
    confidence: protective ? 0.72 : 0.82,
    targetOffsetDays: Math.min(totalDays, step * (index + 1)),
  }));
}

function createTemplate(
  key: StrategyKey,
  domainKey: DomainKey,
  label: string,
  keywords: string[],
  phases: Array<{ key: string; title: string; summary: string; workTypes: PlanningWorkType[] }>,
): StrategyTemplate {
  return {
    key,
    domainKey,
    label,
    keywords,
    buildMilestones(context) {
      const protective = context.analysis.policy.mode === PlanningMode.Protective;
      return buildPhases(
        phases,
        context.goal.horizon,
        context.goal.targetDate,
        context.goal.startDate,
        protective,
      );
    },
  };
}

export const strategyTemplates: StrategyTemplate[] = [
  createTemplate(
    StrategyKey.CreditUtilizationReduction,
    DomainKey.Credit,
    "Utilization reduction",
    ["utilization", "balance", "score", "card"],
    [
      {
        key: "audit",
        title: "Map current utilization and highest-pressure accounts",
        summary: "Identify where revolving balances are creating the biggest drag.",
        workTypes: [PlanningWorkType.Research, PlanningWorkType.Admin],
      },
      {
        key: "target",
        title: "Set a statement-date reduction plan",
        summary: "Choose the account and threshold that will move the score fastest.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.RoutineAction],
      },
      {
        key: "execute",
        title: "Reduce the worst utilization pockets",
        summary: "Apply extra payments and tighten spending around the highest-impact balance.",
        workTypes: [PlanningWorkType.RoutineAction, PlanningWorkType.Admin],
      },
    ],
  ),
  createTemplate(
    StrategyKey.CreditPaymentConsistency,
    DomainKey.Credit,
    "Payment consistency",
    ["payment", "autopay", "minimum", "late"],
    [
      {
        key: "stabilize",
        title: "Stabilize payment timing",
        summary: "Make late or missed payments materially less likely.",
        workTypes: [PlanningWorkType.Admin],
      },
      {
        key: "systemize",
        title: "Systemize recurring payment checks",
        summary: "Turn payment follow-through into a predictable weekly maintenance loop.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.RoutineAction],
      },
    ],
  ),
  createTemplate(
    StrategyKey.CreditCleanup,
    DomainKey.Credit,
    "Dispute and cleanup",
    ["dispute", "collections", "report", "error"],
    [
      {
        key: "review",
        title: "Review report issues and stale negatives",
        summary: "Pull the specific items worth disputing or correcting.",
        workTypes: [PlanningWorkType.Research, PlanningWorkType.Admin],
      },
      {
        key: "resolve",
        title: "Resolve the highest-impact report issues",
        summary: "Submit focused cleanup actions instead of chasing every small issue at once.",
        workTypes: [PlanningWorkType.Communication, PlanningWorkType.Admin],
      },
    ],
  ),
  createTemplate(
    StrategyKey.CreditMonitoring,
    DomainKey.Credit,
    "Score monitoring",
    ["monitor", "score", "track"],
    [
      {
        key: "baseline",
        title: "Create a score and utilization baseline",
        summary: "Track movement so the plan can react to real signal later.",
        workTypes: [PlanningWorkType.Research, PlanningWorkType.Admin],
      },
      {
        key: "review",
        title: "Review score movement without overreacting",
        summary: "Keep the monitoring habit light and diagnostic.",
        workTypes: [PlanningWorkType.Admin],
      },
    ],
  ),
  createTemplate(
    StrategyKey.FitnessConsistency,
    DomainKey.Fitness,
    "Consistency base",
    ["consistent", "routine", "habit", "show up"],
    [
      {
        key: "entry",
        title: "Lock a low-friction training entry point",
        summary: "Reduce startup friction before pushing intensity.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.RoutineAction],
      },
      {
        key: "cadence",
        title: "Hold a repeatable weekly movement cadence",
        summary: "Aim for repeatability before ambition.",
        workTypes: [PlanningWorkType.RoutineAction],
      },
      {
        key: "stability",
        title: "Stabilize the routine around recovery",
        summary: "Keep the streak alive without making the plan fragile.",
        workTypes: [PlanningWorkType.RoutineAction, PlanningWorkType.Admin],
      },
    ],
  ),
  createTemplate(
    StrategyKey.FitnessCaloricControl,
    DomainKey.Fitness,
    "Caloric control",
    ["calorie", "nutrition", "eat", "weight", "meal"],
    [
      {
        key: "observe",
        title: "Observe current intake and meal patterns",
        summary: "Find the easiest adjustment instead of forcing a perfect diet.",
        workTypes: [PlanningWorkType.Research, PlanningWorkType.Admin],
      },
      {
        key: "adjust",
        title: "Make one sustainable nutrition adjustment",
        summary: "Choose the smallest change likely to move the trend.",
        workTypes: [PlanningWorkType.RoutineAction, PlanningWorkType.Admin],
      },
    ],
  ),
  createTemplate(
    StrategyKey.FitnessTrainingFrequency,
    DomainKey.Fitness,
    "Training frequency",
    ["train", "lifting", "running", "conditioning", "workout"],
    [
      {
        key: "schedule",
        title: "Schedule realistic training slots",
        summary: "Use the week you actually have, not the week you wish you had.",
        workTypes: [PlanningWorkType.Admin],
      },
      {
        key: "repeat",
        title: "Repeat short sessions often enough to build momentum",
        summary: "Protect frequency with smaller sessions when certainty is low.",
        workTypes: [PlanningWorkType.RoutineAction],
      },
      {
        key: "progress",
        title: "Progress training volume gradually",
        summary: "Earn the right to add intensity after the cadence holds.",
        workTypes: [PlanningWorkType.DeepWork, PlanningWorkType.RoutineAction],
      },
    ],
  ),
  createTemplate(
    StrategyKey.FitnessRecoveryStructure,
    DomainKey.Fitness,
    "Recovery structure",
    ["recovery", "sleep", "rest", "mobility"],
    [
      {
        key: "protect",
        title: "Protect recovery inputs around training",
        summary: "Use sleep, mobility, and rest to keep the plan sustainable.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.RoutineAction],
      },
      {
        key: "review",
        title: "Review recovery signals weekly",
        summary: "Adjust volume before fatigue compounds.",
        workTypes: [PlanningWorkType.Admin],
      },
    ],
  ),
  createTemplate(
    StrategyKey.FinanceCashFlowClarity,
    DomainKey.Finance,
    "Cash-flow clarity",
    ["budget", "cash flow", "expense", "spending"],
    [
      {
        key: "audit",
        title: "Audit current inflows and outflows",
        summary: "Get a factual picture before changing behavior.",
        workTypes: [PlanningWorkType.Research, PlanningWorkType.Admin],
      },
      {
        key: "tighten",
        title: "Tighten the highest-leverage spending leaks",
        summary: "Shrink obvious friction rather than optimizing every category.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.RoutineAction],
      },
    ],
  ),
  createTemplate(
    StrategyKey.FinanceSavingsRate,
    DomainKey.Finance,
    "Savings rate",
    ["save", "savings", "emergency fund"],
    [
      {
        key: "baseline",
        title: "Set a realistic savings baseline",
        summary: "Choose a repeatable amount that can actually stick.",
        workTypes: [PlanningWorkType.Admin],
      },
      {
        key: "automate",
        title: "Automate the first savings move",
        summary: "Make the transfer easy before increasing the amount.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.RoutineAction],
      },
      {
        key: "ratchet",
        title: "Ratchet savings upward when the system holds",
        summary: "Increase slowly instead of creating a plan that snaps back.",
        workTypes: [PlanningWorkType.Admin],
      },
    ],
  ),
  createTemplate(
    StrategyKey.FinanceDebtPaydown,
    DomainKey.Finance,
    "Debt paydown",
    ["debt", "loan", "pay off"],
    [
      {
        key: "list",
        title: "List balances, rates, and minimums",
        summary: "Make the payoff plan concrete and comparable.",
        workTypes: [PlanningWorkType.Research, PlanningWorkType.Admin],
      },
      {
        key: "attack",
        title: "Attack one debt target consistently",
        summary: "Pick the debt sequence and make the next payment obvious.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.RoutineAction],
      },
    ],
  ),
  createTemplate(
    StrategyKey.CareerOutputBuilding,
    DomainKey.Career,
    "Output building",
    ["portfolio", "ship", "write", "case study", "project"],
    [
      {
        key: "scope",
        title: "Scope the smallest shippable professional output",
        summary: "Turn an abstract career push into a concrete artifact.",
        workTypes: [PlanningWorkType.DeepWork, PlanningWorkType.Admin],
      },
      {
        key: "produce",
        title: "Produce visible work in protected sessions",
        summary: "Build a repeatable output rhythm instead of waiting for a big block.",
        workTypes: [PlanningWorkType.DeepWork],
      },
      {
        key: "polish",
        title: "Polish and package the strongest output",
        summary: "Make the work legible enough to use in applications or networking.",
        workTypes: [PlanningWorkType.DeepWork, PlanningWorkType.Admin],
      },
    ],
  ),
  createTemplate(
    StrategyKey.CareerNetworking,
    DomainKey.Career,
    "Networking",
    ["network", "reach out", "coffee", "referral", "linkedin"],
    [
      {
        key: "list",
        title: "Build a short list of realistic outreach targets",
        summary: "Prioritize reachable contacts over broad, vague networking.",
        workTypes: [PlanningWorkType.Research, PlanningWorkType.Admin],
      },
      {
        key: "reach",
        title: "Send focused outreach with a clear ask",
        summary: "Keep outreach volume low enough to maintain quality.",
        workTypes: [PlanningWorkType.Communication],
      },
      {
        key: "follow",
        title: "Follow up and log warm conversations",
        summary: "Preserve continuity so outreach does not restart from zero.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.Communication],
      },
    ],
  ),
  createTemplate(
    StrategyKey.CareerApplications,
    DomainKey.Career,
    "Applications",
    ["apply", "application", "interview", "resume"],
    [
      {
        key: "target",
        title: "Target a narrow set of strong-fit roles",
        summary: "Reduce spray-and-pray behavior before increasing volume.",
        workTypes: [PlanningWorkType.Research, PlanningWorkType.Admin],
      },
      {
        key: "customize",
        title: "Customize application materials for the best roles",
        summary: "Use a smaller batch with higher quality and less drift.",
        workTypes: [PlanningWorkType.DeepWork, PlanningWorkType.Admin],
      },
      {
        key: "submit",
        title: "Submit applications and track follow-through",
        summary: "Close the loop cleanly instead of leaving partial applications everywhere.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.Communication],
      },
    ],
  ),
  createTemplate(
    StrategyKey.CareerSkillAcquisition,
    DomainKey.Career,
    "Career skill acquisition",
    ["learn", "skill", "course", "tool"],
    [
      {
        key: "focus",
        title: "Choose one career-relevant skill focus",
        summary: "Avoid splitting attention across too many learning tracks.",
        workTypes: [PlanningWorkType.Research, PlanningWorkType.Admin],
      },
      {
        key: "practice",
        title: "Practice the skill in short applied sessions",
        summary: "Build transfer, not just passive exposure.",
        workTypes: [PlanningWorkType.DeepWork, PlanningWorkType.RoutineAction],
      },
    ],
  ),
  createTemplate(
    StrategyKey.SkillCurriculum,
    DomainKey.SkillBuilding,
    "Curriculum sequencing",
    ["course", "curriculum", "syllabus", "module"],
    [
      {
        key: "sequence",
        title: "Sequence the learning path into a small curriculum",
        summary: "Turn scattered resources into an ordered path.",
        workTypes: [PlanningWorkType.Research, PlanningWorkType.Admin],
      },
      {
        key: "complete",
        title: "Complete the next curriculum block",
        summary: "Advance one bounded module at a time.",
        workTypes: [PlanningWorkType.DeepWork, PlanningWorkType.RoutineAction],
      },
    ],
  ),
  createTemplate(
    StrategyKey.SkillDeliberatePractice,
    DomainKey.SkillBuilding,
    "Deliberate practice",
    ["practice", "drill", "repeat", "exercise"],
    [
      {
        key: "drill",
        title: "Define a narrow practice drill",
        summary: "Practice one subskill cleanly instead of vaguely studying.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.DeepWork],
      },
      {
        key: "repeat",
        title: "Repeat the drill on a stable cadence",
        summary: "Use short sessions to build traction.",
        workTypes: [PlanningWorkType.RoutineAction],
      },
    ],
  ),
  createTemplate(
    StrategyKey.SkillPortfolioApplication,
    DomainKey.SkillBuilding,
    "Portfolio application",
    ["portfolio", "project", "build", "demo"],
    [
      {
        key: "apply",
        title: "Apply the skill to a small real artifact",
        summary: "Convert learning into something inspectable.",
        workTypes: [PlanningWorkType.DeepWork],
      },
      {
        key: "review",
        title: "Review the artifact and tighten weak spots",
        summary: "Use feedback to sharpen the next iteration.",
        workTypes: [PlanningWorkType.DeepWork, PlanningWorkType.Admin],
      },
    ],
  ),
  createTemplate(
    StrategyKey.RelationshipConsistency,
    DomainKey.Relationship,
    "Consistency and presence",
    ["partner", "date", "call", "family", "friend"],
    [
      {
        key: "cadence",
        title: "Create a realistic connection cadence",
        summary: "Make the relationship effort consistent instead of sporadic.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.Communication],
      },
      {
        key: "follow",
        title: "Follow through on the next connection window",
        summary: "Keep the next step obvious and easy to honor.",
        workTypes: [PlanningWorkType.Communication],
      },
    ],
  ),
  createTemplate(
    StrategyKey.RelationshipCommunication,
    DomainKey.Relationship,
    "Communication repair",
    ["conversation", "repair", "conflict", "check-in"],
    [
      {
        key: "prepare",
        title: "Prepare for one useful conversation",
        summary: "Clarify the topic before the conversation becomes noisy.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.Communication],
      },
      {
        key: "hold",
        title: "Hold the conversation with a narrow objective",
        summary: "Aim for progress, not resolution of everything at once.",
        workTypes: [PlanningWorkType.Communication],
      },
    ],
  ),
  createTemplate(
    StrategyKey.RelationshipSupportFollowThrough,
    DomainKey.Relationship,
    "Support follow-through",
    ["support", "help", "show up"],
    [
      {
        key: "identify",
        title: "Identify one concrete support action",
        summary: "Make support visible and actionable.",
        workTypes: [PlanningWorkType.Admin],
      },
      {
        key: "deliver",
        title: "Deliver the support action cleanly",
        summary: "Choose a small promise and actually complete it.",
        workTypes: [PlanningWorkType.RoutineAction, PlanningWorkType.Communication],
      },
    ],
  ),
  createTemplate(
    StrategyKey.PersonalRoutineReset,
    DomainKey.Personal,
    "Routine reset",
    ["routine", "reset", "morning", "evening"],
    [
      {
        key: "baseline",
        title: "Reset the minimum viable routine",
        summary: "Strip the routine down to what can realistically stick now.",
        workTypes: [PlanningWorkType.Admin, PlanningWorkType.RoutineAction],
      },
      {
        key: "repeat",
        title: "Repeat the reset on the easiest days first",
        summary: "Build trust with simple repetition before adding complexity.",
        workTypes: [PlanningWorkType.RoutineAction],
      },
    ],
  ),
  createTemplate(
    StrategyKey.PersonalEnvironmentStability,
    DomainKey.Personal,
    "Environment stability",
    ["declutter", "organize", "home", "space"],
    [
      {
        key: "focus-zone",
        title: "Stabilize one friction-heavy environment zone",
        summary: "Pick the space that creates the most daily drag.",
        workTypes: [PlanningWorkType.RoutineAction, PlanningWorkType.Admin],
      },
      {
        key: "maintain",
        title: "Maintain the zone with a light reset cadence",
        summary: "Prevent the space from degrading again immediately.",
        workTypes: [PlanningWorkType.RoutineAction],
      },
    ],
  ),
  createTemplate(
    StrategyKey.PersonalReflection,
    DomainKey.Personal,
    "Reflection and clarity",
    ["journal", "reflect", "clarify"],
    [
      {
        key: "prompt",
        title: "Create a short reflection prompt set",
        summary: "Make reflection specific enough to be usable.",
        workTypes: [PlanningWorkType.Admin],
      },
      {
        key: "review",
        title: "Review personal signal weekly",
        summary: "Use a short reflection loop to preserve continuity.",
        workTypes: [PlanningWorkType.Admin],
      },
    ],
  ),
];

export function selectStrategies(goal: GoalDraftInput, analysis: GoalPlanningAnalysis) {
  const text = [goal.title, goal.summary, goal.successMetric, goal.notes, ...(goal.tags ?? [])]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();
  const selectedDomain = analysis.selectedDomain.domainKey;
  const limit = analysis.policy.mode === PlanningMode.Protective ? 2 : 3;

  const ranked = strategyTemplates
    .filter((template) => template.domainKey === selectedDomain)
    .map((template) => {
      let score = 1;

      for (const keyword of template.keywords) {
        if (text.includes(keyword)) {
          score += 2;
        }
      }

      if (
        template.key === StrategyKey.CareerApplications &&
        analysis.classification.kind === GoalClassificationKind.ProjectGoal
      ) {
        score += 1;
      }

      if (
        template.key === StrategyKey.FitnessConsistency &&
        analysis.classification.complexity !== GoalComplexity.Low
      ) {
        score += 1;
      }

      if (
        template.key === StrategyKey.SkillDeliberatePractice &&
        analysis.classification.kind === GoalClassificationKind.ProcessGoal
      ) {
        score += 1;
      }

      return { template, score };
    })
    .sort((left, right) => right.score - left.score)
    .slice(0, limit);

  return ranked.map(({ template, score }) => ({
    key: template.key,
    domainKey: template.domainKey,
    label: template.label,
    confidence: Number((Math.min(1, 0.45 + score * 0.1)).toFixed(2)),
    rationale:
      score > 1
        ? `Selected because the goal language strongly matches ${template.label.toLowerCase()}.`
        : `Selected as a stable default strategy for ${template.domainKey} goals.`,
  }));
}

export function getStrategyTemplate(key: StrategyKey) {
  return strategyTemplates.find((template) => template.key === key);
}
