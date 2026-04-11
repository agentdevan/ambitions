import * as Calendar from "expo-calendar";

export const CalendarService = {
  async requestAccess() {
    const { status } = await Calendar.requestCalendarPermissionsAsync();
    return status;
  },

  async getDefaultCalendars() {
    const calendars = await Calendar.getCalendarsAsync(Calendar.EntityTypes.EVENT);
    return calendars.filter((calendar) => calendar.allowsModifications);
  },
};
