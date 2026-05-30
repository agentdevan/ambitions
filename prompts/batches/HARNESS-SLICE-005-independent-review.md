<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HARNESS-SLICE-005 — Add independent review and adversarial gates

Issue: AMB-304

## Control Plane

- Main-only execution.
- Use active truth files and AGENTS.md as authority.
- Do not edit `docs/truth/*`.
- Do not commit generated `build/reports/**` runtime output.
- Do not make release, TestFlight, App Store, device, accessibility, privacy/legal, or app-completion claims.
