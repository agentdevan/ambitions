import { Goal, GoalMilestone } from "../domain/models";

export interface GoalRepository {
  listGoals(): Promise<Goal[]>;
  listMilestones(): Promise<GoalMilestone[]>;
  saveGoals(goals: Goal[]): Promise<void>;
  saveMilestones(milestones: GoalMilestone[]): Promise<void>;
}
