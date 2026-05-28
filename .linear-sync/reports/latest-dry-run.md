# Linear Sync Dry Run

Status: dry_run_only
Generated UTC: 2026-05-28T14:11:50Z
Manifest: `.linear-sync/ambitions-linear-sync.yml`
Linear writes: none

## Summary
- active_truth: 11
- active_work: 164
- historical_reference: 1128
- ignored: 2
- proof: 855
- source: 473
- supporting_reference: 20
- test: 269
- unknown: 2992
- total scanned paths: 5914

## Proposed Linear Mappings
- `active_truth` -> class `active_truth`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: canon`, `area: process`, create_work_items=true, sync_status_only=false, priorities conflict_with_truth=1, stale_or_missing_link=2, classification_only=3
- `active_sequence_and_ios26_manifest` -> class `active_work`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: process`, `area: batch-ledger`, create_work_items=true, sync_status_only=false, priorities runnable_sequence_conflict=1, manifest_or_runner_policy_conflict=1, missing_proof_root_mapping=2, status_mirror_only=3
- `source_paths` -> class `source`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: frontend`, `area: runtime`, create_work_items=true, sync_status_only=false, priorities source_compile_or_contract_regression=1, unproven_source_present_status=2, classification_only=3
- `test_paths` -> class `test`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: process`, create_work_items=true, sync_status_only=false, priorities failing_current_test_or_compile_gate=1, stale_test_expectation=2, coverage_mapping_only=3
- `proof_paths` -> class `proof`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: batch-ledger`, `area: process`, create_work_items=false, sync_status_only=true, priorities failed_current_proof_gate=1, missing_required_proof_for_claim=2, historical_or_advisory_proof=4
- `ios26_batch_prompts` -> class `active_work`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`, labels `area: batch-ledger`, `area: process`, create_work_items=true, sync_status_only=false, priorities runnable_ios26_batch_missing_from_manifest=1, prompt_runner_header_missing=1, dependency_or_proof_root_mismatch=2, installed_not_run_status_mirror=3
- `future_decisions_specs_traceability` -> class `supporting_reference`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: canon`, `area: process`, create_work_items=false, sync_status_only=false, priorities conflicts_with_docs_truth=1, should_be_promoted_to_truth=2, reference_only=4
- `codex_state_allowlist` -> class `supporting_reference`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: process`, `area: batch-ledger`, create_work_items=false, sync_status_only=true, priorities contradicts_active_authority=1, stale_status_mirror=3, reference_only=4
- `historical_canon` -> class `historical_reference`, project `OPS-SYNC-001 - Repo-to-Linear Reconciliation`, labels `area: canon`, create_work_items=false, sync_status_only=true, priorities active_truth_conflict=1, useful_reference_not_promoted=3, historical_only=4
- `historical_non_ios26_prompts` -> class `historical_reference`, project `BATCH-LEDGER-001 - Batch Prompt Train Inventory`, labels `area: batch-ledger`, create_work_items=false, sync_status_only=true, priorities conflicts_with_ios26_authority=1, needs_retirement_or_supersession_note=3, historical_only=4

## Exclusions
- `local_generated_and_cache` -> class `ignored`, reason: Local generated artifacts, caches, and build outputs are not active Linear work by default.
- `secrets_and_machine_local` -> class `ignored`, reason: Secret-bearing or machine-local paths must not be mirrored into Linear.

## Active Canon Files
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/PRODUCT_UPGRADES_VISION.md`
- `docs/truth/README.md`
- `docs/truth/RELEASE_TRUTH.md`

## Active Decision Records
- None

## Active Specs
- None

## Active Traceability
- None

## Active Batch Prompts
- `prompts/batches/IOS26-FLAGSHIP-TRAIN-INSTALL-00.md`
- `prompts/batches/IOS26-MOMENTUM-REFLOW-RUNTIME-WIRING-ADDENDUM-01.md`
- `prompts/batches/IOS26-T00-B01-repo-source-inventory.md`
- `prompts/batches/IOS26-T00-B02-validation-baseline.md`
- `prompts/batches/IOS26-T00-B03-naming-api-drift-inventory.md`
- `prompts/batches/IOS26-T01-B01-toolchain-confirmation.md`
- `prompts/batches/IOS26-T01-B02-deployment-target-bump.md`
- `prompts/batches/IOS26-T01-B03-availability-compatibility-cleanup.md`
- `prompts/batches/IOS26-T02-B00-safe-area-root-invariant.md`
- `prompts/batches/IOS26-T02-B01-native-ios26-shell.md`
- `prompts/batches/IOS26-T02-B02-liquid-glass-token-layer.md`
- `prompts/batches/IOS26-T02-B03-icon-screenshot-foundation.md`
- `prompts/batches/IOS26-T03-B01-broad-suite-yellow-repair.md`
- `prompts/batches/IOS26-T03-B01-runtime-kernel-contracts.md`
- `prompts/batches/IOS26-T03-B02-local-only-proof-harness.md`
- `prompts/batches/IOS26-T03-B03-replayable-decision-traces.md`
- `prompts/batches/IOS26-T04-B01-compiler-input-output-model.md`
- `prompts/batches/IOS26-T04-B02-capacity-aware-compilation.md`
- `prompts/batches/IOS26-T04-B03-compiler-persistence-receipts.md`
- `prompts/batches/IOS26-T04A-B01-life-context-domain.md`
- ... 138 more

## Proof Artifacts
- `build/reports/capture-runtime-bridge/.gitkeep`
- `build/reports/capture-runtime-bridge/capture-runtime-gauntlet-output.json`
- `build/reports/capture-runtime-bridge/capture-runtime-gauntlet.md`
- `build/reports/capture-runtime-bridge/capture-ui-review-surface.md`
- `build/reports/capture-runtime-bridge/future-proof-context-storage.md`
- `build/reports/capture-runtime-bridge/goal-relevance-scanner.md`
- `build/reports/capture-runtime-bridge/plan-insertion-approval.md`
- `build/reports/capture-runtime-bridge/receipts-replay-corrections.md`
- `build/reports/capture-runtime-bridge/semantic-extraction.md`
- `build/reports/core-life-object-store/.gitkeep`
- `build/reports/core-replacement-contracts/.gitkeep`
- `build/reports/core-replacement-contracts/IOS26-T04E-B02.md`
- `build/reports/core-replacement-contracts/IOS26-T04E-B03.md`
- `build/reports/core-replacement-contracts/IOS26-T04E-B05.md`
- `build/reports/core-replacement-contracts/IOS26-T04E-B06.md`
- `build/reports/core-replacement-contracts/IOS26-T04E-B07.md`
- `build/reports/core-replacement-contracts/TRAIN_04E_CLOSEOUT.md`
- `build/reports/core-replacement-contracts/calendar-p0-contract-harness.md`
- `build/reports/core-replacement-contracts/cross-app-journey-contract-harness.md`
- `build/reports/core-replacement-contracts/notion-p0-contract-harness.md`
- ... 835 more

## Historical Paths
- `docs/AmbitionsCanon/00_Canon_Index_10_10_Maturity_Gate.md`
- `docs/AmbitionsCanon/01A_Product_Canon_Flagship_Amendment.md`
- `docs/AmbitionsCanon/01_Product_Canon.md`
- `docs/AmbitionsCanon/02_Continuity_Layer_Chrome.md`
- `docs/AmbitionsCanon/03_Signature_Object_Specs.md`
- `docs/AmbitionsCanon/04_Trust_Privacy_Automation.md`
- `docs/AmbitionsCanon/05_Accessibility_Motion_Performance.md`
- `docs/AmbitionsCanon/06_QA_Preview_Visual_Drift.md`
- `docs/AmbitionsCanon/07_Native_Shell_Tokens_Materials.md`
- `docs/AmbitionsCanon/08_Implementation_Codex_Repo_Integration.md`
- `docs/AmbitionsCanon/09_Flagship_Interface_Preservation_Ledger.md`
- `docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md`
- `docs/AmbitionsCanon/11_Canonical_Vocabulary_And_Copy_Bible.md`
- `docs/AmbitionsCanon/12_Screen_Composition_Constitution.md`
- `docs/AmbitionsCanon/13_Flagship_Experience_Laws.md`
- `docs/AmbitionsCanon/14_Flagship_QA_And_Award_Caliber_Bar.md`
- `docs/AmbitionsCanon/15_AFI_Implementation_Lane.md`
- `docs/AmbitionsCanon/16_Surface_Identity_And_Signature_Moments.md`
- `docs/AmbitionsCanon/17_Ambitions_Product_Grammar.md`
- `docs/AmbitionsCanon/18_Trust_Receipts_And_Closure_Language.md`
- ... 1108 more

## Ignored Paths
- `.env.example`
- `.swiftpm/xcode/xcuserdata/devan.xcuserdatad/xcschemes/xcschememanagement.plist`

## Unknown Paths
- `.agents/AGENTS.md`
- `.agents/skills/ambitions-accessibility-proof/SKILL.md`
- `.agents/skills/ambitions-batch-runner-operator/SKILL.md`
- `.agents/skills/ambitions-external-surfaces/SKILL.md`
- `.agents/skills/ambitions-ios-quality-gate/SKILL.md`
- `.agents/skills/ambitions-ios-validation-xcode-wrapper/SKILL.md`
- `.agents/skills/ambitions-no-cost-gate/SKILL.md`
- `.agents/skills/ambitions-privacy-local-first/SKILL.md`
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md`
- `.agents/skills/ambitions-repo-hygiene-rollback/SKILL.md`
- `.agents/skills/ambitions-runtime-persistence/SKILL.md`
- `.agents/skills/ambitions-source-truth-auditor/SKILL.md`
- `.agents/skills/ambitions-source-truth-authority/SKILL.md`
- `.agents/skills/ambitions-subagent-review-template/SKILL.md`
- `.agents/skills/ambitions-visual-product-quality/SKILL.md`
- `.codex/AGENTS.md`
- `.codex/BATCH_TRAIN_REGISTRY.md`
- `.codex/CODEX_SCORECARD.md`
- `.codex/DEPARTMENT_REGISTRY.md`
- `.codex/GLOBAL_BATCH_TRAIN.md`
- ... 2972 more

## TODO/FIXME Markers
- TODO: 5

### Marker Samples
- `docs/codex/LINEAR_CONTROL_PLANE.md:116` | Todo | Work is requested but not proven or executed. |
- `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.json:5967` "excerpt": "residue, stale user-facing Plan/Profile copy, unowned TODO-style comments,",
- `docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.json:5977` "excerpt": "residue, stale user-facing Plan/Profile copy, unowned TODO-style comments,",
- `docs/audits/me01-maintainability-baseline-and-ownership-map-report.md:159` - `rg -n "TODO|compat|route|accessibilityIdentifier|Start here|What Ambitions Knows|failed|Profile|You" ... || true`
- `docs/audits/me10-architecture-scan-gate-report.md:128` - `rg -n "TODO|compat|route|accessibilityIdentifier|Start here|What Ambitions Knows|failed|Profile|You" ... || true`

## Stale/Deprecated Canon Terms
- `AI recommendation framing`: 40
- `deprecated urgency term`: 475
- `failure-state language`: 2671
- `legacy IA with Plan`: 235
- `legacy Plan tab`: 92
- `legacy Profile tab`: 111
- `legacy move language`: 193
- `legacy next-move language`: 167
- `score-pressure language`: 5800
- `streak-pressure language`: 1657

### Stale Term Samples
- `.agents/skills/ambitions-release-proof-honesty/SKILL.md:19` `failure-state language` - 2. Separate verified, failure-state language, not verified, blocked, and human/device follow-up.
- `.agents/skills/ambitions-visual-product-quality/SKILL.md:20` `legacy next-move language` - 3. Reject `legacy next-move language`, `legacy move language`, `legacy focus CTA`, legacy Plan placement, shame/streak-pressure language pressure, and fake urgency.
- `.agents/skills/ambitions-visual-product-quality/SKILL.md:20` `streak-pressure language` - 3. Reject `legacy next-move language`, `legacy move language`, `legacy focus CTA`, legacy Plan placement, shame/streak-pressure language pressure, and fake urgency.
- `.codex/CODEX_SCORECARD.md:3` `score-pressure language` - # Codex score-pressure languagecard
- `.codex/CODEX_SCORECARD.md:5` `score-pressure language` - Status: Active Codex execution-quality score-pressure languagecard
- `.codex/CODEX_SCORECARD.md:9` `score-pressure language` - This score-pressure languagecard measures Codex execution quality. It is not app quality proof,
- `.codex/CODEX_SCORECARD.md:14` `score-pressure language` - score-pressure language only the work being closed out. Do not score-pressure language uninspected repo areas.
- `.codex/CODEX_SCORECARD.md:15` `score-pressure language` - score-pressure languages require evidence; otherwise mark `not score-pressure languaged`.
- `.codex/CODEX_SCORECARD.md:40` `score-pressure language` - - Not score-pressure languaged: excluded
- `.codex/CODEX_SCORECARD.md:42` `score-pressure language` - Do not convert score-pressure language into user-facing product quality, release readiness, or
- `.codex/CODEX_SCORECARD.md:48` `score-pressure language` - Codex score-pressure languagecard:
- `.codex/CODEX_SCORECARD.md:61` `score-pressure language` - Not score-pressure languaged:
- `.codex/CODEX_SCORECARD.md:71` `score-pressure language` - - an owner explicitly asks for a score-pressure languagecard baseline update
- `.codex/CODEX_SCORECARD.md:73` `score-pressure language` - Per-run score-pressure languages belong in closeout reports, not in this definition file, unless
- `.codex/CODEX_SCORECARD.md:78` `score-pressure language` - This setup pass creates the score-pressure languagecard. It does not score-pressure language all historical Codex
- `.codex/CODEX_SCORECARD.md:87` `score-pressure language` - - docs-only score-pressure languagecard artifact
- `.codex/OPERATING_SYSTEM.md:80` `failure-state language` - | Release proof | `RELEASE_TRUTH.md`, release evidence packet, raw logs | Evidence capture and claim firewall only | Verified/failure-state language/not verified/human follow-up |
- `.codex/OPERATING_SYSTEM.md:146` `failure-state language` - 5. Re-run the failure-state language validation or explain why it was not rerun.
- `.codex/OPERATING_SYSTEM.md:147` `failure-state language` - 6. Close with verified, failure-state language, not verified, and non-claims.
- `.codex/PR_PROTOCOL.md:51` `failure-state language` - - failure-state language
- `.codex/evals/README.md:22` `failure-state language` - - Retries should get narrower instead of repeating the same failure-state language step.
- `.codex/hooks/post_tool_use_review.py:54` `failure-state language` - if any(token in text for token in ("error", "failure-state language", "denied", "permission")):
- `.codex/hooks/user_prompt_submit_guard.py:68` `score-pressure language` - score-pressure language = sum(1 for p in RISK_PHRASES if p in text)
- `.codex/hooks/user_prompt_submit_guard.py:70` `score-pressure language` - return score-pressure language >= 3 or has_forbidden
- `.codex/improvement/skill-refinement-template.md:6` `failure-state language` - - Request shape that failure-state language:
- `.codex/manifests/repair-profiles.yml:33` `legacy next-move language` - - "legacy next-move language"
- `.codex/manifests/repair-profiles.yml:34` `legacy move language` - - "Your legacy move language"
- `.codex/manifests/repair-profiles.yml:80` `failure-state language` - - "BUILD failure-state language"
- `.codex/manifests/repair-profiles.yml:92` `failure-state language` - - "TEST failure-state language"
- `.codex/manifests/repair-profiles.yml:93` `failure-state language` - - "failure-state language test"
- `.codex/manifests/visual-proof-map.yml:69` `score-pressure language` - - visual_score-pressure language
- `.codex/operations/batch-train-commit-policy.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-green-gate-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-human-escalation.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-orchestration-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-red-stop-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-repair-prompt-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-resume-protocol.md:7` `failure-state language` - Use after compaction, failure-state language validation, or user-approved resume.
- `.codex/operations/batch-train-resume-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved
- `.codex/operations/batch-train-rollback-protocol.md:36` `failure-state language` - Any Yellow/Red gate, unclear dirty state, forbidden file touched, failure-state language build/focused test, privacy/copy leak, unapproved dependency/workflow change, or unapproved

## Non-Claims
- This dry run does not write to Linear.
- This dry run does not prove implementation completeness.
- This dry run does not prove build, test, accessibility, performance, device, TestFlight, App Store, privacy, legal, or release readiness.
- Historical paths remain historical unless repo truth explicitly promotes them.
