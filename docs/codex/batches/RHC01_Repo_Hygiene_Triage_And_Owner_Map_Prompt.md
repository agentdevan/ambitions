# RHC01 Repo Hygiene Triage And Owner Map Prompt
<!-- markdownlint-disable MD013 -->

## Batch Identity

- Batch ID: RHC01
- Title: Repo Hygiene Triage And Owner Map
- Train: RHC01-RHC06 Repo Hygiene Closeout Train
- Default global placement: after LDI05-LDI22, AOS24-AOS30, FCP27-FCP30, and PFC31-PFC40 unless a Hard Red proves cleanup is blocking the active batch
- Type: docs/audit/governance

## Status

Queued. Do not run while an unfinished LDI, AOS, FCP, or PFC batch is next eligible.

## Purpose

Reconcile known repo hygiene debt from PFC01-PFC03 into a current owner map without interrupting the active global full-stack train.

## Source Truth Files To Read First

- README.md
- AGENTS.md
- .codex/reports/current-run-state.md
- .codex/reports/current-batch-train-state.md
- docs/codex/RESUME_GLOBAL_BATCH_TRAIN.md
- docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md
- docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md
- docs/audits/pfc01-repo-build-system-inventory-report.md
- docs/audits/pfc02-architecture-boundary-module-map-report.md
- docs/audits/pfc03-dead-code-prompt-artifact-naming-smell-audit-report.md
- docs/codex/BATCH_REGISTRY.md
- docs/codex/CONTEXT_INDEX.md

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `scripts/global-train-next-batch.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Allowed Files

- docs/audits/**
- docs/codex/**
- .codex/reports/** only for state pointers that preserve the active batch selection
- scripts/** only for non-mutating queue discovery or advisory status output

## Forbidden Files

- Native/Ambitions/**
- Native/AmbitionsTests/**
- Sources/**
- AppUI/Sources/**
- project.yml
- Package.swift
- signing, entitlements, workflows, generated project files, build artifacts, or release files

## Required Work

1. Confirm the active next eligible batch from repo evidence.
2. Refuse to supersede an unfinished LDI/AOS/FCP/PFC batch.
3. Re-scan the PFC01-PFC03 cleanup findings against current source.
4. Produce an owner map for large files, placeholder/stub seams, compatibility vocabulary, stale copy, generated/local artifacts, and validation-script advisory noise.
5. Decide whether RHC02-RHC06 should run, shrink, split, or safely no-op.

## Green Criteria

RHC01 closes Green only when the owner map is concrete, no source files changed, no active batch pointer is interrupted, and every cleanup item has an owner, proof requirement, and stop condition.

## Yellow Criteria

A cleanup item cannot be confirmed without later owner tests, device proof, or human review, but is non-blocking and recorded with owner and recheck condition.

## Red Criteria

The batch moves the active train pointer away from an unfinished LDI/AOS/FCP/PFC batch, deletes/renames source without proof, weakens validators, or claims cleanup completion without evidence.

## Required Evidence Outputs

- `docs/audits/rhc01-repo-hygiene-triage-owner-map-report.md`
- Registry/context/run-state note only if safe and non-interrupting

## Commit Message Recommendation

`Run RHC01 Repo Hygiene Triage And Owner Map`

## Next Safe Prompt / Next Gate

After Green or accepted Yellow, ask global train for the next eligible batch. Expected next RHC gate when safe: RHC02.
