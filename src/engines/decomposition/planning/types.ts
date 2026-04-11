import { Goal, GoalMilestone, Task } from "../../../domain/models";
import {
  DomainCandidate,
  GoalClassification,
  GoalPlanningAnalysis,
  GoalPathShape,
  GoalDraftInput,
  PlanningPolicy,
  PlanningWorkType,
  StrategyKey,
  StrategySelection,
  TaskFlexibility,
} from "../../../domain/models/planningBrain";

export interface StrategyTemplate {
  key: StrategyKey;
  domainKey: DomainCandidate["domainKey"];
  label: string;
  keywords: string[];
  buildMilestones: (context: StrategyPlanningContext) => MilestoneBlueprint[];
}

export interface StrategyPlanningContext {
  goal: Goal;
  input: GoalDraftInput;
  analysis: GoalPlanningAnalysis;
  strategy: StrategySelection;
}

export interface MilestoneBlueprint {
  phaseKey: string;
  title: string;
  summary: string;
  workTypes: PlanningWorkType[];
  confidence: number;
  targetOffsetDays: number;
}

export interface DurationEstimate {
  minutes: number;
  difficulty: Task["difficulty"];
  effortPoints: number;
  reasons: string[];
}

export interface PlannerArtifacts {
  analysis: GoalPlanningAnalysis;
  milestones: GoalMilestone[];
  tasks: Task[];
}

export interface TaskGenerationBlueprint {
  title: string;
  summary: string;
  workType: PlanningWorkType;
  novelty: "low" | "medium" | "high";
  flexibility: TaskFlexibility;
  splitEligible: boolean;
  fallbackTitle: string;
}

export interface MilestoneContext {
  goal: Goal;
  analysis: GoalPlanningAnalysis;
  milestone: GoalMilestone;
  policy: PlanningPolicy;
  classification: GoalClassification;
}
