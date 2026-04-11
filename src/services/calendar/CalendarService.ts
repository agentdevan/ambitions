import * as Calendar from "expo-calendar";

export interface CalendarEventWindow {
  eventId: string;
  title: string;
  startsAt: string;
  endsAt: string;
  classification: "hard" | "soft";
  location: string | null;
}

export interface AvailableTimeWindow {
  start: string;
  end: string;
  durationMinutes: number;
}

export interface CalendarServiceContract {
  requestAccess(): Promise<Calendar.PermissionStatus>;
  listWritableCalendars(): Promise<Calendar.Calendar[]>;
  readEventWindows(date: string): Promise<CalendarEventWindow[]>;
  deriveAvailableWindows(date: string): Promise<AvailableTimeWindow[]>;
}

export const CalendarService: CalendarServiceContract = {
  async requestAccess() {
    const { status } = await Calendar.requestCalendarPermissionsAsync();
    return status;
  },

  async listWritableCalendars() {
    const calendars = await Calendar.getCalendarsAsync(Calendar.EntityTypes.EVENT);
    return calendars.filter((calendar) => calendar.allowsModifications);
  },

  async readEventWindows() {
    return [];
  },

  async deriveAvailableWindows() {
    return [];
  },
};
