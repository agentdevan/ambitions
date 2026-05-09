# Global Batch Automated Gate Protocol

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
