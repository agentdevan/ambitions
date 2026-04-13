import { EntityRecord, JsonMap } from "./shared";

export enum AmbitionStatus {
  Active = "active",
  Paused = "paused",
  Archived = "archived",
}

export interface Ambition extends EntityRecord {
  title: string;
  thesis: string | null;
  status: AmbitionStatus;
  sortOrder: number;
  isVisible: boolean;
  metadata: JsonMap;
}
