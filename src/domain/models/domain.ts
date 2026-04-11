import { EntityRecord } from "./shared";

export enum DomainKey {
  Fitness = "fitness",
  Finance = "finance",
  Credit = "credit",
  Career = "career",
  SkillBuilding = "skill_building",
  Relationship = "relationship",
  Personal = "personal",
}

export interface Domain extends EntityRecord {
  key: DomainKey;
  name: string;
  description: string;
  accentColor: string;
  isArchived: boolean;
  sortOrder: number;
}
