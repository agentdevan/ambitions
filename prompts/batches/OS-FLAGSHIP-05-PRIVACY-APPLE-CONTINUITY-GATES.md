<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# OS-FLAGSHIP-05-PRIVACY-APPLE-CONTINUITY-GATES

## Purpose

Install and validate privacy, local-first, and Apple continuity claim gates.

## Required Reads

- `docs/truth/README.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/codex/os/AMB-CODEX-OS-PRIVACY-CLAIM-GATE.md`
- `docs/codex/os/AMB-CODEX-OS-APPLE-CONTINUITY-GATE.md`
- `.codex/skills/ambitions/privacy-claim-verifier.md`
- `.codex/skills/ambitions/apple-continuity-reviewer.md`

## Scope

- Claim verification and continuity review routing only.
- No new sync, CloudKit, entitlement, app group, backend, analytics, account, or hosted service behavior.

## Done

- Privacy and continuity claims map to source, entitlement, manifest, user-facing copy, and evidence where applicable.
- Unsupported claims are marked Red or Yellow with owner and no-claim boundary.
- Validation and rollback notes are recorded.
