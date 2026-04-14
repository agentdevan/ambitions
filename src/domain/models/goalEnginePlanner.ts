import {
  createDefaultGoalActor,
  createGoalTiming,
  EvidenceSource,
  ExecutionOwnership,
  GoalDraft,
  GoalMode,
  GoalPlan,
  GoalRelationshipKind,
  GoalTempo,
  GoalTiming,
  GOAL_ENGINE_PLAN_VERSION,
  GOAL_ENGINE_SCHEMA_VERSION,
  PlanAssumption,
  PlanSection,
  PlanSectionKind,
  PlanLintResult,
  PlanningStrategyKind,
  ProgressMetricKind,
  ProgressRollupMethod,
  Step,
  StepActionability,
  StepLifecycleState,
  StepType,
  TimingType,
} from "./goalEngine";
import {
  ClarificationSet,
  ClassificationResult,
  DraftBuildResult,
  MissingField,
} from "./goalEngineIntake";
import { PlanLinter } from "./goalEnginePlannerLinter";
import { StepRewriter } from "./goalEngineStepRewriter";

type PlannerStrategyId =
  | "milestone_plan"
  | "routine_builder"
  | "learning_path"
  | "discovery_map"
  | "stabilization_path"
  | "guided_support"
  | "lightweight_tracking";

interface PlannerStepDraft {
  title: string;
  summary?: string | null;
  type: StepType;
  timingType: TimingType;
  actionability: StepActionability;
  successSignals?: string[];
  isOptional?: boolean;
  isRepeatable?: boolean;
  repeatEveryDays?: number | null;
  dependencyStepIds?: string[];
  dueAt?: string | null;
  targetBy?: string | null;
  suggestedNextAt?: string | null;
  owner?: Step["owner"];
}

interface PlannerSectionDraft {
  title: string;
  summary: string;
  kind: PlanSectionKind;
  steps: PlannerStepDraft[];
}

export interface GoalPlannerInput {
  draft: GoalDraft;
  classification?: ClassificationResult | null;
  clarification?: ClarificationSet | null;
}

export interface GoalPlanningBlocker {
  code: string;
  reason: string;
  suggestedQuestion: string | null;
}

export interface GoalPlannerSuccessResult {
  kind: "plan";
  draft: GoalDraft;
  plan: GoalPlan;
  lint: PlanLintResult;
}

export interface GoalPlannerStarterResult {
  kind: "starter_plan";
  draft: GoalDraft;
  plan: GoalPlan;
  lint: PlanLintResult;
  assumptions: PlanAssumption[];
}

export interface GoalPlannerBlockedResult {
  kind: "blocked";
  draft: GoalDraft;
  blockers: GoalPlanningBlocker[];
  clarification: ClarificationSet | null;
}

export type GoalPlannerResult =
  | GoalPlannerSuccessResult
  | GoalPlannerStarterResult
  | GoalPlannerBlockedResult;

export interface GoalPlannerOptions {
  goalId?: string;
  now?: string;
}

function asPlannerInput(input: GoalPlannerInput | DraftBuildResult | GoalDraft): GoalPlannerInput {
  if ("classification" in input && "clarification" in input && "draft" in input) {
    return {
      draft: input.draft,
      classification: input.classification,
      clarification: input.clarification,
    };
  }

  if ("schemaVersion" in input) {
    return { draft: input };
  }

  return input;
}

function plannerStrategyIdForDraft(draft: GoalDraft, classification?: ClassificationResult | null): PlannerStrategyId {
  const tagged = draft.tags.find((tag): tag is PlannerStrategyId =>
    [
      "milestone_plan",
      "routine_builder",
      "learning_path",
      "discovery_map",
      "stabilization_path",
      "guided_support",
      "lightweight_tracking",
    ].includes(tag),
  );

  if (tagged) {
    return tagged;
  }

  if (classification?.planningStrategyId.value) {
    return classification.planningStrategyId.value;
  }

  switch (draft.mode) {
    case GoalMode.Habit:
    case GoalMode.Maintenance:
      return "routine_builder";
    case GoalMode.Learning:
      return "learning_path";
    case GoalMode.Exploration:
      return "discovery_map";
    case GoalMode.Recovery:
      return "stabilization_path";
    case GoalMode.DelegatedSupport:
      return "guided_support";
    case GoalMode.Achievement:
    case GoalMode.Project:
      return draft.timing.tempo === GoalTempo.Untimed ? "lightweight_tracking" : "milestone_plan";
    default:
      return "lightweight_tracking";
  }
}

function normalizeSubject(draft: GoalDraft): string {
  return (draft.summary ?? draft.title).replace(/\.$/, "");
}

function toDateOnly(dateTime: string): string {
  return dateTime.slice(0, 10);
}

function shiftDate(dateString: string, offsetDays: number): string {
  const date = new Date(`${dateString}T12:00:00.000Z`);
  date.setUTCDate(date.getUTCDate() + offsetDays);
  return date.toISOString().slice(0, 10);
}

function shiftDateTime(dateTime: string, offsetDays: number): string {
  const date = new Date(dateTime);
  date.setUTCDate(date.getUTCDate() + offsetDays);
  return date.toISOString();
}

function createAssumption(missing: MissingField): PlanAssumption {
  const defaults: Record<string, { summary: string; rationale: string }> = {
    support_scope: {
      summary: "Assume a light support role rather than taking over execution.",
      rationale: "This keeps support plans helpful without stripping agency from the real executor.",
    },
    success_definition: {
      summary: "Assume the first useful version should stay small and demonstrable.",
      rationale: "Starter planning needs a concrete win signal even when the user has not defined a full finish line.",
    },
    time_horizon: {
      summary: "Keep timing light until the user chooses a horizon.",
      rationale: "The planner should not invent deadline pressure where the user has not asked for it.",
    },
    goal_shape: {
      summary: "Assume stabilization and consistency come before expansion.",
      rationale: "Broad recovery and maintenance goals are safer when sequenced around stability first.",
    },
  };

  const fallback = defaults[missing.field] ?? {
    summary: `Assume a safe default for ${missing.field.replace(/_/g, " ")}.`,
    rationale: missing.reason,
  };

  return {
    id: `assumption-${missing.field}`,
    summary: fallback.summary,
    rationale: fallback.rationale,
    confidence: missing.blocksPlanning ? "low" : "medium",
    relatedField: missing.field,
  };
}

function makeActionability(params: {
  action: string;
  completionDefinition: string;
  evidenceOfCompletion: string[];
  fallbackMicroStep: string;
  contextRequirements?: string[];
}): StepActionability {
  return {
    action: params.action,
    completionDefinition: params.completionDefinition,
    evidenceOfCompletion: params.evidenceOfCompletion,
    fallbackMicroStep: params.fallbackMicroStep,
    contextRequirements: params.contextRequirements ?? [],
  };
}

function resolveStepTiming(draft: GoalDraft, candidate: PlannerStepDraft, now: string): GoalTiming {
  switch (candidate.timingType) {
    case TimingType.DueAt:
      if (candidate.dueAt ?? draft.timing.dueAt) {
        return createGoalTiming({
          tempo: GoalTempo.DeadlineBased,
          timingType: TimingType.DueAt,
          dueAt: candidate.dueAt ?? draft.timing.dueAt,
          progressReviewCadenceDays: draft.timing.progressReviewCadenceDays,
        });
      }
      break;
    case TimingType.TargetBy:
      if (candidate.targetBy ?? draft.timing.targetBy ?? draft.timing.windowEnd ?? (draft.timing.dueAt ? toDateOnly(draft.timing.dueAt) : null)) {
        return createGoalTiming({
          tempo: GoalTempo.TargetWindow,
          timingType: TimingType.TargetBy,
          targetBy:
            candidate.targetBy ??
            draft.timing.targetBy ??
            draft.timing.windowEnd ??
            (draft.timing.dueAt ? toDateOnly(draft.timing.dueAt) : null),
          progressReviewCadenceDays: draft.timing.progressReviewCadenceDays,
        });
      }
      break;
    case TimingType.RepeatWithinWindow:
      return createGoalTiming({
        tempo: GoalTempo.Ongoing,
        timingType: TimingType.RepeatWithinWindow,
        repeatEveryDays: candidate.repeatEveryDays ?? draft.timing.repeatEveryDays ?? 7,
        progressReviewCadenceDays: draft.timing.progressReviewCadenceDays,
      });
    case TimingType.LogWhenDone:
      return createGoalTiming({
        tempo: GoalTempo.Untimed,
        timingType: TimingType.LogWhenDone,
        progressReviewCadenceDays: draft.timing.progressReviewCadenceDays,
      });
    case TimingType.SuggestedNext:
    default:
      return createGoalTiming({
        tempo: draft.timing.tempo === GoalTempo.Ongoing ? GoalTempo.Ongoing : GoalTempo.Untimed,
        timingType: TimingType.SuggestedNext,
        suggestedNextAt: candidate.suggestedNextAt ?? draft.timing.suggestedNextAt ?? now,
        progressReviewCadenceDays: draft.timing.progressReviewCadenceDays,
      });
  }

  // If the draft does not actually carry a concrete date, fall back to a
  // suggestion instead of inventing precision the user never supplied.
  return createGoalTiming({
    tempo: draft.timing.tempo === GoalTempo.Ongoing ? GoalTempo.Ongoing : GoalTempo.Untimed,
    timingType: TimingType.SuggestedNext,
    suggestedNextAt: candidate.suggestedNextAt ?? draft.timing.suggestedNextAt ?? now,
    progressReviewCadenceDays: draft.timing.progressReviewCadenceDays,
  });
}

function buildStep(
  draft: GoalDraft,
  sectionId: string,
  index: number,
  candidate: PlannerStepDraft,
  now: string,
): Step {
  return {
    id: `${sectionId}-step-${index + 1}`,
    sectionId,
    title: candidate.title,
    summary: candidate.summary ?? null,
    type: candidate.type,
    state: StepLifecycleState.Planned,
    owner: candidate.owner ?? draft.actor,
    timing: resolveStepTiming(draft, candidate, now),
    dependencyStepIds: candidate.dependencyStepIds ?? [],
    isOptional: candidate.isOptional ?? false,
    isRepeatable: candidate.isRepeatable ?? false,
    evidenceRequired: true,
    successSignals: candidate.successSignals ?? [candidate.actionability.completionDefinition],
    actionability: candidate.actionability,
    contract: null,
  };
}

function buildSection(
  draft: GoalDraft,
  goalId: string,
  orderIndex: number,
  definition: PlannerSectionDraft,
  now: string,
): PlanSection {
  const sectionId = `${goalId}-section-${definition.kind}-${orderIndex + 1}`;
  return {
    id: sectionId,
    goalId,
    title: definition.title,
    summary: definition.summary,
    kind: definition.kind,
    orderIndex,
    steps: definition.steps.map((candidate, index) => buildStep(draft, sectionId, index, candidate, now)),
  };
}

function safeDueAnchors(draft: GoalDraft): { early: string | null; mid: string | null; final: string | null } {
  if (draft.timing.dueAt) {
    const dueDate = toDateOnly(draft.timing.dueAt);
    return {
      early: shiftDate(dueDate, -21),
      mid: shiftDate(dueDate, -10),
      final: dueDate,
    };
  }

  const target = draft.timing.targetBy ?? draft.timing.windowEnd ?? null;
  if (target) {
    return {
      early: shiftDate(target, -14),
      mid: shiftDate(target, -5),
      final: target,
    };
  }

  return { early: null, mid: null, final: null };
}

function milestonePlanSections(draft: GoalDraft, now: string): PlannerSectionDraft[] {
  const subject = normalizeSubject(draft);
  const anchors = safeDueAnchors(draft);
  return [
    {
      title: "Milestones",
      summary: "Checkpoint definitions keep achievement work concrete without turning every step into a giant project.",
      kind: PlanSectionKind.Overview,
      steps: [
        {
          title: "Define the first visible milestone",
          summary: "Name the first milestone in a way that lets you tell whether it is reached.",
          type: StepType.ActionUnit,
          timingType: anchors.early ? TimingType.TargetBy : TimingType.SuggestedNext,
          targetBy: anchors.early,
          actionability: makeActionability({
            action: `Write one sentence that defines the first visible milestone for ${subject.toLowerCase()}.`,
            completionDefinition: "You have a milestone sentence and a short checklist of what must be true for it to count.",
            evidenceOfCompletion: ["A saved checklist or note names the milestone and its signs."],
            fallbackMicroStep: "Write the milestone name only, then add one sign that would prove it is reached.",
          }),
        },
        {
          title: "Check what 'ready to finish' will look like",
          summary: "This prevents late-stage thrash by defining the finish standard before the last sprint.",
          type: StepType.ActionUnit,
          timingType: anchors.mid ? TimingType.TargetBy : TimingType.SuggestedNext,
          targetBy: anchors.mid,
          actionability: makeActionability({
            action: "List the three signs that would make the goal feel ready to finish rather than merely started.",
            completionDefinition: "Three finish signs are written in concrete language.",
            evidenceOfCompletion: ["A short finish-sign list exists and can be reviewed later."],
            fallbackMicroStep: "Write one finish sign and leave the other two for the next session.",
          }),
        },
      ],
    },
    {
      title: "Workstreams",
      summary: "Keep the work separated into a few streams so next actions stay visible.",
      kind: PlanSectionKind.SupportingWork,
      steps: [
        {
          title: "Name the current workstream",
          summary: "Choose the one stream that deserves attention before anything else.",
          type: StepType.ActionUnit,
          timingType: TimingType.SuggestedNext,
          suggestedNextAt: now,
          actionability: makeActionability({
            action: `Pick the single workstream that most directly advances ${subject.toLowerCase()} right now.`,
            completionDefinition: "One active workstream is named and the others are explicitly deferred.",
            evidenceOfCompletion: ["A short list shows the active workstream and what is parked."],
            fallbackMicroStep: "Write the active workstream name only.",
          }),
        },
        {
          title: "List blockers for the active workstream",
          summary: "A small blocker list keeps the next action real instead of optimistic.",
          type: StepType.ActionUnit,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: "Write down the one blocker, dependency, or open decision most likely to slow the active workstream.",
            completionDefinition: "At least one blocker is named in specific terms and paired with a next move.",
            evidenceOfCompletion: ["A blocker note pairs the blocker with a response or owner."],
            fallbackMicroStep: "Capture one blocker without solving it yet.",
          }),
        },
      ],
    },
    {
      title: "Next Steps",
      summary: "These are the session-sized actions that move the chosen workstream immediately.",
      kind: PlanSectionKind.ActiveSteps,
      steps: [
        {
          title: "Complete one session-sized build slice",
          summary: "Advance the workstream with one bounded unit rather than a vague push.",
          type: StepType.ActionUnit,
          timingType: TimingType.SuggestedNext,
          suggestedNextAt: now,
          actionability: makeActionability({
            action: `Complete one bounded slice of the active workstream for ${subject.toLowerCase()}.`,
            completionDefinition: "One visible slice is finished and can be shown or described in a sentence.",
            evidenceOfCompletion: ["A changed artifact, checklist mark, or progress note shows the slice is done."],
            fallbackMicroStep: "Set up the file, tool, or materials needed for the slice and stop there if time is low.",
            contextRequirements: ["Only gather materials if they are required to start the slice."],
          }),
        },
        {
          title: "Capture the next handoff or follow-up",
          summary: "Closing the loop prevents progress from getting lost between sessions.",
          type: StepType.ReflectionPrompt,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: "After the build slice, write the exact next thing that should happen before the next session ends.",
            completionDefinition: "There is one explicit follow-up action written in plain language.",
            evidenceOfCompletion: ["A follow-up note exists next to the completed slice."],
            fallbackMicroStep: "Write a single next-action sentence.",
          }),
        },
      ],
    },
  ];
}

function routineBuilderSections(draft: GoalDraft, now: string): PlannerSectionDraft[] {
  const subject = normalizeSubject(draft);
  const repeatEveryDays = draft.timing.repeatEveryDays ?? 1;
  return [
    {
      title: "Cue",
      summary: "Attach the routine to a cue so it starts without negotiation.",
      kind: PlanSectionKind.Overview,
      steps: [
        {
          title: "Choose the cue that starts the routine",
          type: StepType.ActionUnit,
          timingType: TimingType.SuggestedNext,
          suggestedNextAt: now,
          actionability: makeActionability({
            action: `Name the existing cue that should trigger ${subject.toLowerCase()}.`,
            completionDefinition: "One cue is chosen and written in concrete everyday language.",
            evidenceOfCompletion: ["A note pairs the cue with the routine start."],
            fallbackMicroStep: "Write the cue only.",
          }),
        },
      ],
    },
    {
      title: "Routine",
      summary: "The main routine should be repeatable without needing ideal conditions.",
      kind: PlanSectionKind.ActiveSteps,
      steps: [
        {
          title: "Run the standard version once",
          type: StepType.RecurringRoutine,
          timingType: TimingType.RepeatWithinWindow,
          repeatEveryDays,
          isRepeatable: true,
          actionability: makeActionability({
            action: `Complete the standard version of ${subject.toLowerCase()} once after the chosen cue.`,
            completionDefinition: "The routine is completed in full one time using the chosen cue.",
            evidenceOfCompletion: ["A log entry notes that the standard version was completed."],
            fallbackMicroStep: "Do the first two minutes of the routine and log that the minimum version happened.",
          }),
        },
      ],
    },
    {
      title: "Minimum Version",
      summary: "The minimum version keeps the goal alive on low-energy days.",
      kind: PlanSectionKind.SupportingWork,
      steps: [
        {
          title: "Write the minimum viable version",
          type: StepType.ActionUnit,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: "Define the smallest acceptable version that still counts when time or energy is low.",
            completionDefinition: "A single minimum version is written in a way that can be done quickly.",
            evidenceOfCompletion: ["A short fallback script or checklist names the minimum version."],
            fallbackMicroStep: "Write the minimum version as one sentence.",
          }),
        },
      ],
    },
    {
      title: "Recovery Logic",
      summary: "Recovery logic matters more than perfection because streaks break.",
      kind: PlanSectionKind.Review,
      steps: [
        {
          title: "Decide how to restart after a miss",
          type: StepType.ReflectionPrompt,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: "Write the reset rule for the next day after the routine is missed.",
            completionDefinition: "There is one clear reset rule that says how the routine resumes without punishment.",
            evidenceOfCompletion: ["A recovery note exists and uses non-judgmental language."],
            fallbackMicroStep: "Write the first sentence of the reset rule only.",
          }),
        },
      ],
    },
  ];
}

function learningPathSections(draft: GoalDraft, now: string): PlannerSectionDraft[] {
  const subject = normalizeSubject(draft);
  return [
    {
      title: "Skill Map",
      summary: "Break the learning goal into a small map so practice has direction.",
      kind: PlanSectionKind.Overview,
      steps: [
        {
          title: "List the next three sub-skills",
          type: StepType.LearningCheckpoint,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: `Write the next three sub-skills that would make ${subject.toLowerCase()} feel meaningfully stronger.`,
            completionDefinition: "Three sub-skills are listed in plain language and ordered from foundational to advanced.",
            evidenceOfCompletion: ["A sub-skill list exists and the first one is marked as current."],
            fallbackMicroStep: "Write the first sub-skill only.",
          }),
        },
      ],
    },
    {
      title: "Practice Sessions",
      summary: "Practice should be active enough to generate evidence, not just passive exposure.",
      kind: PlanSectionKind.ActiveSteps,
      steps: [
        {
          title: "Run one focused practice session",
          type: StepType.LearningCheckpoint,
          timingType: TimingType.SuggestedNext,
          suggestedNextAt: now,
          actionability: makeActionability({
            action: "Complete one focused practice session centered on the current sub-skill.",
            completionDefinition: "One practice session is completed and tied to a single sub-skill.",
            evidenceOfCompletion: ["A short practice note says what was practiced and for how long."],
            fallbackMicroStep: "Spend ten focused minutes on the current sub-skill and log one example.",
          }),
        },
        {
          title: "Produce one proof-of-understanding example",
          type: StepType.ReflectionPrompt,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: "Create one explanation, example, or demonstration that proves you understood the session.",
            completionDefinition: "There is one concrete artifact that would let someone else inspect your understanding.",
            evidenceOfCompletion: ["A recording, note, worked example, or explanation exists."],
            fallbackMicroStep: "Write two sentences that explain the sub-skill in your own words.",
          }),
        },
      ],
    },
    {
      title: "Checkpoints",
      summary: "Checkpoint language should emphasize evidence of understanding rather than vague effort.",
      kind: PlanSectionKind.Review,
      steps: [
        {
          title: "Review what still feels shaky",
          type: StepType.ReflectionPrompt,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: "After practice, write the part that still feels unclear and the next question it creates.",
            completionDefinition: "One confusion point and one follow-up question are captured.",
            evidenceOfCompletion: ["A checkpoint note records the confusion point and next question."],
            fallbackMicroStep: "Write only the unclear part.",
          }),
        },
      ],
    },
  ];
}

function discoveryMapSections(draft: GoalDraft, now: string): PlannerSectionDraft[] {
  const subject = normalizeSubject(draft);
  return [
    {
      title: "Key Questions",
      summary: "Exploration stays honest when the questions are explicit before the experiments start.",
      kind: PlanSectionKind.Overview,
      steps: [
        {
          title: "Write the top questions that need evidence",
          type: StepType.ReflectionPrompt,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: `List the two or three questions you need answered before narrowing ${subject.toLowerCase()}.`,
            completionDefinition: "A short question list exists and each question is answerable through observation or experiment.",
            evidenceOfCompletion: ["A question list exists and the highest-priority question is marked."],
            fallbackMicroStep: "Write the highest-priority question only.",
          }),
        },
      ],
    },
    {
      title: "Experiments",
      summary: "Experiments should be small enough to learn from without pretending certainty is already earned.",
      kind: PlanSectionKind.ActiveSteps,
      steps: [
        {
          title: "Run one low-cost experiment",
          type: StepType.ExplorationExperiment,
          timingType: TimingType.SuggestedNext,
          suggestedNextAt: now,
          actionability: makeActionability({
            action: "Choose one question and run a low-cost experiment that produces evidence within one session.",
            completionDefinition: "One experiment is completed and tied to a specific question.",
            evidenceOfCompletion: ["A short experiment log names the question, action, and result."],
            fallbackMicroStep: "Define the experiment and what result would count as signal.",
          }),
        },
      ],
    },
    {
      title: "Reflections",
      summary: "Reflections should increase or decrease confidence without forcing certainty too early.",
      kind: PlanSectionKind.Review,
      steps: [
        {
          title: "Record what the experiment changed",
          type: StepType.ObservationPrompt,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: "After the experiment, write what became more likely, less likely, or still uncertain.",
            completionDefinition: "A reflection note updates confidence without pretending the answer is final.",
            evidenceOfCompletion: ["A confidence note records what changed and what remains open."],
            fallbackMicroStep: "Write one sentence about what became more or less likely.",
          }),
        },
      ],
    },
  ];
}

function stabilizationPathSections(draft: GoalDraft, now: string): PlannerSectionDraft[] {
  const subject = normalizeSubject(draft);
  return [
    {
      title: "Stabilization First",
      summary: "Recovery plans should stabilize the system before they ask for growth.",
      kind: PlanSectionKind.Overview,
      steps: [
        {
          title: "Name the baseline that needs protecting",
          type: StepType.ObservationPrompt,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: `Write the baseline condition that would mean ${subject.toLowerCase()} is getting more stable.`,
            completionDefinition: "One stabilization sign is named in plain, observable language.",
            evidenceOfCompletion: ["A note names the stabilization sign and why it matters."],
            fallbackMicroStep: "Write the stabilization sign only.",
          }),
        },
      ],
    },
    {
      title: "Low-Friction Actions",
      summary: "Choose the smallest reliable action before anything ambitious gets added.",
      kind: PlanSectionKind.ActiveSteps,
      steps: [
        {
          title: "Complete one stabilizing action",
          type: StepType.ActionUnit,
          timingType: TimingType.SuggestedNext,
          suggestedNextAt: now,
          actionability: makeActionability({
            action: "Complete the smallest action that would help the next day feel steadier or less chaotic.",
            completionDefinition: "One stabilizing action is finished without adding extra stretch work.",
            evidenceOfCompletion: ["A note or artifact shows the action happened."],
            fallbackMicroStep: "Do the first two minutes of the stabilizing action only.",
          }),
        },
        {
          title: "Log the response after the action",
          type: StepType.ObservationPrompt,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: "Write whether the action made the situation feel steadier, unchanged, or harder.",
            completionDefinition: "A short observation records the immediate response to the action.",
            evidenceOfCompletion: ["A response log exists in one or two sentences."],
            fallbackMicroStep: "Choose one word for the response and add detail later.",
          }),
        },
      ],
    },
  ];
}

function guidedSupportSections(draft: GoalDraft, now: string): PlannerSectionDraft[] {
  const subject = normalizeSubject(draft);
  const supportOwner =
    draft.actor.ownership === ExecutionOwnership.Self
      ? createDefaultGoalActor(ExecutionOwnership.ObservedOnly, "Supported person")
      : draft.actor;

  return [
    {
      title: "Support Actions",
      summary: "Support plans help progress without taking ownership away from the executor.",
      kind: PlanSectionKind.SupportingWork,
      steps: [
        {
          title: "Offer one concrete support action",
          type: StepType.SupportAction,
          timingType: TimingType.SuggestedNext,
          suggestedNextAt: now,
          actionability: makeActionability({
            action: `Offer one specific support action that could help with ${subject.toLowerCase()} without taking over the work.`,
            completionDefinition: "One support offer is prepared or completed and it leaves the executor with agency.",
            evidenceOfCompletion: ["A message, material, or setup note shows what support was offered."],
            fallbackMicroStep: "Write the support offer before sending or doing it.",
          }),
        },
      ],
    },
    {
      title: "Observation Prompts",
      summary: "Observation prompts gather signal without punishment or pressure.",
      kind: PlanSectionKind.ActiveSteps,
      steps: [
        {
          title: "Ask an open observation question",
          type: StepType.ObservationPrompt,
          timingType: TimingType.SuggestedNext,
          suggestedNextAt: shiftDateTime(now, 1),
          owner: supportOwner,
          actionability: makeActionability({
            action: "Ask what feels clear, what feels stuck, and what kind of help would be welcome next.",
            completionDefinition: "At least one open question is asked without directing or judging the response.",
            evidenceOfCompletion: ["A short note records the question or the answer that came back."],
            fallbackMicroStep: "Ask only what feels stuck.",
          }),
        },
      ],
    },
    {
      title: "Milestone Signs",
      summary: "Milestone signs let support plans notice progress without micromanaging it.",
      kind: PlanSectionKind.Review,
      steps: [
        {
          title: "Define the next progress sign to watch for",
          type: StepType.ReflectionPrompt,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: "Write the next sign that would show progress, even if the full goal is still far away.",
            completionDefinition: "One milestone sign is named in observational language.",
            evidenceOfCompletion: ["A milestone-sign note exists and avoids control language."],
            fallbackMicroStep: "Write the milestone sign as a fragment if needed.",
          }),
        },
      ],
    },
  ];
}

function lightweightTrackingSections(draft: GoalDraft, now: string): PlannerSectionDraft[] {
  const subject = normalizeSubject(draft);
  return [
    {
      title: "Starter Focus",
      summary: "When confidence is limited, the planner should produce a safe starter plan instead of pretending certainty.",
      kind: PlanSectionKind.Overview,
      steps: [
        {
          title: "State the current best guess",
          type: StepType.ReflectionPrompt,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: `Write the current best guess about what would move ${subject.toLowerCase()} forward next.`,
            completionDefinition: "One best-guess next move is written without claiming it is the final plan.",
            evidenceOfCompletion: ["A note records the current best guess."],
            fallbackMicroStep: "Write the first half of the guess sentence.",
          }),
        },
      ],
    },
    {
      title: "Smallest Next Move",
      summary: "Starter plans should only ask for the smallest move that can create real signal.",
      kind: PlanSectionKind.ActiveSteps,
      steps: [
        {
          title: "Take one low-risk next step",
          type: StepType.ActionUnit,
          timingType: TimingType.SuggestedNext,
          suggestedNextAt: now,
          actionability: makeActionability({
            action: "Complete one low-risk next step that can be finished quickly and teaches you something useful.",
            completionDefinition: "One bounded next step is completed and its result is visible.",
            evidenceOfCompletion: ["A note or artifact shows what was tried and what happened."],
            fallbackMicroStep: "Set up the step or gather the one thing needed to begin it.",
          }),
        },
      ],
    },
    {
      title: "What To Log",
      summary: "Logging matters because starter plans are designed to learn what should happen next.",
      kind: PlanSectionKind.Review,
      steps: [
        {
          title: "Log whether the next move helped",
          type: StepType.ObservationPrompt,
          timingType: TimingType.LogWhenDone,
          actionability: makeActionability({
            action: "Write whether the low-risk next step clarified direction, exposed friction, or should be repeated.",
            completionDefinition: "A short reflection records what the next move taught you.",
            evidenceOfCompletion: ["A reflection note exists with one clear takeaway."],
            fallbackMicroStep: "Write only the takeaway sentence.",
          }),
        },
      ],
    },
  ];
}

function strategySections(strategyId: PlannerStrategyId, draft: GoalDraft, now: string): PlannerSectionDraft[] {
  switch (strategyId) {
    case "routine_builder":
      return routineBuilderSections(draft, now);
    case "learning_path":
      return learningPathSections(draft, now);
    case "discovery_map":
      return discoveryMapSections(draft, now);
    case "stabilization_path":
      return stabilizationPathSections(draft, now);
    case "guided_support":
      return guidedSupportSections(draft, now);
    case "lightweight_tracking":
      return lightweightTrackingSections(draft, now);
    case "milestone_plan":
    default:
      return milestonePlanSections(draft, now);
  }
}

function strategyShapeFor(strategyId: PlannerStrategyId, draft: GoalDraft) {
  return {
    ...draft.planningStrategy,
    defaultStepType:
      strategyId === "learning_path"
        ? StepType.LearningCheckpoint
        : strategyId === "discovery_map"
          ? StepType.ExplorationExperiment
          : strategyId === "guided_support"
            ? StepType.SupportAction
            : strategyId === "routine_builder"
              ? StepType.RecurringRoutine
              : strategyId === "stabilization_path"
                ? StepType.ObservationPrompt
                : StepType.ActionUnit,
    preferredSectionOrder:
      strategyId === "guided_support"
        ? [PlanSectionKind.SupportingWork, PlanSectionKind.ActiveSteps, PlanSectionKind.Review]
        : [PlanSectionKind.Overview, PlanSectionKind.ActiveSteps, PlanSectionKind.Review],
    preferShortSteps: strategyId !== "milestone_plan",
  };
}

export class GoalPlanner {
  private readonly linter = new PlanLinter();
  private readonly rewriter = new StepRewriter();

  plan(input: GoalPlannerInput | DraftBuildResult | GoalDraft, options: GoalPlannerOptions = {}): GoalPlannerResult {
    const plannerInput = asPlannerInput(input);
    const now = options.now ?? new Date().toISOString();
    const goalId =
      options.goalId ??
      `goal-${plannerInput.draft.title.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "") || "draft"}`;
    const readiness = plannerInput.classification?.readiness ?? plannerInput.clarification?.readiness ?? "ready_for_planning";
    const missingFields = plannerInput.classification?.missingFields ?? plannerInput.clarification?.missingFields ?? [];

    if (readiness === "needs_clarification") {
      return {
        kind: "blocked",
        draft: plannerInput.draft,
        blockers: missingFields
          .filter((field) => field.blocksPlanning)
          .map((field) => ({
            code: field.field,
            reason: field.reason,
            suggestedQuestion:
              plannerInput.clarification?.questions.find((question) => question.field === field.field)?.prompt ?? null,
          })),
        clarification: plannerInput.clarification ?? null,
      };
    }

    const assumptions = readiness === "can_plan_with_defaults" ? missingFields.map(createAssumption) : [];
    // Starter plans intentionally downgrade to lightweight tracking so the engine
    // does not fake certainty when intake still carries explicit assumptions.
    const strategyId = assumptions.length > 0 ? "lightweight_tracking" : plannerStrategyIdForDraft(plannerInput.draft, plannerInput.classification);
    const sections = strategySections(strategyId, plannerInput.draft, now).map((section, index) =>
      buildSection(plannerInput.draft, goalId, index, section, now),
    );

    const rewrittenSections = sections.map((section) => ({
      ...section,
      steps: section.steps.map((step) => this.rewriter.rewrite(step, plannerInput.draft)),
    }));

    const plan: GoalPlan = {
      id: `${goalId}-plan`,
      goalId,
      version: GOAL_ENGINE_PLAN_VERSION,
      generatedAt: now,
      summary:
        assumptions.length > 0
          ? "Starter plan built with explicit assumptions so the next step is safe without pretending the goal is fully defined."
          : `Plan for ${plannerInput.draft.title}.`,
      strategy: strategyShapeFor(strategyId, plannerInput.draft),
      sections: rewrittenSections,
      assumptions,
      lint: {
        goalId,
        planVersion: GOAL_ENGINE_PLAN_VERSION,
        isValid: true,
        issueCount: 0,
        issues: [],
      },
    };

    const lint = this.linter.lint(plan, plannerInput.draft);
    plan.lint = lint;

    if (assumptions.length > 0) {
      return {
        kind: "starter_plan",
        draft: plannerInput.draft,
        plan,
        lint,
        assumptions,
      };
    }

    return {
      kind: "plan",
      draft: plannerInput.draft,
      plan,
      lint,
    };
  }
}

function defaultStrategyKind(mode: GoalMode): PlanningStrategyKind {
  switch (mode) {
    case GoalMode.Maintenance:
    case GoalMode.Habit:
      return PlanningStrategyKind.Cadence;
    case GoalMode.Exploration:
      return PlanningStrategyKind.Exploratory;
    case GoalMode.DelegatedSupport:
      return PlanningStrategyKind.Supportive;
    case GoalMode.Learning:
    case GoalMode.Recovery:
      return PlanningStrategyKind.Adaptive;
    case GoalMode.Project:
      return PlanningStrategyKind.Parallel;
    case GoalMode.Achievement:
    default:
      return PlanningStrategyKind.Sequential;
  }
}

function defaultStepType(mode: GoalMode): StepType {
  switch (mode) {
    case GoalMode.Learning:
      return StepType.LearningCheckpoint;
    case GoalMode.Exploration:
      return StepType.ExplorationExperiment;
    case GoalMode.Maintenance:
    case GoalMode.Habit:
      return StepType.RecurringRoutine;
    case GoalMode.DelegatedSupport:
      return StepType.SupportAction;
    case GoalMode.Recovery:
      return StepType.ObservationPrompt;
    case GoalMode.Achievement:
    case GoalMode.Project:
    default:
      return StepType.ActionUnit;
  }
}

export function createPlannerDraft(params: {
  title: string;
  summary?: string | null;
  mode: GoalMode;
  tempo: GoalTempo;
  timingType?: TimingType;
  dueAt?: string | null;
  targetBy?: string | null;
  repeatEveryDays?: number | null;
  actorOwnership?: ExecutionOwnership;
  actorDisplayName?: string;
  tags?: string[];
}): GoalDraft {
  const timing = createGoalTiming({
    tempo: params.tempo,
    timingType: params.timingType,
    dueAt: params.dueAt ?? null,
    targetBy: params.targetBy ?? null,
    repeatEveryDays: params.repeatEveryDays ?? null,
    progressReviewCadenceDays: 7,
  });

  return {
    schemaVersion: GOAL_ENGINE_SCHEMA_VERSION,
    source: EvidenceSource.AiSuggested,
    title: params.title,
    summary: params.summary ?? null,
    mode: params.mode,
    relationshipKind: params.mode === GoalMode.DelegatedSupport ? GoalRelationshipKind.Support : GoalRelationshipKind.Independent,
    actor: createDefaultGoalActor(params.actorOwnership ?? ExecutionOwnership.Self, params.actorDisplayName ?? "You"),
    parentGoalId: params.mode === GoalMode.DelegatedSupport ? "support-parent" : null,
    tags: params.tags ?? [params.mode],
    timing,
    planningStrategy: {
      strategyKind: defaultStrategyKind(params.mode),
      allowParallelSteps: params.mode === GoalMode.Project,
      maxActiveSteps: 3,
      preferredSectionOrder: [PlanSectionKind.Overview, PlanSectionKind.ActiveSteps, PlanSectionKind.Review],
      defaultStepType: defaultStepType(params.mode),
      autoGenerateReviewSection: true,
      preferShortSteps: true,
      revisitCadenceDays: 7,
    },
    progressStrategy: {
      metricKind: params.mode === GoalMode.Learning ? ProgressMetricKind.EvidenceCount : ProgressMetricKind.StepCompletion,
      rollupMethod: params.mode === GoalMode.Learning ? ProgressRollupMethod.WeightedRatio : ProgressRollupMethod.Ratio,
      targetStepCount: 3,
      targetEvidenceCount: params.mode === GoalMode.Learning ? 3 : null,
      targetMinutes: null,
      supportsUntimedProgress: params.tempo === GoalTempo.Untimed,
      countsChildGoals: params.mode === GoalMode.DelegatedSupport,
      countsSupportGoals: params.mode === GoalMode.DelegatedSupport,
    },
    contract: null,
  };
}
