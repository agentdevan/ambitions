# Encyclopedia to Frontend Operating System

Status: Active frontend control-plane guide
Authority: subordinate to `docs/truth/*`

This document turns the visual encyclopedia into the operating loop for frontend implementation work.

## Operating Rule

The encyclopedia is the source of frontend intent.
Implementation starts from a surface ID, not from ad hoc repo browsing.

## Required Loop

1. Pick a surface ID from `MATURE_APP_SURFACE_UNIVERSE.yaml`.
2. Generate the surface packet.
3. Run frontend preflight.
4. Generate the implementation prompt.
5. Implement only within the declared source scope.
6. Produce proof and a receipt when code changes land.
7. Run drift check, source bindings, dashboard, and next-surface queue.

## What Each Artifact Means

- Surface packets are generated contracts for a single surface.
- Preflight proves the surface is eligible to work on.
- Implementation prompts are runner-compatible task contracts.
- Source bindings connect encyclopedia intent to live source candidates.
- Receipts record what changed and what proof was collected.
- Proof contracts define the evidence needed for each tier.
- Drift checks catch new mismatch between active truth and generated control-plane artifacts.
- Dashboards summarize current implementation status without claiming shipped UI.
- Next-surface queues rank work by readiness and dependency.

## Hard Rules

- Do not treat generated packets as source truth.
- Do not treat receipts as proof unless they describe current evidence.
- Do not claim implementation, accessibility, device, or release readiness without current proof.
- Do not reintroduce Plan as an active top-level destination.
- Do not let chatbot, dashboard, or generic task-list patterns replace the object-first frontend model.
