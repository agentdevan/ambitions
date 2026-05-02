# Product Depth And Drilldown Rules
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX14 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

PXOS makes Ambitions deeper without making it wider. Top-level surfaces stay restrained. Depth belongs in Step Detail, Step Session, Goal Detail, Mission Control lanes, Plan detail views, Life Shape drill-downs, Capture routing review, You grouped navigation, receipts/history, setup flows, trust/review surfaces, proof detail, source detail, and privacy controls.

Reject sprawl: new top-level tabs, generic dashboard pages, chat-first AI surfaces, separate inbox tab, generic notes area, calendar clone, analytics tab, habit tracker mode, project-management mode, or duplicate versions of existing surfaces.

## Drill-Down Discipline

Top-level tabs orient the user. They should not carry all available detail.

Move detail behind a tap when it is not required for immediate orientation or
the next action. This includes proof/history overload, diagnostics, source
detail, repeated receipt detail, secondary explanations, setup configuration,
long preference lists, and object history.

Top-level PXOS surfaces must pass:

- Glance test: main state is legible in 3 seconds.
- One-primary-object test: one dominant visual object or decision is visible.
- Drill-down discipline test: secondary information has an obvious destination
  behind Step Detail, Step Session, Goal Detail, Mission Control lanes, Plan
  detail views, Life Shape drill-downs, Capture routing review, You grouped
  navigation, receipts/history, proof detail, setup flows, or trust/review
  surfaces.

Reject future UI concepts that use vertical stacks of generic cards as the
primary structure for Today, Goals, Capture, Plan, or You.

## Product Depth Definition

Product Depth is not a new product mode. It is the rule that every meaningful
secondary object has a home inside an existing surface.

Allowed depth destinations:

- Today: Step Detail, Step Session, closure/recovery, proof peek, source detail.
- Goals: Goal Detail, Mission Control lanes, proof/history, alternate paths.
- Capture: routing review, placement correction, grow-into-goal, source detail.
- Plan: day/week shape, reflow decisions, pressure review, Life Shape detail.
- You: grouped navigation, trust review, memory/data controls, setup defaults.
- Cross-surface: receipts/history, proof detail, trust review, source detail,
  privacy controls.

Product Depth must never create a sixth destination. It must not create a
generic dashboard, inbox, notes area, habit mode, chatbot surface, analytics
tab, calendar clone, or project-management system.

## Depth Ownership Contract

Every future depth concept must name:

- owning top-level surface;
- owned drill-down, sheet, lane, or detail route;
- primary object;
- rollback path;
- source/trust/proof boundary;
- accessibility and cognitive-load evidence;
- ME owner-file gate if implementation touches large UI/service files;
- CS gate if it touches routes, raw values, deep links, widgets, App Intents,
  import/export, persistence, or compatibility seams;
- AOS gate if it touches recommendation, source truth, proof, alternate path,
  adaptation, reality drift, commitment time, or runtime logic.

If ownership is unclear, the concept is not ready.

## Product Depth Start Boundary

PX14 defines future Product Depth drill-down architecture only. It does not
start the `PD01-PD18 Product Depth Train`, does not authorize implementation,
and does not make PD01 selectable without its required approval phrase and
global gates.

The PD train may start only when:

- `Start Product Depth Train` is explicitly satisfied or global preauthorization
  and the selected PD batch's gates explicitly allow it;
- PX14 is Green;
- PX18 implementation-readiness reorder is Green;
- affected ME and CS gates are identified and Green or accepted Yellow;
- affected AOS gates are Green when runtime/intelligence/proof/source-truth
  logic is touched;
- REC release-claim boundaries remain Green.

## Anti-Sprawl Tests

Future Product Depth work is Red if it:

- adds a new top-level tab;
- makes a top-level surface a detail archive;
- uses stacked same-size cards as the primary top-level structure;
- creates a generic dashboard or analytics wall;
- creates a chat-first surface;
- creates an inbox, notes app, habit tracker, calendar clone, or enterprise
  project-management mode;
- bypasses ME/CS gates to implement faster;
- hides proof, source, privacy, or recovery detail without an owned route.

## Acceptance Tests For Future Depth Prompts

Each depth prompt must answer:

- What surface owns this?
- What object becomes deeper?
- What stays on the top-level surface?
- What moves into drill-down?
- What proof/source/trust detail is visible or inspectable?
- What is the rollback path?
- Which ME/CS/AOS gates apply?
- What validation proves the top-level orientation rule stayed intact?

## Required Source Stack

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/AmbitionsOS_Index.md`
- `docs/codex/PXOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Gates

- Product Decision Lock Gate: major choices must be locked by source truth or recorded as open/deferred.
- Surface Ownership Gate: every future UI change names Today, Goals, Capture, Plan, You, or a drill-down owner.
- Deep-Not-Wide Gate: deepen existing surfaces before creating new surface area.
- Accessibility / Cognitive Load Gate: future UI must specify Dynamic Type, VoiceOver, Reduce Motion, no color-only meaning, and cognitive-load expectations.
- Release Claim Gate: no release/platform/AI/personalization claim without evidence.
- ME Gate: no large UI expansion in known large-file zones without extraction review.
- CS Gate: no route/raw-value/external-surface/persistence breakage.

## Implementation Boundary

This is future canon and process guidance only. It does not implement app behavior, change production Swift, start PXOS, start AOS/ME/CS/REC02, retire compatibility seams, add dependencies, change workflows, add backend/sync/cloud/model runtime, or create release/platform readiness claims.
