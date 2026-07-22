+++
spec_id = "SYSTEM-APPLE-ECOSYSTEM"
title = "Apple Ecosystem"
kind = "system"
status = "normative"
owner_domain = "system-apple-ecosystem"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.apple.command-handoff", "system.apple.intents", "system.apple.platform-baseline", "system.apple.projection", "system.apple.share-handoff", "system.apple.widget-action", "system.apple.widget-projection"]
inherits = ["PLATFORM-NATIVE-IPHONE-001", "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001", "RUNTIME-MUTATION-SEQUENCE-001", "LAW-OFFLINE-NO-ACCOUNT-001"]
depends_on = ["CONSTITUTION", "APP-DEEP-LINKING", "SYSTEM-PRIVATE-LIFE-RUNTIME", "SYSTEM-PRIVACY-DATA-CLASSIFICATION", "SYSTEM-NOTIFICATIONS"]
source_owners = ["Native/Ambitions/App/", "Native/Ambitions/App/Intents/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Projections/", "Native/Ambitions/Projection/ExternalSnapshots/", "Native/AmbitionsWidgetExtension/", "Native/AmbitionsShareExtension/", "Native/Ambitions/Quality/"]
+++

# Apple Ecosystem

This target covers widgets, Lock Screen, App Intents/Shortcuts/Siri, Share, Spotlight, deep links, and lifecycle handoffs.

## SYSTEM-APPLE-PLATFORM-BASELINE-001 — iOS 26 native baseline

- **Concept:** `system.apple.platform-baseline`
- **Modality:** `MUST`
- **Scope:** Native app, extensions, platform API selection, and availability fallbacks
- **Status:** `normative`
- **Verification:** `AUDIT-SYSTEM-APPLE-PLATFORM-BASELINE-001`
- **Supersedes:** none

Ambitions MUST target iOS 26 or the repository-approved successor floor. The
current flagship implementation scope is iPhone, portrait, and single scene.
Landscape, iPad, Mac/Catalyst, visionOS, multiple windows, and external display
are outside current flagship scope and require a new product/platform decision.
Every selected Apple API MUST be valid for the approved floor; a newer API
requires an availability-gated fallback that preserves the owning product,
privacy, accessibility, and failure contract.

## SYSTEM-APPLE-PROJECTION-001 — Ecosystem surfaces use minimized disposable projections

- **Concept:** `system.apple.projection`
- **Modality:** `MUST`
- **Scope:** Widget, Lock Screen, Spotlight, App Group, shortcut/entity display, and app-switcher-sensitive presentation
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-APPLE-PROJECTION-001`
- **Supersedes:** none

Apple ecosystem surfaces MUST consume minimized, versioned, read-only, privacy-filtered Projections or snapshots. They do not open the canonical store, retain an unrestricted private graph, become a fifth root, or invent separate object identity. Sensitive content is hidden by default where ambient exposure is possible, and every visual/spatial action has semantic accessibility parity.

Apple ecosystem projections MUST NOT duplicate or unnecessarily expose the full private life graph.

App Group data MUST remain a minimized projection and MUST NOT become a second full private graph.

Extensions MUST NOT open unrestricted canonical stores or become independent mutation authorities.

## SYSTEM-APPLE-HANDOFF-001 — Every ecosystem action preserves command identity and safe fallback

- **Concept:** `system.apple.command-handoff`
- **Modality:** `MUST`
- **Scope:** Widget, notification, App Intent, Shortcut/Siri, Share, Spotlight, deep link, and background/lifecycle handoff
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-APPLE-HANDOFF-001`
- **Supersedes:** none

A mutating handoff MUST preserve minimum payload, source, stable command/
idempotency identity, privacy and confirmation requirements, timeout/
cancellation behavior, and safe open-app fallback. Widget, Live Activity,
Notification, App Intent, Siri/Shortcuts, and Share extension are separate
source-backed surfaces and require direct target/device proof. Spotlight is
planned only. External callbacks never mutate canonical state directly.

Supported categories SHOULD include Capture, Start, Complete, Add Proof, Show Today, Show next Event, schedule/reschedule with confirmation, and review pending external diffs.

Apple ecosystem handoff MUST preserve command identity and safe fallback and MUST NOT become an alternate private-graph store.

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
Stable approved Projection, policy, availability of required Apple frameworks, permission, and route/command input produce the same snapshot, action set, redaction, and fallback. Duplicate invocations resolve idempotently.

<!-- canon-section: observability -->
Local redacted evidence binds entry/snapshot/route/command IDs, schema/framework availability, permission/privacy state, timing/cancellation, result, fallback, Receipt, and refresh without private payload values.

<!-- canon-section: source-ownership -->
Canonical ownership is divided among App bridges, LocalRuntimeOS projections/effects, extension targets, and Quality.
Exact target owners are `App/`, `App/Intents/`, `Core/LocalRuntimeOS/Projections/`, `ExternalWrites/`, `Projection/ExternalSnapshots/`, widget/share targets, and `Quality/`. app-wide parity, availability review, extensions, entitlements, accessibility, device, and release proof are separate.

<!-- canon-section: tests-proof -->
Cover every entry point, snapshot privacy state, stale/protected data, permission denial, malformed/spoofed route/entity, duplicate command, timeout/cancel/termination, background handoff, Share preservation, open-app fallback, no direct store access/write, VoiceOver/Dynamic Type/Reduce Motion, API availability fallback, and device-family evidence.

<!-- canon-section: performance-resource-constraints -->
Snapshots, intents, indexing, handoffs, and background work are bounded, cancellable, idempotent, memory-safe, timeout-aware, and never assume background completion. Article 31 calibration must define representative projection/entity/payload scale, device/OS/build/tool, latency/launch/energy/memory measures, percentile/maximum, and regressions; no numeric budget is invented.

## SYSTEM-APPLE-INTENTS-001 — App Intents command boundary

- **Concept:** `system.apple.intents`
- **Modality:** `MUST NOT`
- **Scope:** App Intents command boundary
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-APPLE-INTENTS-001`
- **Supersedes:** none

App Intents MUST use canonical objects and validated runtime commands for Capture, object creation, Step start/completion, Proof, root/date navigation, and local Search; they MUST NOT require a cloud model. Material or ambiguous mutations MUST require confirmation.

## SYSTEM-APPLE-SHARE-HANDOFF-001 — Share handoff draft intake

- **Concept:** `system.apple.share-handoff`
- **Modality:** `MUST NOT`
- **Scope:** Share handoff draft intake
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-APPLE-SHARE-HANDOFF-001`
- **Supersedes:** none

Share intake remains separately capability-gated. When enabled, it MUST preserve
a bounded source reference and supported attachment before classification,
continue through the in-app Capture/owner proposal flow, and MUST NOT become an
alternate private-graph store. Durable draft and attachment claims require
direct extension, interruption, privacy, and device proof.

## SYSTEM-APPLE-WIDGET-ACTION-001 — Widget action boundary

- **Concept:** `system.apple.widget-action`
- **Modality:** `MUST`
- **Scope:** Widget action boundary
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-APPLE-WIDGET-ACTION-001`
- **Supersedes:** none

Every interactive widget action MUST validate through the canonical owner and
runtime sequence, preserve idempotency, and create a Receipt only when the
operation’s registry row requires one. Widget source presence alone does not
establish action, privacy, accessibility, device, or release proof.

## SYSTEM-APPLE-WIDGET-PROJECTION-001 — Widget projection boundary

- **Concept:** `system.apple.widget-projection`
- **Modality:** `MUST NOT`
- **Scope:** Widget projection boundary
- **Status:** `normative`
- **Verification:** `REVIEW-SYSTEM-APPLE-WIDGET-PROJECTION-001`
- **Supersedes:** none

Widgets MAY show minimized Now/Next, Today, Time, or Goal-next-action projections; Lock Screen content MUST honor user redaction and device-lock state, and widgets MUST NOT expose the full private graph or substitute for a root surface.
