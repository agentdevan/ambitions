# Frontend First Viewport Budget Gate

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite
> Dispositions: rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Active FET gate
Date: 2026-05-09
Batch: FET03

## Purpose

The first viewport decides whether Ambitions feels like a composed native product or an inventory of panels. This gate prevents top-level screens from passing because every canonical concept is present while nothing has priority.

## Hard Budget

For top-level surfaces and landing-detail first screens:

- max 1 primary object
- max 2 support objects
- max 4 chips
- max 12 body-copy lines
- max 1 floating control
- max 1 bottom navigation system
- no nested card-on-card inside the primary object
- no architecture, governance, implementation, local-first, source-system, or diagnostic copy above the fold

## Green

Screenshot or preview evidence proves one primary object, bounded support, compressed copy, no generic panel stack, and a clear next action.

## Yellow

Minor density debt exists with screenshot evidence, no hard Red, and named owner.

## Red

More than one primary object, more than two support objects, more than four chips, more than twelve body-copy lines, architecture copy above fold, nested primary-card stacking, or no visual evidence for UI-touching work.

## Required Report Fields

- primary object
- support object count
- chip count
- body-copy line count
- floating control count
- bottom navigation owner
- screenshot/preview path
- Red repair decision

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
