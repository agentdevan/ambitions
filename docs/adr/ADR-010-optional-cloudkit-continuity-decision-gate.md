# ADR-010 Optional CloudKit Continuity Decision Gate

Status: Accepted as a future-only gate; implementation blocked

Date: 2026-05-31

Owners: Sync / Privacy / Persistence

## Context

Ambitions is local-first in the current runtime. Product truth allows a future Apple account / iCloud-style sync exception only for user-owned cross-device continuity. Implementation and release truth still say no active iCloud or CloudKit entitlement, container, source implementation, account flow, or validated sync behavior exists.

Existing source posture:

- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift` exposes only `SyncBackendKind.localOnly`.
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift` proves the only supported status is local-only and unavailable.
- `docs/audits/pfc09-icloud-cloudkit-sync-strategy-decision-report.md` defers launch sync.
- `docs/canon/Ambitions_CloudKit_Schema_Zone_Conflict_Model.md` is a future contract only.

## Decision

CloudKit continuity remains optional, Apple-native, private-database-only, and blocked from implementation until all gate evidence is Green and human/platform/privacy approval exists.

The current launch path remains local-only. No future Codex run may add CloudKit entitlements, containers, signing changes, account UI, sync runtime, persistence migration, or user-facing sync copy unless the readiness gate in `docs/architecture/APPLE_NATIVE_SYNC_CLOUDKIT_READINESS_GATE.md` is satisfied and updated with fresh proof.

## Schema Decision

Future CloudKit work may start only from the PFC10 contract and must re-confirm:

- one private custom zone for launch continuity unless an approved migration explains multiple zones
- record-family classification for goals, steps, captures, proof, receipts, memory signals, preferences, tombstones, and sync ledger metadata
- field classification as portable, sensitive, localOnly, derived, or receipt
- tombstone retention and delete-all-memory interaction
- export/import compatibility before any sync enablement

No production schema or SwiftData migration is approved by this ADR.

## Conflict Model

Future sync must be review-first:

- no silent destructive overwrite
- no silent goal, plan, memory, proof, receipt, or commitment mutation
- deletion/correction tombstones prevent resurrection
- ambiguous conflicts produce review receipts and keep local data durable
- SourceRecord, Receipt, ReplayTrace, and You / What Ambitions Knows inspection remain proof-bounded and user-reviewable

## Opt-In UX And Off Switch

Future UI must be explicit:

- default state: local-only unavailable
- enablement: user-initiated, iCloud-account-aware, and reversible
- off switch: pause future syncing while preserving local writes
- disable path: includes export, backup, conflict review, and rollback instructions
- unavailable states: not signed into iCloud, restricted iCloud, network unavailable, sync paused, sync needs review

No account wall may block basic Ambitions value.

## Privacy Copy

Allowed current copy:

```text
Ambitions is local-first in this build.
Sync is unavailable in the current local-only runtime.
Apple-native sync is an allowed future option only if privacy and migration proof are approved.
```

Forbidden copy concepts:

```text
Any claim that iCloud continuity already works.
Any claim that CloudKit-backed syncing already exists.
Any claim that user data already moves across devices.
```

Future privacy copy must explain private iCloud behavior, data classes, off switch, export/import, deletion, conflict review, account-unavailable behavior, and what remains local-only.

## Proof Tests

Before implementation can proceed, the proof plan must include:

- sync capability still reports local-only when CloudKit is absent
- account unavailable never blocks local app use
- zone creation and subscriptions are idempotent
- record encoding/decoding covers every approved record family
- tombstones prevent resurrection
- scalar conflicts create review receipts
- parent deletion versus child edit quarantines safely
- memory deletion/correction wins over stale remote state
- export/import remains compatible with synced records
- logs, notifications, widgets, Live Activities, App Intents, and reports do not leak private content
- enable, pause, disable, migration, rollback, and restore paths have proof

## Alternatives Considered

- Implement CloudKit now: rejected because privacy, migration, entitlement, device, legal, and proof gates are not Green.
- Keep launch local-only indefinitely: allowed as the current fallback, but not permanently decided here.
- Custom hosted backend: rejected for this gate because it conflicts with the Apple-native user-owned continuity posture and would require separate product, security, legal, account, and infrastructure approval.

## Consequences

This ADR allows planning language and fixture design only. It blocks runtime sync implementation by default and keeps release claims honest. The downside is continued lack of cross-device continuity until the gate is intentionally reopened and proven.

## Validation

AMB-382 validation is recorded in `docs/proof/afri/afri-030-optional-cloudkit-continuity-decision-gate-proof.md`.

## Reversal Path

Reversal requires a new ADR or explicit amendment that cites updated truth files, privacy/legal review, migration proof, rollback proof, device proof, and owner approval.

## Links

- `docs/architecture/APPLE_NATIVE_SYNC_CLOUDKIT_READINESS_GATE.md`
- `docs/audits/pfc09-icloud-cloudkit-sync-strategy-decision-report.md`
- `docs/canon/Ambitions_CloudKit_Schema_Zone_Conflict_Model.md`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/AmbitionsTests/Persistence/SyncCapabilityTests.swift`
