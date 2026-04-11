import { CalendarConnectionState, ScheduleConstraint } from "../../domain/models";

export interface DeviceCalendarDescriptor {
  id: string;
  title: string;
  source: string | null;
  color: string | null;
  isVisible: boolean;
}

export interface RawCalendarEvent {
  id: string;
  calendarId: string;
  title: string | null;
  notes: string | null;
  location: string | null;
  startDate: Date;
  endDate: Date;
  isAllDay: boolean;
  timeZone: string | null;
}

export type NormalizedEventKind =
  | "work"
  | "meeting"
  | "travel"
  | "lunch"
  | "relationship"
  | "personal"
  | "informational"
  | "unknown";

export interface NormalizedCalendarEvent {
  id: string;
  externalEventId: string;
  title: string;
  startsAt: string;
  endsAt: string;
  isAllDay: boolean;
  location: string | null;
  notes: string | null;
  calendarId: string;
  calendarTitle: string;
  calendarSource: string | null;
  timeZone: string | null;
  kind: NormalizedEventKind;
  confidence: number;
  normalizationNote: string;
}

export interface CalendarSyncResult {
  connectionState: CalendarConnectionState;
  calendars: DeviceCalendarDescriptor[];
  events: NormalizedCalendarEvent[];
  constraints: ScheduleConstraint[];
  warnings: string[];
  usedSelectedCalendarIds: string[];
}
