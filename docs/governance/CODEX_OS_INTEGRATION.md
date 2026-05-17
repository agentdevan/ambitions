# Codex OS Integration

Status: ACTIVE
Owner: Governance OS
Authority Tier: active
Supersedes: none
Superseded By: none
Proof Expectation: docs-only
Cleanup Destination: none
Expected Lifetime: permanent

## Purpose

This document explains how the local Codex OS control plane fits into Ambitions governance.

It is an operator guide, not source truth. Active truth still lives in `docs/truth/*`.

## Canonical Flow After New Direction

Run these commands in order after ChatGPT installs or updates canon:

```bash
python3 scripts/governance/ambitions-canon-installer.py
python3 scripts/governance/ambitions-repo-doctor.py
python3 scripts/codex-os/ambitions-codex-os-sync-governance.py
```

## Canonical Codex Entry Point

Tell Codex to run:

```bash
python3 scripts/codex-os/ambitions-codex-os-next-action.py
```

Then follow the emitted command exactly.

## Generated Files To Inspect

- `docs/governance/GOVERNANCE_DASHBOARD.md`
- `docs/governance/generated/repo_doctor_summary.md`
- `build/codex-os/ambitions-context-pack.md`
- `build/codex-os/next-action.md`
- `build/codex-os/batch-selection.md`
- `build/codex-os/repair-plan.md`
- `build/codex-os/performance-check.md`
- `build/codex-os/sync-report.md`
- `build/codex-os/active-authority-map.json`

## What Failures Mean

- Missing generated outputs mean the repo needs regeneration before batch selection.
- Repo doctor Red means governance repair comes first.
- Canon changes mean propagation outputs are stale until the canon installer and downstream sync rerun.
- Orphan prompts, stale overlays, and unresolved governance counts block feature expansion.
- Batch selection should never outrun the live queue or current batch state.

## When Feature Work Is Blocked

Feature work is blocked when:

- repo doctor strict fails
- generated outputs are stale or missing
- canon changes have not been propagated
- a governance Red remains unresolved
- the next action resolves to repair instead of batch execution

## Operator Rule

Use the generated outputs to decide the next safest command. Do not infer readiness from batch prose alone.
