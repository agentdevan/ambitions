+++
initiative = "current-opportunity-availability-intelligence"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Add a public, read-only `CurrentAuthorityRegistry` sibling within Source Atlas.
The Foundry admits each source through an explicit contract, converts only
authorized fields into immutable claim-preserving shards, and publishes signed
releases. Native code validates the same semantics, atomically promotes one
snapshot, indexes exact corpus/relationship bindings, applies private filters
locally, and exposes attributed current-state projections. Consumers receive
versioned evidence bindings and reason codes, never mutable public objects or
external-write authority.

The first release uses a synthetic conformance source. A real adapter can ship
only when its signed source-admission configuration is complete; the design does
not assume USAJOBS, RIDB, apprenticeship, provider, licensure, or booking rights.

## User flows

### Inspect current opportunities for a destination

1. From an adopted or proposed destination, the user chooses **Current
   opportunities**.
2. The app reads the destination's exact public subject bindings and current
   registry generation. No network request contains private context.
3. Locally stored user-approved filters are applied on device. Results explain
   which public facts matched, which private constraints were considered, and
   which values remain unknown.
4. Each result states source, offering, location precision, effective/open
   window, checked-at and expiry using absolute dates, plus status/conflicts.
5. The user can inspect all claims, dismiss locally, request a fixed public
   refresh, report an issue, clear cached current data, or open an attributed
   allowlisted source link.
6. Opening the source leaves Ambitions; no application/reservation success is
   recorded. Returning preserves the prior local inspection state.

### Empty, stale, and conflicting results

- No admitted source: “Current opportunity sources aren't available for this
  destination.” Durable destination knowledge remains visible.
- No matching records: “No matching records in the checked sources,” with
  source/region/time coverage; never “no opportunities exist.”
- Offline: valid LKG facts show checked-at/expiry; expired facts are inspection
  only. Refresh can be retried when online.
- Conflict: source claims appear side by side; current use is blocked where the
  conflict affects its purpose.
- Withdrawn/invalid: the affected claim disappears from current lists, remains
  in allowed lineage/receipt form, and exact consumers become source-needed.

### Clear, dismiss, report, and recover

Dismissal is a private preference keyed to a public opaque offering ID. Reporting
creates a private local draft until the user explicitly exports/sends it under
another owner. Clear removes public cache and derived local index; bundled
fallback may reappear with its true state. Interrupted refresh, promotion,
rollback or purge resumes from an idempotent public journal.

## States and recovery

### Claim states

`currentVerified`, `aging`, `staleInspectable`, `staleBlocked`, `unknown`,
`unavailable`, `unsupported`, `notApplicable`, `conflicting`, `superseded`,
`withdrawn`, `sourceChanged`, `rightsBlocked`, `signatureInvalid`, and
`quarantined` are typed states. Domain values such as `open`, `closed`, `full`,
`free`, or zero are values, not absence states.

### Registry states

`bundled`, `refreshAvailable`, `refreshing`, `staging`, `validating`, `promoting`,
`ready`, `offlineLKG`, `refreshFailed`, `rollbackAvailable`, `rollingBack`,
`purging`, and `unavailable` are visible/recoverable. Readers lease an immutable
generation; failures cannot expose partially staged bytes.

### Failure and concurrency rules

- One actor serializes stage/promote/rollback/expire/invalidate/reset/purge.
- Every operation has an idempotency key and journal phase.
- Background refresh may fetch fixed public IDs but cannot evaluate private
  filters. Foreground filters use a captured registry/private-context revision.
- Results whose registry generation, filter revision, locale or purpose changes
  are discarded before presentation or persistence.
- Clock rollback, missing timezone, malformed intervals, unsigned bytes,
  unknown schemas and source-policy changes fail closed.
- Source removal creates a withdrawal tombstone sufficient for permitted
  lineage, then purges prohibited content and resumes after interruption.

## Frontend experience specification

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: Use only the visible meaning, actions, limits, and recovery language resolved by User flows and States and recovery; localization must preserve every non-claim.
- Accessibility: Use native semantic containers and controls with the exact reading order, reflow, assistive actions, focus, announcements, non-color status, and reduced-effects behavior defined below.
- Visual proof: Before the frontend task starts, render one production-intended SwiftUI fixture in one representative viewport, record protected characteristics, and obtain owner approval. Runtime navigation/state, screenshot, accessibility, and named-device proof remain separately required.
- Visual gate: required
- Experience authority: Task 8 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Foundry boundary

`tools/source-atlas/foundry/current_authority_*` modules own source admission,
locks, rights, acquisition, source-native normalization, temporal validation,
conflicts, coverage, release diff, deterministic build and CLI. JSON schemas
define `CurrentAuthorityRelease`, `CurrentOffering`, `CurrentClaim`,
`CurrentSourceAdmission`, `CurrentUseProfile`, and `CurrentCoverage`.

Source adapters produce source-native typed values plus evidence; they cannot
decide product eligibility. The release builder rejects missing terms, ambiguous
timezones, unsupported field use, unbounded URLs, unapproved retention,
non-determinism, private canaries and unresolved high-risk conflicts. The
synthetic adapter exercises all states without impersonating a real source.

### Native boundary

Add under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/CurrentAuthority/`:

- value types for source admission, offering, claim, temporal interval,
  freshness, purpose profile, conflict, coverage, dependency and release;
- artifact decoder and semantic validator with Python/Swift parity;
- immutable snapshot store, migration, query index/actor and read client;
- local-filter evaluator receiving ephemeral typed private predicates, returning
  public claim IDs plus local reason codes without persisting joined graphs;
- coordinator, expiration engine, invalidation planner, dependency notifier,
  rollback/reset/purge services; and
- safe attributed link builder with scheme/host and parameter allowlists.

`CurrentAuthorityReadClient` exposes only:

```
lookup(subjectBindings, purpose, publicRegion?) -> PublicOfferingSet
filter(publicSet, ephemeralLocalConstraints, capturedRevisions) -> LocalFilteredSet
inspect(offeringID, generation) -> CurrentInspection
refresh(fixedPublicTargetID) -> PublicRefreshReceipt
```

There is no free-text remote search, exact-coordinate transport, eligibility
method, transaction method, graph traversal, canonical command or schedule
command.

### Data flow and ownership

1. Foundry reads locked public source bytes under an admitted contract.
2. It emits signed immutable public shards and a release manifest.
3. Existing Source Atlas transport fetches only allowlisted target IDs.
4. Native verifies signature/schema/source lock/rights/time/use semantics and
   stages a generation.
5. Atomic promotion swaps the public snapshot and computes an exact public
   dependency diff.
6. Query returns current public claims; local filter receives private values
   ephemerally. No joined private/public result enters the public cache.
7. Consumers persist evidence binding `{release, offering, claim IDs, purpose}`
   and their own decision. Registry changes only notify.

Public data: releases, source fields, indices, coverage and allowed lineage.
Private data: filters, dismissal/report drafts, selections, viewed history,
Goals, Capability/Proof, schedule and recommendations. Public logs use source,
release, field/reason and aggregate counters only.

### Persistence, migration, deletion

Public snapshots live in Source Atlas public cache and are rebuildable. Private
dismissal/report preferences live in the owning private repository and reference
opaque public IDs. Legacy current-looking fields import only if exact source,
time, rights and release can be reconstructed; otherwise they become
`unverifiedLegacyCandidate` and never drive current use.

Clear-cache removes downloaded public bytes/indices. Reset removes registry
settings and private dismissals/report drafts through their owner. Rights/source
withdrawal purges every prohibited raw, shard, index, rendered, cached, exported
and dependency byte; allowed tombstones contain no source content. Deletion-
terminal replay cannot resurrect removed bytes.

### Typed consumer handoffs

- Destination proposals may show current evidence only for `proposalGrounding`.
- Goal Path proposals may attach an opportunity-dependent Step as conditional,
  never adopt it automatically.
- Simulation may use `simulationInput` with expiry/conflict sensitivity.
- Scheduling sees only an accepted Step's user-owned temporal constraints.
- External actions receive no authority here; later orchestration must recheck
  the source and request confirmation.
- Evaluation receives public claim/reason IDs and privacy-safe aggregate events,
  never the private filter payload.

## Privacy and accessibility

The public-only firewall rejects any private canary at request construction,
transport, cache, artifact, index, dependency, diagnostics and metrics. Coarse
public region targets are finite configuration, not derived silently from exact
device location. Location and sensitive constraints stay local, are editable,
disableable and deletable, and are never inferred from absence or browsing.

Cards use explicit absolute dates and timezones, source name, text status and
“checked” language. Relative time is supplementary. Lists are complete
alternatives to maps. Conflict, expiry, price/capacity unknown, source limits,
and link destination are announced. Focus returns after refresh/dismiss/report;
interruptions preserve context. Largest Dynamic Type, VoiceOver, Voice Control,
Switch Control, keyboard, Reduced Motion, RTL, high contrast and non-color state
must work on physical devices.

## Requirement traceability

| Scope | Design decision |
|---|---|
| REQ-001 | Source admission schema/config and hard release gates |
| REQ-002 | Source-native claim model and lossless parity |
| REQ-003 | Typed claim states and temporal validator |
| REQ-004 | Narrow use profiles and no decision methods |
| REQ-005 | Fixed public targets and firewall at every boundary |
| REQ-006 | Ephemeral on-device filter evaluator and reason codes |
| REQ-007 | Side-by-side conflicts, supersession and exact invalidation |
| REQ-008 | Immutable LKG, per-claim degradation and durable reference separation |
| REQ-009 | Link-only user action and absent transaction APIs |
| REQ-010 | Inspection/dismiss/report/clear/recovery flows |
| REQ-011 | Signed snapshots, actor, journal, rollback and purge |
| REQ-012 | Opaque evidence bindings and notifier-only consumer handoff |
| REQ-013 | Claim-bound coverage/quality release artifacts |
| REQ-014 | Absolute-time, text-state, list and assistive designs |
| REQ-015 | Comprehension study and promotion gate |
| REQ-016 | Safe attributed URL builder |

## Verification design

- Schema/golden tests for every time/value/absence/conflict/use state and
  Python/Swift byte-for-semantic parity.
- Source-admission fixtures for unresolved terms, changed policy, rate limits,
  revoked rights, malformed content, field overreach and withdrawal.
- Temporal property tests across timezones, DST, intervals, clock rollback,
  future timestamps, expiry, supersession and replay.
- Deterministic repeat builds and signed artifact corruption tests.
- Private-canary and network-capture tests at request, transport, cache, log,
  metric, dependency and crash boundaries.
- Concurrency/fault injection for refresh/read/filter/promote/rollback/clear/
  purge with stale-result rejection and deletion-terminal replay.
- Exact dependency tests proving no canonical/private mutation.
- Unsafe URL/redirect/query injection tests and no external-write API audit.
- Accessibility unit/UI/device tests for every state and action.
- Physical-device storage, refresh, validation, promotion, query/filter,
  inspection, clear/purge, memory, energy and background-budget measurements.
- Direct-user comprehension evidence and slice-based quality/bias reports before
  a real-source or remote-query expansion.

## Open decisions

None within the bounded design. Which first real source qualifies is a source-
admission outcome governed by the same contract; failure to qualify leaves the
synthetic conformance implementation and deep-link fallback intact rather than
forcing a product redesign.

Review verdict: **PASS** after two reconciliation rounds. Review added ephemeral
local-filter separation, exact URL safety, source-withdrawal deletion, temporal
clock failure, and typed consumer claim ceilings. Devan delegated approval;
Design was approved on 2026-08-04.
