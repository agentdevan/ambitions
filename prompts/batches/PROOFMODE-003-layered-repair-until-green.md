<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# PROOFMODE-003 — Layered Repair Until Green

Issue: AMB-309

## Control Plane

- Main-only execution.
- Layered bounded repair loop.
- No `docs/truth/*` edits.
- No generated `build/reports/**` commits.
- No production user-data mutation.
- No cloud AI, analytics, backend, telemetry, tracking, signing, hosted CI, App Store automation, or production dependencies.
- No release, TestFlight, App Store, device, accessibility, privacy/legal, or app-completion claims.
