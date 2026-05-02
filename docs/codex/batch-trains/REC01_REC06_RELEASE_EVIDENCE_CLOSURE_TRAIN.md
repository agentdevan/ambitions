# REC01-REC06 Release Evidence Closure Train
<!-- markdownlint-disable MD013 -->

Status: Active Ambitions 4.0 train manifest; REC01-REC05 complete, REC06 selected for closure on 2026-05-02.

## Start Rule

This train starts only after a repo-wide hardening/status-truth pass is PASS or PASS WITH YELLOW and no unresolved Red exists. Required user approval phrase after REC01: `Continue Release Evidence Closure` or current global Ambitions 4.0 preauthorization.

## What Does Not Start This Train

F30 completion, AmbitionsOS future canon, AOS/ME/CS planning, or simulator proof alone does not start this train. This manifest starts only because the pre-train hardening prompt selected Release Evidence Closure as the first safe post-3.0 train.

## Purpose

Convert Ambitions 3.0 simulator and documentation evidence into an honest release-evidence package without claiming release readiness. This train is evidence/status/release-truth focused and does not implement app features.

## Historical Truth To Preserve

Ambitions 3.0 is complete by F30 closeout evidence. F17-F30 remains historically complete. AmbitionsOS remains future canon, not current app behavior. AOS, ME, CS, Product Depth, and PXOS are queued/blocked Ambitions 4.0 trains and not started.

## Batch Order

- REC01: Release Evidence Truth Inventory. Status: Complete / accepted baseline. Scope: inventory current evidence, claim boundaries, gaps, and advisory state. No app code.
- REC02: Human Operator Release Proof Plan. Status: Complete. Scope: physical device, accessibility, App Store Connect, signed archive, and external-platform proof plan.
- REC03: Validation Log Ledger Closure. Status: Complete. Scope: preserve and index validation logs and unsupported proof gaps.
- REC04: Release Claim Copy Guard. Status: Complete. Scope: ensure active docs and handoff copy avoid readiness claims not backed by evidence.
- REC05: Human Review Packet. Status: Complete. Scope: operator-facing release review packet.
- REC06: Release Evidence Closure Handoff. Status: Selected / closing. Scope: closeout report and next decision.

## Gates

- Green: batch report exists, evidence inventory is source-bound, no app code changed, claim gaps remain explicit, registry/context/run-state are updated, and validation commands pass or advisory failures are classified.
- Yellow: doc QA/tooling advisories remain but are classified and do not affect claim truth.
- Red: readiness claim introduced, app behavior changed, forbidden file touched, unclassified validation failure, historical F17-F30 truth altered, or AmbitionsOS treated as implemented.

## Validation Requirements

Docs-only REC batches require `git status --short`, `git diff --check`, doc QA advisory, batch-train gate advisory, release-claim scan, and changed-file boundary check. App build/test is advisory and should be skipped unless app code changes, which REC should not do.

## Stop / Continuation

REC batches continue only after the prior batch is Green or accepted Yellow, committed, pushed, and the required REC phrase or current global Ambitions 4.0 preauthorization is present. Global continuation still stops for unresolved Red, weak validation, human-only proof, release/platform proof, forbidden files, or unsafe source-truth drift.

## Release Claim Boundary

This train may document proof gaps and operator steps. It must not claim App Store readiness, TestFlight readiness, final RC lock, physical-device verification, public accessibility conformance, signed archive validation, App Store Connect validation, rendered external-platform proof, or production platform readiness unless later evidence exists.
