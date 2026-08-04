+++
initiative = "public-reference-knowledge-foundation"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

A user can inspect a supported public fact and understand what is being claimed,
who is authoritative for that particular claim, where and when it applies, when
Ambitions last checked it, and whether it is current, conflicted, superseded, or
unavailable. The same verified fact remains honestly inspectable without an
account or network connection when a safe bundled or last-verified copy exists.

This initiative establishes a shared public-reference truth boundary for later
career, education, and hobby consumers. It does not personalize, recommend, or
change the user's private life graph.

## In scope

- A source-inspection experience for public claims supported by an approved,
  finite public corpus.
- Claim-level identity, meaning, authority-for-purpose, jurisdiction, release or
  effective period, retrieval date, freshness state, attribution, risk, review,
  conflict, and supersession context.
- Source-native concepts and explicit, provenance-bearing crosswalks without
  silent equivalence.
- Honest bundled, last-verified, stale-allowed, conflicted, superseded, and
  unavailable states.
- A first validation corpus limited to the O*NET 30.3 United States Software
  Developers `15-1252.00` slice and the O*NET-owned descriptive facts named in
  approved Research.
- Plain-language, accessible inspection of the source and limits behind every
  visible public claim.
- Product-level eligibility that keeps delivery validity, semantic completeness,
  and recommendation readiness as separate claims.
- The public-only and local-only boundary required for later private matching.

## Out of scope

- Career, education, or hobby destination recommendations and every private
  capability-to-reference match.
- A universal ontology, silent cross-source normalization, or treating O*NET,
  ESCO, CIP, CASE, CTDL, BLS, provider, regulator, and community concepts as
  interchangeable.
- BLS market facts, ESCO crosswalks, employer requirements, qualification,
  employability, or personal-fit claims in the first validation corpus.
- Production ingestion of a broader corpus before its authority, rights,
  freshness, coverage, and risk boundaries are approved.
- Free-form hosted search or retrieval shaped by private intent, private-derived
  requests or cache keys, hosted personalization, or private telemetry.
- Storage of Goals, Proof, capabilities, schedules, recommendation history,
  rejection, correction, or any other private graph data in public packs,
  Source Atlas requests, R2, diagnostics, or feedback.
- Goal creation, destination adoption, Goal Path generation, Step creation,
  scheduling, enrollment, applications, provider contact, purchases, external
  writes, or release authorization.
- Treating source inspection, pack delivery, or structural validation as proof
  that a destination domain is complete or recommendation-ready.

## Requirements

### REQ-001 — Claim meaning remains source-preserving

Every public fact Ambitions presents must retain its subject, predicate, value,
source-native identity, source, authority for that predicate, applicable
jurisdiction, release or effective period, retrieval date, freshness state,
attribution or use constraint, risk and review state, and known conflict or
supersession state. Missing required meaning must be shown as unavailable rather
than inferred.

### REQ-002 — Authority is claim-specific

Ambitions must distinguish classification, description, typical preparation,
hard gate, current provider offering, accreditation or recognition, transfer,
safety or legal rule, and descriptive market or outcome claims. A source's
general reputation or an `official` label must not grant authority for a claim
that source does not own.

### REQ-003 — Crosswalks are inspectable claims

Every relationship between source-native concepts must identify its publisher
or curator, source and target versions, confidence or review state, and known
limits. Absence of an approved crosswalk must preserve distinct concepts rather
than create an apparent equivalence.

### REQ-004 — The first corpus is deliberately narrow

The first usable corpus must be limited to O*NET 30.3, United States Software
Developers `15-1252.00`, and O*NET-owned occupation identity plus descriptive
task, skill, knowledge, work-activity, work-context, education, and experience
facts. Every visible fact must meet the complete source-binding and attribution
bar; unsupported fields remain unavailable.

### REQ-005 — Source inspection is independently useful

A user must be able to open a supported public fact and inspect what the source
says, who owns that claim, its jurisdiction and release, when Ambitions checked
it, its current use state, its attribution, and its material limits without
having to start a recommendation flow.

### REQ-006 — Freshness, conflict, and withdrawal remain honest

Current, aging, stale-allowed, stale-blocked, source-changed, disputed, revoked,
superseded, and unavailable conditions must be distinguishable where applicable.
A source change, conflict, revocation, or missing current authority must block
or qualify only the affected claim and must never be concealed by broader corpus
coverage.

### REQ-007 — Offline and no-account behavior preserves truth

Without an account or network connection, a verified bundled or last-verified
fact may remain inspectable with its actual freshness state. When no safe local
fact is available, Ambitions must say that the reference is unavailable and
must not reconstruct, predict, or imply it. Public-reference failure must not
block the local core.

### REQ-008 — The public firewall is absolute

Public artifacts and their retrieval, cache, logs, diagnostics, and feedback
must contain only approved public/reference data and non-sensitive access state.
Private intent may select among already available public facts only in local
Planning and must never shape a remote request, artifact identity, cache key,
diagnostic value, or public-pack feedback.

### REQ-009 — Rights and attribution govern visibility

A public claim may be packaged or transformed only when its release-specific
rights permit that use and its required attribution remains visible and
accessible. Public availability alone must not be interpreted as redistribution
permission. Rights uncertainty makes the affected content unavailable for that
use.

### REQ-010 — Evidence claim ceilings remain separate

Ambitions must separately communicate whether an artifact was delivered and
verified, whether its visible claims meet the semantic and authority bar, and
whether a domain has enough evaluated coverage for recommendation use. Passing
one state must not imply either of the others.

### REQ-011 — Inspection is accessible without visual inference

Source, authority, jurisdiction, freshness, conflict, unavailability,
attribution, and material limitations must be available in a coherent semantic
reading order, with accessible names for controls and no dependence on color,
shape, motion, hover, or a graph layout to understand the claim. The complete
inspection and recovery flow must support VoiceOver, Voice Control, Switch
Control, Full Keyboard Access and hardware-keyboard operation, Dynamic Type,
increased contrast, reduced effects, RTL, and non-color cues. Focus restoration
and status announcements must return to the exact changed claim, disclosure, or
recovery action.

## Acceptance criteria

- **AC-001 (REQ-001, REQ-002):** Given a supported fact, inspection names the
  exact claim and source-native identity, the authority for that predicate,
  jurisdiction, release/effective date, retrieval/freshness state, attribution,
  review/risk state, and known limits; a classification or descriptive source is
  never presented as a qualification or personal verdict.
- **AC-002 (REQ-003):** Given two related concepts from different sources, the
  relationship shows its provenance, source and target versions, confidence or
  review state, and limitations; removing or rejecting that crosswalk leaves the
  two source-native concepts distinct.
- **AC-003 (REQ-004):** The first validation corpus exposes only O*NET 30.3
  `15-1252.00` facts within the selected descriptive categories. A requested BLS
  fact, ESCO mapping, employer gate, qualification, or personal-fit conclusion
  is unavailable rather than silently added.
- **AC-004 (REQ-004, REQ-009):** Every visible validation-corpus fact carries its
  O*NET 30.3 binding, United States applicability, required CC BY attribution,
  and approved-use state; an unlicensed or unmapped field does not appear as a
  usable claim.
- **AC-005 (REQ-005, REQ-011):** A user can inspect a public fact independently
  of a recommendation and traverse its meaning and limits in semantic order.
  Direct assistive-technology verification covers VoiceOver order/actions,
  Voice Control, Switch Control, Full Keyboard Access and hardware keyboard,
  focus restoration, status announcements, Dynamic Type, increased contrast,
  reduced effects, RTL, and non-color state without hover, motion, or visual
  graph interpretation.
- **AC-006 (REQ-006):** When one fact becomes stale, disputed, revoked,
  source-changed, or superseded, that state and consequence are visible on that
  fact; other valid facts remain available and corpus breadth does not mask the
  affected claim.
- **AC-007 (REQ-007):** With no account and no network, the same bundled or
  last-verified fact and provenance remain inspectable with honest freshness. If
  neither exists, the reference is explicitly unavailable while core local
  planning remains usable.
- **AC-008 (REQ-008):** Private Goals, capabilities, Proof, schedules, searches,
  rejections, and recommendation context never appear in public requests,
  artifact identifiers, caches, logs, diagnostics, feedback, or remote payloads;
  an unrecognized or private-influenced request fails closed.
- **AC-009 (REQ-009):** A source whose rights do not permit the proposed packaged
  or transformed use is omitted for that use, and any visible sourced content
  exposes its required attribution in the accessible inspection experience.
- **AC-010 (REQ-010):** Product and evaluation states can show an artifact as
  delivered but semantically incomplete, or semantically valid but not
  recommendation-ready, without presenting either state as a failure or pass of
  the other.

## Canon impact

- `docs/canon/specifications/systems/source-atlas.md` may need to own the
  claim-specific authority, source-native identity, crosswalk, rights,
  freshness/conflict, and evidence-ceiling behavior that is not yet normative.
- `docs/canon/specifications/objects/source-reference.md` may need to define the
  user-inspectable public-claim identity and its source, version, jurisdiction,
  attribution, and supersession relationships.
- `docs/canon/specifications/systems/local-learning.md` and the future owning
  Planning/recommendation specification may need to state that private matching
  consumes verified public claims locally and cannot turn source confidence
  into a verdict about the user.
- `docs/canon/specifications/global/trust-inspection.md` and the owning surface
  specification may need the accessible source-inspection behavior and honest
  unavailable states.
- Existing `LAW-R2-PUBLIC-ONLY-001`, `LAW-OFFLINE-NO-ACCOUNT-001`,
  `CONST-PROOF-EVIDENCE-001`, and the Source Atlas firewall remain governing and
  must not be weakened.

## Risks and open decisions

### Dependencies

- Broader use depends on approved domain-specific Research and Scope defining
  who owns each career, education, or hobby claim and what coverage is enough
  for that consumer.
- This Scope's O*NET 30.3 Software Developers validation slice does not authorize
  NASA, nursing/licensing, education-provider, accreditation, transfer,
  credential, hobby, safety, or any other domain-corpus expansion. Each broader
  corpus requires separately approved Research and Scope before a dependent
  initiative may treat its claims as authoritative or recommendation-ready.
- Capability continuity must define user-owned capability meaning before any
  private capability is compared with a public concept.
- Production use of every source release depends on rights review, source-release
  change evaluation, and evidence that its selected claims satisfy this Scope.
- The current private-context composer under `SourceAtlas/` conflicts with the
  canon owner boundary; Design must keep public delivery in Source Atlas and the
  private join in local Planning rather than treating that source location as
  authority.

### Risks

- A semantically precise but tiny corpus can be mistaken for broad coverage.
- A single crosswalk can create false equivalence across occupational,
  competency, education, credential, and user-owned capability concepts.
- Release changes, source disputes, and rights changes can alter or withdraw
  otherwise familiar facts.
- Detailed provenance can become inaccessible or overwhelm the primary fact if
  the next phase does not preserve a calm semantic hierarchy.

### Decisions carried into Design

- The exact presentation of primary fact, source detail, and deeper provenance
  may be designed, but every REQ-001 field and consequence must remain
  accessible.
- The next phase may choose how users move among related claims, but it may not
  collapse source-native identity or add a universal ontology.
- Numeric performance and storage budgets require representative corpus/device
  measurement during grooming; this Scope does not invent them.
