---
name: ambitions-external-surfaces
description: Use for Ambitions widgets, Live Activities, App Intents, Shortcuts, share extension, App Group snapshots, and external-surface privacy gates.
---

# Ambitions External Surfaces

## Authority Boundary
Start from `docs/truth/*` before using this skill. Skills are operating support only: they are not product truth, implementation proof, validation proof, release proof, privacy approval, accessibility proof, App Store proof, or permission to change app behavior outside the current task scope.

Active top-level IA is `Today / Goals / Capture / Time / You`. `Plan` may appear only as an internal compatibility seam unless an active truth-file-scoped migration changes it.

Hard stops: required cloud AI/LLM core behavior, hosted personal-data backend, analytics/tracking SDKs without approval, privacy manifest dishonesty, release/App Store/TestFlight/device/accessibility/performance claims without evidence, `Plan` as top-level IA, broad staging, destructive cleanup without indexed approval, or converting Ambitions into a dashboard/chatbot/calendar clone/task manager/habit tracker.
## External Surface Rule
Widgets, Live Activities, App Intents, Shortcuts, share extension, and App Group snapshots must be local, privacy-safe, stale-aware, and fail closed. They must not silently mutate critical state or leak sensitive content.

## Workflow
1. Inspect snapshot freshness, redaction defaults, App Group atomicity, route compatibility, and receipt/provenance behavior.
2. Keep external actions confirmation-bound when sensitive.
3. Preserve canonical Time language; Plan may survive only as a tested legacy route alias.
4. Add or require tests for stale/corrupt/no-data states where source changes occur.
5. Record device/manual proof gaps as Yellow, not Green.
