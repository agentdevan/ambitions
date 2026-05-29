# FVQ02 Five Top-Level Surface Visual Sweep

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-96864649, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-49156184

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active-scope visual quality gate.
Date: 2026-05-05

## Purpose

FVQ02 ensures that visual quality is not fixed only on Today. It forces rendered simulator proof for all five locked top-level tabs:

- Today
- Goals
- Capture
- Plan
- You

FVQ02 must run after FVQ01 unless FVQ01 stops on Hard Visual Red. It must run before broad continuation into platform, AOS, LDI, or late handoff work.

## Required Evidence

Save screenshots under:

`docs/audits/visual-evidence/fvq02/`

Required where tooling permits:

- `today-default.png`
- `goals-default.png`
- `capture-default.png`
- `plan-default.png`
- `you-default.png`
- `top-level-dynamic-type.png` or per-screen Dynamic Type screenshots
- `top-level-reduce-motion.md` or screenshots where possible
- `screenshot-freshness.json`
- `visual-scorecard.md`

## Surface Pass Bars

### Today

Must feel like one living daily decision surface.

Pass requires:

- Start Here is dominant.
- Reality Rail is a connected spine, not an explanatory card.
- closure/proof/trust are calm and discoverable.
- no internal component labels dominate.
- no dashboard/card-stack drift.

### Goals

Must feel like LifePath and MissionControlTimeSpine.

Pass requires:

- one primary becoming/path object.
- no progress-card surface.
- no project-management board.
- proof, blocker, alternate path, and option value feel connected.
- goal detail can drill down; top level stays restrained.

### Capture

Must feel like Capture Atmosphere Composer.

Pass requires:

- composer is primary.
- dark-sky/starfield atmosphere is restrained.
- no inbox/feed/list default.
- placement/resolver affordance is quiet and trusted.
- privacy/source behavior is visible when needed, not noisy.

### Plan

Must feel like LifeShape.

Pass requires:

- primary object is capacity/pressure/protected-pocket shape.
- not a calendar clone.
- not an analytics surface.
- free time, protected time, recovery, and reflow feel like one object language.
- details are folds/drill-downs, not stacked panels.

### You

Must feel like Personal System Center.

Pass requires:

- not a generic Settings dump.
- trust, memory, privacy, planning setup, appearance, receipts, and Found Life are grouped with premium hierarchy.
- user control is obvious.
- no operational surface.

## Scoring

Each surface must be scored:

- Native iPhone believability
- Premium material quality
- One primary object clarity
- Ambitions-specific identity
- Found Life alignment
- Trust/source/privacy expression
- Cognitive load
- Accessibility/readability
- Reduced Motion equivalent
- No dashboard/card-stack drift
- No scaffold/debug language
- Screenshot freshness

Failing any critical category below pass bar creates a visual repair batch.

## Repair Batch Naming

Use narrow repair batch names:

- `FVQ-TODAY-REPAIR`
- `FVQ-GOALS-REPAIR`
- `FVQ-CAPTURE-REPAIR`
- `FVQ-PLAN-REPAIR`
- `FVQ-YOU-REPAIR`
- `FVQ-SHELL-REPAIR`

Repair batches must be focused, screenshot-backed, and not broaden scope.

## Hard Red

Hard Red if any top-level surface remains:

- dashboard-like
- generic card stack
- prototype/demo screen
- too crowded
- missing primary object
- visually incoherent with other tabs
- stale or unproven screenshot
- dependent on color or motion alone

## No-Claim Boundary

FVQ02 does not claim final human visual signoff, App Store readiness, or Apple Design Award readiness. It proves the rendered top-level simulator surfaces are credible enough to continue.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
