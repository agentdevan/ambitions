+++
initiative = "hobby-destination-recommendations"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Hobby exploration is an explicit, in-memory local session reached from You >
Life Capital. It offers only creative/making and knowledge/collecting
activities whose low-risk beginner entry does not depend on a provider,
purchase, certification, legal interpretation, safety-bearing instruction, or
external account. It is never surfaced passively.

The session asks the user for one of two experience directions and one of three
familiarity postures, then optionally lets them select individual eligible
Capabilities. Capability use requires the capability's future-use eligibility
plus a fresh hobby-specific disclosure and deliberate selection; capability-
free exploration is equally supported. These inputs, results, protected-fact
consent, corrections, and dismissals disappear when the session ends and never
become preferences, learning, or identity.

Matching is a deterministic local eligibility-and-inclusion pipeline, not a
score. After corpus, family, source/safety, input, and privacy gates, it shows
up to four candidates using the exact family-diversity and stable identity/name
rules from Scope. Every additional non-suppressed eligible candidate remains
discoverable. Privacy-suppressed candidates are absent from both count and
explanation.

No live hobby corpus is approved by the Research or Scope: photography,
birdwatching, Scouting, Cornell, Toastmasters, and sailing are research pilot
evidence only. The engine and UI can be implemented and verified with declared
synthetic fixtures, but live candidate presentation remains quiet-unavailable
until a separately approved hobby corpus supplies an eligibility certificate
covering authority, rights, freshness, family, and low-risk entry. This Design
does not broaden that corpus or Source Atlas authority.

## User flows

### Start an exploration session

1. The user deliberately chooses `Explore hobbies` from You > Life Capital.
   No card or notification proposes a hobby elsewhere.
2. The opening page says: exploration is private and local; it will not create
   a Goal, change a Capability or Life Area, remember a preference, contact a
   provider, publish activity, or schedule anything.
3. Continuing creates an in-memory session ID and binds a snapshot of the
   eligible public corpus and Capability revisions. Starting and canceling
   emits no Command, Event, Receipt, History, network request, or durable row.

### State the temporary direction

1. The user may choose `Make or express` or `Notice, learn, or collect`, or
   leave the experience choice unset for this session.
2. The user may choose `Build from something I know`, `Mix familiar and new`,
   or `Start completely new`, or leave familiarity unset.
3. These are visibly described as choices for this exploration only. They
   cannot be inferred, preselected from history, or saved as defaults.
4. `Start completely new` keeps capability-free exploration prominent. The
   user can also choose no Capabilities under either other familiarity posture;
   Ambitions explains that current evidence supports only the explicit inputs.

### Select Capabilities, if desired

1. The Capability picker contains only active, non-protected Capabilities whose
   future-use permission is on. Nothing is selected by default.
2. Before first selection, the session explains that selected names may affect
   which possibilities appear and may be named in the local rationale, but do
   not prove aptitude, enjoyment, proficiency, or identity.
3. The user selects each Capability separately. Turning off permission or
   changing lifecycle while the picker is open removes it at recomputation and
   asks the user to review the updated inputs.
4. A protected fact is never inferred. If the user explicitly selects an exact
   eligible protected fact offered by its owning local control, a fresh modal
   names the fact, purpose, possible rationale disclosure, session-only
   retention, and cancel path. Unknown classification blocks use. Scope's
   protected-output boundary still runs after matching.

### Generate and inspect possibilities

1. `Show possibilities` runs entirely on device against the bound approved
   public-corpus projection. If no eligible corpus exists, the session shows
   `Hobby references are not ready for this exploration` with input correction
   and exit; it does not use research-pilot sources or fabricate generic ideas.
2. Eligibility first removes out-of-family, provider/purchase/certification/
   external-account-dependent, safety/legal/medical/emergency-bearing,
   authority-incomplete, stale-blocked, rights-blocked, and privacy-suppressed
   candidates.
3. If two to four candidates remain, all appear. If one remains, it appears
   alone with an honest sparse-results explanation. None yields quiet
   unavailability. Results are never duplicated or padded.
4. If more than four remain, the visible window follows family-first
   alternation, then stable public activity identity and visible name. The page
   states that order has no recommendation meaning and reports only the count
   of additional non-suppressed eligible possibilities.
5. Each card states activity/family, what the practice involves, the exact
   temporary choices that included it, only the selected Capabilities that may
   lower the starting barrier, a modest provider-independent beginner entry,
   known practical considerations, explicit unknowns, and a source link. It
   never predicts enjoyment or completion.
6. Source detail opens the public-reference inspection projection for the
   exact claims, including authority-for-purpose, version/freshness,
   jurisdiction, limits, conflicts, and unknowns. Returning restores focus to
   the same candidate.

### Review overflow, correct, dismiss, or go unrelated

- `See all eligible possibilities` opens the complete non-suppressed set in
  the same neutral order. Every item exposes family, inclusion basis, and
  known/unknown state. Selecting one brings it into the visible window without
  storing preference or demoting another as worse.
- Refining experience, familiarity, family, or selected Capabilities recomputes
  from the new explicit session snapshot. No prior rejection becomes a signal.
- `Not for this session` removes one candidate only in memory and advances the
  next neutral eligible candidate. It produces no shame, argument, count or
  identity leak for privacy-suppressed options, or durable dismissal.
- `Try something unrelated` clears selected Capabilities, sets familiarity to
  `Start completely new`, and recomputes from the user's explicit experience
  choice. It does not imply that capability-based results were wrong.
- `None of these` returns to correction or exit without persuasion. Exit clears
  the complete session.

### Express interest without adopting

`I'm interested` opens a non-durable handoff preview naming the possibility and
stating that nothing has changed. If the separately approved destination-
adoption owner is available, `Continue to adoption` transfers only the chosen
public destination reference and returns control to that owner's fresh review.
Otherwise the preview says adoption is not available. This initiative creates
no Goal, Path, Step, schedule, provider relationship, or external effect.

## States and recovery

### Session states

- **Not started:** no personalized destination or session state exists.
- **Purpose disclosure:** private/local/non-committing explanation; continue or
  exit.
- **Input:** exact experience, familiarity, selected Capability, and separately
  consented protected-fact controls.
- **Evaluating:** cancellable local computation over a revision-bound public
  and private snapshot; no artificial progress animation.
- **Results:** one to four visible, unranked possibilities and discoverable
  non-suppressed overflow.
- **Sparse:** one truthful candidate, with correction/unrelated/exit.
- **Unavailable:** no safely eligible candidate or no approved corpus; the copy
  does not attribute absence to the user.
- **Stale input:** selected Capability, privacy consent, or public claim changed;
  review current inputs before recomputation.
- **Source degraded:** a candidate-specific claim is stale-blocked, conflicted,
  rights-blocked, invalid, or absent; affected candidate is omitted while other
  eligible results remain.
- **Handoff preview:** in-memory interest only, with separate-owner boundary.
- **Ended:** all session inputs, consent, candidates, dismissals, and rationale
  are released.

### Failure and recovery

- Cancellation during evaluation returns to Input with the current in-memory
  choices and no mutation.
- A local engine error preserves the active-session choices, exposes a redacted
  error and `Try again`, `Review choices`, or `Exit`, and announces no protected
  reason. Retry uses the same snapshot unless the user requests refresh.
- Public data unavailable/offline uses only a verified eligible local corpus.
  There is no remote query fallback. If none exists, quiet unavailability
  preserves local core behavior.
- A privacy classification error suppresses the affected candidate before
  inclusion/counting. UI and accessibility receive only a generic unavailable
  result, never the protected reason or candidate identity. It emits no
  session-scoped log, telemetry, cache, feedback, or diagnostic payload.
- Memory pressure or app termination ends the session safely. Foregrounding an
  intact scene may retain its in-memory state; relaunch starts fresh by design
  and never reconstructs choices from logs or History.
- If the corpus or selected Capability revision changes while results are open,
  existing cards become `Needs refresh`; they cannot be adopted or newly
  inspected as current until deterministic recomputation.
- Focus after recompute returns to the results heading and first changed item;
  after dismissal to the replacement or remaining-results heading; after
  failure to the error and first recovery action; after cancel to the
  initiating control.

## Architecture and data

### Components and boundaries

- `HobbyExplorationSession` is a scene-owned in-memory aggregate with session
  ID, phase, exact temporary choices, selected Capability IDs/revisions,
  protected-consent revision, public corpus snapshot ID, candidate window,
  non-suppressed overflow, dismissed IDs, and focus token. It is not canonical
  or persisted.
- `HobbyDestinationCandidate` is a read model containing stable public activity
  identity, one of the two allowed families, practice description claim IDs,
  approved low-risk beginner-entry claim IDs, practical known/unknown fields,
  exact inclusion basis, and source-inspection references. It contains no score
  or provider transaction.
- `HobbyCorpusEligibilityCertificate` binds an approved corpus/release to
  allowed source IDs, rights, claim authority, freshness, family coverage,
  risk boundary, beginner-entry completeness, and domain-review revision. The
  matcher rejects packs without this certificate. Research-pilot sources and
  generic configured pack labels do not qualify.
- `HobbyDestinationEligibilityPolicy` applies first-release family, low-risk
  entry, source authority/freshness/rights, external dependency, explicit input,
  and privacy gates. It returns eligible or a typed internal exclusion; privacy
  exclusions are discarded before presentation or any observability boundary.
- `HobbyCandidateWindowPolicy` receives only non-suppressed eligible candidates
  and performs the exact family diversity, alternation, stable public ID, and
  visible-name ordering. It never consumes confidence, popularity, capability
  count, or fit values.
- A local Planning/recommendation coordinator performs the private join. Source
  Atlas supplies immutable approved public claims only. Capability projection
  supplies only the exact locally selected eligible records. The surface owns
  presentation; no component receives canonical mutation authority.

### Deterministic pipeline

1. Start creates an empty session and captures the current policy version.
2. Explicit choices and separately selected Capability snapshots are validated
   locally. Protected consent is bound to exact fact, purpose, allowed rationale
   fields, policy revision, and this session ID.
3. The coordinator requests the already-local hobby corpus by fixed public
   artifact identity; private selections never become the request or cache key.
4. Corpus certificate validation runs before decoding candidates for private
   matching. Missing certificate produces quiet unavailability.
5. Eligibility filters public candidates using only declared policy gates.
   Local matching then records exact user inputs that caused inclusion.
6. Derived-output privacy classification runs on candidate identity and
   rationale. Suppressed candidates and their identities are removed before
   count, diversity ordering, overflow, any observability boundary, and
   accessibility projection.
7. Window policy groups by family, sorts each group by public activity ID then
   user-visible name, emits one from each represented family before repetition,
   then alternates while both groups remain. It fills at most four; remainder
   stays in the same ordered overflow.
8. Projection renders qualitative cards and source links. All correction,
   dismissal, unrelated exploration, and interest actions change only the
   in-memory session or navigate to a separate non-mutating handoff.

### Persistence, migration, concurrency, and replay

- **Persistence:** N/A for user/session state by product requirement. No
  preferences, consent reuse, selected Capability list, candidate history,
  rationale, correction, dismissal, or handoff preview is written to canonical
  stores, learning stores, History, logs, telemetry, caches, feedback, or
  diagnostics.
- Approved public corpus persistence is owned by the public-reference
  foundation. This Design stores no duplicate source or private/public joined
  artifact. Capability persistence remains owned by Capability continuity.
- **Migration:** the first implementation adds no user-data migration. Engine
  policy and synthetic fixture schemas are versioned; incompatible public
  corpora simply fail the eligibility certificate. No existing hobby pack is
  promoted or rewritten.
- **Concurrency:** session mutations are serialized on the UI/session actor.
  Evaluation runs on an immutable snapshot off-main and returns only if session,
  policy, corpus, selected Capability, and consent revisions still match.
  Otherwise it yields stale-input recovery. Cancellation releases intermediate
  private joins.
- **Replay:** N/A for the exploration because no canonical mutation exists.
  Determinism is proved by equivalent input/corpus/policy snapshots producing
  the same eligible set, neutral window, overflow, and explanations. Ordinary
  runtime replay neither recreates nor reissues a session or public request.
- Diagnostics may contain only a session-independent approved public policy or
  corpus identifier and a fixed phase or error code whose value is provably
  independent of every private input, candidate, result, output, and session
  path. They contain no count, duration, category, correlation, or value
  derived from a session. If that proof is unavailable for any field or event,
  no diagnostic is emitted.

## Privacy and accessibility

All private matching occurs locally and works without an account. Selected
Capabilities, temporary choices, protected facts/consent, candidate set,
rationales, dismissals, corrections, and interest are private graph context
even though they are not persisted. They are prohibited from Source Atlas, R2,
Account, hosted AI, logs, telemetry, caches, feedback, remote search, external
profiles, and provider requests. Equivalent public access uses the same fixed
artifact identity regardless of session inputs. A diagnostic payload cannot be
influenced by any of that private context or by a candidate/result: two
sessions with the same approved public policy/corpus and different private
context either emit byte-identical allowlisted diagnostic data or emit none.

Protected input is exact and purpose-bound; generic future-use permission is
insufficient. Unknown classification blocks participation. Derived output is
classified after matching, and over-revealing results disappear before
count/order/overflow. No proxy candidate, omission message, accessibility
announcement, diagnostic, or source request reveals the suppression. Leaving
the session destroys consent and requires fresh review next time.

Semantic order is: session purpose/privacy; temporary experience choice;
familiarity choice; optional Capability selection and consent; result count and
non-ranking statement; each candidate identity/family/practice; rationale;
beginner entry; knowns/unknowns; source/limits; actions; overflow; correction;
unrelated exploration; exit. Cards never depend on columns, imagery, color, or
motion and remain comprehensible as a vertical list.

Every control has a unique accessible name and consequence. VoiceOver,
Voice Control, Switch Control, Full Keyboard Access, and hardware keyboard can
complete the session, use source disclosure, inspect overflow, dismiss,
correct, go unrelated, open the handoff, and exit without gesture. Dynamic Type
stacks all text/actions; Bold Text, Button Shapes, Increase Contrast,
Differentiate Without Color, Reduce Motion/Transparency, RTL, and localization
preserve meaning. Status announcements say only safe result counts and state;
privacy-suppressed candidates are never announced. Stable focus IDs implement
the recovery behavior above.

## Requirement traceability

| Scope requirement | Design decisions |
| --- | --- |
| REQ-001 | Deliberate You > Life Capital entry, opening privacy/non-commitment disclosure, in-memory session, no passive surface or mutation. |
| REQ-002 | Corpus certificate and eligibility policy admit only low-risk creative/making and knowledge/collecting entries with no excluded dependency. |
| REQ-003 | Exact two optional experience and three optional familiarity controls; explicit unset state; no inference/default persistence; session destruction. |
| REQ-004 | Empty-by-default eligible Capability picker, per-record selection and hobby disclosure, capability-free/unrelated path, no aptitude claim. |
| REQ-005 | Exact session-bound protected consent, unknown block, derived-output classification, suppression before count/order with no proxy leakage. |
| REQ-006 | One-to-four truthful window, no padding, explicit non-ranking, complete overflow path, quiet sparse/unavailable states. |
| REQ-007 | Candidate read model and card contain activity/family/practice, exact inputs, selected progress, beginner entry, knowns/unknowns, no prediction. |
| REQ-008 | Corpus certificate plus claim-specific source inspection; missing/conflicting authority blocks candidate; no research-pilot promotion. |
| REQ-009 | Concise card with deeper public-reference source/limits inspection; provenance has no badge or private-context claim. |
| REQ-010 | In-memory session only; dismissal/correction recompute without learning, History, Receipt, or retained rejection. |
| REQ-011 | Fixed public artifact request and Source Atlas firewall; offline verified local corpus or quiet unavailability; no private-derived egress. |
| REQ-012 | Non-mutating interest handoff; explicit owner transitions; no Goal/Path/Step/Time/Capability/Life Area/Proof/provider write. |
| REQ-013 | None/correction/unrelated/exit controls at results; prohibited-language review; no penalty or persuasion. |
| REQ-014 | Stable semantic order, named controls, full assistive input/reflow/reduced-effects/non-color/focus behavior, fail-quiet recovery. |
| REQ-015 | Exact family-first alternating stable-ID/name algorithm, complete non-suppressed overflow, user selection/refinement, neutral dismissal advancement. |

## Verification design

| Lane | Required evidence |
| --- | --- |
| Policy/unit | Exhaustive family and excluded-dependency table; no-certificate gate; low-risk entry completeness; exact temporary choices; selected/no Capability; protected/unknown/over-revealing cases; sparse/no-padding; no scoring fields. |
| Neutral inclusion | Permutation tests with 0, 1, 2, 4, 5+, one-family, and two-family eligible fixtures; first-from-each, alternation, public-ID/name tie break, full overflow, chosen overflow, dismissal advancement, stable repeatability, privacy-suppressed removal before count. |
| Source/domain | Synthetic corpus certificates prove authority/freshness/rights/risk gating. Negative fixtures prove research-pilot sources, current generic hobby packs, provider/safety/legal/certification/external-account candidates, stale/conflicted/missing authority, and unapproved corpus cannot drive live results. |
| Privacy/firewall | Pairwise test different private sessions against the same approved public policy/corpus and prove any allowlisted diagnostic payload is byte-identical; otherwise prove no diagnostic emits. Reject every Capability/choice/protected/candidate/result/rationale/dismissal/location/schedule value, count, duration, category, correlation, cache key, log, telemetry, cache, or feedback leak; prove prohibited data never enters those boundaries; proxy and accessibility suppression attacks; memory cleanup at exit/termination. |
| UI/runtime | Explicit entry only; disclosure/input/picker/results/overflow/source/sparse/unavailable/error/handoff flows; no passive destination; correction/unrelated/None/exit; revision change; background/termination; every action leaves canonical and external state unchanged. |
| Persistence/replay | Store diff proves zero new private records/events/receipts/learning after every session path; relaunch begins empty; canonical replay does not reproduce sessions; public pack remains separately owned. |
| Accessibility | Direct VoiceOver order/actions/announcements, Voice Control, Switch Control, Full Keyboard Access/hardware keyboard, Dynamic Type, Bold Text, Button Shapes, Increase Contrast, Differentiate Without Color, Reduce Motion/Transparency, RTL/localization, focus for recompute/dismiss/error/cancel/source return, and no protected leakage. |
| Language/comprehension | Copy lint plus moderated prototype checks for invitation versus prescription, non-ranking/order understanding, capability reuse versus aptitude, explicit unknowns, and leisure not being careerized or optimized. |
| Performance/resource | Measure certificate validation, filtering, privacy classification, neutral window/overflow, recomputation, cancellation, and memory release using representative bounded synthetic candidate/capability counts on named device/OS/build. Grooming derives latency, memory, energy, and regression budgets; evaluation stays off-main and cancellable. |
| Build/static | XcodeGen regeneration for new files, affected builds/tests, SwiftLint/static analysis/secrets/privacy scans, Source Atlas boundary audits, `git diff --check`, canon check after canon changes, and changed-scope Code Quality. |

## Open decisions

No unresolved product decision remains. Grooming may resolve only:

- the exact in-memory session actor and SwiftUI navigation/file decomposition;
- the binary/JSON shape and verification signature of a domain-corpus
  eligibility certificate, without changing who can approve corpus behavior;
- the exact local policy type names and the allowlisted static diagnostic codes
  and session-independent public identifiers; and
- measured evaluation/resource budgets and synthetic fixture scale.

Selecting real creative/making or knowledge/collecting activities and sources,
adding a third family, persisting session state, changing the two-by-three input
set, using a score, adding provider/current availability, or relaxing the corpus
certificate is a product/corpus change that must return to Research and Scope.
