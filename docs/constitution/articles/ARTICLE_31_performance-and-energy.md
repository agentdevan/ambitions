# Article 31 — Performance and energy

## PERF-001 — Product-wide budget registry

The repo maintains measured budgets for launch, first interaction, root switching, mutation, projection refresh, Search, Time scrolling, Goal Path interaction, Capture opening/draft save, recurrence, import, sync, migration, backup/restore, attachments, widgets, App Intents, memory, disk growth, and energy.

## PERF-002 — Budget context

Every budget declares device floor, OS, build configuration, data scale, warm/cold state, tool, percentile/maximum, and regression threshold.

## PERF-003 — No unverifiable “fast”

Performance claims require current measurements tied to commit and environment. Simulator-only measurements may not prove physical-device readiness where hardware behavior matters.

## PERF-004 — Regression blocking

A required budget regression beyond its declared tolerance blocks the affected First-Class Green claim unless the budget itself is explicitly amended with evidence and owner approval.

## PERF-005 — Resource-aware scheduling

Expensive background work respects cancellation, Low Power Mode, thermal state, protected-data availability, foreground responsiveness, and storage pressure.

---
