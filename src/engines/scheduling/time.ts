const MINUTES_PER_DAY = 24 * 60;

export interface MinuteRange {
  start: number;
  end: number;
}

export function clampMinutes(value: number) {
  return Math.max(0, Math.min(MINUTES_PER_DAY, Math.round(value)));
}

export function timeToMinutes(value: string) {
  const [hours, minutes] = value.split(":").map((part) => Number(part));
  return clampMinutes((hours * 60) + minutes);
}

export function minutesToTime(value: number) {
  const minutes = clampMinutes(value);
  const hours = Math.floor(minutes / 60)
    .toString()
    .padStart(2, "0");
  const remainder = (minutes % 60).toString().padStart(2, "0");
  return `${hours}:${remainder}`;
}

export function dateTimeToMinutes(value: string) {
  return timeToMinutes(value.slice(11, 16));
}

export function minutesBetween(start: number, end: number) {
  return Math.max(0, end - start);
}

export function buildIso(date: string, minutes: number) {
  return `${date}T${minutesToTime(minutes)}:00.000Z`;
}

export function mergeRanges(ranges: MinuteRange[]) {
  const sorted = [...ranges]
    .filter((range) => range.end > range.start)
    .sort((left, right) => left.start - right.start);

  if (sorted.length === 0) {
    return [];
  }

  const merged: MinuteRange[] = [{ ...sorted[0] }];

  for (const current of sorted.slice(1)) {
    const last = merged[merged.length - 1];

    if (current.start <= last.end) {
      last.end = Math.max(last.end, current.end);
      continue;
    }

    merged.push({ ...current });
  }

  return merged;
}

export function subtractRanges(base: MinuteRange, removals: MinuteRange[]) {
  const normalizedRemovals = mergeRanges(removals);
  const result: MinuteRange[] = [];
  let cursor = base.start;

  for (const removal of normalizedRemovals) {
    if (removal.end <= cursor || removal.start >= base.end) {
      continue;
    }

    if (removal.start > cursor) {
      result.push({ start: cursor, end: Math.min(removal.start, base.end) });
    }

    cursor = Math.max(cursor, removal.end);

    if (cursor >= base.end) {
      break;
    }
  }

  if (cursor < base.end) {
    result.push({ start: cursor, end: base.end });
  }

  return result.filter((range) => range.end > range.start);
}
