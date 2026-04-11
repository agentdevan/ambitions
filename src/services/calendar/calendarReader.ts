import * as Calendar from "expo-calendar";

import { DeviceCalendarDescriptor, RawCalendarEvent } from "./types";

function describeCalendar(calendar: Calendar.Calendar): DeviceCalendarDescriptor {
  return {
    id: calendar.id,
    title: calendar.title,
    source: typeof calendar.source?.name === "string" ? calendar.source.name : null,
    color: typeof calendar.color === "string" ? calendar.color : null,
    isVisible: calendar.isVisible ?? true,
  };
}

function toRawEvent(event: Calendar.Event): RawCalendarEvent {
  return {
    id: event.id,
    calendarId: event.calendarId,
    title: typeof event.title === "string" ? event.title : null,
    notes: typeof event.notes === "string" ? event.notes : null,
    location: typeof event.location === "string" ? event.location : null,
    startDate: new Date(event.startDate),
    endDate: new Date(event.endDate),
    isAllDay: event.allDay ?? false,
    timeZone: typeof event.timeZone === "string" ? event.timeZone : null,
  };
}

export async function getCalendarPermissionStatus() {
  const { status } = await Calendar.getCalendarPermissionsAsync();
  return status;
}

export async function requestCalendarPermission() {
  const { status } = await Calendar.requestCalendarPermissionsAsync();
  return status;
}

export async function listReadableCalendars() {
  const calendars = await Calendar.getCalendarsAsync(Calendar.EntityTypes.EVENT);

  return calendars
    .filter((calendar) => (calendar.isVisible ?? true) !== false)
    .map(describeCalendar)
    .sort((left, right) => left.title.localeCompare(right.title));
}

export async function readRawEventsInRange(params: {
  start: Date;
  end: Date;
  calendarIds: string[];
}) {
  if (params.calendarIds.length === 0) {
    return [];
  }

  const events = await Calendar.getEventsAsync(params.calendarIds, params.start, params.end);

  return events
    .map(toRawEvent)
    .filter((event) => event.endDate.getTime() > event.startDate.getTime())
    .sort((left, right) => left.startDate.getTime() - right.startDate.getTime());
}
