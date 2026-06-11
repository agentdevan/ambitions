# Proof Ledger

Status: Active Codex OS v2 proof ledger
Authority: Process evidence ledger, subordinate to `docs/truth/RELEASE_TRUTH.md`

## Rules

Entries must include claim, commit, touched files, command, exit code, artifact path, screenshot path if visual, scope, non-claims, freshness, responsible program, related Linear issue, and Green/Yellow/Red evidence status.

## Entries

### 2026-06-11 - AMB-CODEX-OS-V2 Initial Validator Audit

- Claim: Existing Codex OS validator/doctor expectations were audited before v2 install.
- Commit: working tree before install from `b5bfa2ed891a412e0d9e43b99c744422fe2a990c`.
- Touched files: audit logs under `artifacts/codex-os-v2/script-output/`.
- Command: `python3 scripts/ambitions-codex-os-validate.py`; `python3 scripts/ambitions-codex-os-doctor.py`; `make scripts-doctor`; `make repo-doctor`.
- Exit code: validate `1`; doctor `0`; scripts-doctor `2`; repo-doctor terminated after bounded timeout.
- Artifact path: `artifacts/codex-os-v2/script-output/`.
- Screenshot path if visual: not applicable.
- Scope: Codex OS governance audit only.
- Non-claims: no app build, tests, accessibility, performance, privacy/legal, device, TestFlight, App Store, or release readiness proof.
- Freshness: current on 2026-06-11 for the local working tree.
- Responsible program: CODEX-OS.
- Related Linear issue: AMB-CODEX-OS-V2-001.
- Evidence status: Yellow/Red existing drift documented.
