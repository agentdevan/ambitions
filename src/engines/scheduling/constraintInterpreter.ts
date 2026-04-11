import {
  AdaptationProfile,
  ConstraintSource,
  ScheduleConstraint,
  ScheduleConstraintType,
  StrategyStrictness,
  UserPreferences,
} from "../../domain/models";
import { ConstraintDisposition, ConstraintKind, InterpretedConstraint } from "../types";
import { buildIso, dateTimeToMinutes, minutesBetween, minutesToTime, timeToMinutes } from "./time";

interface ScheduleProfile {
  sleepWindow: { start: string; end: string };
  workday: { start: string; end: string; days: number[] } | null;
  lunchWindow: { start: string; end: string } | null;
  commuteMinutes: number;
  prepMinutes: number;
  routines: Array<{ title: string; start: string; end: string; hard: boolean }>;
}

export interface ConstraintInterpretationContext {
  date: string;
  constraints: ScheduleConstraint[];
  preferences: UserPreferences;
  adaptationProfile: AdaptationProfile | null;
}

function parseTime(value: string | number | boolean | null | undefined, fallback: string) {
  return typeof value === "string" && /^\d{2}:\d{2}$/.test(value) ? value : fallback;
}

function parseNumber(value: string | number | boolean | null | undefined, fallback: number) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === "string" && value.trim().length > 0) {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }

  return fallback;
}

function parseDays(value: string | number | boolean | null | undefined) {
  if (typeof value !== "string" || value.trim().length === 0) {
    return [1, 2, 3, 4, 5];
  }

  return value
    .split(",")
    .map((part) => Number(part.trim()))
    .filter((day) => Number.isInteger(day) && day >= 0 && day <= 6);
}

function parseRoutineList(value: string | number | boolean | null | undefined) {
  if (typeof value !== "string" || value.trim().length === 0) {
    return [];
  }

  return value
    .split("|")
    .map((entry) => entry.trim())
    .filter(Boolean)
    .map((entry, index) => {
      const [title, start, end, hardValue] = entry.split(",");
      return {
        title: title?.trim() || `Routine ${index + 1}`,
        start: parseTime(start?.trim(), "19:00"),
        end: parseTime(end?.trim(), "19:30"),
        hard: hardValue?.trim() === "hard",
      };
    });
}

function readScheduleProfile(preferences: UserPreferences): ScheduleProfile {
  const metadata = preferences.metadata ?? {};
  const workStart = parseTime(metadata.workdayStart, "09:00");
  const workEnd = parseTime(metadata.workdayEnd, "17:00");

  return {
    sleepWindow: {
      start: parseTime(metadata.sleepWindowStart, "23:00"),
      end: parseTime(metadata.sleepWindowEnd, "07:00"),
    },
    workday:
      workStart !== workEnd
        ? {
            start: workStart,
            end: workEnd,
            days: parseDays(metadata.workdays),
          }
        : null,
    lunchWindow:
      typeof metadata.lunchWindowStart === "string" && typeof metadata.lunchWindowEnd === "string"
        ? {
            start: parseTime(metadata.lunchWindowStart, "12:00"),
            end: parseTime(metadata.lunchWindowEnd, "12:45"),
          }
        : null,
    commuteMinutes: parseNumber(metadata.commuteMinutes, 0),
    prepMinutes: parseNumber(metadata.morningPrepMinutes, 0),
    routines: parseRoutineList(metadata.recurringRoutineWindows),
  };
}

function createSyntheticConstraint(params: {
  id: string;
  date: string;
  title: string;
  kind: ConstraintKind;
  disposition: ConstraintDisposition;
  start: string;
  end: string;
  reason: string;
  confidence: number;
}) {
  const startMinutes = timeToMinutes(params.start);
  const endMinutes = timeToMinutes(params.end);

  return {
    id: params.id,
    sourceConstraintId: null,
    title: params.title,
    source: ConstraintSource.System,
    kind: params.kind,
    disposition: params.disposition,
    startsAt: buildIso(params.date, startMinutes),
    endsAt: buildIso(params.date, endMinutes),
    startsAtTime: params.start,
    endsAtTime: params.end,
    minutes: minutesBetween(startMinutes, endMinutes),
    isAllDay: false,
    confidence: params.confidence,
    reason: params.reason,
    metadata: { synthetic: true },
  } satisfies InterpretedConstraint;
}

function determineKind(constraint: ScheduleConstraint): ConstraintKind {
  const haystack = `${constraint.title} ${constraint.notes ?? ""} ${constraint.metadata.classification ?? ""}`.toLowerCase();

  if (haystack.includes("sleep")) return "sleep";
  if (haystack.includes("prep") || haystack.includes("morning routine")) return "prep";
  if (haystack.includes("commute") || haystack.includes("travel")) return "commute";
  if (haystack.includes("lunch") || haystack.includes("break")) return "lunch";
  if (haystack.includes("work") || haystack.includes("shift")) return "work";
  if (haystack.includes("meeting") || haystack.includes("call") || haystack.includes("interview")) return "meeting";
  if (haystack.includes("relationship") || haystack.includes("date") || haystack.includes("family")) return "relationship";
  if (haystack.includes("personal") || haystack.includes("appointment")) return "personal";
  if (haystack.includes("routine")) return "routine";
  if (haystack.includes("admin")) return "administrative";
  return "other";
}

function determineDisposition(
  constraint: ScheduleConstraint,
  kind: ConstraintKind,
  strictness: StrategyStrictness,
): ConstraintDisposition {
  const flexible = constraint.metadata.flexible === true || constraint.metadata.flexible === "true";
  const usable = constraint.metadata.usableWindow === true || constraint.metadata.usableWindow === "true";

  if (usable || kind === "lunch") {
    return "usable_within_window";
  }

  if (kind === "sleep" || kind === "prep" || kind === "commute") {
    return "hard_constraint";
  }

  if (kind === "work") {
    return "hard_constraint";
  }

  if (kind === "meeting") {
    return constraint.type === ScheduleConstraintType.Soft ? "soft_constraint" : "hard_constraint";
  }

  if (kind === "relationship" || kind === "personal" || kind === "routine") {
    if (constraint.type === ScheduleConstraintType.Hard) {
      return "hard_constraint";
    }

    if (flexible) {
      return "soft_constraint";
    }

    return strictness === StrategyStrictness.Protective ? "hard_constraint" : "soft_constraint";
  }

  if (constraint.type === ScheduleConstraintType.Preference) {
    return "informational";
  }

  return constraint.type === ScheduleConstraintType.Hard || strictness === StrategyStrictness.Protective
    ? "hard_constraint"
    : "soft_constraint";
}

function buildReason(kind: ConstraintKind, disposition: ConstraintDisposition) {
  if (disposition === "usable_within_window") {
    return "This window can host short intentional work without treating the surrounding block as free time.";
  }

  if (disposition === "soft_constraint") {
    return "This block is preserved when possible but can flex if the day would otherwise fail.";
  }

  switch (kind) {
    case "sleep":
      return "Sleep is treated as a hard floor for realism.";
    case "prep":
      return "Prep time is protected so the day does not start already compressed.";
    case "commute":
      return "Commute time is unavailable unless explicitly marked otherwise.";
    case "work":
      return "Work is treated as a hard constraint except for explicit usable windows.";
    default:
      return "This block is handled conservatively to keep the plan executable.";
  }
}

function normalizeConstraint(constraint: ScheduleConstraint, strictness: StrategyStrictness) {
  const kind = determineKind(constraint);
  const disposition = determineDisposition(constraint, kind, strictness);

  return {
    id: `interpreted-${constraint.id}`,
    sourceConstraintId: constraint.id,
    title: constraint.title,
    source: constraint.source,
    kind,
    disposition,
    startsAt: constraint.startsAt,
    endsAt: constraint.endsAt,
    startsAtTime: constraint.startsAt.slice(11, 16),
    endsAtTime: constraint.endsAt.slice(11, 16),
    minutes: minutesBetween(dateTimeToMinutes(constraint.startsAt), dateTimeToMinutes(constraint.endsAt)),
    isAllDay: constraint.isAllDay,
    confidence: disposition === "hard_constraint" ? 0.92 : disposition === "soft_constraint" ? 0.72 : 0.66,
    reason: buildReason(kind, disposition),
    metadata: {
      sourceType: constraint.type,
      classification: String(constraint.metadata.classification ?? ""),
    },
  } satisfies InterpretedConstraint;
}

function dateDay(date: string) {
  return new Date(`${date}T12:00:00.000Z`).getUTCDay();
}

function buildSyntheticConstraints(
  date: string,
  preferences: UserPreferences,
  strictness: StrategyStrictness,
) {
  const profile = readScheduleProfile(preferences);
  const synthetic: InterpretedConstraint[] = [
    ...(timeToMinutes(profile.sleepWindow.start) < timeToMinutes(profile.sleepWindow.end)
      ? [
          createSyntheticConstraint({
            id: `sleep-${date}`,
            date,
            title: "Sleep target",
            kind: "sleep",
            disposition: "hard_constraint",
            start: profile.sleepWindow.start,
            end: profile.sleepWindow.end,
            reason: "Sleep target reserves non-negotiable recovery time.",
            confidence: 0.95,
          }),
        ]
      : [
          createSyntheticConstraint({
            id: `sleep-early-${date}`,
            date,
            title: "Sleep target",
            kind: "sleep",
            disposition: "hard_constraint",
            start: "00:00",
            end: profile.sleepWindow.end,
            reason: "Sleep target reserves non-negotiable recovery time.",
            confidence: 0.95,
          }),
          createSyntheticConstraint({
            id: `sleep-late-${date}`,
            date,
            title: "Sleep target",
            kind: "sleep",
            disposition: "hard_constraint",
            start: profile.sleepWindow.start,
            end: "24:00",
            reason: "Sleep target reserves non-negotiable recovery time.",
            confidence: 0.95,
          }),
        ]),
  ];

  const workday = profile.workday;
  if (workday && workday.days.includes(dateDay(date))) {
    synthetic.push(
      createSyntheticConstraint({
        id: `work-${date}`,
        date,
        title: "Work block",
        kind: "work",
        disposition: "hard_constraint",
        start: workday.start,
        end: workday.end,
        reason: "Work hours are treated as unavailable by default.",
        confidence: 0.94,
      }),
    );

    if (profile.prepMinutes > 0) {
      const workStart = timeToMinutes(workday.start);
      synthetic.push(
        createSyntheticConstraint({
          id: `prep-${date}`,
          date,
          title: "Morning prep",
          kind: "prep",
          disposition: "hard_constraint",
          start: minutesToTime(workStart - profile.prepMinutes),
          end: minutesToTime(workStart),
          reason: "Prep time prevents the plan from assuming a frictionless work start.",
          confidence: 0.86,
        }),
      );
    }

    if (profile.commuteMinutes > 0) {
      const workStart = timeToMinutes(workday.start);
      const workEnd = timeToMinutes(workday.end);
      synthetic.push(
        createSyntheticConstraint({
          id: `commute-am-${date}`,
          date,
          title: "Morning commute",
          kind: "commute",
          disposition: "hard_constraint",
          start: minutesToTime(workStart - profile.commuteMinutes),
          end: minutesToTime(workStart),
          reason: "Commute time is treated as unavailable.",
          confidence: 0.9,
        }),
        createSyntheticConstraint({
          id: `commute-pm-${date}`,
          date,
          title: "Evening commute",
          kind: "commute",
          disposition: "hard_constraint",
          start: minutesToTime(workEnd),
          end: minutesToTime(workEnd + profile.commuteMinutes),
          reason: "Commute time is treated as unavailable.",
          confidence: 0.9,
        }),
      );
    }

    if (profile.lunchWindow) {
      synthetic.push(
        createSyntheticConstraint({
          id: `lunch-${date}`,
          date,
          title: "Lunch window",
          kind: "lunch",
          disposition: "usable_within_window",
          start: profile.lunchWindow.start,
          end: profile.lunchWindow.end,
          reason: "Lunch can host a short task if the rest of the day stays light.",
          confidence: strictness === StrategyStrictness.Protective ? 0.72 : 0.82,
        }),
      );
    }
  }

  for (const [index, routine] of profile.routines.entries()) {
    synthetic.push(
      createSyntheticConstraint({
        id: `routine-${date}-${index + 1}`,
        date,
        title: routine.title,
        kind: "routine",
        disposition: routine.hard ? "hard_constraint" : "soft_constraint",
        start: routine.start,
        end: routine.end,
        reason: routine.hard
          ? "This recurring routine is treated as fixed."
          : "This recurring routine is preserved when the day allows.",
        confidence: routine.hard ? 0.83 : 0.68,
      }),
    );
  }

  return synthetic;
}

export function interpretConstraints(context: ConstraintInterpretationContext) {
  const strictness = context.adaptationProfile?.strategy.strictness ?? StrategyStrictness.Protective;
  const synthetic = buildSyntheticConstraints(context.date, context.preferences, strictness);
  const explicit = context.constraints.map((constraint) => normalizeConstraint(constraint, strictness));

  return [...synthetic, ...explicit].sort((left, right) => left.startsAt.localeCompare(right.startsAt));
}
