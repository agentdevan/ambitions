# FVQ04 Recurring UI-Batch Rendered Proof Protocol

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, terminology-quarantine
> Dispositions: quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active-scope Codex OS protocol.
Date: 2026-05-05

## Purpose

FVQ04 makes rendered visual proof recurring. It prevents future UI-affecting batches from passing Green while rendered screens degrade.

## Applicability

FVQ04 applies to any batch that touches:

- SwiftUI view files
- app shell/chrome/navigation
- visual primitives
- design system primitives
- preview fixtures
- screenshot assets
- widgets
- Live Activities
- App Intents visible confirmations
- notifications
- onboarding
- App Store screenshots
- motion/haptics with visual state
- accessibility presentation

## Required Per-Batch Visual Proof

Every UI-affecting batch must record:

- surfaces touched
- primary object owner
- screenshots/previews updated
- simulator or preview freshness proof
- visual score impact
- accessibility/readability impact
- Reduce Motion impact
- privacy-sensitive rendering impact
- dashboard/card-stack drift result
- scaffold/debug-language result
- whether FVQ repair is required

## Green Requirements

A UI-affecting batch may close Green only if:

- relevant rendered surface remains at/above visual bar
- no Hard Visual Red exists
- screenshot/preview evidence is durable or explicitly covered by an existing FVQ artifact
- visual changes are narrow and source-truth aligned
- no generated slop patterns were introduced

## Yellow Requirements

Accepted Yellow requires:

- durable evidence still exists for the primary screen
- issue does not affect primary product object identity
- owner batch is explicit
- repair path is concrete
- no sensitive/private content exposure
- no dashboard/prototype hard failure

## Red Requirements

Red if:

- Green would rely only on compile/tests/docs
- rendered output is materially worse
- no screenshot or preview evidence exists for a visible change
- visual issue affects primary object identity
- UI becomes dashboard/card-stack/prototype/generic
- screenshot freshness cannot be established

## Orchestrator Rule

Global Batch Execution Orchestrator must treat FVQ evidence as part of the Validation Evidence Gate for all UI-affecting batches.

If a batch cannot produce FVQ evidence because tooling is unavailable, it must write an operator proof checklist and classify the limitation as Yellow, not Green-by-default.

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
