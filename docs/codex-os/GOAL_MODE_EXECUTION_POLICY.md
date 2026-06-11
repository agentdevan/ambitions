# Goal Mode Execution Policy

Status: Active Codex OS v2 policy
Scope: New Ambitions autonomous execution
Authority: Active Codex process authority, subordinate to `docs/truth/*`

## What It Is

Goal Mode is the default autonomous execution model for new Ambitions work. A Goal Mode run starts from a program GOAL file, refreshes the program run-state file, uses the program skill for reusable procedure, runs deterministic scripts for gates, records proof in the proof ledger, and closes Linear only after an honest push to `main` when Linear access exists.

## What It Is Not

Goal Mode is not a parallel Codex OS, product truth, implementation proof, release proof, owner approval, or a shortcut around source ownership, privacy, accessibility, validation, or no-claim gates.

## Policy

- New Ambitions autonomous work uses Goal Mode by default.
- Program GOAL files are the execution source.
- Program run-state files are compact memory.
- Program skills provide reusable instructions and scripts.
- Deterministic scripts provide validation helpers.
- Read-only reviewer agents provide independent review.
- Linear closeout follows successful pushes to `main`.
- The old Ambitions runner is legacy/supporting/historical unless an active issue explicitly requests it.
- New Goal Mode program work does not require runner headers.
- New Goal Mode program work does not route through `scripts/ambitions-codex-train.sh`.
- Do not delete runner files as part of Goal Mode transition.
- Goal Mode still obeys no false Green, no product Yellow, no Red source push, no release claims, no owner approval claims, and main-only execution unless explicitly changed by the user.

## Required Inputs

Truth files, `AGENTS.md`, the program registry entry, program GOAL file, program run-state file, relevant source/script evidence, current git branch/status/HEAD, and active Linear issue text when available.

## Outputs / Artifacts

Updated run-state, script logs under `artifacts/<program>/script-output/`, reviewer output under `artifacts/<program>/reviewer-output/`, proof ledger entries for claims, changelog/repair/decision updates, scoped commit, push hash, and Linear/manual closeout.

## Green / Yellow / Red

Green requires scoped work complete, no forbidden paths changed, required validation passed or truly not applicable, proof ledger updated for claims, run-state updated, and no readiness overclaim.

Yellow is allowed only for bounded tooling/access limits, unavailable Linear access, missing human/device/release proof, or pre-existing drift not caused by the patch. Yellow requires owner, safety reason, no-claim boundary, and retirement condition.

Red requires stop if app source changes unexpectedly, product truth conflicts, runner/Goal Mode authority conflicts remain in active docs, validation fails due to the patch, privacy/release/security risk appears, or a push would publish unresolved Red.

## Repair / Reframe

Reframe stale runner-only instructions as legacy/supporting for new Goal Mode work. Install or repair the missing adapter before implementation work. If app source or runtime behavior changes during governance work, stop and roll back that path or request a new source-scoped issue.

## Rollback / Failure

Rollback path-by-path. Do not use broad reset. Preserve failed logs unless they contain secrets. Do not delete historical runner material.

## Linear Closeout

After push, closeout must include issue list, pushed hash, changed files, validation commands and exits, proof paths, Green/Yellow/Red, non-claims, and next gate. If Linear access is unavailable, write paste-ready manual text into the program report.
