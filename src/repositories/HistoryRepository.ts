import { ActivityEvent } from "../domain/models";

export interface HistoryRepository {
  listActivityEvents(limit?: number): Promise<ActivityEvent[]>;
  saveActivityEvents(events: ActivityEvent[]): Promise<void>;
}
