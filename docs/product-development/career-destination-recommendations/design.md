+++
initiative = "career-destination-recommendations"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Career exploration is a focused native route under **You → Life Capital**, not
a new app root and not a Goal-creation shortcut. The route opens with two equal
choices:

1. **Explore from my progress** uses only capabilities and other inputs the
   user selects for this session to assemble a small, unranked adjacent-career
   portfolio.
2. **Explore a career I name** preserves a user-entered aspiration even when no
   capability relationship or supported public identity exists.

Both lanes produce local, non-durable exploration projections. A projection
explains why an option appeared, identifies each public claim by type and
authority, distinguishes potentially reusable progress from qualification,
shows gaps and unknowns, and exposes source inspection. It never creates a
Goal, path, Step, schedule, Proof, application, profile update, or external
write.

The first implementation is intentionally corpus-limited. Only the separately
approved public-reference foundation's O*NET 30.3 United States Software
Developers `15-1252.00` slice may become eligible, and only after the
career-specific recommendation-readiness checks in this Design pass. Public
delivery or semantic validity alone does not open the gate. New York registered
nursing and NASA astronaut remain valid direct
aspirations, but appear as **Source check needed** because the separately
approved `career-domain-authority-corpus-expansion` does not yet exist. A small
result is honest: one eligible adjacent occupation produces one option, and no
eligible occupation produces a bounded empty state. The system never pads the
portfolio, extrapolates a domain corpus, or promotes generic occupational data
into regulator, employer, or selection authority.

The design introduces a career-specific local Planning boundary rather than
reusing either `RecommendationEngine` or
`SourceAtlasCapabilityPathComposer`. The former selects one current action and
the latter uses scalar path scoring; neither satisfies the Scope's neutral
candidate-inclusion and non-ranking law. Source Atlas continues to retrieve and
verify fixed public artifact identifiers only. Private inputs enter only after
the verified public snapshot has crossed into local Planning.

## User flows

### 1. Enter career exploration

1. From the Life Capital drilldown, the user activates **Explore careers**.
2. The intro states that exploration is local, optional, limited to the
   supported United States reference set, and does not decide qualification or
   change Goals.
3. Two independently focusable actions appear in semantic order:
   **Explore from my progress** and **Explore a career I name**. Neither is
   visually or semantically marked preferred.
4. Leaving at this point creates no session, preference, Receipt, or History
   entry.

### 2. Explore from selected progress

1. The input review begins empty. It offers only the categories approved by
   Scope: confirmed capabilities and approved evidence links; user-stated
   career interests or occupation families; eligible work/context, schedule,
   location-radius, pay-need, education-tolerance, or relocation preferences;
   explicit must-have or must-avoid constraints in those categories; and
   selected education, credential, experience, or eligibility facts for later
   gate explanation.
2. Each item shows its category, current handling classification, whether it is
   merely a preference or a hard constraint, and the consequence of selection.
   No screen provides blanket access to History or an implicit "use all."
3. A preference can influence explanation or portfolio composition but is not
   an exclusion. Turning it into a hard constraint is a separate labeled action
   that previews the consequence. A hard constraint excludes only when a
   current public claim can evaluate it; otherwise the candidate retains an
   **Unknown for this constraint** state.
4. Education, credential, experience, and eligibility facts remain downstream
   explanation inputs. They cannot add, remove, or order candidates.
5. Selecting an explicitly protected fact opens a fresh disclosure that names
   the exact fact, career-exploration purpose, affected decision, current
   session, retention boundary, and revocation consequence. Cancel leaves the
   fact unused. Unknown classification is not consentable and fails quiet.
6. **Review selected inputs** lists every selected item in visible order and
   says exactly how each may be used. The user can remove or reorder an input
   before choosing **Explore these inputs**.
7. A cancellable local computation reads a fixed verified public snapshot,
   enumerates neutral candidates, applies only current evaluable hard
   constraints, and then applies the exact coverage rotation from REQ-004.
8. The result heading says **Career possibilities**, states the supported
   corpus limit, and reports the actual count without implying completeness.
   One to five eligible candidates are all visible. More than five yields
   exactly five visible candidates plus **See other eligible careers**.

### 3. Inspect and change an adjacent portfolio

Each visible card uses the same structure and no ordinal, percentage, star,
match strength, or winner styling:

- occupation title, stable public identifier, and United States jurisdiction;
- **Why it appeared**, listing the exact selected input relationships;
- **Progress that may carry forward**, explicitly not qualification;
- **Typical work and context**;
- **Common preparation**;
- **Requirements and source checks**, separated by authority and current use
  state;
- **What is not known**;
- **Why it may be worth exploring**, using non-predictive language; and
- **Sources and limits**, which opens Trust source inspection.

The visible collection preserves the deterministic selection order internally,
but the presentation does not number options or use position to imply quality.
At larger text sizes cards stack without losing their semantic grouping.

**See other eligible careers** groups omitted options first by the user-visible
input basis and then by public occupation family. Every item says which
relationship made it eligible and which coverage step kept it out of the five
visible slots. **Show this instead** previews the exact visible candidate it
will replace and changes only the session projection. It neither creates a
rank nor affects the aspiration lane.

**Refine inputs** returns to the input review with current session selections.
Removing an input increments the session revision and recomputes only
candidate eligibility and rationale that depended on it. The immutable public
snapshot is not edited. The result announces the changed count and restores
focus to the affected heading or candidate.

**That reason is not right** opens a correction sheet scoped to one input,
relationship, or explanation claim. Correcting canonical capability or
evidence meaning hands off to its owner; until that command settles, the
exploration uses the last accepted value or removes the disputed relationship.
The career route does not directly mutate capability, Proof, education,
credential, or experience objects.

**Not for this exploration** dismisses the exact candidate and rationale only
for the current session. If the user invokes **Remember this for future career
explorations**, a separate review names the occupation identity, stored scope,
future omission consequence, inspection location, Reset and Delete actions,
and Receipt. Cancel retains only the session dismissal.

### 4. Explore a career the user names

1. The user enters an aspiration in a local text field. The text is never a
   Source Atlas request, remote cache key, diagnostic value, or telemetry fact.
2. A local index over already verified public identities offers accessible
   disambiguation when multiple supported identities match. Selecting a public
   identity does not assert qualification. If no supported identity matches,
   the user's wording remains the displayed aspiration for this session.
3. The user may optionally select the same bounded explanation inputs used by
   the adjacency lane, including the protected-fact disclosure when applicable.
   Capability overlap may enrich **What may carry forward**, but zero or unknown
   overlap never removes or demotes the aspiration.
4. The aspiration detail uses the same claim-type sections as an adjacent
   candidate. Unsupported, incomplete, or non-recommendation-ready authority is
   displayed as **Source check needed**. Missing data is not reconstructed.
5. Before the career-domain corpus expansion exists, registered nurse in New
   York and NASA astronaut can be explored only through this lane. They cannot
   enter adjacency. Their details state respectively that current NYSED gate
   authority or a named current NASA selection cycle is not available in the
   approved corpus; generic O*NET context cannot fill that gap.
6. Returning to the lane chooser preserves the independent in-memory result of
   the other lane for the current session. A change in either lane never prunes
   or orders the other.

### 5. Remember, inspect, reset, or delete a career preference

Session input selections and dismissals expire when the user closes the
exploration route or the process ends. They produce no durable mutation.

The user may separately choose one of these narrowly named durable scopes:

- **Use this input in future career explorations**, bound to the exact accepted
  private-object revision and input category; or
- **Do not show this exact career by default in future career explorations**,
  bound to one stable public occupation identity.

Each action follows the local mutation sequence. Review shows what will be
stored, career-only use, what is not affected, and how to inspect, Reset, or
Delete it. Confirmation commits one typed career-preference event, updates the
career-preference projection, and issues a Receipt/History entry. Reset clears
selected remembered career preferences after consequence review; Delete
removes one preference. Neither action changes the referenced capability,
occupation source, Goal, or any adjacent object. If a referenced private input
is corrected, archived, Trashed, deleted, reclassified, or has future-use
permission removed, the preference becomes unavailable or is removed according
to the owning input's lifecycle before another session can use it.

At the start of a later adjacency session, valid remembered inputs appear as a
clearly labeled preselection in input review. The user sees their career-only
scope and can remove any of them before computation; remembered state never
bypasses the deliberate lane choice or input review. A remembered exact-career
dismissal is applied only after neutral eligibility and visible-slot selection.
The candidate remains discoverable under **Hidden by your saved choice**, with
the saved reason and a **Show again** action; it is not deleted from the corpus,
used as negative evidence, or allowed to change the coverage of the other lane.

### 6. Inspect sources and limitations

Activating a source or gate opens the existing Trust-owned source-inspection
route with a career claim adapter. The primary detail says what the claim is,
which authority owns that claim type, jurisdiction, release/effective period,
retrieval and freshness state, attribution, conflict/supersession state, and
use limit. Returning restores focus to the exact source row.

The route never sends the current aspiration, selected inputs, candidate set,
dismissal, or rationale back to Source Atlas. Refresh, when available, requests
only a finite allowlisted public artifact identifier. An updated verified pack
marks the open session **Public information changed** and offers **Recompute**;
it never silently replaces the snapshot behind an already displayed result.

### 7. End the session or hand off

**Done** discards the in-memory session, including unremembered inputs,
aspiration text, substitutions, and dismissals. The route returns to Life
Capital and announces that no Goal or plan changed.

The detail may expose **Consider this as a Goal** only as a disabled or
navigation-only handoff supplied by the separately approved
`destination-adoption-and-pivot` capability. Until that dependency exists,
the action is absent. This initiative never implements adoption itself.

## States and recovery

### Session and computation states

`CareerExplorationSessionState` is an explicit sum type:

- `choosingLane`;
- `selectingInputs`;
- `reviewingProtectedConsent`;
- `readyToExplore`;
- `computing(revision)` with Cancel;
- `showingPortfolio(snapshot)`;
- `showingAspiration(snapshot)`;
- `recomputing(previousSnapshot, revision)`;
- `sourceChanged(previousSnapshot, replacementFingerprint)`;
- `noEligibleAdjacentCandidates(reasonSet)`;
- `privacyQuiet(explanation)`;
- `failed(previousSnapshot?, failureKind)`; and
- `ending` / `ended`.

The state machine accepts results only when session ID, input revision, policy
revision, corpus-gate revision, and public-snapshot fingerprint still match the
active request. Older results are discarded without display.

### Visible source and claim states

Each claim independently carries `current`, `older context`, `mixed cycle`,
`source check needed`, `conflicted`, `superseded`, `revoked`, `unavailable`, or
`unsupported for this use`. A blocked gate claim does not erase unrelated
current descriptive claims or user-owned progress. A destination-level state
summarizes material blocked claims without flattening their individual
reasons.

Regulated and competitive aspirations require a visible source-check row for
every material jurisdictional or cycle-bound gate. Minimum eligibility is
always labeled separately from permission to practice, an open application
cycle, or probability of selection. No named current cycle means the product
cannot say applications are open or that the complete current gate set is
known.

### Empty and bounded-corpus states

- **No inputs selected:** explains that Ambitions will not inspect all History
  and offers input selection or direct aspiration.
- **No supported adjacent careers:** states that the current corpus is limited,
  does not characterize the user's potential, and offers direct aspiration or
  input refinement.
- **One or two candidates:** shows exactly those candidates without empty
  placeholders or pressure to add more.
- **No safe public snapshot:** preserves input review in memory, states that
  public reference is unavailable, and offers Retry, direct aspiration with
  source-check limits, or Done.
- **All results omitted by privacy:** gives a content-free explanation that
  some results could not be shown under the selected privacy scope. It does not
  name, count by protected category, suggest a proxy, or imply a negative
  judgment.

### Failure and recovery rules

- Public pack missing, corrupt, invalid, revoked, or unavailable: retain the
  last verified snapshot only when its per-claim policy permits the displayed
  use; otherwise block affected claims. Offer source inspection and Retry.
- Candidate computation cancelled: retain selected inputs in this process and
  return to `readyToExplore`; show no partial candidate list.
- Input changes during computation: cancel the old generation and recompute
  from the new revision. No stale result may flash as current.
- Source refresh during inspection: keep the old snapshot visible, announce
  that information changed, and require explicit Recompute.
- Protected-data unavailable while the device is locked: redact candidate and
  rationale content, preserve route identity only as allowed, and restore after
  unlock/revalidation. Notifications and app-switcher snapshots reveal no
  aspiration, capability, preference, or result.
- Durable preference commit fails: retain the session-only selection or
  dismissal, say that it was not remembered, and offer Retry or Keep for this
  session. Never show a false Receipt.
- Referenced input becomes stale or unavailable: mark its relationship
  unavailable, remove its influence on the next recompute, and explain the
  precise source-side state without mutating the source object.
- Process termination: ends the non-durable session. On relaunch, remembered
  career preferences remain available after current revision and privacy
  validation; unremembered inputs and aspiration text do not reappear.

The product never replaces a failure with a fabricated occupation, a generic
"no matches" statement, or language that prior progress was wasted. Retry is
idempotent for the same session revision. Cancel and Done are always reachable.

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

The implementation adds a bounded career domain while preserving existing
owners:

- `Surfaces/You/CareerExploration/` owns the native route, navigation state,
  presentation models, semantic focus targets, and user intent dispatch. It
  cannot read stores or mutate canonical objects directly.
- `Core/Domain/` owns value-only career types: occupation identity, lane,
  selected-input descriptor, claim class, gate state, candidate rationale,
  portfolio projection, aspiration projection, session revision, and durable
  career-preference identity.
- `Core/LocalRuntimeOS/Planning/CareerExploration/` owns the local session
  coordinator, private-input snapshot, neutral candidate enumerator, exact
  coverage selector, hard-constraint evaluator, explanation composer, and
  output privacy gate. All computation is side-effect-free until a separately
  named preference command is requested.
- `Core/LocalRuntimeOS/Inspection/` adapts candidate rationale and career claim
  bindings into Trust inspection without copying private content into the
  public source record.
- `Core/LocalRuntimeOS/PrivacySecurity/` owns input/output classification,
  protected-fact disclosure decisions, consent validation, locked-device
  redaction, and the no-egress policy decision.
- `Core/LocalRuntimeOS/Commands/`, `EventJournal/`, `State/`, `Projections/`,
  `Receipts/`, and `Replay/` own only durable remembered career preferences.
- `Core/LocalRuntimeOS/SourceAtlas/` continues to own verified public artifact
  delivery and cache/freshness facts. It accepts only the fixed public artifact
  selectors approved by the public-reference and domain-corpus gates.
- `Trust/SourceInspection*` remains the presentation owner for public source
  inspection. A career adapter adds claim-specific authority, jurisdiction,
  limits, and gate use state to the existing inspection model.
- `Quality/` owns scenario fixtures, privacy abuse cases, deterministic
  portfolio evidence, accessibility proof, and performance calibration.

`RecommendationEngine` remains responsible for a current `NowState` action and
is not called by career exploration. `SourceAtlasCapabilityPathComposer` and
its scalar `scorePath` are not candidate-generation seams. `AmbitionsOSPathPortfolio`
is not reused because career options are not active or alternate Goal Paths and
carry no path mutation or proof-transfer authority.

### Interface contracts

The new domain uses four narrow, injectable interfaces:

```swift
protocol CareerPublicCorpusProviding: Sendable {
    func snapshot(for selector: CareerPublicCorpusSelector) async
        -> CareerPublicCorpusSnapshot
}

protocol CareerPrivateInputProviding: Sendable {
    func snapshot(for selections: [CareerInputSelection]) async throws
        -> CareerPrivateInputSnapshot
}

protocol CareerExplorationPlanning: Sendable {
    func explore(_ request: CareerExplorationRequest) async
        -> CareerExplorationResolution
}

protocol CareerPreferenceCommanding: Sendable {
    func submit(_ command: CareerPreferenceCommand) async
        -> CareerPreferenceSettlement
}
```

`CareerPublicCorpusSelector` contains only an allowlisted domain ID, pack ID,
release/channel, public locale, and United States jurisdiction. It contains no
free-form aspiration, private object ID, capability label, input category,
dismissal, or derived cache key. The provider adapts
`SourceAtlasVerifiedPublicPackProviderOutput` into an immutable snapshot and
retains manifest version, content hash, provenance, rights, freshness, and
recommendation-readiness facts.

`CareerPrivateInputSnapshot` is created later and entirely locally. Each entry
binds a session-local opaque selection ID to the canonical private-object ID and
revision, permitted career use, category, explicit order, evidence-link IDs,
handling class, consent scope where applicable, and availability. Public claim
IDs may be referenced locally, but no joined record crosses back into Source
Atlas.

`CareerExplorationRequest` binds session ID, lane, ordered selected-input
snapshot, optional local aspiration, public-snapshot fingerprint, privacy and
consent policy revision, corpus-gate revision, injected clock, and cancellation
token. It contains no mutable store handle. A resolution is `success`,
`noEligibleCandidates`, `privacyQuiet`, `sourceUnavailable`, `cancelled`, or
`failed`; partial arrays are never treated as success.

### Candidate and claim model

`CareerDestinationCandidate` contains:

- stable public occupation identity, canonical title, family, and jurisdiction;
- lane origin (`adjacency` or `aspiration`) without a relative rank;
- coverage basis input ID and all additional relationship bindings;
- potentially reusable capability references;
- independent claim groups for occupational description, work/context,
  typical preparation, market context, hard/legal gate, employer requirement,
  and competitive selection;
- material unknowns and corpus-limit copy;
- source bindings and output handling class; and
- a stable explanation fingerprint derived from public claim IDs, allowed
  session-local input references, and policy revisions.

Each `CareerClaimBinding` retains subject, predicate/claim type, source-native
claim ID, authority-for-purpose, jurisdiction, release/effective period,
retrieval date, freshness, risk/review state, rights/attribution, conflict or
supersession state, and use ceiling. Typical preparation can never satisfy a
hard gate. A descriptive source cannot override a regulator, employer,
licensing body, or selecting organization.

### Neutral inclusion and coverage algorithm

The planner performs these deterministic stages in order:

1. **Corpus gate:** admit only stable United States occupation identities whose
   packs are explicitly recommendation-ready under the active approved domain
   corpus revision. A delivered or semantically valid pack is insufficient.
2. **Relationship inclusion:** require at least one inspectable current or
   explicitly qualified public relationship to an allowed session input.
   There is no similarity score, embedding distance, weight, pay/outlook bonus,
   qualification value, or inferred personality signal.
3. **Hard-constraint evaluation:** exclude only for an explicitly hard user
   constraint and a current public claim that conclusively evaluates it.
   Unknown, stale, conflicted, or unsupported evidence yields an unknown, not
   an exclusion. Education, credential, experience, and eligibility facts do
   not participate in this stage.
4. **Deduplication:** collapse identical stable public occupation IDs while
   retaining every allowed relationship and claim binding.
5. **Coverage basis:** assign the first allowed relationship in the exact
   user-visible input order as the basis. All later relationships remain in the
   explanation.
6. **Visible selection:** when at most five candidates remain, show all. When
   more remain, traverse input bases in visible order, selecting one per basis
   before a second; within each basis select one per distinct public occupation
   family before repeating a family; break remaining ties by canonical title
   and then stable public identifier. Stop at five.
7. **Omitted projection:** retain all unselected eligible candidates, grouped by
   basis and family with eligibility and omission reasons. User substitution
   changes only a separate visible-slot override for the current session.

The algorithm emits an inspectable trace of stage names, stable public IDs,
session-local input reference IDs, inclusion/omission reason codes, and policy
revisions. It never emits a quality total. Redacted developer diagnostics omit
private labels, aspiration text, canonical private IDs, and candidate rationale.

### Output privacy gate

Before publication, the privacy owner evaluates every candidate identity,
claim, explanation sentence, and relationship as a derived private-graph
output. It verifies that each protected dependency is covered by the exact
fact-, purpose-, decision-, and session-bound consent. Unknown classification
or output that reveals protected context beyond that scope omits the affected
candidate or rationale atomically. The planner may not replace it with a proxy,
nearby occupation, generalized protected category, or diagnostic clue.

Protected consent exists only in the in-memory session unless a future approved
Scope authorizes a compatible retained protected scope. This Design does not
persist protected facts or their consent in career preferences. Revocation
increments the input revision, removes all dependent relationships and results,
and recomputes without treating revocation as negative evidence.

### Persistence, migration, and replay

`CareerExplorationSession` and all portfolio/aspiration projections are
ephemeral values. They are not canonical objects, event-journal entries,
Receipts, searchable content, Spotlight content, widgets, notifications, or
sync records. They survive ordinary view navigation and in-process scene
backgrounding only while protected data remains available. Closing the route or
process termination destroys them. There is no migration for ephemeral data.

The only new durable state is `CareerExplorationPreference` schema v1:

- stable local preference ID;
- kind: remembered input or exact-occupation default dismissal;
- career-only purpose and scope label;
- referenced private-object ID and accepted revision for remembered input, or
  stable public occupation ID for dismissal;
- allowed input category and non-protected handling class;
- active/deleted lifecycle and created/changed timestamps;
- policy/schema revision; and
- content-minimized source lineage sufficient for inspection and replay.

The feature adds typed create, reset, and delete commands plus versioned events,
projection adapters, Receipt registry entries, and replay decoding. Create
validates expected source revision, future-use permission, non-protected class,
career-only purpose, uniqueness, and idempotency. Reset is one atomic owner
command over the explicitly selected preference IDs. Delete removes future
influence while retaining only the minimum tombstone required by current
persistence law; it does not delete the referenced source object or public
occupation.

Migration from every supported prior store creates an empty career-preference
projection and no synthetic preferences. It is idempotent under interruption
and replay. Unknown future event versions stop affected projection rebuilding
with explicit recovery rather than silently resetting. Projection rebuild from
events must reproduce the same active preference set; replay never recreates an
exploration session, reissues a public fetch, or re-dismisses a session-only
candidate. Backup/restore and supported continuity, if enabled by their own
contracts, treat career preferences as private graph data and never move them
to Account or R2.

### Concurrency and resource behavior

`CareerExplorationCoordinator` is an actor. It owns one monotonic input revision
per session and one structured child task for corpus load or computation. New
input, consent, refinement, dismissal, substitution, or source-snapshot choice
cancels the superseded task. Results publish on the main actor only after all
fingerprints still match.

Public pack refresh is isolated from private composition. A refresh may stage
and verify a replacement public snapshot concurrently, but the current session
retains its immutable snapshot until the user chooses Recompute. Preference
commands use expected revisions and idempotency keys through the canonical
runtime; a command conflict reloads current preference state and returns to
review rather than overwriting it.

Candidate enumeration is bounded by the active recommendation-ready corpus,
cancellable between stages, performed off the main actor, and stable across
collection order and hash randomization. Large source detail is loaded on
demand. No interaction path polls, performs synchronous disk I/O, or waits for
network freshness when a policy-permitted verified local snapshot is present.
Grooming must establish measured device/OS/build/corpus budgets before claiming
performance, memory, energy, or storage readiness.

### Canon and ownership changes needed during implementation

Implementation must add or update canonical owners for the two-lane career
exploration contract, neutral coverage algorithm, claim ceilings, explicit
input/consent scope, derived-output privacy omission, corpus gate, and
non-mutation boundary. `local-learning.md` should own only the declared local
use and controls for remembered career inputs; `source-atlas.md` remains public
delivery/firewall authority; Source Reference and Trust own inspection;
You owns route presentation. Goal canon receives only the distinction between
an option and a separately adopted Goal. No canon change may make the current
bounded corpus look comprehensive or silently authorize the career-domain
authority expansion.

## Privacy and accessibility

### Local-first and privacy contract

- Career sessions, selected inputs, aspiration text, relationships, candidate
  sets, explanations, substitutions, dismissals, corrections, and remembered
  preferences are private graph data.
- All joins, constraint evaluation, candidate selection, explanations, output
  classification, and corrections happen on device and work without an account.
- Source Atlas network and cache requests remain fixed public artifact requests.
  They contain no private query, identifier, derived selector, recommendation
  context, or feedback. Hosted AI, Account, R2, telemetry, analytics, and server
  profiling receive none of the career session or preference state.
- Local logs contain only redacted policy/corpus/session correlation categories
  and result counts where counts cannot disclose protected context. They never
  contain aspiration text, capability labels, private object IDs, protected
  categories, occupation rationales, or remembered preference values.
- Private content uses the repository's protected local storage class. Locked
  device, app-switcher, notification, screenshot, Spotlight, clipboard, and
  diagnostics paths default to minimum disclosure. No career notification or
  widget is introduced.
- Source inspection receives public claim bindings plus a local display
  context, never a public record rewritten with private rationale.
- Deleting or revoking an input, permission, consent, or career preference
  removes its future career influence and invalidates dependent in-memory
  results without rewriting historical source truth.

### Semantic and assistive-technology contract

The semantic order is: route title and limits; lane choices; selected-input
purpose and scope; consent; computation status; result count/corpus limit; each
candidate identity; inclusion reason; reusable progress; typical context;
preparation; gates; unknowns; sources; candidate actions; omitted options; and
Done. Headings and rotor landmarks preserve this hierarchy.

Every action has a visible label and a native accessibility action: select or
remove input, change preference/constraint meaning, disclose protected use,
start/cancel/retry, inspect candidate, inspect source, show another candidate,
refine, correct, dismiss, remember, reset, delete, choose aspiration identity,
and Done. Voice Control names match visible labels. Switch Control, Full
Keyboard Access, and hardware keyboard can reach each action without custom
gesture or drag.

Status changes announce concise meaning and next action: loading, cancelled,
portfolio count, omitted count, substitution result, recompute result,
source-changed, stale/mixed-cycle/source-check state, privacy-quiet omission,
failure, remembered/not-remembered settlement, and completion. Announcements
do not reveal protected content on a locked device.

Focus rules are deterministic:

- lane selection focuses the destination heading;
- input add/remove returns to that input and then announces the new selection
  count;
- computation success focuses **Career possibilities** or the aspiration title;
- failure focuses the error heading then Retry;
- source inspection return focuses the exact claim row;
- substitution focuses the incoming candidate title;
- dismissal focuses the next candidate or portfolio heading;
- recompute focuses the changed result heading;
- modal cancellation returns to the invoking control; and
- Done returns to **Explore careers** in Life Capital.

At accessibility Dynamic Type sizes, cards and side-by-side comparisons become
single-column sections; no horizontal scrolling is required for primary
meaning or controls. Bold Text, Button Shapes, Increase Contrast, Differentiate
Without Color, Reduce Motion, and Reduce Transparency preserve state and
action equivalence. RTL mirrors visual placement but not semantic order.
Reachability does not place destructive or privacy actions behind an unlabeled
swipe. No claim depends on color, icon, family grouping position, animation,
timing, chart, haptic, or candidate order.

## Requirement traceability

| Scope requirement | Design decisions |
|---|---|
| `REQ-001` | Explicit two-lane entry, local coordinator, no-account operation, and session-only selected inputs establish deliberate locally bounded exploration. |
| `REQ-002` | Input review enumerates only approved categories; preference versus hard-constraint semantics are explicit; eligibility facts are explanation-only; exact use is inspectable/removable; session expiry and separately commanded remembered scopes are defined. |
| `REQ-003` | Fresh fact-specific disclosure, typed consent scope, unknown-class fail-quiet behavior, derived-output privacy gate, atomic omission, revocation recompute, and no proxy enforce protected-context limits. |
| `REQ-004` | Independent adjacency and aspiration flows, stable occupation eligibility, exact coverage rotation, complete omitted projection, substitution, deterministic recompute, and zero-overlap aspiration retention implement both lanes without ranking. |
| `REQ-005` | Candidate structure contains identity/jurisdiction, exact influencing inputs, reusable progress, work/context, preparation, gates, unknowns, bounded rationale, and sources/limits. |
| `REQ-006` | `CareerClaimBinding`, claim-specific authority precedence, immutable source snapshot, per-claim freshness/conflict states, and Trust inspection prevent source flattening. |
| `REQ-007` | Material gate source-check rows, regulated/competitive state rules, minimum-eligibility ceiling, and named-cycle requirement make high-consequence destinations fail honestly. |
| `REQ-008` | No scalar or winner model; no reuse of scoring composers; equal cards; plain corpus-limit/actual-count copy; and inspectable neutral inclusion reasons preserve a non-ranked, non-exhaustive portfolio. |
| `REQ-009` | Session correction/dismissal, exact-candidate default dismissal as a separate reviewed durable choice, and inspect/reset/delete command flows prevent hidden profiling. |
| `REQ-010` | Claim-local failure states, bounded empty/source-unavailable/privacy-quiet states, aspiration fallback, immutable prior progress, and non-shaming recovery preserve user authority. |
| `REQ-011` | Ephemeral projections, no canonical destination mutation, strict owner handoffs, absent adoption action until its dependency exists, and explicit non-reuse of path models preserve the non-mutation boundary. |
| `REQ-012` | Semantic hierarchy, named actions, AT reachability, deterministic focus/announcements, adaptive layouts, non-color parity, reduced effects, RTL, reachability, locked-device redaction, and direct verification cover the calm accessible experience. |
| `REQ-013` | Recommendation-readiness corpus gate admits only the approved O*NET slice; RN and NASA are direct source-check-first aspirations; no generic source may supply missing NYSED or NASA authority. |

## Verification design

### Automated domain and planning tests

| Evidence | Required scenarios | Requirements |
|---|---|---|
| Input eligibility tests | Each allowed category; rejected blanket History access; preference versus hard constraint; explanation-only education/credential/experience facts; selection expiry; removing one input invalidates only dependent rationale. | `REQ-001`, `REQ-002` |
| Privacy-policy tests | Protected fact absent by default; exact disclosure/consent; unknown classification; over-revealing destination/rationale; atomic omission; no proxy; revocation; locked-device redaction. | `REQ-003`, `REQ-012` |
| Candidate-enumerator tests | Stable identity, required public relationship, deduplication, current evaluable constraint exclusion, unknown constraint retention, no score/weight/pay/outlook/eligibility influence. | `REQ-002`, `REQ-004`, `REQ-008` |
| Coverage property tests | Zero through large eligible sets; all candidates shown for one through five; basis rotation; family rotation; title/ID tie-break; input-order variation; deterministic omitted groups; substitution and refinement. Randomized source collection order must produce the same projection. | `REQ-004`, `REQ-008` |
| Aspiration tests | Zero-overlap NASA remains; ambiguous local identity choice; unsupported free-form aspiration; no Source Atlas free-form query; adjacency changes do not alter aspiration. | `REQ-001`, `REQ-004` |
| Explanation tests | Software developer separates O*NET identity/description from typical preparation, unknown employer facts, and capability relevance; no qualification or winner language; all required sections and source bindings. | `REQ-005`, `REQ-006`, `REQ-008` |
| Authority tests | Generic source cannot satisfy regulator/employer/selecting-organization gate; stale/conflict affects one claim; mixed-cycle cannot claim opening; eligibility never predicts selection or permission to practice. | `REQ-006`, `REQ-007` |
| Corpus-gate tests | Delivered but not recommendation-ready domain rejected; O*NET 30.3 software-developer slice admitted; NYSED/NASA absent from adjacency; RN/NASA direct aspirations show source-check-first and incomplete authority. | `REQ-006`, `REQ-007`, `REQ-013` |
| Failure tests | No pack, bundled/LKG, stale allowed/blocked, corrupt, revoked, conflicting, cancellation, superseded revision, all-private omission, process restart, and truthful no-candidate state. | `REQ-010` |
| Non-mutation tests | Every explore/refine/correct/dismiss/substitute/source-inspect path leaves Goal, Path, Step, schedule, Proof, capability, application, provider, and external-write stores byte-equivalent. | `REQ-011` |

### Persistence, migration, concurrency, and replay evidence

- Round-trip and replay tests for create/reset/delete
  `CareerExplorationPreference` events, Receipt linkage, expected-revision
  conflict, duplicate idempotency key, projection rebuild, deletion influence,
  and source-object lifecycle invalidation.
- Direct upgrade from every supported store version establishes an empty v1
  preference projection; interrupted migration, duplicate replay, corrupt event,
  unsupported future version, backup/restore, and forward-repair cases preserve
  the last readable store.
- Relaunch proves that remembered preferences replay while session-only inputs,
  aspiration text, substitutions, and dismissals do not.
- Structured-concurrency tests race input changes, consent revocation, source
  refresh, cancellation, view dismissal, protected-data loss, and preference
  commands. Only the newest matching fingerprint may publish and no task may
  outlive the session owner.

### Privacy and firewall evidence

- Extend the executable Source Atlas no-private-graph egress audit with every
  career field: aspiration text, selected capability/private IDs and labels,
  evidence IDs, location/pay/schedule preferences, constraints, protected facts,
  candidate IDs chosen from private context, rationale, dismissals, corrections,
  and remembered preferences. Exercise URL, path, headers, body, public selector,
  cache key, artifact identity, logs, diagnostics, metrics, and feedback.
- Prove that requests use only allowlisted public selector fields and fail
  closed for a private-derived or free-form selector.
- Inspect local logs, crash diagnostics, app-switcher snapshots, notifications,
  Spotlight, clipboard, exports, Account payloads, hosted-AI adapters, R2
  objects, and telemetry for prohibited session/preference content.
- Verify every stored and derived type's handling class, owner, destinations,
  redaction, retention/deletion, consent, protection, and inspection policy.

### Runtime, build, and device evidence

- Focused unit suites for CareerExploration domain, Planning, PrivacySecurity,
  Commands/Replay, Source Atlas boundary, Inspection, and surface projections.
- Changed-scope Code Quality checks, `git diff --check`, SwiftLint, static
  analysis, secrets scanning, project regeneration when `project.yml` changes,
  and the relevant native build/test lane.
- Full native runtime scenarios on the declared device/OS/build configuration:
  both lanes; zero/two/five/eight candidates; omitted inspection and
  substitution; refine/correction/dismissal; source detail; stale/offline/error
  recovery; protected consent/revocation; preference create/reset/delete; and
  proof that Done changed no adjacent object.
- Direct VoiceOver, Voice Control, Switch Control, Full Keyboard Access, and
  hardware-keyboard verification for every primary, alternative, failure, and
  recovery path. Verify rotor/headings, modal containment, announcements, focus
  restoration, accessibility labels/values/hints, and locked-device parity.
- Visual/device validation at all supported Dynamic Type categories, Bold Text,
  Button Shapes, Increase Contrast, Differentiate Without Color, Reduce Motion,
  Reduce Transparency, RTL/localized expansion, portrait/landscape where
  supported, reachability/handedness, and sensitive app-switcher presentation.

### Performance and resource calibration

Grooming must define a representative recommendation-ready occupation corpus,
selected-input count, relationship density, omitted-candidate count, source
claim density, durable preference count, device floor, OS, build configuration,
warm/cold cache, and measurement tool. Measure corpus load, first projection,
refinement/recompute, omitted-list presentation, source inspection, cancellation
latency, peak memory, storage growth, and energy. Percentile/maximum and
regression thresholds must be derived from evidence, not invented in this
Design. Tests must also prove bounded work, cancellation, no main-thread disk or
network wait, and graceful storage/protected-data/thermal/Low Power behavior.

### Traceability completion rule

Implementation grooming must map every task and test back to the relevant
Design subsection and Scope `REQ-###`. A Design verification row passes only
when its executable or direct-device evidence proves the stated behavior; code
presence, fixtures, static inspection, simulator build, or Source Atlas delivery
alone cannot claim user-flow, accessibility, privacy, migration, or corpus
readiness.

## Open decisions

No unresolved product decision remains. The following technical choices are
left for grooming without permission to change behavior:

- exact Swift file boundaries and whether the career-preference projection uses
  an existing generic private-runtime record container or a dedicated typed
  repository;
- the adapter shape from the final public-reference foundation projection into
  `CareerPublicCorpusSnapshot`, while preserving every claim and corpus-gate
  field defined here;
- the local search/index implementation for aspiration disambiguation, provided
  it is bounded to verified local identities and never shapes a remote request;
- final plain-language wording after comprehension and localization testing,
  provided the distinctions among typical preparation, hard gate, mixed cycle,
  source check needed, unavailable, and non-exhaustive corpus remain intact; and
- measured performance, memory, energy, and storage budgets for the declared
  representative corpus and device floor.

If implementation discovers that any choice requires scoring, broader corpus
authority, retained protected consent, session recovery after process death,
new recommendation inputs, candidate pruning, or a Goal/adoption mutation, work
must return to Scope rather than resolve it as a technical detail.
