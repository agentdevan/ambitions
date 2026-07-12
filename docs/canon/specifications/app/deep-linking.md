+++
spec_id = "APP-DEEP-LINKING"
title = "Deep Linking and External Route Entry"
kind = "app"
status = "normative"
owner_domain = "app-deep-linking"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "app.deep-linking.external-entry",
  "app.deep-linking.fallback",
  "app.deep-linking.privacy",
  "app.deep-linking.resolution",
  "app.deep-linking.state",
]
inherits = [
  "LAW-IA-NONROOT-001",
  "CONST-RUNTIME-MUTATION-001",
  "CONTROL-MATERIAL-CONFIRMATION-001",
  "LAW-LOCAL-AUTHORITY-001",
  "PLATFORM-NATIVE-IPHONE-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-NAVIGATION", "APP-DEGRADED-STATES"]
source_owners = [
  "Native/Ambitions/App/",
  "Native/Ambitions/PreviewSupport/",
  "Native/Ambitions/Quality/",
]
+++

# Deep Linking and External Route Entry

This shadow specification defines how trusted local route requests and external ecosystem entry resolve into app navigation.

## APP-DEEP-LINK-EXTERNAL-ENTRY-001 — External entry preserves owning-system boundaries

- **Concept:** `app.deep-linking.external-entry`
- **Modality:** `MUST`
- **Scope:** Share intake, Spotlight, widgets, App Intents, notifications, files, and approved deep-link sources
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEEP-LINK-EXTERNAL-001`, `AUDIT-APP-DEEP-LINK-MUTATION-001`
- **Supersedes:** none

External entry MUST resolve through a typed, allowlisted route contract. Share intake routes preserved source content into the owning Capture intake contract; Spotlight and glance surfaces index or carry only approved privacy-filtered local metadata; widgets, App Intents, notifications, and files route to the owning object, date, review, setting, or composer context. No external route may create a new root, bypass authorization or confirmation, or mutate canonical state directly.

## APP-DEEP-LINK-RESOLVE-001 — Resolution validates target and action separately

- **Concept:** `app.deep-linking.resolution`
- **Modality:** `MUST`
- **Scope:** Incoming route parsing, target lookup, eligibility, and optional action intent
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEEP-LINK-RESOLVE-001`, `SCENARIO-APP-DEEP-LINK-REJECT-001`
- **Supersedes:** none

Resolution MUST parse a versioned route identifier, validate source class and payload shape, resolve a local owner and target, and then validate any requested action as a separate step. Opening a destination may be allowed when mutation is not. A material action requires current authorization, consequence preview, confirmation where applicable, and the constitutional mutation sequence after the app is foregrounded in a comprehensible context.

## APP-DEEP-LINK-PRIVACY-001 — Routes disclose minimum necessary identity

- **Concept:** `app.deep-linking.privacy`
- **Modality:** `MUST`
- **Scope:** Route payloads, logs, Spotlight metadata, notification actions, extension handoff, and diagnostics
- **Status:** `normative`
- **Verification:** `PRIVACY-APP-DEEP-LINK-PAYLOAD-001`, `AUDIT-APP-DEEP-LINK-REDACTION-001`
- **Supersedes:** none

Route payloads MUST use opaque minimum-necessary identity and approved action parameters. They must not embed private titles, notes, proof, receipts, schedule assumptions, inferred priorities, or private graph context in URLs, public indexes, logs, analytics, or cross-process handoff unless a separately approved local protected channel and owning specification require the exact field. Invalid or unauthorized routes reveal no target existence.

## APP-DEEP-LINK-FALLBACK-001 — Unavailable targets degrade safely

- **Concept:** `app.deep-linking.fallback`
- **Modality:** `MUST`
- **Scope:** Missing, deleted, archived, trashed, locked, unauthorized, stale-version, and unsupported targets
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEEP-LINK-MISSING-001`, `SCENARIO-APP-DEEP-LINK-UNAUTHORIZED-001`
- **Supersedes:** none

An unavailable target MUST degrade to the nearest safe owning context without fabricating content or leaking why a protected target failed. When useful and authorized, the user may search locally, open the relevant root or setting, restore from Trash through the owning flow, update the app, or retry after unlocking. Unsupported versions fail closed and retain source input where the owning intake contract permits recovery.

## APP-DEEP-LINK-STATE-001 — Route handling is replay-safe and single-use where required

- **Concept:** `app.deep-linking.state`
- **Modality:** `MUST`
- **Scope:** Queued, resolving, presented, rejected, consumed, and recoverable external routes
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-DEEP-LINK-REPLAY-001`, `SCENARIO-APP-DEEP-LINK-INTERRUPTION-001`
- **Supersedes:** none

Deep-link state MUST distinguish queued, resolving, presented, rejected, consumed, and recoverable input. Repeated delivery may reopen an idempotent destination but cannot repeat a consumed mutation or duplicate Capture intake. Interruption preserves recoverable input and resumes only after revalidating target, authorization, canonical state, and user-visible consequence.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Deep linking owns typed external route intake, allowlisting, target/action resolution, minimum payloads, replay handling, and safe fallback. It does not own source-app behavior, canonical objects, destination UI, mutation policy, public indexing policy beyond route payloads, or extension implementation completeness.

<!-- canon-section: inputs-outputs -->
The resolver consumes one bounded typed envelope and emits one typed resolution result.

Inputs are route version, source class, opaque target reference, approved parameters, app lifecycle, local authorization, target eligibility, and optional recoverable content. Outputs are a validated navigation request, a separately validated action proposal, a safe fallback, or a rejection with no private disclosure.

<!-- canon-section: authority-boundary -->
Navigation owns presentation, destination specifications own behavior, Capture owns shared input intake, and LocalRuntimeOS owns mutation. Deep links are entry references only and cannot become roots, stores, object owners, or direct-write paths.

<!-- canon-section: data-classification -->
All route data is minimum-necessary local operational metadata unless the owning protected intake contract classifies preserved content more restrictively. Public URL/query text, Spotlight metadata, and diagnostic logs exclude private graph content by default.

<!-- canon-section: state-model -->
The route record uses explicit orthogonal fields for lifecycle, resolution, and authorization.

Route state includes source, version, opaque target, parameters, lifecycle state, resolution status, action eligibility, consumption token where needed, fallback, and redacted diagnostic reason. Target existence and authorization remain separate.

<!-- canon-section: failure-recovery -->
Resolution errors retain recoverable intake and produce a safe destination or rejection.

Malformed, stale, unknown, missing, locked, unauthorized, or interrupted routes fail closed. Recovery may update, unlock, retry, search locally, open a safe owner, or resume preserved intake; it never repeats a consumed mutation or reveals protected target facts.

<!-- canon-section: local-network-boundary -->
Local object, date, review, setting, Search, and Capture routes resolve offline without an account. A route cannot require a server redirect to discover private identity. Optional external/reference destinations own their own offline fallback.

<!-- canon-section: determinism -->
Route resolution is a pure decision over the declared typed inputs and current local facts.

The same route version, source class, payload, authorization, and current local state produce the same resolution or rejection. Free-form external text cannot choose arbitrary internal types, selectors, commands, or paths.

<!-- canon-section: observability -->
Redacted route evidence records the decision without copying protected payload content.

Evidence records source class, route version, redacted target class, resolution result, action eligibility, presentation result, fallback, and consumption/idempotency result. Private identifiers and payload content remain redacted in routine diagnostics.

<!-- canon-section: source-ownership -->
`App/` owns the registry, typed external-route models, translators, payload/overlay translation, and App Intent launch routing; preview routing remains non-authoritative; `Quality/` owns route, privacy, replay, and accessibility proof.

<!-- canon-section: tests-proof -->
The verification matrix executes each approved source class and route outcome.

Required proof covers every approved source class, versions, malformed and unknown routes, missing/deleted/trashed/locked targets, authorization denial, privacy redaction, offline resolution, duplicate delivery, interrupted intake, action confirmation, no direct mutation, focus restoration, VoiceOver destination announcement, Dynamic Type, and Reduce Motion.

<!-- canon-section: performance-resource-constraints -->
An external route envelope MUST be at most 16 KiB, use maximum nesting depth 8, and enter a queue capped at 32 items; larger or deeper input fails closed before allocation proportional to claimed size. On the oldest supported physical iPhone in an optimized build with 250 typed routes and maximum app route depth 20, parse plus local resolution MUST complete within 25 ms at P95 and presentation dispatch within 50 ms at P95 across 10,000 routes. The run MUST add no more than 8 MiB resident memory, perform zero synchronous disk I/O and zero network calls on resolution, and consume each single-use action at most once. Extension and app handling MUST use no polling or autonomous retry loop.
