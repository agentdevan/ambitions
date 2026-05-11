# Visual Canon + Moat Implementation Overlay

<!-- markdownlint-disable MD013 -->

Status: Active control-plane overlay for visual + moat front-end install.
Date: 2026-05-11

## Purpose

Define the bounded visual and moat control-plane for this phase only. This overlay
does not change runtime behavior by itself.

## Scope and authority

- `docs/AmbitionsCanon/20_Visual_Canon_Moat_Implementation_Spec.md` is the visual/moat authority addendum.
- `docs/codex/VISUAL_CANON_MOAT_BATCH_TRAIN.md` defines the executable visual lane batches.
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_VISUAL_CANON_MOAT_OVERLAY.md` wires this lane into the active global order.
- `docs/status/visual-canon-moat-installation-report.md` records evidence and command status.
- Active top-level destination remains `Today / Goals / Capture / Time / You`; `Plan` is treated as compatibility/contextual only.

## Canonical queue coverage

`docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json` currently contains `146` entries.
The overlay classifies all entries without reactivating historical batches.

The overlay class mapping for existing queue classes is:

- `historical_complete_do_not_run` → `historical` (34)
- `executable_now` → `active` (1)
- `executable_later` → `active`, `must-run-before-ui` where domain support is proven
  (75)
- `absorbed_as_overlay` → `supporting` (18)
- `blocked_until_dependency` → `blocked-until-clean` and `must-run-after-domain` (12)
- `conditional_trigger_only` → `supporting`

## Overlay classes for this phase

All 146 entries are preserved in the source queue and are included here through class
translation rules. New lane batches are assigned one or more classes:

```text
Batch ID                               Overlay Class(es)
AMBITION-GRAPH-FOUNDATION-01           active, supporting, spark-safe, must-run-before-ui, must-run-after-domain
PROOF-RECOVERY-LIFECYCLE-01            active, supporting, spark-safe
RECOMMENDATION-TRACE-TRUST-SEAM-01     active, supporting, spark-safe
PERSONAL-RUNTIME-LOCAL-TRUST-01        active, supporting, spark-safe
SHELL-CONTINUITY-DOCK-MATERIALS-01     active, supporting, spark-safe
TODAY-REALITY-MERIDIAN-VISUAL-01       active, supporting, spark-safe, must-run-before-ui
CAPTURE-ATMOSPHERE-COMPOSER-VISUAL-01  active, supporting, spark-safe
TIME-PRESSURE-LEDGER-VISUAL-01         active, supporting, spark-safe
GOALS-CONSTELLATION-ATLAS-VISUAL-01    active, supporting, spark-safe
YOU-USER-SYSTEM-PROFILE-VISUAL-01      active, supporting, spark-safe
MOAT-ADDENDUM-STATE-SCREENS-01         active, supporting, spark-safe
ACCESSIBILITY-VISUAL-CANON-01          active, supporting, spark-safe, blocked-until-clean (if no accessibility audit available)
VISUAL-QA-PREVIEW-FIXTURES-01          active, visual-proof-required, spark-safe
FINAL-VISUAL-CANON-INTEGRATION-01      active, supporting, senior-review-required
```

### Class vocabulary posture for uncovered families

- `archive-candidate`, `delete-candidate`, `consolidate`, and `split` are explicitly not
  assigned in this phase for this lane.
- `active`, `supporting`, `historical`, `blocked-until-clean`,
  `must-run-before-ui`, `must-run-after-domain`, `visual-proof-required`, `spark-safe`,
  `senior-review-required` are used as needed above.
- `supported` and `unsupported` are not used by this lane schema.

## Classification summary and sequencing

The visual lane ordering is:

1. Source truth and visual canon authority lock.
2. Ambition Graph domain foundations.
3. Proof / Closure / Recovery lifecycle scaffolding.
4. RecommendationTrace / Trust Seam / "Why this?".
5. Personal Runtime / local trust controls.
6. Shared materials / Continuity Dock / shell primitives.
7. Today / Reality Meridian.
8. Capture / Atmosphere Composer and route reveal.
9. Time / Pressure Ledger / Reflow Preview.
10. Goals / Constellation Atlas / Ambition Graph / Proof Trail.
11. You / User System Profile / Personal Runtime.
12. Moat addendum state screens.
13. Accessibility + VT-equivalent states.
14. Preview fixture and visual QA gates.
15. Repo cleanup / obsolete-canon quarantine.
16. Validation packets and proof-honesty.
17. Final integration and release-proof-ready handoff.

## Required compatibility controls

- `PK18` is the queue next-eligible batch from current run-state context; this
  phase does not execute it.
- No completed or historical batches are re-run.
- Hard Red boundaries for this lane:
  - no `Plan` top-level tab,
  - no sixth top-level tab,
  - no task list / dashboard / calendar-follower behavior,
  - no detached Start Here card,
  - no AI-hosted runtime or cloud-first dependency claims,
  - no accessibility/privacy/release claim without evidence.
- Every visual batch prompt created in this phase must include runner headers.

## EFC and claim posture

For each batch touching user-facing behavior, explainability, local trust, accessibility
equivalents, or proof surfaces:

- `EFC applicability`: `invoked` by default for this lane.
- `Release claim`: only local VM/Mac proof and local scans are applicable; no signed
  platform claims are allowed in this phase.
- `Accepted Yellow`: allowed only with explicit no-claim and blocker recording.
