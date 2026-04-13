import type * as Calendar from "expo-calendar";

import { DeviceCalendarDescriptor, RawCalendarEvent } from "./types";
import {
  getUnsupportedCalendarMessage,
  supportsCalendarIntegration,
} from "../../bootstrap/runtime/runtimeSupport";

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

let calendarModulePromise: Promise<typeof import("expo-calendar")> | null = null;

async function getCalendarModule() {
  if (!supportsCalendarIntegration()) {
    return null;
  }

  if (!calendarModulePromise) {
    calendarModulePromise = import("expo-calendar").catch((error) => {
      calendarModulePromise = null;
      throw error;
    });
  }

  return calendarModulePromise;
}

export async function getCalendarPermissionStatus() {
  const CalendarModule = await getCalendarModule();
  if (!CalendarModule) {
    return "unavailable";
  }

  const { status } = await CalendarModule.getCalendarPermissionsAsync();
  return status;
}

export async function requestCalendarPermission() {
  const CalendarModule = await getCalendarModule();
  if (!CalendarModule) {
    return "unavailable";
  }

  const { status } = await CalendarModule.requestCalendarPermissionsAsync();
  return status;
}

export async function listReadableCalendars() {
  const CalendarModule = await getCalendarModule();
  if (!CalendarModule) {
    return [];
  }

  const calendars = await CalendarModule.getCalendarsAsync(CalendarModule.EntityTypes.EVENT);

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
  const CalendarModule = await getCalendarModule();
  if (!CalendarModule) {
    throw new Error(getUnsupportedCalendarMessage());
  }

  if (params.calendarIds.length === 0) {
    return [];
  }

  const events = await CalendarModule.getEventsAsync(params.calendarIds, params.start, params.end);

  return events
    .map(toRawEvent)
    .filter((event) => event.endDate.getTime() > event.startDate.getTime())
    .sort((left, right) => left.startDate.getTime() - right.startDate.getTime());
}
