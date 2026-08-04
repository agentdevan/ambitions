+++
initiative = "verifiable-credential-import"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

A user may hold a degree, certificate, professional credential, license, or
Open Badge that provides stronger provenance than a self-entered profile row.
Ambitions should be able to preserve the issuer's claim and evidence without
turning cryptographic validity into a claim of current competence, universal
acceptance, employability, or legal eligibility.

The user needs to know exactly what was verified, what is merely declared by
the issuer, whether the artifact is expired or revoked, what a receiving school
or employer has actually accepted, and how the credential relates to private
Capabilities and Proof. Those are independent facts with different owners.

## Current truth

This Research uses `main` at
`40894e92c61de55841c31fd797fd5ae39625c5dc`, current canon/source/tests, and the
adaptive-skills portfolio Research.

Proof is user-approved, private, and ungraded. Source Reference owns provenance
for external facts. Privacy canon makes any credential joined to the user
private graph data. Import/repair canon requires staged review, fingerprints,
freshness revalidation, bounded commits, partial-result recovery, and no silent
external mutation. No canonical Credential object, wallet, Open Badges parser,
issuer-status resolver, or end-to-end credential import currently exists.

The source tree contains evidence and freshness primitives but not a complete
credential trust model. Public Source Atlas structures cannot store the user's
credential. Capability can relate to issuer-backed evidence only after the
Capability foundation establishes a private relationship owner.

Open Badges 3.0 was rechecked through official 1EdTech material on 2026-08-03.
The standard represents issuer assertions, achievement criteria, evidence,
issuance, recipient binding, expiration, and optional alignments as W3C
Verifiable Credentials. Cryptographic verification establishes tamper evidence,
authenticity, and integrity of the signed assertion; it does not establish that
the issuer is reputable, the holder retains current competence, or a receiver
accepts the achievement.

## Evidence

Official [1EdTech Open Badges](https://www.1edtech.org/standards/open-badges)
material supports six separate trust questions:

1. Can the artifact be parsed and has its content remained intact?
2. Does the signature/key path validate for the stated issuer?
3. What achievement, criteria, evidence, dates, and recipient does the issuer
   assert?
4. Is the credential currently expired, revoked, or unverifiable under the
   selected Open Badges status mechanisms?
5. Does another authority endorse, accredit, or recognize the issuer or program?
6. Has the specific employer, school, regulator, or other receiver accepted it
   for the user's intended purpose?

Only the first four can potentially be established by artifact and issuer
status checks. The last two require separate current authority evidence. A badge
alignment to a competency framework is publisher-authored context, not an
equivalency decision and not proof of mastery.

Credential state is time-dependent. Issuer keys, status lists, expiration,
revocation endpoints, and linked criteria may be unavailable or changed. A
previously verified artifact can remain part of truthful History while its
current validity becomes stale, revoked, or unknown. Offline use needs a clearly
dated last-known result rather than a fabricated current check.

The W3C [Bitstring Status List privacy considerations](https://www.w3.org/TR/vc-bitstring-status-list/#privacy-considerations)
make the network boundary material to the product. A one-credential status URL
can let an issuer correlate when a verifier checks a particular holder, while a
shared list improves group privacy. The same specification recommends caching
and privacy-preserving retrieval. Ambitions therefore cannot describe a status
lookup as harmless merely because it sends no request body.

Credentials may also expose sensitive education, employment, health,
citizenship, membership, disability, or identity facts. Selective disclosure
and derived-output classification are therefore product requirements, not only
cryptographic details.

### First-format and status investigation

Official 1EdTech specification and conformance material resolves a bounded
first format: a user-selected Open Badges 3.0 `OpenBadgeCredential` represented
as JSON/JSON-LD and verified through a viewer-initiated check. The first boundary
does not include Badge Connect/OAuth, baked PNG or SVG extraction, a wallet,
Verifiable Presentations, CLR bundles, or arbitrary Verifiable Credentials.

The 1EdTech conformance guide, rechecked 2026-08-03, explicitly tests three badge
states: current, expired through `validUntil`, and revoked through a
`BitstringStatusListEntry` whose purpose is revocation. That supplies a primary
fixture source for the first three cases. The complete research fixture matrix
is:

- structurally valid, supported proof, current, and not revoked;
- structurally valid and expired;
- structurally valid and revoked;
- malformed JSON, missing required fields, unsupported context/proof, or failed
  signature, all rejected without creating a credential;
- valid signed content whose issuer document or status list is unavailable,
  retained only as unverified/pending rather than failed or current; and
- a previously verified artifact inspected offline, showing the dated last-known
  result and inability to claim a current network check.

The selected conformance profile does not supply a tested generic suspension
state. A credential using an external or unsupported suspension mechanism is
therefore **unsupported/unknown** in the first boundary, not silently treated as
current, expired, or revoked. Supporting suspension requires separate source
evidence and status semantics.

The official [Open Badges conformance guide](https://standards.1edtech.org/open-badges/specifications/standards/v3p0/cert)
and [implementation guide](https://standards.1edtech.org/open-badges/guides/standards/v3p0/impl)
also show that supported proof mechanisms and revocation guidance can change.
The selected specification/profile version is therefore part of provenance and
freshness, not an invisible parser detail.

### Credential identity, retention, and status-check boundary

Research resolves duplicate and replacement behavior by signed artifact
identity, not by display labels. Re-selecting the exact same artifact produces
an “already imported” result and may refresh its status, but does not create a
second Credential. A changed payload that reuses the same credential identifier
is a conflict requiring review and never overwrites the accepted bytes. A
reissue with a new identifier remains a separate Credential. The older record
becomes superseded only when signed issuer data explicitly relates the new
credential to it or the user deliberately chooses that relationship after
review; matching recipient, title, issuer, or achievement is only a possible
duplicate signal. Expiry and revocation change current status but do not imply
deletion or supersession.

The selected bytes are a temporary staged copy until review is accepted. Cancel,
rejection, or discard removes that staged copy and its parsed private values;
only a content-free failure fact may remain in Receipt/History. Acceptance
retains the exact signed artifact locally with the Credential because later
inspection and verification must remain grounded in what was actually
accepted. The user-selected source file outside Ambitions remains under the
owning app or Files location and is never claimed deleted by Ambitions.

Unlinking a Credential from Capability or Proof removes only that relationship.
Deleting the Credential removes its retained artifact, parsed private fields,
cached status material, and Capability/Proof relationships. A minimum
non-reconstructive History fact may say that a credential was deleted, but it
cannot retain the title, recipient, achievement, identifier, evidence, or other
claim content. The external source copy and any previously disclosed copy are
outside Ambitions' deletion authority.

Import and offline inspection perform no network access. `Check current status`
is a separate viewer-initiated action that previews every destination host and
the correlation risk before each fetch. The first boundary may retrieve only
the verification material needed for the issuer/proof and a shared public HTTPS
`BitstringStatusListCredential`. It sends no credential, recipient or subject
identifier, private graph context, Ambitions identifier, account token, or
receiver purpose, and it does not follow criteria, evidence, profile, refresh,
or unrelated links.

A status URL that is one-to-one with the credential, contains a recipient or
subject identifier, requires authentication, targets a non-public or non-HTTPS
destination, or redirects to a host the user did not review is unsupported in
this first boundary. An arbitrary embedded endpoint is never contacted merely
because it appeared in signed JSON. Ambitions shows current status as unknown
when the minimum privacy boundary cannot be met, while retaining the dated
last-known result separately.

## Alternatives

### Store a credential title manually

This is simple and private but provides no artifact or issuer integrity. It
remains a valid user-stated claim and must not be mislabeled verified.

### Treat credentials as Proof

Proof can preserve user evidence, but it does not own issuer status, revocation,
recipient binding, or receiver acceptance. Collapsing the two would either
overstate Proof or erase credential-specific semantics.

### Full credential wallet

A wallet could support broad standards, presentation protocols, and selective
disclosure. That is a much larger identity/security product and is not justified
by current Ambitions evidence.

### Narrow verified-artifact import

Import a bounded supported format, verify locally where possible, preserve exact
issuer claims and status, and let the user selectively link it to Capability or
Proof. This offers value without claiming a universal wallet.

## Unknowns and risks

- Open Badges 3.0 JSON/JSON-LD is the first researched format. Design and
  verification still need exact licensed/conformance fixtures for every matrix
  state; no broader credential-format coverage is implied.
- Network status checks must send no private capability, Goal, schedule, or
  recommendation context. A shared status URL can still expose retrieval timing
  to its host, so the exact destination and last check remain inspectable.
- Key rotation, issuer disappearance, compromised issuers, status-list outages,
  and unsupported signature suites need honest degraded states.
- A verified signature can create dangerous overconfidence. Copy and evidence
  must keep artifact integrity separate from competence and acceptance.
- A malicious issuer can reuse identifiers, publish holder-specific status
  endpoints, or describe an unrelated artifact as a replacement. The resolved
  identity and network rules limit these attacks but cannot establish issuer
  trustworthiness.
- Professional licenses and regulated eligibility require the relevant current
  regulator, not only a badge issuer.
- Export/presentation of a credential is excluded, uncommitted future work and
  cannot be implied by import or by the focused capability-export initiative.

## Recommended direction

Research favors a narrow, optional Open Badges 3.0 JSON/JSON-LD import that
preserves the original artifact, issuer assertion, criteria/evidence links,
issuance and expiry,
verification method/result/time, revocation or status result, and uncertainty.
The user reviews the imported assertion before it becomes Ambitions-owned and
chooses whether to relate it to a Capability or Proof.

The recommended lifecycle is exact-artifact deduplication, conflict review for
changed bytes under the same identifier, separate records for reissues, and no
supersession without issuer evidence or a deliberate user relationship. Staged
private bytes disappear on cancellation or rejection; accepted bytes live only
with the Credential; Credential deletion removes the artifact, derived private
state, and relationships while preserving at most a content-free deletion fact.

The recommended network posture is offline by default and explicit per-check
egress. Only reviewed public verification hosts and shared status-list
resources are eligible. Recipient-bearing or credential-specific endpoints,
authentication, unrelated links, private-network targets, and unreviewed
redirects fail closed to an honest unknown status rather than trading the
holder's privacy for a fresher badge label.

The product direction should state “verified artifact/issuer assertion” rather
than “verified skill.” Offline inspection remains useful with a dated last-known
status. Unknown, expired, revoked, contradicted, or receiver-unaccepted states
remain distinct and never erase truthful History.

The import can preserve a credential and relate it to Proof without Capability
continuity. That foundation becomes a dependency only when the user relates the
credential to a Capability. Research still indicates a likely canonical
Credential owner. The initiative excludes profile archives, recommendation
decisions, formal equivalency, licensing adjudication, and outbound
presentation/export; the last is an uncommitted future idea with no implied
Scope in this portfolio.
