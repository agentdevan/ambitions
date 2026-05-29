# FCP17 Schedule Availability Defaults Center Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Completed Green
Date: 2026-05-05
Train: FCP01-FCP30 Flagship Completion Train
Batch: FCP17 Schedule / Availability / Defaults Center
Owner: You / Plan

## Purpose

FCP17 creates the You-owned Availability Center from the existing PD16 Schedule,
Planning Defaults, Automation Trust, Vacation / Away Time, and Duration Source
truth. It gives Plan and Today a reviewable user-control surface for hard
context and capacity defaults without turning You into a settings dump or Plan
into a calendar clone.

## Source Truth

- `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/audits/pd16-schedule-availability-planning-defaults-depth-report.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `Native/Ambitions/Domain/ProfilePlanningDefaultsModels.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`

## Scope

Allowed:

- Add typed Availability Center state under You/Profile domain models.
- Project hard context, protected pockets, planning defaults, automation trust,
  duration source proof, and vacation/away behavior from existing local defaults.
- Add a small SwiftUI card for the Schedule & Availability detail sheet.
- Add focused Profile service tests.
- Update FCP/global train reports and state.

Forbidden:

- Do not edit top-level tabs, routes, raw values, persistence/schema, sync,
  CloudKit, account behavior, calendar writers, reminders, entitlements,
  workflows, dependencies, AI runtime, LDI runtime, release/legal/privacy claim
  files, or broad Plan/Today surfaces.
- Do not request calendar/reminder permission from You.
- Do not write calendar data.
- Do not auto-fill open time or silently reflow plans.
- Do not claim physical-device proof, public accessibility conformance,
  TestFlight readiness, App Store readiness, release readiness, or legal/privacy
  compliance.

## Acceptance

- Availability Center names hard context: work, school, protected time, sleep,
  commute/buffers, and away time.
- Open time is not automatically filled.
- Vacation is not free time unless explicitly marked available.
- Guided automation is the default.
- Duration sources are labeled and not presented as fact when suggested or
  historical.
- Defaults explain how they affect Today and Plan.
- The surface remains You-owned and trust/control-first.

## Validation

- `xcodegen generate`
- Focused Profile tests:
  - `AmbitionsTests/ProfileFeatureServiceTests`
- `scripts/build-local.sh`
- `git diff --check`
- touched-file trailing whitespace scan
- CQS product/privacy/prompt scans where relevant
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

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
