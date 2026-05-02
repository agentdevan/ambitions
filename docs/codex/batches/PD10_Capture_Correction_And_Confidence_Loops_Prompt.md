# PD10 Capture Correction and Confidence Loops Prompt
<!-- markdownlint-disable MD013 -->

Status: Queued Ambitions 4.0 Product Depth batch; not started; not implemented; blocked pending `Start Product Depth Train` and prerequisite gates.

## Batch Identity

- Batch ID: `PD10`
- Name: Capture Correction and Confidence Loops
- Train: Product Depth
- Type: Implementation
- Primary surface ownership: Capture
- Required approval phrase: `Start Product Depth Train`

## Purpose

Let the user correct where captured items go and improve future placement without hidden automation.

## Product Depth Ownership

Owns: Wrong-place correction; confidence labels; place somewhere else; not a goal; not now; correction receipt; preference learning boundary.

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

- PD09 Green
- AOS Adaptation/Source Truth dependency if personalization touched
- Privacy/no-hidden-memory gate Green
- Explanation copy gate Green

## Allowed Files

- Native/Ambitions/Features/Captures/**
- Native/Ambitions/Domain/**
- Native/Ambitions/Services/**
- Native/AmbitionsTests/**
- docs/**
- .codex/**

## Forbidden Files

- Hidden learning
- AI confidence copy
- Automatic goal creation
- .github/workflows/**
- dependency manifests and lockfiles unless a future explicit dependency approval exists
- Xcode project/signing/build settings
- generated build output unless validation logs are explicitly captured
- release/platform claim files unless REC gate approves

## Implementation Boundary

This batch may implement only its named Product Depth scope after all prerequisites pass. It must keep changes narrow, owner-scoped, test-backed, accessibility-aware, and rollbackable.

## Non-Goals

- No new top-level tab or destination.
- No generic dashboard, stacked-card top-level surface, calendar clone, habit tracker mode, chatbot-first AI surface, inbox/notes mode, or project-management system.
- No unsupported release, platform, physical-device, TestFlight, App Store, or public accessibility claim.
- No PXOS, AOS, ME, CS, REC02, or Product Depth status overclaim.
- No dependency, workflow, signing, persistence/schema, route, widget, or App Intent change outside explicit scope and gates.

## Batch-Specific Deliverables

- Wrong-place correction
- confidence labels
- place somewhere else
- not a goal
- not now
- correction receipt
- preference learning boundary.

## Batch-Specific Acceptance Criteria

- Correction creates a receipt or reviewable record.
- Confidence language is plain, bounded, and not model theater.
- No hidden memory or personalization happens without consent/source truth.
- Corrections improve future placement only inside approved AOS/adaptation boundaries.

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

It may claim only the completed, validated scope of `PD10` after evidence and commit.

## What This Batch Must Not Claim

It must not claim Product Depth train started before approval, Product Depth complete before PD18, PXOS implemented, AmbitionsOS implemented, release-ready, App Store ready, TestFlight ready, physical-device passed, public accessibility conformant, platform integrated, or human proof completed.

## What This Batch Does Not Prove

It does not prove release readiness, human-only proof, public accessibility conformance, App Store Connect validation, signed archive distribution, TestFlight distribution, external platform rendering, or unrelated PD/PXOS/AOS/ME/CS batch completion.

## Commit Message Recommendation

`Run PD10 Capture Correction and Confidence Loops`

## Next Safe Prompt / Path

Use the next direct PD prompt only after this batch is Green or accepted Yellow, committed, pushed, branch-clean, and continuation gates allow it. Otherwise stop and produce a repair or decision prompt.
