+++
initiative = "verifiable-credential-import"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

The user can select one Open Badges 3.0 JSON/JSON-LD credential, understand the
issuer assertion and exactly what Ambitions could or could not verify, and
choose whether to retain it privately. A valid signature means the accepted
artifact was signed through the stated verification path; it does not mean the
user currently possesses a skill, the issuer is reputable, or an employer,
school, regulator, or other receiver accepts the credential.

Import and ordinary inspection work offline. A current issuer or revocation
check is a separate, viewer-initiated network action with an exact destination
and correlation-risk preview. Unsupported or privacy-unsafe status mechanisms
produce an honest unknown state rather than a false current result. Credential,
Proof, Capability, and receiver acceptance remain separate facts with separate
owners and deletion consequences.

## In scope

- One user-selected Open Badges 3.0 `OpenBadgeCredential` encoded as JSON or
  JSON-LD under an explicitly supported profile/version.
- Private local staging, structural validation, supported proof/signature
  verification from locally available material, user review, acceptance,
  cancellation, rejection, and deletion.
- Exact retention of the accepted signed artifact with an Ambitions-owned
  Credential record.
- Inspectable issuer assertion: issuer, recipient-binding summary, achievement,
  criteria/evidence references, issue/expiry dates, selected profile version,
  proof method/result/time, and uncertainty.
- Distinct current, expired, revoked, unverified/pending, unsupported/unknown,
  conflicted, stale, and deleted states where supported by evidence.
- Exact-artifact deduplication, changed-payload conflict review, separate reissue
  identity, and explicit supersession.
- Optional user-selected relationship to Proof; optional Capability linkage
  only when the Capability owner exists and the user separately confirms it.
- A separate `Check current status` action limited to reviewed public
  verification material and shared HTTPS Bitstring Status List resources.
- Offline last-known status inspection with the exact check time and freshness.
- Local-first privacy, non-reconstructive deletion, Receipt/History/replay, and
  direct accessibility verification.

## Out of scope

- Badge Connect, OAuth, account sign-in, automatic issuer synchronization,
  background refresh, credential wallet behavior, or holder presentation.
- Baked PNG/SVG extraction, CLR bundles, arbitrary W3C Verifiable Credentials,
  Verifiable Presentations, selective-disclosure presentation, or non-Open-
  Badges credential formats.
- Generic suspension semantics; unsupported suspension is unknown.
- Credential export, sharing, resume generation, employer/school submission,
  or any claim that import grants disclosure permission.
- Issuer reputation, accreditation, endorsement, equivalency, transfer credit,
  employability, admissions, licensing, legal eligibility, or receiver
  acceptance decisions.
- “Verified skill,” mastery, proficiency, capability score, automatic Goal or
  Path creation, or planning influence.
- Following criteria, evidence, profile, refresh, image, or unrelated links;
  arbitrary signed URLs do not grant network authority.
- Private-network, authenticated, holder-specific, recipient-bearing,
  credential-specific, or unreviewed redirect destinations.

## Requirements

### REQ-001 — Selection starts a private staged review

The user must deliberately select one supported JSON/JSON-LD file and see that
selection creates no Credential, Proof, Capability, or network request. The
selected bytes are a private staged copy only until the user accepts, cancels,
rejects, or discards the review. The original outside file remains under its
owning app or Files location and outside Ambitions' deletion authority.

### REQ-002 — The supported credential boundary is explicit

Ambitions must accept only an Open Badges 3.0 `OpenBadgeCredential` whose
context, required fields, proof mechanism, and selected profile version are
explicitly supported. Malformed JSON, missing required fields, unsupported
context/proof, failed signature, oversized input, or unsafe structure must be
rejected without creating a Credential. Unsupported is not equivalent to
invalid, expired, revoked, or current.

### REQ-003 — Verification claims are narrowly named

The review must distinguish structural parsing, artifact integrity,
signature/key-path result, issuer assertion, recipient binding, expiry,
revocation/status, issuer recognition, and receiver acceptance. Ambitions may
say “verified artifact” or “issuer assertion” only for the facts established by
the supported check. It must never translate those facts into verified skill,
competence, issuer trustworthiness, or universal acceptance.

### REQ-004 — Credential states remain independent

Artifact verification, expiration, revocation, freshness, conflict,
supersession, Capability/Proof linkage, and receiver acceptance must remain
orthogonal inspectable facts. Expiry, revocation, stale status, or receiver
non-acceptance must not delete the Credential or rewrite the historical result.
A status mechanism outside the supported current/expired/revoked boundary is
unsupported/unknown.

### REQ-005 — Unavailable verification remains honest

A structurally supported artifact whose issuer document, key material, or
status evidence is unavailable may be accepted only as unverified/pending with
the missing dependency and uncertainty visible. It must not be called failed,
current, verified, or revoked without evidence. Offline inspection must show
the dated last-known result separately from the fact that no current check was
performed.

### REQ-006 — Acceptance retains the exact artifact

Before acceptance, the user must see the issuer assertion, private-data scope,
verification result and time, current-status limits, relationship choices,
retained exact artifact, and deletion consequences. Acceptance creates one
private Credential record bound to the exact signed bytes and selected profile
version through canonical mutation, Receipt, History, and replay. Rejection or
cancellation removes the staged artifact and parsed private values, retaining
at most a content-free failure fact where required.

### REQ-007 — Artifact identity governs duplicates and conflicts

Re-selecting the exact same artifact must show “already imported” and may offer
a fresh status check without creating another Credential. Changed bytes under
the same credential identifier create a conflict and must never overwrite the
accepted artifact. A reissue with a new identifier remains separate. An older
Credential may be marked superseded only by signed issuer relationship data or
an explicit user-reviewed relationship; matching title, issuer, recipient, or
achievement is only a possible-duplicate signal.

### REQ-008 — Credential, Proof, and Capability stay distinct

The user may link or unlink an accepted Credential to a Proof without changing
either object's meaning. Linking to a Capability is available only when the
Capability owner exists and after the user reviews the relationship; it adds an
issuer-backed evidence relationship but does not create proficiency, current
competence, or future planning permission. Unlinking removes only the selected
relationship.

### REQ-009 — Current-status checking is a separate explicit action

Import, acceptance, and ordinary inspection must perform no network access.
Before every `Check current status` action, Ambitions must show each destination
host, requested resource class, why it is needed, the retrieval-time
correlation risk, the fact that no private credential or graph context will be
sent, and the effect of cancel or failure. Confirmation applies only to that
check and cannot authorize background or future checks.

### REQ-010 — Status-check egress fails closed

An eligible check may retrieve only the minimum public verification material
needed for the supported issuer/proof path and a shared public HTTPS Bitstring
Status List Credential. The request must contain no credential, recipient or
subject identifier, private graph context, Ambitions identifier, account token,
receiver purpose, or capability data. One-to-one or holder-bearing URLs,
authentication, non-public/non-HTTPS destinations, private-network targets, and
redirects to an unreviewed host are unsupported and must yield unknown status
without contact.

### REQ-011 — Arbitrary links do not grant authority

Ambitions must not fetch criteria, evidence, profile, refresh, image,
achievement, or unrelated links merely because they appear in signed content.
Their labels and URL hosts may be shown at a privacy-minimized level for user
inspection, but opening or exporting them is outside this Scope and cannot be
required to retain the Credential.

### REQ-012 — Status results retain source and time

Every successful or failed current-status check must preserve the selected
Credential revision, reviewed host set, supported profile/policy version, check
time, result source, current/expired/revoked/unknown outcome, freshness, and
truthful external result without retaining private request content. A later
offline view shows that dated result and never presents it as a current network
check.

### REQ-013 — Credential privacy includes all derived facts

The artifact, recipient binding, issuer assertion, parsed fields, evidence and
criteria references, verification result, status cache, links, conflicts, and
relationships are private local graph data. They must not reach Account, R2,
Source Atlas, hosted AI, analytics, telemetry, or an Ambitions backend. Unknown
classification, protected output, or unsafe destination blocks the applicable
proposal or network action without deleting the local artifact.

### REQ-014 — Deletion is scoped and non-reconstructive

Discard removes only unaccepted staging. Unlink removes only the chosen
Credential–Proof or Credential–Capability relationship. Permanently deleting a
Credential removes its retained artifact, parsed private fields, cached status
material, derived state, and all relationships after consequence review; a
related Proof or Capability remains under its own lifecycle but loses that
support. Receipt/History may retain only a content-free deletion fact. The
original outside file and any previously disclosed copy remain outside
Ambitions' deletion authority.

### REQ-015 — The experience is accessible and fail-quiet

Selection, issuer assertion, verification layers, status and freshness,
uncertainty, conflict, duplicate/reissue comparison, link choices, destination
preview, correlation warning, progress, cancellation, result, deletion, and
recovery must have a deterministic semantic order. All actions must support
VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Dynamic Type,
increased contrast, reduced effects, non-color state, named non-gesture
controls, status announcements, and predictable focus restoration.

## Acceptance criteria

1. **AC-001 (REQ-001):** Selecting a supported artifact creates no object and
   performs no network request. Cancel or reject removes staged bytes and parsed
   values while leaving the outside file unchanged.
2. **AC-002 (REQ-002):** A structurally supported Open Badges 3.0 artifact
   reaches review. Malformed, missing-field, unsupported-proof/context,
   failed-signature, or oversized input creates no Credential and reports its
   exact invalid or unsupported state without false verification.
3. **AC-003 (REQ-003, REQ-004):** Inspection separately states parsing,
   signature/integrity, issuer assertion, recipient binding, expiry,
   revocation, recognition, and receiver acceptance. A valid signature never
   produces “verified skill,” competence, employability, or eligibility copy.
4. **AC-004 (REQ-004, REQ-005):** Current, expired, and revoked fixtures remain
   distinct. Unavailable issuer/status material can be retained only as
   unverified/pending or unknown, and an unsupported suspension mechanism is
   never treated as current.
5. **AC-005 (REQ-006):** Acceptance previews retained exact bytes and commits
   one Credential with artifact/profile binding, result time, Receipt, History,
   and replay; cancellation before acceptance leaves no Credential.
6. **AC-006 (REQ-007):** Re-importing identical bytes does not duplicate.
   Changed bytes under the same identifier require conflict review and preserve
   the accepted artifact. A reissue stays separate unless signed issuer evidence
   or deliberate user review establishes supersession.
7. **AC-007 (REQ-008):** Credential–Proof and Credential–Capability links can
   be added and removed independently. No link changes the source objects,
   creates proficiency, enables future use, or upgrades receiver acceptance.
8. **AC-008 (REQ-009, REQ-010):** Import and offline inspection make zero
   network requests. A status check cannot start until the user reviews and
   confirms every eligible host and correlation warning for that single check.
9. **AC-009 (REQ-010, REQ-011):** A shared public HTTPS status list may be
   fetched with no private identifiers. Holder-specific, authenticated,
   private-network, non-HTTPS, or unreviewed-redirect URLs are not contacted;
   criteria, evidence, image, and unrelated links are never followed.
10. **AC-010 (REQ-012):** A successful, failed, or cancelled check records its
    exact external result and time. Offline inspection labels a prior result
    “last checked” and cannot imply current freshness.
11. **AC-011 (REQ-013):** Privacy-egress tests show no artifact, recipient,
    Capability, Goal, schedule, or private identifier reaches a prohibited
    destination, including logs and diagnostics; unsafe classification yields
    a quiet blocked action.
12. **AC-012 (REQ-014):** Staging discard, unlink, and Credential deletion have
    distinct previews. Credential deletion removes local artifact/content/cache
    and relationships without deleting linked Proof/Capabilities or claiming
    deletion of outside copies.
13. **AC-013 (REQ-015):** Direct accessibility verification covers artifact
    review, layered status, conflict comparison, linking, host/correlation
    preview, progress, cancellation, result, deletion, and recovery without
    gesture, color, motion, side-by-side layout, or visual-only meaning.

## Canon impact

- Canon requires a new private Credential object contract to own exact artifact
  identity, issuer assertion, supported profile, verification/status axes,
  duplicate/conflict/reissue/supersession behavior, relationships, retention,
  lifecycle, and deletion. It must remain distinct from Proof, Capability,
  Source Reference, and receiver acceptance.
- `docs/canon/specifications/systems/import-export-repair.md` should own the
  supported Open Badges intake boundary, staged validation, hostile-input
  limits, review, cancellation, deterministic retry, and quarantine.
- `docs/canon/specifications/objects/source-reference.md` should own artifact
  source provenance and outside-file separation without making an issuer or
  external system the private-graph authority.
- `docs/canon/specifications/objects/proof.md` and the canonical Capability
  object should own only their respective user-confirmed relationships; neither
  may absorb Credential status or verification meaning.
- `docs/canon/specifications/systems/privacy-and-data-classification.md` should
  own credential/derived-data classification and the per-check egress firewall.
  Existing external-effect law should own host preview, pending/result state,
  redirect rejection, idempotency, and the rule that replay never repeats
  network egress.
- Trust should own layered verification and provenance inspection; You's
  Sources & Imports depth should own broad discoverability and deletion
  controls. Existing Receipt, History, replay, deletion, offline, and
  accessibility canon remains fully applicable.

## Risks and open decisions

Resolved product decisions:

- The first format is one Open Badges 3.0 JSON/JSON-LD
  `OpenBadgeCredential`; broader wallet and credential formats are excluded.
- Failed signature creates no Credential; unavailable verification material may
  be retained only as unverified/pending.
- Exact artifact bytes define duplicate identity; same-ID changed bytes are a
  conflict and reissues remain separate.
- Import and ordinary inspection are offline. Every status check requires a new
  reviewed-host and correlation-risk confirmation.
- Only minimum public verification material and shared HTTPS Bitstring Status
  Lists are eligible; privacy-unsafe endpoints fail closed to unknown.
- Verified artifact, issuer assertion, Capability, Proof, and receiver
  acceptance remain separate.

Dependencies and delivery risks:

- Capability linking depends on the canonical Capability owner; Credential
  import and optional Proof linkage remain coherent without it.
- Exact conformance fixtures, supported proof suites, key-resolution rules, and
  status-list semantics must be fixed and licensed during Design/grooming
  without broadening the product format.
- Issuer disappearance, key rotation, malicious same-ID payloads, compromised
  issuers, outages, redirect attacks, and holder-specific endpoints require
  explicit degraded-state and abuse verification.
- Exact artifact retention raises storage and deletion sensitivity; migration,
  corruption, backup/export exclusion, replay, and data-remanence tests are
  required.
- Current source has no Credential owner or end-to-end parser/status service;
  adjacent evidence and freshness models are not implementation proof.
