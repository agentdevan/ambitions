# Global Batch Automated Gate Protocol

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-15187566, AMB28-same_source_file_targeted_by_multiple_active_batches-21604483, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-42900710, AMB28-same_source_file_targeted_by_multiple_active_batches-46411209, AMB28-same_source_file_targeted_by_multiple_active_batches-46969109, AMB28-same_source_file_targeted_by_multiple_active_batches-62910670, AMB28-same_source_file_targeted_by_multiple_active_batches-63479679, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-73705370, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932 and 3 more

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

Status: Ambitions 4.0 global Codex OS control; no queued train started
Date: 2026-05-02

## Purpose

Every future global batch must produce explicit gate outputs before closeout and continuation. Automated gates are source-truth, scope, evidence, validation, and drift checks plus reviewer outputs. They do not replace human-only proof.

Before edits, every batch must perform a dry-run selection and declare whether
execution is allowed. The dry-run names the selected global batch, prompt path,
train, current status, approval coverage, allowed and forbidden files, required
gates, expected validation strength, human-proof risk, expected stop condition,
and `Execution allowed: YES` or `Execution allowed: NO`.

Before edits, every batch must also declare its execution budget: maximum file
count touched, intended new files, intended deleted files, diff size category,
whether app code is allowed, whether docs-only mode applies, whether tests may
be edited, whether screenshots/previews are required, and whether human proof
may be required.

## Gate Output Schema

Use this shape in batch reports:

```text
Gate:
Result: Green | Yellow | Red
Rationale:
Evidence:
Required repair if Red:
Deferral owner if Yellow:
Evidence required before continuation:
```

## Green Definition

Green means batch scope completed, required validation passed, no forbidden files touched, no unsupported claims introduced, no product regression introduced, no known critical accessibility regression, no compatibility break introduced, no unaccepted maintainability degradation, no unresolved Red, validation strength is Strong or Adequate for the batch type, evidence logged, registry/context/run-state updated when required, rollback path documented, and commit is safe.

## Yellow Definition

Yellow means a noncritical advisory exists, is classified, has an owner, and does not affect release claims, product identity, architecture, compatibility, accessibility, test strength, next-batch safety, or continuation truth. Yellow may continue only when the deferral owner and rationale are documented.

## Red Definition

Red means a correctness-affecting test failure, build failure caused by the batch, app behavior break, top-level composition violation, unsupported release/platform claim, false PXOS/AmbitionsOS implementation claim, compatibility break, route/raw/persistence break, accessibility blocker, product identity regression, generic product drift, maintainability regression, scope expansion, forbidden file touch, missing required evidence, skipped validation without allowed reason, Weak/Missing implementation validation, weakened canon/tests/gates, incorrect train status, or batch start without required approval.

## Required Evidence Per Gate

- Source Truth: docs read and conflict resolution.
- Scope Boundary: allowed/forbidden files, changed-file boundary check.
- Product Decision Lock: locked/open/deferred decisions.
- REC/Release: claim scans and human-proof boundaries.
- PXOS/Top-Level: surface owner, composition tests, visual/copy/accessibility criteria.
- ME: before/after file sizes, owner map, extraction plan, behavior tests.
- CS: replacement map, compatibility proof, rollback plan.
- AOS: typed contracts, privacy/fallback/source-truth/performance/evaluation evidence.
- SI: Signature Interface creative direction, invented-but-native rubric, anti-generic UI scan, top-level composition evidence when surfaces are touched, preview coverage, visual QA report, accessibility/Dynamic Type/VoiceOver notes, Reduce Motion evidence, symbol grammar, and file-size/component-boundary evidence.
- FET: FAANG Frontend Excellence classification for every UI-touching batch, first-viewport screenshot or preview evidence, one-primary-object proof, chip/body-copy budget, bottom chrome ownership, primitive identity, copy compression, accessibility evidence beyond identifiers, Reduce Motion/non-motion evidence, 1-100 frontend scorecard, and no unsupported premium/flagship/10/10 claim.
- Validation: commands, logs, PASS/PARTIAL/FAIL, proof scope, non-claims.
- Handoff/Rollback: report, next prompt, rollback steps.
- Batch report: batch-specific report under `docs/audits/`, unless the prompt
  defines a stricter alternate report path.
- Post-commit drift: current batch complete with evidence, next batch selected
  correctly, no later batch accidentally started, train status consistent,
  global order count stable, approval phrases unchanged, and unsupported
  release/PXOS/AOS/Product Depth claims absent.

## Batch-Type Gates

Docs-only batches must run Source Truth, Scope Boundary, Product Decision Lock, Product Drift, Validation Evidence, Validation Strength, Handoff, Rollback, and Continuation.

Implementation batches must also run file-size/diff-size, test strength, maintainability, accessibility/copy/visual if UI is touched, compatibility if seams are touched, privacy/trust if data or recommendations are touched, and release-claim scans if messaging is touched.

Frontend/UI-touching implementation batches must run the FET readiness gate and the Frontend Excellence gate pack in `FRONTEND_EXCELLENCE_GATE_MATRIX.md`. This includes future FCP, AFI, DAV, PD, SI, FVQ, AOS UI, LDI UI, Source Atlas UI, and PFC external-surface UI batches. Build, unit tests, UI smoke tests, or source-contract tests cannot close a UI-touching batch Green without fresh simulator screenshots or meaningful preview evidence for the touched visible surface.

Release/evidence batches must run REC Release Evidence, Release Claim Safety, Human Proof, Handoff, and Rollback gates.

Signature Interface implementation batches must run Signature Interface Creative Direction, Native iPhone Believability, Anti-Generic UI, Interaction/Motion/Haptics, Reduce Motion, Accessibility/Dynamic Type/VoiceOver, Preview Coverage, Visual QA, File-Size/Component Boundary, and Release-Claim Safety gates. If the batch touches Today, Goals, Capture, Plan, You, app shell, surface shell, navigation lists, or drill-down entry/exit, it must also run the Top-Level Surface Composition or IA/Shell/Navigation gate as relevant.

SI implementation Green requires build/focused test proof plus UI-quality evidence. Build passing alone is not enough. Each primitive must document the component state matrix, preview or screenshot evidence where tooling supports it, and an invented-but-native rubric scored 1-5 for originality, native iPhone believability, usefulness, restraint, accessibility, emotional tone, system coherence, and maintainability. Green requires average score >= 4, no category below 3, and no Red in accessibility, release-claim safety, route/compatibility, or file-size boundary.

## FAANG Frontend Excellence Gate

FET applies to visible UI, shell/chrome, navigation, visual primitives, motion, haptics, symbols, material, typography, color, preview fixtures, screenshot packets, accessibility presentation, external-surface UI, and user-facing copy.

Hard frontend Red conditions:

- UI batch has no simulator screenshots or preview evidence.
- Build passes but no visual evidence exists.
- First viewport has more than one primary object.
- First viewport has more than two support objects.
- Native tab bar, custom tab rail, floating global action, or toolbar affordances compete visually.
- Hero/primary surface contains unlimited nested content or generic panel stacking.
- More than four chips appear above the fold.
- More than twelve body-copy lines appear above the fold.
- Product explains internal architecture instead of user value.
- Motion is decorative, unexplained, or lacks Reduce Motion equivalent.
- Accessibility identifiers exist but Dynamic Type, VoiceOver, touch target, contrast, or reduced cognitive load evidence is missing.
- The batch claims premium, flagship, Apple-level, FAANG-level, or 10/10 without screenshot evidence and rubric scoring.
- Top-level Today / Goals / Capture / Time / You surfaces look visually interchangeable.
- A primitive intended as a signature object becomes a generic rounded card.
- Build/test success is used as substitute for visual proof.

FET01-FET12 adds the concrete operating gates for screenshot packet structure, first-viewport budget, shell/bottom chrome ownership, top-level surface composition, primitive density roles, copy compression, accessibility/Dynamic Type/Reduce Motion evidence, motion/haptics believability, visual QA scorecards, and UI regression stops. Future UI-touching batches must cite the relevant FET gate docs in their dry-run and report.

Frontend scorecard categories are first-glance clarity, native iPhone believability, visual hierarchy, surface originality, restraint, emotional tone, accessibility resilience, motion/interaction believability, product-language quality, system coherence, maintainability, and screenshot evidence quality. Score each 1-100. Green requires average >= 90, no category below 85, and no Red in accessibility, screenshot evidence, bottom chrome ownership, first viewport composition, route compatibility, or release-claim safety. Yellow is average 80-89 with no hard Red and a named owner. Red is average below 80, any hard Red, missing screenshots for UI-touching work, or build/test success used as substitute for visual proof.

## Failure Handling

- Green: proceed to closeout and commit.
- Yellow: run Yellow advisory loop before closeout.
- Red: run Red repair loop before any commit or continuation.

## Automated Scans Baseline

Future batches should select from this baseline:

```bash
git status --short
git diff --check
git diff --name-only
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

Add batch-specific scans for claims, product drift, top-level composition, file sizes, compatibility, tests, and validation logs. Advisory commands must be classified, not ignored.

Signature Interface batches should add the local SI advisory scans created for the train:

```bash
scripts/si-component-inventory.sh || true
scripts/si-anti-generic-ui-scan.sh || true
scripts/si-top-level-composition-scan.sh || true
scripts/si-preview-coverage-scan.sh || true
scripts/si-accessibility-scan.sh || true
scripts/si-motion-reduce-motion-scan.sh || true
scripts/si-file-size-scan.sh || true
scripts/si-symbol-grammar-scan.sh || true
scripts/si-visual-qa-report.sh || true
scripts/si-readiness-gate.sh || true
```

These scripts are advisory and read-only. They do not fake screenshot proof, human visual approval, physical-device proof, public accessibility conformance, App Store/TestFlight proof, or release readiness.

Frontend/UI-touching batches should add the local FET advisory scans:

```bash
scripts/fet-readiness-gate.sh || true
scripts/fet-first-viewport-budget-scan.sh || true
scripts/fet-bottom-chrome-conflict-scan.sh || true
scripts/fet-primitive-density-scan.sh || true
scripts/fet-copy-density-scan.sh || true
scripts/fet-visual-qa-packet-check.sh || true
```

These scripts are advisory and read-only at FET00. Advisory findings become hard Red when they map to the FET hard frontend Red conditions and the batch touches visible UI.

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
