<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# PROOFMODE-002 — Repair Focused App-Driving Proof Test

Issue: AMB-308

## Control Plane

- Main-only execution.
- Bounded repair only.
- No `docs/truth/*` edits.
- No production user-data mutation.
- No release, TestFlight, App Store, device, accessibility, privacy/legal, or app-completion claims.
