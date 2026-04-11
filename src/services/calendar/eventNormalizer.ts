import { DeviceCalendarDescriptor, NormalizedCalendarEvent, RawCalendarEvent } from "./types";

const workTokens = ["work", "shift", "office", "on call"];
const meetingTokens = ["meeting", "standup", "call", "sync", "interview", "review", "1:1"];
const travelTokens = ["flight", "travel", "commute", "drive", "train", "uber", "lyft"];
const lunchTokens = ["lunch", "breakfast", "dinner", "coffee"];
const relationshipTokens = ["date", "anniversary", "family", "parents", "partner", "friend"];
const personalTokens = ["doctor", "dentist", "therapy", "pickup", "appointment", "errand"];
const informationalTokens = ["birthday", "holiday", "ooo", "out of office"];

function detectKind(raw: RawCalendarEvent, calendar: DeviceCalendarDescriptor) {
  const haystack = `${raw.title ?? ""} ${raw.notes ?? ""} ${calendar.title}`.toLowerCase();

  if (travelTokens.some((token) => haystack.includes(token))) return "travel";
  if (lunchTokens.some((token) => haystack.includes(token))) return "lunch";
  if (meetingTokens.some((token) => haystack.includes(token))) return "meeting";
  if (workTokens.some((token) => haystack.includes(token))) return "work";
  if (relationshipTokens.some((token) => haystack.includes(token))) return "relationship";
  if (personalTokens.some((token) => haystack.includes(token))) return "personal";
  if (informationalTokens.some((token) => haystack.includes(token))) return "informational";
  return "unknown";
}

function toIso(value: Date) {
  return value.toISOString();
}

function normalizationNote(raw: RawCalendarEvent, kind: NormalizedCalendarEvent["kind"]) {
  if (raw.isAllDay) {
    return "All-day event kept as informational unless timing metadata clearly says otherwise.";
  }

  if (kind === "unknown") {
    return "Classification stayed conservative because the event metadata is ambiguous.";
  }

  return "Normalized directly from device calendar metadata without inferred duration changes.";
}

function confidenceFor(raw: RawCalendarEvent, kind: NormalizedCalendarEvent["kind"]) {
  if (raw.isAllDay) {
    return kind === "informational" ? 0.62 : 0.55;
  }

  if (kind === "unknown") {
    return 0.48;
  }

  if (kind === "meeting" || kind === "work" || kind === "travel") {
    return 0.84;
  }

  return 0.7;
}

export function normalizeCalendarEvents(params: {
  events: RawCalendarEvent[];
  calendars: DeviceCalendarDescriptor[];
}) {
  const calendarsById = new Map(params.calendars.map((calendar) => [calendar.id, calendar]));

  return params.events.map((event) => {
    const calendar =
      calendarsById.get(event.calendarId) ??
      ({
        id: event.calendarId,
        title: "Unknown calendar",
        source: null,
        color: null,
        isVisible: true,
      } satisfies DeviceCalendarDescriptor);
    const kind = detectKind(event, calendar);

    return {
      id: `normalized-${event.calendarId}-${event.id}`,
      externalEventId: event.id,
      title: event.title?.trim() || "Untitled event",
      startsAt: toIso(event.startDate),
      endsAt: toIso(event.endDate),
      isAllDay: event.isAllDay,
      location: event.location,
      notes: event.notes,
      calendarId: calendar.id,
      calendarTitle: calendar.title,
      calendarSource: calendar.source,
      timeZone: event.timeZone,
      kind,
      confidence: confidenceFor(event, kind),
      normalizationNote: normalizationNote(event, kind),
    } satisfies NormalizedCalendarEvent;
  });
}
