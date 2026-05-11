<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Ambitions Remaining Batch Execution Standard

This template is supporting prompt-system infrastructure. It does not implement
app behavior and does not override `docs/truth/*`, `AGENTS.md`, the canonical
queue, or the Ambitions runner.

Every remaining executable batch prompt must preserve:

- runner-only execution through `scripts/ambitions-codex-train.sh`
- canonical queue order and IDs
- active top-level IA: `Today / Goals / Capture / Time / You`
- Plan as an internal compatibility seam only where active truth allows it
- local-first and on-device-first posture unless active truth explicitly says
  otherwise
- EFC applicability notes for unfinished user-facing, data, intelligence,
  source/freshness, side-effect, accessibility, performance, release, or public
  claim work
- exact allowed and forbidden scopes
- focused validation, proof boundaries, rollback, final report, and next handoff
- no release, TestFlight, App Store, device, public accessibility, performance,
  privacy/legal, hosted CI, production-readiness, or global-completion claim
  without current evidence

Prompts generated from this standard are implementation-ready only when their
own dependency gate and active source-truth checks pass inside the runner.
