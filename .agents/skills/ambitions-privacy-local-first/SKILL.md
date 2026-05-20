---
name: ambitions-privacy-local-first
description: Use for Ambitions privacy, local-first architecture, no-cloud-core checks, network/backend/dependency gates, memory controls, and privacy-manifest honesty.
---

# Ambitions Privacy Local First

## Authority Boundary
Start from `docs/truth/*` before using this skill. Skills are operating support only: they are not product truth, implementation proof, validation proof, release proof, privacy approval, accessibility proof, App Store proof, or permission to change app behavior outside the current task scope.

Active top-level IA is `Today / Goals / Capture / Time / You`. `Plan` may appear only as an internal compatibility seam unless an active truth-file-scoped migration changes it.

Hard stops: required cloud AI/LLM core behavior, hosted personal-data backend, analytics/tracking SDKs without approval, privacy manifest dishonesty, release/App Store/TestFlight/device/accessibility/performance claims without evidence, `Plan` as top-level IA, broad staging, destructive cleanup without indexed approval, or converting Ambitions into a dashboard/chatbot/calendar clone/task manager/habit tracker.
## Local-First Rule
Core Ambitions behavior must remain local-first and deterministic. External/cloud LLMs, hosted personal-data backends, analytics/tracking SDKs, and server-side planning runtimes are hard stops without explicit active truth-file authority and approval.

## Workflow
1. Inspect touched code/config for network, backend, analytics, AI SDK, CloudKit/iCloud, App Group, privacy manifest, and dependency changes.
2. Confirm personal data is not sent to external services by default.
3. Require user-controlled, inspectable, resettable memory/personalization paths.
4. Keep privacy manifest and App Privacy wording honest to source behavior.
5. Record local-only status as source-present/tested/proven/unproven; do not infer approval.
