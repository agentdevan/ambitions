import {
  GoalDraft,
  GoalMode,
  GoalPlan,
  GoalTempo,
  PlanLintIssue,
  PlanLintIssueCode,
  PlanLintResult,
  PlanLintSeverity,
  Step,
  TimingType,
  lintGoalPlan,
} from "./goalEngine";
import { stepContainsVaguePhrase } from "./goalEngineStepRewriter";

const SUPPORT_TONE_PATTERNS = [/\bmake (him|her|them)\b/i, /\bforce\b/i, /\bcompliance\b/i, /\bensure they\b/i];
const SESSION_BREAKERS = [/\band\b/i, /\bthen\b/i, /\bentire\b/i, /\bfull\b/i, /\bcomplete all\b/i];

function createIssue(
  code: PlanLintIssueCode,
  severity: PlanLintSeverity,
  step: Step | null,
  fieldPath: string[],
  message: string,
  suggestedFix: string,
): PlanLintIssue {
  return {
    code,
    severity,
    fieldPath,
    message,
    sectionId: step?.sectionId ?? null,
    stepId: step?.id ?? null,
    suggestedFix,
  };
}

function looksOversized(step: Step): boolean {
  const combined = [step.title, step.actionability.action, step.actionability.completionDefinition].join(" ");
  const wordCount = combined.trim().split(/\s+/).length;
  return wordCount > 40 || SESSION_BREAKERS.some((pattern) => pattern.test(combined));
}

function missingEvidence(step: Step): boolean {
  return step.evidenceRequired && step.actionability.evidenceOfCompletion.length === 0;
}

function hasWrongSupportTone(step: Step): boolean {
  const combined = [step.title, step.summary ?? "", step.actionability.action].join(" ");
  return SUPPORT_TONE_PATTERNS.some((pattern) => pattern.test(combined));
}

function hasTimingPressureMismatch(step: Step, goal: GoalDraft): boolean {
  if ([GoalMode.Learning, GoalMode.Exploration, GoalMode.Maintenance, GoalMode.Recovery, GoalMode.DelegatedSupport].includes(goal.mode)) {
    return [TimingType.DueAt].includes(step.timing.timingType);
  }

  if (goal.timing.tempo === GoalTempo.Untimed) {
    return [TimingType.DueAt, TimingType.TargetBy].includes(step.timing.timingType);
  }

  return false;
}

function notSessionCompletable(step: Step): boolean {
  return looksOversized(step) || /weeks?|months?/i.test(step.actionability.completionDefinition);
}

function lintPlannerStep(step: Step, goal: GoalDraft): PlanLintIssue[] {
  const issues: PlanLintIssue[] = [];

  if (stepContainsVaguePhrase(step)) {
    issues.push(
      createIssue(
        PlanLintIssueCode.VagueStep,
        PlanLintSeverity.Error,
        step,
        ["steps", step.id, "title"],
        "Planner steps must avoid vague verbs and define an exact action.",
        "Replace broad verbs with one visible, session-sized action.",
      ),
    );
  }

  if (looksOversized(step)) {
    issues.push(
      createIssue(
        PlanLintIssueCode.OversizedStep,
        PlanLintSeverity.Warning,
        step,
        ["steps", step.id],
        "This step looks too large for a single working session.",
        "Split it into one concrete session step plus a separate follow-up step.",
      ),
    );
  }

  if (missingEvidence(step)) {
    issues.push(
      createIssue(
        PlanLintIssueCode.MissingStepEvidence,
        PlanLintSeverity.Error,
        step,
        ["steps", step.id, "actionability", "evidenceOfCompletion"],
        "Actionable steps must say what evidence will show the work is done.",
        "Add one or two concrete artifacts, logs, or observations that prove completion.",
      ),
    );
  }

  if (hasTimingPressureMismatch(step, goal)) {
    issues.push(
      createIssue(
        PlanLintIssueCode.InappropriateTimingPressure,
        PlanLintSeverity.Warning,
        step,
        ["steps", step.id, "timing"],
        "This step applies more timing pressure than the goal mode safely supports.",
        "Use suggested_next, repeat_within_window, or log_when_done unless the goal explicitly needs a deadline.",
      ),
    );
  }

  if (goal.mode === GoalMode.DelegatedSupport && hasWrongSupportTone(step)) {
    issues.push(
      createIssue(
        PlanLintIssueCode.WrongSupportTone,
        PlanLintSeverity.Error,
        step,
        ["steps", step.id, "title"],
        "Delegated-support plans must use non-punitive, non-controlling language.",
        "Rewrite the step as support, observation, or invitation instead of control.",
      ),
    );
  }

  if (notSessionCompletable(step)) {
    issues.push(
      createIssue(
        PlanLintIssueCode.NotSessionCompletable,
        PlanLintSeverity.Warning,
        step,
        ["steps", step.id, "actionability", "completionDefinition"],
        "Each step should be meaningfully completable in one session.",
        "Define a smaller stopping point that can be completed and evidenced today.",
      ),
    );
  }

  return issues;
}

export class PlanLinter {
  lint(plan: GoalPlan, goal: GoalDraft): PlanLintResult {
    const contractLint = lintGoalPlan(plan);
    const semanticIssues = plan.sections.flatMap((section) => section.steps.flatMap((step) => lintPlannerStep(step, goal)));
    const issues = [...contractLint.issues, ...semanticIssues];

    return {
      goalId: plan.goalId,
      planVersion: plan.version,
      isValid: issues.every((issue) => issue.severity !== PlanLintSeverity.Error),
      issueCount: issues.length,
      issues,
    };
  }
}
