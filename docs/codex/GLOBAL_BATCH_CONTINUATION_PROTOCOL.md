# Global Batch Continuation Protocol

<!-- markdownlint-disable MD013 -->

Status: Global planning and Codex OS control; no future train started
Date: 2026-05-02

## Purpose

This protocol defines when Codex may continue from one globally ordered batch to the next.

## Continue Only When

- Current batch is Green or accepted Yellow.
- Current batch is committed.
- Registry/context/run-state/evidence are updated where required.
- Current branch is clean after commit.
- Next batch prerequisites are satisfied.
- Next batch source truth is available.
- Next batch does not require human proof.
- Next batch does not require a separate approval phrase that is missing.
- Train control allows continuation.
- Global order allows continuation.
- Batch scope remains manageable.
- Validation strength is Strong or Adequate for the current batch type.
- No Red is unresolved.
- No unsafe dirty worktree exists.

## Stop When

- Unresolved Red exists.
- Human proof is required.
- App Store Connect, device signing, hardware proof, external rendered proof, public accessibility proof, legal/privacy signoff, or production release decision is required.
- Batch would exceed safe scope.
- Next batch requires explicit user approval.
- Next batch changes train type from docs-only to code implementation and approval is not present.
- Context is too stale to continue safely.
- Current branch is dirty in an unsafe way.
- Validation is Weak or Missing for an implementation batch.
- Codex cannot prove product quality was preserved.
- Expected source truth is missing.
- Global order and train manifest disagree in a way that affects safety.
- The next batch would touch forbidden files without explicit approval.

## Single-Batch Mode

Run only the next global batch, then stop. This is the default for risky, code, release, compatibility, top-level UI, AOS runtime, or human-proof work.

## Continuous Mode

Run multiple global batches in order only when the user says `Run Global Batch Sequence Until Blocked` and every batch remains Green or accepted Yellow after validation, repair, commit, and branch-cleanliness checks.

Continuous mode never allows continuation through unresolved Red.

## Approval Phrase Handling

Global approval phrases do not replace train-specific phrases when a train requires one. If the next globally ordered batch is in REC, PXOS, ME, CS, or AOS and its train phrase is missing, stop and ask for the exact phrase.

## Commit-After-Each-Batch Rule

Every batch gets its own commit. Do not combine multiple global batches into one commit. Do not start the next batch with uncommitted changes from the current batch.

## Human-Proof Stop Rule

Codex must stop and produce an operator checklist for human-only proof. It may document the plan and evidence gaps, but it must not fake, simulate, or claim the proof.

## Context-Staleness Stop Rule

Stop when source truth, current branch state, validation status, or batch manifest status is stale or unclear. Refresh repo truth before continuing.

## Validation-Strength Stop Rule

Weak or Missing validation blocks implementation continuation. Docs-only work may continue with advisory validation only when the advisory is classified, noncritical, and does not hide Red.
