# Batch 38 — Post-2.0 Hardening 04 / Repo Truth, Regression, Performance, and Release Readiness

## Status

Queued

## Goal

Close repo truth drift, regression gaps, preview/docs/copy truth issues, performance-risk review, and release-readiness debt as the consolidation pass for the post-2.0 whole-repo/app hardening wave.

This batch is the fourth and final planned step of the current hardening wave. It consolidates the product after shell truth, external truth, and secondary-surface productization have been stabilized. The separate UI/UX excellence wave should be planned after this hardening wave, not inside it.

## In Scope

- repo truth drift cleanup
- preview, docs, and copy truth alignment
- regression-gap review and hardening
- performance-risk review
- release-readiness debt reduction
- hardening-wave consolidation across the repo and app

## Out Of Scope

- net-new product or intelligence features
- broad visual redesign
- speculative future-wave planning beyond this hardening sequence
- creation of Batch 39 or later in this pass

## Dependency Rules

- do not start this batch until Batches 35 through 37 are stable
- use this batch as the consolidation and release-readiness pass rather than an overflow bucket
- keep the later UI/UX excellence wave out of this batch

## Exit Criteria

- repo truth drift is materially reduced
- preview/docs/copy truth is aligned with shipped behavior
- regression and performance risks are reviewed and bounded
- release-readiness debt is reduced to a truthful, operationally clear state
- the repo is ready for a separate UI/UX excellence planning wave after hardening

## Validation

- docs/control-file truth checks for touched planning files
- targeted regression/performance/release-readiness verification appropriate to the eventual implementation scope
- do not mark this batch completed until the hardening-wave consolidation state is validated truthfully

## Completion Rule

Batch 38 is complete only when the current hardening wave has been consolidated truthfully enough that a separate UI/UX excellence wave can begin without reopening shell, trust, or repo-truth fundamentals.
