import { StrategyStrictness } from "./adaptation";
import { DomainKey } from "./domain";
import { GoalHorizon, GoalType } from "./goal";

export interface GoalDraftInput {
  title: string;
  summary?: string | null;
  successMetric?: string | null;
  notes?: string | null;
  horizon?: GoalHorizon | null;
  type?: GoalType | null;
  targetDate?: string | null;
  startDate?: string | null;
  desiredWeeklyMinutes?: number | null;
  estimatedTotalMinutes?: number | null;
  domainKey?: DomainKey | null;
  tags?: string[];
}

export enum GoalClassificationKind {
  OutcomeGoal = "outcome_goal",
  ProcessGoal = "process_goal",
  ProjectGoal = "project_goal",
}

export enum GoalTimeframe {
  Immediate = "immediate",
  Short = "short",
  Medium = "medium",
  Long = "long",
}

export enum GoalComplexity {
  Low = "low",
  Moderate = "moderate",
  High = "high",
}

export enum GoalPathShape {
  SinglePath = "single_path",
  MultiStep = "multi_step",
}

export interface GoalClassification {
  kind: GoalClassificationKind;
  timeframe: GoalTimeframe;
  measurable: boolean;
  complexity: GoalComplexity;
  domainConfidence: number;
  pathShape: GoalPathShape;
  reasons: string[];
}

export interface DomainCandidate {
  domainKey: DomainKey;
  confidence: number;
  reasons: string[];
}

export enum PlanningMode {
  Protective = "protective",
  Balanced = "balanced",
  Aggressive = "aggressive",
}

export interface PlanningPolicy {
  mode: PlanningMode;
  strictness: StrategyStrictness;
  dailyTaskSoftCap: number;
  maxTasksPerMilestone: number;
  preferredTaskDurationMax: number;
  earlyWinBias: boolean;
  shorterWhenUncertain: boolean;
  reduceVolumeUnderUncertainty: boolean;
  prefersSmallerEntryTasks: boolean;
}

export enum StrategyKey {
  CreditUtilizationReduction = "credit_utilization_reduction",
  CreditPaymentConsistency = "credit_payment_consistency",
  CreditCleanup = "credit_cleanup",
  CreditMonitoring = "credit_monitoring",
  FitnessConsistency = "fitness_consistency",
  FitnessCaloricControl = "fitness_caloric_control",
  FitnessTrainingFrequency = "fitness_training_frequency",
  FitnessRecoveryStructure = "fitness_recovery_structure",
  FinanceCashFlowClarity = "finance_cash_flow_clarity",
  FinanceSavingsRate = "finance_savings_rate",
  FinanceDebtPaydown = "finance_debt_paydown",
  CareerOutputBuilding = "career_output_building",
  CareerNetworking = "career_networking",
  CareerApplications = "career_applications",
  CareerSkillAcquisition = "career_skill_acquisition",
  SkillCurriculum = "skill_curriculum",
  SkillDeliberatePractice = "skill_deliberate_practice",
  SkillPortfolioApplication = "skill_portfolio_application",
  RelationshipConsistency = "relationship_consistency",
  RelationshipCommunication = "relationship_communication",
  RelationshipSupportFollowThrough = "relationship_support_follow_through",
  PersonalRoutineReset = "personal_routine_reset",
  PersonalEnvironmentStability = "personal_environment_stability",
  PersonalReflection = "personal_reflection",
}

export interface StrategySelection {
  key: StrategyKey;
  domainKey: DomainKey;
  label: string;
  confidence: number;
  rationale: string;
}

export enum PlanningWorkType {
  Admin = "admin",
  Research = "research",
  Communication = "communication",
  DeepWork = "deep_work",
  RoutineAction = "routine_action",
}

export type TaskFlexibility = "high" | "medium" | "low";

export interface GoalPlanningAnalysis {
  classification: GoalClassification;
  domainCandidates: DomainCandidate[];
  selectedDomain: DomainCandidate;
  strategies: StrategySelection[];
  policy: PlanningPolicy;
}
