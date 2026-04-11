import {
  ConstraintSource,
  EntitySyncState,
  ScheduleConstraint,
  ScheduleConstraintType,
} from "../../domain/models";
import { JsonMap } from "../../domain/models/shared";

import { NormalizedCalendarEvent } from "./types";

function buildMetadata(event: NormalizedCalendarEvent, type: ScheduleConstraintType, note: string): JsonMap {
  return {
    classification: event.kind,
    calendarId: event.calendarId,
    calendarTitle: event.calendarTitle,
    calendarSource: event.calendarSource ?? "",
    normalizationConfidence: Number(event.confidence.toFixed(2)),
    normalizationNote: event.normalizationNote,
    constraintNote: note,
    liveCalendar: true,
    flexible: type === ScheduleConstraintType.Soft,
    usableWindow: event.kind === "lunch",
  };
}

function classifyConstraint(event: NormalizedCalendarEvent) {
  if (event.kind === "travel") {
    return {
      type: ScheduleConstraintType.Hard,
      note: "Explicit travel time is treated as unavailable.",
    };
  }

  if (event.kind === "work" || event.kind === "meeting") {
    return {
      type: ScheduleConstraintType.Hard,
      note: "Timed work commitments are preserved as hard constraints.",
    };
  }

  if (event.kind === "lunch") {
    return {
      type: ScheduleConstraintType.Soft,
      note: "Meal windows stay usable for short work only when explicitly appropriate.",
    };
  }

  if (event.kind === "relationship") {
    return event.isAllDay
      ? {
          type: ScheduleConstraintType.Soft,
          note: "All-day relationship context stays soft unless a timed block exists.",
        }
      : {
          type: ScheduleConstraintType.Hard,
          note: "Timed relationship commitments are preserved as hard constraints.",
        };
  }

  if (event.kind === "personal") {
    return event.isAllDay
      ? {
          type: ScheduleConstraintType.Preference,
          note: "All-day personal context stays informational by default.",
        }
      : {
          type: ScheduleConstraintType.Soft,
          note: "Timed personal events are preserved conservatively but can flex if explicitly uncertain.",
        };
  }

  if (event.kind === "informational") {
    return {
      type: ScheduleConstraintType.Preference,
      note: "Informational calendar entries do not automatically remove the whole day.",
    };
  }

  if (event.isAllDay) {
    return {
      type: ScheduleConstraintType.Preference,
      note: "Ambiguous all-day events stay informational until clearer timing exists.",
    };
  }

  return {
    type: ScheduleConstraintType.Soft,
    note: "Ambiguous timed events stay soft rather than overclaiming certainty.",
  };
}

export function convertEventsToConstraints(events: NormalizedCalendarEvent[]) {
  const timestamp = new Date().toISOString();

  return events.map((event) => {
    const classification = classifyConstraint(event);

    return {
      id: `calendar-constraint-${event.calendarId}-${event.externalEventId}`,
      ownerUserId: null,
      remoteId: null,
      syncState: EntitySyncState.LocalOnly,
      version: 1,
      lastSyncedAt: null,
      createdAt: timestamp,
      updatedAt: timestamp,
      source: ConstraintSource.Calendar,
      type: classification.type,
      title: event.title,
      startsAt: event.startsAt,
      endsAt: event.endsAt,
      isAllDay: event.isAllDay,
      externalEventId: event.externalEventId,
      location: event.location,
      notes: event.notes,
      metadata: buildMetadata(event, classification.type, classification.note),
    } satisfies ScheduleConstraint;
  });
}
