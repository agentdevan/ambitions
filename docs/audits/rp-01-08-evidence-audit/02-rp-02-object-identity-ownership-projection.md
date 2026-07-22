<!-- markdownlint-disable MD013 MD060 -->

# RP-02 — Object Identity, Ownership, and Projection

Audit base: `main` at `29872755f705f6bd8e276aeac86dcf376ac5f0d8`

Capability vocabulary: `SUPPORTED`, `PARTIALLY_SUPPORTED`, `PLANNED_NOT_IMPLEMENTED`, `ABSENT`, `CONTRADICTED`, `DEPRECATED_OR_SUPERSEDED`, `DEBUG_OR_FIXTURE_ONLY`, `UNKNOWN`

## Executive verdict

RP-02 is **PARTIALLY_SUPPORTED** and structurally incomplete.

The live repository establishes durable local identities for Goal, Goal Draft, Goal Plan, Plan Section, and Step records. Today reads those Goal/Step objects, projects a Step by its existing identifier, and carries `goalID` plus `stepID` into owner-routed actions. Time also reads the same repositories and can retain Goal/Step identifiers in persisted `TimeBlock` relationships. Those facts support a bounded continuity claim for implemented Goal/Step flows.

The repository does not yet implement the full canonical identity graph promised by canon. The live SwiftData schema has no `LifeAreaRecord`, canonical `EventRecord`, `SchedulePlacementRecord`, or Today-priority record. Life Areas are compiled from a fixed enum rather than stored editable objects; `TimeBlock` is a useful local scheduling record but does not implement the complete Schedule Placement or Event contract; and the current mutation registry labels most Goals and several Step/Time paths unproven. Therefore the provisional visual program may preserve continuous Goal/Step identity, but it must not visually imply universal cross-root identity, complete owner-safe editing, canonical Events, or durable history/Receipt linkage where those capabilities are absent or unproven.

Primary dispositions:

- `VISUAL_DIRECTION_SURVIVES` for identity continuity of repository-backed Goals and Steps.
- `TARGETED_VISUAL_REFINEMENT_REQUIRED` wherever a projection must disclose that it is a Goal/Step lens rather than a separately owned object.
- `ARCHITECTURE_DECISION_REQUIRED` and `RUNTIME_CAPABILITY_REQUIRED` for Life Areas, Events, Schedule Placements, broad cross-root identity, deletion lineage, and universal owner routing.
- `UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE` for any depiction that treats a Today priority, calendar event, personal-context object, or Search result as one canonical editable object without an implemented identity and owner.

## Scope

This packet audits canonical object identity, persistence, owner boundaries, cross-root projection lineage, edit authority, history/deletion behavior, and the assumptions carried by:

- `AVF-GOALS-S07-R01`
- `AVF-TIME-S07-R00`
- `AVF-TODAY-S09-R00`
- `AVF-SEARCH-D07-R00`
- `AVF-COHERENCE-S07-R00`

It does not approve a visual direction, infer runtime behavior from a type, or repair missing ontology.

## Authoritative sources

| Authority | Source | Use in this packet |
| --- | --- | --- |
| Generated current canon | `docs/canon/generated/object-boundary-matrix.md:1-27` | Generated boundary between Step, Event, Reminder, Note, and Schedule Placement. |
| Normative object canon | `docs/canon/specifications/objects/goal.md:70-117`; `goal-path.md:61-128`; `life-area.md:37-109`; `event.md:87-130`; `receipt.md:25-79`; `schedule-placement.md:30-111` | Target identity, ownership, lifecycle, projection, history, and deletion laws. |
| Normative surface canon | `docs/canon/specifications/surfaces/today.md:913-1049`; `goals.md:2152-2249`; `time.md:3951-4170` | Surface ownership and lens behavior. |
| Current persistence source | `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataModels.swift:4-288`; `ObjectStoreSwiftData.swift:142-240` | Actually stored identities and declared mutation authorities. |
| Current domain source | `Native/Ambitions/Core/Domain/GoalEngine/GoalEnginePlanSection.swift:3-91`; `GoalEngineContracts.swift:86-109`; `Step.swift:11-25`; `LifeArea.swift:3-37` | Implemented object shapes and lifecycle vocabulary. |
| Current projections | `Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService+Repository01-makeExperience.swift:5-38`; `Repository06-adjustmentPayload.swift:105-160`; `TodayGoalStepActionCommandAdapter.swift:7-53`; `Native/Ambitions/Surfaces/Time/Projection/TimeProjectionSnapshot.swift:4-58`; `TimeWeekShapeProjection.swift:23-150` | Real lineage into Today/Time and action routing. |
| Current scheduling source | `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/TimeBlockGraph.swift:3-200`; `LifeCalendarStore.swift:38-151` | Implemented local temporal identity and persistence. |
| Current proof inventory | `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift:130-180,211-302`; `docs/qa/architecture/architecture-modernization-current-state.md:32-83` | Proof ceiling and unproven owner paths. |
| Provisional input | Attached Campaigns, readiness pass, and locked decisions | Protected visual intent and assumptions to test; not repository capability evidence. |

## Canonical object inventory

“Canonical” in the target column means canon declares the object canonical. “Live” requires a current production model/store or an authoritative completed contract, not merely a name.

| Object or relation | Canonical target | Live implementation finding | Status | Source evidence |
| --- | --- | --- | --- | --- |
| Life Area | Stable, editable organizing object, one identity across surfaces | Fixed `LifeDomainKey`-derived values; no live stored `LifeAreaRecord` found in the declared SwiftData schema | `CONTRADICTED` | `life-area.md:37-41,74-109`; `LifeArea.swift:3-37`; `ObjectStoreSwiftData.swift:142-164` |
| Goal | Stable desired outcome with one current Goal Path and retained lineage | `GoalRecord.id` is unique; record has revision, lifecycle, relationships, timing and snapshot | `PARTIALLY_SUPPORTED` | `goal.md:70-109`; `ObjectStoreSwiftDataModels.swift:4-97` |
| Goal Draft | Provisional intent before accepted Goal | Unique stored record with optional promoted `plannedGoalID` | `SUPPORTED` for storage/identity; promotion lineage only `PARTIALLY_SUPPORTED` | `ObjectStoreSwiftDataModels.swift:99-132`; `ObjectStoreSwiftData.swift:181-189` |
| Goal Path / Goal Plan | One current identity with immutable version lineage | `GoalPlan`/`GoalPlanRecord` have id, goalID and version; complete immutable version/history semantics are not proven | `PARTIALLY_SUPPORTED` | `goal-path.md:61-118`; `GoalEnginePlanSection.swift:57-91`; `ObjectStoreSwiftDataModels.swift:134-167` |
| Plan Section / Path node grouping | Ordered structure under one Goal Plan | Unique `PlanSectionRecord` and nested `[Step]`; not the full canonical node-role ontology | `PARTIALLY_SUPPORTED` | `goal-path.md:30-32`; `ObjectStoreSwiftDataModels.swift:169-196`; `GoalEnginePlanSection.swift:3-10` |
| Step | Stable executable unit referenced by Goal/Time/Today | Unique stored Step ID with goalID/planID/sectionID; live domain `Step` retains id and sectionID | `SUPPORTED` for core identity; `PARTIALLY_SUPPORTED` for full canon lifecycle/history | `object-boundary-matrix.md:8-27`; `ObjectStoreSwiftDataModels.swift:198-288`; `Step.swift:11-25` |
| Today target / priority | Projection, not an independent owner | `TodayTargetItem.id` reuses the Step ID and action target carries Goal/Step IDs; no Today object record | `SUPPORTED` as a Goal/Step projection; `ABSENT` as a canonical Today-priority object | `Repository06-adjustmentPayload.swift:120-159`; `TodayFeatureModels+02-TodayTargetItem.swift:4-46`; `ObjectStoreSwiftData.swift:142-164` |
| Schedule Placement | One identified relationship between object and Time, not a copied Step/Event | No `SchedulePlacementRecord`; `TimeBlock` has its own ID plus optional Step/Goal/Event references and a narrower block lifecycle | `PARTIALLY_SUPPORTED` | `object-boundary-matrix.md:22-27`; `schedule-placement.md:30-57`; `TimeBlockGraph.swift:49-100`; `ObjectStoreSwiftData.swift:142-164` |
| TimeBlock / Life Calendar block | Implementation-specific local temporal record | Stable deterministic ID, source, kind, range and optional object IDs; JSON persistence in `LifeCalendarStore` | `SUPPORTED` as current implementation object, not as full canonical Event/Placement | `TimeBlockGraph.swift:3-100`; `LifeCalendarStore.swift:38-151` |
| Event | Canonical fixed-by-default time-range commitment with recurrence/source/series identity | Canon is complete, but no `EventRecord` or Event repository appears in the current object-store schema; `EventLedgerRecord` is not the canonical Event model | `PLANNED_NOT_IMPLEMENTED` | `event.md:39-59,87-130`; `ObjectStoreSwiftData.swift:142-164`; `RepositoryBackedTimeService.swift:51-91` |
| Reminder | Separate object, not work completion | `ReminderRecord` is present in the schema; this packet did not establish complete lifecycle and owner behavior | `PARTIALLY_SUPPORTED` | `object-boundary-matrix.md:8-26`; `ObjectStoreSwiftData.swift:150-153` |
| Progress Evidence / Proof | User evidence linked to a Goal | Stored `ProgressEvidenceRecord` and proof projection model; full canonical Proof object law is outside this packet | `PARTIALLY_SUPPORTED` | `ObjectStoreSwiftData.swift:148,223-230` |
| Capture | Stored intake object with optional Goal linkage | Unique Capture record and `linkedGoalID`; mutation paths remain largely unproven | `PARTIALLY_SUPPORTED` | `ObjectStoreCaptureRecord.swift:4-34`; `ObjectStoreSwiftData.swift:213-220`; `MeaningfulMutationRegistry.swift:164-206` |
| Receipt | Durable mutation record linked to object/history in canon | Receipt history and runtime snapshot records are stored; only bounded Today/Time paths have durable registry status | `PARTIALLY_SUPPORTED` | `receipt.md:25-79`; `ObjectStoreSwiftData.swift:232-239`; `MeaningfulMutationRegistry.swift:132-149,213-281` |
| History Event / Event ledger | Exact before/after mutation history in canon | An `EventLedgerRecord` exists, but current source also uses it as a calendar-observation mirror; complete canonical History Event coverage is not established | `PARTIALLY_SUPPORTED` | `ObjectStoreSwiftData.swift:153`; `RepositoryBackedTimeService.swift:79-84`; `goal.md:99-100` |
| Conflict | Typed temporal conflict for overlapping blocks | `TimeBlockConflict` has stable ID, block IDs, severity and reason; general cross-domain conflict identity is not established | `PARTIALLY_SUPPORTED` | `TimeBlockGraph.swift:137-196` |
| Personal context / availability | Typed context and availability facts | Models exist, including protected and user-choice-only availability; canonical persistence and cross-root owner are not established here | `PARTIALLY_SUPPORTED` | `TimeContextHierarchy.swift:5-113,355-395`; `ObjectStoreSwiftData.swift:160` |
| Search result | Projection of another object | Search is canonically a lens, but RP-05 owns full Search verification; no independent Search result should be inferred as a canonical editable object | `UNKNOWN` for full coverage | `schedule-placement.md:40-57`; `goal.md:108-109` |

## Object identity matrix

| Object | Stable identifier in source | Persistence | Historical identity | Projection identity | External identity / merge | Deletion behavior | Assessment |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Goal | `String` `Goal.id`; unique `GoalRecord.id` | SwiftData | Revision field exists; full lifecycle/history contract exceeds implemented enum | Today/Time retain Goal ID | Import/re-import reconciliation is canon only in this packet | Repository exposes delete; canon requires Trash/restore/governed deletion | `PARTIALLY_SUPPORTED` |
| Goal Plan | `GoalPlan.id`, `goalID`, `version` | SwiftData plan record | Version integer exists; immutable lineage and rollback not proven | Today uses nested Steps; Time derives plan Steps | Not established | Coupled to Goal in live model; exact deletion lineage unknown | `PARTIALLY_SUPPORTED` |
| Step | `String` `Step.id`; unique `StepRecord.id` | SwiftData | Lifecycle exists; replay/history coverage incomplete | Today target reuses Step ID; TimeBlock may link `stepID` | External identity not established | Stored under Goal/Plan; governed independent deletion is unknown | `PARTIALLY_SUPPORTED` |
| Life Area | `LifeAreaID` equals enum raw value | Compiled fixed list, not a user-edited store | None established for rename/hide/archive | Life Area projections can retain enum-derived ID | Not applicable | Canonical editable deletion/restore absent | `CONTRADICTED` |
| Today target | Reuses Step ID | Computed | Inherits Step history only | It is the projection | Not separate | Disappears when ineligible; does not delete Step | `SUPPORTED` as projection |
| TimeBlock | Stable `String` ID, optionally deterministic; links Step/Goal/Event IDs | Atomic JSON snapshot | Store overwrites by block ID; canonical append-only placement history is not established | Time reads same block ID; Goal routing may retain only Goal ID | `source` and `eventID` fields exist; merge law not proven | Explicit delete by block ID; Trash/restore contract absent | `PARTIALLY_SUPPORTED` |
| Event | Canonical Event/series/occurrence IDs specified | No canonical Event store found | Canon only | Canon requires IDs in Time/Today/Goals | Canon specifies source reconciliation | Canon specifies cancel/archive/Trash/restore/delete | `PLANNED_NOT_IMPLEMENTED` |
| Receipt | Receipt ID inside encoded record/lineage | SwiftData receipt history | Intended immutable lineage | Trust/You/Search projection contract | External-effect status intended | Governed retention/deletion canon | `PARTIALLY_SUPPORTED` |

## Owning-root matrix

Surface is not mutation authority. “Owner” below separates presentation owner from canonical behavior owner.

| Meaningful object | Primary presentation | Contextual projections | Canonical behavior/mutation owner | Current source evidence | Status |
| --- | --- | --- | --- | --- | --- |
| Life Area | Goals | You/Search may inspect | `Core/Domain` + `Core/LocalRuntimeOS` | Canon names owner; live values are fixed enum-derived objects | `CONTRADICTED` |
| Goal | Goals | Today, Time, You, Search, Trust | Commands/Transactions/EventJournal; Goals presents | Store manifest declares command/runtime authority; many Goals surface paths remain registry-unproven | `PARTIALLY_SUPPORTED` |
| Goal Path / Plan | Goals | Today “now”; Time placements; Search/Trust inspection | Planning/Scheduling/Commands/Inspection | Stored plan and Step structure present; complete path command lineage unproven | `PARTIALLY_SUPPORTED` |
| Step | Goals for path; Today for execution context; Time for placement | Search/Trust and external surfaces | Planning + Scheduling + Transactions | Manifest declares authority; Today adapter resolves Goal/Step before preparation | `PARTIALLY_SUPPORTED` |
| Today target | Today | None as a new owner | Inherits Goal/Step owner | Computed from repository Goals and Steps | `SUPPORTED` |
| Schedule Placement / TimeBlock | Time | Today/Goals contexts | Scheduling/Commands | TimeBlock store and durable command adapters exist; canonical placement record absent | `PARTIALLY_SUPPORTED` |
| Event | Time | Today/Goals/Search/Trust | Scheduling/ExternalWrites/Commands/Inspection | Canon only; current Time calendar awareness observes external facts and appends ledger | `PLANNED_NOT_IMPLEMENTED` |
| Receipt | Trust/You inspection | Affected objects, Search, Motion | Inspection/Commands | Receipt storage exists; bounded durable paths only | `PARTIALLY_SUPPORTED` |

## Projection lineage matrix

| Projection | Source → projection lineage | Stored/copied/computed | Mutation route | Finding |
| --- | --- | --- | --- | --- |
| Goal → Today | Goal repository → active/paused Goals → ranked plan Steps → `TodayTargetItem(id: step.id)` | Computed | `TodayActionTarget(goalID, stepID)` → reload canonical Goal/Step → planner | Strong bounded lineage; `SUPPORTED` for Goal/Step projection. |
| Goal → Time week | Goal repository → Goal Plan Steps with planned date → `TimeWeekBlockState` | Computed | Rows route through `GoalRouteTarget(goalID)`; selected Step identity is not carried in that route target | `PARTIALLY_SUPPORTED`; read identity is stronger than focused edit routing. |
| Step → durable Time block | Runtime time command/event → `TimeBlock(stepID, goalID, commandID, eventID)` → `LifeCalendarStore` | Stored relationship | Scheduling/runtime command | `PARTIALLY_SUPPORTED`; implementation block is not the full canonical Schedule Placement object. |
| TimeBlock → Today | Same Life Calendar block graph can inform scheduled Today behavior | Computed from stored block | Owner should remain Time/Scheduling | `PARTIALLY_SUPPORTED`; exact full-day projection lineage is not established in this packet. |
| Goal → Life Area | Goal may carry life-graph context; Life Area reference retains Goal ID | Computed | Canon requires Goals owner | `PARTIALLY_SUPPORTED`; Life Area itself is not a stored editable object. |
| Receipt → object | Encoded receipt history and runtime lineage should carry affected IDs | Stored | Inspection/Commands | `PARTIALLY_SUPPORTED`; universal coverage is not proven. |
| Event → Today/Goals/Search | Canon requires Event/series/occurrence IDs | Not implemented as canonical record | Canonical Event commands planned | `PLANNED_NOT_IMPLEMENTED`. |

## Editing and mutation authority matrix

| Operation | Permitted owner according to current authority | Projection-local narrow action | Current proof ceiling | Status |
| --- | --- | --- | --- | --- |
| Create/edit/close/archive Goal | Goals UI originates; LocalRuntimeOS command owner commits | Today/Time may hand off or prepare a typed Goal/Step action | Registry marks Goal creation and mutation rows unproven | `PARTIALLY_SUPPORTED` |
| Complete/defer/reschedule a projected Step from Today | Goal/Step owner through prepared durable action | Yes; Today supplies action context but reloads Goal and Step by IDs | Adapter exists; durable proof is path-specific, not universal | `PARTIALLY_SUPPORTED` |
| Place/protect/correct time | Scheduling/Time runtime owner | Goals/Today may transfer | Some Time command paths are durable; simple Step placement and EventKit paths remain unproven | `PARTIALLY_SUPPORTED` |
| Edit Event | Canonical Event owner in Scheduling/Commands | Time presents details; external item may require source handoff | No canonical Event store found | `PLANNED_NOT_IMPLEMENTED` |
| Edit Life Area | Canon requires one LocalRuntimeOS owner | Goals presents | Live Life Areas are static derived values | `ABSENT` |
| Edit Today priority as independent object | No independent owner should exist unless architecture defines one | Today may act on underlying object or day-specific relation | No Today-priority store or owner | `ABSENT` |
| Search-local mutation | Must route to canonical object owner | Search may inspect/prepare/transfer | Full Search authority belongs to RP-05; no proof here | `UNKNOWN` |

## History and deletion matrix

| Object | Canonical requirement | Current evidence | Status | Remaining uncertainty |
| --- | --- | --- | --- | --- |
| Goal | Separate completion, Ended, archive, Trash, restore, permanent deletion; receipts/history retained | Live enum has draft/active/paused/completed/archived; repository has direct delete | `CONTRADICTED` | Whether other services emulate missing states does not establish one canonical lifecycle. |
| Goal Path | Immutable version lineage; accepted material edits retain before/after, rollback target | Version field exists | `PARTIALLY_SUPPORTED` | No current executable proof in this audit for immutable multi-version retention and rollback. |
| Step | Stable identity through scheduling/execution/recurrence and governed deletion | Stored ID and lifecycle exist | `PARTIALLY_SUPPORTED` | Cancellation exists, but canonical Trash/restore/history coverage is unverified. |
| Life Area | Hide/archive/Trash/restore retain identity; user can rename/reorder/remove defaults | Static list has no stored lifecycle | `ABSENT` | Requires ontology and migration decisions. |
| TimeBlock | Store can save/replace/delete by ID | JSON actor store implements those operations | `SUPPORTED` for block CRUD; `ABSENT` for canonical Trash/history semantics | Direct deletion is not canonical Event/Placement governed deletion. |
| Event | Canon specifies cancel/archive/Trash/restore/delete and recurrence scope | No canonical Event record | `PLANNED_NOT_IMPLEMENTED` | External EventKit state does not substitute for local canonical Event identity. |
| Receipt/history | Canon requires durable linkage and governed retention | Stored receipt/history types; bounded durable rows | `PARTIALLY_SUPPORTED` | Current architecture report is Red and current-head runtime tests did not execute. |

## Unsupported identity assumptions and duplicate-owner risks

| Assumption or risk | Repository finding | Status | Required disposition | Affected directions |
| --- | --- | --- | --- | --- |
| One editable Life Area object survives across Goals, You, Search, and history | Canon requires it; live source synthesizes fixed values from `LifeDomainKey` and has no stored record | `CONTRADICTED` | `ARCHITECTURE_DECISION_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED` | `AVF-GOALS-S07-R01`, `AVF-SEARCH-D07-R00`, `AVF-COHERENCE-S07-R00` |
| A Today priority is one canonical object | Live Today items are Step projections; there is no Today-priority record | `ABSENT` as separate object | Preserve underlying Step identity or `UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE` | `AVF-TODAY-S09-R00`, `AVF-COHERENCE-S07-R00` |
| Every temporal block is a canonical Event or Schedule Placement | `TimeBlock` can link IDs, but canonical Event and Placement records are absent | `CONTRADICTED` | `TARGETED_VISUAL_REFINEMENT_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED` | `AVF-TIME-S07-R00`, `AVF-TODAY-S09-R00`, `AVF-SEARCH-D07-R00`, `AVF-COHERENCE-S07-R00` |
| Time rows can always return to the exact Step owner | Computed context retains Step ID internally, but `TimeWeekBlockState.target` routes only by Goal ID | `PARTIALLY_SUPPORTED` | `RECONSTRUCTION_PLAN_ACTION_REQUIRED` | `AVF-TIME-S07-R00`, `AVF-GOALS-S07-R01`, `AVF-COHERENCE-S07-R00` |
| String-shaped source/receipt/replay IDs prove durable records | Planning selector constructs display strings without loading durable Source/Receipt/Replay records | `CONTRADICTED` | `UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE` until backed by real records | `AVF-TODAY-S09-R00`, `AVF-SEARCH-D07-R00`, `AVF-COHERENCE-S07-R00` |
| Goal lifecycle supports Ready, Ended, Trash, restore, and permanent deletion as one implemented contract | Live enum omits those states | `CONTRADICTED` | `RUNTIME_CAPABILITY_REQUIRED` | `AVF-GOALS-S07-R01`, `AVF-SEARCH-D07-R00`, `AVF-COHERENCE-S07-R00` |
| All cross-root mutations already use one owner | Manifest declares intended owners, but registry marks many Goals/Step/Time/Capture writes unproven | `PARTIALLY_SUPPORTED` | `RECONSTRUCTION_PLAN_ACTION_REQUIRED` | All affected directions |
| Multiple Step identity types are safely unified | Persisted Goal Steps use `String`; temporal occurrence/context models also use `UUID` identifiers | `UNKNOWN` | `ARCHITECTURE_DECISION_REQUIRED`; document bridge or prove separation | `AVF-TIME-S07-R00`, `AVF-TODAY-S09-R00`, `AVF-COHERENCE-S07-R00` |

## Visual-assumption comparison

| Protected provisional assumption | Capability | Evidence-based disposition | Audit conclusion |
| --- | --- | --- | --- |
| Inline Linked Goal Lens below selected Goal | `PARTIALLY_SUPPORTED` | `VISUAL_DIRECTION_SURVIVES`, `TARGETED_VISUAL_REFINEMENT_REQUIRED` | Goal and nested Step identities exist. The lens must remain a projection of Goal/Plan/Step, not a second stored route or path. Full current/completed/planned/history claims must stay bounded to implemented states. |
| Integrated Period Atlas presents one underlying object across Goals/Time/Today | `PARTIALLY_SUPPORTED` | `TARGETED_VISUAL_REFINEMENT_REQUIRED`, `ARCHITECTURE_DECISION_REQUIRED` | Goal/Step linkage survives; Event, Placement, Life Area, and broad personal-context linkage do not yet meet the same standard. |
| Today priority objects preserve identity and return to owner | `PARTIALLY_SUPPORTED` | `VISUAL_DIRECTION_SURVIVES` for Step-backed items; `UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE` for invented priority objects | The current implementation reuses Step IDs and carries Goal/Step targets. |
| Semantic Search consolidates identities across roots | `UNKNOWN` | `ARCHITECTURE_DECISION_REQUIRED`, `IMPLEMENTATION_DETAIL_DEFERRED` | The underlying Goal/Step graph can support bounded consolidation; universal coverage cannot be claimed without Event/Placement/Life Area identities and Search proof. |
| Native Semantic Continuum means every projection is the same canonical object | `PARTIALLY_SUPPORTED` | `TARGETED_VISUAL_REFINEMENT_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED` | True for bounded Goal/Step projections; false or unknown for several other provisional object families. |

## Contradictions

1. **Editable Life Area canon versus static implementation.** Canon requires editable, retained Life Area identity (`life-area.md:37-41,87-119`), while live source creates a fixed list from an enum (`LifeArea.swift:19-37`). This is a real target-versus-implementation conflict, not generated drift.
2. **Single canonical temporal graph versus split implementation records.** Canon forbids divergent projection stores (`schedule-placement.md:40-57`); live Time combines Goal-plan timing projections with separately persisted `TimeBlock` records (`TimeWeekShapeProjection.swift:23-150`). The two paths are deduplicated by Step ID where possible, but they do not constitute proof of the full canonical Event/Placement graph.
3. **Canonical placement membership versus visualized planned timing.** Canon says an unscheduled Step may appear only as an explicit non-durable proposal (`time.md:3951-3963`). Live week projection turns planned Step timing into normal `TimeWeekBlockState` rows and does not carry an explicit proposed/accepted flag (`TimeWeekShapeProjection.swift:23-54,65-130`).
4. **Full Goal lifecycle versus compressed live enum.** Canon distinguishes Ready, Ended, Archived, Trashed, restored, and permanently deleted (`goal.md:81-100`); live `GoalLifecycleState` has only draft, active, paused, completed, archived (`GoalEngineContracts.swift:86-92`).
5. **Receipt semantics versus label-shaped placeholders.** Canon requires one durable Receipt linked to exact objects/history (`receipt.md:25-71`); the planning selector synthesizes Receipt-like string IDs (`PlanningNextStepSelector.swift:256-272`). Those strings are explanation metadata, not evidence that a Receipt exists.

## Required decisions

### Devan

- Decide whether the protected provisional visual program remains visibly provisional where live canon now specifies different visual targets; this audit does not choose between them.
- Decide whether a Today “priority object” is always an existing canonical Step/Event/Reminder projection or whether a new day-specific relation/object is intended.

### Architecture

- Define whether `TimeBlock` becomes, wraps, or is replaced by the canonical Schedule Placement relationship, and how Event/series/occurrence identity joins it.
- Define the migration from enum-derived Life Areas to stable editable stored Life Areas without breaking existing Goal references.
- Resolve String Goal/Step identifiers versus UUID temporal-context/occurrence identifiers and prohibit accidental duplicate identity.
- Specify exact projection-to-owner routing for every Time, Today, Search, and external-surface action.

### UX Blueprint

- Specify when a projection shows an owner handoff, local narrow action, proposal state, source-owned state, or non-editable context.
- Define visual language that distinguishes Step, Event, Reminder, TimeBlock/Placement, and suggestion without creating a second owner.

### Runtime

- Implement and prove canonical Event, Schedule Placement, Life Area lifecycle, complete Goal lifecycle, and immutable path version/history lineage if those canon obligations remain active.
- Close registry-unproven mutation paths before presenting universal Receipt, undo, replay, or cross-root edit continuity.

### Reconstruction planning

- Sequence identity migrations before visual consolidation across roots.
- Treat legacy/direct repository mutation paths and synthetic receipt-like identifiers as reconciliation targets, not design authority.

## Unsupported assumptions

- A canonical editable Life Area already exists in persistence: `ABSENT`.
- A canonical native Event and series/occurrence graph already powers Time: `ABSENT`.
- Every `TimeBlock` is an accepted Schedule Placement: `CONTRADICTED`.
- A Today priority has independent canonical identity: `ABSENT`; current items are Step projections.
- Every Goal state in the provisional campaigns has a live lifecycle representation: `CONTRADICTED`.
- Every cross-root action already routes through a proven single mutation owner: `CONTRADICTED` by the current mutation registry’s unproven rows.
- Every visible Receipt/source/replay identifier resolves to a durable record: `CONTRADICTED`.
- Search can already consolidate every provisional object family: `UNKNOWN`, with missing upstream identities making a universal claim impossible now.

## Reconstruction implications

1. Establish the canonical object graph and identifier bridge before reusing one visual object treatment across all roots.
2. Add migrations and proof for editable Life Areas if the normative Goals root remains Life-Area-led.
3. Materialize canonical Event and Schedule Placement identities before claiming calendar replacement, cross-root Event editing, or exact source/history consolidation.
4. Make proposal-versus-accepted placement explicit in projection models and tests.
5. Route every surface action through the declared owner and require row-specific replay/restart proof before marking the path supported.
6. Replace receipt-shaped explanation strings with resolved references or visibly non-authoritative trace labels.
7. Add identity-focused tests for Goal↔Today, Goal/Step↔Time, Event/Placement↔Today, Search consolidation, deletion/restore, and projection reopening.

## Evidence appendix

### E-RP02-01 — Stored Goal and Step identities

- **Claim:** Goal and Step have unique persisted IDs with Goal/Plan/Section lineage.
- **Capability status:** `SUPPORTED` for storage identity; `PARTIALLY_SUPPORTED` for full lifecycle lineage.
- **Source:** `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataModels.swift:4-97,134-288`, symbols `GoalRecord`, `GoalPlanRecord`, `PlanSectionRecord`, `StepRecord`.
- **Authority/currentness:** Current production persistence source.
- **Verification:** Source inspection and inclusion in `ObjectStoreSwiftData.schema` at `ObjectStoreSwiftData.swift:142-164`.
- **Result:** Unique IDs and linkage fields are present.
- **Confidence:** High.
- **Remaining uncertainty:** Current-head simulator test execution did not begin because the shared test run failed at simulator boot.
- **Affected directions:** `AVF-GOALS-S07-R01`, `AVF-TODAY-S09-R00`, `AVF-TIME-S07-R00`, `AVF-SEARCH-D07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP02-02 — Today retains underlying Goal/Step identity

- **Claim:** Today’s daily target is computed from repository Goal/Step data and reuses the Step ID rather than storing a second Today object.
- **Capability status:** `SUPPORTED`.
- **Source:** `Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService+Repository01-makeExperience.swift:5-38,77-95`; `Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService+Repository06-adjustmentPayload.swift:105-160`; `Native/Ambitions/Surfaces/Today/Projection/TodayGoalStepActionCommandAdapter.swift:7-53`.
- **Authority/currentness:** Current production projection and command-preparation source.
- **Verification:** Static source trace from repository load to `TodayTargetItem` and `TodayActionTarget`.
- **Result:** Identity lineage is explicit for Goal/Step-backed Today rows.
- **Confidence:** High.
- **Remaining uncertainty:** Runtime behavior was not exercised this audit.
- **Affected directions:** `AVF-TODAY-S09-R00`, `AVF-GOALS-S07-R01`, `AVF-COHERENCE-S07-R00`.

### E-RP02-03 — Time retains some Goal/Step identity but lacks canonical placement completeness

- **Claim:** Time reads the same Goal repository and a persisted local TimeBlock graph, but the block model is narrower than canonical Schedule Placement/Event.
- **Capability status:** `PARTIALLY_SUPPORTED`.
- **Source:** `Native/Ambitions/Surfaces/Time/Projection/TimeProjectionSnapshot.swift:37-58`; `Native/Ambitions/Surfaces/Time/Projection/TimeWeekShapeProjection.swift:23-150`; `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/TimeBlockGraph.swift:49-100`; `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LifeCalendarStore.swift:38-151`.
- **Authority/currentness:** Current production projection and storage source.
- **Verification:** Static source trace; schema search found no `SchedulePlacementRecord` or `EventRecord` in `ObjectStoreSwiftData.schema`.
- **Result:** Goal/Step linking and durable blocks exist; universal temporal identity does not.
- **Confidence:** High.
- **Remaining uncertainty:** Other non-schema stores may contain adjacent data, but they do not change the declared canonical schema finding.
- **Affected directions:** `AVF-TIME-S07-R00`, `AVF-TODAY-S09-R00`, `AVF-SEARCH-D07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP02-04 — Life Area target is not implemented as an editable stored object

- **Claim:** Live Life Areas are fixed enum-derived values, contrary to canonical stable editable object law.
- **Capability status:** `CONTRADICTED`.
- **Source:** `docs/canon/specifications/objects/life-area.md:37-41,74-119`; `Native/Ambitions/Core/Domain/LifeArea.swift:3-37`; `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift:142-164`.
- **Authority/currentness:** Normative current canon plus current domain and persistence source.
- **Verification:** Source inspection and schema membership check.
- **Result:** No stored editable Life Area identity is declared.
- **Confidence:** High.
- **Remaining uncertainty:** None material to the claim.
- **Affected directions:** `AVF-GOALS-S07-R01`, `AVF-SEARCH-D07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP02-05 — Proof ceiling for mutation ownership

- **Claim:** Declared mutation ownership is not equivalent to proven durable behavior across all paths.
- **Capability status:** `PARTIALLY_SUPPORTED`.
- **Source:** `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift:166-240`; `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift:130-180,211-302`; `docs/qa/architecture/architecture-modernization-current-state.md:32-83`.
- **Authority/currentness:** Current manifest, exhaustive runtime registry, and current architecture reconciliation.
- **Verification:** `python3 scripts/ambitions-architecture-10-scorecard-check.py` failed because the checker still cites purged paths; this failure is planning/checker staleness, not runtime behavior evidence. Shared focused XCTest execution failed at simulator boot with zero tests executed.
- **Result:** Bounded durable Today/Time rows exist; many Goals, Step, Time, Capture, and external-write rows remain unproven.
- **Confidence:** High.
- **Remaining uncertainty:** Executable behavior at this SHA remains unverified.
- **Affected directions:** `AVF-GOALS-S07-R01`, `AVF-TIME-S07-R00`, `AVF-TODAY-S09-R00`, `AVF-SEARCH-D07-R00`, `AVF-COHERENCE-S07-R00`.

## Packet self-review

- Every load-bearing implementation claim cites current source.
- Canon target and implementation proof are separated.
- No fixture/debug type is treated as production support.
- Type presence is not treated as completed behavior.
- Unknowns are explicit; no product tradeoff is selected.
- Contradictions are retained rather than reconciled by assertion.
