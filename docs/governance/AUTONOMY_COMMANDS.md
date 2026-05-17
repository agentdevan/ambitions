# Autonomy Commands

Status: ACTIVE
Owner: Governance OS
Authority Tier: active
Supersedes: none
Superseded By: none
Proof Expectation: docs-only
Cleanup Destination: none
Expected Lifetime: permanent

## New Direction

When ChatGPT installs or updates canon:

```bash
python3 scripts/governance/ambitions-canon-installer.py
python3 scripts/governance/ambitions-repo-doctor.py
python3 scripts/codex-os/ambitions-codex-os-sync-governance.py
```

## Ask Codex For The Next Step

```bash
python3 scripts/codex-os/ambitions-codex-os-next-action.py
```

## If Codex Chooses A Batch

Run the batch through the authorized wrapper:

```bash
make authorized-batch BATCH=<BATCH_ID> PROMPT=<PROMPT_FILE>
```

## Local Control Plane Commands

- `make repo-doctor`
- `make repo-doctor-strict`
- `make canon-install`
- `make codex-os-context`
- `make codex-os-next`
- `make codex-os-sync`
- `make codex-os-performance`
- `make codex-os-repair-route`
- `make codex-os-batch-select`
- `make autonomy-loop`

## Failure Interpretation

- `repo-doctor` outputs `YELLOW` when work remains but no strict failure is required.
- `repo-doctor --strict` exits non-zero when unresolved governance remains.
- `next-action` returning a repair command means feature work is blocked.
- `batch-selection` returning no batch means the queue is idle or blocked.

## What To Inspect First

1. `docs/governance/GOVERNANCE_DASHBOARD.md`
2. `docs/governance/generated/repo_doctor_summary.md`
3. `build/codex-os/next-action.md`
4. `build/codex-os/batch-selection.md`
5. `build/codex-os/sync-report.md`

## Operator Boundary

Do not treat these commands as product behavior. They are the repo operating loop.
