# ADR-2026-07-22: Canonical Identity, Ownership, and Projection

Status: Accepted
Date: 2026-07-22
Audit: RP-02 and RP-04 in `docs/audits/rp-01-08-evidence-audit/`
Owner decision: `docs/audits/rp-01-08-evidence-audit/13-owner-reconciliation-decisions.md`
Directions: `AVF-GOALS-S08-R00`, `AVF-TODAY-S10-R00`, `AVF-TIME-S07-R01`, `AVF-SEARCH-D07-R01`

## Decision

One meaningful object has one canonical identity and one mutation owner.
Today, Search, Capture, and cross-root views hold typed references or derived
projections; they do not copy canonical objects or become second owners.

This ADR specifies target architecture. Current source support remains bounded
by the RP evidence audit. In particular, `LifeAreaRecord`, canonical Event and
Schedule Placement identity, and several migrations below are planned and are
not current runtime capability.

## Canonical object model

### Life Area

`LifeAreaRecord` is a locally persisted user-owned record with stable ID,
localized user-editable name, optional meaning, explicit order, visibility,
lifecycle, created/updated revisions, and archive metadata. Goal membership is
represented by the Goal’s Life Area reference, not a copied Goal collection.

Archive removes the Life Area from active planning without deleting member
Goals or history. Removal requires an explicit reassignment or archive outcome
for each member Goal. Search projects active and archived identity with the
same ID. Restoration resolves the ID or falls back to Goals with a stale-target
explanation.

The existing enum-derived values are migration inputs only. Migration creates
deterministic records in former display order, maps every Goal reference, and
records the source value. A resumable migration must be idempotent and must not
create duplicates on replay.

### Goal, Goal Path, and Step

- Goal identity is stable through editing, completion, archive, Trash, and
  restore. Deletion uses existing governed deletion law.
- A Goal Path/Plan has its own stable ID, Goal ID, version, predecessor link,
  lifecycle, and effective interval. One current plan is designated by the
  Goal owner; older versions remain historical.
- Step identity survives projection, scheduling, completion, reopening,
  archive, and restore. A changed plan references or supersedes Steps rather
  than silently replacing identity.
- Goals owns Goal and path mutation, relationships, closure, archive, Trash,
  restore, and history. Time owns placement; Today owns only day admission and
  narrow execution actions authorized by the object owner.

### Event

`EventRecord` has stable local ID, optional series ID, occurrence identity,
source identity, source revision, time zone mode, interval/all-day meaning,
recurrence rule, cancellation state, edit authority, and history.

Imported source identity is `(sourceID, calendarID, externalEventID)` with an
occurrence key for recurrence exceptions. Re-import updates the existing
canonical link; it does not create a second Event. A local Event and external
observation merge only through an explicit match decision. External deletion
is recorded as source state and does not silently erase local history.

Series edits and occurrence edits are distinct commands. The source adapter
owns external authorization and reconciliation; Time owns the local Event
model and canonical edit policy.

### Schedule Placement

`SchedulePlacementRecord` is a stable relation between a placeable canonical
object and a temporal interval. It records ID, placed-object ID and type,
interval and time zone, authority state, source, protection, flexibility,
expected revisions, conflict references, history, and deletion/restoration.

Authority state is at least:

- `proposed`: simulation or suggestion; it is not scheduled truth;
- `accepted`: committed local placement;
- `external`: observed source commitment with source authority;
- `stale`: previously observed external truth whose freshness threshold passed.

A computed Goal time is never rendered as accepted placement without an
accepted Schedule Placement. Removing a placement removes the relation, not
the Goal, Step, Event, or historical record.

### Today admission relation

Today uses `TodayAdmission` rather than a Today-owned task:

```text
TodayAdmission {
  id
  localDay
  sourceObjectReference
  canonicalOwner
  reason
  dayConsequence
  role: startHere | alsoFitsNow | timeline
  permittedLocalAction
  ownerRoute
  derivationRevision
  expiresOrRecalculatesAt
}
```

At most one active relation is `startHere` and at most one earned relation is
`alsoFitsNow`. Recalculation expires or replaces the relation without changing
the source object. A future manual pin, if separately approved, is a typed
relation against the source identity, never a copied object.

### Receipt and settlement identity

A durable Receipt has a stable ID, source command/mutation ID, owning domain,
affected canonical object references, before/after revision references,
settlement outcome, timestamp, reversibility metadata, privacy class, and
history/retention status. A Receipt records what the owning operation actually
did; its presence does not prove Undo or partial settlement.

Receipt deletion follows privacy/retention policy and does not rewrite object
history or replay. Receipt discovery is object-linked Trust inspection and a
supported local You history view; it is not a new root.

## Identity and ownership matrix

| Object | Canonical/edit/mutation owner | Read and projection owners | Search owner | Receipt/conflict/history/deletion owner |
| --- | --- | --- | --- | --- |
| Life Area | Goals | Goals; referenced by Today/Time where relevant | Search indexes Goals identity | Goals |
| Goal | Goals | Goals; Today/Time projections | Search indexes Goals identity | Goals, with Trust inspection |
| Goal Path/Plan | Goals | Goals; Step/Time projections | Search when supported | Goals, with Trust inspection |
| Step | Goals | Goals; Today admission; Time placement | Search indexes canonical Step | Goals for lifecycle; Time for placement conflict; Trust for inspection |
| Event | Time | Time; Today timeline | Search indexes canonical Event | Time and source adapter; Trust for inspection |
| Schedule Placement | Time | Time; Today chronology; Goal/Step context | Search only when explicitly indexed | Time |
| Today Admission | Today projection engine | Today only; owner routes consume the reference | Not independently searchable | Today derivation history; source owner retains object history |
| Personal context/preference | You or named system owner | Minimized Today/Time projection | Search only if explicitly visible | Owning preference/system domain |
| Capture Draft | Capture until transfer | Capture | Not canonical Search content | Capture; owner takes accepted object history |
| Search Result | Search derived index | Search | Search | No independent history/deletion; canonical owner controls object |
| Receipt | Mutation owner/Receipt store | Affected object and Trust/You inspection | Search only when approved | Mutation owner plus retention policy |

“Read owner” grants projection access, never editing authority. Conflict owner
is the domain whose invariant is in conflict; source disagreement also involves
the adapter but does not transfer canonical ownership.

## Projection lineage

| Projection | Lineage and owner rule |
| --- | --- |
| Life Area → Goals | Direct canonical record grouped by explicit order. |
| Goal → Today | `TodayAdmission` retains Goal ID and owner route; no copied Goal. |
| Step → Today | `TodayAdmission` retains Step ID, expected revision, reason, consequence, and local action. |
| Goal/Step → Time | `SchedulePlacementRecord` or proposed placement references the canonical object. |
| Event → Today | Timeline admission references Event/occurrence identity and Time owner. |
| Event → Search | Index record contains canonical ID, owner, source/freshness summary, and index revision. |
| Schedule Placement → Time | Time reads its canonical relation; other roots receive minimized references. |
| Personal context → Today/Time | Owning preference/context domain emits a purpose-limited projection with provenance. |
| Capture → owner | Typed owner-transfer envelope; owner creates or mutates canonical data. |
| Search → owner | Typed owner-transfer envelope; Search never commits the domain mutation. |
| Receipt → object/You | Object reference plus local Trust inspection; no duplicate Receipt. |

Every stored projection includes source ID, source revision/cursor, projection
version, and materialization status. Missing or stale lineage is visible and
repairable; it never silently becomes current truth.

## Mutation authority matrix

| Action | Local action owner | Required handoff |
| --- | --- | --- |
| Rename/reorder/archive Life Area | Goals | None |
| Create/edit/close/archive/restore Goal | Goals | Today/Search/Capture must transfer |
| Start/complete a Step | Goal/Step mutation owner | Today may invoke a narrow typed command |
| Add/move/protect/delete placement | Time | Today/Search/Capture transfer |
| Edit Event/series/occurrence | Time and source adapter | Today/Search/Capture transfer |
| Admit/recalculate Start Here | Today projection engine | Does not mutate source object |
| Change canonical preference | You or named preference owner | Other roots transfer |
| Commit Capture proposal | Destination owner | Capture transfers and awaits result |
| Commit Search Act request | Destination owner | Search transfers and awaits result |

## History and deletion

| Object | Archive | Trash/restore | Permanent deletion | Historical identity |
| --- | --- | --- | --- | --- |
| Life Area | Supported target | Planned with member-resolution rule | Governed destructive action | Stable ID retained in history |
| Goal/Path/Step | Existing canon target | Governed by owner | Governed deletion and tombstone | Version lineage retained |
| Event/occurrence | Target | Source-dependent | Time/source authority | Cancellation and source history retained |
| Schedule Placement | Not archive; supersede/remove | Restore only through a new accepted command | Relation deletion per retention | Prior placement remains historical |
| Today Admission | Expires/recalculates | No Trash | Derived record may expire | Source object history remains canonical |
| Receipt | Retention state | No object restore | Privacy-governed deletion | Deletion does not rewrite source history |

## Unsupported objects and labels

Until runtime identity exists, active UX must omit or label as proposed:

- editable Life Areas backed only by fixed enum values;
- Event series/occurrence controls without canonical Event identity;
- accepted placement claims derived only from computed Goal time or a
  `TimeBlock` observation;
- cross-root identity consolidation without a canonical ID bridge;
- a Today priority/task record copied from Goal, Step, or Event;
- synthetic Receipt, Undo, conflict, history, or provenance labels.

## Migration order

1. Inventory and freeze legacy IDs and enum encodings.
2. Add idempotent Life Area records, then migrate Goal membership.
3. Define and test the Goal/Step ID bridge before rebuilding projections.
4. Add Event source/series/occurrence identity and import reconciliation.
5. Add Schedule Placement identity and accepted/proposed/external states.
6. Rebuild Today, Time, and Search projections from canonical identities.
7. Compare counts, references, replay digests, deletion behavior, and Search
   results before cutover.
8. Remove duplicate or enum authority only after rollback and parity proof.

## Risks and alternatives

- Keeping enum Life Areas is simpler but contradicts editable stable identity.
- Treating `TimeBlock` as both observation and placement avoids migration but
  cannot express accepted versus proposed/external truth.
- Storing Today cards is convenient but creates a second owner and stale-copy
  risk.
- Fuzzy Search consolidation without canonical linkage can merge distinct
  private objects; it remains prohibited.

## Non-claims

This ADR does not implement records, stores, migrations, projections, Search,
Capture, Goals, Today, or Time. It does not authorize Figma, SwiftUI, or product
implementation.
