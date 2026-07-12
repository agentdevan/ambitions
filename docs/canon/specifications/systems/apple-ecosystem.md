+++
spec_id = "SYSTEM-APPLE-ECOSYSTEM"
title = "Apple Ecosystem"
kind = "system"
status = "normative"
owner_domain = "system-apple-ecosystem"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.apple.projection", "system.apple.command-handoff"]
inherits = ["PLATFORM-NATIVE-IPHONE-001", "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001", "RUNTIME-MUTATION-SEQUENCE-001", "LAW-OFFLINE-NO-ACCOUNT-001"]
depends_on = ["CONSTITUTION", "APP-DEEP-LINKING", "SYSTEM-PRIVATE-LIFE-RUNTIME", "SYSTEM-PRIVACY-DATA-CLASSIFICATION", "SYSTEM-NOTIFICATIONS"]
source_owners = ["Native/Ambitions/App/", "Native/Ambitions/App/Intents/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Projections/", "Native/Ambitions/Projection/ExternalSnapshots/", "Native/AmbitionsWidgetExtension/", "Native/AmbitionsShareExtension/", "Native/Ambitions/Quality/"]
+++

# Apple Ecosystem

This shadow target covers widgets, Lock Screen, App Intents/Shortcuts/Siri, Share, Spotlight, deep links, and lifecycle handoffs. It does not claim current feature coverage, entitlement approval, device behavior, or platform readiness.

## SYSTEM-APPLE-PROJECTION-001 — Ecosystem surfaces use minimized disposable projections

- **Concept:** `system.apple.projection`
- **Modality:** `MUST`
- **Scope:** Widget, Lock Screen, Spotlight, App Group, shortcut/entity display, and app-switcher-sensitive presentation
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-APPLE-PROJECTION-001`
- **Supersedes:** none

Apple ecosystem surfaces MUST consume minimized, versioned, read-only, privacy-filtered Projections or snapshots. They do not open the canonical store, retain an unrestricted private graph, become a fifth root, or invent separate object identity. Sensitive content is hidden by default where ambient exposure is possible, and every visual/spatial action has semantic accessibility parity.

## SYSTEM-APPLE-HANDOFF-001 — Every ecosystem action preserves command identity and safe fallback

- **Concept:** `system.apple.command-handoff`
- **Modality:** `MUST`
- **Scope:** Widget, notification, App Intent, Shortcut/Siri, Share, Spotlight, deep link, and background/lifecycle handoff
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-APPLE-HANDOFF-001`
- **Supersedes:** none

A mutating handoff MUST preserve minimum payload, source, stable command/idempotency identity, privacy and confirmation requirements, timeout/cancellation behavior, and safe open-app fallback. Share intake durably preserves original input before classification; deep links and Spotlight resolve identifiers and permitted actions separately; external callbacks never mutate canonical state directly.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns common projection, privacy, identity, lifecycle, timeout, accessibility, and command-handoff rules for Apple ecosystem entry points. It does not own canonical objects, root IA, platform API availability claims, entitlement approval, or a parallel runtime.

<!-- canon-section: inputs-outputs -->
The contract consumes approved local Projections, command envelopes, routes/entities, source payloads, privacy/permission/accessibility state, lifecycle limits, and API availability. It emits minimized snapshots, valid actions/routes, durable Share intake, Command results, refresh intents, and safe fallback.

<!-- canon-section: authority-boundary -->
App/extension code adapts system APIs; `Projections/` owns external reads and `ExternalWrites/`/`Commands/` own effects/mutations. Availability-gated native APIs or fallbacks are required; no bridge bypasses privacy, confirmation, receipt, or replay law.

<!-- canon-section: data-classification -->
External snapshots and entities include only allowlisted minimum metadata under sensitive-surface policy. Attachments, notes, proof, schedules, rationale, learning, and private context are excluded unless a named user action explicitly requires and previews them.

<!-- canon-section: state-model -->
Each handoff records entry type, source, payload/schema, privacy/permission state, command/route identity, lifecycle phase, timeout/cancellation, accepted/rejected result, refresh need, and fallback destination.

<!-- canon-section: failure-recovery -->
Failure handling preserves source input and routes to a safe local destination.
Unavailable API/permission/data, stale snapshot, malformed/spoofed input, timeout, termination, protected-data lock, or extension failure preserves input where applicable and safely opens/reconciles in app without false success or duplicate mutation.

<!-- canon-section: local-network-boundary -->
Core ecosystem projection, Capture, commands, routes, and fallbacks work locally/no-account. Optional public-reference refresh is separately firewalled; ecosystem payloads never send private graph data to Ambitions services.

<!-- canon-section: determinism -->
Stable approved Projection, policy, API availability, permission, and route/command input produce the same snapshot, action set, redaction, and fallback. Duplicate invocations resolve idempotently.

<!-- canon-section: observability -->
Local redacted evidence binds entry/snapshot/route/command IDs, schema/API availability, permission/privacy state, timing/cancellation, result, fallback, Receipt, and refresh without private payload values.

<!-- canon-section: source-ownership -->
Canonical ownership is divided among App bridges, LocalRuntimeOS projections/effects, extension targets, and Quality.
Exact target owners are `App/`, `App/Intents/`, `Core/LocalRuntimeOS/Projections/`, `ExternalWrites/`, `Projection/ExternalSnapshots/`, widget/share targets, and `Quality/`. Current bridges and projections remain implementation facts; app-wide parity, availability review, extensions, entitlements, accessibility, device, and release proof are separate.

<!-- canon-section: tests-proof -->
Cover every entry point, snapshot privacy state, stale/protected data, permission denial, malformed/spoofed route/entity, duplicate command, timeout/cancel/termination, background handoff, Share preservation, open-app fallback, no direct store access/write, VoiceOver/Dynamic Type/Reduce Motion, API availability fallback, and device-family evidence.

<!-- canon-section: performance-resource-constraints -->
Snapshots, intents, indexing, handoffs, and background work are bounded, cancellable, idempotent, memory-safe, timeout-aware, and never assume background completion. Article 31 calibration must define representative projection/entity/payload scale, device/OS/build/tool, latency/launch/energy/memory measures, percentile/maximum, and regressions; no numeric budget is invented.
