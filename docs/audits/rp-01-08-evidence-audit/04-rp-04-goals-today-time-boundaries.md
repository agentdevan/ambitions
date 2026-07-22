<!-- markdownlint-disable MD013 MD060 -->

# RP-04 — Goals, Today, and Time Domain Boundaries

Audit base: `main` at `29872755f705f6bd8e276aeac86dcf376ac5f0d8`

Capability vocabulary: `SUPPORTED`, `PARTIALLY_SUPPORTED`, `PLANNED_NOT_IMPLEMENTED`, `ABSENT`, `CONTRADICTED`, `DEPRECATED_OR_SUPERSEDED`, `DEBUG_OR_FIXTURE_ONLY`, `UNKNOWN`

## Executive verdict

The Goals–Today–Time boundary is **PARTIALLY_SUPPORTED**, but the selected provisional directions depend on major unresolved architecture and conflict with current canon in two structural areas.

The strongest surviving boundary is that Goals owns a Goal and its Step/Plan meaning, Today computes an execution-focused lens over those same Goal/Step identities, and Time owns local temporal blocks and scheduling consequences. Today’s durable Goal/Step action preparation reloads the owning objects by `goalID` and `stepID`, and Time can persist blocks linked to those IDs. That supports cross-root continuity without making Today a second owner.

The first structural conflict is the Goals root. Current canon requires a native, editable Life Area index, while `AVF-GOALS-S07-R01` centers a living Goal index with an inline Linked Goal Lens. The inline lens is compatible with Goal detail, but its proposed root placement cannot be called canon-compatible without a UX Blueprint decision or a new visual branch. The second conflict is Today: current canon requires one dominant `Start here` object and at most one earned fit suggestion, while the locked provisional direction names “What Matters Today” and allows up to three root-level priority objects. Live source does compute up to three Step-backed items under “What fits now,” so implementation residue happens to resemble the provisional count, but current source does not override canon.

Time’s Week emphasis is directionally compatible with live source—the service defaults its availability horizon to `week` and only a week-shaped surface is currently evident—but canon requires accessible Day, Week, Month, Year, and List views and remembering the last-used view. A forced Week root would contradict that retention law; a first-use Week default remains a product/UX decision. The repository does not currently prove a complete calendar, canonical Event model, accepted-placement-only rendering, or rich personal-availability semantics.

Primary dispositions:

- `VISUAL_DIRECTION_SURVIVES` for Goal/Step identity continuity, a compact Goal lens in owner depth, protected/fixed/flexible time distinctions, and a Today execution lens.
- `NEW_VISUAL_BRANCH_MAY_BE_REQUIRED` for Goals root and Today first-viewport differences between the protected provisional package and current higher-authority canon.
- `ARCHITECTURE_DECISION_REQUIRED`, `UX_BLUEPRINT_DECISION_REQUIRED`, and `RUNTIME_CAPABILITY_REQUIRED` for Life Area ownership, Today priority ontology, canonical Events/Placements, calendar replacement, and day-specific versus persistent meaning.
- `UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE` for calendar-grade, exact-owner, or rich-capacity behaviors presented as current when only plans/types exist.

## Scope

This packet audits:

- Goal, Goal Plan/Path, Step, lifecycle, progression, history, focus, and mutation ownership.
- Today eligibility, priority/attention, current-day projection, execution, timeline, quiet-day state, and reshape authority.
- Time ranges, blocks, events, placements, protection, availability, capacity, conflict, recovery, and calendar-source boundaries.
- Cross-domain projection, owner return, local actions, and overlap.
- Explicit implications for `AVF-GOALS-S07-R01`, `AVF-TIME-S07-R00`, and `AVF-TODAY-S09-R00`.

## Authoritative sources

| Authority | Sources | Purpose |
| --- | --- | --- |
| Current generated canon | `docs/canon/generated/object-boundary-matrix.md:1-27` | Distinguishes Step, Event, Reminder, Note, and Schedule Placement. |
| Normative object canon | `docs/canon/specifications/objects/goal.md:70-117`; `goal-path.md:61-128`; `event.md:39-130`; `schedule-placement.md:30-111`; `life-area.md:37-119` | Target domain boundaries and ownership. |
| Normative surface canon | `docs/canon/specifications/surfaces/goals.md:2058-2252`; `today.md:873-1080`; `time.md:3840-4170` | Current product/surface authority. |
| Current domain models | `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineContracts.swift:86-109,314-323`; `GoalEnginePlanSection.swift:3-205`; `Step.swift:11-25`; `LifeArea.swift:3-37`; `TimeContextHierarchy.swift:5-113,355-395` | Implemented ontology. |
| Current persistence | `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataModels.swift:4-288`; `ObjectStoreSwiftData.swift:142-240`; `Scheduling/TimeBlockGraph.swift:3-200`; `Scheduling/LifeCalendarStore.swift:38-151` | Stored truth and temporal blocks. |
| Current projections/actions | Today and Time projection files cited in the evidence appendix | Actual cross-root behavior and limits. |
| Current proof ceiling | `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift:130-180,211-302`; `docs/qa/architecture/architecture-modernization-current-state.md:32-83,149-158` | Durable versus unproven paths. |
| Provisional visual inputs | Attached three markdown records | Protected intent only; lower authority than live source/canon. |

## Goals domain model

| Concept | Current model | Status | Evidence and interpretation |
| --- | --- | --- | --- |
| Goal identity | `Goal.id: String`, revision, relationships, timing, optional plan; unique stored `GoalRecord.id` | `SUPPORTED` for core identity | `GoalEnginePlanSection.swift:140-205`; `ObjectStoreSwiftDataModels.swift:4-97` |
| Goal lifecycle | draft, active, paused, completed, archived | `PARTIALLY_SUPPORTED` | Live enum at `GoalEngineContracts.swift:86-92`; canon also requires Ready, Ended, Trash, restore, permanent deletion at `goal.md:81-100`. |
| Goal Path / progression | Versioned `GoalPlan`, ordered sections, Steps; planning strategy can allow parallel active Steps | `PARTIALLY_SUPPORTED` | `GoalEnginePlanSection.swift:3-91`; `GoalEngineContracts.swift:314-323`; canon’s richer path node/history law is `goal-path.md:30-43,61-118`. |
| Progression unit | `Step` is the executable unit; Step is distinct from Event/Reminder/Note | `SUPPORTED` as ontology boundary | `Step.swift:11-25`; generated matrix `object-boundary-matrix.md:8-27`. |
| Goal relationships | Parent/child/support IDs, tags, optional life graph; Step membership via Goal Plan | `PARTIALLY_SUPPORTED` | `GoalEnginePlanSection.swift:140-203`; `StepRecord` adds goalID/planID/sectionID at `ObjectStoreSwiftDataModels.swift:198-288`. |
| Life Area owner/index | Canon requires editable Life Areas and a Life-Area-led Goals root | `CONTRADICTED` in implementation | `goals.md:2152-2197`; live `LifeArea.canonical` is a fixed enum-derived list at `LifeArea.swift:19-37`; no stored Life Area record is in `ObjectStoreSwiftData.swift:142-164`. |
| Focused depth | Canon gives Goal detail/path native depth; live routes use `GoalRouteTarget(goalID...)` | `PARTIALLY_SUPPORTED` | `goals.md:2191-2197`; `StageRoute.swift:8-35`. |
| Mutation authority | Canon says canonical commands; store manifest assigns Goal/Step to runtime owners | `PARTIALLY_SUPPORTED` | `ObjectStoreSwiftData.swift:166-211`; registry marks most Goals paths unproven at `MeaningfulMutationRegistry.swift:151-163`. |
| History and closure | Canon requires separate completion, closure, archive, Trash, restore, receipts/history | `PLANNED_NOT_IMPLEMENTED` as a complete contract | Canon `goal.md:81-100`; compressed live enum and registry proof ceiling do not establish it. |

### Goals boundary conclusion

The repository supports “Goal with meaningful Steps and a versioned Plan” better than “Goal as a complete living canon Path with full closure/history.” A Linked Goal Lens can truthfully show the selected Goal, its current Step(s), timing, and plan context where those values exist. It cannot truthfully imply all canonical lifecycle states, immutable path lineage, universal Receipt history, or editable Life Area ownership.

## Today domain model

| Concept | Current model | Status | Evidence and interpretation |
| --- | --- | --- | --- |
| Surface purpose | Object-led reality around now; not backlog/calendar/dashboard | `SUPPORTED` as normative contract | `today.md:877-894`. |
| Eligibility | Canon: scheduled/execution-relevant objects, recovery-flexible work, at most one earned fit suggestion | `PARTIALLY_SUPPORTED` | Canon `today.md:913-926`; live service ranks all eligible plan Steps from active/paused Goals (`Repository01-makeExperience.swift:5-38`) without demonstrating the full canonical schedule-membership filter. |
| Priority / attention model | Canon: one dominant `Start here`; provisional: up to three “What Matters Today” objects; live: up to three “What fits now” Step items | `CONTRADICTED` across authorities | Canon `today.md:943-960`; live `Repository06-adjustmentPayload.swift:105-160`; attached VC-07 is provisional and lower authority. |
| Projection identity | Today items reuse Step IDs and carry Goal/Step action targets | `SUPPORTED` | `TodayFeatureModels+02-TodayTargetItem.swift:4-46`; `Repository06-adjustmentPayload.swift:120-159`. |
| Top-priority derivation | Deterministic selector ranks active/paused Goal Steps using dependencies, evaluation, learned fit and stable tie-breaks | `PARTIALLY_SUPPORTED` | `PlanningNextStepSelector.swift:22-140`; the complete canonical fit threshold and schedule membership are not proven. |
| Day-specific meaning | Today derives a current experience, completion summaries, ranked focus, free-time and milestone views | `PARTIALLY_SUPPORTED` | `Repository01-makeExperience.swift:40-127`; no canonical stored Today-priority identity exists. |
| Timeline | Canon requires a supporting rolling ±24-hour rail | `PLANNED_NOT_IMPLEMENTED` or unverified in this packet | Canon `today.md:896-911`; no load-bearing support claim is made from view names alone. |
| Mutation/reshape authority | Today may execute compact actions on underlying Goal/Step; complex temporal editing returns to Time | `PARTIALLY_SUPPORTED` | Canon `today.md:928-941,1021-1046`; adapter reloads Goal/Step and prepares owner-routed actions at `TodayGoalStepActionCommandAdapter.swift:7-53`. |
| Quiet/empty state | Live experience has empty mode and empty Step messaging | `SUPPORTED` at projection-model level | `Repository01-makeExperience.swift:55-59`; `Repository06-adjustmentPayload.swift:152-160`. |

### Today boundary conclusion

Today is a computed lens, not an owner of duplicate Goal/Step records. Its strongest supported operation is a narrow action on a projected Step with explicit Goal/Step identity. The repository does not establish a separate priority object, a full-day calendar, or an unconstrained local reshape authority. Canon explicitly routes complex rescheduling and long-range editing to Time or the canonical object owner.

## Time domain model

| Concept | Current model | Status | Evidence and interpretation |
| --- | --- | --- | --- |
| Root temporal scope | Current service defaults the calendar-availability horizon to `week`; live projection builds seven days | `PARTIALLY_SUPPORTED` | `RepositoryBackedTimeService.swift:17-32`; `TimeWeekShapeProjection.swift:23-54,74-151`. |
| Canonical view family | Day, Week, Month, Year, List; remember last-used view | `PLANNED_NOT_IMPLEMENTED` as complete family | `time.md:3858-3878,3998-4051`; source inspected here establishes week projection, not five-view parity. |
| Events/commitments | Canon defines first-class local Event with recurrence/source/series identity | `PLANNED_NOT_IMPLEMENTED` | `event.md:39-130`; no canonical Event record appears in `ObjectStoreSwiftData.swift:142-164`. |
| Local temporal block | `TimeBlock` has ID, range, kind, source, optional Step/Goal/Event/command IDs; JSON persisted | `SUPPORTED` as implementation block | `TimeBlockGraph.swift:3-100`; `LifeCalendarStore.swift:38-151`. |
| Schedule Placement | Canon defines a relation, distinct from Step/Event | `PARTIALLY_SUPPORTED` | TimeBlock links object IDs but no complete `SchedulePlacementRecord`/state contract exists; `schedule-placement.md:30-57`. |
| Protection/flexibility/recovery | Block kinds include protected, fixed, flexible, scheduled Step, recovery, buffer and related states | `PARTIALLY_SUPPORTED` | `TimeBlockGraph.swift:3-37`. Type support does not prove every command or UI state. |
| Conflict | Overlap yields typed advisory/blocking conflict tied to both block IDs | `SUPPORTED` at model level | `TimeBlockGraph.swift:137-196`. |
| External calendar reality | Optional service can query busy windows and append a calendar-observation ledger entry | `PARTIALLY_SUPPORTED` | `RepositoryBackedTimeService.swift:51-91`; this is not canonical Event import or replacement proof. |
| Personal availability | Typed context source, rigidity, and availability distinguish protected/user-choice-only time | `PARTIALLY_SUPPORTED` | `TimeContextHierarchy.swift:5-113,355-395`; canonical persistence and complete projection are unproven. |
| Capacity | Week projection uses block count plus weighted contexts against a constant `3.0` | `PARTIALLY_SUPPORTED` | `TimeWeekShapeProjection.swift:82-105`; it is a coarse heuristic, not proof of rich energy/cognitive/transition capacity. |
| Goal-linked scheduling | Persisted TimeBlocks may carry Goal/Step IDs; computed Goal timing also becomes week rows | `PARTIALLY_SUPPORTED` | `TimeWeekShapeProjection.swift:23-150`; the computed path risks displaying unaccepted placement as scheduled work. |
| Mutation ownership | Some Time command/ritual paths are durable; simple Step placement and EventKit paths remain unproven | `PARTIALLY_SUPPORTED` | `MeaningfulMutationRegistry.swift:211-302`. |

### Time boundary conclusion

Time owns the strongest implemented temporal relation: local persisted blocks, block conflicts, and selected durable command paths. It does not yet truthfully support complete calendar replacement, canonical Event CRUD/recurrence, five-view parity, or all rich availability concepts implied by `AVF-TIME-S07-R00`. Week is a practical current implementation shape, not proof that Week may override the canon requirement to remember the user’s last-used view.

## Shared-concept table

| Shared concept | Goals meaning/owner | Today meaning/owner | Time meaning/owner | Boundary finding |
| --- | --- | --- | --- | --- |
| Goal | Canonical desired outcome; Goals presents/edits | Context label and source for action | Context for placed/proposed Step | One Goal identity can survive; projections must not edit copies. |
| Step | Canonical executable path unit | Candidate/current action; Step ID retained | Placed or proposed temporal work | Shared identity is supported; placement acceptance state needs repair. |
| Priority | Goal planning strategy/relationship concern | “What to act on next” projection | Temporal fit/pressure input, not Goal priority owner | No canonical Today-priority object is implemented. |
| Current truth | Goal/path lifecycle and Step state | Current execution lens | Accepted local blocks plus disclosed external facts | Projections must distinguish accepted, proposed, and stale facts. |
| Schedule | Goal may express timing target | Compact local action/handoff | Time/Scheduling owns placement reality | Today must not become a second schedule owner. |
| Capacity | Planning inputs and fit | Selects what fits now | Temporal blocks, availability, pressure | Current algorithms are partial and use different abstractions. |
| Protected time | Goal automation cannot override | Boundary shown around current action | TimeBlock/availability owner | Model-level support survives; end-to-end owner proof is partial. |
| Recovery | Goal/path recovery context | Contextual execution recovery | Recovery blocks/windows and reflow | Shared concept exists, but one canonical recovery object/lineage is not established here. |
| History/Receipt | Goal/path mutations retain lineage | Links action result | Placement/external result lineage | Canon is broad; runtime proof is bounded. |
| Return to owner | Goal detail/path | Opens underlying Step or hands complex time work to Time | Goal-linked rows return to Goals | Goal return exists; Time object/Step exact routing is incomplete. |

## Ownership and mutation boundary matrix

| Operation | Canonical owner | Allowed originating surface | Current implementation | Status |
| --- | --- | --- | --- | --- |
| Edit Goal meaning/lifecycle | Goal/Planning/Commands | Goals; Search/Capture/Today/Time may transfer | Goals repository-backed mutations exist but registry is unproven | `PARTIALLY_SUPPORTED` |
| Complete/defer a Step in Today | Step/Goal command owner | Today narrow contextual action | Today reloads Goal/Step and prepares command | `PARTIALLY_SUPPORTED` |
| Choose Today focus | Projection/fit owner using canonical facts | Today | Selector computes deterministic ranking | `PARTIALLY_SUPPORTED`; no stored priority owner. |
| Place/move/protect time | Scheduling/Commands | Time; Goals/Today/Capture may prepare/transfer | TimeBlocks and some durable runtime commands exist | `PARTIALLY_SUPPORTED` |
| Edit Event | Event/Scheduling/ExternalWrites | Time | Canon only; no canonical Event store | `PLANNED_NOT_IMPLEMENTED` |
| Reshape one low-risk Today item | Placement owner through typed command | Today compact sheet | Canon permits narrow flow; adapter supports several Goal/Step actions | `PARTIALLY_SUPPORTED` |
| Multi-item/day-wide reshape | Time/adjustment owner | Today handoff to Time | No complete grouped placement model proven | `PLANNED_NOT_IMPLEMENTED` |
| Change Life Area | Life Area owner | Goals | Live Life Areas are not editable stored objects | `ABSENT` |

## Projection matrix

| Source domain | Destination | Projected data | Linkage | Assessment |
| --- | --- | --- | --- | --- |
| Goals | Today | Active/paused Goals, actionable Steps, Goal title, timing, state | Goal ID + Step ID | `SUPPORTED` for identity; eligibility completeness `PARTIALLY_SUPPORTED`. |
| Goals | Time | Goal-plan Step timing and evaluation | Internal Goal/Step; UI target often Goal ID only | `PARTIALLY_SUPPORTED`. |
| Time | Today | Canon promises execution-relevant Events/Reminders/placed Steps and boundaries | Intended canonical IDs | `PARTIALLY_SUPPORTED`; full projection not established. |
| Time | Goals | Scheduled Goal items and placement consequences | TimeBlock can retain Goal/Step IDs | `PARTIALLY_SUPPORTED`; complete placement/history lineage absent. |
| Today | Goals | Open underlying Goal/Step; action updates canonical Goal/Step projection | Explicit action target IDs | `PARTIALLY_SUPPORTED`; runtime test not executed. |
| Today | Time | Complex reschedule/full-day handoff | Canon requires selection/context preservation | `PLANNED_NOT_IMPLEMENTED` or `UNKNOWN` for exact return. |

## Overlap and contradiction register

| ID | Contradiction | Evidence | Severity | Disposition |
| --- | --- | --- | --- | --- |
| RP04-C01 | Provisional Goals root is a living Goal index with inline lens; current canon requires a native editable Life Area index | Attached VC-08; `goals.md:2152-2197` | High | `NEW_VISUAL_BRANCH_MAY_BE_REQUIRED`, `UX_BLUEPRINT_DECISION_REQUIRED` |
| RP04-C02 | Provisional Today permits up to three “What Matters Today” objects; canon requires one dominant `Start here` and at most one earned fit suggestion | Attached VC-07; `today.md:913-960` | Critical | `NEW_VISUAL_BRANCH_MAY_BE_REQUIRED`, `UX_BLUEPRINT_DECISION_REQUIRED` |
| RP04-C03 | Live Today has up to three “What fits now” items, but those implementation strings/counts are lower authority than canon and are not visual authority | `Repository06-adjustmentPayload.swift:120-160`; `today.md:943-960` | High | `RECONSTRUCTION_PLAN_ACTION_REQUIRED`; do not use legacy/current UI residue as visual authority |
| RP04-C04 | Canon says unscheduled Steps are clearly non-durable proposals; week projection turns Goal timing into ordinary block state without an accepted/proposal flag | `time.md:3951-3963`; `TimeWeekShapeProjection.swift:23-54,65-130` | Critical | `RUNTIME_CAPABILITY_REQUIRED`, `TARGETED_VISUAL_REFINEMENT_REQUIRED` |
| RP04-C05 | Canon promises a complete native calendar and five views; current source evidence is centered on week projection and TimeBlocks, without canonical Events | `time.md:3848-3878,3998-4051,4167-4170`; current Time source cited above | Critical | `RECONSTRUCTION_PLAN_ACTION_REQUIRED`, `UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE` until implemented/proven |
| RP04-C06 | Week is locked as provisional default, while canon requires remembering last-used view | Attached VC-09; `time.md:3998-4007` | Medium | `UX_BLUEPRINT_DECISION_REQUIRED`; Week may be a first-use default, not a forced override, if explicitly decided |
| RP04-C07 | Canon requires editable Life Areas, but live model is static | `life-area.md:37-119`; `LifeArea.swift:19-37` | Critical | `ARCHITECTURE_DECISION_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED` |
| RP04-C08 | “Personally usable opening” implies richer availability/capacity than live count/weight heuristics establish | `TimeContextHierarchy.swift:83-113`; `TimeWeekShapeProjection.swift:82-105` | High | `TARGETED_VISUAL_REFINEMENT_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED` |

## Missing ontology and runtime capability

- Editable, persistent Life Area identity and lifecycle.
- Complete Goal lifecycle axes and closure/history semantics.
- Canonical Event, recurring series, occurrence, import/link, and source ownership records.
- Canonical Schedule Placement and grouped Schedule Change Set records.
- Explicit accepted-versus-proposed placement state in all Time projections.
- A defined Today priority relation if “priority” means more than ranked Step projection.
- Durable full-day reshape, grouped adjustment, and owner-transfer contracts.
- One inspectable availability/capacity model connecting calendar facts, protected time, personal choice, energy, cognitive load, transition friction, and recovery.
- Exact Time object routing that carries the selected Step/Event/Placement identity, not only Goal ID.
- Current-head executable proof for cross-root mutations, replay, restoration, and owner return.

## Visual-assumption comparison

### AVF-GOALS-S07-R01 — Linked Goal Lens

**Capability status:** `PARTIALLY_SUPPORTED`.

Survives:

- A selected Goal can expose its identity, plan, current Step(s), completed/planned sections, timing, and related context from one repository-backed object graph.
- The lens can remain inline in Goal-owned detail and act as a projection, not a second route owner.
- Multiple active Steps are representable because `PlanningStrategy` has `allowParallelSteps` and `maxActiveSteps`.

Requires refinement or branch:

- At Goals root, current canon foregrounds editable Life Areas; the provisional living Goal index cannot silently replace it.
- “One relationship” and continuity/history must disclose only relationships and lineage actually resolved from current records.
- Complete settled history, full closure states, and Receipt continuity are not generally proven.

Disposition: `VISUAL_DIRECTION_SURVIVES`, `TARGETED_VISUAL_REFINEMENT_REQUIRED`, and, for the root composition, `NEW_VISUAL_BRANCH_MAY_BE_REQUIRED`.

### AVF-TIME-S07-R00 — Integrated Period Atlas

**Capability status:** `PARTIALLY_SUPPORTED` with major planned capability.

Survives:

- Week is the strongest live temporal scale.
- Protected, fixed, flexible, scheduled-Step, recovery, buffer, and external-busy distinctions exist in current models.
- Goal/Step-linked TimeBlocks and overlap conflicts support meaningful integration.

Requires refinement or removal:

- Day/Month/Year/longer-scale behavior, canonical Event detail, recurrence, complete calendar replacement, personal availability, transition friction, and full preview/current/proposed chronology are not established as usable behavior.
- “Week default” must not erase the canonically remembered last-used view.
- Computed Goal timing must be styled as proposed unless an accepted placement exists.

Disposition: `VISUAL_DIRECTION_SURVIVES` in concept, `RUNTIME_CAPABILITY_REQUIRED`, `RECONSTRUCTION_PLAN_ACTION_REQUIRED`, and `UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE` for unimplemented calendar-grade details shown as current.

### AVF-TODAY-S09-R00 — Contextual Today Command

**Capability status:** `PARTIALLY_SUPPORTED` and canon-conflicted.

Survives:

- Today can show a small set of Step-backed objects with Goal identity and narrow contextual actions.
- Today can remain an execution lens and route complex temporal work to Time.
- A quiet/empty state is supported by current projection models.

Requires branch/decision:

- “What Matters Today” and up to three root objects conflict with the current canon’s single dominant `Start here` viewport.
- The present implementation’s three “What fits now” rows cannot be used to overrule canon or treated as visual authority.
- A full-day Today model, current/upcoming execution rail, interruption semantics, and exact owner return require further implementation proof.

Disposition: `VISUAL_DIRECTION_SURVIVES` for object-led contextual action; `NEW_VISUAL_BRANCH_MAY_BE_REQUIRED` for first-viewport hierarchy; `UX_BLUEPRINT_DECISION_REQUIRED`.

## Required decisions

### Devan

- Decide whether the protected provisional Goals and Today compositions should be reconciled to current canon, or whether canon/visual authority should later be changed through a separate authorized process. This audit does not select the winner.
- Decide whether Week is a first-use default only, while preserving last-used view, or a stronger reset rule.
- Decide whether Today’s “priority object” is a projection of existing objects or a new day-specific relation.

### Architecture

- Define canonical Life Area persistence and Goal membership.
- Define Event, Schedule Placement, TimeBlock, occurrence, and source identities and migrations.
- Establish one fit/capacity contract shared by Today and Time without giving Today schedule ownership.
- Define accepted/proposed placement state and exact owner-routing targets.

### UX Blueprint

- Reconcile Goals root: Life Area index versus living Goal index/lens.
- Reconcile Today root: one `Start here` versus up to three “What Matters Today” objects.
- Define day-specific versus persistent meaning, compact local actions versus owner handoff, and personally usable opening versus merely calendar-open time.
- Define how proposed, accepted, external, protected, flexible, conflict, and recovery states remain legible without creating duplicate object meanings.

### Runtime

- Implement and prove canonical Event/Placement graphs, full lifecycle/history, grouped reflow, availability/capacity inputs, and cross-root owner commands.
- Close current unproven Goals, Step, Time, and EventKit mutation rows.

### Reconstruction planning

- Put identity/ownership migrations ahead of rebuilding root visuals.
- Treat the current three-item Today block and week-only Time view as implementation evidence, not target authority.
- Add focused behavioral proof per owner boundary before declaring a visual assumption supported.

## Unsupported assumptions

- Goals root can already truthfully be only a living Goal index: `CONTRADICTED` by current canon’s Life Area root.
- Today’s locked label/count already match current product authority: `CONTRADICTED` by current canon, despite similar legacy/current source count.
- Every Goal-timed Step shown in Time has an accepted placement: `CONTRADICTED` by the projection’s ordinary rendering of plan timing.
- Time is currently a complete calendar replacement: `ABSENT` as proven behavior; canon explicitly says the spec/build do not prove replacement.
- Native Ambitions Event identity and recurrence already exist: `ABSENT` in the declared object-store schema.
- Day, Week, Month, Year, and List have current parity: `PLANNED_NOT_IMPLEMENTED` based on inspected evidence.
- Personal availability is equivalent to calendar-open time: `CONTRADICTED` by the typed availability distinctions and incomplete live heuristic.
- Today owns broad rescheduling or day-wide mutation: `CONTRADICTED` by canonical owner handoff.
- Full Goal closure/history/Receipt behavior is implemented: `CONTRADICTED` by compressed lifecycle and proof registry.

## Reconstruction implications

1. Reconcile canon and provisional compositions before Figma or SwiftUI reconstruction; otherwise the team would build mutually incompatible roots.
2. Establish editable Life Areas and migration before a canon-compliant Goals root can be considered complete.
3. Establish canonical Event and Schedule Placement identities before Time can claim calendar replacement or cross-root temporal continuity.
4. Split proposed Goal timing from accepted Time placement in projection models and visual semantics.
5. Define a shared availability/capacity projection that respects personal choice, protected time, external-source uncertainty, energy, transition, and recovery.
6. Preserve Today as an execution lens: contextual actions may originate there, but the underlying Goal/Step/Placement owner must validate and commit.
7. Build tests for owner handoff, projection identity, accepted/proposed placement, last-used Time view, Life Area editing, Today eligibility, dense/quiet-day behavior, and exact return.
8. Delete or migrate duplicate authority only after canonical records and lineage are proven; this audit does not designate files for immediate deletion.

## Evidence appendix

### E-RP04-01 — Goals owns stable Goal/Step structures, not the full canonical lifecycle

- **Claim:** Live Goal, Plan, Section, and Step structures support a meaningful Goal lens, while the complete canon lifecycle/path/history contract is not implemented.
- **Capability status:** `PARTIALLY_SUPPORTED`.
- **Source:** `Native/Ambitions/Core/Domain/GoalEngine/GoalEnginePlanSection.swift:3-91,140-205`; `Native/Ambitions/Core/Domain/Step.swift:11-25`; `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineContracts.swift:86-109,314-323`; `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataModels.swift:4-288`.
- **Authority/currentness:** Current production domain and persistence source.
- **Verification/result:** Static inspection confirms IDs, plan version, ordered sections, Step membership, and parallel-step strategy; live lifecycle omits canonical states.
- **Confidence:** High.
- **Remaining uncertainty:** No current-head runtime test executed due simulator boot failure.
- **Affected direction:** `AVF-GOALS-S07-R01`.

### E-RP04-02 — Goals root conflict

- **Claim:** Current canon requires a native editable Life Area index, while live implementation lacks editable persisted Life Areas and the provisional visual root is Goal-led.
- **Capability status:** `CONTRADICTED`.
- **Source:** `docs/canon/specifications/surfaces/goals.md:2152-2197`; `docs/canon/specifications/objects/life-area.md:37-119`; `Native/Ambitions/Core/Domain/LifeArea.swift:19-37`; `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift:142-164`; attached VC-08.
- **Authority/currentness:** Current canon and current source; attached record is protected provisional input.
- **Verification/result:** Canon/source comparison identifies both target-versus-implementation and canon-versus-provisional conflicts.
- **Confidence:** High.
- **Remaining uncertainty:** The eventual product decision is intentionally unresolved.
- **Affected direction:** `AVF-GOALS-S07-R01`.

### E-RP04-03 — Today is a Step-backed projection

- **Claim:** Today derives ranked Steps from active/paused repository Goals and carries Goal/Step IDs into contextual actions.
- **Capability status:** `SUPPORTED` for identity lineage; `PARTIALLY_SUPPORTED` for full eligibility/fit.
- **Source:** `Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService+Repository01-makeExperience.swift:5-38,77-100`; `Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService+Repository06-adjustmentPayload.swift:105-160`; `Native/Ambitions/Surfaces/Today/Projection/TodayGoalStepActionCommandAdapter.swift:7-53`; `Native/Ambitions/Core/LocalRuntimeOS/Planning/PlanningNextStepSelector.swift:22-140`.
- **Authority/currentness:** Current production projection and command preparation.
- **Verification/result:** Static dataflow trace establishes read, rank, render, and owner-target preparation.
- **Confidence:** High.
- **Remaining uncertainty:** Runtime mutation result and restoration were not executed.
- **Affected directions:** `AVF-TODAY-S09-R00`, `AVF-GOALS-S07-R01`.

### E-RP04-04 — Today priority conflict

- **Claim:** Canon’s single dominant `Start here` conflicts with the locked provisional three-object region; live source’s three “What fits now” rows do not resolve the authority conflict.
- **Capability status:** `CONTRADICTED`.
- **Source:** `docs/canon/specifications/surfaces/today.md:913-960`; `Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService+Repository06-adjustmentPayload.swift:120-160`; attached VC-07.
- **Authority/currentness:** Current canon outranks current implementation residue and provisional visual intent for product contract.
- **Verification/result:** Direct authority comparison.
- **Confidence:** High.
- **Remaining uncertainty:** Requires Devan/UX decision.
- **Affected direction:** `AVF-TODAY-S09-R00`.

### E-RP04-05 — Time supports local blocks and a week projection, not complete calendar behavior

- **Claim:** Time has a week-oriented repository-backed projection, persisted local blocks, and conflict semantics, but lacks evidence of a complete canonical Event/calendar surface.
- **Capability status:** `PARTIALLY_SUPPORTED`.
- **Source:** `Native/Ambitions/Surfaces/Time/Projection/RepositoryBackedTimeService.swift:4-91`; `Native/Ambitions/Surfaces/Time/Projection/TimeProjectionSnapshot.swift:4-58`; `Native/Ambitions/Surfaces/Time/Projection/TimeWeekShapeProjection.swift:23-175`; `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/TimeBlockGraph.swift:3-200`; `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LifeCalendarStore.swift:38-151`; `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift:142-164`.
- **Authority/currentness:** Current production source and declared schema.
- **Verification/result:** Static source and schema inspection. No canonical `EventRecord`/`SchedulePlacementRecord` is declared.
- **Confidence:** High.
- **Remaining uncertainty:** No simulator behavior proof; adjacent experimental models do not establish production completion.
- **Affected direction:** `AVF-TIME-S07-R00`.

### E-RP04-06 — Proposed-versus-accepted placement conflict

- **Claim:** Live week projection renders Goal-plan timing as ordinary blocks when no persisted TimeBlock carries that Step ID, while canon requires unaccepted Steps to be explicitly non-durable proposals.
- **Capability status:** `CONTRADICTED`.
- **Source:** `docs/canon/specifications/surfaces/time.md:3951-3963`; `Native/Ambitions/Surfaces/Time/Projection/TimeWeekShapeProjection.swift:23-54,65-130`.
- **Authority/currentness:** Current normative canon plus current production projection.
- **Verification/result:** Static branch/data-model inspection finds no proposal flag on the constructed `TimeWeekBlockState`.
- **Confidence:** High.
- **Remaining uncertainty:** Styling elsewhere could add a visual distinction, but the projection contract shown here does not encode accepted/proposed authority; therefore support cannot be claimed.
- **Affected directions:** `AVF-TIME-S07-R00`, `AVF-TODAY-S09-R00`, `AVF-GOALS-S07-R01`.

### E-RP04-07 — Current proof ceiling

- **Claim:** Bounded durable Time/Today paths exist, but broad Goals/Step/Time mutation ownership remains unproven at this SHA.
- **Capability status:** `PARTIALLY_SUPPORTED`.
- **Source:** `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift:130-180,211-302`; `docs/qa/architecture/architecture-modernization-current-state.md:32-83,149-158`.
- **Authority/currentness:** Current exhaustive registry and architecture reconciliation.
- **Verification/result:** `python3 scripts/ambitions-canon.py check` passed. `python3 scripts/ambitions-architecture-10-scorecard-check.py` failed because it cites purged evidence paths; that is checker staleness, not behavior proof. Shared targeted XCTest execution ended at simulator boot with zero tests executed.
- **Confidence:** High for the proof ceiling; runtime behavior remains unverified.
- **Remaining uncertainty:** Current-head executable results.
- **Affected directions:** `AVF-GOALS-S07-R01`, `AVF-TODAY-S09-R00`, `AVF-TIME-S07-R00`.

## Packet self-review

- Goals, Today, and Time ownership conclusions match RP-02.
- Canon target, live implementation, test-source inventory, and provisional intent are kept distinct.
- No legacy UI count or label is treated as product authority.
- No type is promoted to usable behavior without sufficient source or proof.
- All unresolved product choices remain decisions, not audit conclusions.
- No implementation plan, source edit, visual rewrite, or approval is included.
