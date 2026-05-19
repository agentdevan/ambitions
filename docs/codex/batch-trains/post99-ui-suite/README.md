# POST99 UI Suite Review And Implementation Train

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

It must reject generic dashboard/card-stack/task-list/calendar/chatbot drift.

## Completion behavior

Batch 00 must produce a concrete batch map and either:

- install the next executable UI Suite batch prompt, or
- explicitly route to an existing prompt with a command, or
- return Yellow/Red with the blocking reason.

Repo OS should no longer report idle when this activation file is present, Repo Doctor is Green, and no stronger governance blocker exists.
