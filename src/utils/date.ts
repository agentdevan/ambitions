const longFormatter = new Intl.DateTimeFormat("en-US", {
  weekday: "long",
  month: "long",
  day: "numeric",
});

const shortDateFormatter = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
});

const shortDateTimeFormatter = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
  hour: "numeric",
  minute: "2-digit",
  hour12: true,
});

const timeFormatter = new Intl.DateTimeFormat("en-US", {
  hour: "numeric",
  minute: "2-digit",
  hour12: true,
});

function parseLocalDateOnly(dateString: string) {
  const [year, month, day] = dateString.split("-").map(Number);
  return new Date(year, (month ?? 1) - 1, day ?? 1, 12, 0, 0, 0);
}

function parseClockParts(hours: number, minutes: number) {
  if (!Number.isFinite(hours) || !Number.isFinite(minutes)) {
    return null;
  }

  if (minutes < 0 || minutes > 59) {
    return null;
  }

  if (hours === 24 && minutes === 0) {
    return { hours: 0, minutes, dayOffset: 1 };
  }

  if (hours < 0 || hours > 23) {
    return null;
  }

  return { hours, minutes, dayOffset: 0 };
}

function buildClockDate(hours: number, minutes: number, dayOffset = 0) {
  return new Date(2026, 0, 1 + dayOffset, hours, minutes, 0, 0);
}

export function normalizeTimeString(value: string) {
  const normalized = value.trim().toLowerCase();
  if (!normalized) {
    return null;
  }

  const meridiemMatch = normalized.match(/^(\d{1,2})(?::(\d{2}))?\s*([ap])m?$/i);
  if (meridiemMatch) {
    const rawHours = Number(meridiemMatch[1]);
    const minutes = Number(meridiemMatch[2] ?? "0");

    if (rawHours < 1 || rawHours > 12 || minutes < 0 || minutes > 59) {
      return null;
    }

    const isPm = meridiemMatch[3] === "p";
    const hours = rawHours % 12 + (isPm ? 12 : 0);
    return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}`;
  }

  const twentyFourHourMatch = normalized.match(/^(\d{1,2})(?::(\d{2}))?$/);
  if (!twentyFourHourMatch) {
    return null;
  }

  const parsed = parseClockParts(
    Number(twentyFourHourMatch[1]),
    Number(twentyFourHourMatch[2] ?? "0"),
  );

  if (!parsed) {
    return null;
  }

  return `${String(parsed.hours).padStart(2, "0")}:${String(parsed.minutes).padStart(2, "0")}`;
}

export function getCurrentLocalDateString(reference = new Date()) {
  const year = reference.getFullYear();
  const month = String(reference.getMonth() + 1).padStart(2, "0");
  const day = String(reference.getDate()).padStart(2, "0");

  return `${year}-${month}-${day}`;
}

export function formatLongDate(dateString: string) {
  return longFormatter.format(parseLocalDateOnly(dateString));
}

export function formatShortDate(dateString: string) {
  return shortDateFormatter.format(parseLocalDateOnly(dateString));
}

export function formatShortDateTime(value: string) {
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return value;
  }

  return shortDateTimeFormatter.format(parsed);
}

export function formatTimeLabel(
  value: string,
  options?: {
    compact?: boolean;
  },
) {
  const normalized = normalizeTimeString(value);
  if (!normalized) {
    return value;
  }

  const [hours, minutes] = normalized.split(":").map(Number);
  const parsed = parseClockParts(hours, minutes);
  if (!parsed) {
    return value;
  }

  const formatted = timeFormatter.format(
    buildClockDate(parsed.hours, parsed.minutes, parsed.dayOffset),
  );

  if (!options?.compact) {
    return formatted;
  }

  return formatted.replace(" AM", "a").replace(" PM", "p");
}

export function formatTimeRangeLabel(
  start: string,
  end: string,
  options?: {
    compact?: boolean;
  },
) {
  return `${formatTimeLabel(start, options)} - ${formatTimeLabel(end, options)}`;
}
