import { DomainKey } from "../../../domain/models";
import { DomainCandidate, GoalDraftInput } from "../../../domain/models/planningBrain";

const domainSignals: Record<DomainKey, string[]> = {
  [DomainKey.Fitness]: [
    "workout",
    "train",
    "fitness",
    "gym",
    "run",
    "running",
    "strength",
    "cardio",
    "conditioning",
    "weight",
    "nutrition",
    "sleep",
  ],
  [DomainKey.Finance]: [
    "budget",
    "save",
    "saving",
    "finance",
    "cash flow",
    "emergency fund",
    "expense",
    "spending",
    "invest",
    "debt",
  ],
  [DomainKey.Credit]: [
    "credit",
    "utilization",
    "score",
    "statement",
    "collections",
    "late payment",
    "report",
    "card balance",
  ],
  [DomainKey.Career]: [
    "career",
    "job",
    "application",
    "interview",
    "portfolio",
    "networking",
    "manager",
    "promotion",
    "resume",
    "linkedin",
  ],
  [DomainKey.SkillBuilding]: [
    "learn",
    "study",
    "course",
    "practice",
    "skill",
    "curriculum",
    "drill",
    "certification",
  ],
  [DomainKey.Relationship]: [
    "partner",
    "relationship",
    "family",
    "friend",
    "date",
    "conversation",
    "connection",
    "check-in",
  ],
  [DomainKey.Personal]: [
    "routine",
    "personal",
    "journal",
    "home",
    "declutter",
    "reset",
    "organize",
    "energy",
    "life admin",
  ],
};

export function mapGoalDomain(input: GoalDraftInput): DomainCandidate[] {
  const text = [input.title, input.summary, input.notes, ...(input.tags ?? [])]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();

  const candidates = Object.entries(domainSignals).map(([domainKey, signals]) => {
    let score = input.domainKey === domainKey ? 4 : 0;
    const reasons: string[] = [];

    if (input.domainKey === domainKey) {
      reasons.push("Existing goal domain provides an explicit hint.");
    }

    for (const signal of signals) {
      if (!text.includes(signal)) {
        continue;
      }

      score += 1;
      reasons.push(`Matched keyword: "${signal}".`);
    }

    if (input.successMetric?.toLowerCase().includes("score") && domainKey === DomainKey.Credit) {
      score += 1;
      reasons.push("Credit-score language strongly matches the credit domain.");
    }

    return {
      domainKey: domainKey as DomainKey,
      confidence: 0,
      reasons,
      score,
    };
  });

  const maxScore = Math.max(...candidates.map((candidate) => candidate.score), 1);

  return candidates
    .map(({ score, ...candidate }) => ({
      ...candidate,
      confidence: Number((score / maxScore).toFixed(2)),
    }))
    .sort((left, right) => right.confidence - left.confidence);
}
