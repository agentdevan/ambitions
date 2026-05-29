<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HARNESS-T00-B01 — Baseline Audit

## Batch type
Harness Slice 1 baseline audit.

## Objective
Record current repo state before further Harness work.

## Why this exists
This batch establishes a current-state checkpoint for the Harness Slice 1 support layer so later work can compare changes against live repo truth instead of stale assumptions.

## Dependencies
- Active repo truth files.
- `AGENTS.md`.
- Existing Slice 1 support docs, scripts, and prompts.

## Active source truth
- `docs/truth/*` is the active authority layer.
- Live repo source, scripts, tests, command output, and current proof artifacts win over stale prompts, old reports, and historical docs.
- This prompt is operational support only. It is not implementation proof, validation proof, release proof, accessibility proof, privacy proof, or performance proof.

## Truth files to read
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Exact source areas to inspect
- `docs/codex/HARNESS_README.md`
- `docs/codex/HARNESS_PLAN.md`
- `docs/codex/HARNESS_ARTIFACT_SCHEMA.md`
- `docs/codex/HARNESS_LINEAR.md`
- `docs/codex/HARNESS_RUNS.md`
- `scripts/harness/install-harness-slice1.py`
- `scripts/harness/check-slice1.py`
- `scripts/ambitions-slice1-status.py`
- `scripts/ambitions-slice1-gates.py`
- `prompts/batches/HARNESS-T00-B01-baseline-audit.md`
- `prompts/batches/HARNESS-T01-B01-docs.md`

## Allowed scope
- Prompt-only repair in `prompts/batches/HARNESS-T00-B01-baseline-audit.md`.
- Read-only inspection of the exact source areas listed above.
- Running the docs/scripts prompt-slice validation commands listed below.

## Exact changes allowed
- Prompt-only repair in `prompts/batches/HARNESS-T00-B01-baseline-audit.md`.
- No app source changes.
- No `docs/truth/*` changes.
- No generated project, build, or app behavior changes.

## Forbidden scope
- App source, shared package source, project configuration, generated project files, truth files, repo-intelligence artifacts, and broad cleanup are out of scope.
- Do not stage or commit unrelated dirty worktree material.
- Do not claim app behavior, build/test, release, accessibility, privacy, performance, device, TestFlight, App Store, or CI proof from this prompt-only batch.

## Exact changes forbidden
- `Native/**`
- `Sources/**`
- `AppUI/**`
- `docs/truth/**`
- `project.yml`
- `Package.swift`
- Generated `.xcodeproj`
- Repo-intelligence artifacts
- Any broad cleanup outside this prompt file

## Hard Red
- Any app source, runtime dependency, `docs/truth/*`, project/package config, generated project, or broad cleanup change.
- No required cloud AI, hosted backend, analytics/tracking, signing, hosted CI, or release automation addition.
- Any false claim of app validation, release readiness, accessibility proof, privacy proof, performance proof, device proof, TestFlight proof, App Store proof, or CI proof.
- Any use of advisory repo-intelligence findings as proof without direct repo/log/script verification.

## Implementation steps
1. Read the active truth files and `AGENTS.md`.
2. Record branch, SHA, and dirty tree.
3. Check whether Slice 1 support docs, scripts, and prompts exist.
4. Report Green / Yellow / Red.

## Tests to add/update
- None. This is a baseline audit prompt repair only.

## Commands to run
- `git status --short --branch`
- `python3 scripts/harness/check-slice1.py`
- `python3 scripts/harness/install-harness-slice1.py --json`

## Proof artifacts
- Prompt text itself.
- Any command output used to confirm repo state and Slice 1 support availability.

## Accessibility requirements
- Not applicable. No UI or app source is being changed.

## Privacy/local-first requirements
- Preserve repo privacy/local-first posture by avoiding app-source or dependency changes.

## iOS 26 API verification requirements
- Not applicable. No iOS 26 API adoption or validation is part of this batch.

## Closeout rules
- State whether the run was Green, Yellow, or Red.
- Include status, scope, files changed, evidence, validation, risks, non-claims, and next recommended step.
- Do not claim app validation, release readiness, accessibility proof, privacy proof, or performance proof.

## Rollback strategy
- Revert only this prompt file if the scaffold needs to be removed or replaced.

## Final report format
```text
Status: Green / Yellow / Red
Batch ID:
Scope:
Branch:
Commit:
Files changed:
Truth files inspected:
Source areas inspected:
Commands run:
Commands not run:
Environment:
Evidence:
Passes:
Failures:
Skipped:
Unproven:
Accessibility status:
Privacy/local-first status:
Claims allowed:
Claims forbidden:
Release blockers:
Post-batch gates:
Rollback:
Next eligible batch:
```
