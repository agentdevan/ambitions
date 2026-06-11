# AMB-CODEX-OS-V2 Run-State

```yaml
program: CODEX-OS
current_issue: AMB-CODEX-OS-V2-001..013 install in progress
last_completed_issue: none before this install
latest_pushed_commit: not pushed in this run
branch: main
authority_files_read:
  - docs/truth/README.md
  - docs/truth/PRODUCT_DESIGN_TRUTH.md
  - docs/truth/PRODUCT_MOAT_TRUTH.md
  - docs/truth/IMPLEMENTATION_TRUTH.md
  - docs/truth/RELEASE_TRUTH.md
  - docs/truth/CODEX_PROCESS_TRUTH.md
  - docs/truth/HISTORICAL_POLICY.md
  - AGENTS.md
  - .codex/OPERATING_SYSTEM.md
  - .codex/REPO_INVENTORY.md
  - .agents/AGENTS.md
  - .linear-sync/ambitions-linear-sync.yml
  - scripts/ambitions-codex-os-validate.py
  - scripts/ambitions-codex-os-doctor.py
  - Makefile
source_ownership: docs/scripts/skills/artifacts governance only
active_gates:
  - git branch/status/head/pull gate
  - existing Codex OS validator/doctor audit
  - docs/scripts/artifacts-only scope gate
  - program preflight gates
  - proof index gate
  - linear closeout validator help gate
  - final red-team audit
evidence_index:
  - artifacts/proof-ledger/PROOF_LEDGER.md
  - artifacts/proof-ledger/proof-index.json
script_output_index:
  - artifacts/codex-os-v2/script-output/001-initial-ambitions-codex-os-validate.log
  - artifacts/codex-os-v2/script-output/001-initial-ambitions-codex-os-doctor.log
  - artifacts/codex-os-v2/script-output/001-initial-make-scripts-doctor.log
  - artifacts/codex-os-v2/script-output/001-initial-make-repo-doctor.log
reviewer_output_index: []
red_blockers: []
yellow_tooling_limits:
  - Existing ambitions-codex-os-validate.py expectations are Red before v2 install because legacy hardening assets are missing.
  - Existing make scripts-doctor reports script inventory drift before v2 install.
  - Initial make repo-doctor exceeded bounded interactive audit time and was terminated.
linear_update_status: pending; manual text required if Linear issues or access unavailable
next_dependency: finish install, validate, commit, push, then Linear/manual closeout
stale_or_unknown_fields:
  - Linear issue existence not verified yet.
updated_at: 2026-06-11 America/New_York
```
