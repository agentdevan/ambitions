<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# OS-FLAGSHIP-06-LAUNCH-BELIEVABILITY-REVIEW

## Purpose

Install and validate the launch believability and red-team review gates.

## Required Reads

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/codex/os/AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE.md`
- `.codex/skills/ambitions/release-believability-reviewer.md`
- `.codex/skills/ambitions/red-team-reviewer.md`

## Scope

- Review rubric and closeout discipline only.
- No release readiness, TestFlight readiness, App Store readiness, legal approval, privacy approval, device proof, or public accessibility proof claims without matching evidence.

## Done

- The review asks whether Ambitions feels flagship, local-first, trustworthy, category-creating, and free of early-product seams.
- False proof, generic UI, data-loss risk, duplicate authority, and privacy mismatch are explicit Red checks.
- Validation and rollback notes are recorded.
