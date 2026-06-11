# UIQL Run-State

```yaml
program: UIQL
current_issue: AMB-960 / UIQL-005 Visual Anatomy Purge, not started
last_completed_issue: AMB-959 / UIQL-004 Shell Safe-Area + Dock Legibility Repair
latest_pushed_commit: fdb2d39de1a8b707312a31cc5aba0ee194631c07
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
  - artifacts/ui-quality-lockdown/UIQL-006_TIME_LIFESHAPE_FIELD_PROOF.md
  - artifacts/ui-quality-lockdown/UIQL-006_REPAIR_REFRAME_REPORT.md
  - artifacts/ui-quality-lockdown/screenshots/UIQL-006-time-lifeshape-before.png
  - artifacts/ui-quality-lockdown/screenshots/UIQL-006-time-lifeshape-final.png
  - artifacts/ui-quality-lockdown/UIQL-007_MOTION_CURRENT_PROOF.md
  - artifacts/ui-quality-lockdown/UIQL-007_REPAIR_REFRAME_REPORT.md
  - artifacts/ui-quality-lockdown/screenshots/UIQL-007-motion-current-before.png
  - artifacts/ui-quality-lockdown/screenshots/UIQL-007-motion-current-final.png
  - artifacts/ui-quality-lockdown/UIQL_LINEAR_RECONCILIATION_20260611.md
  - artifacts/ui-quality-lockdown/UIQL_LINEAR_MAPPING_PATCH_20260611.md
  - artifacts/ui-quality-lockdown/UIQL-001-aor-failure-postmortem.md
  - artifacts/ui-quality-lockdown/UIQL-002-quality-firewall-report.md
  - artifacts/ui-quality-lockdown/UIQL-003-runtime-shell-proof.md
  - artifacts/ui-quality-lockdown/UIQL-004-AMB-959_REPAIR_REFRAME_REPORT.md
  - artifacts/ui-quality-lockdown/UIQL-004-AMB-959-shell-safe-area-dock-legibility-proof.md
  - artifacts/ui-quality-lockdown/screenshots/amb-959/AMB-959-final-labels-today.png
  - artifacts/ui-quality-lockdown/screenshots/amb-959/AMB-959-final-labels-goals.png
  - artifacts/ui-quality-lockdown/screenshots/amb-959/AMB-959-final-labels-time.png
  - artifacts/ui-quality-lockdown/screenshots/amb-959/AMB-959-final-labels-motion.png
  - artifacts/ui-quality-lockdown/screenshots/amb-959/AMB-959-final-labels-you.png
  - artifacts/ui-quality-lockdown/screenshots/amb-959/AMB-959-final-labels-activated-capture.png
  - artifacts/ui-quality-lockdown/screenshots/amb-959/AMB-959-final-labels-increase-contrast.png
  - docs/codex/ui-quality-firewall.md
  - docs/codex/uiql-issue-template.md
script_output_index:
  - artifacts/ui-quality-lockdown/script-output/.gitkeep
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T010741.log
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T011330.log
  - artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log
  - artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log
  - artifacts/ui-quality-lockdown/script-output/uiql-shell.log
  - artifacts/ui-quality-lockdown/script-output/AMB-958-runtime-shell-repo-state.log
  - artifacts/ui-quality-lockdown/script-output/AMB-958-runtime-shell-root-scan.log
  - artifacts/ui-quality-lockdown/script-output/AMB-958-runtime-shell-tab-scan.log
  - artifacts/ui-quality-lockdown/script-output/AMB-958-runtime-shell-overlay-scan.log
  - artifacts/ui-quality-lockdown/script-output/AMB-958-runtime-shell-contract-check.log
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T075750.log
  - artifacts/ui-quality-lockdown/script-output/AMB-959-shell-geometry-fresh-derived-backdrop.log
  - artifacts/ui-quality-lockdown/script-output/AMB-959-activated-capture-seam-fresh-derived-backdrop.log
  - artifacts/ui-quality-lockdown/script-output/AMB-959-shell-geometry-final-labels.log
  - artifacts/ui-quality-lockdown/script-output/AMB-959-activated-capture-seam-final-labels.log
  - artifacts/ui-quality-lockdown/script-output/AMB-959-final-backdrop-surface-screenshots.log
  - artifacts/ui-quality-lockdown/script-output/AMB-959-final-backdrop-variants-screenshots.log
  - artifacts/ui-quality-lockdown/script-output/AMB-959-final-backdrop-time-recapture.log
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T075437.log
  - artifacts/ui-quality-lockdown/script-output/program-proof-index-20260611T075505.log
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
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T052728.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-006-build-for-testing-final-20260611T102057Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-006-time-object-stage-primitive-focused-test-final-20260611T094333Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-006-time-workspace-ui-test-final-20260611T102158Z.log
  - artifacts/ui-quality-lockdown/script-output/program-proof-index-20260611T062511.log
  - artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T062815.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-007-build-for-testing-after-ui-selector-fold-20260611T110340Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-007-motion-object-stage-primitive-focused-test-final-20260611T105802Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-007-motion-source-proof-receipt-focused-test-final-20260611T105916Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-007-motion-copy-forbidden-focused-test-final-20260611T110733Z.log
  - artifacts/ui-quality-lockdown/script-output/UIQL-007-motion-current-ui-test-folded-final-20260611T110509Z.log
  - artifacts/ui-quality-lockdown/script-output/program-proof-index-20260611T071100.log
  - artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log
  - artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log
  - artifacts/ui-quality-lockdown/script-output/uiql-shell.log
reviewer_output_index:
  - artifacts/ui-quality-lockdown/reviewer-output/.gitkeep
red_blockers:
  - none for AMB-959 shell safe-area and dock legibility after final direct tests and visual inspection.
yellow_tooling_limits:
  - Synthetic UIQL-001 through UIQL-007 source commits remain partial repo evidence only; they do not close actual AMB issues unless later AMB closeouts explicitly map and accept them.
  - AOR evidence is superseded as active runtime scaffold evidence, not flagship UI quality proof.
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
  - UIQL-006 Linear issue was not found by available connector; manual closeout text is in UIQL-006_TIME_LIFESHAPE_FIELD_PROOF.md.
  - UIQL-006 wrapper logs report missing `.xcresult` bundles after successful build/test footers; treat result-bundle availability as Yellow tooling, not as release proof.
  - UIQL-006 stale compiled UI test retries and brittle legacy Time assertions are retained as repair evidence only; final Green relies on rebuilt passing build/test logs and current screenshot visual evaluation.
  - UIQL-007 Linear issue was not found by available connector; manual closeout text is in UIQL-007_MOTION_CURRENT_PROOF.md.
  - UIQL-007 wrapper logs report missing `.xcresult` bundles after successful build/test footers; treat result-bundle availability as Yellow tooling, not as release proof.
  - UIQL-007 concurrent zero-test unit logs and standalone UI selector discovery failure are retained as repair evidence only; final Green relies on serial passing tests, folded UI proof, and current screenshot visual evaluation.
  - AMB-959 wrapper build/test paths reported missing `.xcresult` bundles or stale assertions during repair; final Green relies on direct fresh-derived-data `xcodebuild test` logs and current screenshot visual evaluation.
  - AMB-959 first Time screenshot after the backdrop repair captured the bootstrap card too early; corrected longer-wait recapture is the valid Time visual proof.
  - AMB-959 card-anatomy scanner now blocks newly added forbidden anatomy terms while retaining whole-file reference findings, so narrow label repairs do not falsely complete or block AMB-960 visual anatomy purge.
linear_update_status: actual AMB issues are fetchable; AMB-959 closeout comment posted and issue moved to Done; AMB-960 not started
next_dependency: AMB-960 / UIQL-005 Visual Anatomy Purge
stale_or_unknown_fields:
  - Synthetic UIQL closeout artifacts remain named with `UIQL-*`; they are historical/partial evidence and not actual Linear closeouts.
  - Owner must decide whether partial source commits should be kept, amended by follow-up, or reverted before relying on them for later AMB issues.
updated_at: 2026-06-11 America/New_York
```
