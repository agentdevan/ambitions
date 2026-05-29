# PD17 Cross-Surface Proof and Review Integration Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-98202852, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Queued Ambitions 4.0 Product Depth batch; not started; not implemented; blocked pending `Start Product Depth Train` and prerequisite gates.

## Batch Identity

- Batch ID: `PD17`
- Name: Cross-Surface Proof and Review Integration
- Train: Product Depth
- Type: Mixed implementation
- Primary surface ownership: Cross-surface
- Required approval phrase: `Start Product Depth Train`

## Purpose

Connect Today, Goals, Capture, Plan, and You through proof and review.

## Product Depth Ownership

Owns: Capture to Goal proof; Today completion to Goal proof rail; Plan reflow to receipt; Goal change to You history; receipt/detail navigation; review prompts.

## Required Source Truth Files

- README.md
- AGENTS.md
- docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md
- docs/canon/Ambitions_Beyond_3_0_Roadmap.md
- docs/canon/Ambitions_Product_Experience_OS_Index.md
- docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md
- docs/canon/Ambitions_Product_Depth_Plan.md
- docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md
- docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md
- docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md
- docs/codex/BATCH_REGISTRY.md
- docs/codex/CONTEXT_INDEX.md
- .codex/reports/current-run-state.md
- .codex/reports/current-batch-train-state.md

## Relationship To PXOS

PXOS owns the user-facing hierarchy, top-level composition rule, copy, visual, accessibility, trust, recovery, and Product Depth drill-down gates. This batch may proceed only when the named PXOS prerequisites are Green or accepted Yellow. It must preserve visual orientation at top level and push secondary detail behind owned drill-downs.

## Relationship To ME

ME owns maintainability, file-size, extraction, and testability gates. If this batch touches production code or large owner files, it must run the relevant ME owner gate first and avoid making future extraction harder.

## Relationship To CS

CS owns route, raw-value, deep-link, widget, App Intent, import/export, and persistence compatibility. This batch must not rename, remove, or retire compatibility seams without the relevant CS proof.

## Relationship To AOS

AOS owns runtime intelligence, recommendation, source truth, proof trust, adaptation, alternate-path, reality-drift, and commitment-time logic. If this batch needs AOS runtime behavior, that dependency is a blocker until the named AOS gates are Green.

## Relationship To REC / Release Claims

REC owns release evidence and claim boundaries. This batch must not claim release readiness, App Store readiness, TestFlight readiness, physical-device proof, public accessibility conformance, signed archive validation, App Store Connect validation, or external-platform proof.

## Required Prerequisite Gates

- PX15 Green
- PD07/PD12/PD15 dependencies Green
- CS route/navigation compatibility Green
- AOS proof/runtime dependency if data model touched

## Allowed Files

- Native/Ambitions/Features/**
- Native/Ambitions/Domain/**
- Native/Ambitions/Services/**
- Native/AmbitionsTests/**
- Native/AmbitionsUITests/**
- docs/**
- .codex/**

## Forbidden Files

- New top-level review tab
- Route breakage
- Hidden proof mutation
- .github/workflows/**
- dependency manifests and lockfiles unless a future explicit dependency approval exists
- Xcode project/signing/build settings
- generated build output unless validation logs are explicitly captured
- release/platform claim files unless REC gate approves

## Implementation Boundary

This batch may implement only its named Product Depth scope after all prerequisites pass. It must keep changes narrow, owner-scoped, test-backed, accessibility-aware, and rollbackable.

## Non-Goals

- No new top-level tab or destination.
- No generic surface, stacked-card top-level surface, calendar clone, habit tracker mode, chatbot-first AI surface, inbox/notes mode, or project-management system.
- No unsupported release, platform, physical-device, TestFlight, App Store, or public accessibility claim.
- No PXOS, AOS, ME, CS, REC02, or Product Depth status overclaim.
- No dependency, workflow, signing, persistence/schema, route, widget, or App Intent change outside explicit scope and gates.

## Batch-Specific Deliverables

- Capture to Goal proof
- Today completion to Goal proof rail
- Plan reflow to receipt
- Goal change to You history
- receipt/detail navigation
- review prompts.

## Batch-Specific Acceptance Criteria

- Cross-surface links preserve route/navigation compatibility.
- Proof and receipts connect surfaces without creating a new surface.
- Review prompts are sparse, contextual, and user-owned.
- AOS proof/runtime dependencies are blockers if data model/runtime changes are required.

## Required Validation Commands

- `git status --short`
- `git diff --check`
- `grep -R "Product Depth.*started\|PD01.*complete\|PD18.*complete" docs .codex | cat || true`
- `grep -R "new top-level tab\|stacked cards\|calendar clone\|chatbot" docs/canon docs/codex .codex | cat || true`
- `grep -R "App Store ready\|TestFlight ready\|production ready\|physical device passed" README.md docs .codex | cat || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `focused build/test pack named by touched owner files`
- `copy/accessibility/product-drift scans for touched paths`
- `file-size and diff-size before/after check`

## Required Evidence Outputs

- Batch report or handoff section with files changed, proof run, validation strength, and non-claims.
- Updated registry/context/run-state only after validation evidence exists.
- Green/Yellow/Red gate table with deferral owners for any Yellow.
- Rollback or repair path.
- Exact next safe prompt/path.

## Required Skills / Review Boards

- source truth / canon review skill
- batch prompt quality skill
- evidence / validation skill
- product decision lock review
- scope boundary review
- product-depth strategist
- top-level surface composition reviewer
- PXOS product experience reviewer
- ME maintainability reviewer if code or owner files are touched
- CS compatibility reviewer if routes, names, external surfaces, import/export, or persistence are touched
- AOS runtime/privacy/trust reviewer if intelligence/runtime/source-truth/proof behavior is touched
- release claim safety reviewer if copy, messaging, handoff, or release-adjacent text is touched

## Green / Yellow / Red Criteria

Green: scope completed, required gates Green or accepted Yellow, validation Strong or Adequate for batch type, no forbidden files touched, no product widening, no unsupported claims, no compatibility break, evidence logged, rollback path documented, and commit is safe.

Yellow: non-safety advisory is classified, owned by a future batch or backlog, does not affect next-batch safety, does not hide a Red, and is documented in evidence/handoff.

Red: new top-level tab, stacked-card top-level surface, generic dashboard/calendar/chatbot/task/habit drift, unsupported release/platform claim, forbidden file touch, compatibility break, accessibility blocker, weak/missing implementation validation, unclassified failure, product canon weakening, test weakening, or train status overclaim.

## Stop Conditions

Stop on any Red, missing prerequisite gate, unclear source truth, unsafe dirty state, human-proof requirement, weak implementation validation, forbidden file touch, or pressure to widen Product Depth beyond existing surfaces.

## Rollback / Repair Expectations

Make the smallest safe repair. Do not weaken product canon, delete tests, loosen gates, hide failures, remove accessibility requirements, bypass ME/CS/AOS/REC gates, or make the UI more generic to pass validation. If safe repair is impossible, stop and write a Red repair report.

## What This Batch May Claim

It may claim only the completed, validated scope of `PD17` after evidence and commit.

## What This Batch Must Not Claim

It must not claim Product Depth train started before approval, Product Depth complete before PD18, PXOS implemented, AmbitionsOS implemented, release-ready, App Store ready, TestFlight ready, physical-device passed, public accessibility conformant, platform integrated, or human proof completed.

## What This Batch Does Not Prove

It does not prove release readiness, human-only proof, public accessibility conformance, App Store Connect validation, signed archive distribution, TestFlight distribution, external platform rendering, or unrelated PD/PXOS/AOS/ME/CS batch completion.

## Commit Message Recommendation

`Run PD17 Cross-Surface Proof and Review Integration`

## Next Safe Prompt / Path

Use the next direct PD prompt only after this batch is Green or accepted Yellow, committed, pushed, branch-clean, and continuation gates allow it. Otherwise stop and produce a repair or decision prompt.

## Living Dream Architecture Hook

LDI hook: Cross-surface proof/review may prepare source dependency index, dream handling receipts, source change receipts, mutation receipts, and user-review-required flows.

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
