const longFormatter = new Intl.DateTimeFormat("en-US", {
  weekday: "long",
  month: "long",
  day: "numeric",
});

export function formatLongDate(dateString: string) {
  return longFormatter.format(new Date(dateString));
}
