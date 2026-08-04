+++
initiative = "generalized-life-branch-simulation"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Add `GeneralizedLifeBranchCoordinator` over a registered set of
`LifeBranchOwnerParticipant` adapters. A `LifeBranchSnapshotAssembler` creates a
consistent immutable baseline; deterministic simulation validates complete
branches. On confirmation, owners independently prepare typed deltas. A protocol
selector uses shared local atomic commit only when every owner proves support;
otherwise `LifeBranchSagaCoordinator` journals ordered commit/compensation.
External intents are handed to, never executed by, the branch.

## User flows

1. A portfolio/changed-reality flow proposes Life Branch review; qualifier shows
   why multi-owner reconciliation is necessary and the keep-current alternative.
2. Snapshot/branch preview lists affected/unchanged owners, assumptions,
   constraints, consequences, unknowns and external intents.
3. Comparison shows full before/after, operation order, reversibility and
   sensitivity. User edits assumptions, chooses another branch, saves or exits.
4. Selecting **Review changes** requests owner validation and shows any conflicts.
5. Final confirmation shows exact local atomic/saga protocol, undo/compensation
   limits and explicitly separate external actions.
6. Commit progress reports each owner. Success creates linked receipts. Failure
   shows abort or reconciliation-required with retry/compensate/manual options.
7. External intents, if any, appear afterward as separate unconfirmed actions.

## States and recovery

Gate: `conformanceOnly`, `eligible`, `revoked`. Branch: `draft`, `simulating`,
`ready`, `incomplete`, `stale`, `selected`, `validatingOwners`, `prepared`,
`committing`, `committed`, `aborting`, `aborted`, `compensating`,
`reconciliationRequired`, `reconciled`, `expired`, `deleted`.

Owner operation phases: `proposed`, `valid`, `prepared`, `committed`, `aborted`,
`compensationPending`, `compensated`, `failed`, each with durable phase receipt.
One branch actor serializes state. A durable journal is fsync/transactionally
advanced before/after side effects as appropriate. Relaunch derives work from
receipts and idempotency keys; it never reuses expired confirmation or external
consent.

## Architecture and data

Add under `Native/Ambitions/Core/LocalRuntimeOS/Simulation/LifeBranch/`:

- activation gate, qualification and snapshot models/assembler;
- branch/assumption/consequence/unchanged/external-intent models;
- operation/precondition/dependency/reversibility/compensation models;
- deterministic simulator, completeness/graph/semantic validator;
- comparison/sensitivity/explanation projector;
- owner participant registry/protocol and prepared token vault;
- protocol selector, atomic coordinator and saga coordinator;
- journal, branch/owner receipt assembler, replay/recovery/reconciler;
- external action draft-input builder;
- repository, migration, invalidation, archive/delete/purge;
- privacy/security/evaluation diagnostics.

`LifeBranchOwnerParticipant` exposes snapshot, validate, prepare, commit, abort,
compensate, status and reconcile. Prepared tokens are opaque, branch/plan/revision/
expiry bound and protected; only their owner interprets them. Owners declare
shared transaction domain ID, idempotency behavior and compensation limits.

Atomic selection requires same proven transaction domain and compatible prepare/
commit contract for every operation. Otherwise saga prepares all first, commits
topologically, and on fault compensates in reverse dependency order where safe.
Unknown/non-compensatable local operation requires an explicit irreversible
protocol and stronger preview or blocks under policy; no false rollback.

The branch stores semantics/IDs/hashes and allowed preview excerpts, not copied
owner stores. External intent contains provider/action class/public target and
required local payload-field categories, never credentials or executable
payload. External owner rebuilds it from current truth.

Migration accepts v1 branch drafts only when changed/unchanged owners,
preconditions, reversibility and exact revisions reconstruct; otherwise
inspection-only. Deleting uncommitted data purges drafts/snapshots/prepared
tokens/journals not required for recovery/explanations/feedback/exports. Committed
receipts follow History and owner retention; purge cannot break recovery truth.

## Privacy and accessibility

Owner snapshots and prepared commands remain protected local data; no whole
graph/model/public/telemetry egress. Diagnostics expose IDs/phases/reasons/counts,
no payload. Generative explanation, if enabled, receives validated semantic
aliases only and cannot access prepared tokens.

Each branch has an ordered outline: purpose/assumptions, affected and unchanged,
before/after, operation order, reversibility/external, unknowns and actions.
Progress/recovery never relies on animation/color. VoiceOver, Voice Control,
Switch Control, keyboard, largest Dynamic Type, Reduced Motion, RTL and focus/
announcement recovery cover compare, confirm, commit, failure and reconciliation.

## Requirement traceability

| Scope | Design decision |
|---|---|
| REQ-001 | Strict qualifier and keep-current branch |
| REQ-002 | Consistent complete snapshot/branch model |
| REQ-003 | Owner participant prepare/commit protocol; opaque tokens |
| REQ-004 | Typed bounded dependency graph/topological validation |
| REQ-005 | Exact reversibility/compensation models/copy |
| REQ-006 | Deterministic simulator/non-prediction validator |
| REQ-007 | Alias-only optional explanation |
| REQ-008 | Expiring baseline/plan-bound final confirmation |
| REQ-009 | Proven atomic selector or journaled saga |
| REQ-010 | Owner phases and reconciliation-required recovery |
| REQ-011 | Intent-only external draft builder |
| REQ-012 | Branch/owner receipts and idempotent replay |
| REQ-013 | Protected stores/token vault/scoped purge/history boundary |
| REQ-014 | Per-branch/owner/protocol evidence metadata |
| REQ-015 | Ordered accessible branch/progress/recovery projections |
| REQ-016 | Signed activation gate, conformance-only default |

## Verification design

- Qualification/completeness/snapshot consistency/keep-current fixtures.
- Owner participant contract tests for stale/reject/prepare/commit/abort/
  compensate/status/reconcile/idempotency.
- Atomic versus saga selection, every phase fault, reverse compensation,
  relaunch and stuck recovery; no false success/undo.
- Dependency cycle/unknown/budget/injection/tampered-token security tests.
- External spies proving zero effect/credential/payload and fresh action handoff.
- Migration/archive/delete/purge and committed-history integrity tests.
- Privacy/bias/dignity, accessibility and physical-device performance at bounds.
- Signed upstream activation/user comprehension evidence gate.

## Open decisions

None. Each owner set determines atomic versus saga through declared/proven
capabilities; unsupported/unknown operations remain simulation-only.

Review verdict: **PASS** after two reconciliation rounds. Review made prepared
tokens opaque/expiring, required prepare-all before saga, preserved recovery
receipts and isolated external payload/credentials. Devan delegated approval;
Design approved 2026-08-04.
