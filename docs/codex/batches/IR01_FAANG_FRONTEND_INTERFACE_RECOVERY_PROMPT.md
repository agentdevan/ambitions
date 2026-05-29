# IR01 FAANG Frontend Interface Recovery Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-82417320, AMB28-same_source_file_targeted_by_multiple_active_batches-50973887, AMB28-same_source_file_targeted_by_multiple_active_batches-64094379, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Ready-to-run single-batch prompt
Date: 2026-05-08
Train: Interface Recovery / Codex OS Frontend Quality
Required skill: `.codex/skills/faang-frontend-implementation-team.md`
Required protocol: `docs/codex/frontend-implementation/FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM.md`

## Purpose

Run a focused frontend recovery batch that repairs Ambitions' live SwiftUI surfaces from stacked compliance-panel output toward a FAANG-quality native iPhone interface. This batch exists because prior global batch work implemented many correct concepts but allowed the rendered UI to become too dense, too generic, and too explanatory.

This is not a new feature batch. It is a composition, deletion, hierarchy, shell, and rendered-proof batch.

## Approval Phrase

`Run Interface Recovery Batch IR01`

## Scope

Allowed files:

- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppShellPresentationMode.swift`
- `Native/Ambitions/Features/Today/**`
- `Native/Ambitions/Features/Goals/**`
- `Native/Ambitions/Features/Captures/**`
- `Native/Ambitions/Features/Planning/**`
- `Native/Ambitions/Features/Profile/**`
- `Sources/Components/**`
- preview/screenshot fixture files needed for visual proof
- focused tests or scripts needed for visual-budget proof
- `docs/audits/ir01-faang-frontend-interface-recovery-report.md`

Forbidden unless required by compile repair:

- persistence/schema migrations
- service/runtime intelligence changes
- sync/cloud behavior
- new top-level tabs
- new product features
- legal/privacy/release claims
- unrelated docs cleanup

## Required Source Truth

Read first:

1. `docs/codex/frontend-implementation/FAANG_FRONTEND_IMPLEMENTATION_TEAM_OPERATING_SYSTEM.md`
2. `.codex/skills/faang-frontend-implementation-team.md`
3. `docs/codex/visual-quality/FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL.md`
4. `docs/canon/Ambitions_Signature_Interface_System.md`
5. `docs/canon/Ambitions_3_0_Ambition_Meridian_Shell_SwiftUI_Build_Spec.md`
6. `docs/canon/PXOS_Today_Experience_Canon.md`
7. latest FVQ/visual QA audit reports with screenshots, if present

## Known Red-State Hypothesis

Use simulator screenshots as the visual baseline. Current likely issues:

- top-level screens read as generic rounded panel stacks
- Today exposes too many internal proof/planning/recovery/closure concepts at once
- `HeroDecisionPanel` and rich panel primitives allow unbounded vertical content
- shell bottom chrome can read as native tab bar plus custom Meridian plus floating plus control instead of one coherent navigation system
- repeated top headers and explanatory strips make tabs feel templated
- visible copy explains product architecture instead of user value

Confirm or correct this hypothesis from repo evidence before implementation.

## Required Work

### 1. Screen Contracts

For each touched top-level surface, write a pre-implementation contract in the report:

```text
Surface:
Primary object:
Secondary objects, maximum two:
Primary action:
Collapsed detail path:
Visible copy budget:
Visible chip budget:
Bottom chrome owner:
Accessibility equivalent:
Reduce Motion equivalent:
Deletion/collapse targets:
```

### 2. Shell / Chrome Repair

Resolve bottom chrome competition.

Requirements:

- one visible bottom navigation owner
- no independent-looking native tab bar plus custom rail plus floating global action conflict
- floating plus must be contextual, integrated, or demoted
- headers must be compact and must not repeat heavy location context already provided by selected tab state

### 3. Today Repair

Rebuild Today's first viewport around Start Here as a constrained primary object.

Default first viewport may show only:

- `Start here`
- one recommended step title
- one reason line
- one time/goal fit proof line
- one primary CTA
- one collapsed `Why this?` or receipt/detail affordance

Move or collapse by default:

- TodayContractGrid
- protected must-do
- not-today state
- recovery fallback
- action closure entry
- plan layer strip
- one-step goals strip
- repeated semantic chips

These can remain available through disclosure, detail, receipt drawer, or below first viewport.

### 4. Other Top-Level Surface Pass

For Goals, Capture, Time, and You:

- enforce one primary visual thesis
- reduce visible architecture copy
- collapse support proof/details when not immediately needed
- ensure each tab feels related but not cloned
- keep surface-specific object identity visible

### 5. Rich Primitive Guardrails

Add bounded role slots or screen-level guardrails so hero/top-level objects cannot become unlimited panel dumps.

Acceptable approaches:

- add constrained hero variants
- add visible-density configuration
- split detail content into disclosure/drawer slots
- add debug/precondition-style visual budget helpers where safe
- add tests/scripts scanning for known density smells

### 6. Rendered Proof

Produce or reference durable rendered proof for Today, Goals, Capture, Time, and You.

Required proof table:

| Surface | Before proof | After proof | First viewport budget | Verdict |
| --- | --- | --- | --- | --- |

If simulator capture is unavailable, classify as Accepted Yellow at best and provide an operator screenshot checklist. Do not close Green from compile/tests/docs alone.

## First Viewport Budget

Every touched top-level tab must pass or explicitly justify:

- max 1 primary surface/object
- max 2 support surfaces/objects
- max 4 chips
- max 12 visible body-copy lines
- max 1 floating control
- max 1 bottom navigation system
- no card-on-card nesting inside the primary object
- no internal architecture copy above the fold
- one obvious visual thesis within two seconds

## Validation

Required:

- focused build/test command available in repo
- focused visual-budget script/test if added
- screenshot or preview proof per FVQ04
- accessibility impact statement
- Reduce Motion impact statement
- performance/material/motion risk statement

## Closure Rules

Green only if:

- build/focused validation passes
- rendered proof exists
- first viewport budget passes
- Today reads as one Start Here surface, not a report
- shell reads as one coherent navigation system
- no top-level surface reads as dashboard/card-stack/prototype/generic

Recoverable Red if:

- rendered output remains dense/generic
- bottom chrome still competes
- primary object identity remains unclear
- visible UI changed but proof is missing

Hard Red if:

- batch tries to close Green without rendered proof
- repair requires weakening accessibility, privacy, canon, validation, or release truth
- primary object identity is broken across top-level tabs

## Required Report

Write `docs/audits/ir01-faang-frontend-interface-recovery-report.md` with:

- files changed
- screen contracts
- deleted/collapsed visible inventory
- before/after proof references
- first viewport budget table
- visual QA verdict
- accessibility verdict
- performance verdict
- remaining Yellow/Red gaps
- exact next batch recommendation

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
