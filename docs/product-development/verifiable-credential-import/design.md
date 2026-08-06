+++
initiative = "verifiable-credential-import"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

The credential flow imports one explicitly supported Open Badges 3.0
`OpenBadgeCredential` JSON/JSON-LD artifact into a new private Credential owner.
Selection, validation, acceptance, and ordinary inspection are local and make
no network request. The accepted record retains the exact signed bytes and
reports independent facts for structure, integrity/signature path, issuer
assertion, recipient binding, expiry, revocation/status, freshness, conflict,
supersession, recognition, relationships, and receiver acceptance.

Ambitions describes only evidence actually established by the supported check.
A verified artifact does not mean verified skill, current competence, reputable
issuer, employability, eligibility, or receiver acceptance. Proof, Capability,
Credential, and external receiver decisions remain separate owners.

Current issuer or revocation information is available only through a distinct,
viewer-initiated **Check current status** operation. Before every check the user
reviews the exact eligible hosts, public resource classes, purpose, and
retrieval-time correlation risk. A hardened egress planner permits only minimum
public verification material and shared public HTTPS Bitstring Status List
resources. It fails closed without contact for authenticated, holder-specific,
one-to-one, private-network, non-HTTPS, or unreviewed-redirect targets. Replay
records results but never repeats the fetch.

## User flows

### Import and acceptance

1. In **You > Sources & Imports > Import credential**, the introduction names
   the supported Open Badges 3.0 boundary, private on-device processing, zero
   automatic network access, and Ambitions' inability to change or delete the
   original outside file.
2. The user chooses one JSON/JSON-LD file. Ambitions writes an encrypted,
   file-protected staged copy and computes its exact artifact fingerprint.
   Selection creates no Credential, Proof, Capability, Source Reference, or
   network request.
3. Before parsing, the fingerprint index handles identity:
   - exact bytes already accepted show **Already imported** and open that
     Credential; no duplicate is created;
   - the same external credential identifier with changed bytes is a conflict
     and preserves both artifacts for comparison without overwrite;
   - a new identifier is a separate reissue candidate, not an automatic
     supersession.
4. A bounded parser validates JSON structure, Open Badges 3.0 context/type,
   required fields, selected supported profile, proof method, canonicalization
   rules, and size/depth/count limits. Locally available key/proof material is
   checked without following URLs. Malformed, unsafe, unsupported, or failed-
   signature input creates no Credential and shows the exact category.
5. **Review issuer assertion** presents, in stable order: artifact/profile;
   issuer assertion; recipient-binding summary; achievement; criteria/evidence
   references as non-followed labels and privacy-minimized hosts; issue/expiry;
   structural, integrity, proof/key-path, status/freshness, recognition, and
   receiver-acceptance axes; retained exact artifact; relationships; and
   deletion consequences.
6. If required issuer/key/status evidence is not locally available, the review
   says `unverified/pending` or `unknown`, names the missing dependency, and
   distinguishes it from failed, current, expired, and revoked. The user may
   accept this honest state; a failed signature cannot be accepted.
7. **Accept Credential** confirms the current staged revision. One atomic
   command commits the Credential, exact encrypted artifact reference, Source
   Reference, verification snapshot, Receipt, History, and replay identity.
   Staging is then removed. Cancel or Reject deletes staged bytes and parsed
   private values and retains at most a content-free failure fact.

### Inspection and relationships

Credential detail shows the independent axes rather than one trust badge.
Historical import verification and each last-known status result include their
time and source. Offline copy says **Last checked [date]** and never implies a
current check.

**Link to Proof** and **Unlink from Proof** create relationship commands without
altering either object's meaning. **Link to Capability** is shown only when the
canonical Capability owner exists. It previews an issuer-backed evidence
relationship and explicitly denies proficiency, present competence, receiver
acceptance, and planning permission. Future-use remains off. Unlink removes
only the chosen edge.

A supersession comparison may be offered only when signed issuer relationship
data supports it or the user explicitly reviews and confirms the relationship.
Title, issuer, recipient, and achievement similarity can flag a possible
duplicate but cannot merge or supersede records.

### Check current status

1. The user invokes **Check current status** on a specific committed Credential
   revision. No background, import-time, launch-time, or ordinary-inspection
   refresh exists.
2. The planner reads only signed locators from the supported proof/status path,
   resolves resource classes, and builds a no-contact plan. It rejects arbitrary
   criteria, evidence, profile, refresh, image, achievement, and unrelated links.
3. **Review network check** lists every normalized host, resource class, why it
   is needed, correlation warning, minimum public request fields, redirect rule,
   and cancel/failure behavior. It states that no credential bytes, recipient,
   subject, private graph context, Ambitions ID, account token, receiver purpose,
   or capability data will be sent.
4. Confirmation is single-use and binds the exact Credential revision, host
   set, resource set, policy/profile versions, and plan digest. A changed plan
   or revision returns to review.
5. A cookie-free, credential-free client executes only approved public HTTPS
   reads. Before connect and after DNS resolution it rejects loopback, link-
   local, private, reserved, local-name, authenticated, credential-bearing, and
   one-to-one targets. Redirects are followed only when the exact destination
   host was in the confirmed set; otherwise the check stops as unknown.
6. The result independently records proof/key availability and supported
   Bitstring current/expired/revoked/unknown state, exact time, source, freshness,
   and external-operation disposition. Failure and cancellation never erase the
   artifact or manufacture a current result.

### Deletion

- **Discard staged import** removes only unaccepted staging and parsed values.
- **Unlink** removes only the selected Proof or Capability relationship.
- **Permanently delete Credential** previews and removes the exact artifact,
  parsed private fields, credential-specific cached status, derived axes,
  conflicts/supersession edges, Source relationship, and all Proof/Capability
  links. Linked objects survive and visibly lose support.
- Shared public verification cache entries may remain only if content-addressed,
  public, unlinked from the deleted Credential, and still needed by another
  record. All credential-specific indexes and correlations are removed.
- A minimum content-free tombstone preserves deletion/idempotency lineage. The
  original outside file and previously disclosed copies remain outside
  Ambitions' authority.

## States and recovery

### Import session states

| State | Meaning | Recovery/action |
| --- | --- | --- |
| `selected` | Exact bytes are protected staging only. | Validate or discard. |
| `validating` | Bounded local parse/proof work is in progress; graph unchanged. | Cancel; resume only with checksum-valid staging. |
| `invalid` | Structure or signature failed; acceptance prohibited. | Inspect redacted cause, discard, or select another file. |
| `unsupported` | Structure is understood enough to name an unsupported context/profile/proof/status mechanism; it is not declared invalid. | Discard or retain no content and return. |
| `reviewable` | Supported result is staged, including honest unverified/pending dependencies. | Accept, reject, or inspect conflict. |
| `conflictReview` | Same external ID has changed bytes; accepted record is untouched. | Keep as separate conflict record or reject; never overwrite. |
| `committing` | Revision-bound atomic acceptance is executing. | Relaunch returns existing result by idempotency key or retries before acceptance. |
| `accepted` | Credential and exact artifact are durable; staging cleanup is due or complete. | Inspect/link/check status/delete. |
| `discarded` | Staging and parsed private values are gone. | Return. |
| `quarantined` | Corrupt or unsafe bytes are isolated from parsers and search. | Delete quarantine or inspect redacted diagnosis. |

### Credential axes

The Credential has no composite “trusted” boolean. It projects independent
enums for structural support, artifact integrity/signature, issuer assertion,
recipient binding, expiration, supported revocation, freshness, issuer
recognition, receiver acceptance, conflict, supersession, and relationship
state. `unknown`, `unavailable`, `unsupported`, `failed`, `current`, `expired`,
and `revoked` are not interchangeable. Axis updates append evidence snapshots;
they never rewrite the historical import result or delete the object.

### Status operation states

`planned -> awaitingConfirmation -> locallyCommittedPending -> executing ->
succeeded | failed | cancelledBeforeEffect | reconciliationRequired`. The
effect disposition is separately `notAttempted`, `confirmedAbsent`,
`confirmedPresent`, or `indeterminate`. Only `confirmedPresent` with a valid
supported response produces a new status snapshot. Ambiguous post-invocation
failure remains ambiguous and is never labeled current.

Relaunch may restore an accepted durable pending operation and present Resume,
Cancel if no effect began, or Reconcile. It never automatically invokes the
network. A new manual attempt rebuilds the plan from the current Credential and
policy, receives a new single-use confirmation, and has a new attempt ID.
Provider retry uses a stable idempotency key where meaningful but cannot assume
a GET was absent after ambiguous transport.

Acceptance and deletion are atomic local transactions. Low storage, protected-
data unavailability, stale revision, key loss, corrupt artifact, or migration
failure preserves the last honest store and offers retry, quarantine, safe
export/recovery where allowed, or explicit unsupported-store handling. No
routine error silently resets or deletes a Credential.

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
- Experience authority: Task 6 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Ownership and components

- A new `Core/Domain/Credential` owner defines Credential identity, exact-
  artifact binding, independent evidence axes, duplicate/conflict/reissue/
  supersession rules, relationships, lifecycle, and deletion.
- `Repair/CredentialImport` owns hostile-input limits, JSON/JSON-LD parsing,
  supported Open Badges profile adapters, local proof verification, staging,
  quarantine, and review facts. Adapters cannot commit canonical meaning.
- `Storage` and the encrypted blob vault own exact artifact bytes, checksums,
  file protection, atomic moves, corruption detection, and secure deletion.
- `PrivacySecurity` owns credential classification, network-plan policy,
  minimum payload, DNS/IP/redirect controls, and fail-closed decisions.
- `ExternalOperations` owns durable status-check intent, lease/attempt/result,
  reconciliation, and no-reissue-on-replay semantics. A dedicated public-
  verification HTTP adapter receives only an approved plan.
- `Commands` owns acceptance, relationship, supersession, and deletion
  mutations. `Inspection`/Trust own layered status, Source, Receipt, and History
  projections; You owns broad Sources & Imports controls.

### Credential model

`CredentialRecord` contains stable local ID, exact SHA-256 artifact fingerprint,
encrypted artifact blob ID, external credential identifier, supported
profile/version, issuer-assertion summary, privacy-minimized recipient-binding
summary, issue/expiry facts, independent evidence axes, import snapshot ID,
status snapshot IDs, conflict/reissue/supersession relationships, Source
Reference ID, lifecycle/revision, and Proof/Capability edge IDs. It stores no
proficiency, competence, employability, eligibility, planning permission, or
receiver-acceptance inference.

Each `CredentialVerificationSnapshot` binds Credential revision, artifact
fingerprint, profile/parser/canonicalization/crypto policy versions, local
material fingerprints, check time, supported result axes, missing dependencies,
source class, and uncertainty. The exact artifact remains the authority for
what was accepted; parsed projections are rebuildable and never overwrite it.

`CredentialStatusSnapshot` binds the exact reviewed Credential revision,
approved host/resource set and digest, supported policy/profile versions,
attempt ID, check time, result source fingerprint, current/expired/revoked/
unknown outcome, freshness, redirect/DNS decision codes, and truthful external
result. It contains no private request content. A shared public resource cache
is content-addressed, classified public, bounded, and has no reverse private-
credential index; private relation and interpretation stay in the Credential.

### Command, concurrency, and external-effect boundary

`AcceptCredential` atomically writes Credential, artifact ownership, Source
Reference, verification snapshot, History Event, Receipt, and projections.
Idempotency binds staged artifact fingerprint plus acceptance revision.
`LinkCredentialEvidence`, `ConfirmCredentialSupersession`, and deletion are
separate expected-revision commands.

A per-Credential actor serializes acceptance-adjacent relationships, deletion,
and status-result application. Compare-and-set rejects a status plan or result
whose Credential revision, artifact hash, host plan, or policy changed. The
network operation is committed locally before invocation, and its state/result
settles independently from the Credential content transaction. Deletion during
a pending check cancels before effect when possible; otherwise it marks the
operation for privacy-safe reconciliation and prevents result linkage.

The status adapter accepts only method GET, normalized approved HTTPS URLs,
expected media/size limits, no auth/cookies/referrer/custom identifiers, a
redirect allowlist, and an ephemeral cache policy. The adapter cannot accept
raw Credential data or arbitrary signed URLs by type. Response parsing is
bounded, signature-checked where required, and treats all bytes as hostile.

### Persistence, migration, replay, and resources

The additive first migration creates Credential, verification/status snapshot,
relationship, operation-link, and encrypted-artifact metadata stores plus
versioned events. Existing stores initialize them empty; no Proof, attachment,
or source record is inferred to be a Credential. The migration preserves the
owning direct-upgrade horizon and rollback/repair boundary. Unsupported or
corrupt versions quarantine and preserve the last readable copy.

Replay reconstructs Credential axes, exact artifact links, relationships,
tombstones, Receipts, History, pending/terminal status operations, and dated
last-known status. It never fetches issuer documents/status lists, opens signed
links, reissues an external operation, upgrades unknown to current, or infers
Capability/Proof meaning. Projection rebuild validates artifact and event
checksums and exposes a blocked/corrupt state rather than silently dropping the
record.

Parsing, JSON-LD processing, cryptography, hashing, and status-list decode run
off the main actor with calibrated byte, nesting, term expansion, proof count,
key count, decompression, response, memory, time, cache, and cancellation
limits. Algorithms and proof suites are explicit allowlists; no dynamic code,
remote context execution, or unbounded context resolution is permitted.

## Privacy and accessibility

Credential artifacts, parsed fields, recipient binding, issuer assertion,
verification/status interpretations, conflicts, relationships, and private
cache links are private local graph data. They are excluded from Account, R2,
Source Atlas, Ambitions backend, hosted AI, analytics, telemetry, implicit
support upload, Spotlight, widgets, and logs. Exact bytes use encrypted storage
and complete file protection. Locked-device UI renders only a redacted
placeholder until protected data is available.

The only network capability is the confirmed public-verification adapter.
Policy checks classification, purpose, normalized destination, scheme, port,
DNS results, address ranges, auth/userinfo/query sensitivity, resource sharing,
redirects, allowed fields, response size/type, and retention. Unknown fails
closed. Local inspection and deletion remain fully available offline. Redacted
diagnostics store IDs, policy versions, host fingerprints or approved public
hosts, resource classes, decision codes, and timings—not credential, recipient,
subject, Capability, Goal, or schedule values.

Accessibility uses a fixed semantic order: Credential identity; plain-language
issuer assertion; verification layers; dated freshness; uncertainty; conflict/
supersession; relationships; status-check control; privacy/deletion. Status is
always label plus value and never a seal, color, icon, animation, or side-by-
side-only comparison. Criteria/evidence links are announced as non-opened
references, not actionable URLs.

VoiceOver provides headings/rotors, layer labels, expanded explanations, host-
by-host check preview, progress, result, and recovery. Semantic focus returns to
the initiating Credential/action or nearest stable heading after modal dismiss,
check result, link change, conflict decision, and deletion. Voice Control,
Switch Control, Full Keyboard Access, and hardware keyboard reach all actions;
no gesture or long press is required. Dynamic Type through accessibility sizes,
Bold Text, Button Shapes, Increase Contrast, Differentiate Without Color,
Reduce Motion, Reduce Transparency, RTL/localization, adequate targets, and
locked-device privacy are verified directly. Announcements distinguish
cancelled-before-contact, failed, unknown, stale, expired, and revoked without
alarmist audio or haptics.

## Requirement traceability

| Scope requirement | Design binding |
| --- | --- |
| REQ-001 | Import steps 1-2 provide deliberate selection, private staging, outside-file boundary, and zero object/link/network effect. |
| REQ-002 | Import step 4 and the allowlisted bounded parser enforce supported Open Badges 3.0 context/profile/proof while separating invalid from unsupported. |
| REQ-003 | Review step 5, independent snapshots, and copy boundaries name only structure, artifact/proof path, issuer assertion, recipient, expiry/status, recognition, and receiver acceptance. |
| REQ-004 | Credential axes and append-only snapshots keep verification, expiry, revocation, freshness, conflict, supersession, relationships, and acceptance orthogonal. |
| REQ-005 | Import step 6 and dated offline inspection preserve unverified/pending/unknown missing dependencies without false failure/current claims. |
| REQ-006 | Import step 7, `AcceptCredential`, and exact encrypted artifact binding provide preview, atomic mutation, Receipt, History, replay, and cleanup. |
| REQ-007 | Import step 3 plus relationship rules use exact bytes for duplicates, protect same-ID conflicts, keep reissues separate, and constrain supersession evidence. |
| REQ-008 | Relationship flows and separate owners make Proof/Capability links reversible evidence edges with no transferred meaning or future use. |
| REQ-009 | The six-step status flow structurally separates every viewer-initiated, single-use confirmed check from import and inspection. |
| REQ-010 | Hardened plan/client types enforce minimum public material, shared HTTPS Bitstring resources, no private payload/auth/private network, and reviewed redirects. |
| REQ-011 | Planner rejects arbitrary signed criteria/evidence/profile/refresh/image/achievement links and presents only privacy-minimized inert references. |
| REQ-012 | `CredentialStatusSnapshot` binds revision, hosts/resources, policy/profile, time, source, outcome, freshness, and exact external disposition. |
| REQ-013 | Private classification, encrypted storage, structural adapter boundary, and prohibited-destination matrix cover artifacts and all derived facts. |
| REQ-014 | Separate discard/unlink/delete flows remove local exact content and relationships, retain only content-free lineage, and name outside-copy limits. |
| REQ-015 | Accessibility design supplies deterministic order, state equivalence, non-gesture inputs, focus/announcements, reflow, contrast, reduced effects, and direct proof. |

## Verification design

| Evidence lane | Required evidence |
| --- | --- |
| Parser/crypto unit | Licensed deterministic Open Badges 3.0 fixtures for every supported context/profile/proof suite; malformed JSON, missing fields, unsupported context/proof, failed signature, altered bytes, invalid canonicalization, key rotation/unavailability, expiry, Bitstring current/revoked, unsupported suspension, oversized/deep/expansive input, cancellation, and resource exhaustion. |
| Domain/command | Exact-byte duplicate, same-ID conflict/no overwrite, new-ID reissue, signed and user-reviewed supersession, independent axes, unverified acceptance, failed-signature rejection, atomic acceptance, idempotent retry, Proof/Capability link/unlink, future-use off, deletion, Receipt/History/Source linkage, and no proficiency/planning inference. |
| Network/privacy abuse | Instrument zero requests during import/inspection/replay. Exercise HTTPS allowlist, DNS rebinding, loopback/link-local/private/reserved/IPv6 targets, userinfo/auth, holder/recipient-bearing and one-to-one URLs, query leakage, cookies/referrers, redirects to reviewed/unreviewed hosts, arbitrary signed links, response type/size, malicious status list, logs/diagnostics, and every prohibited destination. Assert request bytes contain no private identifier/context. |
| External operation | State-machine tests for confirmation digest, stale revision/policy, cancel before effect, permission/network loss, timeout before/after invocation, ambiguous result, reconciliation, duplicate attempt, relaunch, result application, deletion race, and ordinary replay without reissue. |
| Persistence/migration | Additive migration across the supported horizon, exact artifact checksum/storage protection, crash points, low storage, key/protected-data unavailable, corrupt artifact/quarantine, rollback, tombstones, cache unlink/retention, compaction, projection deletion/rebuild, and replay equivalence. |
| Integration/runtime | Physical-device import/reject/accept/offline inspection, duplicate/conflict/reissue, link/unlink, current/expired/revoked/unknown/stale views, every host preview, cancellation/failure/result, relaunch, deletion, and original-file survival with exact fixture and request-trace hashes. |
| Accessibility | Automated semantics plus direct iPhone VoiceOver order/rotors/actions/announcements/focus, Voice Control, Switch Control, Full Keyboard Access, hardware keyboard, Dynamic Type, Bold Text, Button Shapes, contrast/non-color, Reduce Motion/Transparency, RTL/localization, locked-device privacy, error/recovery, and external check progress. Automation alone is insufficient. |
| Performance/resource | Calibrate artifact parse/canonicalization/crypto, hashing, large status-list decode, peak memory, energy, storage/cache amplification, cancellation and deletion latency on representative supported devices. Set thresholds from measured fixtures, not this document. |
| Build/static | XcodeGen after `project.yml` membership edits, focused and changed-scope Code Quality lanes, SwiftLint/static analysis/secrets scan, `git diff --check`, dependency/license review for crypto/JSON-LD fixtures, and canon validation for later canon edits. |

Every evidence bundle binds commit, artifact/status fixture hashes, supported
profile/proof/policy versions, test command, device/OS/toolchain, launched/
executed/pass counts, captured request trace, and known gaps. Unit proof does
not claim end-to-end cryptographic interoperability, network privacy, rendered
states, assistive technology, physical-device, migration, or release proof.

## Open decisions

There are no unresolved product decisions. Broader VC formats, wallets,
presentations, Badge Connect/OAuth, automatic refresh, credential export,
arbitrary link opening, suspension semantics, issuer reputation, or receiver
acceptance must return to Research and Scope.

Implementation grooming must resolve technical-only choices: the exact Open
Badges 3.0 profile revision, proof suites, canonicalization and key-resolution
allowlists; licensed conformance fixtures; calibrated parser/status limits;
public-resource cache representation; HTTP/DNS/redirect hardening APIs; event
and store schema IDs; and Capability-owner API availability. None may widen the
egress or semantic claim boundaries.
