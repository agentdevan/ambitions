<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HARNESS-SLICE-001 — Lock Slice 1 harness baseline

Issue: AMB-300

## Control Plane

- Main-only execution.
- Use active truth files and AGENTS.md as authority.
- Do not edit `docs/truth/*`.
- Do not commit generated `build/reports/**` runtime output.
- Do not make release, TestFlight, App Store, device, accessibility, privacy/legal, or app-completion claims.
