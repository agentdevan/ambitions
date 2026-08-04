+++
initiative = "multi-goal-portfolio-simulation"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Add a deterministic `PortfolioSimulationEngine` consuming immutable
`PortfolioSnapshot`, `SharedResourceLedger` and explicit
`PortfolioScenarioAssumptions`. It emits validated `PortfolioScenarioSet` with
per-Goal/resource results and one-variable sensitivities. `PortfolioExplanation`
is deterministic; optional generative phrasing is downstream. Production entry
is blocked by a signed `PortfolioSimulationActivationGate` until upstream and
user evidence pass.

## User flows

1. User opens portfolio review and explicitly selects Goals/current or draft
   Path versions, horizon and context categories.
2. Snapshot preview lists owners/revisions, protected facts, unknown resources
   and exclusions. User can continue partial or correct owners/context.
3. User selects scenario templates/postures; any protect-Goal template requires
   naming the Goal.
4. Engine computes bounded scenarios and shows current-commitment first, then
   stable non-ranked alternatives with assumptions.
5. Comparison exposes per-Goal changes, resource ledgers, conflicts, continuity,
   reversibility, unknowns and sensitivity.
6. User edits assumptions/recomputes, saves/dismisses, or selects a scenario.
7. Selection builds owner proposals. Independent changes open their respective
   previews; inseparable changes open a Life Branch draft. Nothing commits here.

Before activation gate, the product exposes a clearly labeled fixture/
development conformance surface only—not user data or a fake production result.

## States and recovery

Gate: `conformanceOnly`, `evidenceIncomplete`, `eligible`, `revoked`. Snapshot:
`editing`, `ready`, `partial`, `stale`, `invalid`. Simulation: `queued`,
`running`, `ready`, `partial`, `noAlternative`, `conflicted`, `canceled`,
`failed`, `superseded`. Handoff: `notSelected`, `ownerPreviews`,
`lifeBranchRequired`, `stale`, `rejected`.

One actor owns each simulation, captures all revisions/policy/clock/locale and
enforces goal/horizon/scenario/node budgets. Changes cancel/discard results; no
implicit rerun. Owner reads are snapshot transactions where supported or carry
independent revision checks with a final consistency barrier. Save/delete/purge
uses idempotent private journals.

## Architecture and data

Add under `Native/Ambitions/Core/LocalRuntimeOS/Simulation/Portfolio/`:

- activation gate/evidence record models/loader;
- snapshot/selection/owner-revision models and assembler;
- heterogeneous resource amount/range/unit/period/availability models;
- shared resource ledger, allocation/double-count validator;
- scenario template/assumption/posture/budget registry;
- dependency/resource/conflict/continuity/reversibility evaluators;
- deterministic engine, validation and stable ordering;
- sensitivity engine and explanation projector;
- scenario set repository, invalidation, migration and purge;
- owner change proposal builder and Life Branch escalation client;
- privacy-safe evaluation/diagnostic models.

Typed owner clients expose immutable public/private projections for exact IDs
and purposes. No client supports enumeration beyond explicit selection or write.
Money/time/place/equipment/context/opportunity/people/capability dimensions use
distinct enums and evaluators. Cross-dimension output is a list of tradeoffs,
never arithmetic.

`PortfolioScenario` stores assumptions, semantic result per Goal/resource,
constraint results, dependency/current bindings, continuity, reversibility,
unknowns and provenance. It stores no probability/global score. Sensitivity
creates child scenarios varying one allowed field/range endpoint, with an exact
semantic diff and budget.

`OwnerChangeProposalBundle` contains expected owner revisions and non-authorized
typed draft inputs. A dependency graph classifies independent versus inseparable.
The coordinator cannot invoke commands. The Life Branch client can create only a
private branch draft input; that owner revalidates.

Persistence is protected private draft data. Public claims remain in registries.
Migration accepts prior simulation artifacts only with exact owner/resource/
assumption semantics; otherwise they remain legacy inspection-only. Purge removes
all derived snapshots/ledgers/scenarios/sensitivity/explanations/feedback/
dependencies/exports without touching canonical objects.

## Privacy and accessibility

User selection and purpose grants bound every read. No whole graph, public
request, hosted provider or payload telemetry. Sensitive context clear values
remain in Context Registry and are ephemerally resolved; stored scenario
evidence uses opaque bindings/semantic results. Diagnostics use category/state/
count/timing only.

Comparison has a complete ordered list view by scenario, then Goal/resource.
Tables/maps/charts are supplementary. Assumptions, unknowns, conflict, preserved
work and sensitivity are announced. VoiceOver, Voice Control, Switch Control,
keyboard, largest Dynamic Type, Reduced Motion, RTL, non-color and focus recovery
cover selection, run/cancel, comparison, edit and handoff.

## Requirement traceability

| Scope | Design decision |
|---|---|
| REQ-001 | Explicit selection/horizon builder |
| REQ-002 | Immutable owner snapshot and consistency barrier |
| REQ-003 | Typed heterogeneous ledgers and double-count validator |
| REQ-004 | Explicit template assumptions/postures |
| REQ-005 | Deterministic bounded engine/evaluators |
| REQ-006 | Non-ranked semantic set and validator |
| REQ-007 | Per-Goal continuity/effect models |
| REQ-008 | One-variable sensitivity engine |
| REQ-009 | Context-bound results/copy/bias validation |
| REQ-010 | Optional explanation-only private runtime handoff |
| REQ-011 | Command-free owner bundle and Life Branch classifier |
| REQ-012 | Revision capture, cancellation and partial states |
| REQ-013 | Private repository/migration/journaled purge |
| REQ-014 | Per-scenario/slice evidence records |
| REQ-015 | Ordered accessible comparison |
| REQ-016 | Signed activation gate with conformance-only default |

## Verification design

- Cross-dimension accounting/range/unknown/double-count/property tests.
- Stable scenario/assumption/non-ranking/no-prediction golden sets.
- Snapshot consistency, bounded combinatorics, cancellation and stale discard.
- Owner/Life Branch mutation spies and independent/inseparable classification.
- Privacy/bias/dignity fixtures and payload/network diagnostics canaries.
- Migration/replay/archive/delete/purge fault injection.
- Accessibility/physical-device performance at maximum supported scale.
- Upstream gate verifier and direct-user comprehension/usefulness evidence; a
  missing/revoked record always leaves production entry unavailable.

## Open decisions

None. Scenario-count and template-copy calibration may change through evaluated
policy versions without altering the product authority model.

Review verdict: **PASS** after two reconciliation rounds. Review added snapshot
consistency, double-count validation, explicit conformance-only state and command-
free Life Branch routing. Devan delegated approval; Design approved 2026-08-04.
