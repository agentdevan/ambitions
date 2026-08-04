+++
initiative = "personal-context-and-constraint-controls"
document_type = "research"
status = "approved"
upstream = ""
+++

## Idea and user problem

A path is useful only when it fits the person's actual life. Duration alone is
not enough: thirty free minutes before work can differ from thirty minutes after
the gym; money can be a monthly ceiling or a one-time budget; equipment,
transport, caregiving, accessibility, energy, place, deadlines and relationships
can make a Step feasible, undesirable or unknown. Ambitions needs a coherent way
for users to express these facts without turning them into a hidden personality,
health, wealth, family or “commitment” score.

The outcome is a user-owned Context & Constraints library. People add only what
helps, see exactly which proposals/simulations use it, correct/disable/expire/
delete it, and can run intelligence with categories excluded. Owners receive
typed permitted facts and unknowns; no constraint is a moral judgment or an
automatic instruction to mutate a Goal or schedule.

## Current truth

### Approved baseline

- Context-quality scheduling v1 models qualitative time fit and preserves
  schedule placement authority/confirmation.
- Capability Continuity owns user-approved capabilities/Proof; local learning
  owns bounded explicit influences and neutral behavior when evidence is weak.
- Destination/path proposals need time, money, location, equipment, opportunity
  and other constraints but must not infer personal eligibility or fit.
- Private Generative Runtime defines purpose-bound context capsules and prohibits
  whole-profile/hosted leakage.
- Multi-Goal/Life Branch simulations need comparable constraint inputs but must
  preserve uncertainty and user control.

These documents are approved plans, not shipped evidence. Research can define a
shared context contract now; effectiveness thresholds and default capture
burden must be calibrated after v1 capability/scheduling interaction evidence.

### Live repository seams

Live source includes protected Time, schedule block repositories, planning
defaults, Life Context models/receipts, permission controls, local learning,
Capability/Proof, Goal/Step/Resource models, private runtime boundaries,
History/Receipts and deletion/replay contracts. It does not expose one complete
typed, purpose-scoped context/constraint repository with user-facing influence
inspection and field-level consent.

### External evidence and standards

Apple's [privacy HIG](https://developer.apple.com/design/human-interface-guidelines/privacy)
calls for contextual permission requests, specific purpose explanation and user
choice for location, health, financial, contacts, calendar and other protected
data. System permission does not equal permission to use every resulting field
for intelligence; Ambitions still needs a product-purpose control and local
fallback.

Apple's current [machine-learning HIG](https://developer.apple.com/design/human-interface-guidelines/machine-learning)
warns that implicit feedback can be sensitive and asks products to help people
control their information. Completion timing, dismissals and browsing therefore
cannot silently become stable context.

The [NIST Privacy Framework](https://www.nist.gov/privacy-framework) treats
privacy risk across the data lifecycle and processing ecosystem. For Ambitions,
context needs purpose, retention, recipients, correction/deletion and change
controls even when data stays local; a future hosted model or integration is a
different processing role requiring separate review.

The [IANA Time Zone Database](https://www.iana.org/time-zones) changes as
governments change offsets and daylight-saving rules. A context such as “before
work in my home time zone” must retain a zone identifier and system/database
version, not a permanent UTC offset. Calendar math remains platform-owned.

Currency, measurement units, locale and calendars should use platform
Foundation/ICU semantics. Public cost/location/access claims remain with Current
Authority Registry; the user's budget/travel willingness/access needs remain
private context. One never edits the other.

### Context taxonomy

The smallest coherent shared taxonomy is:

1. **Time envelope:** recurring/one-off availability, protected time, deadlines,
   lead time, flexibility, interruption tolerance and timezone.
2. **Activity quality:** user-described energy/focus/social/privacy/indoor/
   outdoor/transit/recovery/cognitive-load contexts. These are labels, not health
   diagnoses or inferred chronotype.
3. **Money:** one-time/recurring/range/ceiling, currency, period, flexibility and
   whether unknown/declined. No income inference.
4. **Place and mobility:** user-approved coarse/home/remote/on-site regions,
   travel time/willingness, relocation posture and transport modes. Exact
   location history is not required.
5. **Equipment and environment:** available/borrowable/purchasable equipment,
   space, connectivity, device, clothing, storage and environmental needs.
6. **Opportunity/authority dependencies:** must coincide with a source-owned
   opening, cohort, permit, prerequisite recheck or external decision.
7. **People and responsibilities:** user-described caregiving, household,
   collaboration, privacy, support or coordination windows. Do not create a
   contact/relationship graph by default.
8. **Accessibility and accommodation preferences:** user-authored functional
   needs and interface/action constraints, not diagnosis or legal status.
9. **Health/safety/legal/sensitive facts:** excluded by default; may be explicit
   task-specific private facts with strongest controls and no model inference.
10. **Preference and tradeoff posture:** reversible user statements such as
   “protect evenings” or “prefer a longer route that avoids debt,” not stable
   personality/value labels.

Every item has value/range, unit, applicability, recurrence/effective interval,
confidence source (`userStated` or `systemObservedWithConfirmation`), sensitivity,
allowed purposes, expiry/review, revision and notes. `unknown`, `notIncluded`,
`notApplicable`, `unavailable`, `conflicting`, `temporarilyDisabled` and
`deleted` are distinct.

### Capture and inference boundary

Manual entry and in-context confirmation are primary. A surface may suggest:
“You often move this kind of task; would you like to set a preference?” only if
the separately approved local-learning rule, evidence display and no-shame
threshold permit it. Until confirmed, it is a disposable suggestion—not a
context fact. Absence, noncompletion, late-night use, location patterns,
calendar titles, Proof content, contacts or external app data cannot create a
constraint.

Imported Calendar/Health/location/financial/contact data requires its own
system permission and integration Scope. This initiative can represent an
explicit derived/user-entered fact but does not authorize those imports.

### Purpose, precedence and conflicts

Facts use allowlisted purposes: `destinationProposal`, `pathProposal`,
`scheduleSuggestion`, `adaptiveReplan`, `portfolioSimulation`,
`lifeBranchSimulation`, `externalActionPreview`. Default sharing is none beyond
the initiating feature; the user can grant a category to a purpose with an
expiry. On-device generation still needs purpose authorization.

Hard/soft language is dangerous: a “hard” constraint might be mistaken for an
objective impossibility. Use `mustRespect`, `prefer`, `informOnly`, and
`unknown`, all user-editable. Authority-owned requirements are not stored as
personal constraints. Conflicts (e.g. protect evenings and meet a night cohort)
remain visible options/unknowns; an engine cannot silently relax either.

Precedence is deterministic: legal/platform safety and explicit user exclusions
block; current task-specific confirmed context beats general preferences;
unknown never becomes a default; conflicts yield alternatives/clarification;
no optimization score hides a violated must-respect fact.

### Influence inspection and control

Every proposal/simulation must list used, not used, excluded, expired,
conflicting and missing context by human label and show the observable effect:
“Kept evenings protected,” “Cost is unknown,” “This option needs travel beyond
your stated range.” Users can remove one fact and recompute a draft without
changing the saved context, or edit/disable/delete it globally with an impact
preview. Canonical Goals/Steps/Time do not change until their owner confirms.

### Lifecycle and deletion

Context facts are private, encrypted/protected at rest under existing local
storage protections, revisioned and event-sourced consistently with repository
practice. Expiry prompts a neutral review and produces unknown if not renewed.
Deletion must remove fact, derived indices, context snapshots, draft influences,
feedback, exports and optional continuity copies; accepted canonical objects
retain a provenance note that an input was deleted/unknown rather than copying
the secret. Reset can be category/purpose/all.

### Evidence-dependent calibration

Scope can define observable ownership, taxonomy and engine boundaries now.
Runtime evidence from v1 scheduling and Capability interactions is required
before choosing default prompts, inferred-suggestion thresholds, vocabulary
ordering, maximum visible categories or claiming improved usefulness. Those are
evaluation/rollout parameters, not missing architecture.

## Evidence

The platform already has multiple legitimate consumers and separate owners; a
shared context contract prevents each from inventing incompatible private
profiles. External guidance supports contextual collection and lifecycle
control. The need for changing time-zone/version facts proves that even simple
constraints require typed semantics. Explicit-purpose context allows ambitious
intelligence while remaining local and correctable.

## Alternatives

1. **One free-form “about me” profile.** Easy to enter but untyped, overbroad,
   hard to delete and dangerous for hosted prompts. Reject.
2. **Infer everything from behavior.** Low effort but opaque, sensitive and
   self-reinforcing. Reject.
3. **Each feature owns private settings.** Simple locally but duplicates meaning
   and makes cross-feature correction inconsistent. Reject.
4. **Shared typed facts with purpose grants and feature-local overrides.** More
   explicit interaction, but inspectable and composable. Recommend.

## Unknowns and risks

- Capture burden may outweigh value; progressive in-context entry is required.
- “Energy” and “focus” can drift into health/personality inference; vocabulary
  must remain self-described and situational.
- Budget/location/access constraints may encode structural inequality; the UI
  must offer alternatives and never shame or lower a person score.
- Relationship facts can expose other people. Store coordination needs without
  unnecessary identity/contact data.
- System time-zone/database updates can change future occurrences; simulations
  must re-resolve and explain changes.
- Direct-user evidence is required to calibrate prompts and usefulness claims.

No hard fork remains. Sensitive imports and implicit suggestions stay disabled
until separately scoped/evidenced; manual/purpose-bound context is complete.

## Recommended direction

Create a local `PersonalContextRegistry` of typed user-controlled facts, purpose
grants, task-local overrides and influence receipts. Provide progressive manual/
contextual capture, deterministic conflict/precedence, ephemeral context views
for consumers, full inspection and scoped deletion. Do not build a monolithic
profile or permit intelligence engines to mutate facts.

### Five compounding ruthless review passes

1. Completeness: covered all required constraint families, temporal/units,
   states, capture, precedence, influence, lifecycle and evidence holds.
2. Connections: separated public authority, scheduling, capability, learning,
   generation, simulation, integrations and canonical owners.
3. Privacy/authority: removed implicit profile creation, contact graphs, import
   authority, purpose bundling and silent constraint relaxation.
4. Feasibility: aligned with live local repositories/permissions/receipts and
   platform timezone/locale services.
5. Coherence/value: chose progressive task-local entry, removable what-if
   overrides and non-shaming alternatives instead of exhaustive onboarding.

Review verdict: **PASS** after reconciliation. Devan delegated approval;
Research was approved on 2026-08-04.
