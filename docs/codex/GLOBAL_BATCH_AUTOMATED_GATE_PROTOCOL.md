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

Release/evidence batches must run REC Release Evidence, Release Claim Safety, Human Proof, Handoff, and Rollback gates.

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
