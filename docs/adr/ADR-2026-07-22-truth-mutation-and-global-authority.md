# ADR-2026-07-22: Truth, Mutation, Receipt, Undo, Search, and Capture Authority

Status: Accepted
Date: 2026-07-22
Audit: RP-03 and RP-05 in `docs/audits/rp-01-08-evidence-audit/`
Owner decision: `docs/audits/rp-01-08-evidence-audit/13-owner-reconciliation-decisions.md`
Directions: `AVF-CAPTURE-S07-R01`, `AVF-SEARCH-D07-R01`, `AVF-RECOVERY-S07-R01`

## Shared truth-state algebra

The runtime exposes a shared algebra, not one universal storage enum. Each
state carries an owner, object or operation ID, revision, observed time,
provenance, and permitted transitions. A domain may extend the algebra only in
its owning specification.

| State | Meaning | May be shown as current truth? |
| --- | --- | --- |
| Current | Latest authoritative value known to the canonical owner | Yes |
| Proposed | Preview or simulation not yet accepted | No |
| Accepted | Committed by the canonical owner | Yes, after commit publication |
| External | Observed from a named external authority | Only as external truth |
| Stale | Previously known value beyond its freshness rule | Only with stale status |
| Unknown | The owner cannot establish the value | No |
| Historical | Former authoritative state retained for inspection | No |
| Saving | Commit is executing and no terminal result exists | No new truth yet |
| Pending | An accepted durable operation awaits later work | Only the pending fact |
| Settled changed | Terminal result changed accepted truth | Yes |
| Settled unchanged | Terminal valid no-op | Yes; prior truth remains |
| Blocked | Preconditions prevented authority commit | No change |
| Failed | Attempt did not reach its required terminal effect | Depends on commit boundary; disclose both sides |
| Conflict | Two claims cannot both satisfy an owned invariant | No winner until owner resolution |
| Recovering | A named retry/repair is active | No new truth yet |
| Recovered | Recovery reached a verified terminal result | Yes, as that result |
| Irreversible | Accepted effect has no supported inverse or compensation | Yes, with warning |
| Undo available | A proven inverse/compensating command is currently eligible | It is capability metadata, not truth itself |

`External`, `Stale`, `Pending`, `Conflict`, `Irreversible`, and `Undo available`
are qualifying dimensions where needed; implementations must not collapse them
into a single linear status when that would lose meaning.

## Mutation lifecycle

```text
Intent -> Preparation -> Validation -> Preview -> Confirmation
-> Authority Commit -> Projection Materialization -> External Side Effects
-> Settlement -> Receipt -> optional Undo -> Recovery
```

1. **Intent** records the user request and origin without changing truth.
2. **Preparation** resolves canonical identity, owner, expected revision, and
   capability.
3. **Validation** checks authorization, preconditions, freshness, invariants,
   duplication, and owner availability.
4. **Preview** presents proposed truth, consequence, uncertainty, external
   effects, reversibility, and confirmation requirement.
5. **Confirmation** is explicit when consequence, externality, destruction, or
   ambiguity requires it.
6. **Authority commit** is the only boundary that changes canonical truth.
7. **Projection materialization** publishes owner-derived views without making
   them owners.
8. **External side effects** execute through source adapters with durable
   correlation when asynchronous.
9. **Settlement** reports the complete typed outcome.
10. **Receipt** is written only when the mutation registry requires a durable
    record and the recorded result is known.
11. **Undo** is offered only while a proven typed inverse/compensation remains
    eligible.
12. **Recovery** retries or repairs a named failed/pending scope without
    replaying a completed commit.

### Terminal outcome rules

- A no-op validates current truth and settles unchanged; it is not fake success.
- A block before commit preserves accepted truth and records the reason only
  when policy requires a durable attempted-operation Receipt.
- A failure before commit changes no canonical truth.
- A failure after local commit exposes the local accepted revision and the
  failed external/projection effect separately.
- Projection failure never rolls back canonical truth implicitly; it creates a
  repairable materialization state.
- A stale expected revision rejects or enters an explicit owner conflict flow.
- Duplicate command identity returns the existing result and does not reapply
  the effect.
- Cancellation before commit preserves input and accepted truth. After commit,
  cancellation means stop remaining supported work, not erase history.
- Retry uses the same operation identity and scope; a new user intent uses a new
  command identity.
- Irreversibility must be disclosed before confirmation.

## Settlement contract

Atomic single-owner operations settle as one of `changed`, `unchanged`,
`blocked`, `failed`, or `unsupported`. They never synthesize a Settlement
Ledger.

Typed per-scope settlement may be introduced only when all are true:

1. the operation contains two or more independently authoritative scopes;
2. each scope has a stable ID, owner, expected revision, commit boundary, and
   terminal outcome;
3. completed, failed, deferred, uncertain, reversible, irreversible, and
   review-required scopes can be represented independently;
4. replay, retry, cancellation, privacy, Receipt, and accessibility semantics
   are specified per scope;
5. tests prove no completed scope is replayed while recovering another.

Until then, multi-owner work is split into atomic owner commits or stops after
preparation and owner handoff. A Settlement Ledger is forbidden without this
typed model.

## Receipt contract

Durable Receipts are required for registry-covered meaningful mutations whose
future inspection is necessary to understand changed truth, an external
effect, destructive consequence, recovery, or a time-bounded inverse. Routine
navigation, selection, query, preview, refresh, and cancellation create none.

| Outcome | Receipt rule |
| --- | --- |
| Success changed | Record command, owner, affected IDs, revision transition, consequence, external effect, and reversibility. |
| Success unchanged | Record only when the registry requires auditability; mark no-op explicitly. |
| Blocked/failed before commit | Record only for security, destructive intent, external reconciliation, or required recovery; never imply mutation. |
| Failure after commit | Record local accepted truth and each failed post-commit effect. |
| External effect | Record source, minimized correlation, verification time, and current outcome. |
| Partial | Forbidden until typed per-scope settlement is approved; then record each scope. |

Receipts remain local, use minimum necessary private content, link to affected
objects, and follow an explicit retention class. Discovery occurs through
object-linked Trust inspection or a supported local history view. Deleting a
Receipt under privacy policy does not rewrite canonical history. Replay uses
the source event/command record, not presentation copy from a Receipt.

## Undo contract

Undo is a new typed inverse or compensating command. Eligibility requires an
implemented command, supported owner, expected revision, unexpired policy, and
known external limitations. It runs the normal mutation lifecycle, preserves
the original history, and creates its own result/Receipt where required.

- **Undo**: user-invoked inverse or compensation for a prior accepted mutation.
- **Rollback**: internal transaction abort before the authority commit becomes
  accepted truth.
- **Restore**: governed recovery of an archived/deleted object or backup state.
- **Compensating action**: a new forward mutation that offsets an effect that
  cannot be directly inverted.

A rollback ID, snapshot, or prior value is not proof of executable Undo. Undo
failure leaves the original accepted state and reports the failed compensation.

## Conflict taxonomy

| Conflict | Audit posture | Owner | Required response |
| --- | --- | --- | --- |
| Duplicate command | Supported for covered authority | Mutation registry | Return prior result; do not replay effect. |
| Stale revision | Partially supported | Canonical object owner | Reject or request explicit revalidation. |
| Projection cursor | Partially supported | Projection owner | Rebuild from canonical cursor; do not edit projection as truth. |
| External duplicate | Partially supported | Source adapter plus domain owner | Reconcile source IDs before merge. |
| Concurrent domain edit | Partially supported in bounded flows | Canonical owner | Show competing revisions and owner-approved choices. |
| Calendar conflict | Planned, not implemented | Time | Preserve commitments; preview fit or owner choices. |
| Goal conflict | Absent as shared runtime capability | Goals | Preserve Goal/path truth; review relationship or lifecycle choice. |
| Identity conflict | Absent | Owning domain | Do not merge until explicit identity resolution. |
| Source disagreement | Planned through domain adapters | Domain owner plus adapter | Show source, freshness, and authority; do not silently choose. |
| Offline divergence | Planned, not implemented | Owner plus synchronization policy | Preserve local accepted truth and reconcile explicitly. |

Validation failure, missing permission, unsupported capability, stale data, and
insufficient context are not conflicts unless competing valid claims exist.

## Capture authority

Capture is a temporary global preparation surface. Its approved current
baseline is text input, bounded deterministic extraction, simple time
extraction, destination proposal, Accept/Change/Cancel, proven Quick Capture
creation, and proven Capture-to-Goal handoff.

A `CaptureDraft` has a session-stable ID, original expression, structured
fragments, correction lineage, proposed destination, origin, and capability
snapshot. Durability is optional and may be claimed only when a store,
restoration, deletion, and privacy contract exist.

```text
expression -> bounded extraction -> ambiguity check -> correction
-> consequence preview -> owner handoff -> owner revalidation/acceptance
-> atomic settlement -> capability-gated Receipt -> truthful return
```

Correction replaces only the disputed fragment and preserves unaffected
interpretation with provenance. Ambiguity that changes identity, destination,
time, or consequence must be clarified or left unresolved; Capture may not
guess. Conflict checks are limited to implemented destination capabilities.

Dictation, broad attachments, arbitrary semantic understanding, universal
cross-domain conflict detection, coordinated multi-root mutations, partial
settlement, and Capture-specific Undo are absent from the current baseline.
Future adapters remain hidden unless their capability manifest proves input,
interpretation, owner acceptance, failure, privacy, offline, settlement, and
return behavior.

## Search authority

Search is a local derived index and is never a mutation owner.

### Find

Find performs deterministic local retrieval and ranking over explicitly indexed
canonical identities. Results contain canonical ID, owner, result type, index
revision, provenance, and freshness. Open routes directly to the owner.

### Understand

Understand is limited to grounded object-backed explanation. It distinguishes
current, historical, inferred, proposed, external, stale, and unknown content;
identifies supporting local objects or Receipts; and states uncertainty and
freshness. It does not manufacture causal history or cross-root linkage.

### Act

```text
Search request -> resolve canonical object -> prepare operation
-> show consequence/uncertainty -> transfer to owner -> owner revalidates
-> owner confirms -> owner commits -> owner settles -> return to origin
```

Search may locally settle only non-mutating Open, Inspect, Compare, and Navigate
operations. Creation transfers to Capture; domain mutation transfers to the
canonical owner.

### Owner-transfer envelope

```text
OwnerTransferEnvelope {
  envelopeVersion
  objectReference
  owner
  sourceRevision
  originatingContext
  requestedAction
  preparedInput
  preview
  consequence
  uncertainty
  confirmationRequirement
  capabilitySnapshot
  commitResult?
  receiptID?
  undoEligibility?
  returnTarget
}
```

The owner re-resolves identity and revision and may reject the preparation. The
envelope does not grant authorization or contain copied canonical truth.

## Search failure correctness

| State | Meaning |
| --- | --- |
| No result | Query completed over declared coverage and matched nothing. |
| Read failure | Canonical read failed; results are not known empty. |
| Index unavailable | Index cannot answer. |
| Index stale | Index exists but missed its freshness rule. |
| Permission limitation | One or more declared sources cannot be read. |
| Unsupported query | Query requests unimplemented interpretation/action. |
| Ambiguous object | Multiple identities cannot be safely consolidated. |
| Conflict | Competing valid claims require an owner decision. |
| Partial coverage | Search completed only over named available domains. |

Repository, adapter, or index errors may never collapse to “no match.” Search
query persistence across relaunch is not promised.

## Capability gating and tests

Every command/presentation gate is backed by a registry row naming owner,
current implementation posture, settlement type, Receipt policy, Undo command,
offline behavior, privacy egress, failure states, and proof IDs. A type,
protocol, fixture, debug route, or test name is not an enabled capability.

Required tests cover lifecycle transitions; pre/post-commit failure; no-op;
deduplication; stale revision; replay; projection repair; external failure;
Receipt retention/linkage; actual Undo execution; Capture ambiguity/correction;
Search failure distinctions; owner transfer/revalidation; offline boundaries;
accessibility announcements; and focus return.

## Non-claims

No runtime type, registry, command, Receipt, Undo, Search, or Capture behavior
was implemented. No Figma, SwiftUI, or product implementation is authorized.
