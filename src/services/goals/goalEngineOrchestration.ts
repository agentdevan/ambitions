import { GoalDraft, GoalPlan, PlanAssumption, PlanLintResult } from "../../domain/models/goalEngine";
import {
  ClarificationQuestion,
  ClassificationResult,
  ClassifiedValue,
  ClarificationSet,
  InferenceMetadata,
  MissingField,
  MissingFieldKey,
  PlanningReadiness,
  UserExecutionRole,
} from "../../domain/models/goalEngineIntake";
import { GoalPlanningBlocker, GoalPlannerInput, GoalPlannerResult } from "../../domain/models/goalEnginePlanner";

export type GoalPlanningStrictness = "strict" | "balanced" | "starter_friendly";
export type GoalSupportScope = "supporting" | "coaching" | "tracking";
export type GoalOrchestrationResultKind =
  | "clarification_required"
  | "planned"
  | "starter_planned"
  | "blocked";

export interface GoalEngineOrchestrationContext {
  actorName?: string | null;
  preferredPlanningStrictness?: GoalPlanningStrictness | null;
  goalOwnerRole?: string | null;
  supportScope?: GoalSupportScope | null;
  deadlineHints?: string[] | null;
  existingGoalReferences?: string[] | null;
  sourceScreen?: string | null;
  sourceFlow?: string | null;
  clarifiedFields?: Partial<Record<MissingFieldKey, string | null>> | null;
  referenceNow?: string | null;
}

export interface GoalEngineOrchestrationInputSnapshot {
  rawInput: string;
  normalizedInput: string;
}

export interface GoalEngineOrchestrationContextSnapshot {
  actorName: string | null;
  preferredPlanningStrictness: GoalPlanningStrictness;
  goalOwnerRole: string | null;
  supportScope: GoalSupportScope | null;
  deadlineHints: string[];
  existingGoalReferences: string[];
  sourceScreen: string | null;
  sourceFlow: string | null;
  clarifiedFields: Partial<Record<MissingFieldKey, string>>;
  referenceNow: string | null;
}

export interface GoalInputContradiction {
  code: "timing_conflict" | "goal_subject_gap";
  reason: string;
  question: ClarificationQuestion;
}

export interface GoalOrchestrationClarification {
  readiness: PlanningReadiness;
  questions: ClarificationQuestion[];
  missingFields: MissingField[];
  contradictions: GoalInputContradiction[];
}

export interface GoalOrchestrationInferenceSnapshot {
  mode: ClassificationResult["mode"];
  tempo: ClassificationResult["tempo"];
  relationshipKind: ClassificationResult["relationshipKind"];
  executionOwnership: ClassificationResult["executionOwnership"];
  userRole: ClassificationResult["userRole"];
  strictDeadlinesAppropriate: ClassificationResult["strictDeadlinesAppropriate"];
  planningStrategyId: ClassificationResult["planningStrategyId"];
  progressStrategyId: ClassificationResult["progressStrategyId"];
  actorDisplayName: string;
  actorRoleLabel: string | null;
  timing: GoalDraft["timing"];
}

export interface GoalOrchestrationPlannerMetadata {
  attempted: boolean;
  resultKind: GoalPlannerResult["kind"] | null;
  blockers: GoalPlanningBlocker[];
  lint: PlanLintResult | null;
}

export interface GoalOrchestrationReasoningMetadata {
  readiness: PlanningReadiness;
  clarificationNeeded: boolean;
  starterPlanSafe: boolean;
  missingFields: MissingField[];
  contradictions: GoalInputContradiction[];
  assumptions: PlanAssumption[];
  inference: Record<
    | "mode"
    | "tempo"
    | "relationshipKind"
    | "executionOwnership"
    | "userRole"
    | "strictDeadlinesAppropriate"
    | "planningStrategyId"
    | "progressStrategyId",
    InferenceMetadata
  >;
}

export interface GoalOrchestrationMetadata {
  input: GoalEngineOrchestrationInputSnapshot;
  context: GoalEngineOrchestrationContextSnapshot;
  inference: GoalOrchestrationInferenceSnapshot;
  clarification: GoalOrchestrationClarification;
  planner: GoalOrchestrationPlannerMetadata;
  reasoning: GoalOrchestrationReasoningMetadata;
}

export interface GoalOrchestrationBaseResult {
  kind: GoalOrchestrationResultKind;
  draft: GoalDraft;
  metadata: GoalOrchestrationMetadata;
}

export interface GoalClarificationRequiredResult extends GoalOrchestrationBaseResult {
  kind: "clarification_required";
  clarification: GoalOrchestrationClarification;
}

export interface GoalPlannedResult extends GoalOrchestrationBaseResult {
  kind: "planned";
  plan: GoalPlan;
  lint: PlanLintResult;
}

export interface GoalStarterPlannedResult extends GoalOrchestrationBaseResult {
  kind: "starter_planned";
  plan: GoalPlan;
  lint: PlanLintResult;
  assumptions: PlanAssumption[];
  clarification: GoalOrchestrationClarification;
}

export interface GoalBlockedResult extends GoalOrchestrationBaseResult {
  kind: "blocked";
  blockers: GoalPlanningBlocker[];
  clarification: GoalOrchestrationClarification | null;
}

export type GoalOrchestrationResult =
  | GoalClarificationRequiredResult
  | GoalPlannedResult
  | GoalStarterPlannedResult
  | GoalBlockedResult;

export interface GoalOrchestrationPreparedInput {
  classification: ClassificationResult;
  clarification: GoalOrchestrationClarification;
  plannerInput: GoalPlannerInput;
}

function normalizeString(value: string | null | undefined): string | null {
  const normalized = value?.trim();
  return normalized ? normalized : null;
}

function normalizeStringList(value: string[] | null | undefined): string[] {
  if (!value) {
    return [];
  }

  return value
    .map((entry) => entry.trim())
    .filter((entry, index, list) => entry.length > 0 && list.indexOf(entry) === index);
}

export function normalizeOrchestrationContext(
  context: GoalEngineOrchestrationContext = {},
): GoalEngineOrchestrationContextSnapshot {
  const clarifiedEntries = Object.entries(context.clarifiedFields ?? {}).flatMap(([field, value]) => {
    const normalized = normalizeString(value);
    return normalized ? [[field as MissingFieldKey, normalized] as const] : [];
  });

  return {
    actorName: normalizeString(context.actorName),
    preferredPlanningStrictness: context.preferredPlanningStrictness ?? "balanced",
    goalOwnerRole: normalizeString(context.goalOwnerRole),
    supportScope: context.supportScope ?? null,
    deadlineHints: normalizeStringList(context.deadlineHints),
    existingGoalReferences: normalizeStringList(context.existingGoalReferences),
    sourceScreen: normalizeString(context.sourceScreen),
    sourceFlow: normalizeString(context.sourceFlow),
    clarifiedFields: Object.fromEntries(clarifiedEntries),
    referenceNow: normalizeString(context.referenceNow),
  };
}

function deriveResolvedFields(context: GoalEngineOrchestrationContextSnapshot): Set<MissingFieldKey> {
  const resolved = new Set<MissingFieldKey>(Object.keys(context.clarifiedFields) as MissingFieldKey[]);
  if (context.supportScope) {
    resolved.add("support_scope");
  }
  return resolved;
}

function recomputeReadiness(missingFields: MissingField[]): PlanningReadiness {
  if (missingFields.some((field) => field.blocksPlanning)) {
    return "needs_clarification";
  }
  if (missingFields.length > 0) {
    return "can_plan_with_defaults";
  }
  return "ready_for_planning";
}

function cloneClassifiedValue<T>(value: ClassifiedValue<T>): ClassifiedValue<T> {
  return {
    value: value.value,
    metadata: { ...value.metadata },
  };
}

export function applyContextToClassification(
  classification: ClassificationResult,
  context: GoalEngineOrchestrationContextSnapshot,
): ClassificationResult {
  const resolvedFields = deriveResolvedFields(context);
  const missingFields = classification.missingFields.filter((field) => !resolvedFields.has(field.field));
  const readiness = recomputeReadiness(missingFields);
  const actorDisplayName = context.actorName ?? classification.draft.actor.displayName;
  const actorRoleLabel =
    context.goalOwnerRole ??
    (context.supportScope
      ? context.supportScope === "coaching"
        ? "Coached owner"
        : context.supportScope === "tracking"
          ? "Tracked owner"
          : classification.draft.actor.roleLabel
      : classification.draft.actor.roleLabel);

  return {
    ...classification,
    mode: cloneClassifiedValue(classification.mode),
    tempo: cloneClassifiedValue(classification.tempo),
    relationshipKind: cloneClassifiedValue(classification.relationshipKind),
    executionOwnership: cloneClassifiedValue(classification.executionOwnership),
    userRole: cloneClassifiedValue(classification.userRole),
    strictDeadlinesAppropriate: cloneClassifiedValue(classification.strictDeadlinesAppropriate),
    planningStrategyId: cloneClassifiedValue(classification.planningStrategyId),
    progressStrategyId: cloneClassifiedValue(classification.progressStrategyId),
    missingFields,
    readiness,
    clarificationNeeded: readiness !== "ready_for_planning",
    starterPlanSafe: readiness !== "needs_clarification",
    draft: {
      ...classification.draft,
      actor: {
        ...classification.draft.actor,
        displayName: actorDisplayName,
        roleLabel: actorRoleLabel,
      },
    },
  };
}

export function detectGoalInputContradictions(
  classification: ClassificationResult,
  context: GoalEngineOrchestrationContextSnapshot,
): GoalInputContradiction[] {
  const lower = classification.normalizedInput.toLowerCase();
  const contradictions: GoalInputContradiction[] = [];
  const mentionsNoDeadlines = /\b(no deadlines|don't want deadlines|dont want deadlines|without deadlines)\b/.test(lower);
  const mentionsSpecificTiming =
    /\b(deadline|due|must|no later than|this week|this month|this quarter|this year|before|by [a-z]+|by \d{4}-\d{2}-\d{2}|next month|this summer|this fall)\b/.test(
      lower,
    ) || context.deadlineHints.length > 0;

  if (mentionsNoDeadlines && mentionsSpecificTiming) {
    contradictions.push({
      code: "timing_conflict",
      reason:
        "The input asks to avoid deadline pressure while also pointing at a concrete date or timing anchor.",
      question: {
        id: "timing-conflict",
        field: "time_horizon",
        prompt:
          "You mentioned both avoiding deadlines and wanting a specific date. Should this stay flexible, or should the date drive planning?",
        rationale:
          "The orchestrator should not pretend it knows whether the date is a soft hint or a real constraint.",
        skipSafeDefault: "No full plan is produced until the timing preference is clarified.",
      },
    });
  }

  if (/\b(i don't know where to start|dont know where to start|where to start)\b/.test(lower)) {
    contradictions.push({
      code: "goal_subject_gap",
      reason:
        "The input signals uncertainty about where to begin, but it does not supply a concrete goal subject the planner can safely decompose.",
      question: {
        id: "goal-subject-gap",
        field: "goal_subject",
        prompt: "What is the actual goal you want help starting?",
        rationale:
          "Starter planning still needs a concrete subject. Uncertainty about the first step is not the same as having a defined goal.",
        skipSafeDefault: "No starter plan is produced until the goal subject is explicit.",
      },
    });
  }

  return contradictions;
}

export function buildOrchestrationClarification(
  clarification: ClarificationSet,
  resolvedFields: Set<MissingFieldKey>,
  contradictions: GoalInputContradiction[],
  readinessOverride?: PlanningReadiness,
): GoalOrchestrationClarification {
  const baseQuestions = clarification.questions.filter((question) => !resolvedFields.has(question.field));
  const baseMissingFields = clarification.missingFields.filter((field) => !resolvedFields.has(field.field));
  const contradictionMissingFields: MissingField[] = contradictions
    .filter((entry) => !baseMissingFields.some((field) => field.field === entry.question.field))
    .map((entry) => ({
      field: entry.question.field,
      reason: entry.reason,
      blocksPlanning: true,
    }));
  const contradictionFields = new Set(contradictions.map((entry) => entry.question.field));
  const questions = [
    ...baseQuestions.filter((question) => !contradictionFields.has(question.field)),
    ...contradictions.map((entry) => entry.question),
  ].slice(0, 3);
  const missingFields = [...baseMissingFields, ...contradictionMissingFields];

  return {
    readiness: readinessOverride ?? recomputeReadiness(missingFields),
    questions,
    missingFields,
    contradictions,
  };
}

export function buildPlannerInputFromClassification(classification: ClassificationResult): GoalPlannerInput {
  const clarification: ClarificationSet = {
    readiness: classification.readiness,
    questions: [],
    missingFields: classification.missingFields,
  };

  return {
    draft: classification.draft,
    classification,
    clarification,
  };
}

export function buildPreparedOrchestrationInput(params: {
  classification: ClassificationResult;
  clarification: ClarificationSet;
  context: GoalEngineOrchestrationContextSnapshot;
}): GoalOrchestrationPreparedInput {
  const classification = applyContextToClassification(params.classification, params.context);
  const contradictions = detectGoalInputContradictions(classification, params.context);
  const resolvedFields = deriveResolvedFields(params.context);
  const readiness =
    contradictions.length > 0 && classification.readiness === "ready_for_planning"
      ? "needs_clarification"
      : classification.readiness;
  const clarification = buildOrchestrationClarification(
    params.clarification,
    resolvedFields,
    contradictions,
    readiness,
  );
  const classificationWithReadiness: ClassificationResult = {
    ...classification,
    readiness: clarification.readiness,
    clarificationNeeded: clarification.readiness !== "ready_for_planning",
    starterPlanSafe: clarification.readiness !== "needs_clarification",
    missingFields: clarification.missingFields,
  };

  return {
    classification: classificationWithReadiness,
    clarification,
    plannerInput: {
      draft: classificationWithReadiness.draft,
      classification: classificationWithReadiness,
      clarification: {
        readiness: clarification.readiness,
        questions: clarification.questions,
        missingFields: clarification.missingFields,
      },
    },
  };
}

export function buildOrchestrationMetadata(params: {
  classification: ClassificationResult;
  clarification: GoalOrchestrationClarification;
  context: GoalEngineOrchestrationContextSnapshot;
  plannerResult?: GoalPlannerResult | null;
}): GoalOrchestrationMetadata {
  const assumptions =
    params.plannerResult?.kind === "starter_plan" ? params.plannerResult.assumptions : [];

  return {
    input: {
      rawInput: params.classification.rawInput,
      normalizedInput: params.classification.normalizedInput,
    },
    context: params.context,
    inference: {
      mode: params.classification.mode,
      tempo: params.classification.tempo,
      relationshipKind: params.classification.relationshipKind,
      executionOwnership: params.classification.executionOwnership,
      userRole: params.classification.userRole as ClassifiedValue<UserExecutionRole>,
      strictDeadlinesAppropriate: params.classification.strictDeadlinesAppropriate,
      planningStrategyId: params.classification.planningStrategyId,
      progressStrategyId: params.classification.progressStrategyId,
      actorDisplayName: params.classification.draft.actor.displayName,
      actorRoleLabel: params.classification.draft.actor.roleLabel,
      timing: params.classification.draft.timing,
    },
    clarification: params.clarification,
    planner: {
      attempted: Boolean(params.plannerResult),
      resultKind: params.plannerResult?.kind ?? null,
      blockers: params.plannerResult?.kind === "blocked" ? params.plannerResult.blockers : [],
      lint:
        params.plannerResult && "lint" in params.plannerResult
          ? params.plannerResult.lint
          : null,
    },
    reasoning: {
      readiness: params.classification.readiness,
      clarificationNeeded: params.classification.clarificationNeeded,
      starterPlanSafe: params.classification.starterPlanSafe,
      missingFields: params.classification.missingFields,
      contradictions: params.clarification.contradictions,
      assumptions,
      inference: {
        mode: params.classification.mode.metadata,
        tempo: params.classification.tempo.metadata,
        relationshipKind: params.classification.relationshipKind.metadata,
        executionOwnership: params.classification.executionOwnership.metadata,
        userRole: params.classification.userRole.metadata,
        strictDeadlinesAppropriate: params.classification.strictDeadlinesAppropriate.metadata,
        planningStrategyId: params.classification.planningStrategyId.metadata,
        progressStrategyId: params.classification.progressStrategyId.metadata,
      },
    },
  };
}
