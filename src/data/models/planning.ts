export type BlockEnergy = "light" | "steady" | "deep";
export type PlanBlockState = "scheduled" | "complete" | "rolled" | "deferred";

export interface PlanBlock {
  id: string;
  title: string;
  startsAt: string;
  endsAt: string;
  energy: BlockEnergy;
  state: PlanBlockState;
  linkedGoalId?: string;
  note?: string;
}

export interface DailyPlan {
  date: string;
  focus: string;
  blocks: PlanBlock[];
}
