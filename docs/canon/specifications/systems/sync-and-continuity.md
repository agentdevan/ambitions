+++
spec_id = "SYSTEM-SYNC-CONTINUITY"
title = "Sync and Continuity"
kind = "system"
status = "normative"
owner_domain = "system-sync-continuity"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.continuity.user-owned-cloudkit", "system.continuity.disabled-gate"]
inherits = ["LAW-LOCAL-AUTHORITY-001", "LAW-OFFLINE-NO-ACCOUNT-001", "LAW-ACCOUNT-BOUNDARY-001", "PRIVACY-CLOUDKIT-CONTINUITY-001", "LAW-DATA-LOSS-STOP-SHIP-001"]
depends_on = ["CONSTITUTION", "SYSTEM-PRIVATE-LIFE-RUNTIME", "SYSTEM-PERSISTENCE-REPLAY", "SYSTEM-PRIVACY-DATA-CLASSIFICATION", "SURFACE-YOU"]
source_owners = ["Native/Ambitions/Core/LocalRuntimeOS/Continuity/", "Native/Ambitions/Core/LocalRuntimeOS/Boundary/", "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Quality/"]
+++

# Sync and Continuity

This shadow target specifies a possible user-owned CloudKit continuity boundary. Continuity remains disabled; source scaffolding or tests do not constitute approval, enablement, production CloudKit proof, or release readiness.

## SYSTEM-CONTINUITY-SEPARATION-001 — CloudKit continuity is separate and locally subordinate

- **Concept:** `system.continuity.user-owned-cloudkit`
- **Modality:** `MUST`
- **Scope:** Optional private-graph continuity across the user's Apple devices
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-CONTINUITY-SEPARATION-001`
- **Supersedes:** none

User-owned CloudKit continuity MUST remain separate from Ambitions Account identity/entitlement and R2/Source Atlas public-reference infrastructure. Local device state remains readable, mutable, replayable, and authoritative offline; CloudKit transports only explicitly eligible versioned envelopes and never becomes command, policy, sole-copy, or local-core authority. Sign-out and account deletion do not delete local data without a separate explicit destructive action.

## SYSTEM-CONTINUITY-DISABLED-001 — Continuity stays disabled until the full gate passes

- **Concept:** `system.continuity.disabled-gate`
- **Modality:** `MUST`
- **Scope:** Any CloudKit container, schema, zone, upload, download, merge, restore, or user-facing enablement
- **Status:** `normative`
- **Verification:** `PRIVACY-CLOUDKIT-APPROVAL-001`, `SCENARIO-SYSTEM-CONTINUITY-GATE-001`
- **Supersedes:** none

Continuity MUST stay disabled until owner-approved design and executable exact-revision proof cover: data classification and explicit consent; local source-of-truth authority; user-private container, encryption/key and Ambitions Account separation; stable record/schema/causal identity; deterministic merge and human conflict quarantine; tombstones/deletion propagation; offline divergence; retry, batching, quotas, token expiry and partial failure; iCloud unavailable/disabled/account change/device removal; backup/restore and duplicate prevention; sign-out/delete/reset; old-client compatibility and minimum upgrade; development/production environment separation; schema migration and rollback; privacy/security/threat review; interruption/relaunch; diagnostics/observability; and release rollback. Every cell is conjunctive; scaffolding, prose, or partial tests cannot enable a subset.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns optional continuity eligibility, envelope transport, causal merge, conflict/quarantine, tombstone propagation, sync state, and enablement gate. It does not own Ambitions Account identity, R2, public references, canonical command decisions, local store meaning, backup as a synonym for sync, or current enablement.

<!-- canon-section: inputs-outputs -->
Inputs are committed local event/object envelopes, stable identities, schema/policy revisions, causal clocks, tombstones, eligibility/consent, local/account/iCloud state, server tokens, and environment. Outputs are disabled/eligible state, upload/download batch, deterministic merge or quarantine, local Command proposal, sync cursor/status, conflict review, and Receipt/history.

<!-- canon-section: authority-boundary -->
Downloaded facts cannot mutate canonical state directly; they enter the runtime mutation sequence as validated idempotent Commands. Local commit precedes upload. CloudKit, Ambitions Account, and R2 remain distinct capabilities and stores.

<!-- canon-section: data-classification -->
Only approved private-continuity envelopes may enter the user's private CloudKit boundary after the full gate. Account/R2/Source Atlas never receive them. Attachments and highly sensitive fields require explicit eligibility, protection, quota, tombstone, restore, and deletion rules.

<!-- canon-section: state-model -->
The state model binds continuity capability, causal progress, and recovery action.
Global and per-envelope states distinguish disabled, ineligible, eligible-not-enabled, enabled-idle, local-pending, uploading, remote-pending, merging, conflicted/quarantined, retrying, paused, unavailable, signed-out, migrating, restoring, and blocked. Disabled is the required current target state until gate proof exists.

<!-- canon-section: failure-recovery -->
Conflict never silently last-write-wins; unresolvable change is quarantined for human review. Partial failure retains local truth and causal progress, retry is idempotent, token/account/environment change revalidates, and restore uses a reviewed causal plan. Any silent-loss path is P0 Red.

<!-- canon-section: local-network-boundary -->
All Today/Goals/Time/You/Capture/Search, mutation, proof/history, learning, and replay remain complete without CloudKit, Ambitions Account, or network. Continuity outage only degrades continuity and cannot coerce sign-in.

<!-- canon-section: determinism -->
Equivalent versioned envelopes, causal metadata, local state, merge policy, and tombstones yield the same merge, rejection, or quarantine. Arrival timing and device order cannot silently change meaning.

<!-- canon-section: observability -->
Local redacted traces bind each envelope and cursor to one continuity result.
Local redacted sync evidence includes environment/container class, enablement-gate revision, envelope/cursor/causal IDs, batch/result, retries, conflicts/quarantine, tombstones, account/iCloud state, restore/migration phase, and Receipt without private content.

<!-- canon-section: source-ownership -->
Canonical ownership resides in the exact Continuity, Boundary, PrivacySecurity, and Inspection domains.
Exact target owner is `Core/LocalRuntimeOS/Continuity/`, with `Boundary/`, `PrivacySecurity/`, and `Inspection/` enforcement; `Surfaces/You/` presents controls and `Quality/` owns gate proof. Current Continuity source/tests are source-present only; production enablement, CloudKit schema/container, full app-wide consumption, approvals, device matrix, migration/restore, and release proof remain absent.

<!-- canon-section: tests-proof -->
Executable gate scenarios exercise every required continuity and separation cell.
Test the entire disabled gate, separation from Account/R2, local-first offline mutations, two-device conflicts, deterministic merge/quarantine, tombstones/deletion, duplicates, partial batches, token/quotas/network, iCloud/account/device changes, old clients, environment separation, migrations/rollback, backup/restore, sign-out retention, explicit deletion, interruption/relaunch, privacy attacks, and exact-revision production procedures. No test subset authorizes enablement.

<!-- canon-section: performance-resource-constraints -->
Envelope creation, batching, merge, retry, attachment work, and reconciliation are bounded, cancellable, backpressured, off-main where material, and lifecycle-safe. Article 31 calibration must define device/OS/build, graph/envelope/device/conflict/blob scale, network conditions, tools, percentile/maximum, memory/energy/storage/quota, and regression thresholds; no budget or readiness is claimed here.
