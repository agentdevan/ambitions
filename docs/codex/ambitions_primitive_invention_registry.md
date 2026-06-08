> Supporting note: This file supports Ambitions primitive-invention governance. It does not override `docs/truth/*`, live source, current validation logs, or release proof.

# Ambitions Primitive Invention Registry

Status: Active supporting governance
Scope: New visual, interaction, layout, motion, accessibility, and proof primitives proposed after the Active Runtime UI Reconstruction train
Owner posture: Registry template, not implementation proof

## Purpose

This registry prevents Codex or human contributors from inventing parallel UI primitives when an existing Ambitions primitive or canonical owner should be extended.

Every proposed primitive must answer:

- Which active product object needs this primitive?
- Which existing primitive was inspected first?
- Why extension is insufficient?
- Which top-level surface owns the first use?
- What accessibility fallback ships with it?
- What proof artifact will make the primitive inspectable?

## Registry Template

Use this table for every proposed primitive before source work begins.

| Field | Required entry |
|---|---|
| Primitive ID | Stable short name, for example `reality-meridian-source-band` |
| Status | Proposed, approved for prototype, promoted, rejected, retired |
| Owner surface | Today, Goals, Time, Motion, You, or Global Capture |
| Product object | Reality Meridian, Direction Atlas, LifeShape Field, Motion Current, Personal Runtime, Atmosphere Composer, or named drill-down object |
| Existing owners inspected | Source paths and docs consulted before invention |
| Missing capability | Concrete gap that cannot be solved by extending an existing primitive |
| Anti-card reason | Why this avoids a top-level pile-of-panels or generic metric-board pattern |
| Runtime path | SourceRecord, Receipt, ReplayTrace, or You inspection connection |
| Accessibility fallback | VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, Differentiate Without Color, tap-target handling |
| Proof artifact | Screenshot, focused test, source audit, manual note, or report path required for promotion |
| Promotion issue | Linear issue ID that may promote it beyond prototype |
| Rollback path | Exact source/docs paths to revert if the primitive fails gates |

## Current Registry

| Primitive ID | Status | Owner surface | Product object | Promotion issue | Notes |
|---|---|---|---|---|---|
| pending-intake | Proposed | TBD | TBD | TBD | Placeholder row. Replace only when a scoped issue proposes a primitive with evidence. |

## Non-Negotiable Checks

- Do not create a primitive because a screen looks plain.
- Do not create a new owner when an existing primitive can be extended.
- Do not use decorative celestial, gradient, glass, particle, or card-like structure as the reason to invent.
- Do not bypass `docs/truth/PRODUCT_DESIGN_TRUTH.md` one-primary-object discipline.
- Do not claim a primitive is promoted until proof exists and the promotion protocol passes.

## Required Closeout For Primitive Proposals

Any primitive proposal issue must close with:

- Existing owners inspected
- Proposed owner path
- Accessibility fallback
- Proof artifact path
- Promotion status
- Rollback note
- No-readiness-claim boundary
