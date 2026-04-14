import {
  ContractValueSource,
  createContractProvenance,
  createDefaultGoalActor,
  createGoalActorProvenance,
  createGoalContractMetadata,
  createGoalTiming,
  createGoalTimingProvenance,
  EvidenceSource,
  ExecutionOwnership,
  GoalDraft,
  GoalMode,
  GoalRelationshipKind,
  GoalTempo,
  GoalTiming,
  GOAL_ENGINE_SCHEMA_VERSION,
  PlanningStrategy,
  PlanningStrategyKind,
  PlanSectionKind,
  ProgressMetricKind,
  ProgressRollupMethod,
  ProgressStrategy,
  StepType,
  TimingType,
} from "./goalEngine";

export type ClassificationConfidence = "low" | "medium" | "high";
export type IntakePlanningStrategyId =
  | "milestone_plan"
  | "routine_builder"
  | "learning_path"
  | "discovery_map"
  | "stabilization_path"
  | "guided_support"
  | "lightweight_tracking";
export type IntakeProgressStrategyId =
  | "timed_execution"
  | "untimed_growth"
  | "learning"
  | "exploration"
  | "maintenance"
  | "delegated_support"
  | "observational_progress";
export type PlanningReadiness =
  | "ready_for_planning"
  | "needs_clarification"
  | "can_plan_with_defaults";
export type UserExecutionRole = "executor" | "planner_supporter";
export type MissingFieldKey =
  | "goal_subject"
  | "goal_shape"
  | "executor_identity"
  | "support_scope"
  | "success_definition"
  | "time_horizon";

export interface InferenceMetadata {
  source: ContractValueSource;
  inferred: boolean;
  confidence: number;
  label: ClassificationConfidence;
  reason: string;
}

export interface MissingField {
  field: MissingFieldKey;
  reason: string;
  blocksPlanning: boolean;
}

export interface ClarificationQuestion {
  id: string;
  field: MissingFieldKey;
  prompt: string;
  rationale: string;
  skipSafeDefault: string;
}

export interface ClarificationSet {
  readiness: PlanningReadiness;
  questions: ClarificationQuestion[];
  missingFields: MissingField[];
}

export interface ClassifiedValue<T> {
  value: T;
  metadata: InferenceMetadata;
}

export interface ClassificationResult {
  rawInput: string;
  normalizedInput: string;
  title: string;
  summary: string | null;
  mode: ClassifiedValue<GoalMode>;
  tempo: ClassifiedValue<GoalTempo>;
  relationshipKind: ClassifiedValue<GoalRelationshipKind>;
  executionOwnership: ClassifiedValue<ExecutionOwnership>;
  userRole: ClassifiedValue<UserExecutionRole>;
  strictDeadlinesAppropriate: ClassifiedValue<boolean>;
  planningStrategyId: ClassifiedValue<IntakePlanningStrategyId>;
  progressStrategyId: ClassifiedValue<IntakeProgressStrategyId>;
  readiness: PlanningReadiness;
  clarificationNeeded: boolean;
  starterPlanSafe: boolean;
  missingFields: MissingField[];
  tags: string[];
  draft: GoalDraft;
}

export interface DraftBuildResult {
  classification: ClassificationResult;
  clarification: ClarificationSet;
  draft: GoalDraft;
}

interface IntakeSignals {
  lower: string;
  learning: boolean;
  understandHow: boolean;
  exploration: boolean;
  support: boolean;
  delegationOnly: boolean;
  noDeadlines: boolean;
  recurring: boolean;
  flexible: boolean;
  maintenance: boolean;
  recovery: boolean;
  broadHealth: boolean;
  launchProject: boolean;
  achievement: boolean;
  childActor: boolean;
  partnerActor: boolean;
  teamActor: boolean;
  householdActor: boolean;
  observedOnly: boolean;
  explicitDate: boolean;
  hardDeadline: boolean;
  targetWindow: boolean;
  metaPreferenceOnly: boolean;
  ambiguousSubject: boolean;
}

function clampConfidence(value: number): number {
  return Number(Math.min(1, Math.max(0, value)).toFixed(2));
}

function confidenceLabel(value: number): ClassificationConfidence {
  if (value >= 0.8) {
    return "high";
  }
  if (value >= 0.55) {
    return "medium";
  }
  return "low";
}

function createInferenceMetadata(params: {
  source: ContractValueSource;
  inferred: boolean;
  confidence: number;
  reason: string;
}): InferenceMetadata {
  const confidence = clampConfidence(params.confidence);
  return {
    source: params.source,
    inferred: params.inferred,
    confidence,
    label: confidenceLabel(confidence),
    reason: params.reason,
  };
}

function classifiedValue<T>(
  value: T,
  params: { source: ContractValueSource; inferred: boolean; confidence: number; reason: string },
): ClassifiedValue<T> {
  return {
    value,
    metadata: createInferenceMetadata(params),
  };
}

function normalizeInput(rawInput: string): string {
  return rawInput.trim().replace(/\s+/g, " ");
}

function normalizeTitle(rawInput: string): string {
  const normalized = normalizeInput(rawInput)
    .replace(/^i want to\s+/i, "")
    .replace(/^help me\s+/i, "")
    .replace(/^my goal is to\s+/i, "")
    .replace(/^i just want to\s+/i, "");

  if (!normalized) {
    return "New goal";
  }

  const capitalized = normalized.charAt(0).toUpperCase() + normalized.slice(1);
  return capitalized.endsWith(".") ? capitalized.slice(0, -1) : capitalized;
}

function hasAny(text: string, patterns: RegExp[]): boolean {
  return patterns.some((pattern) => pattern.test(text));
}

function analyzeSignals(rawInput: string): IntakeSignals {
  const lower = normalizeInput(rawInput).toLowerCase();
  const learning = hasAny(lower, [/\blearn\b/, /\bpractice\b/, /\bstudy\b/, /\bhow to\b/, /\bunderstand\b/]);
  const understandHow = hasAny(lower, [/\bunderstand how\b/, /\bhow to do\b/, /\bhow this works\b/]);
  const exploration = hasAny(lower, [/\bfigure out if\b/, /\bdecide whether\b/, /\bexplore\b/, /\bsee if\b/]);
  const support = hasAny(lower, [/\bhelp\b/, /\bsupport\b/, /\bfor someone else\b/, /\bfor my\b/]);
  const delegationOnly = hasAny(lower, [/\bbreak this down for someone else\b/, /\bplan this for someone else\b/]);
  const noDeadlines = hasAny(lower, [/\bno deadlines\b/, /\bdon'?t want deadlines\b/, /\bwithout deadlines\b/]);
  const recurring = hasAny(lower, [/\brecurring\b/, /\bdaily\b/, /\bweekly\b/, /\bongoing\b/, /\bevery\b/]);
  const flexible = hasAny(lower, [/\bflexible\b/, /\bnot strict\b/, /\bno rush\b/]);
  const maintenance = hasAny(lower, [/\bmaintain\b/, /\bkeep\b/, /\bstay on top of\b/, /\bkeep current\b/]);
  const recovery = hasAny(lower, [/\brecover\b/, /\bstabilize\b/, /\bfeel better\b/, /\breset\b/]);
  const broadHealth = hasAny(lower, [/\bget healthier\b/, /\bhealthier\b/, /\bsleep better\b/, /\bmore energy\b/]);
  const launchProject = hasAny(lower, [/\blaunch\b/, /\bbuild\b/, /\bship\b/, /\bpublish\b/, /\bstart\b/]);
  const achievement = hasAny(lower, [/\bfinish\b/, /\bcomplete\b/, /\bachieve\b/, /\bimprove\b/, /\bget\b/]);
  const childActor = hasAny(lower, [/\bdaughter\b/, /\bson\b/, /\bchild\b/, /\bkid\b/]);
  const partnerActor = hasAny(lower, [/\bpartner\b/, /\bspouse\b/, /\bhusband\b/, /\bwife\b/]);
  const teamActor = hasAny(lower, [/\bteam\b/, /\bstaff\b/, /\bemployee\b/, /\bcompany\b/]);
  const householdActor = hasAny(lower, [/\bhousehold\b/, /\bfamily\b/, /\bhome\b/]);
  const observedOnly = hasAny(lower, [/\btrack\b/, /\bobserve\b/, /\bkeep tabs\b/]) || delegationOnly;
  const explicitDate = hasAny(lower, [
    /\bthis week\b/,
    /\bthis month\b/,
    /\bthis quarter\b/,
    /\bthis year\b/,
    /\bin \d+ (day|days|week|weeks|month|months)\b/,
    /\bby [a-z]+\b/,
    /\bby \d{4}-\d{2}-\d{2}\b/,
    /\bbefore\b/,
    /\bnext month\b/,
    /\bthis summer\b/,
    /\bthis fall\b/,
  ]);
  const hardDeadline = hasAny(lower, [/\bdeadline\b/, /\bdue\b/, /\bmust\b/, /\bno later than\b/]);
  const targetWindow = explicitDate && !hardDeadline;
  const goalSignalsPresent =
    learning || exploration || support || recurring || maintenance || recovery || broadHealth || launchProject || achievement;
  const metaPreferenceOnly = (noDeadlines || recurring || flexible) && !goalSignalsPresent;
  const ambiguousSubject = hasAny(lower, [/\bdo this\b/, /\bthis\b/, /\bit\b/]) && !launchProject && !learning && !exploration && !broadHealth;

  return {
    lower,
    learning,
    understandHow,
    exploration,
    support,
    delegationOnly,
    noDeadlines,
    recurring,
    flexible,
    maintenance,
    recovery,
    broadHealth,
    launchProject,
    achievement,
    childActor,
    partnerActor,
    teamActor,
    householdActor,
    observedOnly,
    explicitDate,
    hardDeadline,
    targetWindow,
    metaPreferenceOnly,
    ambiguousSubject,
  };
}

function inferOwnership(signals: IntakeSignals): ClassifiedValue<ExecutionOwnership> {
  if (signals.childActor) {
    return classifiedValue(ExecutionOwnership.Child, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.95,
      reason: "Family-language points to a child as the primary executor.",
    });
  }
  if (signals.partnerActor) {
    return classifiedValue(ExecutionOwnership.Partner, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.88,
      reason: "Partner-language suggests the goal work belongs to a partner rather than the app user.",
    });
  }
  if (signals.teamActor) {
    return classifiedValue(ExecutionOwnership.Team, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.87,
      reason: "Team-language implies the work is executed by a group the user supports or coordinates.",
    });
  }
  if (signals.householdActor) {
    return classifiedValue(ExecutionOwnership.Household, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.77,
      reason: "Household language suggests shared execution across a household context.",
    });
  }
  if (signals.observedOnly) {
    return classifiedValue(ExecutionOwnership.ObservedOnly, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.75,
      reason: "The input describes planning or observation for someone else instead of direct execution.",
    });
  }
  return classifiedValue(ExecutionOwnership.Self, {
    source: ContractValueSource.DerivedContract,
    inferred: true,
    confidence: 0.86,
    reason: "No delegated actor was mentioned, so the safest default is self execution.",
  });
}

function inferMode(signals: IntakeSignals, ownership: ExecutionOwnership): ClassifiedValue<GoalMode> {
  if (ownership !== ExecutionOwnership.Self && (signals.support || signals.delegationOnly)) {
    return classifiedValue(GoalMode.DelegatedSupport, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.94,
      reason: "Supporting or planning for another person maps to delegated support mode.",
    });
  }
  if (signals.exploration) {
    return classifiedValue(GoalMode.Exploration, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.92,
      reason: "Exploration language focuses on discovering fit rather than executing a fixed outcome.",
    });
  }
  if (signals.learning || signals.understandHow) {
    return classifiedValue(GoalMode.Learning, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.92,
      reason: "Learning language signals a skill or understanding goal rather than a delivery goal.",
    });
  }
  if (signals.maintenance || signals.recurring) {
    return classifiedValue(GoalMode.Maintenance, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.84,
      reason: "Recurring or upkeep language fits maintenance better than an end-state achievement.",
    });
  }
  if (signals.recovery || signals.broadHealth) {
    return classifiedValue(GoalMode.Recovery, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.72,
      reason: "Broad health-improvement language is safer to treat as stabilization than as a hard achievement.",
    });
  }
  if (signals.launchProject) {
    return classifiedValue(GoalMode.Project, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.88,
      reason: "Launch and build language usually implies a project with coordinated phases.",
    });
  }
  return classifiedValue(GoalMode.Achievement, {
    source: ContractValueSource.DerivedContract,
    inferred: true,
    confidence: 0.63,
    reason: "The input points at a desired outcome but does not strongly indicate another mode.",
  });
}

function inferTempo(signals: IntakeSignals, mode: GoalMode): ClassifiedValue<GoalTempo> {
  if (signals.noDeadlines) {
    return classifiedValue(signals.recurring ? GoalTempo.Ongoing : GoalTempo.Untimed, {
      source: ContractValueSource.DerivedContract,
      inferred: false,
      confidence: 0.97,
      reason: "The user explicitly said deadlines are not wanted, so the draft should stay flexible.",
    });
  }
  if (signals.delegationOnly && !signals.recurring && !signals.explicitDate) {
    return classifiedValue(GoalTempo.Untimed, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.78,
      reason: "Pure delegation requests are safer as untimed until the real executor and horizon are known.",
    });
  }
  if (signals.recurring || signals.flexible || [GoalMode.Maintenance, GoalMode.DelegatedSupport].includes(mode)) {
    return classifiedValue(GoalTempo.Ongoing, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.86,
      reason: "Recurring, flexible, or support-oriented goals are safer as ongoing work.",
    });
  }
  if (signals.hardDeadline) {
    return classifiedValue(GoalTempo.DeadlineBased, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.9,
      reason: "Hard deadline language implies a due date should anchor the plan.",
    });
  }
  if (signals.targetWindow) {
    return classifiedValue(GoalTempo.TargetWindow, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.8,
      reason: "Relative time language suggests a target window, not necessarily a strict deadline.",
    });
  }
  if ([GoalMode.Learning, GoalMode.Exploration, GoalMode.Recovery].includes(mode)) {
    return classifiedValue(GoalTempo.Untimed, {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.82,
      reason: "Learning, exploration, and stabilization work should stay untimed unless the user clearly opts in.",
    });
  }
  return classifiedValue(GoalTempo.Untimed, {
    source: ContractValueSource.DerivedContract,
    inferred: true,
    confidence: 0.64,
    reason: "No reliable timing signal was present, so the intake layer keeps the goal untimed.",
  });
}

function inferRelationship(
  mode: GoalMode,
  ownership: ExecutionOwnership,
  signals: IntakeSignals,
): ClassifiedValue<GoalRelationshipKind> {
  if (mode === GoalMode.DelegatedSupport) {
    return classifiedValue(
      signals.delegationOnly || ownership === ExecutionOwnership.ObservedOnly
        ? GoalRelationshipKind.Delegated
        : GoalRelationshipKind.Support,
      {
        source: ContractValueSource.DerivedContract,
        inferred: true,
        confidence: 0.91,
        reason:
          signals.delegationOnly || ownership === ExecutionOwnership.ObservedOnly
            ? "The input describes planning for someone else more than co-executing with them."
            : "The input describes support around another person's work.",
      },
    );
  }

  return classifiedValue(GoalRelationshipKind.Independent, {
    source: ContractValueSource.DerivedContract,
    inferred: true,
    confidence: 0.9,
    reason: "No parent or support relationship was expressed, so the goal stays independent.",
  });
}

function inferUserRole(
  ownership: ExecutionOwnership,
  relationshipKind: GoalRelationshipKind,
): ClassifiedValue<UserExecutionRole> {
  const plannerSupporter =
    ownership !== ExecutionOwnership.Self || relationshipKind !== GoalRelationshipKind.Independent;

  return classifiedValue(plannerSupporter ? "planner_supporter" : "executor", {
    source: ContractValueSource.DerivedContract,
    inferred: true,
    confidence: plannerSupporter ? 0.92 : 0.88,
    reason: plannerSupporter
      ? "The app user appears to be supporting, coordinating, or observing execution for someone else."
      : "The user appears to be the direct executor of the goal.",
  });
}

function inferStrictDeadlinesAppropriate(
  tempo: GoalTempo,
  mode: GoalMode,
  signals: IntakeSignals,
): ClassifiedValue<boolean> {
  const inappropriate =
    signals.noDeadlines ||
    [GoalMode.Learning, GoalMode.Exploration, GoalMode.Maintenance, GoalMode.DelegatedSupport, GoalMode.Recovery].includes(
      mode,
    ) ||
    [GoalTempo.Ongoing, GoalTempo.Untimed].includes(tempo);

  return classifiedValue(!inappropriate && tempo !== GoalTempo.TargetWindow ? true : false, {
    source: ContractValueSource.DerivedContract,
    inferred: !signals.noDeadlines,
    confidence: inappropriate ? 0.9 : 0.8,
    reason: inappropriate
      ? "The goal reads as flexible, exploratory, supportive, or untimed, so strict deadlines would distort planning."
      : "A more delivery-oriented goal with timing pressure can safely use deadline-shaped planning.",
  });
}

function inferPlanningStrategy(
  mode: GoalMode,
  tempo: GoalTempo,
  userRole: UserExecutionRole,
): ClassifiedValue<IntakePlanningStrategyId> {
  if (userRole === "planner_supporter" || mode === GoalMode.DelegatedSupport) {
    return classifiedValue("guided_support", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.95,
      reason: "Support-oriented goals need planning that avoids taking ownership away from the executor.",
    });
  }
  if (mode === GoalMode.Learning) {
    return classifiedValue("learning_path", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.94,
      reason: "Learning goals benefit from checkpoints, resources, and reflection.",
    });
  }
  if (mode === GoalMode.Exploration) {
    return classifiedValue("discovery_map", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.94,
      reason: "Exploration goals should optimize for experiments and synthesis instead of straight-line execution.",
    });
  }
  if (mode === GoalMode.Maintenance) {
    return classifiedValue("routine_builder", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.9,
      reason: "Maintenance goals are better served by cadence and repeatability than milestone stacks.",
    });
  }
  if (mode === GoalMode.Recovery || (tempo === GoalTempo.Untimed && mode === GoalMode.Achievement)) {
    return classifiedValue("stabilization_path", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.79,
      reason: "Broad or stabilization-oriented goals should start small before formal milestone pressure appears.",
    });
  }
  if (tempo === GoalTempo.Untimed) {
    return classifiedValue("lightweight_tracking", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.73,
      reason: "Untimed delivery goals need light structure until the user supplies a sharper scope or horizon.",
    });
  }
  return classifiedValue("milestone_plan", {
    source: ContractValueSource.DerivedContract,
    inferred: true,
    confidence: 0.9,
    reason: "Project-like goals with timing pressure benefit from milestone-based planning.",
  });
}

function inferProgressStrategy(
  mode: GoalMode,
  userRole: UserExecutionRole,
  tempo: GoalTempo,
): ClassifiedValue<IntakeProgressStrategyId> {
  if (userRole === "planner_supporter" || mode === GoalMode.DelegatedSupport) {
    return classifiedValue("delegated_support", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.95,
      reason: "Support goals should track updates and support actions rather than pretending the user executes the work.",
    });
  }
  if (mode === GoalMode.Learning) {
    return classifiedValue("learning", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.93,
      reason: "Learning progress is better measured by evidence and practice than by completed deliverables.",
    });
  }
  if (mode === GoalMode.Exploration) {
    return classifiedValue("exploration", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.94,
      reason: "Exploration should count experiments and observations instead of fixed step completion alone.",
    });
  }
  if (mode === GoalMode.Maintenance) {
    return classifiedValue("maintenance", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.9,
      reason: "Maintenance progress is best tracked through consistency and repeated upkeep.",
    });
  }
  if (mode === GoalMode.Recovery) {
    return classifiedValue("observational_progress", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.84,
      reason: "Recovery-style goals need observational progress before hard performance metrics.",
    });
  }
  if ([GoalTempo.DeadlineBased, GoalTempo.TargetWindow].includes(tempo)) {
    return classifiedValue("timed_execution", {
      source: ContractValueSource.DerivedContract,
      inferred: true,
      confidence: 0.89,
      reason: "Timed delivery work should track concrete execution against visible steps.",
    });
  }
  return classifiedValue("untimed_growth", {
    source: ContractValueSource.DerivedContract,
    inferred: true,
    confidence: 0.8,
    reason: "Untimed personal growth work should show steady movement without forcing hard deadlines.",
  });
}

function inferMissingFields(
  normalizedInput: string,
  signals: IntakeSignals,
  mode: GoalMode,
  userRole: UserExecutionRole,
): MissingField[] {
  const missing: MissingField[] = [];
  const lower = normalizedInput.toLowerCase();

  if (
    !normalizedInput ||
    signals.metaPreferenceOnly ||
    signals.ambiguousSubject ||
    (signals.understandHow && /\b(this|it)\b/.test(lower))
  ) {
    missing.push({
      field: "goal_subject",
      reason: "The input describes a preference or vague placeholder without a concrete goal subject.",
      blocksPlanning: true,
    });
  }

  if (missing.some((field) => field.field === "goal_subject")) {
    if (userRole === "planner_supporter" && signals.delegationOnly) {
      missing.push({
        field: "executor_identity",
        reason: "A delegated plan should know who is actually executing the work before decomposition starts.",
        blocksPlanning: true,
      });
    }
    return missing;
  }

  if (userRole === "planner_supporter" && signals.delegationOnly) {
    missing.push({
      field: "executor_identity",
      reason: "A delegated plan should know who is actually executing the work before decomposition starts.",
      blocksPlanning: true,
    });
  }

  if (userRole === "planner_supporter" && !signals.delegationOnly) {
    missing.push({
      field: "support_scope",
      reason: "Clarifying whether the user is supporting, coaching, or only observing will improve the language and step types.",
      blocksPlanning: false,
    });
  }

  if ([GoalMode.Project, GoalMode.Achievement, GoalMode.Recovery].includes(mode) && !signals.explicitDate) {
    missing.push({
      field: "success_definition",
      reason: "A clearer first version or success signal will improve decomposition without requiring a deadline.",
      blocksPlanning: false,
    });
  }

  if (mode === GoalMode.Recovery) {
    missing.push({
      field: "goal_shape",
      reason: "Broad stabilization goals benefit from knowing whether the user wants routine-building or a concrete outcome.",
      blocksPlanning: false,
    });
  }

  if ([GoalMode.Project, GoalMode.Achievement].includes(mode) && !signals.explicitDate && !signals.noDeadlines) {
    missing.push({
      field: "time_horizon",
      reason: "A rough horizon helps decide whether the first plan should behave like a sprint, quarter, or open-ended build.",
      blocksPlanning: false,
    });
  }

  return missing;
}

function inferReadiness(missingFields: MissingField[]): PlanningReadiness {
  if (missingFields.some((field) => field.blocksPlanning)) {
    return "needs_clarification";
  }
  if (missingFields.length > 0) {
    return "can_plan_with_defaults";
  }
  return "ready_for_planning";
}

function createPlanningStrategy(id: IntakePlanningStrategyId): PlanningStrategy {
  switch (id) {
    case "routine_builder":
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
    case "learning_path":
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
    case "discovery_map":
      return {
        strategyKind: PlanningStrategyKind.Exploratory,
        allowParallelSteps: true,
        maxActiveSteps: 4,
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
    case "stabilization_path":
      return {
        strategyKind: PlanningStrategyKind.Adaptive,
        allowParallelSteps: false,
        maxActiveSteps: 2,
        preferredSectionOrder: [PlanSectionKind.Overview, PlanSectionKind.ActiveSteps, PlanSectionKind.Review],
        defaultStepType: StepType.ObservationPrompt,
        autoGenerateReviewSection: true,
        preferShortSteps: true,
        revisitCadenceDays: 4,
      };
    case "guided_support":
      return {
        strategyKind: PlanningStrategyKind.Supportive,
        allowParallelSteps: true,
        maxActiveSteps: 3,
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
    case "lightweight_tracking":
      return {
        strategyKind: PlanningStrategyKind.Adaptive,
        allowParallelSteps: true,
        maxActiveSteps: 2,
        preferredSectionOrder: [PlanSectionKind.Overview, PlanSectionKind.ActiveSteps, PlanSectionKind.Review],
        defaultStepType: StepType.ReflectionPrompt,
        autoGenerateReviewSection: true,
        preferShortSteps: true,
        revisitCadenceDays: 7,
      };
    case "milestone_plan":
    default:
      return {
        strategyKind: PlanningStrategyKind.Sequential,
        allowParallelSteps: true,
        maxActiveSteps: 4,
        preferredSectionOrder: [
          PlanSectionKind.Overview,
          PlanSectionKind.ActiveSteps,
          PlanSectionKind.Upcoming,
          PlanSectionKind.Review,
        ],
        defaultStepType: StepType.ActionUnit,
        autoGenerateReviewSection: true,
        preferShortSteps: false,
        revisitCadenceDays: 7,
      };
  }
}

function createProgressStrategy(id: IntakeProgressStrategyId): ProgressStrategy {
  switch (id) {
    case "learning":
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
    case "exploration":
      return {
        metricKind: ProgressMetricKind.ObservationLog,
        rollupMethod: ProgressRollupMethod.Sum,
        targetStepCount: 4,
        targetEvidenceCount: 5,
        targetMinutes: null,
        supportsUntimedProgress: true,
        countsChildGoals: false,
        countsSupportGoals: false,
      };
    case "maintenance":
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
    case "delegated_support":
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
    case "observational_progress":
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
    case "timed_execution":
      return {
        metricKind: ProgressMetricKind.StepCompletion,
        rollupMethod: ProgressRollupMethod.Ratio,
        targetStepCount: 5,
        targetEvidenceCount: null,
        targetMinutes: 300,
        supportsUntimedProgress: false,
        countsChildGoals: true,
        countsSupportGoals: true,
      };
    case "untimed_growth":
    default:
      return {
        metricKind: ProgressMetricKind.TimeInvested,
        rollupMethod: ProgressRollupMethod.Ratio,
        targetStepCount: 4,
        targetEvidenceCount: null,
        targetMinutes: 240,
        supportsUntimedProgress: true,
        countsChildGoals: false,
        countsSupportGoals: false,
      };
  }
}

function defaultDisplayNameForOwnership(ownership: ExecutionOwnership): string {
  switch (ownership) {
    case ExecutionOwnership.Child:
      return "Child";
    case ExecutionOwnership.Partner:
      return "Partner";
    case ExecutionOwnership.Team:
      return "Team";
    case ExecutionOwnership.Household:
      return "Household";
    case ExecutionOwnership.ObservedOnly:
      return "Observed owner";
    case ExecutionOwnership.Self:
    default:
      return "You";
  }
}

function createActor(
  ownership: ClassifiedValue<ExecutionOwnership>,
  userRole: UserExecutionRole,
  relationshipKind: GoalRelationshipKind,
) {
  const actor = createDefaultGoalActor(ownership.value, defaultDisplayNameForOwnership(ownership.value));
  return {
    ...actor,
    roleLabel:
      userRole === "planner_supporter"
        ? relationshipKind === GoalRelationshipKind.Support
          ? "Supported person"
          : "Delegated executor"
        : actor.roleLabel,
    provenance: createGoalActorProvenance({
      ownership: createContractProvenance({
        source: ownership.metadata.source,
        inferred: ownership.metadata.inferred,
        confidence: ownership.metadata.confidence,
        reason: ownership.metadata.reason,
      }),
      displayName: createContractProvenance({
        source: ContractValueSource.DerivedContract,
        inferred: true,
        confidence: ownership.value === ExecutionOwnership.Self ? 0.95 : 0.78,
        reason:
          ownership.value === ExecutionOwnership.Self
            ? "The default display name 'You' is safe when the user is the executor."
            : "A neutral non-self display name avoids misleading self-execution language in support flows.",
      }),
    }),
  };
}

function createTiming(
  tempo: ClassifiedValue<GoalTempo>,
  planningStrategyId: IntakePlanningStrategyId,
): GoalTiming {
  const cadenceDays = planningStrategyId === "discovery_map" ? 5 : planningStrategyId === "routine_builder" ? 7 : 7;
  const timingType =
    tempo.value === GoalTempo.DeadlineBased
      ? TimingType.DueAt
      : tempo.value === GoalTempo.TargetWindow
        ? TimingType.TargetBy
        : tempo.value === GoalTempo.Ongoing
          ? TimingType.RepeatWithinWindow
          : TimingType.LogWhenDone;

  return createGoalTiming({
    tempo: tempo.value,
    timingType,
    repeatEveryDays: tempo.value === GoalTempo.Ongoing ? 7 : null,
    progressReviewCadenceDays: cadenceDays,
    provenance: createGoalTimingProvenance({
      tempo: createContractProvenance({
        source: tempo.metadata.source,
        inferred: tempo.metadata.inferred,
        confidence: tempo.metadata.confidence,
        reason: tempo.metadata.reason,
      }),
      timingType: createContractProvenance({
        source: ContractValueSource.DerivedContract,
        inferred: true,
        confidence: 0.9,
        reason: "The intake layer maps tempo directly to the safest matching timing contract.",
      }),
      repeatEveryDays:
        tempo.value === GoalTempo.Ongoing
          ? createContractProvenance({
              source: ContractValueSource.DefaultStrategy,
              inferred: true,
              confidence: 0.62,
              reason: "Ongoing starter drafts use a weekly repeat cadence until the user chooses a tighter rhythm.",
            })
          : null,
      progressReviewCadenceDays: createContractProvenance({
        source: ContractValueSource.DefaultStrategy,
        inferred: true,
        confidence: 0.76,
        reason: "Starter drafts default review cadence from the selected planning strategy.",
      }),
    }),
  });
}

function buildTags(
  mode: GoalMode,
  planningStrategyId: IntakePlanningStrategyId,
  progressStrategyId: IntakeProgressStrategyId,
  readiness: PlanningReadiness,
): string[] {
  return [mode, planningStrategyId, progressStrategyId, readiness];
}

export class IntakeClassificationService {
  classify(rawInput: string): ClassificationResult {
    const normalizedInput = normalizeInput(rawInput);
    const signals = analyzeSignals(normalizedInput);
    const ownership = inferOwnership(signals);
    const mode = inferMode(signals, ownership.value);
    const tempo = inferTempo(signals, mode.value);
    const relationshipKind = inferRelationship(mode.value, ownership.value, signals);
    const userRole = inferUserRole(ownership.value, relationshipKind.value);
    const strictDeadlinesAppropriate = inferStrictDeadlinesAppropriate(tempo.value, mode.value, signals);
    const planningStrategyId = inferPlanningStrategy(mode.value, tempo.value, userRole.value);
    const progressStrategyId = inferProgressStrategy(mode.value, userRole.value, tempo.value);
    const missingFields = inferMissingFields(normalizedInput, signals, mode.value, userRole.value);
    const readiness = inferReadiness(missingFields);
    const actor = createActor(ownership, userRole.value, relationshipKind.value);
    const timing = createTiming(tempo, planningStrategyId.value);
    const draft: GoalDraft = {
      schemaVersion: GOAL_ENGINE_SCHEMA_VERSION,
      source: EvidenceSource.AiSuggested,
      title: normalizeTitle(normalizedInput),
      summary: normalizedInput.length > 24 ? normalizedInput : null,
      mode: mode.value,
      relationshipKind: relationshipKind.value,
      actor,
      parentGoalId: null,
      tags: buildTags(mode.value, planningStrategyId.value, progressStrategyId.value, readiness),
      timing,
      planningStrategy: createPlanningStrategy(planningStrategyId.value),
      progressStrategy: createProgressStrategy(progressStrategyId.value),
      contract: createGoalContractMetadata({
        mode: createContractProvenance({
          source: mode.metadata.source,
          inferred: mode.metadata.inferred,
          confidence: mode.metadata.confidence,
          reason: mode.metadata.reason,
        }),
        relationshipKind: createContractProvenance({
          source: relationshipKind.metadata.source,
          inferred: relationshipKind.metadata.inferred,
          confidence: relationshipKind.metadata.confidence,
          reason: relationshipKind.metadata.reason,
        }),
        actor: actor.provenance ?? null,
        timing: timing.provenance ?? null,
      }),
    };

    return {
      rawInput,
      normalizedInput,
      title: draft.title,
      summary: draft.summary,
      mode,
      tempo,
      relationshipKind,
      executionOwnership: ownership,
      userRole,
      strictDeadlinesAppropriate,
      planningStrategyId,
      progressStrategyId,
      readiness,
      clarificationNeeded: readiness !== "ready_for_planning",
      starterPlanSafe: readiness !== "needs_clarification",
      missingFields,
      tags: draft.tags,
      draft,
    };
  }
}

export class ClarificationQuestionGenerator {
  generate(result: ClassificationResult): ClarificationSet {
    const questions: ClarificationQuestion[] = [];

    for (const missing of result.missingFields) {
      if (questions.length >= 3) {
        break;
      }

      switch (missing.field) {
        case "goal_subject":
          questions.push({
            id: "goal-subject",
            field: "goal_subject",
            prompt: "What is the actual goal or thing you want planned?",
            rationale: "The system cannot safely decompose a preference-only or placeholder input.",
            skipSafeDefault: "No starter plan is created until the subject is clarified.",
          });
          break;
        case "executor_identity":
          questions.push({
            id: "executor-identity",
            field: "executor_identity",
            prompt: "Who is actually doing the work this plan is for?",
            rationale: "Delegated plans should not use self-execution language when the executor is someone else.",
            skipSafeDefault: "The draft stays in support mode and waits for clarification before decomposition.",
          });
          break;
        case "support_scope":
          questions.push({
            id: "support-scope",
            field: "support_scope",
            prompt: "Are you supporting the person, coaching them, or mostly tracking progress for them?",
            rationale: "That choice changes step language and what counts as progress.",
            skipSafeDefault: "The starter plan assumes a light support role with check-ins and resource support.",
          });
          break;
        case "success_definition":
          questions.push({
            id: "success-definition",
            field: "success_definition",
            prompt: "What would count as a good first version of this goal?",
            rationale: "A first-success definition sharpens decomposition without forcing a deadline.",
            skipSafeDefault: "The starter plan stays broad and uses a minimal first milestone.",
          });
          break;
        case "goal_shape":
          questions.push({
            id: "goal-shape",
            field: "goal_shape",
            prompt: "Should this be treated as a routine to stabilize, or as a result you want to reach?",
            rationale: "Broad stabilization goals can otherwise get over-structured too early.",
            skipSafeDefault: "The starter draft stays stabilization-oriented and avoids strict deadlines.",
          });
          break;
        case "time_horizon":
          questions.push({
            id: "time-horizon",
            field: "time_horizon",
            prompt: "Do you want a rough horizon for this, or should the first plan stay untimed?",
            rationale: "A horizon improves sequencing, but only if the user actually wants it.",
            skipSafeDefault: "The starter draft stays untimed and uses lightweight sequencing.",
          });
          break;
      }
    }

    return {
      readiness: result.readiness,
      questions,
      missingFields: result.missingFields,
    };
  }
}

export function buildGoalDraftFromIntake(rawInput: string): DraftBuildResult {
  const classification = new IntakeClassificationService().classify(rawInput);
  const clarification = new ClarificationQuestionGenerator().generate(classification);

  return {
    classification,
    clarification,
    draft: classification.draft,
  };
}
