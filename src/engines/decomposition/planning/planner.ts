import { Goal } from "../../../domain/models";
import { GoalPlanningAnalysis, PlanningMode } from "../../../domain/models/planningBrain";
import { mapGoalDomain } from "./domainMapper";
import { classifyGoal } from "./goalClassifier";
import { toGoalDraftInput } from "./goalInput";
import { generateMilestones } from "./milestoneGenerator";
import { buildPlanningPolicy } from "./protectiveMode";
import { selectStrategies } from "./strategyTemplates";
import { generateTasks } from "./taskGenerator";

export function analyzeGoal(goal: Goal, mode: PlanningMode = PlanningMode.Protective): GoalPlanningAnalysis {
  const input = toGoalDraftInput(goal);
  const classification = classifyGoal(input);
  const domainCandidates = mapGoalDomain(input);
  const selectedDomain = domainCandidates[0];
  const policy = buildPlanningPolicy(mode);
  const analysis: GoalPlanningAnalysis = {
    classification: {
      ...classification,
      domainConfidence: selectedDomain?.confidence ?? classification.domainConfidence,
    },
    domainCandidates,
    selectedDomain,
    strategies: [],
    policy,
  };

  analysis.strategies = selectStrategies(input, analysis);

  return analysis;
}

export function buildGoalPlan(goal: Goal, mode: PlanningMode = PlanningMode.Protective) {
  const analysis = analyzeGoal(goal, mode);
  const milestones = generateMilestones(goal, analysis);
  const tasks = milestones.flatMap((milestone) => generateTasks(goal, milestone, analysis));

  return { analysis, milestones, tasks };
}
