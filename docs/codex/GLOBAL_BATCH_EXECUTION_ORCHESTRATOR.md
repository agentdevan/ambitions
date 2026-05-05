# Global Batch Execution Orchestrator

<!-- markdownlint-disable MD013 -->

Status: Ambitions 4.0 execution-program orchestrator; optimized implementation order overlay active; no queued train started by this document
Date: 2026-05-05

## Purpose

This orchestrator tells future Codex sessions how to select, execute, validate, repair, commit, and continue globally ordered batches without weakening Ambitions product quality or truth.

This document does not start REC, PXOS, ME, CS, SI, Product Depth, FCP, AOS, LDI, release, or any implementation train.

Ambitions 4.0 is the active post-3.0 execution program, not a shipped product version. Queued 4.0 batches are not implemented and not release-proven until a batch runs, validates, commits, and records evidence.

## Global Order Source

Use this order for remaining work:

1. `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md` — active overlay for remaining batch selection by best implementation dependency order.
2. `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md` — historical global order, completed-batch evidence, and stable batch identity map.
3. Train manifests under `docs/codex/batch-trains/` — batch-local dependencies, boundaries, and gates.
4. Batch prompts under `docs/codex/batches/` — exact selected-batch instructions.

When the optimized order and historical order conflict for remaining queued work, select from the optimized order. When dependencies or gates conflict, use the stricter dependency, stricter gate, or safer order. Stop and write a reconciliation report if the conflict affects safety.

## Approval Phrases

Do not treat vague language as execution approval.

- `Run Next Global Batch`: run only the next eligible globally ordered batch.
- `Run Global Batch Sequence Until Blocked`: run global batches in optimized order until a Red, human-proof requirement, explicit approval gate, weak validation condition, unsafe condition, or user stop blocks continuation.
- `Continue Release Evidence Closure`: continue REC only.
- `Start PXOS Future-Canon Train`: start PXOS future-canon train only.
- `Start ME Train`: start ME only.
- `Start CS Train`: start CS only.
- `Start Signature Interface Train`: start SI only.
- `Start Product Depth Train`: start Product Depth only.
- `Start Flagship Completion Train`: start FCP only.
- `Start AOS Train`: start AOS only.

This global sequencing prompt is not an approval phrase to execute a future batch.

When a current user prompt says the exact phrase `Run Global Batch Sequence Until Blocked` and explicitly preauthorizes cross-train Ambitions 4.0 execution, that approval satisfies routine train transition approval for the next eligible batch in `GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`. This preauthorization is only permission to attempt the next eligible batch. It does not satisfy proof, validation, release, platform, visual-approval, privacy/legal, App Store Connect, TestFlight, signed archive, physical-device, public accessibility, or final release decision requirements.

## Execution Loop

1. Confirm branch is `main` unless the user explicitly requested otherwise.
2. Run `git status --short`, current branch, HEAD, and latest commit.
3. Select the next eligible batch from `GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`.
4. Cross-check the selected batch against `GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`, the dependency graph, train manifest, and batch prompt.
5. Read the batch prompt or, if the optimized order names a reconciliation/planning step, read the named reconciliation/planning prompt.
6. Read all source truth required by that batch.
7. Confirm the exact approval phrase exists for the batch/train/mode, or that the current prompt's global cross-train sequence preauthorization explicitly covers the selected train.
8. Confirm all prerequisite gates are Green or accepted Yellow.
9. Confirm no blocker exists.
10. Create a narrow implementation or docs plan with allowed/forbidden files.
11. Invoke required skills/review boards and record gate outputs.
12. Implement only the batch scope.
13. Run required validation and classify validation strength as Strong, Adequate, Weak, or Missing.
14. If Green, update evidence, registry/context/run-state as required, stage, commit, and continue only if continuation rules allow.
15. If Yellow, classify, fix now if it affects safety, or defer with an owner and continue only if safe.
16. If Red, stop forward progress and enter the Red repair loop.
17. Commit only after Green or accepted Yellow.
18. Continue to the next optimized batch only when the continuation protocol allows.

## Single-Batch Mode

Use single-batch mode when:

- Code implementation is involved.
- Human review or human proof is needed.
- Validation is expensive or uncertain.
- Release proof or claim boundaries are involved.
- Compatibility seams are touched.
- Top-level UI surfaces are touched.
- FCP flagship objects are touched.
- AOS runtime/intelligence is touched.
- LDI runtime/safety/source/continuity is touched.
- The task is risky or broad.

Run one batch, validate, repair if needed, commit, report, and stop.

## Continuous Mode

Continuous mode is allowed only when:

- The user says `Run Global Batch Sequence Until Blocked`.
- Batches are docs-only or low-risk.
- Each batch can be committed independently.
- No human proof is required.
- Validation strength is Strong or Adequate.
- No batch requires a separate approval phrase outside the current global cross-train preauthorization.
- Train control and optimized global order both allow continuation.

Continuous mode means implement, validate, repair, commit, then continue. It never means pushing through failures.

Continuous mode has no arbitrary batch-count cap. After compaction, resume, or long-run context refresh, reload the 4.0 execution source truth, the last completed batch report, the optimized order, and the next selected prompt before continuing.

## Gate Sequence

Run gates in this order unless the batch prompt adds stricter sequencing:

1. Source Truth Gate.
2. Optimized Order Selection Gate.
3. Scope Boundary Gate.
4. Product Decision Lock Gate.
5. Batch-type gates from the relevant gate matrix.
6. Product Drift Gate.
7. Validation Evidence Gate.
8. Validation Strength Gate.
9. Handoff Gate.
10. Rollback Gate.
11. Continuation Gate.

## Skills And Review Boards

Always invoke or map an equivalent protocol for:

- Source truth / canon review.
- Codex prompt quality review.
- Evidence / validation review.
- Release claim safety review.
- Product decision lock review.
- Scope boundary review.
- Optimized order / dependency review.

Use additional reviewers by batch type:

- PXOS/user-facing: PXOS surface hierarchy, product-depth/deep-not-wide, top-level composition, premium visual, product language, accessibility/cognitive-load, recovery, trust/proof.
- ME/code maintainability: maintainability, large-file extraction, testability, file-size/diff-size.
- CS/compatibility: compatibility migration, route/raw value/external surface, persistence/import/export if relevant.
- SI/signature UI: signature-interface creative director, Ambitions-native UI primitive, top-level surface composition, IA/shell/navigation, interaction/motion/haptics, accessibility adaptive interface, visual QA/preview fixture, iconography/symbol, loading/degraded state, file-size/component boundary, and release-claim safety.
- FCP/flagship completion: 10/10 object standard, anti-generic UI, receipt/proof/source, accessibility/reduced-motion, file-boundary, top-level object identity, and full-app audit.
- AOS/intelligence: runtime contract, privacy/trust, recommendation/source-truth, fallback/degraded-state.
- LDI/living dream: safety/legality/feasibility, source claim graph, pack integrity, mutation permissions, professional boundary, privacy/local-first, red-team evaluation.
- REC/release: release evidence, claim boundary, human proof.

If a required skill does not exist, map to an existing equivalent skill, define the review behavior in the batch report, or document the gap as Yellow only if safe.

## Validation Strength Rules

- Strong: focused tests/build/scans directly cover the changed behavior and batch risks.
- Adequate: docs/evidence scans cover the docs-only or audit-only batch risks.
- Weak: validation is indirect, partial, or missing a relevant risk area.
- Missing: required validation did not run and no acceptable substitute exists.

Implementation batches with Weak or Missing validation are Red unless a documented repo/tooling constraint and near-term validation owner make the risk nonblocking. Docs-only batches may pass with Adequate validation and advisory doc QA when findings are classified.

## Stop Conditions

Stop on:

- Unresolved Red.
- Human proof requirement.
- App Store Connect, signing, hardware, public accessibility, external rendered proof, or release decision requirement.
- Forbidden file touch.
- Weak/Missing implementation validation.
- Missing approval phrase or missing current global cross-train preauthorization.
- Unsafe dirty worktree.
- Source truth conflict affecting safety.
- Optimized order and train manifest conflict affecting safety.
- Product degradation proposed as a repair.
- Top-level surface composition violation.
- SI/FCP primitive generic/dashboard/card-stack drift.
- Missing Reduce Motion equivalent for motion work.
- Uncontrolled component/file-size regression.
- Unsupported release/platform/PXOS/AmbitionsOS/FCP/LDI implementation claim.
- LDI unsafe operationalization, professional-boundary breach, or user-data-server claim.

## Commit Rules

- Commit only after Green or accepted Yellow.
- Commit one batch at a time.
- Do not bundle unrelated repairs.
- Do not commit if `git diff --check` fails.
- Do not commit if changed files violate the allowed boundary.
- After commit, confirm branch cleanliness before any continuation.

## No-Degradation Rules

Codex must not resolve a failure by weakening product canon, UX, accessibility, architecture, maintainability, compatibility, privacy, release truth, or validation quality. Codex must not delete tests, loosen gates, hide failures in docs, or replace Ambitions-specific requirements with generic productivity language to make a batch pass.
