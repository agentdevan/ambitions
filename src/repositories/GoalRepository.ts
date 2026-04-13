import { Ambition, Goal, GoalMilestone } from "../domain/models";

export interface GoalRepository {
  listAmbitions(): Promise<Ambition[]>;
  listGoals(): Promise<Goal[]>;
  listMilestones(): Promise<GoalMilestone[]>;
  saveAmbitions(ambitions: Ambition[]): Promise<void>;
  saveGoals(goals: Goal[]): Promise<void>;
  saveMilestones(milestones: GoalMilestone[]): Promise<void>;
}
