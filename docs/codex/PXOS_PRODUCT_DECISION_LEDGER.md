# PXOS Product Decision Ledger
<!-- markdownlint-disable MD013 -->

Status: Future-canon decision ledger; PXOS implementation not started
Date: 2026-05-02

## Purpose

Record product decisions for PXOS as locked, open, or deferred. Codex must not
convert open questions into locked decisions.

## Decision States

- Locked by user
- Locked by existing 3.0 canon
- Locked by AmbitionsOS dependency
- Locked by ME constraint
- Locked by CS constraint
- Locked by REC/release truth
- Open question
- Deferred future decision

## Ledger

| Decision | Source | Owner | Affected surface | Future train | Implementation impact | Validation impact | Release-claim impact | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PXOS is future user-facing product experience canon beside AmbitionsOS | User prompt | PXOS | all | PX | Creates future canon only | Docs/claim scans | No shipped claim | Locked by user |
| Top-level surfaces remain Today / Goals / Capture / Plan / You | User prompt and 3.0 canon | PXOS | all | PX/Product Depth | Blocks new tabs | Deep-not-wide scan | No new IA claim | Locked by user |
| Ambitions should feel 70% Apple quiet luxury, 20% OpenAI intelligence, 10% executive command surface | User prompt | PXOS visual/copy | all | PX | Sets quality bar | Visual/copy review | Future direction only | Locked by user |
| AmbitionsOS owns internal intelligence; PXOS owns user-facing expression | User prompt | PXOS/AOS | all | PX/AOS | Defines dependency | Cross-train traceability | Prevents implementation claim | Locked by user |
| REC01-REC06 are complete as evidence/status work; human proof remains pending | REC06 handoff | REC | release evidence | REC | Preserves release claim boundary | Registry scan | Prevents release overclaim | Locked by REC/release truth |
| PX01 may start through current global preauthorization after REC06 | User prompt and global order | PXOS | all | PX | Allows future-canon sequencing only | Dry-run gate | No implementation claim | Locked by user |
| AOS/ME/CS remain future/inactive | User prompt and registry | Governance | all | AOS/ME/CS | Blocks automatic starts | Status scans | Prevents false status | Locked by REC/release truth |
| Capture uses restrained dark-sky/starfield signature in Capture and First Run | User prompt | PXOS Capture | Capture/onboarding | PX | Future visual direction | Visual review | Future only | Locked by user |
| Default automation level is Guided | User prompt | PXOS You | You | PX | Future setup default | Trust review | No current behavior claim | Locked by user |
| Top-level tabs are visual orientation surfaces, not detail containers or stacked-card screens | User prompt | PXOS surface/visual | Today/Goals/Capture/Plan/You | PX/Product Depth | Blocks repeated same-size card stacks as primary structure | Glance, one-primary-object, and drill-down discipline tests | Future direction only | Locked by user |
| Today top-level object is Reality Rail / Ambitions Day Rail | PX02 and 3.0 Today canon | Today | Today | PX02/PD02-PD04 | Keeps Today oriented around one dominant daily decision | Today glance and drill-down checks | Future direction only | Locked by existing 3.0 canon |
| Today Hero Step Panel is a lead state inside the Reality Rail, not a separate stacked card by default | PX02 and 3.0 Day Rail spec | Today | Today | PX02/PD02 | Prevents duplicate hero/card stacking | Top-level composition scan | Future direction only | Locked by existing 3.0 canon |
| Today secondary explanation, proof, history, diagnostics, and receipts live behind owned drill-downs | PX02 | Today | Today | PX02/PX07/PX08/PD02-PD04 | Preserves deep-not-wide surface behavior | Drill-down ownership check | Future direction only | Locked by PXOS |
| Goals top-level object is Ambition Portfolio | PX03 and 3.0 Goal Mission Control canon | Goals | Goals | PX03/PD05-PD08 | Keeps Goals strategic instead of task/database shaped | Goals glance and drill-down checks | Future direction only | Locked by existing 3.0 canon |
| Goal Detail and Mission Control lanes own path, proof, decisions, risks, assumptions, and archive depth | PX03 and 3.0 Primitive Architecture | Goals | Goals/Goal Detail | PX03/PX14/PD05-PD08 | Preserves deep-not-wide Goals architecture | Mission Control lane check | Future direction only | Locked by existing 3.0 canon |
| Goal vitality is visual orientation, not a score or KPI | PX03 | Goals | Goals | PX03/PX10/PD05-PD08 | Prevents dashboard/OKR drift | Product language and visual review | Future direction only | Locked by PXOS |
| Exact future visual treatment for Goal alive visualization | Not fully specified | PXOS Goals | Goals | PX03 | Requires design decision | Screenshot/preview criteria later | Future only | Open question |
| Exact future Goal path/lifecycle visualization treatment | Not fully specified | PXOS Goals/visual | Goals | PX10/PD06 | Requires visual/motion decision | Reduce Motion and preview criteria later | Future only | Deferred future decision |
| Capture top-level object is the private intake composer and current captured thought | PX04 and 3.0 Capture Placement Resolver canon | Capture | Capture | PX04/PD09-PD11 | Keeps Capture fast and private instead of inbox-shaped | Capture glance and placement-state checks | Future direction only | Locked by existing 3.0 canon |
| Capture placement preview must show consequence before confirmation | PX04 and F08 Placement Resolver evidence | Capture | Capture/Placement Review | PX04/PD09 | Prevents silent routing and hidden automation | Trust/privacy and no-silent-change checks | Future direction only | Locked by PXOS |
| Grow into Goal is a confirmed handoff, not automatic goal creation | PX04 and F09 Capture-to-Goal evidence | Capture/Goals | Capture/Goals | PX04/PD11 | Preserves user control and goal ownership | Confirmation and routing review checks | Future direction only | Locked by existing 3.0 canon |
| Exact future dark-sky/starfield motion treatment for Capture | Partially specified | PXOS Capture/visual | Capture/First Run | PX10/PX11 | Requires visual/motion decision | Reduce Motion and preview criteria later | Future only | Deferred future decision |
| Exact First Run sequence and copy | Partially specified | PXOS onboarding | onboarding | PX11 | Requires future UX decision | Onboarding preview/tests later | Future only | Open question |
| Exact future Today motion treatment for connected rail dots and progress rhythm | Not fully specified | PXOS Today/visual | Today | PX10 | Requires visual/motion decision | Reduce Motion and preview criteria later | Future only | Deferred future decision |
| Whether PXOS implementation should precede all ME work or only affected ME work | Prompt gives principle, not exact per-file sequencing | Governance | all | PX/ME | Needs reorder gate per batch | Reorder report | Future only | Deferred future decision |
