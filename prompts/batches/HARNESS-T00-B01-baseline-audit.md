<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HARNESS-T00-B01 — Baseline Audit

Status: Slice 1 prompt.
Scope: docs/scripts/prompts only.

## Goal

Record current repo state before further Harness work.

## Boundaries

- No app source changes.
- No `docs/truth/*` changes.
- Use the Ambitions runner.

## Required work

1. Read active truth files and `AGENTS.md`.
2. Record branch, SHA, and dirty tree.
3. Check whether Slice 1 support docs, scripts, and prompts exist.
4. Report Green / Yellow / Red.

## Final report

Include status, scope, files changed, evidence, validation, risks, non-claims, and next recommended step.
