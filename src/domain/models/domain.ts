import { EntityRecord } from "./shared";

export enum DomainKey {
  Career = "career",
  Health = "health",
  Craft = "craft",
  Relationships = "relationships",
  Home = "home",
  Wealth = "wealth",
}

export interface Domain extends EntityRecord {
  key: DomainKey;
  name: string;
  description: string;
  accentColor: string;
  isArchived: boolean;
  sortOrder: number;
}
