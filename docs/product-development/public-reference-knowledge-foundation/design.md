+++
initiative = "public-reference-knowledge-foundation"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

The foundation adds a source-preserving public-claim envelope and a plain
source-inspection route over Source Atlas's existing verified public delivery.
It validates exactly one corpus: O*NET 30.3, United States Software Developers
`15-1252.00`, limited to O*NET-owned occupation identity and descriptive task,
skill, knowledge, work-activity, work-context, education, and experience facts.
No BLS fact, ESCO link, employer requirement, qualification, or personal-fit
claim enters this corpus.

Every visible fact is projected from an immutable source-native record plus
claim-specific authority, jurisdiction, release, retrieval/freshness, rights,
review, risk, conflict, and supersession state. Missing required fields make
that claim unavailable. A source-level `official` flag is never sufficient.
Crosswalks use the same provenance-bearing claim contract and never merge
source-native identity.

Source Atlas remains public/reference/freshness infrastructure. The inspection
experience performs no private matching and issues no canonical mutation. The
existing private-context path composer under `SourceAtlas/` is not reused by
this design; later consumers must perform any private join in local Planning.
Bundled or last-verified claims remain inspectable offline, while absence is
reported honestly without affecting the local core.

## User flows

### Open the validation corpus

1. In You > Data & Privacy, the user opens `Public reference sources`. This is
   a bounded Trust inspection entry, not a Source Atlas dashboard or pack
   browser.
2. The page identifies the only supported slice: `O*NET 30.3 — Software
   Developers (15-1252.00), United States`. It states separately:
   - delivery: bundled, cached verified, last verified, or unavailable;
   - semantic use: complete for the visible approved descriptive claims or
     blocked/incomplete; and
   - recommendation readiness: not approved for recommendation use.
3. Descriptive categories are listed in a stable semantic order. Unsupported
   categories are not fabricated; a user following a direct reference to one
   receives an explicit unavailable explanation.
4. Choosing one fact opens Claim inspection. The primary statement comes
   first, followed by `What this source can claim`, jurisdiction and release,
   checked/freshness state, source-native identifiers, attribution/use terms,
   known limits, conflicts/supersession, and technical provenance in a deeper
   disclosure.
5. Opening the source locator is an explicit external navigation action under
   existing safe-link behavior. The locator receives no private parameters and
   opening it changes no Ambitions object.

### Inspect authority and limits

- An occupation classification says that O*NET identifies this occupation; it
  does not say the user belongs to it.
- A descriptive education or experience fact is labelled as O*NET descriptive
  context, never a universal employer gate or qualification decision.
- Claim inspection names the exact predicate for which O*NET is the authority
  in this corpus and states that employers, regulators, educators, and the user
  retain their own authority outside it.
- If a required authority-for-purpose field is absent, the fact is shown only
  as unavailable metadata; raw text is not promoted to a usable statement.

### Inspect a relationship without false equivalence

1. Related-source inspection is available only when an approved crosswalk
   record exists.
2. It shows publisher/curator, source and target native IDs and versions,
   relationship kind, confidence/review state, and limits.
3. Rejecting, withdrawing, or lacking a crosswalk leaves the concepts separate.
   The first validation corpus contains no ESCO or other external crosswalk, so
   the honest state is `No approved cross-source relationship`.

### Refresh and source change

1. The user can inspect last checked and current local source state. Optional
   background/manual refresh requests only the fixed allowlisted artifact ID;
   the selected fact and all private state are absent from the request.
2. A downloaded release is signature/hash/schema/rights checked and staged. A
   release diff identifies changed, added, withdrawn, and unmapped claim IDs.
3. Only a release whose visible claims pass complete semantic and rights review
   becomes current. Pointer promotion is atomic; the previous verified release
   remains last-known-good.
4. If a claim changes, its prior statement remains inspectable as superseded
   where rights permit, with the new statement and consequence. A revoked,
   disputed, rights-blocked, or stale-blocked claim is not presented as current.

### Offline and unavailable

- Offline/no-account uses the verified bundled 30.3 slice or a last-verified
  local copy and displays its actual age. It never labels an old fact current
  merely because the network is absent.
- If no safe local claim exists, the fact page says `Reference unavailable`,
  preserves attribution/provenance metadata that remains valid, offers retry
  when useful, and leaves Today, Goals, Time, You, and local planning usable.
- Failure to load one claim does not hide other independently valid claims.

## States and recovery

### Claim state axes

State is represented by orthogonal axes rather than one confidence enum:

- **delivery:** bundled, cached verified, last verified, staged, invalid,
  quarantined, unavailable;
- **semantic review:** complete, incomplete, mapping needed, disputed;
- **freshness:** current, aging, stale allowed, stale blocked, source changed,
  revoked, superseded, unknown;
- **rights:** approved with attribution, citation only, transformation blocked,
  review required, withdrawn;
- **consumer readiness:** inspection only or separately approved domain use.

The UI combines these into plain consequences without hiding the independent
facts. `Delivered` never renders as `recommendation ready`.

### Failure and recovery

- Signature, hash, schema, decompression, size, manifest, source-binding, or
  rights failure quarantines the staged artifact and preserves the prior
  verified release. Retry fetches the same allowlisted public identity or waits
  for a newer manifest; it never relaxes validation.
- A source release with unmapped or authority-incomplete fields makes only
  those claims unavailable. It cannot be promoted by corpus-level pass rate.
- A conflict displays each source-preserving statement and the affected-use
  block. This corpus has one source family; future conflict records cannot be
  simulated with hidden normalization.
- An inspection snapshot is bound to pack/release/claim revisions. If refresh
  promotes a new revision while it is open, a nonmodal `Source updated` status
  offers `Review update`; the old screen never silently changes its meaning.
- Interruption during download or verification leaves no current-pointer
  change. Resumption restarts or continues bounded staging by artifact hash.
- Cache corruption selects verified bundled/last-known-good fallback or honest
  unavailability. It never blocks the private local store.
- After refresh or recovery, focus returns to the exact claim status or retry
  result. On external-link cancellation it returns to the source-link control.

## Frontend experience specification

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: Use only the visible meaning, actions, limits, and recovery language resolved by User flows and States and recovery; localization must preserve every non-claim.
- Accessibility: Use native semantic containers and controls with the exact reading order, reflow, assistive actions, focus, announcements, non-color status, and reduced-effects behavior defined below.
- Visual proof: Before the frontend task starts, render one production-intended SwiftUI fixture in one representative viewport, record protected characteristics, and obtain owner approval. Runtime navigation/state, screenshot, accessibility, and named-device proof remain separately required.
- Visual gate: approved
- Experience authority: Task 4 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Ownership and components

- **SourceAtlas public domain:** add `PublicReferenceClaimEnvelope`,
  `PublicReferenceAuthority`, `PublicReferenceRights`,
  `PublicReferenceApplicability`, `PublicReferenceCrosswalkClaim`, and
  orthogonal claim-state value types. They contain public/reference data only.
- **O*NET adapter:** a release-pinned adapter accepts only O*NET 30.3 records for
  `15-1252.00` and the eight approved descriptive categories. An exhaustive
  field allowlist maps source-native IDs to predicates; unknown fields are
  rejected or retained only as quarantined adapter diagnostics, never visible
  claims.
- **Verification/cache:** existing manifest, signature, hash, public-cache,
  last-known-good, freshness, and boundary services remain delivery owners. A
  semantic/rights validator runs after structural verification and before a
  claim becomes inspectable.
- **Inspection:** `PublicReferenceInspectionProjector` in local Inspection
  creates read-only projections. Trust provides claim detail; You provides the
  bounded entry. Neither can mutate a public claim or private object.
- **Planning boundary:** no private input enters this initiative. The current
  `SourceAtlasCapabilityPathComposer` API accepting Goal/Life Context is
  excluded. Before any later consumer uses this foundation, private matching
  must be implemented under local Planning against an immutable public
  projection.

### Public data contracts

Every `PublicReferenceClaimEnvelope` carries stable Ambitions public claim ID,
source-native subject ID, predicate ID, typed value and unit/language where
applicable, source record ID, authority-for-predicate and purpose, jurisdiction,
release/effective interval, retrieved/checked dates, freshness policy/state,
rights/use state, required attribution, risk/review state, conflict IDs,
supersedes/superseded-by IDs, content hash, and inspection-use eligibility.
Required fields are non-optional at the usable-claim boundary.

Source records carry publisher, source kind, release ID, locator, license and
attribution text, content hash, retrieved time, and verification result. A
crosswalk carries its own ID, publisher/curator, relationship kind, both
source-native IDs and releases, confidence/review state, limits, rights, and
freshness. It never changes either concept's identity.

The corpus manifest fixes:

- artifact ID independent of a user or private query;
- O*NET release `30.3`, jurisdiction `US`, occupation `15-1252.00`;
- the exact selected category and field allowlists;
- source/license/attribution material and content hashes;
- schema and semantic-policy revisions; and
- explicit non-claims for BLS, ESCO, employer, qualification, fit, and
  recommendation readiness.

### Data flow

1. A bundled build artifact or optional fixed-namespace refresh supplies the
   signed manifest and bytes.
2. Public-only firewall validates request, URL, headers, object key, cache key,
   log fields, and artifact classification before network or persistence.
3. Structural verification checks size, hash, signature, schema, and source
   records. The O*NET adapter then performs exact release/occupation/category
   filtering.
4. Semantic validation checks every visible claim's source-native identity,
   predicate authority, jurisdiction, dates, freshness, rights, attribution,
   risk, and conflict state. Any failure blocks only that claim from usable
   projection.
5. A staged immutable release is promoted by an atomic current-pointer swap
   after complete slice validation. Last-known-good pointer and release diff
   remain locally inspectable.
6. The inspection projector reads a revision-bound snapshot. No inspection,
   search, selected category, or private context is returned to Source Atlas or
   R2.

### Persistence, migration, concurrency, and replay

- Public manifests, immutable releases, claim envelopes, source records,
  crosswalks, validation results, and current/last-known-good pointers live in
  the existing public-reference cache boundary, never the private canonical
  object store.
- Introduce a versioned claim-envelope schema beside existing pack decoding.
  Existing configured packs remain at their current evidence ceiling and are
  not automatically migrated or promoted. Only the exact O*NET slice is built
  through the new adapter.
- Installation migration is additive: build or verify the bundled slice,
  initialize pointers after validation, and retain prior cache for rollback.
  Interruption is idempotent; invalid old cache is quarantined, not rewritten
  into a valid claim.
- One isolated public-cache actor serializes stage/promote/quarantine/pointer
  operations. Immutable release content supports concurrent readers.
  Inspection snapshots carry release and claim revisions; refresh cannot mutate
  the bytes behind an open snapshot.
- Equivalent verified artifact, policy, clock, and locale produce the same
  claim set, states, attribution, and projection. Rebuild reads immutable
  public artifacts; it never reissues network access or touches Command/Event/
  Receipt state because inspection is non-mutating.
- Release removal follows rights and storage policy while preserving the
  minimum non-content validation/supersession audit needed to explain why a
  former claim is unavailable. It cannot leave attributed source text when
  rights require withdrawal.

## Privacy and accessibility

The remote request vocabulary is a finite set of public artifact IDs, public
channel/app/schema versions, and approved coarse public locale/jurisdiction.
It contains no Goal, capability, Proof, schedule, search, selected fact,
recommendation, rejection, location, stable private ID, derived hash, or
feedback. Unknown or private-influenced inputs fail closed. Public cache and
diagnostics use public classification and log-safe artifact/claim IDs only.
Combining a public claim with private context is outside Source Atlas and would
be private graph data under the later local Planning owner.

No account is required. Network refresh is optional freshness, not core
intelligence. Hosted search, hosted AI, private telemetry, free-form URLs, and
user-shaped object keys are absent. External source links use the stored public
locator exactly and never append private state.

Inspection uses a native list/detail hierarchy rather than a graph. Semantic
order is primary claim; consequence/current-use state; authority and limits;
jurisdiction/release/freshness; attribution; conflict/supersession; deeper
provenance; actions. VoiceOver names each axis and never reduces it to an icon
or color. Crosswalks are read as two source-native concepts plus relationship
and limitations, not spatial edges.

Voice Control, Switch Control, Full Keyboard Access, and hardware keyboard can
open categories, claims, disclosures, source links, updates, and retry. Dynamic
Type stacks all source details and does not truncate identifiers/attribution;
accessible copy controls are provided where long identifiers require them.
Increase Contrast, Differentiate Without Color, Bold Text, Button Shapes,
Reduce Motion/Transparency, RTL, and localization preserve state. Refresh and
failure changes announce exact consequences and restore focus to the affected
claim/disclosure/recovery action.

## Requirement traceability

| Scope requirement | Design decisions |
| --- | --- |
| REQ-001 | Required `PublicReferenceClaimEnvelope` fields and claim-level validation; missing meaning yields unavailable. |
| REQ-002 | Typed predicate authority/purpose; source reputation separated from classification, description, gate, provider, accreditation, transfer, safety/legal, and market claims. |
| REQ-003 | First-class versioned crosswalk claim with publisher/curator, confidence/review, limits, and no identity merge. |
| REQ-004 | Release/occupation/category allowlisted O*NET adapter and explicit corpus non-claims; no automatic promotion of existing packs. |
| REQ-005 | Bounded You entry into independent read-only Trust claim inspection with plain source/authority/limit layers. |
| REQ-006 | Orthogonal freshness/conflict/withdrawal/supersession states, per-claim blocking, immutable release diffs, revision-bound inspection. |
| REQ-007 | Bundled/last-verified fallback, honest age/unavailability, no-account behavior, private core isolation. |
| REQ-008 | Fixed request namespace, public-only boundary gate, public cache/log classification, no private input, later private join under Planning only. |
| REQ-009 | Release-specific rights validator, visible attribution, blocked/withdrawn content behavior. |
| REQ-010 | Separate delivery, semantic-use, and recommendation-readiness axes in data and UI. |
| REQ-011 | Native semantic list/detail inspection, verbalized relationships, full assistive input/reflow/reduced-effects/RTL/focus behavior. |

## Verification design

| Lane | Required evidence |
| --- | --- |
| Adapter/domain | Golden O*NET 30.3 `15-1252.00` fixture; exhaustive accepted category/field matrix; reject BLS, ESCO, employer, fit, qualification, other occupation/release, unmapped, missing-authority, missing-rights, and wrong-jurisdiction fixtures; claim and crosswalk round trips. |
| Structural/source | Manifest/signature/hash/schema/size/decompression validation; exact native IDs, release, retrieval, CC BY attribution; rights change; claim-level current/aging/stale/source-changed/disputed/revoked/superseded/unavailable transitions. |
| Evidence ceilings | Fixtures prove delivered-but-incomplete and semantically-valid-but-not-recommendation-ready; no aggregate pass can mask one invalid visible claim. |
| Firewall/privacy | Existing Source Atlas request/object-key/header/cache/log/projection abuse matrix plus selected fact, capability, Goal, Proof, schedule, private location, rejection, rationale, and derived-hash attacks; unknown request fails closed; inspect network capture for fixed equivalent requests. |
| Offline/recovery | Bundled, cached verified, last-known-good, no-account, offline, corrupt cache, interrupted staging, atomic promotion, rollback, absent local copy, one-claim failure, rights withdrawal, and core-surface availability. |
| Migration/concurrency | Additive schema install; interrupted/idempotent migration; incompatible cache quarantine; simultaneous inspection and release promotion; stable old snapshot; deterministic rebuild without fetch. |
| UI/runtime | Independent source entry; every visible category and unavailable direct link; layered claim/authority/rights/freshness/conflict inspection; external-link return; refresh update; no recommendation or private mutation. |
| Accessibility | Direct VoiceOver order/actions/announcements; Voice Control; Switch Control; Full Keyboard Access/hardware keyboard; Dynamic Type; Bold Text; Button Shapes; Increase Contrast; Differentiate Without Color; Reduce Motion/Transparency; RTL/localization; long attribution/identifier; focus for update, unavailable, retry, and external-link return. |
| Performance/resource | Measure decode, semantic validation, cache promotion, projection, inspection, and fallback for the exact slice plus bounded stress fixtures on named device/OS/build. Grooming derives latency, memory, storage, energy, size, and regression budgets; work is cancellable, bounded, decompression-limited, and off-main. |
| Build/static | XcodeGen regeneration for added files, affected builds/tests, SwiftLint/static analysis/secrets scans, Source Atlas boundary audits, `git diff --check`, canon check after canon changes, and changed-scope Code Quality. |

## Open decisions

No unresolved product behavior remains. Grooming may decide only:

- the exact versioned binary/JSON representation and indexes for immutable
  public claim envelopes and release diffs;
- whether the bounded You entry projects directly from Inspection or through a
  small surface adapter;
- exact refresh-task batching and cache-retention values derived from measured
  resource evidence; and
- the implementation sequence for isolating the existing private-context
  composer from Source Atlas before any dependent consumer is enabled.

Any request to add another occupation, O*NET release, BLS/ESCO fact, crosswalk,
employer requirement, education/hobby claim, or recommendation use is a corpus
and authority expansion requiring its own approved domain Research and Scope;
it is not a technical open decision in this Design.
