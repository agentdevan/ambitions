+++
initiative = "personal-context-and-constraint-controls"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

Users can progressively state, inspect and control the real-life constraints and
preferences Ambitions may use. Every intelligence result shows which context
affected it; the user can exclude, override, correct, expire or delete facts and
recompute drafts without hidden inference or automatic canonical mutation.

## In scope

- Typed private Context Facts across time, activity quality, money, place/
  mobility, equipment/environment, opportunity dependencies, people/
  responsibilities, accessibility, sensitive task facts and tradeoff posture.
- Explicit value/unit/range/effective/recurrence/sensitivity/provenance/revision.
- `mustRespect`, `prefer`, `informOnly`, unknown/not-included and conflict states.
- Purpose grants for proposal, scheduling, replanning, simulation and action
  preview; purpose-specific expiry/revoke.
- Progressive manual/in-context capture, task-local overrides and optional
  confirmed local-learning suggestions behind future evidence gates.
- Deterministic context resolution, precedence, conflict/clarification and
  ephemeral read views for typed consumers.
- Influence receipts, impact preview, correction, disable, expiry, archive,
  deletion, reset, migration, replay and offline behavior.
- Accessibility, privacy/security and direct-user evidence.

## Out of scope

- Hidden personality, aptitude, employability, health, wealth, relationship,
  commitment or universal person score/model.
- Unconfirmed inference from completion, delay, device use, calendar titles,
  location history, Proof, contacts, browsing or rejection.
- HealthKit, financial, contacts, location-history, calendar or third-party data
  imports; each requires separate integration authority.
- Public-source claim editing, eligibility/diagnosis/legal determination,
  automatic Goal/Step/Time mutation, external action or model training.
- Default prompt frequency/inference thresholds before v1 interaction evidence.

## Requirements

### REQ-001 — Facts are typed and user-owned
Every fact has category/type/value/range/unit, applicability, recurrence/effective
time, zone/locale as relevant, sensitivity, provenance, revision and status.

### REQ-002 — Unknown states remain distinct
Unknown, not included, declined, not applicable, unavailable, conflicting,
expired, disabled and deleted cannot become zero, false, unmet or negative fit.

### REQ-003 — Collection is progressive and contextual
Core value requires no profile setup. Capture explains immediate purpose and
fallback; optional fields can be skipped. System/import permissions are absent.

### REQ-004 — No fact is inferred without confirmation
Behavior/local-learning may create a disposable suggestion only under separately
evaluated policy. A fact exists only after visible user confirmation.

### REQ-005 — Purpose grants are field/category scoped
Use requires an allowlisted purpose grant with current revision/expiry.
On-device processing does not bypass it. Revoke blocks future reads immediately.

### REQ-006 — Sensitive facts receive strongest defaults
Health, disability, finance, legal, citizenship, family/relationship and exact
location are excluded by default, task-specific, locally protected and never
required for generic/manual value.

### REQ-007 — Consumers receive ephemeral minimum views
Typed clients request exact categories/purpose/revision and receive only allowed
facts plus explicit unknown/conflict states. They cannot enumerate the registry,
write facts, persist joined profiles or send views to public services.

### REQ-008 — Precedence and conflict are deterministic
Explicit exclusions/must-respect facts cannot be silently relaxed; task-specific
confirmed facts beat general preferences; conflicts yield visible alternatives
or clarification and list every affected decision.

### REQ-009 — Context never becomes authority
Facts inform proposals/simulations only. They do not establish public truth,
eligibility, diagnosis, safety, affordability or success, and cannot directly
mutate Goal/Path/Step/Time/Proof or external state.

### REQ-010 — Influence is inspectable
Every derived result reports used/not-used/excluded/expired/conflicting/missing
facts and their observable effect, with no opaque aggregate score.

### REQ-011 — Local overrides support what-if
Users can include/exclude/change a fact for one draft/simulation without editing
the registry, and can promote an override only through explicit fact editing.

### REQ-012 — Correction and impact preview are safe
Edit/disable/expire/delete shows exact saved drafts/accepted objects that may
need recomputation. The registry notifies; it never rewrites those owners.

### REQ-013 — Lifecycle and deletion are complete
Save/migrate/replay/archive/restore/reset/purge are atomic/idempotent. Deletion
removes facts, grants, indices, snapshots, influences, exports and continuity
copies in scope; deletion-terminal replay cannot restore them.

### REQ-014 — Time, money and units are stable
Use platform calendar/timezone/locale/currency/measurement identifiers and
versions. DST/zone/locale changes cause exact re-resolution, not silent drift.

### REQ-015 — Privacy-safe observability
Metrics/diagnostics contain category/purpose/state/reason and aggregate counts,
not values, notes, exact times/places, identity or joined private profiles.

### REQ-016 — Accessibility and dignity are mandatory
All values/states/purposes/influences/conflicts/controls have text and ordered
alternatives. Copy treats constraints as reality, never weakness or failure.

### REQ-017 — Calibration is evidence gated
Prompt defaults, suggestion thresholds and breadth roll out only after claim-
bound v1 scheduling/capability interaction and direct-user evidence; unavailable
calibration leaves manual capture intact.

## Acceptance criteria

- AC-001: all category fixtures round-trip typed units/time/revision/provenance.
- AC-002: every absence state remains distinct across consumers/rendering.
- AC-003: fresh install has no required profile and every capture is skippable.
- AC-004: behavior canary creates no fact without explicit confirmation.
- AC-005: expired/revoked/wrong-purpose grants return explicit unavailable.
- AC-006: sensitive fields are absent from generic contexts and still optional.
- AC-007: clients cannot enumerate/write/persist/egress joined context.
- AC-008: precedence/conflict fixtures never silently relax must-respect facts.
- AC-009: mutation spies prove no direct canonical/public/external changes.
- AC-010: every result exposes dimension-level context influence.
- AC-011: what-if overrides leave registry bytes unchanged unless promoted.
- AC-012: impact notification identifies dependents without rewriting them.
- AC-013: fault-injected purge is complete, resumable and deletion terminal.
- AC-014: DST/timezone/locale/currency changes re-resolve and explain impacts.
- AC-015: private value canaries occur nowhere in logs/metrics/diagnostics.
- AC-016: accessibility/device/language review covers all states and controls.
- AC-017: unproven suggestion/default policy stays disabled.

## Frontend impact contract

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: The approved requirements, acceptance criteria, and user flows own visible terminology and non-claims; implementation must localize that meaning without inventing promotional, score, authority, or outcome language.
- Accessibility: Every new child view and action must preserve the approved semantic order, Dynamic Type/reflow, assistive-input parity, non-color meaning, focus, announcements, and reduced-effects behavior.
- Visual proof: One production-intended native fixture and viewport requires owner visual approval before implementation, followed by changed-state runtime, screenshot, accessibility, and named-device evidence required by Verification.

## Canon impact

Add Personal Context Registry canon and update privacy/data classification,
permissions, local learning, planning/scheduling/simulation, private runtime,
trust inspection, degraded states, History/Receipts and deletion contracts.

## Risks and open decisions

No hard architecture fork remains. Default prompting and unconfirmed suggestion
policies are explicitly disabled pending named v1/user evidence; this does not
block manual context or typed consumer controls.

Review verdict: **PASS** after two reconciliation rounds. Review added purpose
grants even for on-device use, no-enumeration clients, task-local what-if,
timezone versioning and evidence-gated prompts. Devan delegated approval; Scope
approved 2026-08-04.
