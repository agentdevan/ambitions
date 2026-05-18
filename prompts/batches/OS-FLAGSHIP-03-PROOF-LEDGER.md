<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# OS-FLAGSHIP-03-PROOF-LEDGER

## Purpose

Install and validate proof-ledger discipline for future Ambitions batches.

## Required Reads

- `docs/truth/README.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/os/AMB-CODEX-OS-PROOF-LEDGER.md`
- `docs/codex/os/AMB-CODEX-OS-GREEN-YELLOW-RED-STANDARD.md`
- `.codex/skills/ambitions/proof-ledger-writer.md`

## Scope

- Batch proof schema, report expectations, and claim-to-evidence mapping only.
- No production Swift, release automation, public release claim, or app-store readiness claim.

## Done

- Every touched claim has evidence path, command, status, known gap, and proof type.
- Green is blocked when proof is missing.
- Validation and rollback notes are recorded.
