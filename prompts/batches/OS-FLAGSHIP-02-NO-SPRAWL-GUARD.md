<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# OS-FLAGSHIP-02-NO-SPRAWL-GUARD

## Purpose

Install and validate the no-sprawl guard for Ambitions Codex OS work.

## Required Reads

- `docs/truth/README.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/os/AMB-CODEX-OS-NO-SPRAWL-GUARD.md`
- `.codex/skills/ambitions/no-sprawl-guard.md`
- `.codex/skills/ambitions/source-truth-classifier.md`

## Scope

- Control-plane guardrails, prompt hygiene, and duplicate-authority checks only.
- No app behavior, product IA, backend dependency, analytics, server, signing, or release-posture changes.

## Done

- Candidate duplicate roots, orphan prompts, stale docs, and unregistered control-plane artifacts are listed with owner paths.
- Any repair is additive, deterministic, and path-limited.
- Validation and rollback notes are recorded.
