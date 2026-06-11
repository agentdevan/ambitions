# UIQL Run-State

```yaml
program: UIQL
current_issue: UIQL-003 next runnable after UIQL-002 push
last_completed_issue: UIQL-002 shell geometry and safe-area proof
latest_pushed_commit: pending UIQL-002 closeout push; git commit hash cannot be embedded in the same commit that creates it
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
  - artifacts/ui-quality-lockdown/UIQL-001_ACTIVATION_CONTRACT_REPAIR.md
  - artifacts/ui-quality-lockdown/UIQL-002_SHELL_GEOMETRY_PROOF.md
  - artifacts/ui-quality-lockdown/UIQL-002_REPAIR_REFRAME_REPORT.md
script_output_index:
  - artifacts/ui-quality-lockdown/script-output/.gitkeep
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T010741.log
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T011330.log
  - artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log
  - artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log
  - artifacts/ui-quality-lockdown/script-output/uiql-shell.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-001-build-for-testing-20260611T051751Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-001-activation-contract-focused-test-20260611T051330Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-001-activation-contract-focused-test-rebuilt-20260611T051909Z.log
  - artifacts/ui-quality-lockdown/script-output/program-proof-index-20260611T012300.log
  - artifacts/ui-quality-lockdown/script-output/program-closeout-check-UIQL-001-20260611T012300.log
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T012519.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-002-build-for-testing-after-seam-clearance-fix-20260611T060706Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-002-shell-geometry-ui-test-after-header-clearance-final-20260611T060022Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-002-activated-capture-seam-ui-test-after-seam-clearance-fix-20260611T060859Z.log
  - artifacts/ui-quality-lockdown/script-output/program-proof-index-20260611T021500.log
reviewer_output_index:
  - artifacts/ui-quality-lockdown/reviewer-output/.gitkeep
red_blockers: []
yellow_tooling_limits:
  - Visual/accessibility proof requires current screenshots and actual evaluation before claims.
  - Linear issue UIQL-001 was not found by available identifier fetch; manual closeout text is in UIQL-001_PREFLIGHT_REPORT.md.
  - First focused test run used a stale test bundle and reproduced the old assertion; valid proof required build-for-testing followed by a rebuilt focused test.
  - `program-closeout-check uiql UIQL-001` returned Red before commit because the intended repair was still dirty; rerun after commit/push from a clean tree.
  - UIQL-002 Linear issue was not found by available connector; manual closeout text is in UIQL-002_SHELL_GEOMETRY_PROOF.md.
linear_update_status: manual-text-ready; Linear issue not found by available connector
next_dependency: confirm UIQL-003 Linear authority and start UIQL-003 preflight on clean main
stale_or_unknown_fields:
  - Active Linear issue IDs must be refreshed before execution; UIQL-001 fetch returned issue-not-found.
  - UIQL-002 fetch/list-comments returned issue-not-found.
updated_at: 2026-06-11 America/New_York
```
