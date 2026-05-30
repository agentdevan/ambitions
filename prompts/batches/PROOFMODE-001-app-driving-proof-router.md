<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# PROOFMODE-001 — Bounded Local App-Driving Proof Router

Issue: AMB-307

## Control Plane

- Main-only execution.
- No `docs/truth/*` edits.
- No production user-data mutation.
- No cloud AI, hosted inference, analytics, backend, telemetry, tracking, signing, or App Store automation.
- No release, TestFlight, App Store, device, accessibility, privacy/legal, or app-completion claims.
