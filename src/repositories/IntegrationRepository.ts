import { CalendarConnectionState, ScheduleConstraint } from "../domain/models";

export interface IntegrationRepository {
  getCalendarConnectionState(): Promise<CalendarConnectionState | null>;
  listScheduleConstraintsForDate(date: string): Promise<ScheduleConstraint[]>;
  saveCalendarConnectionState(state: CalendarConnectionState): Promise<void>;
  saveScheduleConstraints(constraints: ScheduleConstraint[]): Promise<void>;
}
