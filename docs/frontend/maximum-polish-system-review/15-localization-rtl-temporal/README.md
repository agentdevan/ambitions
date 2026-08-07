# 15 — Localization, RTL, and Temporal Resilience

## System rules

- Localize meaning, not just labels: dates, time ranges, recurrence, pluralization, units, duration, relative language, and status phrases use locale-aware formatters.
- Preserve canonical chronological order while mirroring navigation/visual direction appropriately.
- Directional symbols are semantic: mirror arrows/chevrons when they express navigation/direction; do not mirror universal symbols that would change meaning.
- Mixed-direction dates, numerals, Goal names, and imported external titles require explicit testing.
- Never use tracked uppercase or fixed-width labels as an essential hierarchy mechanism.
- Layouts must tolerate long German/French-like expansion, Arabic RTL, CJK compact text, and accessibility size together.
- Time must separate locale presentation from canonical event/placement identity and ordering.

## High-risk surfaces

1. Time Day/Week/Month chronology labels and overlapping external titles.
2. Goals Path direction, Start/Now/Next/Proof/Finish, and relationship lenses.
3. Dock labels and global Search/Capture grouping under RTL.
4. Capture free text mixed with parsed dates/times and owner proposal.
5. Search result snippets and action transfer language.
6. You grouped rows, legal/support data, and system Settings handoff.
7. Relative phrases such as “today,” “next,” “this week,” and review horizon.

## Evidence posture

Selected long-text/RTL captures exist for Shell, Time, and Goals candidates. That does not establish catalog completeness, all plural/date/time formats, mixed-direction robustness, or physical-device inspection. Goals R02 localization evidence remains technically informative but cannot serve as selected visual authority.
