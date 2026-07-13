+++
spec_id = "APP-PERMISSIONS"
title = "Contextual Permissions"
kind = "app"
status = "normative"
owner_domain = "app-permissions"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "app.permissions.contextual-request",
  "app.permissions.denied-fallback",
  "app.permissions.reconciliation",
  "app.permissions.recovery",
  "app.permissions.state",
]
inherits = [
  "PRIVACY-VISIBILITY-001",
  "LAW-OFFLINE-NO-ACCOUNT-001",
  "CONTROL-FORCE-NOTHING-001",
  "PLATFORM-NATIVE-IPHONE-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
  "CONST-PROOF-EVIDENCE-001",
]
depends_on = ["CONSTITUTION", "APP-LAUNCH-SETUP", "APP-DEGRADED-STATES"]
source_owners = [
  "Native/Ambitions/Core/Permissions/",
  "Native/Ambitions/Core/LocalRuntimeOS/Boundary/",
  "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/",
  "Native/Ambitions/Surfaces/You/",
  "Native/Ambitions/Quality/",
]
+++

# Contextual Permissions

This shadow specification defines permission request, denial, recovery, and reconciliation behavior.

## APP-PERMISSIONS-CONTRACT-001 — Every request explains its boundary

- **Concept:** `app.permissions.contextual-request`
- **Modality:** `MUST`
- **Scope:** Every system or app-managed permission request
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-PERMISSION-REQUEST-001`, `AUDIT-APP-PERMISSION-COPY-001`
- **Supersedes:** none

Every permission request MUST occur in the context of a user-understandable feature and state: what the feature needs, what Ambitions reads or writes, what remains available without permission, and where the choice can later be changed. The app asks only when the capability is relevant and the user has a meaningful choice. Setup may explain a future capability but cannot batch-request unrelated access or treat consent as mandatory product completion.

Ambitions MUST NOT open with a permission wall.

## APP-PERMISSION-DENIAL-001 — Denial preserves useful local behavior

- **Concept:** `app.permissions.denied-fallback`
- **Modality:** `MUST`
- **Scope:** Denied, restricted, unavailable, or not-yet-requested permission states
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-PERMISSION-DENIED-001`, `SCENARIO-APP-PERMISSION-RESTRICTED-001`
- **Supersedes:** none

Denial MUST produce a useful degraded state rather than a dead end. The owning feature continues with local manual entry, local-only content, reduced integration, or another explicitly specified fallback. The app does not repeatedly prompt, shame, conceal core actions, or imply that denied access erased existing Ambitions-owned data.

Prompts MUST be contextual and explain value.

## APP-PERMISSION-STATE-001 — Permission state remains distinct from feature data

- **Concept:** `app.permissions.state`
- **Modality:** `MUST`
- **Scope:** Authorization status, request eligibility, and feature availability
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-PERMISSION-STATE-001`, `AUDIT-APP-PERMISSION-DATA-SEPARATION-001`
- **Supersedes:** none

Permission state MUST distinguish not determined, authorized, limited where the platform supports it, denied, restricted, and unavailable. This authorization axis remains separate from source freshness, local data availability, import state, account state, and external-write result. A permission transition cannot independently create, delete, import, or mutate a canonical Ambitions object.

## APP-PERMISSION-RECOVERY-001 — Recovery uses exact settings and safe return

- **Concept:** `app.permissions.recovery`
- **Modality:** `MUST`
- **Scope:** Later enablement, revocation, and settings recovery
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-PERMISSION-SETTINGS-001`, `SCENARIO-APP-PERMISSION-REVOCATION-001`
- **Supersedes:** none

When the platform permits recovery through Settings, Ambitions MUST present an exact, user-initiated path and explain the consequence before leaving the app. On return or foreground activation, the owning feature re-reads authorization, reconciles its projection, restores focus, and shows the resulting capability state. Revocation preserves Ambitions-owned local objects and marks only the affected external capability unavailable or stale.

## APP-PERMISSION-RECONCILE-001 — Authorization changes reconcile deterministically

- **Concept:** `app.permissions.reconciliation`
- **Modality:** `MUST`
- **Scope:** Foreground, relaunch, extension entry, and external authorization change
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-PERMISSION-RECONCILE-001`, `SCENARIO-APP-PERMISSION-PARTIAL-001`
- **Supersedes:** none

Authorization changes MUST reconcile through the owning capability without silently accepting external data or replaying a previously rejected action. Pending work is revalidated against current authorization and canonical state. Partial external results remain inspectable and recoverable; an authorization change does not convert an external candidate into an Ambitions object or mark an external write successful.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
This system owns contextual request eligibility, authorization-state interpretation, denied fallback routing, Settings recovery, and authorization reconciliation. It does not own platform authorization, feature-specific data use, imports, external writes, privacy approval, or canonical mutation.

<!-- canon-section: inputs-outputs -->
Inputs are explicit user intent, owning-feature need, platform authorization state, request history, app lifecycle, and capability fallback. Outputs are request/no-request, a scoped explanation, current availability, degraded fallback, Settings recovery, and a reconciliation signal to the owning feature.

<!-- canon-section: authority-boundary -->
Permission coordination mediates access while product and data authority stay with their owning systems.

Privacy and user-control laws set the floor. Each feature specification owns why it needs data and its fallback. Permissions mediate access only and never become a private-data owner, import owner, mutation authority, or release approval.

<!-- canon-section: data-classification -->
Authorization status is local security metadata. Permission rationale may identify a capability but must not disclose sensitive object content. Data obtained after authorization retains the classification and egress limits of its owning feature.

<!-- canon-section: state-model -->
Authorization, request eligibility, fallback, and reconciliation remain separate state axes.

Authorization states are not determined, authorized, limited, denied, restricted, and unavailable. Separate axes track request eligibility, feature fallback, pending reconciliation, and last-known platform state; these axes do not collapse into sync or source freshness.

<!-- canon-section: failure-recovery -->
Request API failure, Settings-return failure, revocation, and partial external access produce a bounded degraded state with retry, manual fallback, or exact recovery. Existing local data remains intact and no unauthorized action is replayed automatically.

<!-- canon-section: local-network-boundary -->
Permission interpretation, local fallback, and Settings recovery require no account or Ambitions network. Authorization never becomes a reason to send private context to an external service.

<!-- canon-section: determinism -->
Given the same platform state, request history, feature need, and explicit user action, the permission system produces the same request eligibility and fallback. It does not infer consent from usage, setup completion, or account state.

<!-- canon-section: observability -->
Evidence records permission class, prior and current authorization, request decision, fallback selected, Settings handoff, and reconciliation result without protected resource content.

<!-- canon-section: source-ownership -->
`Core/Permissions/` maps platform authorization and request coordination; LocalRuntimeOS Boundary and PrivacySecurity enforce capability and egress law; You owns global discoverability and repair; `Quality/` owns verification. Existing files are implementation evidence only.

<!-- canon-section: tests-proof -->
Required proof covers every state transition, first request, denial, repeated denial without nagging, restriction, limited access where supported, revocation, Settings return, foreground reconciliation, offline fallback, local-data preservation, VoiceOver explanation/actions, Dynamic Type, and focus restoration.

<!-- canon-section: performance-resource-constraints -->
For 8 declared permission classes on the oldest supported physical iPhone in an optimized build, cached authorization lookup MUST complete within 10 ms at P95, a platform-state refresh excluding system-owned prompt time within 100 ms at P95, and foreground reconciliation within 250 ms at P95 across 1,000 checks. The reconciliation queue MUST cap at 8 classes and coalesce duplicate lifecycle signals. One thousand checks MUST add no more than 2 MiB resident memory and perform zero network calls and zero synchronous disk writes. A failed platform read may retry once per foreground transition; further retry requires a new lifecycle event or user action. Permission coordination MUST not poll in foreground or background.
