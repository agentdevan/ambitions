import { DraftBuildResult, buildGoalDraftFromIntake } from "../../domain/models/goalEngineIntake";
import { GoalPlanner } from "../../domain/models/goalEnginePlanner";
import {
  GoalBlockedResult,
  GoalClarificationRequiredResult,
  GoalEngineOrchestrationContext,
  GoalOrchestrationResult,
  GoalPlannedResult,
  GoalStarterPlannedResult,
  buildOrchestrationMetadata,
  buildPreparedOrchestrationInput,
  normalizeOrchestrationContext,
} from "./goalEngineOrchestration";

export class GoalEngineOrchestrator {
  private readonly planner: GoalPlanner;

  constructor(planner: GoalPlanner = new GoalPlanner()) {
    this.planner = planner;
  }

  /**
   * Compile raw goal language into a single app-facing result.
   *
   * The orchestrator keeps intake and planner pure, then adds the application
   * decision layer that decides whether the app should ask for clarification,
   * show a starter plan, show a full plan, or surface a blocked state.
   */
  compileGoal(rawInput: string, context: GoalEngineOrchestrationContext = {}): GoalOrchestrationResult {
    const draftBuild: DraftBuildResult = buildGoalDraftFromIntake(rawInput);
    const normalizedContext = normalizeOrchestrationContext(context);
    const prepared = buildPreparedOrchestrationInput({
      classification: draftBuild.classification,
      clarification: draftBuild.clarification,
      context: normalizedContext,
    });

    const requireClarification =
      prepared.clarification.contradictions.length > 0 ||
      prepared.classification.readiness === "needs_clarification" ||
      (prepared.classification.readiness === "can_plan_with_defaults" &&
        normalizedContext.preferredPlanningStrictness === "strict");

    if (requireClarification && !prepared.classification.starterPlanSafe) {
      const metadata = buildOrchestrationMetadata({
        classification: prepared.classification,
        clarification: prepared.clarification,
        context: normalizedContext,
      });
      const result: GoalClarificationRequiredResult = {
        kind: "clarification_required",
        draft: prepared.classification.draft,
        clarification: prepared.clarification,
        metadata,
      };
      return result;
    }

    if (
      prepared.clarification.contradictions.length > 0 ||
      (prepared.classification.readiness === "can_plan_with_defaults" &&
        normalizedContext.preferredPlanningStrictness === "strict")
    ) {
      const metadata = buildOrchestrationMetadata({
        classification: prepared.classification,
        clarification: prepared.clarification,
        context: normalizedContext,
      });
      const result: GoalClarificationRequiredResult = {
        kind: "clarification_required",
        draft: prepared.classification.draft,
        clarification: prepared.clarification,
        metadata,
      };
      return result;
    }

    const plannerResult = this.planner.plan(prepared.plannerInput, {
      now: normalizedContext.referenceNow ?? undefined,
    });
    const metadata = buildOrchestrationMetadata({
      classification: prepared.classification,
      clarification: prepared.clarification,
      context: normalizedContext,
      plannerResult,
    });

    switch (plannerResult.kind) {
      case "plan": {
        const result: GoalPlannedResult = {
          kind: "planned",
          draft: plannerResult.draft,
          plan: plannerResult.plan,
          lint: plannerResult.lint,
          metadata,
        };
        return result;
      }
      case "starter_plan": {
        const result: GoalStarterPlannedResult = {
          kind: "starter_planned",
          draft: plannerResult.draft,
          plan: plannerResult.plan,
          lint: plannerResult.lint,
          assumptions: plannerResult.assumptions,
          clarification: prepared.clarification,
          metadata,
        };
        return result;
      }
      case "blocked":
      default: {
        const result: GoalBlockedResult = {
          kind: "blocked",
          draft: plannerResult.draft,
          blockers: plannerResult.blockers,
          clarification: prepared.clarification,
          metadata,
        };
        return result;
      }
    }
  }
}

export function compileGoal(
  rawInput: string,
  context: GoalEngineOrchestrationContext = {},
): GoalOrchestrationResult {
  return new GoalEngineOrchestrator().compileGoal(rawInput, context);
}
