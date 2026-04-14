import { GoalDraft, GoalMode, Step, StepType } from "./goalEngine";

const VAGUE_PATTERNS = [
  /\bwork on\b/i,
  /\bimprove\b/i,
  /\bfocus on\b/i,
  /\bcontinue\b/i,
  /\bmake progress on\b/i,
  /\bhandle\b/i,
  /\bdeal with\b/i,
];

function containsVaguePhrase(value: string | null | undefined): boolean {
  if (!value) {
    return false;
  }

  return VAGUE_PATTERNS.some((pattern) => pattern.test(value));
}

function normalizeSubject(goal: GoalDraft): string {
  return (goal.summary ?? goal.title).replace(/\.$/, "");
}

function preferredVerb(stepType: StepType, mode: GoalMode): string {
  switch (stepType) {
    case StepType.RecurringRoutine:
      return "Complete";
    case StepType.LearningCheckpoint:
      return "Demonstrate";
    case StepType.ExplorationExperiment:
      return "Run";
    case StepType.SupportAction:
      return mode === GoalMode.DelegatedSupport ? "Offer" : "Complete";
    case StepType.ObservationPrompt:
      return "Log";
    case StepType.Resource:
      return "Assemble";
    case StepType.ReflectionPrompt:
      return "Write";
    case StepType.ActionUnit:
    default:
      return "Complete";
  }
}

function buildConcreteRewrite(step: Step, goal: GoalDraft): Step {
  const subject = normalizeSubject(goal);
  const verb = preferredVerb(step.type, goal.mode);

  let title = step.title.trim();
  if (containsVaguePhrase(title)) {
    title = `${verb} one concrete ${subject.toLowerCase()} session`;
  }

  const action = containsVaguePhrase(step.actionability.action)
    ? `${verb} one bounded action for ${subject.toLowerCase()} and stop when the result can be shown or logged.`
    : step.actionability.action;

  const completionDefinition = containsVaguePhrase(step.actionability.completionDefinition)
    ? "Finish a single session-sized unit that can be marked done without carrying unfinished sub-parts."
    : step.actionability.completionDefinition;

  const fallbackMicroStep = containsVaguePhrase(step.actionability.fallbackMicroStep)
    ? `Spend five focused minutes on the smallest visible piece of ${subject.toLowerCase()}.`
    : step.actionability.fallbackMicroStep;

  const evidenceOfCompletion =
    step.actionability.evidenceOfCompletion.length > 0
      ? step.actionability.evidenceOfCompletion
      : ["A short note, log entry, or artifact shows exactly what was completed."];

  return {
    ...step,
    title,
    successSignals:
      step.successSignals.length > 0
        ? step.successSignals
        : ["The completed action can be shown, logged, or described in one sentence."],
    actionability: {
      ...step.actionability,
      action,
      completionDefinition,
      evidenceOfCompletion,
      fallbackMicroStep,
    },
  };
}

export class StepRewriter {
  isVague(step: Step): boolean {
    return (
      containsVaguePhrase(step.title) ||
      containsVaguePhrase(step.summary) ||
      containsVaguePhrase(step.actionability.action) ||
      containsVaguePhrase(step.actionability.completionDefinition) ||
      containsVaguePhrase(step.actionability.fallbackMicroStep)
    );
  }

  rewrite(step: Step, goal: GoalDraft): Step {
    return this.isVague(step) ? buildConcreteRewrite(step, goal) : step;
  }
}

export function stepContainsVaguePhrase(step: Step): boolean {
  return new StepRewriter().isVague(step);
}
