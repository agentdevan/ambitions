import {
  GoalEngineOrchestrationContext,
  GoalOrchestrationResult,
} from "./goalEngineOrchestration";
import { GoalEngineOrchestrator } from "./GoalEngineOrchestrator";

export interface GoalEngineOrchestratorFixture {
  id: string;
  input: string;
  context?: GoalEngineOrchestrationContext;
  result: GoalOrchestrationResult;
}

const orchestrator = new GoalEngineOrchestrator();
const fixedNow = "2026-04-14T12:00:00.000Z";

function runFixture(
  id: string,
  input: string,
  context: GoalEngineOrchestrationContext = {},
): GoalEngineOrchestratorFixture {
  return {
    id,
    input,
    context,
    result: orchestrator.compileGoal(input, {
      ...context,
      referenceNow: context.referenceNow ?? fixedNow,
    }),
  };
}

export const goalEngineOrchestratorFixtures: GoalEngineOrchestratorFixture[] = [
  runFixture("clear-timed-self-goal", "Submit my conference talk proposal by 2026-05-15", {
    sourceScreen: "goal_composer",
    sourceFlow: "manual_entry",
  }),
  runFixture("untimed-learning-goal", "Learn how to mix vocals", {
    sourceScreen: "goal_composer",
  }),
  runFixture("exploratory-vague-goal", "Launch my business", {
    preferredPlanningStrictness: "starter_friendly",
  }),
  runFixture("delegated-child-support-goal", "Help my daughter read better", {
    actorName: "Maya",
    supportScope: "supporting",
    goalOwnerRole: "Supported learner",
  }),
  runFixture("blocked-requiring-clarification", "Break this down for someone else"),
  runFixture(
    "contradictory-input",
    "I want to launch my business this summer, but I don't want deadlines",
  ),
  runFixture("dont-know-where-to-start", "I don't know where to start"),
];

export function findGoalEngineOrchestratorFixture(
  id: string,
): GoalEngineOrchestratorFixture | undefined {
  return goalEngineOrchestratorFixtures.find((fixture) => fixture.id === id);
}
