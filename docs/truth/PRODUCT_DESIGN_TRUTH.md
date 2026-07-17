# PRODUCT_DESIGN_TRUTH.md — Ambitions Product Constitution / Design / Runtime Canon

**Canonical path:** `docs/truth/PRODUCT_DESIGN_TRUTH.md`
**Status:** Active product/design constitution; canonical product-source root
**Applies to:** native SwiftUI, iPhone-first, local-first Ambitions architecture
**Owner posture:** product constitution and implementation-shaping law, not implementation or release proof
**Last updated:** 2026-07-10
**Decision basis:** owner decisions `1–201`, including the 2026-07-09 owner-approved reconciliation amendment
**Mission lens:** read through `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`, the supreme mission canon

This file is the durable constitution for Ambitions product identity, information architecture, object law, user-visible runtime behavior, privacy/product boundaries, surface behavior, SwiftUI implementation direction, accessibility, validation obligations, and stable architecture ownership.

It is deliberately written for both humans and Codex. It defines the laws that downstream Linear projects, design documents, Codex leaves, source changes, tests, proof packets, and release claims must implement without re-deciding the product.

It does **not** prove that the current app implements these laws. Current source, tests, logs, screenshots, device evidence, known-issue state, and release evidence set the implementation claim ceiling.

---

## Codex digest

Read this file before work that touches:

- product identity or category,
- Today, Goals, Time, or You,
- Capture, Search, Motion, or Trust,
- Goal Path, scheduling, reflow, proof, closure, or recovery,
- object taxonomy or state transitions,
- account, CloudKit, R2, Source Atlas, permissions, notifications, import/export, or external calendars,
- SwiftUI shell, interaction, motion, haptics, accessibility, or visual quality,
- source ownership, architecture deletion/replacement, acceptance, or closeout.

This file owns:

- root product/design law,
- stable user-facing object law,
- persistent-surface and global-system ownership,
- Private Life Runtime product contract,
- calendar and external-import product contract,
- privacy/product and local-first boundaries,
- stable architecture owner map,
- constitutional acceptance and Codex-readiness rules.

This file does not own:

- implementation status,
- exact persistence schema,
- CloudKit record schema,
- R2 deployment configuration,
- mutable known-issue status,
- release readiness,
- legal approval,
- App Store readiness.

Hard red from this file alone:

- a fifth persistent surface,
- Capture or Motion as a root destination,
- private life graph egress to R2, Source Atlas, hosted AI, or an Ambitions backend,
- cloud/LLM dependency for core value,
- silent material mutation,
- a commodity task/calendar/dashboard/chatbot center,
- inaccessible spatial-only interaction,
- fake or fixture-only primary paths,
- a claim of Green without linked evidence.

### How Codex must consume laws

Stable law IDs are normative. Decision numbers are provenance only.

A Codex implementation leaf must name the laws it implements, the source owners it touches, the old authority it deletes or demotes, the validation it will run, and the proof artifacts it will produce.

Example:

```text
Implements: TODAY-001, TODAY-004, RUNTIME-MUTATION-001, A11Y-002
Source owners: Surfaces/Today, Core/LocalRuntimeOS/Projections, Quality
Deletes/replaces: <named old path or state>
Validation: <commands and suites>
Proof: <screenshots, logs, receipts, accessibility output>
```

---

# Article 0 — Authority, precedence, and amendment law

## AUTH-001 — Supreme mission precedence

`PRIVATE_LIFE_ORCHESTRATION_TRUTH.md` owns Ambitions' highest-order category, mission, app purpose, primary function, and orchestration loop.

This file must never be interpreted in a way that weakens:

```text
Intent
→ Context
→ Path
→ Time Fit / Placement
→ Reflow
→ Action
→ Closure / Proof
→ Learning
→ Recovery / Adaptation
```

## AUTH-002 — Product constitution authority

Within the mission lens, this file is authoritative for:

- product/design direction,
- root IA,
- persistent surfaces,
- product objects,
- user-visible runtime behavior,
- surface and shell law,
- privacy/product boundaries,
- stable architecture ownership,
- product-level acceptance.

## AUTH-003 — Decision integration and precedence

Owner decisions `1–201` are integrated into this constitution.

Precedence for product/design conflict is:

1. later explicit owner decisions and corrections,
2. this consolidated constitution,
3. older product/design amendments,
4. subordinate experience or implementation guidance,
5. historical lore and compatibility language.

A later product decision does not automatically weaken:

- the supreme mission,
- local-first or privacy boundaries,
- `Command → Event → Projection → Receipt → Replay`,
- user control and material-confirmation law,
- accessibility equivalence,
- evidence and Green-status discipline.

Those are constitutional invariants and require an explicit constitutional amendment to change.

## AUTH-004 — 2026-07-09 owner-approved reconciliation amendment

Five apparent conflicts are resolved as follows:

1. **Today remains the Reality Window.** The rolling `±24-hour` rail is supporting temporal anatomy, not the primary product identity.
2. **Saved for Later is a durable unresolved state.** It is not a Capture inbox, persistent destination, root surface, or Today backlog.
3. **Root navigation remains icon-only by default.** Visible labels may appear for onboarding, long press, accessibility, or evidence-backed comprehension fallback.
4. **External-event visibility and capacity awareness are separate.** An external item may remain hidden from primary Time while still reserving capacity unless the user explicitly chooses `Ignore for planning`.
5. **User-facing and runtime hierarchies remain distinct.** The visible hierarchy stays plain and simple; the richer runtime continuity remains constitutional internal law.

These reconciliations supersede conflicting literal wording in Decisions `1–201` without weakening their intended capability.

## AUTH-005 — Relationship to other truth files

- `PRIVATE_LIFE_ORCHESTRATION_TRUTH.md` — supreme mission and primary-function lens.
- `PRODUCT_ORIGIN_TRUTH.md` — origin/problem doctrine.
- `PRODUCT_MOAT_TRUTH.md` — moat and anti-commodity strategy.
- `PRODUCT_EXPERIENCE_CANON.md` — subordinate feature-behavior and scenario detail; it may not override this file.
- `IMPLEMENTATION_TRUTH.md` — current source and implementation-status authority.
- `IMPLEMENTATION_ACCEPTANCE_TRUTH.md` — rendered product and shell acceptance authority.
- `RELEASE_TRUTH.md` — validation, proof, release, and claim authority.
- `CODEX_PROCESS_TRUTH.md` — Codex operating process.
- `docs/truth/2026-06-22-runtime-remediation-decision-register.md` and `docs/qa/remediation/2026-06-22-codex-remediation-law.md` — retained subordinate remediation history and execution law where not superseded here.


## AUTH-005A — Normative engineering annex binding

`docs/constitution/ENGINEERING_CONSTITUTION.md`, its Article `25–43` files under `docs/constitution/articles/`, and the machine-readable registries named by that annex are a **normative subordinate part of this Ambitions Product Constitution**.

The binding order is:

```text
PRIVATE_LIFE_ORCHESTRATION_TRUTH.md
→ PRODUCT_DESIGN_TRUTH.md
→ ENGINEERING_CONSTITUTION.md + Articles 25–43
→ machine-readable constitutional registries
→ Project design specifications
→ Parent Feature acceptance objects
→ Codex implementation leaves
→ live source, tests, proof, and release evidence
```

The engineering annex may add implementation specificity, measurable obligations, source/test/proof routing, and fail-closed enforcement. It may not weaken or reinterpret the parent product law, root IA, privacy boundary, local-first runtime law, user-control law, accessibility equivalence, or proof ceiling.

The following files are constitutionally required while this binding is active:

- `docs/constitution/ENGINEERING_CONSTITUTION.md`
- exactly one Article file for each Article `25–43`
- `docs/constitution/opportunity-register.json`
- `docs/constitution/laws.json`
- `docs/constitution/law-source-map.json`
- `docs/constitution/law-test-map.json`
- `docs/constitution/scenarios.json`
- `docs/constitution/performance-budgets.json`
- `docs/constitution/data-classification.json`
- `docs/constitution/dependency-graph.json`
- `scripts/ambitions-constitution-audit.py`

A missing, malformed, duplicated, cyclic, orphaned, or internally inconsistent constitutional registry is a hard Red for constitutional integrity. It blocks constitutional Green, affected `Spec Ready` promotion, and unsupported implementation claims; it does not by itself assert runtime or release failure.

Changes to the annex or registries require the amendment, independent-review, audit, proof, and rollback rules in Articles `42–43`. Current implementation and release claims remain governed by live evidence, `IMPLEMENTATION_TRUTH.md`, `IMPLEMENTATION_ACCEPTANCE_TRUTH.md`, and `RELEASE_TRUTH.md`.

## AUTH-006 — Claim discipline

Canon is not proof.

Allowed from this file alone:

- intended product law,
- intended object and surface ownership,
- required behavior and quality bar,
- required architecture boundaries,
- required validation categories.

Not allowed from this file alone:

- implementation Green,
- build or test Green,
- visual Green,
- accessibility Green,
- physical-device Green,
- privacy/legal approval,
- production CloudKit or R2 readiness,
- TestFlight or App Store readiness,
- total product completion.

---

# Article 1 — Locked product law

## IA-ROOT-001 — Persistent surfaces

Ambitions has exactly four persistent root surfaces:

```text
Today / Goals / Time / You
```

No fifth persistent surface is allowed.

## IA-GLOBAL-001 — Global composer

Ambitions has one global composer:

```text
Capture
```

Capture is not a tab, destination, inbox, or permanent root state.

## IA-MOTION-001 — Motion ownership

Motion is cross-surface behavior. It is not a root destination or content category.

## IA-TRUST-001 — Trust ownership

Trust is inspectable and contextual:

```text
Proof / Source / Privacy / History / Receipts
```

Trust details support the changed object. They do not replace the object or become persistent global chrome.

## IA-STAGE-001 — One native Stage

Ambitions presents one native object Stage with adaptive root and drilldown composition.

The user sees life objects, not implementation architecture.

## IA-ACTION-001 — Every meaningful action must become real

Every meaningful accepted user action must produce, as applicable:

```text
validated command
local runtime mutation
visible object/stage mutation
accessible state change
receipt or history evidence
safe fallback or rollback plan
```

A control that does not perform its represented action is a hard red.

## IA-OFFLINE-001 — Offline core

Core Today, Goals, Time, Capture, Search, proof, closure, and local history remain usable without account sign-in and without network access.

## IA-NAMING-001 — Plain-native primary language

Persistent root labels are only:

```text
Today / Goals / Time / You
```

The following may describe internal design/runtime concepts but must not become root labels or exposed architecture language:

- Reality Window,
- Life Area Atlas,
- Life Calendar,
- Goal Thread,
- Runtime,
- Projection,
- Event Journal,
- Command Spine,
- Source Atlas,
- Stage OS,
- Lens,
- Kernel,
- Ledger,
- Policy.

The object experience may embody those concepts without naming them to the user.

---

# Article 2 — Strategic product identity and promise

## MISSION-001 — Product category

Ambitions is a premium native iPhone-first, local-first **Personal Life OS** for contextual life orchestration.

It converts life intent into adaptive, scheduled, recoverable progress while keeping personal intelligence private, inspectable, and user-controlled.

## MISSION-002 — Product thesis

```text
Ambitions helps life make sense, then helps the user start what fits.
```

## MISSION-003 — Integrated product promise

Ambitions helps the user:

1. place life input somewhere safe,
2. understand what reality can hold,
3. connect direction to a living path,
4. place the next action into time,
5. start what fits now,
6. adjust without losing the thread,
7. close loops without shame,
8. preserve proof of meaningful progress,
9. recover when capacity changes,
10. remain in control of the system.

## MISSION-004 — Capability without category collapse

Ambitions may contain best-in-class behavior from task, calendar, reminder, planning, habit/ritual, notes, proof, and executive-assistant categories.

Those capabilities serve one orchestration loop. They must not become separate apps inside Ambitions.

## MISSION-005 — Anti-commodity law

Ambitions is not centered as:

- a task app,
- a calendar clone,
- a habit tracker,
- a chatbot,
- a dashboard,
- a generic AI planner,
- a notes app,
- a productivity score,
- a streak system,
- a web-app shell.

Task-grade and calendar-grade capability are required. Commodity product framing and commodity information architecture are forbidden.

---

# Article 3 — Private Life Runtime constitution

## RUNTIME-INTELLIGENCE-001 — Intelligence loop

The Private Life Runtime must connect:

```text
Intent
→ Context
→ Path
→ Placement / Time Fit
→ Action
→ Closure / Proof
→ Learning
→ Reflow / Recovery
```

The loop is user-visible through practical object behavior, not an intelligence dashboard.

## RUNTIME-MUTATION-001 — Safe mutation loop

No meaningful Ambitions state change may bypass:

```text
Command → Event → Projection → Receipt → Replay
```

Every parser, planner, scheduler, search action, App Intent, widget action, Share intake, import action, automation, and recovery operator must route through the same mutation law.

## RUNTIME-LOCAL-001 — Local deterministic core

Core pathing, placement, reflow, learned behavior, proof, closure, Search, and object projections must be local, deterministic, replayable, and inspectable.

External services may assist with approved non-core public/reference tasks. They may not be required for the core loop.

## RUNTIME-VISIBILITY-001 — Quiet but inspectable intelligence

Allowed primary explanations are practical and object-specific, for example:

- `Fits better at 3:30`,
- `Shorter version suggested`,
- `Moved from 2:00`,
- `This path changed after reality changed`,
- `Proof required before completion`,
- `Three flexible items moved because the morning filled up`.

Deeper rationale is inspectable on demand.

Forbidden primary framing includes:

- model confidence,
- AI memory dashboards,
- productivity grades,
- intelligence scores,
- hidden learning,
- uncorrectable personalization,
- streak pressure.

## RUNTIME-AUTOMATION-001 — Automation ladder

Per-goal automation levels are:

- Manual,
- Suggest Only,
- Auto Minor,
- Adaptive with Confirmations.

Global defaults live in You. Per-goal overrides live in Goal detail.

## RUNTIME-AUTOMATION-002 — Minor versus material boundary

Minor changes may include:

- reordering unscheduled upcoming work,
- resizing a suggested duration,
- adding optional preparation substeps,
- changing reminder recommendations,
- changing a suggested placement before commitment.

Material changes include any change to:

- Today or Time commitments,
- scheduled dates or times,
- due dates,
- recurrence,
- notifications,
- protected or fixed boundaries,
- required steps,
- goal completion criteria,
- external writes,
- deletion or irreversible data scope.

Material changes require confirmation unless an explicit user rule permits the exact class of change.

## RUNTIME-LEARNING-001 — Learned completion behavior

Ambitions may learn locally from:

- timing,
- step shape and duration,
- context,
- reminder tolerance,
- proof friction,
- reschedule behavior,
- completion patterns,
- explicit corrections.

Learning must remain inspectable, editable where appropriate, reversible through correction, and free from shame or scoring.

## RUNTIME-REFLOW-001 — Reflow is core

Reflow is a primary differentiator, not a convenience feature.

When new intent, a new scheduled item, changed capacity, proof, completion, missed work, an external import, or explicit correction changes reality, Ambitions must evaluate:

- what is Protected,
- what is Fixed,
- what is Flexible,
- what remains Suggested,
- what can move,
- what can shrink,
- what should defer,
- what needs recovery,
- what consequence requires confirmation.

## RUNTIME-REFLOW-002 — Inspectable change set

A material reflow produces an inspectable change set containing, as applicable:

```text
trigger
new or changed object
proposed placement
objects moved
objects resized
objects deferred
protected boundaries preserved
conflicts avoided or accepted
rationale
user confirmation state
receipt
rollback or undo plan
```

No material reflow may occur silently.

## RUNTIME-EXTERNAL-001 — External side-effect ordering

Local validated commit precedes external write attempt.

EventKit, notifications, widgets, App Intents, Share intake, exports, and future approved external effects must use an outbox/reconciliation boundary with durable result state.

External failure must not erase or corrupt the accepted local intent.

---

# Article 4 — Object constitution

## OBJECT-HIERARCHY-001 — User-facing hierarchy

The plain user-facing hierarchy is:

```text
Life Area
→ Goal
→ Goal Path
→ Step
→ Substep
```

Events, Reminders, Notes, Proof, and Attachments link into this ecology without becoming artificial hierarchy layers.

## OBJECT-HIERARCHY-002 — Runtime continuity hierarchy

The richer internal continuity remains:

```text
Identity Direction
→ Life Area
→ Goal Thread
→ Commitment / Step
→ Placement
→ Closure Event
→ Proof
→ Reflection
→ Learning Record
→ Adaptation / Recovery
```

The visible hierarchy may simplify this model. Source and persistence design must preserve the continuity required for proof, learning, replay, recovery, and inspection.

## OBJECT-IDENTITY-001 — One canonical identity

One real-world Ambitions object has one canonical identity.

Today, Goals, Time, Search, widgets, App Intents, receipts, and history are projections of that identity. They must not create independent duplicate objects to represent the same thing.

## OBJECT-OWNER-001 — Canonical owner law

Each object family has one canonical mutation owner and may have multiple read projections.

A projection may not mutate its own copy. It must issue a command against the canonical object owner.

## OBJECT-STATE-001 — Orthogonal state axes

Do not compress unrelated state into one overloaded enum.

Where applicable, model separate axes for:

1. **Lifecycle** — draft, active, completed, archived, trashed.
2. **Placement** — unplaced, suggested, scheduled, occurring, past.
3. **Time authority** — Protected, Fixed, Flexible, Suggested.
4. **Execution** — ready, in progress, waiting, blocked, deferred.
5. **Proof** — none, optional, suggested, required, satisfied.
6. **Recovery** — healthy, needs attention, recovering, recovered.
7. **External source** — none, candidate, linked, imported, source changed, source unavailable.
8. **Sync** — local only, pending, synced, conflicted, quarantined.
9. **Automation** — manual, suggest only, auto minor, adaptive with confirmations.

UI may summarize these axes into humane states. Domain and runtime code must preserve their distinctions.

## OBJECT-DEFINITION-001 — Life Area

A Life Area is a broad, editable organizing region for direction, goals, proof, recovery, and related context.

It is not a score category or dashboard metric.

## OBJECT-DEFINITION-002 — Goal

A Goal is a meaningful outcome with:

- intent and direction,
- a living Goal Path,
- lifecycle,
- schedule relationship,
- proof and closure rules,
- recovery behavior,
- optional automation policy.

## OBJECT-DEFINITION-003 — Goal Path

A Goal Path is the inspectable living route from current reality to goal closure.

It carries planned movement, completed movement, proof, recovery, schedule changes, decisions, and adaptive revisions.

## OBJECT-DEFINITION-004 — Step

A Step is an executable unit of progress sized to real capacity.

It may be free-floating or belong to one primary Goal. It may have duration, due date, placement, substeps, reminders, attachments, notes, proof rules, and recovery state.

## OBJECT-DEFINITION-005 — Substep

A Substep is preparation, detail, or checklist content under a Step.

It is not independently scheduled until explicitly promoted to a Step through preview and receipt.

## OBJECT-DEFINITION-006 — Event

An Event is a time-range commitment or occurrence. It reserves time and may carry:

- location,
- recurrence,
- time-zone semantics,
- attendees and organizer metadata,
- notification rules,
- goal/context links,
- provenance.

## OBJECT-DEFINITION-007 — Reminder

A Reminder is a return point that asks the user to remember or act.

It does not reserve duration unless explicitly converted to or paired with a Step/Event.

## OBJECT-DEFINITION-008 — Note

A Note is context without inherent execution, duration, or completion law.

## OBJECT-DEFINITION-009 — Proof

Proof is user-approved evidence attached to a Step, Goal, Event, Closure, or meaningful path moment.

Proof may be optional, suggested, or required. Required proof must be visible before completion, not introduced as a surprise at the final action.

## OBJECT-DEFINITION-010 — Receipt

A Receipt is an append-only user-inspectable record of a meaningful accepted mutation, including:

- creation,
- import,
- placement,
- reflow,
- completion,
- proof,
- closure,
- conversion,
- export,
- delete/restore,
- external-write result.

## OBJECT-DEFINITION-011 — Placement

A Placement is the relationship between an object and time reality. It records time range, time authority, reflow rule, source rationale, and relevant constraints.

## OBJECT-DEFINITION-012 — Schedule change set

A Schedule Change Set is a proposed or accepted group of placement changes with rationale, affected objects, confirmation state, receipt, and rollback context.

## OBJECT-DEFINITION-013 — External calendar candidate

An External Calendar Candidate is an external item awaiting user review. It is not an Ambitions Event and must not appear as one before import.

## OBJECT-DEFINITION-014 — Capture draft

A Capture Draft is durable unresolved input. It survives interruption, crash, permission denial, attachment failure, and validation failure.

## OBJECT-CONVERSION-001 — Explicit conversion

Compatible conversions require preview, field-impact summary, and receipt.

Required conversion coverage includes at least:

- Reminder → Step,
- Reminder → Event,
- Step → Event,
- Event → Step where semantically valid,
- Substep → Step,
- Note → Proof,
- Capture Draft / Saved for Later → typed object.

A conversion must define:

- retained fields,
- dropped fields,
- schedule consequences,
- recurrence consequences,
- notification consequences,
- goal/proof consequences,
- identity and history behavior,
- undo/rollback behavior.

No object changes type silently.

## OBJECT-LINK-001 — Goal linkage

A Step may have one primary Goal. Events and Reminders may link to Goals without becoming Goal-owned Steps.

Contextual secondary links may exist but must not create duplicate identity or ambiguous mutation ownership.

## OBJECT-DELETE-001 — Delete, Trash, restore

Where technically feasible:

- recent lightweight mutations offer undo,
- delete moves to Trash,
- permanent deletion requires explicit confirmation,
- parent deletion previews dependent consequences,
- recurring deletion requires scope selection,
- unlinking external provenance does not delete an Ambitions-native object,
- restore creates history and revalidates projections.

---

# Article 5 — Shared time constitution

## TIME-SEMANTIC-001 — Unequal time

Ambitions does not treat all time as equivalent.

Every scheduled placement may carry one time-authority state:

- **Protected** — boundary Ambitions must not violate by default.
- **Fixed** — committed time; exact placement matters.
- **Flexible** — scheduled but movable within explicit rules.
- **Suggested** — proposed placement not yet committed.

## TIME-SEMANTIC-002 — Per-item reflow rules

Supported rules:

- Never move,
- Ask before moving,
- Auto-move within day,
- Auto-move within week,
- Suggest only.

## TIME-SEMANTIC-003 — Defaults

Default policy:

- Ambitions-created Event → Fixed,
- imported Event → Fixed,
- explicit protected block → Protected,
- scheduled Step → Flexible,
- scheduled Reminder → Flexible,
- placement proposal → Suggested.

The user may override defaults during creation, import, or edit.

## TIME-SEMANTIC-004 — Conflict authority

- Protected time is never violated by default.
- Fixed time requires explicit override or scoped editing.
- Flexible time may move only within its rule.
- Suggested time may be edited or rejected before commitment.

The best safe placement is shown first. Tradeoffs appear when requested or when no safe placement exists.

---

# Article 6 — Shell and navigation constitution

## SHELL-001 — Root navigation

The root dock contains four icon-only root controls for Today, Goals, Time, and You.

Visible labels may appear only for:

- onboarding/education,
- long-press disclosure,
- accessibility presentation,
- evidence-backed fallback when symbol comprehension fails.

The root dock appears only at root and dissolves or leaves in drilldowns, full-screen Capture, deep inspection, and appropriate deep Time states.

## SHELL-002 — Capture and Search access

Capture and Search are available through integrated root chrome and contextual actions. They are not persistent fifth/sixth tab controls.

## SHELL-003 — Full-screen integration

The shell is a product layer, not a border around the product.

- atmosphere may bleed full-screen,
- content respects safe areas,
- chrome integrates with the active surface,
- no boxed header or bordered dock,
- no pasted-on material capsules,
- no detached web-app chrome.

## SHELL-004 — Drilldown law

Drilldowns use native back behavior, predictable gesture return, focus restoration, and no persistent root dock.

Use object transforms where they preserve continuity. Prefer native push or sheet where transformation would reduce clarity or accessibility.

## SHELL-005 — Platform ownership

SwiftUI-native navigation, controls, materials, accessibility, and presentation are the default.

Custom Stage, UIKit, Canvas, Metal, or custom gesture infrastructure must prove that a native API cannot satisfy the required behavior and must include semantic and reduced-motion equivalents.

---

# Article 7 — Today constitution

**Decision provenance:** `4`, `11–14`, `53–54`, `96–108`, owner reconciliation amendment `1`.

## TODAY-001 — Product identity

Today is the **Reality Window**.

It answers:

```text
What can reality hold around now, and what should I act on next?
```

Today is not a planner, full calendar, task backlog, dashboard, generic timeline, recommendation feed, or CTA stack.

## TODAY-002 — First viewport law

The first viewport must communicate, when available:

- Now,
- usable capacity,
- one Start Here Step/action,
- protected boundaries,
- next fixed point,
- why the Step fits,
- current closure, proof, or recovery state.

The Start Here object is not merely a visually enlarged task row. It represents the current best executable fit within real constraints.

## TODAY-003 — Supporting temporal rail

A rolling `±24-hour` execution rail supports the Reality Window:

- 24 hours of prior context,
- 24 hours of upcoming context,
- anchored around Now,
- populated or important hours expand,
- empty stretches compress,
- Now is visually and semantically strongest,
- Next is secondary.

The rail may never replace the Reality Window as the primary product identity.

## TODAY-004 — Eligibility

Today may project only execution-relevant objects:

- scheduled Steps,
- Reminders,
- Events,
- all-day items,
- due items,
- recovery-eligible flexible work,
- one earned fit suggestion.

Today must not project:

- broad backlog,
- unscheduled Goal inventory,
- future project lists,
- Saved for Later inventory,
- unreviewed external calendar candidates.

## TODAY-005 — Object presentation

A shared native object-row system may include:

- time,
- title,
- primary action,
- lifecycle/placement summary,
- goal context,
- trust marker when relevant.

Now and Start Here are strongest. Protected and Fixed feel anchored. Flexible, Suggested, and Recovery states feel lighter. Completed objects collapse without disappearing from history.

## TODAY-006 — Interaction

- explicit primary action on the object,
- tap opens detail,
- swipe supports lightweight reversible actions,
- long press opens contextual actions,
- low-risk single-object rescheduling may use a compact sheet,
- drag, resize, recurrence, protected/fixed conflict, multi-item reflow, and long-range editing hand off to Time.

## TODAY-007 — Completion and closure

Completion is:

- immediate for simple objects,
- receipt-backed,
- proof-aware,
- undoable for a short safe window,
- reflected in the linked Goal Path,
- announced accessibly.

Closure controls appear only when a real Step is started or proof-eligible. Generic fake closure is forbidden.

## TODAY-008 — Fit suggestion threshold

At most one quiet fit suggestion may appear, and only when all required conditions pass:

- duration fit,
- transition buffer,
- protected/fixed boundaries,
- upcoming-event risk,
- deadline safety,
- learned completion likelihood,
- step shape/context fit,
- a plain user-facing reason.

Primary action may adapt to the object: Start, Schedule, Pay, Call, Write, Add proof, Resume.

Secondary actions:

- Why here,
- Alternatives,
- Dismiss,
- Not today.

## TODAY-009 — Empty and degraded states

A low-density or empty Today remains calm.

Allowed secondary actions:

- Capture,
- View Time,
- Review Goals.

Do not fill space with backlog or low-confidence suggestions.

Offline local Today remains functional. Stale external data is disclosed only when it changes interpretation.

### Today implementation obligations

Primary source owners:

```text
Native/Ambitions/Surfaces/Today/
Native/Ambitions/Core/LocalRuntimeOS/Projections/
Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/
Native/Ambitions/Core/LocalRuntimeOS/Scheduling/
Native/Ambitions/Quality/
```

Required proof:

- first-viewport screenshots across density and accessibility matrices,
- semantic ordering and VoiceOver actions,
- fit-threshold unit/scenario tests,
- completion/receipt/replay integration,
- reduced-motion and focus-restoration proof,
- no-backlog and no-external-candidate projection tests.

---

# Article 8 — Goals and Goal Path constitution

**Decision provenance:** `5`, `15–20`, `47–55`, `72–79`, `109–124`, owner reconciliation amendment `5`.

## GOALS-001 — Product identity

Goals is the life-area-first direction and living-path system.

It answers:

```text
What am I building, where am I on the path, and what is the next meaningful movement?
```

## GOALS-002 — Goals root

Goals opens to a premium native life-area index.

Each Life Area may show:

- current movement,
- next movement,
- active Goal count,
- proof or recovery status,
- quiet path health.

Life Areas can be renamed, reordered, hidden, and restored.

The root must not become a dashboard or metrics grid.

## GOALS-003 — Life-area detail

A Life Area operating page includes:

- current direction,
- active Goals,
- next movement,
- proof/recovery status,
- completed and archived Goals,
- contextual actions.

## GOALS-004 — Goal detail first viewport

Goal detail opens as an object operating page with:

- title and humane lifecycle state,
- current route,
- next movement,
- proof requirement/state,
- schedule fit,
- compact Goal Path preview.

Metadata remains accessible but does not dominate.

## GOALPATH-001 — Living proof path

The user-visible Goal Path is a living proof trail with forward motion.

It may show:

- planned Steps,
- completed Steps,
- reality-changed/recovered Steps,
- Proof Moments,
- Schedule Changes,
- Adaptive Changes,
- Closure Moments.

It must feel adult, premium, personal, and alive without points, levels, badges, quest language, or streak pressure.

## GOALPATH-002 — Adaptive strategy underneath

The runtime maintains an adaptive strategy path beneath the visible proof path.

Triggers include:

- new or changed intent,
- missed or deferred work,
- time reality,
- new scheduled Steps,
- proof/completion,
- learned behavior,
- explicit correction.

Minor changes may auto-apply with receipt. Material changes require confirmation according to automation law.

## GOALPATH-003 — Path interaction

The full path is a horizontal native path rail with:

- current position anchored,
- snap-to-node,
- haptic selection,
- selected-node detail below or in a sheet,
- jump controls for Start, Now, Next, Finish,
- filters for Chronology, Proof, Recovery, Schedule, Receipts.

It must not resemble a project-management Gantt chart.

## GOALPATH-004 — Node taxonomy

Supported semantic nodes:

- Start,
- Current Position,
- Next Movement,
- Step,
- Substep Group,
- Proof Moment,
- Recovery Segment,
- Schedule Change,
- Adaptive Change,
- Decision Point,
- Pause,
- Resume,
- Closure.

Meaning uses shape, weight, material, micro-symbol, line treatment, and sparse semantic color. Color may not be the sole carrier.

## GOALS-005 — Generated route review

Creating a Goal may generate an inspectable draft route containing:

- assumptions,
- milestones,
- Steps,
- Substeps,
- proof rules,
- schedule suggestions,
- automation level.

The review is a first-class native surface. The user can approve, edit, remove, regenerate, or save as draft.

Nothing material is scheduled without confirmation.

## GOALS-006 — Activation

Activation:

- creates the Goal,
- records an activation receipt,
- opens Goal detail,
- highlights Current Position and Next Movement,
- shows accepted schedule placements,
- offers contextual handoff to Today or Time.

## GOALS-007 — Lifecycle and advisory state

User-controlled lifecycle states include:

- Draft,
- Ready to Activate,
- Active,
- Paused,
- Completed,
- Archived,
- Ended.

Advisory runtime states include:

- Needs Attention,
- Recovering,
- Waiting,
- Blocked.

Internal state may be more precise. Default user-facing copy must remain humane and follow `Copy and State Language` authority; internal enum names must not leak automatically.

## GOALS-008 — Recovery packet

When attention or recovery is needed, present:

- what changed,
- why attention is needed,
- recommended next movement,
- route impact,
- schedule impact,
- proof gaps,
- one clear recovery action.

## GOALS-009 — Closure

Goal closure is a first-class native surface containing:

- final status,
- completed path,
- Proof Moments,
- recovery segments,
- remaining open objects,
- schedule cleanup,
- final receipt,
- optional reflection,
- next direction.

Actions may include Close, Archive, Continue, or Create follow-up Goal.

### Goals implementation obligations

Primary source owners:

```text
Native/Ambitions/Surfaces/Goals/
Native/Ambitions/Core/Domain/
Native/Ambitions/Core/LocalRuntimeOS/Planning/
Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/
Native/Ambitions/Core/LocalRuntimeOS/Scheduling/
Native/Ambitions/Core/LocalRuntimeOS/Inspection/
Native/Ambitions/Quality/
```

Required proof:

- generated-route fixtures with assumptions and material confirmations,
- path-node semantic and accessibility tests,
- minor/material adaptation tests,
- recovery and closure scenario tests,
- proof/receipt/replay continuity,
- screenshot and Dynamic Type matrices for root, detail, path, recovery, closure.

---

# Article 9 — Time constitution

**Decision provenance:** `6`, `21–28`, `53`, `80–86`, `101`, `125–166`.

## TIME-001 — Product identity

Time is Ambitions' native Life Calendar and full temporal operating surface.

It answers:

```text
How is my time arranged, what is protected or fixed, what can move,
and what happens when reality changes?
```

It must be calendar-grade, Apple-native, obvious, editable, and enriched by Ambitions semantics. It is not an anti-calendar and not a calendar clone whose value stops at event display.

## TIME-002 — Landing and navigation

- restore the last-used view,
- anchor around today/now unless the user intentionally browsed elsewhere,
- provide a visible Today control,
- use a discoverable segmented switcher for Day, Week, Month, Year, List,
- gestures may accelerate but never become the only path.

## TIME-003 — Day view

Native vertical day grid with:

- current-time marker,
- all-day rail,
- Events,
- Steps,
- Reminders,
- Protected/Fixed/Flexible/Suggested semantics,
- goal context,
- subtle proof/reflow markers,
- direct manipulation where valid.

## TIME-004 — Week view

Native week grid with:

- protected blocks,
- fixed Events,
- flexible work,
- suggestions,
- goal-linked Steps,
- conflict pressure,
- recovery pockets,
- capacity density,
- proof/reflow semantics.

## TIME-005 — Month view

Native month grid optimized for scanability, showing semantic day summaries such as:

- density,
- protected-heavy days,
- Goal movement,
- recovery days,
- proof days,
- conflicts,
- scheduled Step presence.

Do not attempt to render every object.

## TIME-006 — Year view

High-level annual overview showing:

- monthly density,
- protected-time seasons,
- Goal movement arcs,
- recovery-heavy periods,
- completion/proof clusters,
- conflict pressure,
- scheduled Step concentration.

Granular objects require drilldown.

## TIME-007 — List view

List is the chronological semantic and screen-reader-friendly counterpart to the grids.

It includes:

- time/date,
- object identity,
- Protected/Fixed/Flexible/Suggested state,
- Goal context,
- due/recovery/proof state,
- compact conflict/reflow markers.

It is not a second Today. Today prioritizes execution fit around Now; Time List prioritizes complete temporal navigation and search across ranges.

## TIME-008 — Direct manipulation

Day and Week support drag and resize for editable objects.

- Protected, Fixed, recurring, imported-linked, and external-effectful changes require confirmation or scoped editing.
- Flexible and Suggested placements move only within their rules.
- conflict and reflow consequences appear before commit.

Simple reflow uses inline ghost preview. Complex, grouped, cross-day, or multi-day reflow uses a compact confirmation surface with inspectable detail.

## TIME-009 — Conflict preview

Conflict feedback distinguishes:

- Protected conflict,
- Fixed conflict,
- Flexible displacement,
- deadline risk,
- recurrence impact,
- external-write impact,
- reflow impact.

A move commits only when valid or explicitly confirmed.

## TIME-010 — Object detail

Tap opens compact native detail with, as applicable:

- title,
- time/date,
- all-day/multi-day state,
- time zone,
- location,
- notes/attachments,
- recurrence,
- notification rules,
- time-authority state and reflow rule,
- Goal link,
- proof/reflow state,
- provenance,
- edit actions.

Use full-screen detail only when object depth requires it.

## TIME-011 — Creation

Tap or long-press an empty slot to create Event, Step, or Reminder with date/time prefilled.

Event is the default type for empty-slot creation. Type remains visible and changeable. Creation routes through the same command/object model as Capture. New objects are Ambitions-owned canonical Time objects by default; any explicit Apple Calendar write is an external side effect and does not create a second canonical identity.

## TIME-012 — All-day and multi-day

All-day Events:

- appear in Day/Week all-day rail,
- influence Month/Year semantics,
- appear in List,
- do not consume hourly capacity by default.

Capacity choices:

- No capacity impact,
- Light context marker,
- Protected day,
- Reduces available working time.

Multi-day Events remain one canonical object with one identity, recurrence relationship, and receipt chain. Day shows the relevant segment; Week/Month show continuous span; List shows the full range.

## TIME-013 — Time zones

Preserve authored time-zone semantics.

- floating local-time stays floating,
- zone-bound stays zone-bound,
- device/travel changes do not silently shift intent,
- wall-clock changes are previewed,
- relevant Detail exposes zone,
- secondary-zone ruler may appear when useful.

## TIME-014 — Reminder behavior

A Reminder may carry date, time, location, recurrence, urgency, notes, and notification rules.

It does not reserve duration unless explicitly converted or scheduled as a Step/Event.

- timed Reminder appears at trigger point,
- date-only Reminder appears in date/all-day rail,
- conversion uses preview and receipt.

## TIME-015 — Search and filters

Time search is local and object-first.

Searchable data may include title, notes, location, attendee/organizer metadata, Goal link, recurrence, date range, time-authority state, proof/receipt metadata, and provenance.

Filters may include object type, time-authority state, Goal, date range, conflict, proof, and provenance. Filters must remain discoverable without permanently occupying the calendar viewport.

## TIME-016 — Export and interoperability

Support user-controlled export of single object, range, calendar, or filtered set.

ICS-compatible export preserves, where applicable:

- recurrence and exceptions,
- time zones,
- all-day/multi-day state,
- notes,
- location,
- alerts,
- source metadata safe for export.

Export requires preview for sensitive content and creates a receipt.

## TIME-017 — Empty, permission, stale, and failure states

Time must distinguish:

- genuinely empty,
- calendar permission denied,
- notification permission denied,
- external source stale,
- external diff pending,
- import failure/partial import,
- sync pending/conflict,
- local store degraded.

Local Ambitions-owned Time remains usable when external sources are unavailable.

## TIME-018 — Calendar-grade acceptance

Time is not accepted until it proves:

- Day/Week/Month/Year/List,
- real-time marker,
- all-day/multi-day,
- recurrence and exceptions,
- time zones,
- direct manipulation,
- conflict/reflow preview,
- create/edit/delete/restore,
- search/filter,
- import/export,
- notifications,
- accessibility equivalence,
- offline local use.

---

# Article 10 — External calendar migration constitution

**Decision provenance:** `138–159`, owner reconciliation amendment `4`.

## TIME-IMPORT-001 — Product posture

Apple Calendar and other approved calendar sources are onboarding, migration, and external-change sources.

Ambitions Time is the primary planning and execution calendar for Ambitions-owned objects.

External calendar services may remain necessary for organizer-controlled invitation administration until Ambitions explicitly owns that capability.

## TIME-IMPORT-002 — Guided migration

Migration is user-initiated and reviewable:

1. request permission in context,
2. select calendars,
3. select date range/categories,
4. scan and preview,
5. identify duplicates, recurrence, notification, conflict, and capacity impact,
6. allow per-item or scoped decisions,
7. confirm accepted change set,
8. create Ambitions-native objects and import receipts.

No immediate blind bulk import.

## TIME-IMPORT-003 — Candidate visibility

External candidates do not appear as Ambitions Events in primary Time until imported.

A Time toolbar action carries a badge for unreviewed external diffs:

- new,
- changed,
- removed.

Reviewed, rejected, and ignored candidates do not count.

## TIME-IMPORT-004 — Visibility versus planning capacity

External candidate visibility and capacity awareness are separate.

A candidate may remain hidden from primary Time while still reserving planning capacity if the user chooses `Keep external but reserve time`.

Required review outcomes:

- **Import into Ambitions** — create canonical Ambitions object.
- **Keep external but reserve time** — no native Event UI; capacity remains unavailable.
- **Ignore for planning** — do not reserve capacity.
- **Reject permanently** — dismiss current candidate lineage unless a materially new external item appears.

The earlier generic `Keep external` action is superseded by these explicit semantics.

## TIME-IMPORT-005 — Impact-first review

Group review by schedule impact:

- Needs attention,
- Safe to import,
- Duplicate/link candidates,
- Removed source,
- Ignored history.

Show:

- diff type,
- duplicate matches,
- source mapping,
- affected Ambitions objects,
- conflict/reflow consequences,
- notification risk,
- recurrence scope,
- capacity impact,
- proposed action.

## TIME-IMPORT-006 — Import action semantics

- **Import** — creates Ambitions-owned object with provenance and receipt.
- **Replace** — resolves a duplicate by preserving one canonical Ambitions identity.
- **Link** — retains external authority and attaches Ambitions context without creating a second canonical Event.
- **Keep external but reserve time** — external authority, hidden primary UI, planning capacity reserved.
- **Ignore for planning** — no native object and no capacity reservation.
- **Reject permanently** — store dismissal lineage and remove badge contribution.

## TIME-IMPORT-007 — Conflict and reflow

Before commit show:

- conflicting objects,
- Protected/Fixed boundaries,
- available reflow,
- downstream Goal/deadline impact,
- notification and external-write impact.

Choices may include:

- Import and reflow,
- Import without reflow,
- Edit before import,
- Keep external but reserve time,
- Ignore for planning,
- Reject.

No import silently reflows Ambitions-owned objects.

## TIME-IMPORT-008 — Imported ownership

After import, the object is an Ambitions-native Event and defaults to Fixed.

The user may promote it to Protected or change its reflow rule.

Provenance remains inspectable in Detail but does not appear as permanent source chrome.

Product law does not prescribe whether persistence uses private runtime storage, EventKit, CloudKit, or a reconciled adapter. Downstream Domain, Persistence, Continuity, and ExternalWrites specs must preserve:

- one canonical identity,
- local mutation authority,
- offline use,
- provenance,
- deterministic reconciliation,
- receipt-backed external writes.

## TIME-IMPORT-009 — External changes after import/link

No external change silently mutates an Ambitions-owned object.

Proposals may include:

- Accept update,
- Keep Ambitions version,
- Split,
- Unlink source,
- Archive,
- Ignore.

Source removal marks provenance unavailable; it does not delete the Ambitions object.

## TIME-IMPORT-010 — Recurrence

Import review exposes:

- recurrence rule,
- exceptions,
- date range,
- conflicts,
- reflow impact.

Scopes:

- this occurrence,
- this and following,
- entire series,
- selected date range.

Imported recurrence preserves series/occurrence semantics and creates receipt history. Editing uses native scopes with Ambitions-aware impact preview.

## TIME-IMPORT-011 — Invite metadata

Imported invite Events preserve attendee, organizer, RSVP, location, notes, and source metadata where available.

Ambitions may plan around the Event but does not claim active RSVP ownership until explicit invitation-management infrastructure exists.

External invite changes enter diff review.

## TIME-IMPORT-012 — Alert handoff

Imported alerts may become Ambitions-native notification rules on the Event, not separate Reminders.

Review shows:

- external alerts,
- proposed Ambitions rules,
- duplicate-notification risk.

Choices:

- Import with Ambitions notifications,
- Import without Ambitions notifications,
- Edit rules,
- keep external planning outcome.

Ambitions does not silently modify external alerts.

### Import implementation obligations

Primary source owners:

```text
Core/LocalRuntimeOS/Scheduling/
Core/LocalRuntimeOS/ExternalWrites/
Core/LocalRuntimeOS/Continuity/
Core/LocalRuntimeOS/Inspection/
Core/LocalRuntimeOS/Transactions/
Surfaces/Time/
Permissions/
Quality/
```

Required proof corpus:

- duplicate and near-duplicate fixtures,
- recurring series with exceptions,
- time-zone/DST cases,
- invite updates,
- removed source,
- permission revocation,
- partial import and retry,
- notification duplication,
- protected/fixed conflicts,
- external-hidden-but-capacity-reserved behavior,
- receipt/replay/rollback evidence.

---

# Article 11 — You constitution

**Decision provenance:** `7`, `29–35`, `79`, `90–95`, `167–176`.

## YOU-001 — Product identity

You is the low-scroll, searchable command center for identity, preferences, automation, privacy, data, security, sync, notifications, sources, receipts, history, and diagnostics.

It is not a profile feed, product manifesto, help center, AI-memory dashboard, or debug console.

## YOU-002 — First viewport

Show, with quiet hierarchy:

- identity/profile summary,
- account and sync status,
- privacy state,
- automation posture,
- notification status,
- data/security shortcuts,
- settings search.

Elevate only current problems or required actions.

## YOU-003 — Grouping

Primary groups:

1. Account & Sync
2. Privacy & Security
3. Automation & Behavior
4. Notifications & Presence
5. Appearance
6. Data & Storage
7. Sources & Imports
8. Receipts & History
9. Diagnostics

All settings remain searchable. No dedicated Help section.

## YOU-004 — Search

Search labels, synonyms, and relevant state. Results deep-link to the exact setting or review surface.

Required terms include at least calendar, reflow, privacy, Face ID, export, notifications, sync, receipt, automation, import, and account.

## YOU-005 — Account

- optional but encouraged,
- local core does not require sign-in,
- account may own identity, entitlements, subscription, support/service access,
- CloudKit sync is explained separately,
- sign-out retains local data unless the user explicitly deletes it,
- account deletion and local-data deletion are distinct actions.

## YOU-006 — Sync

Expose:

- CloudKit state,
- last successful sync,
- pending local changes,
- devices where available,
- conflict review,
- retry,
- pause/resume where supported,
- reset/rebuild with consequence preview.

Sync conflict never silently discards user data.

## YOU-007 — Privacy

Explain:

- what stays local,
- what syncs through CloudKit,
- what an Ambitions account stores,
- source permissions,
- export contents,
- deletion boundaries,
- diagnostics contents,
- R2/Source Atlas prohibition on private graph data.

## YOU-008 — Automation

Global controls include:

- conservative/adaptive posture,
- reflow authority,
- reminder recommendations,
- Goal Path automation,
- learned timing and step-shape behavior,
- proof defaults,
- confirmation thresholds.

Per-Goal overrides remain in Goal detail.

## YOU-009 — Notifications and presence

Control:

- Reminder notifications,
- Event notifications,
- contextual summaries,
- quiet hours,
- urgent behavior,
- permission state,
- duplicate-notification warnings,
- widget/Lock Screen presence.

Presence is user-configured and non-coercive.

## YOU-010 — Appearance

Appearance uses semantic design-system controls and may include system/light/dark, accent, material intensity, built-in themes, photo themes, custom photo, and accessibility appearance.

Appearance cannot reduce contrast, legibility, semantic meaning, or privacy without explicit warning and safe fallback.

## YOU-011 — Data and security

Provide:

- full/selective export,
- backup and restore,
- storage usage,
- import history,
- Trash and restore,
- reset local data,
- delete all local data,
- app lock,
- Face ID/passcode,
- sensitive-action confirmation,
- privacy-preserving notification previews.

Destructive actions require scope and consequence review.

## YOU-012 — Diagnostics

Expose redacted, user-understandable health for:

- sync,
- local stores,
- source connections,
- imports,
- external writes,
- performance budget failures.

Debug package export previews included content. Private content is excluded by default and requires explicit inclusion.

---

# Article 12 — Capture constitution

**Decision provenance:** `8`, `36–46`, `82–83`, `117–120`, `177–183`, owner reconciliation amendment `2`.

## CAPTURE-001 — Product identity

Capture is the global full-screen composer and durable intake boundary.

It receives intent, preserves it, infers or accepts object type, previews material consequences, and routes accepted objects to their canonical owners.

It is not a root tab, half-sheet quick box, category wall, chat screen, or inbox destination.

## CAPTURE-002 — Entry and return

- launch from integrated global create control,
- use current surface as context without silently changing meaning,
- local drilldowns may provide more specific creation actions,
- closing returns to exact prior context,
- draft persists across interruption.

## CAPTURE-003 — Blank composer

Default state:

- plain text entry,
- native voice/dictation where available,
- attachment intake,
- visible type override,
- preserved draft.

Do not begin with an interrogation wizard.

## CAPTURE-004 — Classification

Ambitions may infer Goal, Step, Reminder, Event, Proof, Note, or Attachment intake from content and context.

The inferred type is visible and editable. A material interpretation is never hidden.

Classification must remain deterministic and locally available for core paths. Optional assistive services may not become required for save/routing.

## CAPTURE-005 — Adaptive proposal flow

Simple captures save quickly. Complexity introduces only required steps:

- type/destination,
- metadata,
- schedule proposal,
- conflict check,
- confirmation,
- receipt.

Scheduling uses smart default plus alternatives, not unnecessary questioning.

## CAPTURE-006 — Durable save and draft recovery

Input must survive:

- app interruption,
- navigation away,
- crash,
- permission denial,
- attachment failure,
- validation failure.

Unsaved discard requires explicit confirmation.

No routing failure may destroy the user’s original input.

## CAPTURE-007 — Saved for Later

Saved for Later is a **durable unresolved state**, not a Capture inbox or product destination.

- saving creates clear confirmation,
- items remain searchable and recoverable,
- review may occur through Capture history, Search, or contextual filtered collection,
- items enter Today only after explicit scheduling or one earned fit suggestion,
- no persistent root or tab is created.

## CAPTURE-008 — Attachments

Support:

- Camera,
- Photos,
- Files,
- Scan Document,
- Scan Text,
- Voice,
- Web link,
- Proof attachment.

Attachments remain local unless an explicit sync/export action includes them. Sensitive boundaries appear at the point of action.

## CAPTURE-009 — Placement suggestion

When enough information exists, preselect one best placement and expose alternatives on demand.

Fit model considers:

- deadline safety,
- calendar fit,
- Protected/Fixed time,
- Goal priority,
- learned completion behavior,
- step shape,
- energy/context,
- reflow impact.

Primary copy remains plain. Rationale is inspectable.

---

# Article 13 — Search constitution

**Decision provenance:** `9`, `61–62`, `76`, `156`, `162`, `169`, `184`.

## SEARCH-001 — Product identity

Search is local-first **Find / Ask / Act / Inspect**.

It is object-led, not chatbot-first, command-line theater, a shallow sheet, or a cloud/LLM dependency. Find remains deterministic and offline; Ask cannot weaken that core path.

## SEARCH-002 — Find

Find at least:

- Life Areas,
- Goals,
- Goal Path nodes where useful,
- Steps,
- Reminders,
- Events,
- Notes,
- Proof,
- Receipts,
- History,
- Sources/provenance,
- settings.

## SEARCH-002A — Ask

Ask is an **optional on-device grounded Ask** over eligible local Ambitions objects. It presents grounded, contextual answers inside the object-led Search experience, may offer a **Capture handoff** for creation intent, and keeps conversation history session-local unless the user accepts a proposed-only action through the canonical object owner.

Ask must not transfer the private life graph to hosted AI, an external model, R2, Source Atlas, or an Ambitions backend. It must not become a chatbot destination or a second mutation authority. Any Act surfaced from Ask is proposed-only until the canonical owner validates, confirms where required, commits, receipts, and exposes undo or recovery. Ask unavailability must preserve deterministic offline Find, contextual Act, and Inspect.

This law defines product intent only. It does not activate Ask commands, close specification or visual gaps, prove production implementation, or authorize Visual Green.

## SEARCH-003 — Act

Contextual actions may include:

- complete,
- start,
- schedule/reschedule,
- open Capture,
- add Proof,
- pause/resume Goal,
- review conflict/reflow,
- open exact setting.

Material actions use validation, confirmation, mutation, and receipt law.

## SEARCH-004 — Inspect

Search may inspect:

- why an object moved,
- provenance,
- proof history,
- receipts,
- privacy state,
- sync state,
- recovery state.

## SEARCH-005 — Ranking and index contract

Search must be deterministic, local, privacy-filtered, and projection-fed.

Downstream Search design must define measurable ranking behavior across:

- exact title match,
- prefix/typo match,
- object status,
- recency,
- date proximity,
- Goal/context relevance,
- archived/Trash suppression,
- privacy eligibility,
- action safety.

Index rebuild, corruption recovery, and offline operation are mandatory.

---

# Article 14 — Trust, proof, privacy, source, and history constitution

**Decision provenance:** `10`, `55`, `68`, `87–95`, `185`, `198`.

## TRUST-001 — Layered trust seam

Trust appears in layers:

1. inline marker where the fact matters,
2. compact trust row in Detail when relevant,
3. deeper inspection for Proof, History, Source, Receipt, Privacy, and rationale,
4. searchable archives under You.

## TRUST-002 — Receipt coverage

Every product-significant accepted mutation produces an inspectable receipt or history entry.

Small reversible actions may use lightweight confirmation. Material actions require durable receipt detail.

## TRUST-003 — Proof levels

Proof may be:

- optional,
- suggested,
- required.

Requirement may come from explicit user rule, Goal closure, object category, repeated recovery, or path integrity. It must be visible before execution/completion.

## TRUST-004 — Closure

Completion and closure are distinct where product meaning requires it.

Closure may include proof, reflection, dependent cleanup, schedule cleanup, final receipt, and recovery/continuation choices.

## TRUST-005 — Privacy seam

Privacy is quiet by default and explicit at trust boundaries:

- account/sync,
- external source connection,
- import/export,
- sharing,
- attachment/proof intake,
- sensitive Goal content,
- diagnostics,
- destructive actions.

## TRUST-006 — Humane copy

Domain state and user-facing copy are separate.

Internal names such as `Missed`, `Abandoned`, `Conflict`, or `Failed` may not be rendered automatically. User-facing language must follow the active Copy and State Language authority, favoring truthful, non-shaming phrases such as:

- Reality changed,
- Still counts,
- Waiting,
- Needs your review,
- Review when ready.

---

# Article 15 — Account, CloudKit, R2, and privacy boundaries

## PRIVACY-LOCAL-001 — Local authority

Core private life data is local by default, including Goals, Life Areas, Capture drafts, Steps, Events, Reminders, schedule assumptions, Protected time, closures, receipts, proof, recovery, personalization, corrections, and recommendation history.

## PRIVACY-ACCOUNT-001 — Ambitions account boundary

An Ambitions account may own:

- optional identity,
- entitlement/subscription,
- support/account recovery,
- non-sensitive service state,
- Source Atlas/reference access state.

It does not own the private life graph.

## PRIVACY-CLOUDKIT-001 — CloudKit continuity

CloudKit may provide optional private-graph continuity while preserving:

- local device authority,
- offline core,
- explicit sync state,
- deterministic conflict review,
- no silent data loss,
- sign-out that retains local data unless explicitly deleted.

Product truth does not claim production readiness without current proof.

## PRIVACY-R2-001 — R2 / Source Atlas firewall

R2 and Source Atlas may store or deliver only approved public/reference/freshness data and non-sensitive connector/account state.

They must not receive, store, infer from, personalize from, or transmit:

- private life graph,
- Goals,
- Captures,
- schedules,
- Proof,
- Receipts,
- behavior patterns,
- inferred priorities,
- private user context.

## PRIVACY-EGRESS-001 — Egress review

Every network or external-system boundary requires:

- data classification,
- minimum necessary payload,
- local authorization,
- redaction,
- user-visible explanation where relevant,
- durable result/receipt,
- failure recovery.

---

# Article 16 — System layer and Apple ecosystem constitution

**Decision provenance:** `63–67`, `174`, `186–192`.

## SYSTEM-001 — Progressive first use

- open local core before sign-in,
- demonstrate value before requesting account or notification permission,
- request permissions in context,
- offer calendar migration when Time becomes relevant,
- avoid long mandatory onboarding.

## SYSTEM-002 — Permission contract

Every permission request states:

- the feature that needs it,
- what Ambitions reads or writes,
- what remains available without it,
- where the choice can be changed.

Denied permission produces a useful fallback, not a dead end.

## SYSTEM-003 — Notifications

Notifications are object-aware and action-oriented. Actions may include Complete, Start, Snooze, Reschedule, Add Proof, Open Event, or Review Reflow.

Notification previews respect privacy settings and do not expose sensitive content by default.

## SYSTEM-004 — Widgets and Lock Screen

Widgets/Lock Screen may project:

- Now/Next,
- one current Step,
- upcoming Fixed Event,
- compact Goal movement,
- quick Capture,
- pending review count where appropriate.

They are projections, not separate stores or mutation paths.

## SYSTEM-005 — App Intents, Shortcuts, Siri

Supported categories should include Capture, Start, Complete, Add Proof, Show Today, Show next Event, schedule/reschedule with confirmation, and review pending external diffs.

Every mutation routes through runtime mutation law.

## SYSTEM-006 — Share, Spotlight, deep links

- Share intake opens Capture with source content preserved.
- Spotlight indexes only approved local metadata.
- deep links resolve exact object/date/review/setting and degrade safely.
- no ecosystem path bypasses privacy, confirmation, mutation, or receipt law.

## SYSTEM-007 — Failure taxonomy

Distinguish at least:

- offline but healthy,
- stale source,
- sync pending,
- sync conflict,
- import failure,
- external-write failure,
- local store degradation,
- partial operation,
- unavailable permission.

Preserve input. Prefer retry, export, diagnostics, quarantine, rollback, or repair preview over destructive reset.

---

# Article 17 — Visual, SwiftUI, interaction, motion, and haptic constitution

## UI-NATIVE-001 — Native-first

SwiftUI-native APIs and Apple interaction patterns are the default. Custom machinery must earn its existence.

## UI-DESIGN-001 — Flagship design system

All product surfaces use semantic design-system controls for:

- color,
- typography,
- spacing,
- material,
- depth/lighting,
- motion,
- haptics,
- accessibility variants.

No local ad hoc visual constants when a semantic token exists.

## UI-MATERIAL-001 — Material honesty

Materials must communicate hierarchy and state without fake glass, excessive borders, glow, decorative sci-fi HUD treatment, or web-card chrome.

Full-screen integration, restrained depth, legibility, and native behavior outrank novelty.

## UI-OBJECT-001 — Object-first composition

Every top-level surface has a clear primary object. Supporting chrome remains subordinate.

Cards, tiles, rows, grids, and sheets are implementation patterns, not the product idea.

## UI-MOTION-001 — Motion continuity

Motion communicates:

- object continuity,
- accepted mutation,
- route depth,
- reflow consequence,
- closure,
- recovery.

Motion is never decorative proof of sophistication. Every motion has Reduce Motion behavior and semantic state equivalence.

## UI-HAPTIC-001 — Haptic restraint

Haptics may confirm meaningful selection, placement, snap, completion, conflict, or destructive confirmation. They may not become noisy or substitute for visual/audible/accessibility feedback.

## UI-STATE-001 — Complete state design

Every surface and object must specify and render:

- loading,
- empty,
- populated,
- dense,
- stale,
- offline,
- denied permission,
- conflict,
- partial failure,
- recovery,
- destructive confirmation,
- restored state.

Fixture-only state coverage is insufficient if runtime behavior is absent.

---

# Article 18 — Accessibility constitution

**Decision provenance:** `126`, `132–134`, `199`.

## A11Y-001 — Acceptance law

Accessibility is a product acceptance requirement, not a later compliance pass.

## A11Y-002 — Semantic equivalence

Spatial or visual systems must expose equivalent semantics and actions.

Required examples:

- Time grids have ordered semantic access and List equivalence.
- Goal Path exposes node order, current position, state, rationale, and actions without requiring horizontal visual interpretation.
- drag/resize has accessible action alternatives.
- ghost previews and reflow have verbal summaries.
- Month/Year have accessible summaries.

## A11Y-003 — Required support

- Dynamic Type at all supported sizes,
- VoiceOver labels, values, hints, actions, and predictable order,
- rotor-friendly navigation where useful,
- Reduce Motion,
- Reduce Transparency,
- non-color state encoding,
- contrast validation,
- minimum hit targets,
- focus restoration,
- keyboard/Switch Control support where system-supported,
- haptic alternatives.

## A11Y-004 — Proof

Green requires:

- VoiceOver scripts and recordings/logs where appropriate,
- accessibility identifier and action tests,
- Dynamic Type screenshot matrix,
- Reduce Motion proof,
- contrast/tap-target audit,
- focus-restoration scenarios,
- semantic parity review.

---

# Article 19 — Canonical end-to-end scenario contracts

These scenarios are constitutional probes. Downstream design documents must expand them into concrete state machines, tests, and proof.

## SCENARIO-001 — Intent to active Goal

```text
Capture intent
→ durable draft
→ local classification
→ generated Goal Path
→ assumptions review
→ schedule/proof review
→ activation confirmation
→ Goal + Path + placements committed
→ activation receipt
→ Today / Goals / Time / Search projections update
```

## SCENARIO-002 — Step execution and proof

```text
Scheduled Step
→ Today Start Here eligibility
→ start
→ in-progress state
→ complete
→ optional/suggested/required Proof handling
→ receipt
→ Goal Path movement
→ learned behavior update
→ replay-safe relaunch
```

## SCENARIO-003 — Reality changes

```text
Step no longer fits
→ reason/context identified
→ safe alternatives
→ recovery/reflow change set
→ material confirmation if required
→ commit
→ receipt + undo/rollback context
→ Today/Time/Goal Path update
```

## SCENARIO-004 — External calendar migration

```text
permission
→ source selection
→ scan
→ candidate grouping
→ duplicate/recurrence/notification/capacity review
→ conflict/reflow preview
→ user decision
→ import or external-capacity outcome
→ receipt
→ Time projection
```

## SCENARIO-005 — Recurring external update

```text
external series changes
→ diff badge
→ scope-aware review
→ consequence preview
→ accept/keep/split/unlink/ignore
→ receipt
→ recurrence projections update
```

## SCENARIO-006 — No-account to CloudKit continuity

```text
local no-account use
→ optional account prompt after value
→ CloudKit explanation
→ eligibility/preflight
→ continuity activation
→ sync state visible
→ conflict-safe replay
→ local data remains authoritative
```

## SCENARIO-007 — Sync conflict

```text
conflicting local/remote histories
→ quarantine
→ compare human-meaningful changes
→ choose/merge/duplicate safely
→ commit
→ receipt
→ projections rebuild
```

## SCENARIO-008 — Destructive Goal action

```text
delete/end Goal
→ dependent Step/Event/Reminder consequences
→ scope preview
→ Trash or end-state commit
→ receipt
→ restore path
→ projection and schedule cleanup
```

## SCENARIO-009 — Permission denied

```text
permission request
→ denial
→ useful degraded state
→ local core preserved
→ exact settings recovery path
→ later enablement
→ object state reconciles
```

## SCENARIO-010 — Capture attachment failure

```text
input + attachment
→ attachment failure/quarantine
→ text and draft preserved
→ retry/remove/replace options
→ successful save or safe unresolved state
```

## SCENARIO-011 — External source removed

```text
source unavailable
→ provenance state changes
→ Ambitions-native object remains
→ user review when consequence exists
→ no silent delete
```

## SCENARIO-012 — Offline completion and later sync

```text
offline complete
→ local command/event/receipt
→ projections update immediately
→ relaunch/replay works offline
→ later sync
→ no duplicate completion
```

---

# Article 20 — Validation, evidence, and Green constitution

**Decision provenance:** `69`, `81`, `87–95`, `199–201`.

## VALIDATION-001 — Green is multi-dimensional

A Feature is not Green because source exists or a screen renders.

Required dimensions:

- Product law,
- Runtime behavior,
- Functional completeness,
- Privacy/local-first,
- UI/visual quality,
- Accessibility,
- Performance/scale,
- Failure/recovery,
- Proof and owner acceptance.

## VALIDATION-002 — Product law proof

Prove:

- only four persistent surfaces,
- Capture/Motion/Trust ownership,
- no internal architecture language in primary UI,
- no commodity category drift,
- no fake controls or fixture-only primary paths.

## VALIDATION-003 — Runtime and object proof

Prove:

- command/event/projection/receipt/replay,
- canonical identity across projections,
- orthogonal state transitions,
- import/reflow confirmation,
- recurrence/exception handling,
- proof/closure/recovery,
- Trash/restore,
- external-write result handling.

## VALIDATION-004 — Privacy/local-first proof

Prove:

- local core without sign-in,
- offline use and replay,
- account/CloudKit separation,
- R2 private-graph denial,
- minimum egress and redaction,
- diagnostics/export preview.

## VALIDATION-005 — UI and accessibility proof

Prove:

- semantic token use,
- preview matrices,
- screenshot diffs,
- dark/light and accessibility appearance,
- Dynamic Type,
- VoiceOver,
- Reduce Motion/Transparency,
- focus restoration,
- gesture alternatives,
- haptics restraint.

## VALIDATION-006 — Performance and scale contracts

Every implementation project that affects runtime, projection, search, import, Time rendering, attachments, or sync must define measurable budgets before Codex-ready status.

Budget areas include:

- launch/readiness latency,
- object mutation latency,
- projection refresh latency,
- Search P50/P95 on declared fixture scale,
- Time grid/List scrolling and interaction responsiveness,
- import throughput and memory,
- recurrence expansion limits,
- local store size and migration duration,
- battery/background work,
- widget/App Intent response,
- attachment storage and export.

The constitution does not invent a fake universal number. The owning design document must set and validate numbers against supported devices and declared data scale.

## VALIDATION-007 — Proof artifacts

As applicable, closeout includes:

- PR/commit,
- commands run and exact result,
- tests and scenario gates,
- screenshots/video,
- accessibility proof,
- performance output,
- migration/import fixtures,
- receipts/history evidence,
- known-issue updates,
- rollback plan,
- owner acceptance.

## VALIDATION-008 — Claim ceiling

A truth update, Linear comment, source name, test file, screenshot, or generated report cannot manufacture Green.

Current executed evidence sets the claim ceiling.

---

# Article 21 — Codex and Linear implementation constitution

## CODEX-001 — No vague implementation leaves

A Codex leaf must be bounded, repo-backed, and independently reviewable.

It must state:

- law IDs implemented,
- user scenario,
- current source reality,
- exact source owners,
- files expected to change,
- authority to delete/demote old paths,
- state transitions,
- edge/failure cases,
- accessibility behavior,
- privacy boundary,
- validation commands,
- proof artifacts,
- rollback plan.

## CODEX-002 — Project/Feature/leaf hierarchy

Use the Ambitions Linear hierarchy:

```text
Initiative
→ Project / Epic
→ Milestone
→ Parent Feature acceptance object
→ Codex implementation leaf
```

A parent Feature does not become Done merely because leaves are done. Parent acceptance requires integrated product, validation, accessibility, proof, and closeout evidence.

## CODEX-003 — Law over lore

- delete before naming,
- do not add managers/coordinators/engines when an owner exists,
- do not preserve compatibility owners without removal plan,
- do not create generic `Features/` ownership when canonical source owners exist,
- do not expose architecture vocabulary as UI depth.

## CODEX-004 — Source comparison before work

Before implementation, Codex must inspect:

- current source owner,
- current tests,
- related projections,
- current truth files,
- current known issues,
- current validation scripts,
- recent related commits where relevant.

A design document or issue cannot substitute for live source inspection.

## CODEX-005 — Required closeout block

```text
Status: Green / Yellow / Red
Scope completed:
Files changed:
Product law preserved:
Validation run:
Validation not run:
Proof artifacts:
Known risks:
Follow-up required:
Rollback plan:
```

Accepted Yellow must name the risk and linked follow-up. It is never reported as Green.

---

# Article 22 — Final Architecture Tree and source-owner constitution

This is the Final Architecture Tree at stable owner-boundary granularity. It defines responsibility ownership and Codex routing. It is not a claim that every path is implemented, migrated, or Green.

## PLATFORM-001 — Native platform baseline

```text
Repository: agentdevan/ambitions
Native app root: Native/Ambitions/
Project generation: XcodeGen via project.yml
Deployment target: iOS 26.0
Swift language mode: Swift 6
Primary targets: Ambitions, AmbitionsWidgetExtension, AmbitionsShareExtension, AmbitionsTests, AmbitionsUITests
```

`Ambitions.xcodeproj` is generated output and is not source authority.

## PLATFORM-002 — Runtime root chain

```text
AmbitionsApp
→ AmbitionsRootScene
→ LaunchGateView
→ AmbitionsStageHost
→ AmbitionsStage
```

New root composition must preserve this ownership or explicitly supersede it through a reviewed architecture amendment with migration and deletion proof.

Current leaf source, source-presence status, compatibility debt, and implementation proof belong to live source and `IMPLEMENTATION_TRUTH.md`. Validation command truth belongs to `RELEASE_TRUTH.md` and current retained scripts; do not hard-code stale command lists here.

```text
Native/Ambitions/
  App/
    app entry, root scene, dependency assembly, feature flags

  Stage/
    root composition, route depth, shell/chrome, overlays, motion,
    safe-area, focus, accessibility containment

  Core/
    Domain/
      canonical life-object models and value semantics

    Time/
      clock, time zone, day boundaries, temporal primitives

    LocalRuntimeOS/
      Boundary/
        local-only, account, egress, Source Atlas capability law
      Commands/
        command envelope, validation, authorization, idempotency, journal
      Transactions/
        read/write sets, conflict detection, commit, rollback
      EventJournal/
        durable events, causal order, replay, compaction, tombstones
      State/
        canonical object-state store families
      Projections/
        Today, Goals, Time, You, Search, widget, intent, trust projections
      PrivateLifeRuntimeKernel/
        fit, recommendation, closure, proof, recovery, adaptation, explanation
      Planning/
        Goal Path, dependencies, smaller Steps, plan repair, progress preservation
      Scheduling/
        Life Calendar, recurrence, constraints, capacity, placement, conflict/recovery windows
      CaptureRouting/
        durable intake, draft, classification, routing, attachments, promotion, correction
      Inspection/
        events, receipts, proof, source, audit, undo, history
      Search/
        local FTS/semantic index, ranking, action validation, rebuild
      ExternalWrites/
        outbox, EventKit, notifications, widgets, intents, share intake, reconciliation
      Continuity/
        local-authoritative CloudKit continuity, merge, conflict, tombstones, account state
      SourceAtlas/
        public-only request, verification, freshness, cache, R2 gateway, projection
      PrivacySecurity/
        classification, redaction, egress firewall, export, local auth, file protection
      Storage/
        event/object/projection/search/blob/app-group/backup/migration stores
      Repair/
        schema/migration planning, backup, invariants, quarantine, doctor, rollback
      Diagnostics/
        health, traces, projection/command/privacy/sync/store inspection, performance budgets

  Projection/
    contracts and user-visible mutation semantics only where not owned by LocalRuntimeOS

  Language/
    user-facing copy, runtime vocabulary separation, forbidden terms, copy budgets

  Trust/
    contextual inspection surfaces and disclosure policy

  Interaction/
    gesture, direct manipulation, keyboard, haptic policy

  Rendering/
    custom visual primitives only with semantic mirrors and performance proof

  DesignSystem/
    foundations, accessibility policy, Stage primitives, shared product-object components

  Surfaces/
    Today/
    Goals/
    Time/
    You/

  Composer/
    Capture/

  Scenarios/
    canonical runtime, surface, overlay, motion, stress, and accessibility probes

  Diagnostics/
    app/stage/render/store diagnostics presentation

  Quality/
    snapshots, accessibility, performance, visual regression, motion,
    shell, language, safe-area, Dynamic Type, real-device checklists
```

## ARCH-001 — Removed or forbidden ownership

Do not restore as canonical root architecture:

- `RootTab.swift` or `TabView` as the product model,
- `Surfaces/Motion/`,
- `Surfaces/Capture/`,
- Motion as a top-level surface projection/scenario,
- direct repository/service mutation outside command/transaction/event/projection/receipt/replay law,
- generic feature-owned architecture that duplicates canonical owners,
- R2 or hosted services as private runtime owners.

## ARCH-002 — Compatibility debt

Remaining old `Core/Runtime/`, `Core/Persistence/`, legacy projection, or duplicate service ownership is compatibility/migration debt unless current truth explicitly reauthorizes it.

When touched, work must delete, move, or provide a bounded removal plan.

---

# Article 23 — Hard reds

Stop and report Red when work causes or promotes:

- a fifth persistent root,
- Capture or Motion as destination,
- Today as a broad backlog or generic agenda identity,
- Goals as a dashboard or project-management board,
- Time without first-class calendar behavior,
- unreviewed external candidates rendered as native Events,
- hidden external commitments treated as free capacity without explicit user choice,
- silent material reflow/import/sync mutation,
- Goal Path changes that cannot be inspected or corrected,
- one object duplicated across surfaces as separate canonical records,
- type conversion without preview/receipt,
- private graph egress to R2, Source Atlas, hosted AI, or Ambitions account backend,
- cloud/LLM dependency for core behavior,
- account gate before local core use,
- internal enum/runtime vocabulary leaked as primary UI,
- productivity scoring, streak pressure, shame, or coercive notification presence,
- spatial interaction without semantic equivalent,
- fake controls, fake success, fixture-only primary flows,
- source-only closeout without rendered/runtime proof,
- Green claim without linked current evidence.

---

# Article 24 — Decision provenance and supersession register

Decision numbers are retained for traceability. The constitutional articles above are normative.

| Decision range | Integrated constitutional area |
|---|---|
| 1–10 | Product identity, root IA, Capture/Search/Trust ownership |
| 11–14 | Today identity, ordering, eligibility, empty-state law |
| 15–20 | Goals root, Life Areas, Goal detail, Goal Path, closure |
| 21–28 | Time views, creation, real-time marker, scheduled Steps |
| 29–35 | You grouping, account, privacy, appearance, data, receipts |
| 36–46 | Capture entry, durable save, proposal flow, attachments, unresolved state |
| 47–55 | Step/Substep law, metadata, completion, section ownership, receipts/history |
| 56–60 | Shell/navigation/drilldown; Decision 56 reconciled by AUTH-004 |
| 61–69 | Search actions, progressive setup, account/sync/privacy, proof/undo, Spec Ready |
| 70–75 | Closed-loop moat and Goal Path emotional/visual model |
| 76–80 | Minor/material adaptation, learning controls, reflow authority |
| 81–86 | Reflow presentation, placement fit, time semantics, conflict authority |
| 87–95 | Proof, closure, trust, privacy, sync/account, R2/runtime boundary |
| 96–108 | Today fit, rail, eligibility, interaction, completion, empty state |
| 109–124 | Goals root/detail, Goal Path, creation/activation, lifecycle, recovery, closure |
| 125–137 | Time landing, views, direct manipulation, conflict, detail, creation |
| 138–159 | Calendar migration, external diffs, recurrence, invites, notifications, all-day |
| 160–166 | Multi-day, time zones, Time search/filter, Reminder, export, failure, acceptance |
| 167–176 | You landing, groups, search, account, sync, privacy, automation, notifications, data, security |
| 177–183 | Capture launch, composer, classification, proposal, unresolved state, recovery, attachments |
| 184–185 | Search and contextual Trust |
| 186–192 | First use, permissions, notifications, widgets, intents, share/Spotlight/deep links, failure |
| 193–198 | Object boundaries, state/lifecycle, linkage, destructive actions |
| 199 | Accessibility constitution |
| 200–201 | Acceptance matrix, readback, closure, claim discipline |

## Supersession summary

The 2026-07-09 decision integration supersedes older conflicting product/design wording while preserving:

- supreme mission law,
- runtime mutation law,
- local-first/privacy/R2 boundaries,
- icon-only root shell with evidence-backed fallback,
- Reality Window identity,
- richer runtime hierarchy,
- proof/evidence claim discipline.

Older 2026-06-22 amendments remain valid where they do not conflict with this constitution.

---

# Final non-negotiables

- Ambitions is a private Personal Life OS for contextual life orchestration.
- Today / Goals / Time / You are the only persistent surfaces.
- Capture is the global composer, not an inbox or root destination.
- Motion is behavior, not a surface.
- Trust is contextual inspection, not global chrome.
- Today is the Reality Window; the `±24-hour` rail supports it.
- Goals owns Life Areas, Goals, Goal Paths, proof, recovery, and closure.
- Time is calendar-grade and expresses unequal time, capacity, protection, and reflow.
- External candidates do not become native Events without review.
- Hidden external commitments are not treated as free capacity without explicit choice.
- Every real object has one canonical identity.
- Lifecycle, placement, time authority, execution, proof, recovery, source, sync, and automation states remain distinguishable.
- Every material mutation is validated, inspectable, receipt-backed, and confirmable according to user rules.
- Core private behavior is local, deterministic, replayable, and usable offline.
- CloudKit continuity is optional; Ambitions account and R2 do not own the private graph.
- SwiftUI-native implementation is the default.
- Every spatial interaction has semantic and reduced-motion equivalence.
- Every implementation train cites laws, source owners, validation, proof, and rollback.
- No canon, source name, screenshot, or prose turns absent proof into Green.

This is the product constitution. Preserve it, implement it, validate it, and do not weaken it through convenience, lore, or unsupported claims.
