import { StrategyStrictness, UserPreferences } from "../../domain/models";
import { CapacitySummary, InterpretedConstraint, TimeCapacityOutput, UsableTimeWindow } from "../types";
import { mergeRanges, minutesBetween, subtractRanges, timeToMinutes } from "./time";

function toTime(minutes: number) {
  const hours = Math.floor(minutes / 60)
    .toString()
    .padStart(2, "0");
  const remainder = (minutes % 60).toString().padStart(2, "0");
  return `${hours}:${remainder}`;
}

function labelForWindow(start: number, kind: UsableTimeWindow["kind"]) {
  if (kind === "lunch") {
    return "Lunch window";
  }

  if (start < 12 * 60) {
    return "Before work";
  }

  if (start >= 17 * 60) {
    return "After work";
  }

  return "Open gap";
}

export function deriveUsableWindows(
  interpretedConstraints: InterpretedConstraint[],
  strictness: StrategyStrictness,
) {
  const hardRanges = interpretedConstraints
    .filter(
      (constraint) =>
        constraint.disposition === "hard_constraint" ||
        (strictness === StrategyStrictness.Protective && constraint.disposition === "soft_constraint"),
    )
    .map((constraint) => ({
      start: timeToMinutes(constraint.startsAtTime),
      end: timeToMinutes(constraint.endsAtTime),
    }));

  const usableOverrides = interpretedConstraints
    .filter((constraint) => constraint.disposition === "usable_within_window")
    .map((constraint) => ({
      constraint,
      start: timeToMinutes(constraint.startsAtTime),
      end: timeToMinutes(constraint.endsAtTime),
    }));

  const windows: UsableTimeWindow[] = subtractRanges({ start: 0, end: 24 * 60 }, hardRanges).map(
    (range, index) => ({
      id: `window-core-${index + 1}`,
      start: "",
      end: "",
      startTime: toTime(range.start),
      endTime: toTime(range.end),
      minutes: minutesBetween(range.start, range.end),
      kind: "core",
      sourceConstraintIds: [],
      confidence: strictness === StrategyStrictness.Protective ? 0.9 : 0.94,
      label: labelForWindow(range.start, "core"),
    }),
  );

  for (const [index, override] of usableOverrides.entries()) {
    windows.push({
      id: `window-override-${index + 1}`,
      start: "",
      end: "",
      startTime: toTime(override.start),
      endTime: toTime(override.end),
      minutes: minutesBetween(override.start, override.end),
      kind: override.constraint.kind === "lunch" ? "lunch" : "gap",
      sourceConstraintIds: [override.constraint.sourceConstraintId ?? override.constraint.id],
      confidence: override.constraint.confidence,
      label: labelForWindow(override.start, override.constraint.kind === "lunch" ? "lunch" : "gap"),
    });
  }

  return windows
    .filter((window) => window.minutes >= 10)
    .sort((left, right) => left.startTime.localeCompare(right.startTime));
}

export function buildCapacityOutput(params: {
  interpretedConstraints: InterpretedConstraint[];
  usableWindows: UsableTimeWindow[];
  preferences: UserPreferences;
  strictness: StrategyStrictness;
}) {
  const hardRanges = mergeRanges(
    params.interpretedConstraints
      .filter(
        (constraint) =>
          constraint.disposition === "hard_constraint" ||
          (params.strictness === StrategyStrictness.Protective &&
            constraint.disposition === "soft_constraint"),
      )
      .map((constraint) => ({
        start: timeToMinutes(constraint.startsAtTime),
        end: timeToMinutes(constraint.endsAtTime),
      })),
  );

  const totalUnavailableMinutes = hardRanges.reduce(
    (sum, range) => sum + minutesBetween(range.start, range.end),
    0,
  );
  const totalUsableMinutes = params.usableWindows.reduce((sum, window) => sum + window.minutes, 0);
  const confidencePenalty = params.interpretedConstraints.filter(
    (constraint) => constraint.disposition === "soft_constraint",
  ).length;

  const capacitySummary: CapacitySummary = {
    totalDayMinutes: 24 * 60,
    totalUnavailableMinutes,
    totalUsableMinutes,
    scheduledMinutes: 0,
    unscheduledDemandMinutes: 0,
    unusedCapacityMinutes: totalUsableMinutes,
    overloadMinutes: 0,
    confidence: Math.max(
      params.strictness === StrategyStrictness.Protective ? 0.56 : 0.62,
      0.92 - (confidencePenalty * 0.05),
    ),
  };

  return {
    focusMinutes: params.usableWindows
      .filter((window) => window.kind !== "lunch")
      .reduce((sum, window) => sum + window.minutes, 0),
    adminMinutes: Math.min(totalUsableMinutes, params.preferences.defaultFocusSessionMinutes * 2),
    recoveryMinutes: params.usableWindows
      .filter((window) => window.kind === "gap")
      .reduce((sum, window) => sum + Math.min(window.minutes, 20), 0),
    capacitySummary,
    interpretedConstraints: params.interpretedConstraints,
    usableWindows: params.usableWindows,
  } satisfies TimeCapacityOutput;
}
