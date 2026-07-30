<!-- markdownlint-disable MD013 MD060 -->

# Current Capability Ceiling

Audit baseline in the required RP-04 packet: `29872755f705f6bd8e276aeac86dcf376ac5f0d8`

Current packet baseline rechecked against the cited source: `4ced31dc9a9bd2c9a987ad7649eedd7bb1569b72`

No executable behavior was run. Every finding below is static source or normative evidence.

## Inspected source boundary

The required RP-04 audit routed this recheck to these current paths only:

- `Native/Ambitions/Surfaces/Time/Projection/RepositoryBackedTimeService.swift:17-91`;
- `Native/Ambitions/Surfaces/Time/Projection/TimeWeekShapeProjection.swift:23-151`;
- `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/TimeBlockGraph.swift:3-196`;
- `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LifeCalendarStore.swift:8-151`;
- `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift:142-164`;
- `Native/Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift:214-302`; and
- `docs/audits/rp-01-08-evidence-audit/04-rp-04-goals-today-time-boundaries.md:89-104,156-169,260-268,329-349`.

File or type names were not treated as capability proof.

## Supported or partially supported source facts

| Capability | Status | Current evidence | Ceiling |
|---|---|---|---|
| Week-shaped projection | `PARTIALLY_SUPPORTED` | `RepositoryBackedTimeService` defaults its availability horizon to `"week"`; `TimeWeekShapeProjection` builds seven days. | Not a complete Week calendar, Week-first restoration proof, or five-scale family. |
| Persisted local temporal blocks | `SUPPORTED` as a local implementation block | `TimeBlock` has stable ID, range, kind, source, optional Step/Goal/Event/command IDs; `LifeCalendarStore` persists JSON snapshots. | Not canonical Event or full Schedule Placement authority. |
| Protection/fixed/flexible/recovery/buffer kinds | `PARTIALLY_SUPPORTED` | `TimeBlockKind` declares protected, fixed, flexible, scheduled Step, recovery, buffer, unavailable, keep-clear, lighter-pressure, and external-busy states. | Type presence does not prove complete owner commands, recurrence, UI, or settlement. |
| Pairwise overlap conflict | `SUPPORTED` at model level | `TimeBlockGraph` produces advisory/blocking conflicts tied to both block IDs and overlap minutes. | Does not prove canonical participants, complete conflict policy, review, or settlement. |
| External busy observation | `PARTIALLY_SUPPORTED` | `RepositoryBackedTimeService.makeTimeCalendarAware` queries open windows and appends a calendar-observation ledger entry. | Not canonical Event import, durable Source Reference parity, or calendar replacement. |
| Some durable Time command paths | `PARTIALLY_SUPPORTED` as source-present | Mutation registry describes Time ritual and placement adapters with authority/event/projection/receipt owners. | All cited Time and EventKit rows remain `unproven`; no fresh executable proof in this packet. |

## Binding gaps

| Target capability | Current disposition | Consequence for research and later rendering |
|---|---|---|
| Complete Day/Week/Month/Year/List parity | `PLANNED_NOT_IMPLEMENTED` as a complete family | Only Week may anchor the first calibration; unsupported scales stay absent. |
| Canonical Event CRUD, recurrence, series, occurrence, source, and lifecycle | `PLANNED_NOT_IMPLEMENTED` | Fixture Event-like truth must be explicitly synthetic; external observation cannot be shown as native Event. |
| Complete Schedule Placement state | `PARTIALLY_SUPPORTED` | Accepted/proposed/subject/source/revision/recurrence scope must be fixture fields, not runtime claims. |
| Accepted-versus-proposed authority in current week projection | `CONTRADICTED` | The live projection’s computed Goal timing must not be reused as accepted scheduled work. |
| Complete external calendar replacement and reconciliation | `PARTIALLY_SUPPORTED` at observation/outbox seams | External write settlement and native import remain absent or inspection-only. |
| Durable grouped reflow | `PLANNED_NOT_IMPLEMENTED` | Conflict review may compare and cancel; it cannot imply multi-item commit. |
| Rich personal usability from energy/cognitive/transition context | `PARTIALLY_SUPPORTED` at types/heuristics | `Open` remains calendar space only; no “best time” or recommendation claim. |
| Complete Receipt and executable Undo | `PLANNED_NOT_IMPLEMENTED` across the target family | Receipt/Undo controls stay absent from the first fixture slice. |
| Production cross-root return | `UNKNOWN` or `PLANNED_NOT_IMPLEMENTED` for complete Time journey | A direction must preserve the target context model, but rendering cannot prove runtime restoration. |
| Arbitrary drag and resize mutation | `PLANNED_NOT_IMPLEMENTED` as complete behavior | Later prototype can show inspection or preview only; named alternatives are required before mutation claims. |

## Critical current contradiction

`TimeWeekShapeProjection.weekStepContexts` converts Goal Plan timing into ordinary `TimeWeekBlockState` values when no persisted `TimeBlock` carries that Step ID. The constructed state does not encode accepted-versus-proposed placement authority. This can make proposed Goal timing resemble scheduled truth.

This packet therefore rejects reuse of current week rows as fixture authority. The proposed nursery Step is always `Proposed · Not scheduled`; only the two named accepted local placements receive accepted treatment.

## Capacity ceiling

The current week projection computes pressure from block counts and weighted Goal contexts against a constant `3.0`. It can label days open, steady, tight, or overloaded and can produce “Open window” or “Usable room” copy. This is a coarse heuristic, not proof of personally usable capacity, energy, cognitive load, transition friction, or a safe recommendation.

The research fixture records `After 6:30 PM` as open calendar space and explicitly states that personal usability is not inferred.

## External-truth ceiling

Current code can observe calendar busy windows and record a ledger fact. It does not establish the complete target sequence of candidate identity, Source Reference, freshness, reviewed external-capacity decision, native Event import/link, recurrence reconciliation, local-before-external settlement, and failure recovery.

The prenatal appointment is therefore an `External observation` from Apple Calendar, never an accepted Ambitions Event or placement.

## Mutation and settlement ceiling

At this baseline, the Meaningful Mutation Registry still marks the cited Time placement, Time ritual, Step placement/recurrence, calendar-aware, and EventKit outbox/result paths `unproven`. Source presence and historical test IDs do not raise the current proof tier.

Valid first-calibration outcomes are:

- Cancel;
- Keep current time; or
- fixture-only proposed-alternative inspection.

No working commit, grouped reflow, external write, Receipt, or Undo may be implied.

## Allowed synthetic representation

Immutable fixture snapshots may visualize target truth distinctions only when:

- the fixture ID and non-production status are explicit;
- every proposal says it is not scheduled;
- every external fact retains source and observation status;
- unsupported commands are absent or labelled fixture-only in evidence;
- current accepted truth remains authoritative during review; and
- no visual evidence is described as runtime, accessibility, device, or settlement proof.
