+++
initiative = "education-destination-recommendations"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Education exploration is a resumable, local Planning flow presented from the
Goals surface. It does not add a root destination and does not require the
user to create a Goal. A user starts with one user-owned learning objective or
chosen life direction and first sees three type-level possibilities: a degree
program, a provider-issued professional certificate, and an open self-study
course. The three forms remain visibly distinct and explain their ordinary
commitment, completion meaning, recognition and transfer limits, and unknowns.

Named providers are a second, explicit threshold. The user chooses **Explore
current providers** for one or more route forms before a provider or offering
name can appear. Even then, the named-provider layer stays unavailable unless
the public-reference owner supplies an approved, recommendation-ready education
corpus. The currently approved O*NET 30.3 Software Developers validation slice
does not satisfy that gate. The UMGC, Google, and CS50x Research examples remain
paper-pilot evidence and are never compiled into product fixtures, fallback
content, search results, or special cases by this Design. Their literal names
may occur only as negative-gate sentinels in tests that prove those identities
cannot enter production recommendation. Synthetic, non-provider analogues test
the six-lane authority behavior until a separately approved corpus authorizes
real provider records.

When a future education-domain corpus is separately approved, Source Atlas
delivers its finite public artifact without private selectors. A new education
recommendation owner under local Planning joins that public snapshot to the
objective and only the private inputs selected for this exploration. It creates
an eligible set through claim-level, boolean inclusion rules; it does not score
or rank. The initial comparison window contains at most two offerings per route
form in stable provider-identity then offering-identity order. Every other
eligible offering remains identifiable, inspectable, and user-selectable.
Explicit user selection or narrowing changes the window, not the underlying
eligible set or access to it.

Every named option is an explanation, not a verdict. Its six authority lanes—
classification, learning meaning, current offering, recognition, transfer, and
descriptive outcomes—remain independent. Capability overlap may explain likely
curriculum repetition but never mastery, credit, waiver, admission, quality,
employability, or return. Choosing an option creates only a typed handoff to
`destination-adoption-and-pivot`; it creates no Goal, Path, Step, Proof rule,
Time placement, provider contact, application, payment, or external write.

## User flows

### 1. Start from a user-owned direction

1. From Goals, the user chooses **Explore ways to learn**. From an existing
   Goal or reviewed destination, the same action may prefill that item's exact
   outcome as a read-only source binding. Otherwise the user enters one learning
   objective. Neither route mutates the source object.
2. The opening review says, “These are ways you could learn next. Nothing here
   is a Goal or a judgment about your potential.” It shows the objective's
   source and an **Edit direction** action.
3. The privacy classifier evaluates the objective before it influences any
   rationale. A normal objective is the one input authorized by the explicit
   start action. A protected or uncertain objective requires the exact consent
   flow described below. Without that consent, the user may inspect only the
   generic three-form comparison, replace the objective, or end exploration;
   no objective-specific rationale or named candidate is produced.
4. The flow creates one local draft session and advances to the three-form
   comparison. It does not create a Goal or save a destination candidate.

The presentation uses a `NavigationStack` inside the Goals-owned exploration
route, not a new root tab. Its stable steps are **Direction**, **Ways to learn**,
**Inputs**, optional **Providers**, **Compare**, and **Handoff review**. Back
navigation never commits the later step implicitly.

### 2. Compare the three route forms before providers

1. **Ways to learn** always renders degree program, provider-issued professional
   certificate, and open self-study course in that semantic order.
2. Each form shows locally bundled product semantics: typical commitment shape,
   what completion ordinarily means, what recognition might exist, what
   transfer cannot be assumed, and what remains unknown without a named
   offering. These statements are definitions and claim ceilings, not provider
   facts.
3. If a form cannot be supported by current product evidence, its row remains
   in place as **Unavailable for current comparison** with a reason. Another
   route form never substitutes for it.
4. The user chooses any subset of the three forms for deeper review or continues
   with all three. Reordering, a winner state, percent match, and “best” language
   do not exist.

The bundled descriptor contract is exact and versioned as product policy. It
does not contain current provider facts, numeric duration/cost claims, outcome
claims, or corpus-derived examples:

| Form | Meaning shown to the user | Commitment and completion meaning | Recognition and transfer ceiling | Always unknown until a qualified named offering supplies it | Prohibited inference |
| --- | --- | --- | --- | --- | --- |
| Degree program | “A provider-defined program of study that can lead to a degree when that provider confirms all of its requirements are complete.” | “Usually includes multiple required areas of study under provider and catalog rules. The provider alone decides whether the program is complete and awards the degree.” | “Accreditation or approval is a separate fact with an exact institution or program scope. A degree does not automatically establish licensure, certification, admission elsewhere, or transfer credit. A receiving institution decides prior-learning and transfer value.” | Exact provider/program/branch, catalog, curriculum, admission, dates, duration, delivery, location, technology needs, price, availability, accreditation/monitoring state, transfer, outcomes, accessibility support, and individual fit. | Admission, affordability, quality, prestige, completion, employment, licensure, return, or that a degree is required for the objective. |
| Provider-issued professional certificate | “A provider-defined learning sequence that can lead to that provider's certificate when its stated completion rules are met.” | “Usually focuses on a bounded subject or practice area. Content, pace, assessment, and completion rules belong to the provider. The artifact records provider-defined completion; it is not a degree, license, or independent professional certification unless the proper authority separately says so.” | “Recognition depends on the receiving school, employer, certification body, or other authority. Curriculum overlap does not create academic credit, waive a prerequisite, or make the certificate stackable.” | Exact provider/certificate/version, curriculum, prerequisites, assessment, dates, duration, delivery, location, technology needs, price, availability, receiver recognition, articulation, outcomes, accessibility support, and individual fit. | Competence, mastery, transfer, employability, certification eligibility, quality, completion, return, or equivalence to a degree/course. |
| Open self-study course | “An openly available course or body of instructional material that a learner can use without assuming admission to a degree or certificate program.” | “Pacing, support, assessment, and completion artifacts vary. Accessing material is not completion. A free completion artifact and a paid or verified artifact remain different when the provider distinguishes them.” | “Open access does not create academic credit, accreditation, licensure, or professional recognition. Only a receiving authority can accept the work for credit or another requirement.” | Exact publisher/course/version, curriculum, support, assessment, completion artifact, access term, dates, expected effort, technology needs, price, availability, receiver recognition, outcomes, accessibility support, and individual fit. | Credit, transfer, mastery, equivalence, admission, employability, completion, quality, return, or that an available course is current. |

`EducationRouteFormDescriptor` stores this matrix as
`education_route_forms.v1` and links to the approved Scope and Design revision
that own the copy. It is not
a Source Atlas fact and has no network freshness state. Any change to the form
meaning or claim ceiling requires product-document/canon review. If the app
cannot load the exact supported descriptor version, that form renders
`routeFormUnavailable`; it cannot synthesize copy, fall back to another form,
or borrow a provider claim.

### 3. Select private inputs deliberately

1. The **Inputs** step begins with only the supplied objective active. Eligible
   capabilities, Proof references, education/training facts, preferences, and
   constraints appear in an unselected tray grouped by their owning object, not
   by a system-inferred profile.
2. Selecting a non-protected input shows the exact purpose—relevance explanation,
   overlap explanation, or an explicitly requested narrowing—and the sections
   it can affect. A generic capability future-use flag is never read as
   education permission.
3. Selecting a protected input opens a fresh disclosure naming that exact fact,
   the education purpose, the affected comparison behavior, local-only handling,
   retention in this session, and what revocation removes. Only **Use this fact
   for this education review** grants consent. Consent is bound to the session,
   fact revision, purpose, policy revision, and disclosure revision. It cannot
   authorize another fact or a future exploration.
4. If a datum's classification is unknown, it cannot be selected. The user sees
   that the input cannot be used safely and may review it with its owning
   feature; no protected classification is guessed.
5. The **Inputs used** inspector lists each active binding and which rationale,
   overlap, or explicit filter it affected. Removing an input or revoking
   consent immediately invalidates dependent results, hides the old projection,
   and recomputes from a fresh snapshot. Unrelated results retain their stable
   identities.

An output privacy gate runs after composition as well as before it. If a
candidate identity or rationale would expose protected context beyond exact
consent, or the output classification is uncertain, that result is discarded
before count, ordering, omission, persistence, accessibility values, or UI
projection. The product uses the same neutral no-current-option state it uses
for other ineligible results; it never reveals that privacy suppression
occurred or substitutes a proxy.

### 4. Cross the provider-intent and corpus gates

1. On a route form, **Explore current providers** opens a confirmation that
   names the selected forms and says this permits only local comparison of
   approved public facts. It does not permit contact, enrollment, application,
   external search, or additional private inputs.
2. Confirmation records provider intent for those forms and evaluates the
   installed public corpus. The evaluation distinguishes artifact delivery,
   semantic validity, and recommendation readiness.
3. Unless an exact education-domain corpus is `recommendationReady`, the
   provider layer shows **Current provider comparison isn't available from the
   approved education sources on this device**. It offers **Keep comparing ways
   to learn** and, when an inspectable approved public education claim exists,
   **Inspect available public sources**. It never promotes the O*NET slice, a
   Research URL, ad hoc network fetch, or user-entered web address into an
   offering.
4. When a qualifying corpus is present, provider comparison requires one
   inspectable objective-concept binding. The device may offer source-native
   learning concepts whose approved label or alias exactly matches the user's
   wording, but the user confirms the concept before it filters offerings.
   Ambiguous, fuzzy, model-generated, or silently inferred equivalence is not a
   binding. If no concept is confirmed, general named candidates remain
   unavailable; the user may continue type-level comparison or inspect one
   exact offering they name.
5. The local composer then builds the eligible
   set. A user may also choose **Find an offering I have in mind** and enter a
   provider/offering name. That text searches only the already verified local
   education corpus. It is never transmitted or used in a cache key. An exact
   source-qualified match occupies one of the two comparison positions; an
   absent, ambiguous, stale-blocked, or insufficiently sourced match shows the
   exact public-source insufficiency reason instead. If the match is removed by
   the protected-input or derived-output privacy gate, the lookup uses the same
   neutral `noEligibleOffering` state as every other privacy-filtered result; it
   never names the offering, count, suppression, or reason.
6. **Stop showing providers** removes provider intent from the active session,
   clears active provider search text, filters, and window selections, and
   returns to route forms. Prior user actions remain in local History with
   private content minimized, while no provider identity remains in the active
   projection. A saved option remains saved but is marked **Provider review
   paused** until the user deliberately restores provider intent and it passes
   current revalidation.

### 5. Form the neutral eligible set and comparison window

#### Objective-concept binding

Named general candidates require exactly one
`EducationObjectiveConceptBinding`. The binding contains the user's objective
revision, one source-native public concept ID, concept scheme/version,
jurisdiction, the exact label/alias claim used, corpus revision, confirmation
timestamp, and one of these closed match bases:

- `exactPrimaryLabel`: after Unicode compatibility normalization, whitespace
  folding, and locale-aware case folding, the complete user-entered objective
  label equals one approved primary concept label; or
- `exactApprovedAlias`: the complete label equals an alias explicitly published
  or curated as part of the approved corpus; or
- `userSelectedFromSourceInspection`: the user chooses one source-native
  concept from the corpus's inspectable concept list.

Normalization never strips meaningful words, stems terms, expands acronyms,
uses embeddings, assigns similarity, translates, or combines concepts. An exact
string that resolves to several concepts is ambiguous: all source-native
identities and their authority/jurisdiction are shown in neutral ID order and
the user must select one. Nothing is preselected. Zero matches, declined
selection, unavailable source, incompatible version, or unknown jurisdiction
leaves the objective unbound. An unbound objective supports the three type-level
forms and exact user-named-offering inspection only; it produces no general
named candidates.

The user can inspect, change, or remove the binding. A change invalidates every
general candidate and explanation derived from the prior binding. Only one
binding is active for one comparison; the product never silently unions or
chooses among several concepts.

After binding, an offering qualifies on objective relationship only through one
of two closed, directional predicates:

1. `exactClassification`: the offering's approved classification claim targets
   the identical source-native concept ID in the identical scheme/version and
   a compatible jurisdiction; or
2. `publisherDeclaredLearningCoverage`: the offering or curriculum publisher
   has an approved claim whose subject is that exact offering, whose predicate
   declares that the offering teaches/covers the exact bound concept, and whose
   object is that concept in a compatible version and jurisdiction.

An approved crosswalk may bridge versions/schemes only when it explicitly
asserts exact equivalence, names both versions and jurisdictions, is current,
unconflicted, and is approved for this consumer. `Related`, broader, narrower,
approximate, inferred, community-similar, unlabeled CASE association, or
direction-reversed relationships do not qualify. Unknown or unsupported
predicate, missing direction, absent relationship, version mismatch,
jurisdiction mismatch, stale/conflicted/revoked relationship, or ambiguous
crosswalk produces no general candidate and the neutral explanation **No
source-qualified offerings are available for this learning focus**. The corpus
may publish facts, but it cannot add another qualifying predicate without a
Scope/Design revision.

For each requested route form, the composer evaluates all offering records in
one immutable corpus snapshot. Inclusion is conjunctive and boolean:

1. the exact corpus and release are approved for education recommendation;
2. the record declares one of the three in-scope route forms;
3. its provider and offering identities, current-offering claim, authority,
   jurisdiction, version, rights, freshness, conflict, and review state satisfy
   that corpus's approved use contract;
4. it has either an approved, source-preserving classification or learning-
   meaning relationship to the locally selected objective concept, or it is the
   exact offering the user asked to inspect; and
5. both input and derived-output privacy gates allow the candidate.

Failure of any item excludes the offering from product recommendation. The
composer does not derive a substitute identity, fuzzy equivalence, popularity,
quality, prestige, outcome, price, or relevance score. Capability, Proof,
education history, and training history never decide inclusion; they may only
produce bounded overlap explanations after inclusion.

The eligible set is sorted by stable source-native provider identity, then
stable source-native offering identity, then claim identity as a deterministic
tie-breaker. Display names and localization never affect order. With zero
eligible offerings, the form remains visible with the applicable source state.
With one, it is the only window item. With two, both appear. With more than two,
the first two in neutral order form the initial window and the header says, for
example, “Comparing 2 of 7 eligible offerings—not ranked.”

An exact user-named offering that passes the same gate is a user-selected
window choice, not a higher-ranked result. It occupies the first window
position and the earliest neutrally ordered remaining eligible offering
occupies the second. The header labels the first as **You asked to inspect
this**. The full eligible set retains its neutral order and count.

**See all eligible offerings** lists every remaining identity and its inclusion
basis in the same neutral order. The user can replace either window position
with any eligible offering. An explicit narrowing choice may use only a
currently selected input with a declared predicate such as delivery mode or
location. Confirmed matches may fill the window, but unknown or nonmatching
eligible offerings remain accessible in separate **Unknown for this filter**
and **Other eligible offerings** groups. The total pre-filter eligible count,
the active narrowing basis, and access to every nonsuppressed eligible offering
remain visible. No hidden pruning or score is permitted.

### 6. Inspect and correct an option

Each option opens in this semantic order:

1. provider and exact offering identity, route form, version/catalog identity,
   coverage boundary, and inclusion reason;
2. a qualitative “Why this may be relevant” explanation with every selected
   local input named and the statement that overlap does not establish mastery,
   credit, admission, completion, or fit;
3. commitment facts—dates, duration, delivery, location, cost, prerequisites,
   technology needs, and availability—each bound to its owning claim;
4. the six independent authority lanes; and
5. freshness, conflict, unknowns, limitations, attribution, and source
   inspection actions.

The six lanes never collapse to one badge. Each is **Available**, **Unknown**,
**Not applicable**, **Needs review**, **Conflicting**, **Stale**, **Revoked**, or
**Unavailable**, with source and consequence. Recognition names its exact
institution/program scope and monitoring or action state. Transfer names the
receiving authority or applicable agreement. Outcome facts name cohort,
geography, period, suppression, and method. A status in one lane never repairs
another.

**Correct how this was used** lets the user mark an input relationship or one
public claim's applicability to this review as incorrect. The correction is a
private, session-owned claim-use correction: it changes local composition,
retains lineage, and can be reversed, but never edits the public artifact or
claims authority over a provider, accreditor, or receiving institution. Public
source inspection remains available for the source's actual meaning. A
correction invalidates only results whose dependency set contains that binding.

### 7. Save, defer, dismiss, or hand off

- **Save for later** stores the exact option identity, explanation dependency
  binding, corpus revision, public claim references, and unknown summary inside
  the local session. Reopening always revalidates it; saved does not mean current.
- **Do this later** closes the presentation while retaining the draft session,
  review position, and active selections. It does not mark an option saved.
- **Not this option** records the exact offering, rationale, evidence fingerprint,
  corpus revision, selected-input fingerprint, and review context. Only that
  unchanged basis stays quiet. User-requested reconsideration or a material
  objective, offering, source, or selected-input change creates a new basis.
  This increment exposes no broader provider, institution, route-form, price,
  or inferred-preference exclusion.
- **Change route forms** returns to the three-form review without translating
  one form into another.
- **End exploration** closes the session with no Goal or destination mutation.
- **Continue with this destination** opens a handoff review showing the exact
  destination meaning, optional provider identity, evidence and unknowns,
  source state, and external decisions still required. Confirming only emits an
  `EducationDestinationHandoff` to `destination-adoption-and-pivot`. Back or
  cancel emits nothing. Adoption remains the sole owner of any saved direction
  or provisional Goal.

**Do this later** and **End exploration** have different retention consequences.
Deferring keeps the session active exactly as described for resume. Ending makes
it read-only and removes it from ordinary active exploration, but retains its
objective, selected-input/consent lineage, corrections, saved options, exact
dismissals, recommendation revisions, and History until the user deletes it.
The end confirmation states this consequence. Retained exact dismissals continue
to keep an unchanged basis quiet across a later exploration; deleting the ended
session removes that influence and warns that the option may appear again.

From the education exploration's **Past explorations** inspector, the user may
remove an individual saved option, move a deferred or ended exploration to
Trash, restore it, or permanently delete it. Trash makes the session and all of
its influences unavailable to ordinary comparison while retaining recoverable
state. Restore revalidates every source, consent, corpus, and policy binding
before any result appears current. Permanent deletion has a consequence review
and removes the objective copy, selected-input bindings, protected consents,
provider interest, option/window state, filters, corrections, saves,
dismissals, recommendation revisions, and private History detail for that
session. It does not edit the source Goal, capability, Proof, Life Context fact,
public pack, provider record, or an already separately adopted destination.

## States and recovery

The presentation renders a typed state; it never guesses from missing fields.

| State | Visible meaning | Available recovery |
| --- | --- | --- |
| `needsDirection` | No objective has been supplied. Nothing has been created. | Enter or select a direction; cancel. |
| `objectiveConsentRequired` | The objective cannot influence results until its exact education use is reviewed. | Review disclosure, continue generically, replace objective, or end. |
| `routeFormsReady` | Three distinct route forms are available for type-level review. | Select forms, edit direction, select inputs, or defer. |
| `routeFormUnavailable` | One named form lacks enough product evidence; the other forms do not replace it. | Inspect the reason or continue with the remaining visible forms. |
| `inputSelection` | Only explicitly checked inputs will be used. | Select, inspect, remove, or return to forms. |
| `inputClassificationBlocked` | A fact cannot be classified safely and is not in use. | Inspect it with its owner, omit it, or cancel. |
| `protectedConsentRequired` | One exact protected fact awaits purpose-specific consent. | Consent, decline, or inspect retention/revocation. |
| `providerIntentRequired` | No provider names are active. | Explore current providers for named forms or remain type-level. |
| `educationCorpusUnavailable` | No approved recommendation-ready education corpus is installed. | Compare route forms or inspect any separately approved public facts. |
| `educationCorpusReviewOnly` | Public facts may be inspected, but semantic completeness, rights, freshness, conflict, or recommendation readiness blocks named use. | Inspect the exact gate state or return to route forms. |
| `composing` | A fresh immutable public/private snapshot is being evaluated locally. Prior results are not current. | Cancel the computation or wait; navigation remains reversible. |
| `comparisonReady` | Zero to two nonscored named offerings per requested form are shown with eligible count and source state. | Inspect, replace from all eligible, explicitly narrow, correct, save, dismiss, or hand off. |
| `eligibleOverflow` | Additional eligible offerings exist and remain accessible in neutral order. | Select any offering into the two-position window or return unchanged. |
| `noEligibleOffering` | No source-qualified current option is available for this review. | Inspect non-private source limitations, remove narrowing, compare forms, or name an offering for local lookup. |
| `claimNeedsReview` | An affected lane is stale, conflicting, revoked, unavailable, or not applicable; it cannot be presented as current. | Inspect source, remove the affected option, retry a public refresh by finite artifact ID, or return to type-level review. |
| `offlineVerified` | A bundled or cached verified fact is being used with its actual current-use state. | Continue when allowed or inspect freshness. |
| `offlineReviewOnly` | Last-known-good public material is inspectable but cannot support a current named recommendation. | Continue type-level, inspect cached evidence, or retry later. |
| `recomputingAfterChange` | An input, consent, correction, source, or filter changed; dependent results are withheld. | Wait, undo the local change where allowed, or cancel. |
| `recoveredDraft` | The saved session was restored and all dependencies were revalidated. Changed items are called out before comparison resumes. | Review changes, remove invalid inputs, or end. |
| `persistenceFailure` | The latest control could not be saved; the last committed revision remains authoritative. | Retry, return to the last committed state, or close without claiming success. |
| `handoffReady` | Only a destination candidate will be passed to adoption; nothing else changes. | Continue to adoption, go back, or cancel. |
| `ended` | Exploration ended with no Goal or route mutation. Its retained choices and History are read-only until deleted. | Inspect past exploration, start a new one, move it to Trash, or permanently delete through Trash. |
| `trashed` | The exploration and its recommendation influence are unavailable to ordinary review but remain recoverable. | Restore and revalidate, or review permanent-deletion consequences. |
| `permanentlyDeleted` | Private exploration content cannot be restored; only content-free deletion lineage remains. | Start a new exploration. |

Privacy-suppressed candidates never generate a distinct visible state, row,
count, identifier, accessibility value, diagnostic value, or omission reason.
An empty post-gate set uses `noEligibleOffering` with the same neutral language
as every other empty eligible set.

On relaunch, recovery loads the last committed session revision, restores the
semantic step and stable focus identifier, then reloads current private source
revisions and a single public corpus snapshot. Any changed dependency is marked
before rendering current claims. Missing or revoked inputs are removed from
composition. A source refresh invalidates only options and lanes containing its
claim IDs. A stale asynchronous result whose session revision, corpus hash,
policy revision, or consent bindings no longer match is discarded and cannot
replace the projection.

Cancellation during composition stores no derived result. Duplicate commands
reuse the original result through their idempotency key. Retry never replays an
accepted external fetch or emits a second local semantic event; it re-evaluates
only the failed read or computation against the current revision.

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
- Experience authority: Task 5 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Component ownership

| Component | Responsibility | Explicit non-responsibility |
| --- | --- | --- |
| `Core/Domain/EducationRecommendation/` | Value types for route forms, authority lanes, exploration sessions, input/consent bindings, claim-use corrections, comparison projections, and handoff payloads. | Persistence, public fetching, UI, Goal mutation, or external authority decisions. |
| `Core/LocalRuntimeOS/Planning/EducationRecommendation/` | One actor-isolated session owner, deterministic eligibility/composition, explanation, command validation, invalidation, and handoff preparation. | Source Atlas delivery, hosted matching, Goal adoption, path generation, scheduling, or external writes. |
| `Core/LocalRuntimeOS/PrivacySecurity/` | Classify every selected and derived datum, enforce exact purpose consent, redact inspection, and fail closed at every prohibited destination. | Inferring protected facts or silently broadening consent. |
| Existing `SourceAtlas/` and `Boundary/` | Deliver, verify, cache, quarantine, refresh, and inspect one finite approved public education artifact and its claim metadata. | Receiving the objective, selected inputs, provider interest, local match, correction, dismissal, or recommendation result. |
| `Core/Persistence/` and `Core/LocalRuntimeOS/Storage/` | Store private session snapshots and semantic event/projection/receipt lineage with schema migration and local protection. | Storing public pack bytes redundantly or writing provider state. |
| `Surfaces/Goals/EducationExploration/` | Present the flow as a Goals-owned projection and emit typed intents. | Canonical writes, composition, privacy classification, or network calls. |
| Existing public source inspection | Present source-native claims, authority, rights, freshness, conflicts, and limitations. | Treating a user correction as a public-source edit or a current-use approval. |
| `destination-adoption-and-pivot` router | Receive a reviewed handoff after the user chooses to continue. | Being called before handoff confirmation or inheriting education recommendation authority. |

Implementation must update the owning canon with a new education-recommendation
system contract before source behavior claims completion. Source Atlas and
privacy canon retain their current authority; the Goals surface gains an entry
and presentation contract but not a new root. `project.yml` is the only project
membership source and must be regenerated with XcodeGen; generated Xcode state
must not be edited by hand.

### Current implementation fit and gaps

There is no live education recommendation owner, session repository, provider
comparison flow, or test that composes user-owned capabilities into an
education option portfolio. Existing code is supporting infrastructure, not an
implementation claim:

- `LifeContextModels.swift` can distinguish education/training history,
  sensitivity, source, freshness, contradiction, and a broad
  `runtimeUseAllowed` state. That broad state is not education-purpose consent.
  This feature reads eligible facts through their owner and creates its own
  session/fact/purpose/revision bindings; it does not add recommendation state
  to `LifeContextBundle` or reinterpret its flag.
- `SourceAtlasVerifiedPublicPackProvider` already separates current public
  reference from review-only fallback, exposes public-only ownership, and its
  tests require a nil private `goalIntent`. The education provider adapter must
  preserve that seam. Current generic requirements, starter items, risk classes,
  and path composition types are not the six-lane education contract and must
  not be relabeled to avoid a separately approved corpus expansion.
- `PublicOnlyFirewall`, `SourceAtlasPublicOnlyBoundaryGate`, and their abuse
  tests are the mandatory outer boundary. The new local composer sits under
  `Planning/`, not `SourceAtlas/`, so no private-bearing source query or pack
  request is introduced.
- `SwiftDataLifeContextRepository` demonstrates snapshot persistence and safe
  projection behavior, while runtime command/event/receipt/replay facilities
  demonstrate mutation lineage. Education gets a separate repository and one
  runtime mutation owner; it does not write education sessions into Life
  Context or directly from a SwiftUI projection.
- Existing offline/no-account, last-known-good, runtime replay, Life Context
  sensitivity, and repository tests are regression dependencies. They are not
  evidence for route-form UX, education authority semantics, named-provider
  eligibility, consent, rendered comparison, or accessibility.

### Core interfaces

The domain boundary is expressed by narrow `Sendable` protocols. Exact Swift
names may be refined during grooming, but ownership and payload direction may
not change.

```swift
protocol EducationPublicCorpusProviding: Sendable {
    func snapshot(for artifactID: PublicArtifactID) async
        -> EducationPublicCorpusSnapshot
}

protocol EducationExplorationRepository: Sendable {
    func session(id: EducationExplorationID) async throws
        -> EducationExplorationSession?
    func commit(_ transaction: EducationExplorationTransaction) async throws
        -> EducationExplorationCommitReceipt
}

protocol EducationRecommendationComposing: Sendable {
    func compose(_ input: EducationCompositionInput)
        -> EducationComparisonProjection
}

protocol EducationRecommendationPrivacyChecking: Sendable {
    func authorize(_ input: EducationPrivacyInput)
        -> EducationPrivacyDecision
}
```

`EducationPublicCorpusProviding` receives only a preapproved finite artifact ID.
It cannot receive a Goal/objective string, private ID, selected-input identity,
provider-interest term, local filter, recommendation feedback, or derived cache
key. The existing `SourceAtlasQuery.goalIntent` is not a permissible remote
selector or artifact/cache identity for this feature. Public delivery completes
before private composition; the complete safe public snapshot is passed inward
to local Planning.

### Public corpus contract and gate

`EducationPublicCorpusSnapshot` contains only public/reference data:

- corpus, manifest, release, schema, content hash, rights, attribution,
  jurisdiction, retrieval, cache, and coverage-limit identity;
- separately evaluated delivery, semantic-completeness, and recommendation-
  readiness states;
- provider and offering source-native identities and route-form claims;
- claim-level source, authority-for-predicate, version/effective period,
  freshness, conflict, supersession, risk, and review metadata;
- source-preserving classification/learning relationships; and
- the six authority-lane claim references and explicit absent/not-applicable
  states.

The readiness state is one of `absent`, `deliveryVerifiedOnly`,
`semanticallyIncomplete`, `inspectionOnly`, `recommendationReady`,
`staleBlocked`, or `quarantined`. Only `recommendationReady` allows a named
offering into composition, and only for the exact approved domain, release,
jurisdiction, route form, claims, and use. This Design neither assigns an
education corpus ID nor approves sources; the separately approved domain-corpus
expansion supplies that identity and contract. Until then, all named-provider
fixtures assert an unavailable gate.

### Private session model

`EducationExplorationSession` is private local graph data with:

- stable local ID, schema version, revision, created/updated timestamps, and
  lifecycle (`draft`, `deferred`, `ended`, `trashed`), with a terminal
  content-free permanent-deletion tombstone;
- objective binding containing source object ID/revision or user-entered text,
  classification decision, and education-purpose authorization;
- optional user-confirmed public objective-concept binding with source-native
  concept/alias claim IDs and corpus revision;
- selected route forms and provider-intent forms;
- selected input bindings with source owner/ID/revision, handling class,
  declared use, and active/revoked state;
- protected consent bindings with fact ID/revision, purpose, disclosure/policy
  revisions, granted/revoked timestamps, retention, and revocation consequence;
- provider-local-search text as memory-only presentation state while provider
  intent is active; raw lookup text is never written to the snapshot, event
  ledger, History, Receipt, or diagnostic;
- selected window positions, explicit narrowing predicates, and stable eligible-
  set dependency fingerprint;
- reversible claim-use corrections;
- saved option bindings and exact-basis dismissal fingerprints;
- the last committed semantic step, review position, and stable focus ID; and
- immutable recommendation revision references to corpus/policy/input hashes,
  public claim IDs, option IDs, and unknown categories.

Private source content is not copied when an owner ID/revision is sufficient.
If a source is deleted, redacted, archived from planning use, or consent is
revoked, the binding follows that owner's lifecycle and composition revalidates.
History retains content-minimized lineage without reconstructing deleted or
withdrawn content.

`EducationRouteFormDescriptor` is bundled product copy for exactly the three
approved forms. `EducationAuthorityLaneProjection` represents one of the six
lanes and carries state, owning authority, source claim IDs, region/version,
freshness, limits, and inspection route. `EducationOfferingRecord` remains
public-only. `EducationOptionProjection` is the private derived join and may
exist only inside local Planning/presentation/persistence boundaries.

`EducationDestinationHandoff` contains:

- the user's exact destination wording and route form;
- optional provider/offering public identities;
- the last reviewed corpus and claim references;
- selected-input category references and a plain-language rationale;
- authority-lane states, unknowns, freshness, and explicit claim ceilings; and
- a declaration that the payload is advisory and creates no Goal or route.

It contains no accepted transfer credit, admission, eligibility, completion,
schedule, application, or external-write state. The adoption owner must
revalidate it before offering its own mutation.

### Commands, events, projection, and replay

Lasting actions—start, change direction, select/remove input, grant/revoke
consent, change route forms, set/remove provider intent, choose a comparison
window, set/remove narrowing, correct claim use, save, dismiss/reconsider,
remove a saved option, defer, end, move to Trash, restore, permanently delete,
and prepare a confirmed handoff—route through one education
recommendation owner. Each command carries session ID, expected revision,
idempotency key, actor/source, policy revision, and injected clock. Accepted
commands append a typed semantic event, update the session projection, and
produce one truthful Receipt/History result atomically. Rejected stale or
invalid commands preserve the previous projection and expose the rejection.

Scroll position and stable focus ID are resumable presentation checkpoints,
not evidence and not independent History entries. They are committed with the
nearest semantic session update or a bounded draft checkpoint. A checkpoint
cannot change objective, consent, eligibility, dismissal, save, or handoff
meaning.

Replay folds events in stable causal order and reconstructs an equivalent
session before re-running derived composition against the bound public corpus
and current owner revisions. It does not refetch remotely, emit handoffs,
contact providers, or duplicate receipts. Recommendation revisions store
dependency hashes and references rather than trusting a rendered snapshot as
current truth. If old private content has been governed away, replay produces a
redacted/missing dependency and neutral recomputation.

### Persistence and migration

The first implementation adds an `education_exploration_session.v1` snapshot
record plus education semantic-event/projection support to the existing local
runtime persistence boundary. The snapshot is local protected data and uses the
same store isolation and atomic commit owner as other private graph mutations.
Verified public pack bytes remain in the Source Atlas cache and are referenced
by corpus/manifest/hash; they are not copied into the private record.

There is no legacy education recommendation state. Migration is therefore
additive and creates an empty repository. It must not infer sessions from Goals,
Life Context education history, capabilities, Source Atlas packs, the Research
pilot, or browsing history. Decoder defaults are allowed only for future
optional presentation checkpoints; an unknown semantic enum, missing privacy
binding, or incompatible schema quarantines the affected session. Recovery may
retry the local decode, leave the quarantined bytes untouched, or permanently
delete the affected exploration through the same governed Trash/deletion path;
there is no export or inferred reset in this initiative. Migration is
idempotent across interruption and replay and preserves rollback compatibility
until the release's governed rollback window closes.

### Retention, Trash, and permanent deletion

No exploration data expires or changes influence automatically. `draft` and
`deferred` retain all committed session state for resume. `ended` retains a
read-only review/history record and exact dismissal influence. Removing one
saved option deletes only that saved binding and its current projection; its
truthful save/remove events remain in the session's private History until the
session is permanently deleted. Revoking protected consent immediately removes
the fact from active bindings, discards every dependent projection, and retains
only the local consent/revocation lineage needed to explain the action until
session deletion. Raw provider lookup text is never retained.

There is no session-wide **Reset** action in this increment because an
unspecified reset would obscure which consents, dismissals, saves, or History
survive. The user can remove individual inputs, consent, provider intent,
filters, corrections, saves, and dismissals through their named controls, or
use Trash and permanent deletion for the whole exploration. **Start a new
exploration** creates a distinct session and does not silently reset the old one.

Trash is recoverable and stops every session input, correction, save, and
dismissal from influencing ordinary education composition. Restore returns the
prior lifecycle (`deferred` or `ended`) only after current source, corpus,
privacy, consent, and policy revalidation. A consent grant is not revived by
restore; a protected fact requires fresh consent before reuse.

Permanent deletion is available only from Trash after an exact consequence
review. Session event payloads and private snapshots are stored behind a
session-scoped content-encryption key. Deletion destroys that key, removes all
materialized private projections and inspection rows, and writes a content-free
tombstone containing only session ID, deletion transaction/receipt ID, schema
version, deletion timestamp, and replay terminal state. The tombstone contains
no objective/provider text or identity, public-option identity, private source
ID, consent fact/purpose, save/dismissal basis, result/count, correction, or
recommendation content. If a stable ID itself could disclose content, the
tombstone uses a random local session ID rather than a content-derived ID.

Replay encountering the tombstone skips and cannot decrypt all earlier session
payloads, never rebuilds a projection or dismissal influence, and produces the
same terminal deleted state. Duplicate deletion returns the original receipt.
Interrupted deletion either leaves the restorable Trashed state and key intact
or atomically commits key destruction plus the tombstone; it never reports
success in between. Public cache data and separately owned Goals, capabilities,
Proof, Life Context, adopted destinations, and their History are outside this
deletion scope and remain unchanged.

### Concurrency and invalidation

An actor-isolated `EducationExplorationService` is the sole session mutation
owner. It reads one immutable tuple of session revision, selected source
revisions, consent/policy revision, and public corpus hash. Composition is a
pure deterministic function that may run off-main and is cancellable. Before a
result publishes, the service compares the entire dependency tuple; a mismatch
discards the result and schedules one recomputation from current state.

Public refresh, input edit/deletion, consent revocation, correction, and user
navigation may race safely. None mutates an in-flight snapshot. Compare-and-swap
rejects stale commands. Duplicate idempotency keys return the original commit
result. Rapid filters or pair replacements coalesce only uncommitted computation,
not semantic events. UI projections arrive on the main actor and views emit
intents only. Representative stress tests must cover refresh-during-compose,
revoke-during-compose, delete-source-during-resume, duplicate save/dismiss,
cancel/retry, stale reads, and replay under concurrent public-cache access.

## Privacy and accessibility

### Local-first and privacy firewall

Objectives, source bindings, selected capabilities/Proof/history, protected
consent, provider intent and local search, eligibility results, explanations,
corrections, filters, dismissals, saves, recommendation history, and handoffs
are private graph data. They work without an account and never enter Account,
R2, Source Atlas requests/artifacts/cache keys/feedback, hosted AI, telemetry,
analytics, support upload, external profiles, logs, widgets, Spotlight, pasteboard,
or notification payloads.

Every datum and derivation carries handling class, owner, purpose, allowed
destinations, redaction, retention, deletion, consent, and inspection policy.
Unknown classification denies use. Combining a public offering with a private
objective produces a private option. Redacted developer traces may contain only
session-independent policy/correlation identifiers, corpus public IDs, decision
categories, and safe payload-shape hashes; they contain no objective, private
ID, provider-interest term, match, option identity joined to a user, count after
privacy filtering, rationale, or behavior value.

Source Atlas network activity is optional public freshness. It is compiled only
from a finite allowlisted artifact identity, passes the existing public-only
firewall, and cannot be triggered or shaped by a private objective or provider
search. Offline type comparison always works. Verified bundled or cached public
facts may support the exact use their state allows. Last-known-good or stale
material remains inspection-only when its contract blocks current recommendation.
Network failure never blocks ending, correcting, removing input, revoking
consent, reading saved local state, or returning to route forms.

Protected facts are never inferred. Exact consent is default-off, session- and
purpose-bound, independently revocable, and rechecked at composition and render
time. Quiet omission occurs before the eligible count. No proxy, negative
inference, gap marker, special empty copy, accessibility text, or diagnostic can
reveal why an option was omitted.

### Semantic and assistive-technology contract

The visual comparison is also an ordered semantic list; no table, horizontal
swipe, color, icon, animation, or relative card position is required to compare
it. Reading order is:

1. page title and user-owned objective;
2. advisory/no-commitment statement;
3. route form or provider identity and state;
4. inclusion and coverage meaning;
5. selected-input use and overlap limit;
6. offering facts;
7. six authority lanes in fixed order;
8. freshness, conflicts, unknowns, and attribution;
9. eligible-count/window meaning; and
10. actions with their exact consequence.

Each route form, provider, option, source, input, consent, lane, filter, dismissal,
save, and handoff control has a stable semantic focus ID. After adding/removing
an input, focus returns to that input's status. After consent, it returns to the
fact's use state. After window replacement, it returns to the inserted option.
After source refresh or correction, it returns to the changed lane. After
recovery, it returns to the last valid focus ID, then the owning option, then
the page heading. Loading, stale, conflict, unavailable, recomputation,
persistence failure, and completion states announce status and next action.

Every action has a visible labeled button and custom accessibility action where
appropriate. Voice Control names are unique in the current view. Switch Control,
Full Keyboard Access, and hardware keyboard traversal follow semantic order.
No drag, swipe, long press, hover, or gesture is required to replace a window
item, open all eligible offerings, inspect a source, consent, correct, dismiss,
or hand off.

Dynamic Type through supported accessibility sizes reflows comparison sections
vertically without truncating provider identity, unknowns, or actions. Bold
Text and Button Shapes preserve hierarchy. Increase Contrast strengthens
boundaries; Differentiate Without Color uses text and symbols; Reduce
Transparency uses opaque semantic surfaces; Reduce Motion uses focus-preserving
crossfades. RTL changes layout direction but not route/authority semantic order.
Missing public accessibility-support information is explicitly **Unknown** and
never rendered as “not supported.”

## Requirement traceability

| Scope requirement | Design decisions |
| --- | --- |
| REQ-001 | Flow 1 requires explicit start and one objective, labels output advisory, and creates only a draft session. |
| REQ-002 | Flow 2 always preserves the exact three route forms, fixed semantic order, versioned content/claim-ceiling matrix, and visible unavailable states without substitution or invented provider facts. |
| REQ-003 | Flow 4 introduces a separate provider-intent command, names its limited consequence, and forbids provider names or added authority before it. |
| REQ-004 | Flow 5 defines a user-confirmed exact objective binding, two closed directional relationship predicates, neutral no-match outcomes, zero-to-two windows, exact user-named offering handling, stable neutral ordering, visible eligible totals/bases, all-eligible access, explicit narrowing, and privacy filtering before counts. |
| REQ-005 | Flow 6 and `EducationAuthorityLaneProjection` keep six independently inspectable authority lanes and explicit absent/not-applicable states. |
| REQ-006 | The public corpus contract and option order bind offering facts to provider/authority, exact identity/version/region/retrieval/freshness/conflict metadata. |
| REQ-007 | Recognition is its own lane with exact scope, status, monitoring/action state, dates, limits, and no admission/transfer/quality/fit implication. |
| REQ-008 | Private input composition restricts capability/Proof/history to overlap or formal-evaluation possibility; only receiving-authority claims can show transfer/waiver/credit. |
| REQ-009 | Flow 3 defaults all additional facts off, uses source-revision bindings, exposes declared use, and supports remove/recompute without generic capability permission. |
| REQ-010 | Exact session/fact/purpose consent, input and output gates, unknown-class denial, and pre-count quiet omission prevent inference, proxying, or revealing explanations. |
| REQ-011 | Option inspection is qualitative, source-bound, correctable, dependency-aware, and has no score/rank/winner field in domain or presentation models. |
| REQ-012 | Flow 7 defines inspect, save/remove-save, defer, exact-basis dismissal/reconsideration, route adjustment, provider-intent removal, end, retained influence, Trash/restore, and governed deletion; broader exclusions are not implemented. |
| REQ-013 | Typed claim/corpus states, dependency invalidation, offline review-only behavior, and route-form fallback prevent stale/conflicting/unavailable facts from appearing current. |
| REQ-014 | `EducationDestinationHandoff` and Flow 7 pass only reviewed candidate meaning/evidence/unknowns to adoption and expose no Goal/Path/Step/Proof/Time/provider mutation API. |
| REQ-015 | The component table and six-lane model preserve capability, public delivery, provider, recognition, transfer, gate, outcome, import, adoption, path, and schedule owners. |
| REQ-016 | Local session ownership, finite public artifact requests, egress denial, offline behavior, private derived classification, local protection, explicit retention, and content-destroying deletion preserve the local/public firewall. |
| REQ-017 | Typed recovery states, revision-bound persistence, owner revalidation, cancellation, idempotency, focus restoration, stale-result discard, Trash/restore, and deletion-terminal replay preserve honest interruption semantics. |
| REQ-018 | The semantic order, stable focus IDs, status announcements, non-gesture controls, input equivalence, Dynamic Type, contrast/effects, RTL, and unknown accessibility state define full accessible equivalence. |
| REQ-019 | The public corpus gate explicitly rejects O*NET, Research links, ad hoc fetches, and pilot providers until a separately approved recommendation-ready education corpus exists. |

## Verification design

Verification binds every fixture to the exact app commit, schema/policy revision,
public corpus/manifest/hash, source revisions, injected clock, locale, device/OS,
and expected claim ceiling. A structural Source Atlas pass never counts as
recommendation, runtime, rendered UI, accessibility, or release proof.

| Lane | Required evidence | Requirements covered |
| --- | --- | --- |
| Domain unit | Assert the exact `education_route_forms.v1` descriptor text, field matrix, claim ceilings, provenance links, load-failure state, and three distinct identities; six lane states do not substitute; handoff omits forbidden mutation/eligibility fields; correction invalidates only bound dependencies. | REQ-001, REQ-002, REQ-005–REQ-008, REQ-011, REQ-014, REQ-015 |
| Neutral eligibility/property | Permute corpus input order and localization and prove identical eligible identities/order; exact-label/alias objective binding requires user confirmation while ambiguity/fuzzy similarity yields no general candidates; zero/one/two/more-than-two fixtures prove window bound, exact user-named first slot, neutral second slot, full overflow access, visible count/basis, filter partitions, and absence of every score/rank field. | REQ-004, REQ-011 |
| Domain-corpus gate | With only O*NET 30.3, use UMGC/Google/CS50x literal strings solely as forbidden-identity sentinels and assert none can enter a product projection. Exercise absent, delivered-only, semantically incomplete, inspection-only, stale-blocked, quarantined, and separately approved recommendation-ready synthetic states. Research URLs and ad hoc fetches always fail. | REQ-003, REQ-004, REQ-006, REQ-013, REQ-019 |
| Authority adversarial | Synthetic unnamed institution, certificate, and open-course facts keep accreditation, delivery scope, monitoring state, program limits, and free-versus-verified artifacts separate; overlap does not award credit; contradictory accreditor/receiving-provider claims remain visible and block simple conclusions. | REQ-005–REQ-008, REQ-011, REQ-013, REQ-015 |
| Privacy unit/abuse | Every datum/derived output has a handling rule; no input beyond objective is active initially; protected/unknown inputs fail without exact fresh consent; consent is fact/purpose/revision bound; output suppression occurs before count; proxy, accessibility, log, cache-key, diagnostic, feedback, Account, R2, hosted-AI, telemetry, widget, Spotlight, pasteboard, and notification leaks fail. | REQ-009, REQ-010, REQ-016 |
| Source Atlas boundary | Request contains only a finite approved public artifact identity. Goal/objective, private ID, provider-interest text, selected input, filter, dismissal, correction, result, and derived fingerprint injection each fail closed through the existing boundary audits. | REQ-006, REQ-015, REQ-016, REQ-019 |
| Command/persistence/replay | Start, select/remove, consent/revoke, provider-intent add/remove, window replace, narrow, correct, save/remove-save, dismiss/reconsider, defer, end, Trash/restore/delete, and handoff each commit once; rejection rolls back; restart/replay reconstructs equivalent state and one receipt; cancellation creates no derived/canonical mutation. Defer and end retain their exact declared fields and dismissal behavior. | REQ-001, REQ-003, REQ-009, REQ-012, REQ-014, REQ-017 |
| Migration/corruption/deletion | Empty additive migration, interrupted/repeated migration, rollback, unknown schema/enum, corrupt snapshot, missing/redacted private source, and incompatible consent bindings fail safely without inferred sessions or pilot data. Trash removes influence and restores only after revalidation; permanent deletion destroys the session key/content, leaves only the specified tombstone, survives interruption atomically, and replay cannot reconstruct content. | REQ-009, REQ-010, REQ-012, REQ-016, REQ-017, REQ-019 |
| Concurrency/stress | Refresh/revoke/delete/correct during composition, rapid filters, duplicate commands, cancel/retry, stale projection read, and replay concurrent with public-cache access discard obsolete results and preserve one semantic transition. Run applicable thread and address sanitizers. | REQ-009–REQ-013, REQ-016, REQ-017 |
| UI integration | Goals entry, direction review, three-form order, input tray, consent disclosure, corpus-unavailable fallback, zero/two/overflow provider windows, six-lane detail, correction, save/defer/dismiss, provider-intent removal, recovery, and handoff consequence render from typed projections. | REQ-001–REQ-019 |
| Accessibility direct | On supported devices/OS, directly verify VoiceOver order/actions/rotors/announcements/focus, Voice Control, Switch Control, Full Keyboard Access and hardware keyboard, Dynamic Type, Bold Text, Button Shapes, contrast, Reduce Motion/Transparency, Differentiate Without Color, RTL, tap targets, interruption, every failure/recovery state, and unknown accessibility-support copy. Scripts explicitly cover Past explorations, saved-option removal, Trash, restore revalidation, permanent-deletion consequence review/result, and focus return after each. | REQ-002–REQ-005, REQ-009–REQ-014, REQ-017, REQ-018 |
| Offline/no-account | Type comparison and all private controls work without account/network; verified cached public facts show exact use state; last-known-good is review-only when blocked; no public cache yields named-unavailable while route forms and local recovery remain usable. | REQ-002, REQ-013, REQ-016, REQ-017, REQ-019 |
| Performance/resource | Measure cold/warm session load, immutable corpus decode, eligibility composition, >2 overflow projection, input invalidation, protected gate, accessibility-size rendering, memory, storage, energy, cancellation, and background/foreground recovery at representative approved-corpus scale. Establish budgets from measured baseline during grooming; no number is asserted by this Design. | REQ-004, REQ-011, REQ-017, REQ-018 |
| Canon/static/build | Update and compile owning canon; regenerate the Xcode project from `project.yml`; pass `git diff --check`, SwiftLint, static analysis, secrets/privacy scans, canon check, Source Atlas boundary audits, focused unit/integration/UI suites, and the relevant build/test lane without weakening existing tests. | REQ-015, REQ-016, REQ-018, REQ-019 |

The minimum adversarial fixture set includes: no education corpus; O*NET-only;
one synthetically approved education corpus; a source-delivered but semantic-
incomplete corpus; more than two neutral eligible offerings; locale-changed
display names; exact and ambiguous objective concepts; a user-named current,
absent, and stale offering; stale catalog; changed
accreditation action; missing articulation; suppressed outcome; capability
overlap without credit; ambiguous free versus verified certificate; protected
input absent/consented/revoked; derived-output uncertainty; private query
injection; offline bundled/last-known-good/none; interrupted save; stale command;
duplicate handoff; source deletion; and full accessibility content stress.

## Open decisions

There are no unresolved product decisions in this Design. The following are
technical grooming decisions and may not change product behavior:

- exact Swift file splits, event names, and persistence record names within the
  owners above;
- the public pack schema extension used by a future separately approved
  education-domain corpus;
- measured corpus/candidate scale and resulting latency, memory, energy, and
  storage regression budgets; and
- the smallest implementation order that first ships route-form comparison and
  the locked corpus-unavailable state before enabling any future approved
  education corpus.

Approval of this Design does not approve that corpus expansion. If implementation
would require another route form, a ranking or relevance score, a hidden
candidate limit, a remote private query, a broader exclusion, a different
protected-data consequence, provider/application action, or any admission,
transfer, quality, eligibility, or outcome claim, work must return to Scope.
