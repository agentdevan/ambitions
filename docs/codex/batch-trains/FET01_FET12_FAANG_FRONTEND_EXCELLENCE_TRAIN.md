# FET01-FET12 FAANG Frontend Excellence Train

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-15187566, AMB28-same_source_file_targeted_by_multiple_active_batches-21604483, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-42900710, AMB28-same_source_file_targeted_by_multiple_active_batches-46969109, AMB28-same_source_file_targeted_by_multiple_active_batches-62910670, AMB28-same_source_file_targeted_by_multiple_active_batches-63479679, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429 and 1 more

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Queued Codex OS / frontend excellence train; no app UI implementation starts by this document
Date: 2026-05-09
Parent: CQS25 / FET00

## Purpose

FET01-FET12 converts the FET operating system into durable source truth, evidence packets, preview/screenshot discipline, and repair sequencing before further visible top-level UI expansion. It prevents future frontend batches from closing Green because SwiftUI compiled while the simulator still looks generic, dense, explanatory, or visually interchangeable.

## Ordering Rule

FET01-FET12 must run before any further visible top-level UI expansion. Future FCP, AFI, DAV, PD, SI, AOS UI, LDI UI, Source Atlas UI, and PFC external-surface UI work inherits FET gates immediately, even before the train completes.

## Train

| Batch | Title | Type | Purpose | Stop rule |
| --- | --- | --- | --- | --- |
| FET01 | Frontend Operating System Source Truth | docs/governance | Reconcile FET with AFI/FCP/FVQ/SI/PD/PFC/AOS/LDI source truth and explain the difference between feature completion and frontend composition completion. | Stop on source-truth conflict affecting active IA, route compatibility, or release claims. |
| FET02 | Screenshot Evidence Pipeline | docs/tooling | Define screenshot location, naming, baseline/after packets, dark mode, Dynamic Type, Reduce Motion, what counts as visual proof, and what does not. | Stop if the standard implies human/device/release proof. |
| FET03 | First Viewport Budget Gate | docs/tooling | Formalize one-primary-object, support-object, chip, copy-line, floating-control, bottom-nav, nested-content, and architecture-copy budgets. | Stop if budget weakens current FET Red conditions. |
| FET04 | Shell / Bottom Chrome Ownership Gate | docs/tooling | Lock native tab bar, custom rail, FAB, toolbar, receipt overlay, header, and bottom safe-area ownership rules. | Stop on route/raw-value or shell behavior implementation without approval. |
| FET05 | Top-Level Surface Composition Gate | docs/governance | Define the one-thesis composition gate for Today, Goals, Capture, Time, and You. | Stop if it changes active top-level IA. |
| FET06 | Primitive Misuse And Density Gate | docs/tooling | Map signature objects to constrained anatomy and reject generic rounded-card, chip-grid, nested-panel, and unlimited-content drift. | Stop if it invents new product IA or weakens SI. |
| FET07 | Copy Compression And Product-Language Gate | docs/tooling | Lock root copy budgets, user-value language, internal-architecture suppression, and AI-theater bans. | Stop on product strategy rewrite or release overclaim. |
| FET08 | Accessibility / Dynamic Type / Reduce Motion Gate | docs/tooling | Require Dynamic Type, VoiceOver, touch target, contrast, non-color, Reduce Motion, and cognitive-load evidence beyond identifiers. | Stop if public accessibility approval is claimed. |
| FET09 | Motion / Haptics / Interaction Believability Gate | docs/governance | Require motion and haptics to orient, confirm, or reduce uncertainty with Reduce Motion equivalents. | Stop if it approves decorative/gimmicky motion or device proof without evidence. |
| FET10 | Visual QA Scorecard And Review Packet | docs/tooling | Harden the 1-100 scorecard, review packet, screenshot reviewer, and readiness gate. | Stop if scripts mutate source, require network, signing, hosted CI, or secrets. |
| FET11 | UI Regression Stop Protocol | docs/planning | Define when visual regressions stop continuation, enter repair loops, and block build-passed overrides. | Stop if it implements app UI or claims current UI is approved. |
| FET12 | Resume Global Train With Frontend Council Enforcement | docs/handoff | Close the train with inherited gate map, unresolved Yellow owners, rollback paths, and next eligible implementation prompt. | Stop on unclassified Red or unsafe dirty state. |

## Required Validation Baseline

```bash
git status --short
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
scripts/fet-readiness-gate.sh || true
scripts/fet-first-viewport-budget-scan.sh || true
scripts/fet-bottom-chrome-conflict-scan.sh || true
scripts/fet-primitive-density-scan.sh || true
scripts/fet-copy-density-scan.sh || true
scripts/fet-visual-qa-packet-check.sh || true
```

## Non-Claims

This train does not implement or fix current app UI by itself. It does not approve current visual quality, accessibility, device behavior, App Store screenshots, TestFlight, release readiness, legal/privacy readiness, or human visual approval.

## Completion Note

FET01-FET12 may be marked complete only when the per-batch reports and final train report exist, the FET scripts validate as present/executable, global gate docs inherit FET, and no unsupported UI repair or release/readiness claim is introduced.

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
