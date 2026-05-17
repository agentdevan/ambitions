# Ambitions Batch Closeout Contract

Status: ACTIVE

## Purpose

No batch may close operationally until governance state is updated.

## Required Closeout Actions

Every completed batch must:

- update governance reconciliation outputs
- update manifests if ownership/state changed
- regenerate registry projections
- rerun stale overlay scans
- rerun orphan prompt scans
- classify archive candidates
- identify superseded operational truth
- update next eligible execution state

## Required Commands

```bash
python3 scripts/governance/ambitions-governance-reconcile.py --write
python3 scripts/governance/ambitions-governance-validate.py
```

## Forbidden

- closing batches without governance updates
- adding prompts without ownership
- leaving stale queue declarations
- leaving superseded overlays active

## Goal

Governance state must evolve continuously with implementation.
