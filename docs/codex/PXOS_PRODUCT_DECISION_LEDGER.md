# PXOS Product Decision Ledger

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
| REC01 remains active; REC02 must not start here | User prompt and REC manifest | REC | release evidence | REC | Preserves active train | Registry scan | Prevents release overclaim | Locked by REC/release truth |
| AOS/ME/CS remain future/inactive | User prompt and registry | Governance | all | AOS/ME/CS | Blocks automatic starts | Status scans | Prevents false status | Locked by REC/release truth |
| Capture uses restrained dark-sky/starfield signature in Capture and First Run | User prompt | PXOS Capture | Capture/onboarding | PX | Future visual direction | Visual review | Future only | Locked by user |
| Default automation level is Guided | User prompt | PXOS You | You | PX | Future setup default | Trust review | No current behavior claim | Locked by user |
| Top-level tabs are visual orientation surfaces, not detail containers or stacked-card screens | User prompt | PXOS surface/visual | Today/Goals/Capture/Plan/You | PX/Product Depth | Blocks repeated same-size card stacks as primary structure | Glance, one-primary-object, and drill-down discipline tests | Future direction only | Locked by user |
| Exact future visual treatment for Goal alive visualization | Not fully specified | PXOS Goals | Goals | PX03 | Requires design decision | Screenshot/preview criteria later | Future only | Open question |
| Exact First Run sequence and copy | Partially specified | PXOS onboarding | onboarding | PX11 | Requires future UX decision | Onboarding preview/tests later | Future only | Open question |
| Whether PXOS implementation should precede all ME work or only affected ME work | Prompt gives principle, not exact per-file sequencing | Governance | all | PX/ME | Needs reorder gate per batch | Reorder report | Future only | Deferred future decision |
