+++
initiative = "current-opportunity-availability-intelligence"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Ambitions can show whether a source reports a specific public opportunity or
offering as current, where and when the claim applies, when it was checked, and
what remains unknown. A user can inspect, filter locally, dismiss, refresh, or
open the owning source without Ambitions claiming eligibility, guaranteeing
capacity, leaking private intent, or performing the transaction.

## In scope

- A public Current Authority Registry layered on Source Atlas.
- Source-specific admission, rights, field-authority and freshness policies.
- Offering identity and claim types for open window, status, place, delivery,
  price, capacity signal, schedule, prerequisite statement, application route,
  accessibility statement, and source notice.
- Exact subject bindings to admitted corpus identities and Relationship Registry
  edges without deriving equivalence or qualification.
- Fixed public artifact/region acquisition and wholly local matching/filtering.
- Signed versioned snapshots, deterministic replay, LKG inspection, rollback,
  invalidation, withdrawal, purge, reset, and offline behavior.
- User-facing current-state, source, checked-at, expiry, conflicts, limitations,
  unknowns, and external-link inspection.
- A synthetic conformance source and no more than one real source family whose
  product use, retention, redistribution and withdrawal terms are cleared.
- Accessibility, privacy, source quality, coverage and direct-user evaluation.

## Out of scope

- Universal job, course, credential, event, hobby, service, permit, licensure,
  program, or booking aggregation.
- Any real source whose terms or exact field authority remain unresolved.
- Private query-shaped remote search, precise-location upload, background
  surveillance, scraping, browser automation, or model-authored current facts.
- Personal eligibility, admission, affordability, qualification, safety,
  outcome, fit, legal, tax, licensure, transfer, or benefit determinations.
- Application, reservation, enrollment, purchase, payment, outreach, account
  creation, calendar mutation, Goal creation, or other external write.
- Automatic canonical mutation, schedule mutation, or recommendation adoption.
- Treating a capacity signal as held inventory or an application link as an
  endorsed opportunity.

## Requirements

### REQ-001 — Source admission is explicit

Every source family must have an approved source identity, owner, endpoint or
artifact contract, terms/rights/retention/redistribution state, field-level
authority, allowed product uses, rate/update policy, withdrawal route, and
reviewed release. Unresolved source families remain unavailable.

### REQ-002 — Offering and claims retain source-native meaning

An offering must bind stable source/offering/subject identifiers. Each current
claim must retain its source-native value/unit, type, jurisdiction/location,
effective interval, publication/retrieval/verification/expiry timestamps,
locator, authority, rights, conflict, uncertainty and release hash.

### REQ-003 — Time and absence are honest

Unknown, unavailable, unsupported, not-applicable, stale-inspectable,
stale-blocked, withdrawn, closed, zero, free, full, remote, and missing must be
distinct. An expired claim cannot drive a current presentation. No results must
not be presented as proof that no opportunity exists.

### REQ-004 — Claim purposes remain narrow

Purpose profiles must separately authorize identity, display, local filter,
comparison, proposal grounding, simulation input, deep link, and review-only
use. No profile may derive eligibility, qualification, safety, availability
guarantee, outcome, or endorsement.

### REQ-005 — Acquisition stays public and finite

Network acquisition may send only allowlisted public source/artifact/release/
coarse-region identifiers. It must never transmit private Goal text, identity,
profile, exact location/history, schedule, Capability/Proof, correction,
selection, rejection or generated proposal content.

### REQ-006 — Matching and personal filtering are local

Public offering records may be joined to corpus subjects through approved exact
bindings. All user/context filtering happens on device and returns reason codes
and unknowns; it does not assert personal eligibility or edit public claims.

### REQ-007 — Conflicts and supersession remain visible

Conflicting current claims remain source-attributed. Supersession, correction,
withdrawal and expiry invalidate only exact dependents. Ambitions must not
silently prefer the cheaper, nearer, open, or otherwise favorable value.

### REQ-008 — Offline and failure states degrade per claim

Verified LKG claims remain inspectable with their actual checked-at/expiry
state. Missing, corrupt, signature-invalid, source-changed, rate-limited,
offline, permission-blocked, and refresh-failed states do not erase durable
reference knowledge or relax current-use gates.

### REQ-009 — External effects are absent

The experience may open an attributed source URL only after clear user action.
It must not apply, book, enroll, pay, contact, authenticate, reserve inventory,
create a Goal, or mutate Time. A link opening is not a transaction receipt.

### REQ-010 — Inspection and correction are complete

Users can inspect source, value, scope, checked-at, effective/expiry time,
authority, rights, limitations, conflicts and unknowns; report a public issue;
dismiss an item locally; clear cached current data; and recover from interruption.
Reports and dismissals are private and do not edit public truth.

### REQ-011 — Public data lifecycle is atomic and deletable

Snapshots are signed, immutable, versioned and atomically promoted. Readers see
one generation. Refresh/rollback/replay/reset/withdrawal/purge are idempotent and
crash recoverable. Purge removes prohibited raw, derived, index, render, cache,
export and dependency bytes.

### REQ-012 — Dependencies invalidate without mutation

Consumers store opaque public evidence bindings only. Changed/expired/withdrawn
claims notify exact dependents to recompute or become unavailable; the registry
cannot edit Goals, Steps, schedules, simulations, recommendations or receipts.

### REQ-013 — Coverage and quality are measurable

Evaluation reports admitted sources, geography/subject/time-window coverage,
claim completeness, staleness, conflict, expiry, false-current, withdrawal,
privacy, rights, bias and source-family concentration. No universal quality or
person score is permitted.

### REQ-014 — Accessibility communicates time and uncertainty

Current state, source, expiry, conflict and limits have text equivalents; no
meaning depends on color, animation, map, relative time, or visual ordering.
VoiceOver, Dynamic Type, Voice Control, Switch Control, keyboard, Reduced Motion,
RTL and non-map alternatives are required.

### REQ-015 — User evidence gates expansion

Users must distinguish destination from current offer, checked-at from
guaranteed, prerequisite from eligibility, capacity signal from reservation,
and no data from no opportunity. A real source or broader query mode cannot
expand without claim-bound evaluation and terms approval.

### REQ-016 — Source links are safe and attributed

URLs must be source-supplied, scheme/host allowlisted and visibly attributed.
Unsafe, changed or malformed links fail closed. Ambitions must not append private
query parameters or claim the external page is accessible, safe, or available.

## Acceptance criteria

- **AC-001 (REQ-001):** an unresolved terms or retention field makes the family
  unavailable; admitting another family does not override it.
- **AC-002 (REQ-002):** golden records round-trip every identity, value, time,
  authority, rights, conflict and provenance byte without normalization loss.
- **AC-003 (REQ-003):** clock tests distinguish every absence/current state and
  block expired claims from current use.
- **AC-004 (REQ-004):** purpose-isolation tests reject eligibility, guarantee,
  outcome and endorsement projections.
- **AC-005 (REQ-005):** private canaries occur nowhere in requests, keys, logs,
  diagnostics, artifacts or source receipts.
- **AC-006 (REQ-006):** local filter fixtures return deterministic evidence and
  unknown reason codes without changing source records.
- **AC-007 (REQ-007):** conflicting and superseded claims remain inspectable;
  only exact dependency bindings invalidate.
- **AC-008 (REQ-008):** offline/corrupt/rate-limit/source-change tests retain
  durable reference knowledge and honest current state.
- **AC-009 (REQ-009):** all non-link external-effect attempts are impossible;
  link opening requires user action and creates no success claim.
- **AC-010 (REQ-010):** inspection, dismissal, report, clear and interrupted
  recovery work without public mutation.
- **AC-011 (REQ-011):** fault injection proves atomic reader generations,
  idempotent replay and complete resumable purge.
- **AC-012 (REQ-012):** expiry/revocation notifies exact consumers while
  canonical and private owner bytes remain unchanged.
- **AC-013 (REQ-013):** evaluation exposes denominator, slice, source and time;
  false-current and private-egress hard gates fail promotion.
- **AC-014 (REQ-014):** accessibility tests and device inspection cover every
  state, control, time expression and non-map route.
- **AC-015 (REQ-015):** direct-user evidence passes predefined comprehension
  thresholds before production-source expansion.
- **AC-016 (REQ-016):** unsafe/link-injection fixtures fail closed and send no
  private values.

## Canon impact

Implementation is expected to add a Current Authority Registry specification
and update Source Atlas, Source Reference, trust inspection, privacy/data
classification, destination proposals, path proposals and evaluation canon.
Canon changes describe the product contract; they do not prove a source is
licensed, current, implemented, or released.

## Risks and open decisions

No hard product decision remains. The registry and synthetic conformance source
can be implemented independently. Each real source remains unavailable until
its terms and field authority are affirmatively resolved; the first admitted
real source is an implementation-time source-admission result, not an assumed
Scope promise. Deep linking is the fallback.

Review verdict: **PASS** after two reconciliation rounds. The review narrowed
the first release from assumed USAJOBS/RIDB ingestion to terms-gated admission,
added safe-link and temporal absence semantics, and made private local filtering
and user comprehension explicit. Devan delegated approval; Scope was approved
on 2026-08-04.
