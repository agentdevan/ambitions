---
name: ambitions-runtime-persistence
description: Use for Ambitions Private Life Runtime, deterministic local decisions, receipts, replay, SwiftData migration, export/delete/reset, and persistence safety.
---

# Ambitions Runtime Persistence

## Authority Boundary
Start from `docs/truth/*` before using this skill. Skills are operating support only: they are not product truth, implementation proof, validation proof, release proof, privacy approval, accessibility proof, App Store proof, or permission to change app behavior outside the current task scope.

Active top-level IA is `Today / Goals / Time / Motion / You`. Global action: `Capture` (not a tab). `Motion` replaces `Pulse` (historical context only). `Plan` may appear only as an internal compatibility seam unless an active truth-file-scoped migration changes it.

Hard stops: required cloud AI/LLM core behavior, hosted personal-data backend, analytics/tracking SDKs without approval, privacy manifest dishonesty, release/App Store/TestFlight/device/accessibility/performance claims without evidence, `Plan` as top-level IA, broad staging, destructive cleanup without indexed approval, or converting Ambitions into a dashboard/chatbot/calendar clone/task manager/habit tracker.
## Runtime Rule
The moat is the Private Life Runtime: local, deterministic, inspectable, capacity-aware decisions with receipts, replay, closure, proof, and recovery. Do not add opaque ranking or required cloud AI.

## Workflow
1. Inspect runtime/domain/persistence boundaries before changing behavior.
2. Require deterministic fixtures for recommendation, compilation, closure, recovery, and replay changes.
3. Prefer existing receipt/event ledgers before new schema.
4. Do not make destructive SwiftData changes without migration fixtures and rollback behavior.
5. For export/delete/reset, require confirmation, failure recovery, and proof-bound UI status.
