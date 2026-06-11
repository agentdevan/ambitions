# UIQL Run-State

```yaml
program: UIQL
current_issue: UIQL-002 blocked by UIQL-001 Red dependency
last_completed_issue: UIQL-001 preflight and authority refresh
latest_pushed_commit: pending UIQL-001 closeout push; git commit hash cannot be embedded in the same commit that creates it
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
  - artifacts/ui-quality-lockdown/UIQL-001_PREFLIGHT_REPORT.md
script_output_index:
  - artifacts/ui-quality-lockdown/script-output/.gitkeep
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T010741.log
  - artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log
  - artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log
  - artifacts/ui-quality-lockdown/script-output/uiql-shell.log
reviewer_output_index:
  - artifacts/ui-quality-lockdown/reviewer-output/.gitkeep
red_blockers:
  - UIQL-002 must not start while Native/AmbitionsTests/App/ActivationContractTests.swift still asserts Capture/Plan-era canonical activation surfaces.
yellow_tooling_limits:
  - Visual/accessibility proof requires current screenshots and actual evaluation before claims.
  - Linear issue UIQL-001 was not found by available identifier fetch; manual closeout text is in UIQL-001_PREFLIGHT_REPORT.md.
linear_update_status: manual-text-ready; Linear issue not found by available connector
next_dependency: repair or reframe Activation Contract stale IA expectation before UIQL-002
stale_or_unknown_fields:
  - Active Linear issue IDs must be refreshed before execution; UIQL-001 fetch returned issue-not-found.
updated_at: 2026-06-11 America/New_York
```
