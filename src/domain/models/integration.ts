import { EntityRecord, ISODateTimeString, JsonMap } from "./shared";

export enum CalendarPermissionState {
  Unknown = "unknown",
  Granted = "granted",
  Denied = "denied",
}

export enum CalendarSyncState {
  NotConnected = "not_connected",
  Ready = "ready",
  NeedsAttention = "needs_attention",
  Syncing = "syncing",
}

export enum ScheduleConstraintType {
  Hard = "hard",
  Soft = "soft",
  Preference = "preference",
}

export enum ConstraintSource {
  Calendar = "calendar",
  Manual = "manual",
  System = "system",
}

export interface CalendarConnectionState extends EntityRecord {
  permissionState: CalendarPermissionState;
  connectionStatus: CalendarSyncState;
  selectedCalendarIds: string[];
  lastSuccessfulSyncAt: ISODateTimeString | null;
  metadata: JsonMap;
}

export interface ScheduleConstraint extends EntityRecord {
  source: ConstraintSource;
  type: ScheduleConstraintType;
  title: string;
  startsAt: ISODateTimeString;
  endsAt: ISODateTimeString;
  isAllDay: boolean;
  externalEventId: string | null;
  location: string | null;
  notes: string | null;
  metadata: JsonMap;
}
