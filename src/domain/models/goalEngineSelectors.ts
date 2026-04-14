import {
  Goal,
  GoalPlan,
  PlanSection,
  PlanSectionKind,
  Step,
  StepLifecycleState,
  TimingType,
} from "./goalEngine";

export interface GoalCompletionCounts {
  total: number;
  completed: number;
  active: number;
  planned: number;
  blocked: number;
  cancelled: number;
  repeatable: number;
  optional: number;
}

export interface GoalProgressSummary {
  hasPlan: boolean;
  totalSteps: number;
  completedSteps: number;
  remainingSteps: number;
  activeSteps: number;
  repeatableSteps: number;
  percentComplete: number;
}

export interface ActiveMilestoneSummary {
  sectionId: string;
  stepId: string;
  title: string;
  summary: string | null;
  state: StepLifecycleState;
  targetBy: string | null;
  dueAt: string | null;
  suggestedNextAt: string | null;
}

export interface GoalStepsByTiming {
  due: Step[];
  suggested: Step[];
  repeatable: Step[];
  logWhenDone: Step[];
}

export interface GoalSectionStepGroup {
  section: PlanSection;
  steps: Step[];
  completedCount: number;
  remainingCount: number;
}

function asGoalPlan(goalOrPlan: Goal | GoalPlan | null | undefined): GoalPlan | null {
  if (!goalOrPlan) {
    return null;
  }

  return "sections" in goalOrPlan ? goalOrPlan : goalOrPlan.plan;
}

function isRemainingStep(step: Step): boolean {
  return ![StepLifecycleState.Completed, StepLifecycleState.Cancelled].includes(step.state);
}

function stepSortValue(step: Step): number {
  if (step.state === StepLifecycleState.Active) {
    return 0;
  }
  switch (step.timing.timingType) {
    case TimingType.DueAt:
      return 1;
    case TimingType.TargetBy:
      return 2;
    case TimingType.SuggestedNext:
      return 3;
    case TimingType.RepeatWithinWindow:
      return 4;
    case TimingType.LogWhenDone:
    default:
      return 5;
  }
}

function timingDateValue(step: Step): string {
  return (
    step.timing.dueAt ??
    step.timing.targetBy ??
    step.timing.suggestedNextAt ??
    step.timing.startsOn ??
    ""
  );
}

export function getGoalPlanSections(goalOrPlan: Goal | GoalPlan | null | undefined): PlanSection[] {
  return asGoalPlan(goalOrPlan)?.sections ?? [];
}

export function getGoalPlanSteps(goalOrPlan: Goal | GoalPlan | null | undefined): Step[] {
  return getGoalPlanSections(goalOrPlan).flatMap((section) => section.steps);
}

export function getDueSteps(goalOrPlan: Goal | GoalPlan | null | undefined): Step[] {
  return getGoalPlanSteps(goalOrPlan).filter((step) =>
    [TimingType.DueAt, TimingType.TargetBy].includes(step.timing.timingType),
  );
}

export function getSuggestedSteps(goalOrPlan: Goal | GoalPlan | null | undefined): Step[] {
  return getGoalPlanSteps(goalOrPlan).filter((step) => step.timing.timingType === TimingType.SuggestedNext);
}

export function getRepeatableSteps(goalOrPlan: Goal | GoalPlan | null | undefined): Step[] {
  return getGoalPlanSteps(goalOrPlan).filter(
    (step) => step.isRepeatable || step.timing.timingType === TimingType.RepeatWithinWindow,
  );
}

export function getPrimaryNextSteps(
  goalOrPlan: Goal | GoalPlan | null | undefined,
  limit = 3,
): Step[] {
  return getGoalPlanSteps(goalOrPlan)
    .filter(isRemainingStep)
    .sort((left, right) => {
      const timingOrder = stepSortValue(left) - stepSortValue(right);
      if (timingOrder !== 0) {
        return timingOrder;
      }
      return timingDateValue(left).localeCompare(timingDateValue(right));
    })
    .slice(0, limit);
}

export function getCompletionCounts(goalOrPlan: Goal | GoalPlan | null | undefined): GoalCompletionCounts {
  const steps = getGoalPlanSteps(goalOrPlan);

  return {
    total: steps.length,
    completed: steps.filter((step) => step.state === StepLifecycleState.Completed).length,
    active: steps.filter((step) => step.state === StepLifecycleState.Active).length,
    planned: steps.filter((step) => step.state === StepLifecycleState.Planned).length,
    blocked: steps.filter((step) => step.state === StepLifecycleState.Blocked).length,
    cancelled: steps.filter((step) => step.state === StepLifecycleState.Cancelled).length,
    repeatable: steps.filter((step) => step.isRepeatable).length,
    optional: steps.filter((step) => step.isOptional).length,
  };
}

export function getProgressSummary(goalOrPlan: Goal | GoalPlan | null | undefined): GoalProgressSummary {
  const counts = getCompletionCounts(goalOrPlan);
  const remainingSteps = Math.max(0, counts.total - counts.completed - counts.cancelled);

  return {
    hasPlan: getGoalPlanSections(goalOrPlan).length > 0,
    totalSteps: counts.total,
    completedSteps: counts.completed,
    remainingSteps,
    activeSteps: counts.active,
    repeatableSteps: counts.repeatable,
    percentComplete: counts.total === 0 ? 0 : Number(((counts.completed / counts.total) * 100).toFixed(1)),
  };
}

export function getActiveMilestoneSummaries(
  goalOrPlan: Goal | GoalPlan | null | undefined,
  limit = 3,
): ActiveMilestoneSummary[] {
  return getGoalPlanSections(goalOrPlan)
    .filter((section) => section.kind === PlanSectionKind.Overview)
    .flatMap((section) =>
      section.steps
        .filter(isRemainingStep)
        .map((step) => ({
          sectionId: section.id,
          stepId: step.id,
          title: step.title,
          summary: step.summary,
          state: step.state,
          targetBy: step.timing.targetBy,
          dueAt: step.timing.dueAt,
          suggestedNextAt: step.timing.suggestedNextAt,
        })),
    )
    .slice(0, limit);
}

export function groupStepsByTiming(goalOrPlan: Goal | GoalPlan | null | undefined): GoalStepsByTiming {
  const steps = getGoalPlanSteps(goalOrPlan);

  return {
    due: steps.filter((step) => [TimingType.DueAt, TimingType.TargetBy].includes(step.timing.timingType)),
    suggested: steps.filter((step) => step.timing.timingType === TimingType.SuggestedNext),
    repeatable: steps.filter(
      (step) => step.isRepeatable || step.timing.timingType === TimingType.RepeatWithinWindow,
    ),
    logWhenDone: steps.filter((step) => step.timing.timingType === TimingType.LogWhenDone),
  };
}

export function groupStepsBySection(goalOrPlan: Goal | GoalPlan | null | undefined): GoalSectionStepGroup[] {
  return getGoalPlanSections(goalOrPlan).map((section) => {
    const completedCount = section.steps.filter((step) => step.state === StepLifecycleState.Completed).length;
    return {
      section,
      steps: section.steps,
      completedCount,
      remainingCount: Math.max(0, section.steps.length - completedCount),
    };
  });
}
