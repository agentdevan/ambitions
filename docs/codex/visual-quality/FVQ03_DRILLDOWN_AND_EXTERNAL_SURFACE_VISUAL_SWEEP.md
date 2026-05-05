# FVQ03 Drill-Down And External Surface Visual Sweep
<!-- markdownlint-disable MD013 -->

Status: Active-scope visual quality gate.
Date: 2026-05-05

## Purpose

FVQ03 ensures Ambitions' premium visual system does not collapse outside the five top-level tabs.

FVQ03 audits rendered drill-downs and external surfaces after their implementation batches exist and before final handoff claims.

## Drill-Down Targets

Audit when implemented:

- Step Detail
- Step Session
- Goal Detail / Mission Control
- LifePath detail
- LifeShape detail
- Memory Lens
- Receipt Drawer
- Source Fold
- Weekly Life Sweep
- Appearance Studio
- Schedule & Availability
- Planning Defaults
- Capture Placement Resolver
- Grow Into Goal
- Proof Spine / Evidence Ledger
- Reflow Decision Fold
- Pressure / Recovery Loop

## External Surface Targets

Audit when implemented:

- widgets
- Live Activities
- App Intents confirmation/result surfaces
- notification content previews
- Lock Screen / Dynamic Island content where applicable
- App Store screenshots

## Required Standards

All drill-downs must:

- feel native and premium
- preserve the parent surface's object language
- avoid dashboard/card-stack drift
- use progressive disclosure
- show trust/source/privacy where relevant
- preserve accessibility and Reduce Motion equivalents
- avoid showing sensitive Found Life content by default

All external surfaces must:

- be glanceable
- be privacy-safe by default
- deep-link to exact relevant app context
- avoid ads/promotions
- avoid sensitive life content unless explicitly allowed
- use restrained Ambitions identity
- never look like generic widgets or notification spam

## Evidence

Save visual evidence under:

`docs/audits/visual-evidence/fvq03/`

Every audited surface needs:

- screenshot or rendered preview
- freshness proof or fixture proof
- visual score
- privacy/accessibility note
- repair owner if below bar

## Hard Red

Hard Red if:

- drill-down becomes dashboard/page pile
- external surface exposes sensitive Found Life content
- widget/Live Activity looks generic or promotional
- App Intent confirmation allows hidden mutation
- detail surface breaks object language
- screenshot or preview cannot be tied to current build/fixture

## Completion

FVQ03 completes only when implemented drill-down/external surfaces have visual evidence or explicit accepted Yellow deferral with owner and no Hard Red.
