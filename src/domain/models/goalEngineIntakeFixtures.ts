import {
  ClassificationResult,
  DraftBuildResult,
  PlanningReadiness,
  buildGoalDraftFromIntake,
} from "./goalEngineIntake";
import {
  ExecutionOwnership,
  GoalMode,
  GoalRelationshipKind,
  GoalTempo,
} from "./goalEngine";

export interface GoalEngineIntakeFixtureExpectation {
  mode: GoalMode;
  tempo: GoalTempo;
  ownership: ExecutionOwnership;
  relationshipKind: GoalRelationshipKind;
  readiness: PlanningReadiness;
  starterPlanSafe: boolean;
  clarificationQuestionCount: number;
}

export interface GoalEngineIntakeFixture {
  id: string;
  input: string;
  result: DraftBuildResult;
  expectations: GoalEngineIntakeFixtureExpectation;
}

function makeFixture(
  id: string,
  input: string,
  expectations: GoalEngineIntakeFixtureExpectation,
): GoalEngineIntakeFixture {
  return {
    id,
    input,
    result: buildGoalDraftFromIntake(input),
    expectations,
  };
}

export const goalEngineIntakeFixtures: GoalEngineIntakeFixture[] = [
  makeFixture("timed-goal", "Launch my business this summer", {
    mode: GoalMode.Project,
    tempo: GoalTempo.TargetWindow,
    ownership: ExecutionOwnership.Self,
    relationshipKind: GoalRelationshipKind.Independent,
    readiness: "ready_for_planning",
    starterPlanSafe: true,
    clarificationQuestionCount: 0,
  }),
  makeFixture("untimed-goal", "Get healthier", {
    mode: GoalMode.Recovery,
    tempo: GoalTempo.Untimed,
    ownership: ExecutionOwnership.Self,
    relationshipKind: GoalRelationshipKind.Independent,
    readiness: "can_plan_with_defaults",
    starterPlanSafe: true,
    clarificationQuestionCount: 2,
  }),
  makeFixture("learning-goal", "Learn how to mix vocals", {
    mode: GoalMode.Learning,
    tempo: GoalTempo.Untimed,
    ownership: ExecutionOwnership.Self,
    relationshipKind: GoalRelationshipKind.Independent,
    readiness: "ready_for_planning",
    starterPlanSafe: true,
    clarificationQuestionCount: 0,
  }),
  makeFixture("exploration-goal", "Figure out if freelancing is right for me", {
    mode: GoalMode.Exploration,
    tempo: GoalTempo.Untimed,
    ownership: ExecutionOwnership.Self,
    relationshipKind: GoalRelationshipKind.Independent,
    readiness: "ready_for_planning",
    starterPlanSafe: true,
    clarificationQuestionCount: 0,
  }),
  makeFixture("maintenance-goal", "This is recurring but flexible", {
    mode: GoalMode.Maintenance,
    tempo: GoalTempo.Ongoing,
    ownership: ExecutionOwnership.Self,
    relationshipKind: GoalRelationshipKind.Independent,
    readiness: "needs_clarification",
    starterPlanSafe: false,
    clarificationQuestionCount: 1,
  }),
  makeFixture("delegated-support-goal", "Help my daughter read better", {
    mode: GoalMode.DelegatedSupport,
    tempo: GoalTempo.Ongoing,
    ownership: ExecutionOwnership.Child,
    relationshipKind: GoalRelationshipKind.Support,
    readiness: "can_plan_with_defaults",
    starterPlanSafe: true,
    clarificationQuestionCount: 1,
  }),
  makeFixture("delegated-breakdown", "Break this down for someone else", {
    mode: GoalMode.DelegatedSupport,
    tempo: GoalTempo.Untimed,
    ownership: ExecutionOwnership.ObservedOnly,
    relationshipKind: GoalRelationshipKind.Delegated,
    readiness: "needs_clarification",
    starterPlanSafe: false,
    clarificationQuestionCount: 2,
  }),
  makeFixture("ambiguous-preference", "I don't want deadlines", {
    mode: GoalMode.Achievement,
    tempo: GoalTempo.Untimed,
    ownership: ExecutionOwnership.Self,
    relationshipKind: GoalRelationshipKind.Independent,
    readiness: "needs_clarification",
    starterPlanSafe: false,
    clarificationQuestionCount: 1,
  }),
];

export function findGoalEngineIntakeFixture(id: string): GoalEngineIntakeFixture | undefined {
  return goalEngineIntakeFixtures.find((fixture) => fixture.id === id);
}

export function getGoalEngineIntakeClassificationResults(): ClassificationResult[] {
  return goalEngineIntakeFixtures.map((fixture) => fixture.result.classification);
}
