+++
spec_id = "SYSTEM-NOTIFICATIONS"
title = "Notifications"
kind = "system"
status = "normative"
owner_domain = "system-notifications"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.notifications.object-aware", "system.notifications.external-effect"]
inherits = ["OBJECT-REMINDER-COMPLETION-001", "RUNTIME-MUTATION-SEQUENCE-001", "LAW-RUNTIME-DURABLE-SUCCESS-001", "PRIVACY-VISIBILITY-001", "PLATFORM-NATIVE-IPHONE-001"]
depends_on = ["CONSTITUTION", "APP-PERMISSIONS", "OBJECT-NOTIFICATION-RULE", "SYSTEM-PRIVATE-LIFE-RUNTIME", "SYSTEM-PRIVACY-DATA-CLASSIFICATION"]
source_owners = ["Native/Ambitions/Core/Permissions/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Projections/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Quality/"]
+++

# Notifications

This shadow specification defines notification policy and external-effect boundaries. It does not claim permission, delivery, Lock Screen privacy, action, device, or release proof.

## SYSTEM-NOTIFICATIONS-POLICY-001 — Notifications are contextual, object-aware, private, and non-coercive

- **Concept:** `system.notifications.object-aware`
- **Modality:** `MUST`
- **Scope:** Reminder, Event, protected window, reflow/review, proof, quiet hours, previews, and actions
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-NOTIFICATIONS-POLICY-001`
- **Supersedes:** none

Notification permission MUST be requested only when a user chooses notification-dependent behavior, with purpose, fields, fallback, and settings path explained. Rules bind a canonical object and user policy; previews redact sensitive content by default; copy is calm and non-shaming; quiet hours and duplicate-source risk are honored. Generic return prompts, productivity pressure, learning insights, and hidden private detail are forbidden.

Lock-screen notification copy SHOULD be private by default.

Notifications MUST NOT be aggressive, overly personal, or emotionally interpretive.

## SYSTEM-NOTIFICATIONS-EFFECT-001 — Scheduling and actions preserve local authority

- **Concept:** `system.notifications.external-effect`
- **Modality:** `MUST`
- **Scope:** Notification scheduling/removal/reconciliation and Complete, Start, Snooze, Reschedule, Add Proof, Open, and Review actions
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-NOTIFICATIONS-EFFECT-001`
- **Supersedes:** none

Local validated commit of a Notification Rule or object mutation MUST precede notification scheduling/removal. Delivery state is an outbox result, not canonical success. Every mutating action preserves command/idempotency identity and follows validation through Event, Projection, Receipt, and Replay; Reminder acknowledgment alone never completes underlying work.

Notifications MUST be object-aware and action-oriented.

Notification actions MAY include Complete, Start, Snooze, Reschedule, Add Proof, Open Event, and Review Reflow.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns notification permission posture, rule-to-request derivation, privacy preview, quiet-hour/duplicate policy, delivery reconciliation, and action handoff. It does not own object completion, surface navigation, external calendar alerts, canonical mutation, or guaranteed delivery.

<!-- canon-section: inputs-outputs -->
The contract consumes Notification Rules, object projections, permission/privacy/quiet-hour state, locale/time-zone, and durable outbox intent. It emits minimized requests, removal/reconciliation work, delivery state, action Commands, Receipt linkage, and privacy-safe presentation.

<!-- canon-section: authority-boundary -->
Notification APIs and callbacks are external adapters. They never open unrestricted stores, decide product policy, or mutate canonical state; `Commands/` validates actions and `ExternalWrites/` owns effects.

<!-- canon-section: data-classification -->
Titles, schedules, proof state, rationale, Goal links, and actions are private. Lock Screen payloads use explicit sensitivity policy and minimum fields; diagnostics record identifiers/results, not private copy.

<!-- canon-section: state-model -->
Rule and effect state distinguishes disabled, permission-not-requested/denied/allowed, scheduled, superseded, removed, delivered, acted, externally failed, and reconciled while retaining canonical object/rule identity.

<!-- canon-section: failure-recovery -->
Permission denial, stale schedule, DST/time-zone change, duplicate request, callback replay, or delivery failure preserves local objects and exposes contextual retry/settings/reconcile behavior. Relaunch rebuilds requests from current committed rules without duplicate actions.

<!-- canon-section: local-network-boundary -->
Local notifications, rules, actions, and reconciliation require no account/network. Denial or platform failure degrades alerts only and never blocks local planning/execution; no private notification content is sent to Ambitions backend/R2/Source Atlas.

<!-- canon-section: determinism -->
Stable committed rules, object facts, permission/privacy/quiet-hour state, locale/time-zone, and policy select the same request set and redaction. Callback duplication yields one canonical mutation.

<!-- canon-section: observability -->
Local redacted traces bind rule/object/request/command IDs, permission/privacy policy, scheduled time, delivery/action/reconciliation result, Receipt, and retry without message content.

<!-- canon-section: source-ownership -->
Exact targets are `Core/Permissions/`, `Core/LocalRuntimeOS/ExternalWrites/`, `Commands/`, and `Projections/`; `Surfaces/You/` presents settings and `Quality/` proves device/privacy/action behavior. Current permission/runtime/outbox source is not complete app-wide or device proof.

<!-- canon-section: tests-proof -->
Exercise contextual ask/denial, every rule/object class and action, preview privacy states, quiet hours, duplicates/external alerts, DST/time-zone/locale/significant-time changes, removal/update, callback replay/spoof, offline/relaunch, outbox failure/reconcile, Reminder noncompletion, VoiceOver actions, and physical-device Lock Screen behavior.

<!-- canon-section: performance-resource-constraints -->
Scheduling and reconciliation are bounded, cancellable, batched, lifecycle-safe, and off-main where material; callbacks finish promptly with safe fallback. Article 31 calibration must declare representative rule/request scale, device/OS/build/tool, timing/energy measures, percentile/maximum, and regression threshold; no numeric budget or device proof is asserted.
