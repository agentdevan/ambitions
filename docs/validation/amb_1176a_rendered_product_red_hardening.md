# AMB-1176A Rendered Product Red Hardening

Status: Red / Ready for Visual Review maximum after source repair
Date: 2026-06-22
Branch: main

## Purpose

AMB-1176A exists because Time / LifeShape Field proof exposed a product-quality failure: source architecture and focused tests could pass while the rendered root surface still looked like a prototype report stack.

AMB-1176 remains a blocker for AMB-1177 and downstream master fold-in until rendered product acceptance is satisfied.

## Scope

- Remove duplicate crown ownership.
- Replace stacked LifeShape Field root composition with one dominant root instrument.
- Demote or delete report-panel anatomy from root Time.
- Make the visual field the first-viewport product object.
- Remove root semantic jargon.
- Stop fabricated minimum-count capacity claims.
- Add product-object dominance, single-owner, report-panel, projection-truth, language-category, test-strength, visual-target, and device-evidence gates.
- Require attached target-versus-actual visual proof.

## Current Red Fixture

Red fixture:

`docs/design/red_fixtures/time/current_failed_lifeshape_field.png`

This fixture documents the failure family:

- duplicate shell/object crown ownership
- stacked component anatomy
- report-panel primary object
- text carrying meaning before visuals
- selected layer disconnected from the field
- local screenshot path treated as enough proof

## Target And Rubric

Target:

`docs/design/targets/time/lifeshape_field_visual_target.md`

Rubric:

`docs/design/targets/time/lifeshape_field_acceptance_rubric.md`

## Status Ceiling

Codex may reach Ready for Visual Review after source repair and current simulator proof.

Codex may not claim Visual Green or Release Green.

Visual Green requires independent visual review, reviewable attached/embedded target and actual screenshots, and physical iPhone proof with build SHA.

## Validation Required

- `python3 scripts/ambitions-visual-proof-gate.py`
- `python3 scripts/ambitions-test-strength-audit.py`
- `python3 scripts/ambitions-screenshot-artifact-audit.py`
- `python3 scripts/ambitions-linear-green-claim-audit.py`
- `python3 scripts/ambitions-device-proof-required.py`
- `scripts/ambitions-xcode-test-focused.sh --batch AMB-1176A --only-testing AmbitionsTests/RenderedProductAcceptanceAuditTests --timeout 15m --kill-after 90s`
- Rendered UI tests for product-object dominance, single-crown ownership, first-viewport copy budget, and visual target attachment after the root rebuild.

## Rollback

Revert the AMB-1176A source hardening commit and restore the prior Time root implementation only if the new gates break unrelated app launch/build behavior. Do not rollback by deleting the acceptance truth or visual-proof gates without explicit owner approval.
