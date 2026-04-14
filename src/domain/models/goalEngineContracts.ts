/**
 * Canonical TypeScript entry point for the additive goal engine rollout.
 *
 * Prefer importing `EngineGoal` / `EngineStep` and `LegacyGoal` / `LegacyTask`
 * from this module when both contract families are in scope. That keeps the
 * TS contract explicit and reduces accidental mixing with the legacy domain.
 */
export type { Goal as LegacyGoal, GoalMilestone as LegacyGoalMilestone } from "./goal";
export type { Task as LegacyTask } from "./planning";

export * from "./goalEngine";
export * from "./goalEngineSelectors";

export type {
  Goal as EngineGoal,
  GoalActor as EngineGoalActor,
  GoalContractMetadata as EngineGoalContractMetadata,
  GoalDraft as EngineGoalDraft,
  GoalPlan as EngineGoalPlan,
  GoalTiming as EngineGoalTiming,
  PlanSection as EnginePlanSection,
  Step as EngineStep,
  StepContractMetadata as EngineStepContractMetadata,
} from "./goalEngine";
