# Frontend Regression Pack

Use this pack before broad UI reruns for post-hardening transformation batches.

The goal is to prove the recurring shell and flagship-surface seams without paying for the full UI suite on every batch.

## Core Pack

Run the narrowest affected slice first.

### Shell / Command Core

- shell command entry opens
- shell command can route to Plan
- shell-owned create-goal entry works
- shell quick-capture entry works when relevant

### Today Guard Pack

- Today surface loads with dominant hero / primary action
- quick recovery returns to Today with explicit reentry
- quick focus returns to Today with explicit reentry
- Today -> Goal Detail handoff works
- Today -> Plan handoff works

### Goals Guard Pack

- Goals board loads
- Goals hero primary action works
- Goals card-to-detail routing works
- create-goal remains non-regressive from Goals

## Batch-Specific Additions

Add only the surface proofs directly needed by the active batch.
Examples:

- Batch 46: goal intake open, clarification step, strategy composer entry, feasibility/pacing explanation, capture-to-goal promotion
- Batch 47: Goal Detail first-screen load, path filmstrip continuity, return routing
- Batch 49: Plan load, pressure scrubber, week handoff, capture/habit continuity

## Run Order

1. affected slice of the fixed pack
2. new batch-specific UI proofs
3. broader UI reruns only if the affected slice shows instability or the validation matrix requires it

## Flake Discipline

If one fixed-pack test flakes in combined execution:

- rerun it in isolation
- compare against `known-flakes.md`
- do not rerun the full pack repeatedly without a new hypothesis

## Manual Signoff Relationship

The regression pack proves route/function continuity.
It does not replace manual signoff for:

- scanability
- hierarchy
- motion quality
- reduced motion
- practical accessibility/readability
