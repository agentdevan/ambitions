import {
  CalendarConnectionState,
  CalendarPermissionState,
  CalendarSyncState,
  EntitySyncState,
} from "../../domain/models";
import {
  getUnsupportedCalendarMessage,
  supportsCalendarIntegration,
} from "../../bootstrap/runtime/runtimeSupport";

import {
  getCalendarPermissionStatus,
  listReadableCalendars,
  readRawEventsInRange,
  requestCalendarPermission,
} from "./calendarReader";
import { convertEventsToConstraints } from "./constraintConverter";
import { normalizeCalendarEvents } from "./eventNormalizer";
import { CalendarSyncResult, DeviceCalendarDescriptor } from "./types";

function dayRange(date: string) {
  return {
    start: new Date(`${date}T00:00:00.000`),
    end: new Date(`${date}T23:59:59.999`),
  };
}

function buildConnectionState(params: {
  existing: CalendarConnectionState | null;
  permissionState: CalendarPermissionState;
  connectionStatus: CalendarSyncState;
  selectedCalendarIds: string[];
  availableCalendars: DeviceCalendarDescriptor[];
  lastSuccessfulSyncAt: string | null;
  metadata?: CalendarConnectionState["metadata"];
}) {
  const timestamp = new Date().toISOString();

  return {
    id: params.existing?.id ?? "calendar-state-default",
    ownerUserId: params.existing?.ownerUserId ?? null,
    remoteId: params.existing?.remoteId ?? null,
    syncState: params.existing?.syncState ?? EntitySyncState.LocalOnly,
    version: (params.existing?.version ?? 0) + 1,
    lastSyncedAt: params.existing?.lastSyncedAt ?? null,
    createdAt: params.existing?.createdAt ?? timestamp,
    updatedAt: timestamp,
    permissionState: params.permissionState,
    connectionStatus: params.connectionStatus,
    selectedCalendarIds: params.selectedCalendarIds,
    lastSuccessfulSyncAt: params.lastSuccessfulSyncAt,
    metadata: {
      availableCalendarCount: params.availableCalendars.length,
      selectedCalendarCount: params.selectedCalendarIds.length,
      availableCalendarTitles: params.availableCalendars.map((calendar) => calendar.title).join(" | "),
      ...params.metadata,
    },
  } satisfies CalendarConnectionState;
}

function mapPermissionState(status: string) {
  if (status === "unavailable") {
    return CalendarPermissionState.Unavailable;
  }

  if (status === "granted") {
    return CalendarPermissionState.Granted;
  }

  if (status === "denied") {
    return CalendarPermissionState.Denied;
  }

  return CalendarPermissionState.NotAsked;
}

function selectCalendarIds(
  calendars: DeviceCalendarDescriptor[],
  requestedCalendarIds: string[] | undefined,
) {
  const availableIds = new Set(calendars.map((calendar) => calendar.id));
  const requested = (requestedCalendarIds ?? []).filter((calendarId) => availableIds.has(calendarId));

  if (requested.length > 0) {
    return requested;
  }

  return calendars.map((calendar) => calendar.id);
}

function summarizeSelectedCalendarTitles(
  calendars: DeviceCalendarDescriptor[],
  selectedCalendarIds: string[],
) {
  const selected = calendars
    .filter((calendar) => selectedCalendarIds.includes(calendar.id))
    .map((calendar) => calendar.title);

  return selected.slice(0, 4).join(" | ");
}

export interface CalendarServiceContract {
  getPermissionStatus(): Promise<string>;
  requestAccess(): Promise<string>;
  listUsableCalendars(): Promise<DeviceCalendarDescriptor[]>;
  syncDate(params: {
    date: string;
    existingState: CalendarConnectionState | null;
    selectedCalendarIds?: string[];
  }): Promise<CalendarSyncResult>;
}

export const CalendarService: CalendarServiceContract = {
  async getPermissionStatus() {
    return getCalendarPermissionStatus();
  },

  async requestAccess() {
    return requestCalendarPermission();
  },

  async listUsableCalendars() {
    return listReadableCalendars();
  },

  async syncDate(params) {
    if (!supportsCalendarIntegration()) {
      return {
        connectionState: buildConnectionState({
          existing: params.existingState,
          permissionState: CalendarPermissionState.Unavailable,
          connectionStatus: CalendarSyncState.Idle,
          selectedCalendarIds: [],
          availableCalendars: [],
          lastSuccessfulSyncAt: params.existingState?.lastSuccessfulSyncAt ?? null,
          metadata: {
            lastReadDate: params.date,
            lastError: getUnsupportedCalendarMessage(),
            lastEventCount: 0,
            lastConstraintCount: 0,
            selectedCalendarTitles: "",
          },
        }),
        calendars: [],
        events: [],
        constraints: [],
        warnings: [getUnsupportedCalendarMessage()],
        usedSelectedCalendarIds: [],
      };
    }

    const permissionStatus = await getCalendarPermissionStatus();
    const permissionState = mapPermissionState(permissionStatus);

    if (permissionState !== CalendarPermissionState.Granted) {
      const deniedStatus =
        permissionState === CalendarPermissionState.Denied
          ? CalendarSyncState.Idle
          : CalendarSyncState.Idle;

      return {
        connectionState: buildConnectionState({
          existing: params.existingState,
          permissionState,
          connectionStatus: deniedStatus,
          selectedCalendarIds: [],
          availableCalendars: [],
          lastSuccessfulSyncAt: params.existingState?.lastSuccessfulSyncAt ?? null,
        }),
        calendars: [],
        events: [],
        constraints: [],
        warnings: [],
        usedSelectedCalendarIds: [],
      };
    }

    const calendars = await listReadableCalendars();

    if (calendars.length === 0) {
      return {
        connectionState: buildConnectionState({
          existing: params.existingState,
          permissionState,
          connectionStatus: CalendarSyncState.NoUsableCalendars,
          selectedCalendarIds: [],
          availableCalendars: [],
          lastSuccessfulSyncAt: params.existingState?.lastSuccessfulSyncAt ?? null,
          metadata: {
            lastReadDate: params.date,
            lastError: null,
            lastEventCount: 0,
            lastConstraintCount: 0,
            selectedCalendarTitles: "",
          },
        }),
        calendars,
        events: [],
        constraints: [],
        warnings: ["No visible event calendars were available on this device."],
        usedSelectedCalendarIds: [],
      };
    }

    const selectedCalendarIds = selectCalendarIds(calendars, params.selectedCalendarIds);

    try {
      const range = dayRange(params.date);
      const rawEvents = await readRawEventsInRange({
        start: range.start,
        end: range.end,
        calendarIds: selectedCalendarIds,
      });
      const normalizedEvents = normalizeCalendarEvents({ events: rawEvents, calendars });
      const constraints = convertEventsToConstraints(normalizedEvents);
      const syncedAt = new Date().toISOString();

      return {
        connectionState: buildConnectionState({
          existing: params.existingState,
          permissionState,
          connectionStatus: CalendarSyncState.Ready,
          selectedCalendarIds,
          availableCalendars: calendars,
          lastSuccessfulSyncAt: syncedAt,
          metadata: {
            lastReadDate: params.date,
            lastError: null,
            lastEventCount: normalizedEvents.length,
            lastConstraintCount: constraints.length,
            selectedCalendarTitles: summarizeSelectedCalendarTitles(
              calendars,
              selectedCalendarIds,
            ),
          },
        }),
        calendars,
        events: normalizedEvents,
        constraints,
        warnings: [],
        usedSelectedCalendarIds: selectedCalendarIds,
      };
    } catch (error) {
      const hadSuccessfulRead = Boolean(params.existingState?.lastSuccessfulSyncAt);
      const message = error instanceof Error ? error.message : "Unknown calendar read failure";

      return {
        connectionState: buildConnectionState({
          existing: params.existingState,
          permissionState,
          connectionStatus: hadSuccessfulRead
            ? CalendarSyncState.Stale
            : CalendarSyncState.TemporaryFailure,
          selectedCalendarIds,
          availableCalendars: calendars,
          lastSuccessfulSyncAt: params.existingState?.lastSuccessfulSyncAt ?? null,
          metadata: {
            lastReadDate: params.date,
            lastError: message,
            lastEventCount: params.existingState?.metadata.lastEventCount ?? 0,
            lastConstraintCount: params.existingState?.metadata.lastConstraintCount ?? 0,
            selectedCalendarTitles:
              params.existingState?.metadata.selectedCalendarTitles ??
              summarizeSelectedCalendarTitles(calendars, selectedCalendarIds),
          },
        }),
        calendars,
        events: [],
        constraints: [],
        warnings: [message],
        usedSelectedCalendarIds: selectedCalendarIds,
      };
    }
  },
};
