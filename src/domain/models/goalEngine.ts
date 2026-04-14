import { EntityId, ISODateString, ISODateTimeString } from "./shared";

/**
 * Canonical goal engine contract.
 *
 * Keep TypeScript as the source of truth for shape, defaults, validation, and
 * serialization. The mirrored Swift file is intentionally secondary and should
 * follow this contract instead of diverging from it. If generators are added
 * later, they should derive from this TypeScript contract whenever possible.
 */
export const GOAL_ENGINE_SCHEMA_VERSION = "goal_engine.v1" as const;
export type GoalEngineSchemaVersion = typeof GOAL_ENGINE_SCHEMA_VERSION;
export const GOAL_ENGINE_PLAN_VERSION = 1 as const;
export const GOAL_ENGINE_SERIALIZATION_VERSION = 1 as const;

export enum GoalTempo {
  DeadlineBased = "deadline_based",
  TargetWindow = "target_window",
  Ongoing = "ongoing",
  Untimed = "untimed",
}

export enum GoalMode {
  Achievement = "achievement",
  Project = "project",
  Habit = "habit",
  Learning = "learning",
  Exploration = "exploration",
  Maintenance = "maintenance",
  Recovery = "recovery",
  DelegatedSupport = "delegated_support",
}

export enum ExecutionOwnership {
  Self = "self",
  Child = "child",
  Partner = "partner",
  Team = "team",
  Household = "household",
  ObservedOnly = "observed_only",
}

export enum StepType {
  ActionUnit = "action_unit",
  RecurringRoutine = "recurring_routine",
  LearningCheckpoint = "learning_checkpoint",
  ExplorationExperiment = "exploration_experiment",
  SupportAction = "support_action",
  ObservationPrompt = "observation_prompt",
  Resource = "resource",
  ReflectionPrompt = "reflection_prompt",
}

export enum TimingType {
  DueAt = "due_at",
  TargetBy = "target_by",
  RepeatWithinWindow = "repeat_within_window",
  SuggestedNext = "suggested_next",
  LogWhenDone = "log_when_done",
}

export enum GoalLifecycleState {
  Draft = "draft",
  Active = "active",
  Paused = "paused",
  Completed = "completed",
  Archived = "archived",
}

export enum GoalRelationshipKind {
  Independent = "independent",
  Child = "child",
  Support = "support",
  Delegated = "delegated",
}

export enum PlanSectionKind {
  Overview = "overview",
  ActiveSteps = "active_steps",
  Upcoming = "upcoming",
  Review = "review",
  Resources = "resources",
  SupportingWork = "supporting_work",
  Completed = "completed",
}

export enum StepLifecycleState {
  Planned = "planned",
  Active = "active",
  Completed = "completed",
  Blocked = "blocked",
  Cancelled = "cancelled",
}

export enum PlanningStrategyKind {
  Sequential = "sequential",
  Parallel = "parallel",
  Cadence = "cadence",
  Exploratory = "exploratory",
  Supportive = "supportive",
  Adaptive = "adaptive",
}

export enum ProgressMetricKind {
  StepCompletion = "step_completion",
  EvidenceCount = "evidence_count",
  Streak = "streak",
  TimeInvested = "time_invested",
  ConfidenceGain = "confidence_gain",
  ObservationLog = "observation_log",
}

export enum ProgressRollupMethod {
  Sum = "sum",
  Ratio = "ratio",
  Latest = "latest",
  WeightedRatio = "weighted_ratio",
  StreakLength = "streak_length",
}

export enum ProgressEvidenceKind {
  StepCompleted = "step_completed",
  SessionLogged = "session_logged",
  ReflectionLogged = "reflection_logged",
  DelegatedUpdate = "delegated_update",
  ObservationLogged = "observation_logged",
  MilestoneReached = "milestone_reached",
}

export enum EvidenceSource {
  Manual = "manual",
  Migration = "migration",
  Imported = "imported",
  Derived = "derived",
  AiSuggested = "ai_suggested",
}

export enum ContractValueSource {
  Manual = "manual",
  Migration = "migration",
  LegacyGoalMetadata = "legacy_goal_metadata",
  LegacyGoalType = "legacy_goal_type",
  LegacyGoalTags = "legacy_goal_tags",
  LegacyGoalDates = "legacy_goal_dates",
  LegacyGoalParent = "legacy_goal_parent",
  LegacyActorMetadata = "legacy_actor_metadata",
  LegacyTaskDates = "legacy_task_dates",
  LegacyTaskRecurrence = "legacy_task_recurrence",
  LegacyMilestone = "legacy_milestone",
  DefaultStrategy = "default_strategy",
  DerivedContract = "derived_contract",
}

export enum FeedbackEventType {
  PlanAdjusted = "plan_adjusted",
  Blocked = "blocked",
  ConfidenceUpdated = "confidence_updated",
  EnergyMismatch = "energy_mismatch",
  DelegationUpdate = "delegation_update",
  ReflectionCaptured = "reflection_captured",
}

export enum FeedbackSentiment {
  Positive = "positive",
  Neutral = "neutral",
  Negative = "negative",
  Mixed = "mixed",
}

export enum PlanLintSeverity {
  Error = "error",
  Warning = "warning",
  Info = "info",
}

export enum PlanLintIssueCode {
  MissingTitle = "missing_title",
  InvalidTiming = "invalid_timing",
  MissingParentForRelationship = "missing_parent_for_relationship",
  MissingPlanSections = "missing_plan_sections",
  MissingStepTitle = "missing_step_title",
  DuplicateSectionId = "duplicate_section_id",
  DuplicateStepId = "duplicate_step_id",
  InvalidDependency = "invalid_dependency",
  InvalidProgressStrategy = "invalid_progress_strategy",
  InvalidDelegatedOwnership = "invalid_delegated_ownership",
}

export interface ContractValueProvenance {
  source: ContractValueSource;
  inferred: boolean;
  confidence: number;
  reason: string;
}

export interface GoalActorProvenance {
  ownership: ContractValueProvenance | null;
  displayName: ContractValueProvenance | null;
}

export interface GoalTimingProvenance {
  tempo: ContractValueProvenance | null;
  timingType: ContractValueProvenance | null;
  startsOn: ContractValueProvenance | null;
  dueAt: ContractValueProvenance | null;
  targetBy: ContractValueProvenance | null;
  windowStart: ContractValueProvenance | null;
  windowEnd: ContractValueProvenance | null;
  suggestedNextAt: ContractValueProvenance | null;
  repeatEveryDays: ContractValueProvenance | null;
  progressReviewCadenceDays: ContractValueProvenance | null;
}

export interface GoalContractMetadata {
  mode: ContractValueProvenance | null;
  relationshipKind: ContractValueProvenance | null;
  actor: GoalActorProvenance | null;
  timing: GoalTimingProvenance | null;
}

export interface StepContractMetadata {
  legacySourceKind: "goal" | "milestone" | "task" | null;
  legacySourceId: EntityId | null;
  actor: GoalActorProvenance | null;
  timing: GoalTimingProvenance | null;
}

export interface GoalActor {
  actorId: EntityId;
  displayName: string;
  ownership: ExecutionOwnership;
  roleLabel: string | null;
  isPrimary: boolean;
  provenance?: GoalActorProvenance | null;
}

export interface GoalTiming {
  tempo: GoalTempo;
  timingType: TimingType;
  startsOn: ISODateString | null;
  dueAt: ISODateTimeString | null;
  targetBy: ISODateString | null;
  windowStart: ISODateString | null;
  windowEnd: ISODateString | null;
  suggestedNextAt: ISODateTimeString | null;
  repeatEveryDays: number | null;
  progressReviewCadenceDays: number | null;
  provenance?: GoalTimingProvenance | null;
}

export interface PlanningStrategy {
  strategyKind: PlanningStrategyKind;
  allowParallelSteps: boolean;
  maxActiveSteps: number;
  preferredSectionOrder: PlanSectionKind[];
  defaultStepType: StepType;
  autoGenerateReviewSection: boolean;
  preferShortSteps: boolean;
  revisitCadenceDays: number | null;
}

export interface ProgressStrategy {
  metricKind: ProgressMetricKind;
  rollupMethod: ProgressRollupMethod;
  targetStepCount: number | null;
  targetEvidenceCount: number | null;
  targetMinutes: number | null;
  supportsUntimedProgress: boolean;
  countsChildGoals: boolean;
  countsSupportGoals: boolean;
}

export interface Step {
  id: EntityId;
  sectionId: EntityId;
  title: string;
  summary: string | null;
  type: StepType;
  state: StepLifecycleState;
  owner: GoalActor;
  timing: GoalTiming;
  dependencyStepIds: EntityId[];
  isOptional: boolean;
  isRepeatable: boolean;
  evidenceRequired: boolean;
  successSignals: string[];
  contract?: StepContractMetadata | null;
}

export interface PlanSection {
  id: EntityId;
  goalId: EntityId;
  title: string;
  summary: string | null;
  kind: PlanSectionKind;
  orderIndex: number;
  steps: Step[];
}

export interface PlanLintIssue {
  code: PlanLintIssueCode;
  severity: PlanLintSeverity;
  fieldPath: string[];
  message: string;
  sectionId: EntityId | null;
  stepId: EntityId | null;
}

export interface PlanLintResult {
  goalId: EntityId | null;
  planVersion: number;
  isValid: boolean;
  issueCount: number;
  issues: PlanLintIssue[];
}

export interface GoalPlan {
  id: EntityId;
  goalId: EntityId;
  version: number;
  generatedAt: ISODateTimeString;
  summary: string | null;
  strategy: PlanningStrategy;
  sections: PlanSection[];
  lint: PlanLintResult;
}

export interface ProgressEvidence {
  id: EntityId;
  goalId: EntityId;
  stepId: EntityId | null;
  evidenceKind: ProgressEvidenceKind;
  source: EvidenceSource;
  capturedAt: ISODateTimeString;
  progressDelta: number | null;
  confidenceDelta: number | null;
  minutesInvested: number | null;
  note: string | null;
}

export interface FeedbackEvent {
  id: EntityId;
  goalId: EntityId;
  stepId: EntityId | null;
  eventType: FeedbackEventType;
  sentiment: FeedbackSentiment;
  occurredAt: ISODateTimeString;
  confidenceBefore: number | null;
  confidenceAfter: number | null;
  blockerPresent: boolean;
  summary: string;
}

export interface GoalDraft {
  schemaVersion: GoalEngineSchemaVersion;
  source: EvidenceSource;
  title: string;
  summary: string | null;
  mode: GoalMode;
  relationshipKind: GoalRelationshipKind;
  actor: GoalActor;
  parentGoalId: EntityId | null;
  tags: string[];
  timing: GoalTiming;
  planningStrategy: PlanningStrategy;
  progressStrategy: ProgressStrategy;
  contract?: GoalContractMetadata | null;
}

export interface Goal {
  schemaVersion: GoalEngineSchemaVersion;
  id: EntityId;
  revision: number;
  createdAt: ISODateTimeString;
  updatedAt: ISODateTimeString;
  state: GoalLifecycleState;
  title: string;
  summary: string | null;
  mode: GoalMode;
  relationshipKind: GoalRelationshipKind;
  actor: GoalActor;
  parentGoalId: EntityId | null;
  childGoalIds: EntityId[];
  supportGoalIds: EntityId[];
  tags: string[];
  timing: GoalTiming;
  planningStrategy: PlanningStrategy;
  progressStrategy: ProgressStrategy;
  plan: GoalPlan | null;
  contract?: GoalContractMetadata | null;
}

export type EngineGoalActor = GoalActor;
export type EngineGoalTiming = GoalTiming;
export type EnginePlanningStrategy = PlanningStrategy;
export type EngineProgressStrategy = ProgressStrategy;
export type EngineStep = Step;
export type EnginePlanSection = PlanSection;
export type EngineGoalPlan = GoalPlan;
export type EngineGoalDraft = GoalDraft;
export type EngineGoal = Goal;

type GoalLintSubject = Pick<
  Goal,
  "title" | "mode" | "relationshipKind" | "actor" | "parentGoalId" | "timing" | "progressStrategy"
> &
  Partial<Pick<GoalDraft, "source">>;

function issue(
  code: PlanLintIssueCode,
  severity: PlanLintSeverity,
  fieldPath: string[],
  message: string,
  sectionId: EntityId | null = null,
  stepId: EntityId | null = null,
): PlanLintIssue {
  return { code, severity, fieldPath, message, sectionId, stepId };
}

function clampProvenanceConfidence(value: number): number {
  return Number(Math.min(1, Math.max(0, value)).toFixed(2));
}

export function createContractProvenance(params: {
  source: ContractValueSource;
  inferred: boolean;
  confidence: number;
  reason: string;
}): ContractValueProvenance {
  return {
    source: params.source,
    inferred: params.inferred,
    confidence: clampProvenanceConfidence(params.confidence),
    reason: params.reason,
  };
}

export function createGoalActorProvenance(
  params: Partial<GoalActorProvenance> = {},
): GoalActorProvenance {
  return {
    ownership: params.ownership ?? null,
    displayName: params.displayName ?? null,
  };
}

export function createGoalTimingProvenance(
  params: Partial<GoalTimingProvenance> = {},
): GoalTimingProvenance {
  return {
    tempo: params.tempo ?? null,
    timingType: params.timingType ?? null,
    startsOn: params.startsOn ?? null,
    dueAt: params.dueAt ?? null,
    targetBy: params.targetBy ?? null,
    windowStart: params.windowStart ?? null,
    windowEnd: params.windowEnd ?? null,
    suggestedNextAt: params.suggestedNextAt ?? null,
    repeatEveryDays: params.repeatEveryDays ?? null,
    progressReviewCadenceDays: params.progressReviewCadenceDays ?? null,
  };
}

export function createGoalContractMetadata(
  params: Partial<GoalContractMetadata> = {},
): GoalContractMetadata {
  return {
    mode: params.mode ?? null,
    relationshipKind: params.relationshipKind ?? null,
    actor: params.actor ?? null,
    timing: params.timing ?? null,
  };
}

export function createStepContractMetadata(
  params: Partial<StepContractMetadata> = {},
): StepContractMetadata {
  return {
    legacySourceKind: params.legacySourceKind ?? null,
    legacySourceId: params.legacySourceId ?? null,
    actor: params.actor ?? null,
    timing: params.timing ?? null,
  };
}

export function createDefaultGoalActor(
  ownership: ExecutionOwnership = ExecutionOwnership.Self,
  displayName = "You",
): GoalActor {
  return {
    actorId: ownership,
    displayName,
    ownership,
    roleLabel: ownership === ExecutionOwnership.Self ? "Primary owner" : "Supported owner",
    isPrimary: true,
    provenance: createGoalActorProvenance({
      ownership: createContractProvenance({
        source: ContractValueSource.Manual,
        inferred: false,
        confidence: 1,
        reason: "The actor ownership was set directly in the canonical TypeScript contract helper.",
      }),
      displayName: createContractProvenance({
        source: ContractValueSource.Manual,
        inferred: false,
        confidence: 1,
        reason: "The actor display name was set directly in the canonical TypeScript contract helper.",
      }),
    }),
  };
}

export function createGoalTiming(params: {
  tempo: GoalTempo;
  timingType?: TimingType;
  startsOn?: ISODateString | null;
  dueAt?: ISODateTimeString | null;
  targetBy?: ISODateString | null;
  windowStart?: ISODateString | null;
  windowEnd?: ISODateString | null;
  suggestedNextAt?: ISODateTimeString | null;
  repeatEveryDays?: number | null;
  progressReviewCadenceDays?: number | null;
  provenance?: GoalTimingProvenance | null;
}): GoalTiming {
  return {
    tempo: params.tempo,
    timingType:
      params.timingType ??
      (params.tempo === GoalTempo.DeadlineBased
        ? TimingType.DueAt
        : params.tempo === GoalTempo.TargetWindow
          ? TimingType.TargetBy
          : params.tempo === GoalTempo.Ongoing
            ? TimingType.RepeatWithinWindow
            : TimingType.LogWhenDone),
    startsOn: params.startsOn ?? null,
    dueAt: params.dueAt ?? null,
    targetBy: params.targetBy ?? null,
    windowStart: params.windowStart ?? null,
    windowEnd: params.windowEnd ?? null,
    suggestedNextAt: params.suggestedNextAt ?? null,
    repeatEveryDays: params.repeatEveryDays ?? null,
    progressReviewCadenceDays: params.progressReviewCadenceDays ?? null,
    provenance: params.provenance ?? null,
  };
}

export function createDefaultPlanningStrategy(mode: GoalMode): PlanningStrategy {
  switch (mode) {
    case GoalMode.Habit:
    case GoalMode.Maintenance:
      return {
        strategyKind: PlanningStrategyKind.Cadence,
        allowParallelSteps: true,
        maxActiveSteps: 3,
        preferredSectionOrder: [PlanSectionKind.Overview, PlanSectionKind.ActiveSteps, PlanSectionKind.Review],
        defaultStepType: StepType.RecurringRoutine,
        autoGenerateReviewSection: true,
        preferShortSteps: true,
        revisitCadenceDays: 7,
      };
    case GoalMode.Learning:
      return {
        strategyKind: PlanningStrategyKind.Adaptive,
        allowParallelSteps: true,
        maxActiveSteps: 4,
        preferredSectionOrder: [
          PlanSectionKind.Overview,
          PlanSectionKind.ActiveSteps,
          PlanSectionKind.Resources,
          PlanSectionKind.Review,
        ],
        defaultStepType: StepType.LearningCheckpoint,
        autoGenerateReviewSection: true,
        preferShortSteps: true,
        revisitCadenceDays: 7,
      };
    case GoalMode.Exploration:
      return {
        strategyKind: PlanningStrategyKind.Exploratory,
        allowParallelSteps: true,
        maxActiveSteps: 5,
        preferredSectionOrder: [
          PlanSectionKind.Overview,
          PlanSectionKind.ActiveSteps,
          PlanSectionKind.SupportingWork,
          PlanSectionKind.Review,
        ],
        defaultStepType: StepType.ExplorationExperiment,
        autoGenerateReviewSection: true,
        preferShortSteps: true,
        revisitCadenceDays: 5,
      };
    case GoalMode.DelegatedSupport:
      return {
        strategyKind: PlanningStrategyKind.Supportive,
        allowParallelSteps: true,
        maxActiveSteps: 4,
        preferredSectionOrder: [
          PlanSectionKind.Overview,
          PlanSectionKind.SupportingWork,
          PlanSectionKind.Review,
        ],
        defaultStepType: StepType.SupportAction,
        autoGenerateReviewSection: true,
        preferShortSteps: true,
        revisitCadenceDays: 7,
      };
    case GoalMode.Recovery:
      return {
        strategyKind: PlanningStrategyKind.Adaptive,
        allowParallelSteps: false,
        maxActiveSteps: 2,
        preferredSectionOrder: [PlanSectionKind.Overview, PlanSectionKind.ActiveSteps, PlanSectionKind.Review],
        defaultStepType: StepType.ActionUnit,
        autoGenerateReviewSection: true,
        preferShortSteps: true,
        revisitCadenceDays: 3,
      };
    case GoalMode.Achievement:
    case GoalMode.Project:
    default:
      return {
        strategyKind: PlanningStrategyKind.Sequential,
        allowParallelSteps: mode === GoalMode.Project,
        maxActiveSteps: mode === GoalMode.Project ? 4 : 3,
        preferredSectionOrder: [PlanSectionKind.Overview, PlanSectionKind.ActiveSteps, PlanSectionKind.Upcoming],
        defaultStepType: StepType.ActionUnit,
        autoGenerateReviewSection: false,
        preferShortSteps: false,
        revisitCadenceDays: 7,
      };
  }
}

export function createDefaultProgressStrategy(mode: GoalMode, tempo: GoalTempo): ProgressStrategy {
  switch (mode) {
    case GoalMode.Habit:
    case GoalMode.Maintenance:
      return {
        metricKind: ProgressMetricKind.Streak,
        rollupMethod: ProgressRollupMethod.StreakLength,
        targetStepCount: null,
        targetEvidenceCount: 5,
        targetMinutes: null,
        supportsUntimedProgress: true,
        countsChildGoals: false,
        countsSupportGoals: false,
      };
    case GoalMode.Learning:
      return {
        metricKind: ProgressMetricKind.EvidenceCount,
        rollupMethod: ProgressRollupMethod.WeightedRatio,
        targetStepCount: 4,
        targetEvidenceCount: 8,
        targetMinutes: 240,
        supportsUntimedProgress: true,
        countsChildGoals: false,
        countsSupportGoals: false,
      };
    case GoalMode.Exploration:
      return {
        metricKind: ProgressMetricKind.ObservationLog,
        rollupMethod: ProgressRollupMethod.Sum,
        targetStepCount: 5,
        targetEvidenceCount: 5,
        targetMinutes: null,
        supportsUntimedProgress: true,
        countsChildGoals: false,
        countsSupportGoals: false,
      };
    case GoalMode.DelegatedSupport:
      return {
        metricKind: ProgressMetricKind.EvidenceCount,
        rollupMethod: ProgressRollupMethod.Latest,
        targetStepCount: 3,
        targetEvidenceCount: 4,
        targetMinutes: null,
        supportsUntimedProgress: true,
        countsChildGoals: true,
        countsSupportGoals: true,
      };
    case GoalMode.Recovery:
      return {
        metricKind: ProgressMetricKind.ConfidenceGain,
        rollupMethod: ProgressRollupMethod.Latest,
        targetStepCount: 3,
        targetEvidenceCount: 6,
        targetMinutes: null,
        supportsUntimedProgress: true,
        countsChildGoals: false,
        countsSupportGoals: true,
      };
    case GoalMode.Achievement:
    case GoalMode.Project:
    default:
      return {
        metricKind:
          tempo === GoalTempo.DeadlineBased ? ProgressMetricKind.StepCompletion : ProgressMetricKind.TimeInvested,
        rollupMethod: ProgressRollupMethod.Ratio,
        targetStepCount: mode === GoalMode.Project ? 6 : 4,
        targetEvidenceCount: null,
        targetMinutes: tempo === GoalTempo.Untimed ? null : 360,
        supportsUntimedProgress: tempo === GoalTempo.Untimed,
        countsChildGoals: true,
        countsSupportGoals: true,
      };
  }
}

function lintTiming(timing: GoalTiming, fieldPath: string[]): PlanLintIssue[] {
  const issues: PlanLintIssue[] = [];

  if (timing.windowStart && timing.windowEnd && timing.windowStart > timing.windowEnd) {
    issues.push(
      issue(
        PlanLintIssueCode.InvalidTiming,
        PlanLintSeverity.Error,
        fieldPath,
        "windowStart must be earlier than or equal to windowEnd.",
      ),
    );
  }

  switch (timing.tempo) {
    case GoalTempo.DeadlineBased:
      if (!timing.dueAt) {
        issues.push(
          issue(
            PlanLintIssueCode.InvalidTiming,
            PlanLintSeverity.Error,
            fieldPath,
            "Deadline-based goals require dueAt.",
          ),
        );
      }
      if (timing.windowStart || timing.windowEnd) {
        issues.push(
          issue(
            PlanLintIssueCode.InvalidTiming,
            PlanLintSeverity.Warning,
            fieldPath,
            "Deadline-based goals should not also declare a target window.",
          ),
        );
      }
      break;
    case GoalTempo.TargetWindow:
      if (!timing.targetBy && !(timing.windowStart && timing.windowEnd)) {
        issues.push(
          issue(
            PlanLintIssueCode.InvalidTiming,
            PlanLintSeverity.Error,
            fieldPath,
            "Target-window goals require targetBy or both windowStart and windowEnd.",
          ),
        );
      }
      break;
    case GoalTempo.Ongoing:
      if (timing.dueAt) {
        issues.push(
          issue(
            PlanLintIssueCode.InvalidTiming,
            PlanLintSeverity.Warning,
            fieldPath,
            "Ongoing goals should not declare dueAt.",
          ),
        );
      }
      if (!timing.repeatEveryDays && timing.timingType === TimingType.RepeatWithinWindow) {
        issues.push(
          issue(
            PlanLintIssueCode.InvalidTiming,
            PlanLintSeverity.Error,
            fieldPath,
            "Ongoing repeat_within_window timing requires repeatEveryDays.",
          ),
        );
      }
      break;
    case GoalTempo.Untimed:
      if (timing.dueAt || timing.targetBy || timing.windowStart || timing.windowEnd) {
        issues.push(
          issue(
            PlanLintIssueCode.InvalidTiming,
            PlanLintSeverity.Error,
            fieldPath,
            "Untimed goals cannot declare dueAt, targetBy, or a target window.",
          ),
        );
      }
      break;
  }

  return issues;
}

function lintGoalCore(goal: GoalLintSubject): PlanLintIssue[] {
  const issues: PlanLintIssue[] = [];

  if (!goal.title.trim()) {
    issues.push(issue(PlanLintIssueCode.MissingTitle, PlanLintSeverity.Error, ["title"], "Goal title is required."));
  }

  issues.push(...lintTiming(goal.timing, ["timing"]));

  if (goal.relationshipKind !== GoalRelationshipKind.Independent && !goal.parentGoalId) {
    issues.push(
      issue(
        PlanLintIssueCode.MissingParentForRelationship,
        PlanLintSeverity.Error,
        ["parentGoalId"],
        "Child, support, and delegated goals require parentGoalId.",
      ),
    );
  }

  if (goal.mode === GoalMode.DelegatedSupport && goal.actor.ownership === ExecutionOwnership.Self) {
    issues.push(
      issue(
        PlanLintIssueCode.InvalidDelegatedOwnership,
        PlanLintSeverity.Warning,
        ["actor", "ownership"],
        "Delegated support goals usually point at a non-self owner.",
      ),
    );
  }

  if (
    goal.progressStrategy.metricKind === ProgressMetricKind.Streak &&
    goal.progressStrategy.rollupMethod !== ProgressRollupMethod.StreakLength
  ) {
    issues.push(
      issue(
        PlanLintIssueCode.InvalidProgressStrategy,
        PlanLintSeverity.Error,
        ["progressStrategy"],
        "Streak metrics must use streak_length rollup.",
      ),
    );
  }

  return issues;
}

export function lintGoalDraft(goal: GoalDraft): PlanLintResult {
  const issues = lintGoalCore(goal as GoalLintSubject);

  return {
    goalId: null,
    planVersion: 0,
    isValid: issues.every((entry) => entry.severity !== PlanLintSeverity.Error),
    issueCount: issues.length,
    issues,
  };
}

export function lintGoalPlan(plan: GoalPlan): PlanLintResult {
  const issues: PlanLintIssue[] = [];
  const sectionIds = new Set<EntityId>();
  const stepIds = new Set<EntityId>();
  const validStepIds = new Set<EntityId>();

  if (plan.sections.length === 0) {
    issues.push(
      issue(
        PlanLintIssueCode.MissingPlanSections,
        PlanLintSeverity.Error,
        ["sections"],
        "Goal plans require at least one section.",
      ),
    );
  }

  for (const section of plan.sections) {
    if (sectionIds.has(section.id)) {
      issues.push(
        issue(
          PlanLintIssueCode.DuplicateSectionId,
          PlanLintSeverity.Error,
          ["sections", section.id],
          "Section identifiers must be unique.",
          section.id,
        ),
      );
    }
    sectionIds.add(section.id);

    for (const step of section.steps) {
      validStepIds.add(step.id);
      if (stepIds.has(step.id)) {
        issues.push(
          issue(
            PlanLintIssueCode.DuplicateStepId,
            PlanLintSeverity.Error,
            ["sections", section.id, "steps", step.id],
            "Step identifiers must be unique.",
            section.id,
            step.id,
          ),
        );
      }
      stepIds.add(step.id);

      if (!step.title.trim()) {
        issues.push(
          issue(
            PlanLintIssueCode.MissingStepTitle,
            PlanLintSeverity.Error,
            ["sections", section.id, "steps", step.id, "title"],
            "Step title is required.",
            section.id,
            step.id,
          ),
        );
      }

      issues.push(...lintTiming(step.timing, ["sections", section.id, "steps", step.id, "timing"]));
    }
  }

  for (const section of plan.sections) {
    for (const step of section.steps) {
      for (const dependencyStepId of step.dependencyStepIds) {
        if (!validStepIds.has(dependencyStepId)) {
          issues.push(
            issue(
              PlanLintIssueCode.InvalidDependency,
              PlanLintSeverity.Error,
              ["sections", section.id, "steps", step.id, "dependencyStepIds"],
              `Dependency step '${dependencyStepId}' was not found in the plan.`,
              section.id,
              step.id,
            ),
          );
        }
      }
    }
  }

  return {
    goalId: plan.goalId,
    planVersion: plan.version,
    isValid: issues.every((entry) => entry.severity !== PlanLintSeverity.Error),
    issueCount: issues.length,
    issues,
  };
}

export function lintGoal(goal: Goal): PlanLintResult {
  const issues = [...lintGoalCore(goal)];

  if (goal.relationshipKind !== GoalRelationshipKind.Independent && !goal.parentGoalId) {
    issues.push(
      issue(
        PlanLintIssueCode.MissingParentForRelationship,
        PlanLintSeverity.Error,
        ["parentGoalId"],
        "Related goals must carry parentGoalId.",
      ),
    );
  }

  if (goal.plan) {
    issues.push(...lintGoalPlan(goal.plan).issues);
  }

  return {
    goalId: goal.id,
    planVersion: goal.plan?.version ?? 0,
    isValid: issues.every((entry) => entry.severity !== PlanLintSeverity.Error),
    issueCount: issues.length,
    issues,
  };
}

export interface GoalContractValidationSuccess<T> {
  ok: true;
  value: T;
  lint: PlanLintResult;
}

export interface GoalContractValidationFailure<T> {
  ok: false;
  value: T;
  lint: PlanLintResult;
}

export type GoalContractValidationResult<T> =
  | GoalContractValidationSuccess<T>
  | GoalContractValidationFailure<T>;

export interface GoalContractDeserializeFailure {
  ok: false;
  value: null;
  issues: string[];
}

export type GoalContractDeserializationResult<T> =
  | GoalContractValidationResult<T>
  | GoalContractDeserializeFailure;

function validationResult<T>(value: T, lint: PlanLintResult): GoalContractValidationResult<T> {
  return lint.isValid ? { ok: true, value, lint } : { ok: false, value, lint };
}

export function validateGoalDraftContract(goal: GoalDraft): GoalContractValidationResult<GoalDraft> {
  return validationResult(goal, lintGoalDraft(goal));
}

export function validateGoalPlanContract(plan: GoalPlan): GoalContractValidationResult<GoalPlan> {
  return validationResult(plan, lintGoalPlan(plan));
}

export function validateGoalContract(goal: Goal): GoalContractValidationResult<Goal> {
  return validationResult(goal, lintGoal(goal));
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function isGoalDraftRecord(value: unknown): value is GoalDraft {
  return (
    isRecord(value) &&
    value.schemaVersion === GOAL_ENGINE_SCHEMA_VERSION &&
    typeof value.title === "string" &&
    typeof value.mode === "string" &&
    isRecord(value.actor) &&
    isRecord(value.timing)
  );
}

function isGoalPlanRecord(value: unknown): value is GoalPlan {
  return (
    isRecord(value) &&
    typeof value.id === "string" &&
    typeof value.goalId === "string" &&
    typeof value.version === "number" &&
    Array.isArray(value.sections)
  );
}

function isGoalRecord(value: unknown): value is Goal {
  return (
    isRecord(value) &&
    value.schemaVersion === GOAL_ENGINE_SCHEMA_VERSION &&
    typeof value.id === "string" &&
    typeof value.title === "string" &&
    typeof value.mode === "string" &&
    isRecord(value.actor) &&
    isRecord(value.timing)
  );
}

function parseSerializedContract(serialized: string): { ok: true; value: unknown } | GoalContractDeserializeFailure {
  try {
    return { ok: true, value: JSON.parse(serialized) };
  } catch (error) {
    return {
      ok: false,
      value: null,
      issues: [error instanceof Error ? error.message : "Failed to parse contract JSON."],
    };
  }
}

export function serializeGoalDraftContract(goal: GoalDraft): string {
  return JSON.stringify(goal, null, 2);
}

export function serializeGoalPlanContract(plan: GoalPlan): string {
  return JSON.stringify(plan, null, 2);
}

export function serializeGoalContract(goal: Goal): string {
  return JSON.stringify(goal, null, 2);
}

export function deserializeGoalDraftContract(serialized: string): GoalContractDeserializationResult<GoalDraft> {
  const parsed = parseSerializedContract(serialized);
  if (!parsed.ok) {
    return parsed;
  }
  if (!isGoalDraftRecord(parsed.value)) {
    return {
      ok: false,
      value: null,
      issues: ["Serialized payload does not match the minimal goal draft contract shape."],
    };
  }
  return validateGoalDraftContract(parsed.value);
}

export function deserializeGoalPlanContract(serialized: string): GoalContractDeserializationResult<GoalPlan> {
  const parsed = parseSerializedContract(serialized);
  if (!parsed.ok) {
    return parsed;
  }
  if (!isGoalPlanRecord(parsed.value)) {
    return {
      ok: false,
      value: null,
      issues: ["Serialized payload does not match the minimal goal plan contract shape."],
    };
  }
  return validateGoalPlanContract(parsed.value);
}

export function deserializeGoalContract(serialized: string): GoalContractDeserializationResult<Goal> {
  const parsed = parseSerializedContract(serialized);
  if (!parsed.ok) {
    return parsed;
  }
  if (!isGoalRecord(parsed.value)) {
    return {
      ok: false,
      value: null,
      issues: ["Serialized payload does not match the minimal goal contract shape."],
    };
  }
  return validateGoalContract(parsed.value);
}
