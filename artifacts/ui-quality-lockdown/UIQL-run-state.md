# UIQL Run-State

```yaml
program: UIQL
current_issue: UIQL-006 next runnable after UIQL-005 push
last_completed_issue: UIQL-005 Goals / Direction quality gate
latest_pushed_commit: d4b273e299ac4a207759d9104685a223dbfb9bbd; UIQL-005 closeout commit pending push after this run-state update
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
  - artifacts/ui-quality-lockdown/UIQL-003_TODAY_REALITY_MERIDIAN_PROOF.md
  - artifacts/ui-quality-lockdown/screenshots/UIQL-003-today-preview-stable-final.png
  - artifacts/ui-quality-lockdown/UIQL-004_START_HERE_RECOMMENDATION_PROOF.md
  - artifacts/ui-quality-lockdown/UIQL-004_REPAIR_REFRAME_REPORT.md
  - artifacts/ui-quality-lockdown/screenshots/UIQL-004-start-here-recommendation-final.png
  - artifacts/ui-quality-lockdown/UIQL-005_GOALS_DIRECTION_ATLAS_PROOF.md
  - artifacts/ui-quality-lockdown/UIQL-005_REPAIR_REFRAME_REPORT.md
  - artifacts/ui-quality-lockdown/screenshots/UIQL-005-goals-your-direction-final.png
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
  - artifacts/ui-quality-lockdown/script-output/UIQL-003-build-for-testing-after-headline-repair-20260611T065532Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-ui-test-after-headline-repair-20260611T065658Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-unit-visible-copy-booted-20260611T070244Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-003-focused-unit-object-stage-booted-20260611T070425Z.log
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T031154.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-004-build-for-testing-after-uiql003-proof-fold-20260611T074348Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-004-start-here-proof-via-today-ui-test-20260611T074511Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-004-start-here-kernel-public-focused-test-final-20260611T074834Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-004-start-here-kernel-private-focused-test-final-serial-20260611T075123Z.log
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T035814.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-005-build-for-testing-after-proof-mode-fit-repair-20260611T091550Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-005-goals-overview-afi07-focused-test-after-loading-repair-serial-20260611T085157Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-005-goals-overview-afri024-focused-test-after-loading-repair-serial-20260611T085322Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-005-screen-contract-human-language-focused-test-20260611T085445Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-005-goals-atlas-ui-test-after-proof-mode-fit-repair-20260611T091732Z.log
reviewer_output_index:
  - artifacts/ui-quality-lockdown/reviewer-output/.gitkeep
red_blockers: []
yellow_tooling_limits:
  - Visual/accessibility proof requires current screenshots and actual evaluation before claims.
  - Linear issue UIQL-001 was not found by available identifier fetch; manual closeout text is in UIQL-001_PREFLIGHT_REPORT.md.
  - First focused test run used a stale test bundle and reproduced the old assertion; valid proof required build-for-testing followed by a rebuilt focused test.
  - `program-closeout-check uiql UIQL-001` returned Red before commit because the intended repair was still dirty; rerun after commit/push from a clean tree.
  - UIQL-002 Linear issue was not found by available connector; manual closeout text is in UIQL-002_SHELL_GEOMETRY_PROOF.md.
  - UIQL-003 Linear issue was not found by available connector; manual closeout text is in UIQL-003_TODAY_REALITY_MERIDIAN_PROOF.md.
  - UIQL-003 failed/interrupted UI automation and abandoned parallel unit logs are retained as repair evidence; final Green relies only on rebuilt passing build/test/unit logs and visual evaluation.
  - UIQL-004 Linear issue was not found by available connector; manual closeout text is in UIQL-004_START_HERE_RECOMMENDATION_PROOF.md.
  - UIQL-004 standalone UI test selector discovery was unreliable; repair reframe folds UIQL-004 assertions into the already-discovered Today UIQL preview selector.
  - UIQL-005 Linear issue was not found by available connector; manual closeout text is in UIQL-005_GOALS_DIRECTION_ATLAS_PROOF.md.
  - UIQL-005 wrapper logs repeatedly report missing `.xcresult` bundles after successful build/test footers; treat wrapper result-bundle availability as Yellow tooling, not as release proof.
  - UIQL-005 broad `ScreenContractRegistryTests` run exposes existing Capture/Motion drift outside this issue; final Green uses the focused human-language screen-contract selector plus scoped Goals tests.
  - UIQL-005 invalid/stale screenshots and zero-test selector attempts are retained as repair evidence only; final Green relies on serial passing tests and current visual evaluation.
linear_update_status: manual-text-ready; Linear issue not found by available connector
next_dependency: after UIQL-005 push, confirm UIQL-006 Linear authority and start UIQL-006 preflight on clean main
stale_or_unknown_fields:
  - Active Linear issue IDs must be refreshed before execution; UIQL-001 fetch returned issue-not-found.
  - UIQL-002 fetch/list-comments returned issue-not-found.
  - UIQL-003 fetch/list-comments returned issue-not-found.
  - UIQL-004 fetch/list-comments returned issue-not-found.
  - UIQL-005 fetch/list-comments returned issue-not-found.
updated_at: 2026-06-11 America/New_York
```
