# UIQL Run-State

```yaml
program: UIQL
current_issue: UIQL-001 next runnable
last_completed_issue: none in Goal Mode
latest_pushed_commit: not pushed by UIQL Goal Mode
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
  - docs/codex-os/PROGRAM_REGISTRY.md
source_ownership: UI quality governance; app source only when active UIQL issue scopes it and guards pass
active_gates:
  - program-preflight uiql
  - uiql-preflight
  - uiql-mini-regression
  - reviewer board when useful
  - proof ledger update for visual/accessibility claims
evidence_index:
  - artifacts/proof-ledger/PROOF_LEDGER.md
script_output_index:
  - artifacts/ui-quality-lockdown/script-output/.gitkeep
reviewer_output_index:
  - artifacts/ui-quality-lockdown/reviewer-output/.gitkeep
red_blockers: []
yellow_tooling_limits:
  - Visual/accessibility proof requires current screenshots and actual evaluation before claims.
linear_update_status: not yet updated
next_dependency: UIQL-001 preflight
stale_or_unknown_fields:
  - Active Linear issue IDs must be refreshed before execution.
updated_at: 2026-06-11 America/New_York
```
