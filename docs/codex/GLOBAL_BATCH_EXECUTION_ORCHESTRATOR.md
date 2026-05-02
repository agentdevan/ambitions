# Global Batch Execution Orchestrator

<!-- markdownlint-disable MD013 -->

Status: Ambitions 4.0 execution-program orchestrator; no queued train started
Date: 2026-05-02

## Purpose

This orchestrator tells future Codex sessions how to select, execute, validate, repair, commit, and continue globally ordered batches without weakening Ambitions product quality or truth.

This document does not start REC02, PXOS, ME, CS, AOS, Product Depth, or any implementation train.

Ambitions 4.0 is the active post-3.0 execution program, not a shipped product version. Queued 4.0 batches are not implemented and not release-proven until a batch runs, validates, commits, and records evidence.

## Approval Phrases

Do not treat vague language as execution approval.

- `Run Next Global Batch`: run only the next eligible globally ordered batch.
- `Run Global Batch Sequence Until Blocked`: run global batches in order until a Red, human-proof requirement, explicit approval gate, weak validation condition, unsafe condition, or user stop blocks continuation.
- `Continue Release Evidence Closure`: continue REC only.
- `Start PXOS Future-Canon Train`: start PXOS future-canon train only.
- `Start ME Train`: start ME only.
- `Start CS Train`: start CS only.
- `Start Product Depth Train`: start Product Depth only.
- `Start AOS Train`: start AOS only.

This global sequencing prompt is not an approval phrase to execute a future batch.

When a current user prompt says the exact phrase
`Run Global Batch Sequence Until Blocked` and explicitly preauthorizes the
Ambitions 4.0 Execution Program, that approval satisfies routine train
transition approval for REC02-REC06, PX01-PX20, ME01-ME12, CS01-CS10,
PD01-PD18, and AOS01-AOS30 in global order. This preauthorization is only
permission to attempt the next eligible batch. It does not satisfy proof,
validation, release, platform, visual-approval, privacy/legal, App Store
Connect, TestFlight, signed archive, physical-device, public accessibility, or
final release decision requirements.

## Execution Loop

1. Confirm branch is `main` unless the user explicitly requested otherwise.
2. Run `git status --short`, current branch, HEAD, and latest commit.
3. Select the next eligible batch from `GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`.
4. Read the batch prompt or, if a REC02-REC06 prompt file does not exist, the REC train manifest entry.
5. Read all source truth required by that batch.
6. Confirm the exact approval phrase exists for the batch/train/mode, or that
   the current prompt's global 4.0 sequence preauthorization explicitly covers
   the selected train.
7. Confirm all prerequisite gates are Green or accepted Yellow.
8. Confirm no blocker exists.
9. Create a narrow implementation or docs plan with allowed/forbidden files.
10. Invoke required skills/review boards and record gate outputs.
11. Implement only the batch scope.
12. Run required validation and classify validation strength as Strong, Adequate, Weak, or Missing.
13. If Green, update evidence, registry/context/run-state as required, stage, commit, and continue only if continuation rules allow.
14. If Yellow, classify, fix now if it affects safety, or defer with an owner and continue only if safe.
15. If Red, stop forward progress and enter the Red repair loop.
16. Commit only after Green or accepted Yellow.
17. Continue to the next globally ordered batch only when the continuation protocol allows.

## Single-Batch Mode

Use single-batch mode when:

- Code implementation is involved.
- Human review or human proof is needed.
- Validation is expensive or uncertain.
- Release proof or claim boundaries are involved.
- Compatibility seams are touched.
- Top-level UI surfaces are touched.
- AOS runtime/intelligence is touched.
- The task is risky or broad.

Run one batch, validate, repair if needed, commit, report, and stop.

## Continuous Mode

Continuous mode is allowed only when:

- The user says `Run Global Batch Sequence Until Blocked`.
- Batches are docs-only or low-risk.
- Each batch can be committed independently.
- No human proof is required.
- Validation strength is Strong or Adequate.
- No batch requires a separate approval phrase outside the current global 4.0
  preauthorization.
- Train control and global order both allow continuation.

Continuous mode means implement, validate, repair, commit, then continue. It never means pushing through failures.

Continuous mode has no arbitrary batch-count cap. After compaction, resume, or
long-run context refresh, reload the 4.0 execution source truth, the last
completed batch report, and the next selected prompt before continuing.

## Gate Sequence

Run gates in this order unless the batch prompt adds stricter sequencing:

1. Source Truth Gate.
2. Scope Boundary Gate.
3. Product Decision Lock Gate.
4. Batch-type gates from `GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`.
5. Product Drift Gate.
6. Validation Evidence Gate.
7. Validation Strength Gate.
8. Handoff Gate.
9. Rollback Gate.
10. Continuation Gate.

## Skills And Review Boards

Always invoke or map an equivalent protocol for:

- Source truth / canon review.
- Codex prompt quality review.
- Evidence / validation review.
- Release claim safety review.
- Product decision lock review.
- Scope boundary review.

Use additional reviewers by batch type:

- PXOS/user-facing: PXOS surface hierarchy, product-depth/deep-not-wide, top-level composition, premium visual, product language, accessibility/cognitive-load, recovery, trust/proof.
- ME/code maintainability: maintainability, large-file extraction, testability, file-size/diff-size.
- CS/compatibility: compatibility migration, route/raw value/external surface, persistence/import/export if relevant.
- AOS/intelligence: runtime contract, privacy/trust, recommendation/source-truth, fallback/degraded-state.
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
- Missing approval phrase or missing current global 4.0 preauthorization.
- Unsafe dirty worktree.
- Source truth conflict affecting safety.
- Global order and train manifest conflict affecting safety.
- Product degradation proposed as a repair.
- Top-level surface composition violation.
- Unsupported release/platform/PXOS/AmbitionsOS implementation claim.

## Commit Rules

- Commit only after Green or accepted Yellow.
- Commit one batch at a time.
- Do not bundle unrelated repairs.
- Do not commit if `git diff --check` fails.
- Do not commit if changed files violate the allowed boundary.
- After commit, confirm branch cleanliness before any continuation.

## No-Degradation Rules

Codex must not resolve a failure by weakening product canon, UX, accessibility, architecture, maintainability, compatibility, privacy, release truth, or validation quality. Codex must not delete tests, loosen gates, hide failures in docs, or replace Ambitions-specific requirements with generic productivity language to make a batch pass.
