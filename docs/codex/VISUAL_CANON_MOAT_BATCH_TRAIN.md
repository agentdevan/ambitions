# Visual Canon + Moat Front-End Batch Train

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: docs/control-plane only
Date: 2026-05-11

## Purpose

Install the visual/moat front-end sequence as a lane-compatible train without
executing runtime app source in this phase.

## Train scope (control-plane only)

- Build missing batch prompts under `prompts/batches/` for visual/moat front-end work.
- Sequence lane batches so they respect local-first and existing product truth.
- Prevent duplicate semantically identical batches by checking existing batch IDs in repo.

## Required new batch set for this phase

1. `AMBITION-GRAPH-FOUNDATION-01`
2. `PROOF-RECOVERY-LIFECYCLE-01`
3. `RECOMMENDATION-TRACE-TRUST-SEAM-01`
4. `PERSONAL-RUNTIME-LOCAL-TRUST-01`
5. `SHELL-CONTINUITY-DOCK-MATERIALS-01`
6. `TODAY-REALITY-MERIDIAN-VISUAL-01`
7. `CAPTURE-ATMOSPHERE-COMPOSER-VISUAL-01`
8. `TIME-PRESSURE-LEDGER-VISUAL-01`
9. `GOALS-CONSTELLATION-ATLAS-VISUAL-01`
10. `YOU-USER-SYSTEM-PROFILE-VISUAL-01`
11. `MOAT-ADDENDUM-STATE-SCREENS-01`
12. `ACCESSIBILITY-VISUAL-CANON-01`
13. `VISUAL-QA-PREVIEW-FIXTURES-01`
14. `FINAL-VISUAL-CANON-INTEGRATION-01`

No existing runner-compatible prompts were found for these exact IDs in this phase.

## Required sequence

1. Source-truth + visual authority install (this spec + overlay docs).
2. Ambition Graph foundations and domain scaffolding prompts.
3. Proof/recovery/closure lifecycle.
4. Recommendation trace and Trust Seam explainability.
5. Personal Runtime local trust controls.
6. Shell materials + continuity primitives.
7. Today Reality Meridian install prompts.
8. Capture Atmosphere Composer prompts.
9. Time Pressure Ledger / Reflow prompts.
10. Goals Constellation Atlas + proof trail prompts.
11. You User System Profile / runtime controls prompts.
12. Moat addendum screens.
13. Accessibility and visual proof gates.
14. Visual QA fixtures and preview matrices.
15. Final integration and honesty notes.

## Lane class and dependency constraints

- `active`: all 14 new lane batches.
- `must-run-before-ui`: Today/Accessibility/Visual QA checkpoints that produce
  safe handoff boundaries.
- `must-run-after-domain`: Proof recovery and Recommendation batches depend on domain
  consistency already represented in queue and run context.
- `visual-proof-required`: `VISUAL-QA-PREVIEW-FIXTURES-01`.
- `gpt-5.4-mini-safe`: all 14 batches are bounded and control-plane-safe.
- `senior-review-required`: `FINAL-VISUAL-CANON-INTEGRATION-01` requires human review for
  global handoff assumptions.

## Run behavior for future execution

- Do not execute these batches in this phase.
- Preserve `Time` as top-level IA in all future prompt text.
- Never convert `Plan` to a top-level destination.
- Use runner requirement headers in every generated prompt.
- For each future run batch, include EFC applicability (`invoked`, `not applicable`, or
  accepted Yellow owner).

## Non-goals for this phase

- Do not add app source edits.
- Do not claim implementation completeness.
- Do not assert accessibility, privacy, release, or visual conformance proof without
  logs/fixtures.

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
