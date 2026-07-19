# Article 40 — App lifecycle and background execution

## LIFECYCLE-001 — Scene transitions

Cold launch, warm launch, background, foreground, scene reconnect, termination, and memory pressure define draft, transaction, projection, and external-reconciliation behavior.

## LIFECYCLE-002 — System changes

Time-zone, significant-time, locale, calendar-store, notification, iCloud-account, and protected-data changes trigger deterministic reconciliation.

## LIFECYCLE-003 — Background limits

Background work is bounded, cancellable, idempotent, privacy-safe, and does not assume completion. Relaunch resumes or reconciles safely.

## LIFECYCLE-004 — Extension handoff

Widget, Share, App Intent, notification, and future Live Activity handoffs preserve command identity, minimum data, timeout behavior, and safe fallback.

---
