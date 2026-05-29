# POST99 UI Suite Review And Implementation Train

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active executable train activation

## Purpose

This train converts the post-23 recommendation boundary into an executable runner lane after `AMB-FE-BE-INTEGRATED-PROOF-99` is Green.

It exists because `AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md` recommends the following order, but recommendation reports do not automatically register executable batches with Repo OS / Codex OS:

1. Core-loop proof and backend repair
2. UI Suite review and implementation
3. Frontend Flagship
4. Apple continuity and durability strategy
5. Launch-believability and closed beta readiness

The first lane is complete when the current HEAD contains Green bounded proof for `AMB-FE-BE-MOAT-SCENARIO-PROOF-98` and Green integrated packaging for `AMB-FE-BE-INTEGRATED-PROOF-99`.

This train activates lane 2 without inventing a new product direction.

## Source authority

Read in this order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md`
8. `docs/audits/amb-fe-be-integrated-proof-99-report.md`
9. `frontend/visual-encyclopedia/**`
10. `.codex/skills/**`
11. `.codex/operations/**`

## Active first batch

```bash
scripts/ambitions-codex-train.sh POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00 prompts/batches/POST99-UI-SUITE-REVIEW-IMPLEMENTATION-00.md
```

## UI Suite Batch Map

This activation file does not invent a new UI program. It routes into the existing UI Studio prompt family that was already installed for the flagship UI lane.

1. `UI-STUDIO-01-SURFACE-BRIEF-SYSTEM`
   - First executable UI Suite batch
   - Best entry point for surface-level review and implementation because it establishes the shared visual brief before narrower polish or red-team passes
   - Command:

```bash
scripts/ambitions-codex-train.sh UI-STUDIO-01-SURFACE-BRIEF-SYSTEM prompts/batches/ui-flagship/UI-STUDIO-01-SURFACE-BRIEF-SYSTEM.md
```

2. `UI-STUDIO-02-TOKENS-AND-MATERIALS-REVIEW`
   - Follow-on review once the surface brief is established

3. `UI-STUDIO-03-REALITY-MERIDIAN-ART-DIRECTION`
   - Follow-on art-direction pass for the Today / Reality Meridian surface

4. `UI-STUDIO-04-START-HERE-COMMAND-OBJECT`
   - Follow-on command-object refinement for Start Here

5. `UI-STUDIO-05-FIVE-SURFACE-COMPOSITION`
   - Follow-on top-level composition review across the flagship shell

6. `UI-STUDIO-06-CLOSURE-RECOVERY-INTERACTIONS`
   - Follow-on review for closure and recovery interaction quality

7. `UI-STUDIO-07-TRUST-CONTINUITY-UX`
   - Follow-on trust and continuity review

8. `UI-STUDIO-08-ONBOARDING-CATEGORY-UX`
   - Follow-on onboarding and category UX review

9. `UI-STUDIO-09-PREVIEW-SCREENSHOT-MATRIX`
   - Follow-on preview and screenshot-readiness matrix

10. `UI-STUDIO-10-FAANG-LEVEL-UI-RED-TEAM`
    - Final review pass for generic-drift and polish regressions

## Scope boundary

This is a UI Suite review and implementation activation lane. It may inspect and modify SwiftUI, tests, previews, design-system primitives, screenshot-readiness proof, accessibility proof, motion/reduce-motion behavior, haptics, visual QA scaffolding, and review artifacts when the active batch explicitly scopes those changes.

It must not claim release readiness, App Store readiness, TestFlight readiness, privacy/legal approval, public accessibility conformance, performance readiness, device proof, or backend completion unless later proof artifacts establish those claims.

## Non-negotiable product boundary

Ambitions remains a premium native iPhone-first Personal Life OS with active IA:

```text
Today / Goals / Capture / Time / You
```

The UI Suite must preserve:

- Today → Reality Meridian
- Goals → Constellation Atlas
- Capture → Atmosphere Composer
- Time → LifeShape Field
- You → User System Profile
- Start here
- Recommended step
- Start now
- Open step
- Step
- local-first deterministic Private Life Runtime
- proof, receipt, source freshness, closure, recovery, and replay visibility

It must reject generic productivity-app drift and preserve the flagship object discipline.

## Completion behavior

Batch 00 must produce a concrete batch map and either:

- install the next executable UI Suite batch prompt, or
- explicitly route to an existing prompt with a command, or
- return Yellow/Red with the blocking reason.

Repo OS should no longer report idle when this activation file is present, Repo Doctor is Green, and no stronger governance blocker exists.

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
