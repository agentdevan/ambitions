# Ambitions Script Inventory

Status: Active script hygiene index
Scope: Scripts, Makefile entrypoints, script safety posture, and deletion eligibility
Authority: Supporting control-plane inventory only; not product truth, app implementation proof, validation proof, release proof, or cleanup approval beyond rows marked delete_safe.

## Summary

- Total indexed script/control files: 372
- Executable scripts: 195
- Python scripts: 205
- Shell scripts: 164
- Makefile/canonical entrypoints: 63
- Scripts with risky git commands after repair: 0
- Scripts with unapproved raw Xcode front-door commands after repair: 0
- Scripts with old IA or old-canon flags: 3
- Classification counts: active=63, archive-candidate=141, duplicate=1, stale=1, supporting=166

## Canonical Active Script Lanes

- `scripts/ambitions-codex-train.sh` - Canonical batch runner
- `scripts/ambitions-xcode-validate.sh` - Canonical Xcode validation wrapper
- `scripts/ambitions-codex-os-validate.py` - Canonical Codex OS validator
- `scripts/governance/ambitions-repo-doctor.py` - Canonical repo doctor
- `scripts/codex-forbidden-claim-scan.sh` - Canonical forbidden-claim scanner
- `scripts/ios26-flagship-preflight.py` - Canonical iOS 26 preflight gate
- `scripts/ios26-flagship-proof-packet-check.py` - Canonical iOS 26 proof-packet gate
- `scripts/ios26-flagship-run-sequential.sh` - Canonical iOS 26 sequential runner

## Deletion Boundary

Only rows with `delete_safe: true` may be deleted by a future cleanup pass. This pass deletes only `scripts/.DS_Store` as obvious local junk. Train-family scanners and validators are classified but preserved.

## Inventory

| path | family | classification | entrypoint_status | risk | replacement | action | delete_safe | notes |
|---|---|---|---|---|---|---|---|---|
| scripts/.DS_Store | misc | duplicate | deleted | junk-macos-metadata | delete junk file | deleted in this pass | true |  |
| scripts/accessibility-cognitive-load-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/accessibility-ui-batch-readiness-scan.sh | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ai/acx | ai | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ai/acx-local | ai | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ai/acx.py | ai | supporting | executable-helper | claim-sensitive |  | preserve as supporting helper | false |  |
| scripts/ai/acx_accessibility_packet.py | ai | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ai/acx_build_triage.py | ai | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ai/acx_closeout.py | ai | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ai/acx_impact.py | ai | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ai/acx_local.py | ai | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ai/acx_repair.py | ai | supporting | helper | claim-sensitive |  | preserve as supporting helper | false |  |
| scripts/ai/acx_sanitized_evidence.py | ai | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ai/acx_visual_packet.py | ai | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ai/pk_boundary_scan.py | ai | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-accessibility-contract-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-active-authority-residue-zero-check.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-adr-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-advance-batch-state.py | batch-runner | archive-candidate | helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-authority-ledger-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-authority-supersession-check.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-authorized-batch.sh | batch-runner | active | makefile-exposed | none | scripts/ambitions-codex-train.sh | preserve as active entrypoint | false |  |
| scripts/ambitions-autonomous-train-fastpath.py | batch-runner | archive-candidate | helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-autonomous-train.sh | batch-runner | active | makefile-exposed | none | scripts/ambitions-codex-train.sh | preserve as active entrypoint | false |  |
| scripts/ambitions-batch-closeout-accelerator.py | batch-runner | archive-candidate | helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-batch-lane-classifier.py | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-batch-prep-scaffold.py | batch-runner | active | makefile-exposed | none | scripts/ambitions-codex-train.sh | preserve as active entrypoint | false |  |
| scripts/ambitions-batch-scope-guard.py | batch-runner | archive-candidate | helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-build-lab-doctor.sh | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-bundle-next-batches.py | batch-runner | archive-candidate | helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-closeout-coalesce.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-codex-os-doctor.py | codex-os | active | makefile-exposed | none | scripts/ambitions-codex-os-validate.py | preserve as active entrypoint | false |  |
| scripts/ambitions-codex-os-print-install-notes.py | codex-os | supporting | executable-helper | none | scripts/ambitions-codex-os-validate.py | preserve as supporting helper | false |  |
| scripts/ambitions-codex-os-validate.py | codex-os | active | canonical-entrypoint | none | scripts/ambitions-codex-os-validate.py | preserve as active entrypoint | false | Canonical Codex OS validator |
| scripts/ambitions-codex-train.sh | batch-runner | active | canonical-entrypoint | none | scripts/ambitions-codex-train.sh | preserve as active entrypoint | false | Canonical batch runner |
| scripts/ambitions-component-contract-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-control-plane-check.py | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-dashboard-conflict-authority-check.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-dependency-boundary-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-deriveddata-manager.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-design-system-dashboard.py | design-system | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-design-to-source-trace-check.py | design-system | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-design-token-completeness-check.py | design-system | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-encyclopedia-to-frontend-os-final-gate.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-faang-red-team-evidence-check.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-faang-red-team-review-check.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-fe11-generate-fixture-screenshots.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-fe11-preview-visual-qa-report.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-feature-service-boundary-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-final-report-gate.py | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-frontend-architecture-atlas-check.py | frontend | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-frontend-authority-packet.py | frontend | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-frontend-authority-preflight.py | frontend | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-frontend-drift-check.py | frontend | active | makefile-exposed | claim-sensitive |  | preserve as active entrypoint | false |  |
| scripts/ambitions-frontend-implementation-dashboard.py | frontend | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-frontend-implementation-prompt.py | frontend | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-frontend-next-surface-queue.py | frontend | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-frontend-obsolete-term-scan.py | frontend | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-frontend-proof-contract-check.py | frontend | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-frontend-receipt-check.py | frontend | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-frontend-source-bindings.py | frontend | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-global-train-frontend-authority-check.py | batch-runner | archive-candidate | helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-global-train-supervisor.sh | batch-runner | active | makefile-exposed | none | scripts/ambitions-codex-train.sh | preserve as active entrypoint | false |  |
| scripts/ambitions-historical-baseline-train-guard.py | batch-runner | archive-candidate | helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-human-code-quality-gate.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-ia-surface-vocabulary-ledger.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-install-signature-visual-instruments-07.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-known-yellow-scan.sh | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-local-first-boundary-scan.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-local-first-runtime-trust-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-mature-app-surface-universe-complete-check.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-moat-drift-scan.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-mri-autonomous-router.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-mri-autonomous-train.sh | batch-runner | archive-candidate | helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-mri-materialize-prompts.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-native-iphone-interaction-grammar-check.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-next-batch-resolver.py | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-next-batch-router.py | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-owned-files-detector.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-performance-budget-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-post-pk-speed-router.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-post-pk-speed-train.sh | batch-runner | archive-candidate | helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions-preview-matrix-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-process-preflight.sh | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-prompt-audit.sh | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-prompt-queue-consistency.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-queue-snapshot.py | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-red-repair-router.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-repair-classifier.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-repo-authority-validate.py | misc | supporting | helper | old-canon-reference |  | preserve as supporting helper | false |  |
| scripts/ambitions-runner-access-guard.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-runner-quote-self-check.sh | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-runner-self-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-script-doctor.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-signature-object-gate.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-signature-visual-instruments-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-source-atlas-title-check.py | source-atlas | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-source-proof-receipt-coverage-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-source-provenance-batch-linkage-complete-check.py | batch-runner | active | makefile-exposed | none | scripts/ambitions-codex-train.sh | preserve as active entrypoint | false |  |
| scripts/ambitions-speed-lane-policy.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-speed-queue-guard.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-speed-train.sh | batch-runner | active | makefile-exposed | none | scripts/ambitions-codex-train.sh | preserve as active entrypoint | false |  |
| scripts/ambitions-stale-state-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-state-advance-validate.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-state-machine-contract-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-surface-recipe-coverage-check.py | misc | active | makefile-exposed | claim-sensitive |  | preserve as active entrypoint | false |  |
| scripts/ambitions-surface-recipe-inventory-check.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-surface-recipe-specificity-check.py | misc | active | makefile-exposed | claim-sensitive |  | preserve as active entrypoint | false |  |
| scripts/ambitions-surface-scenario-coverage-check.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-swift6-final-gate.sh | misc | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-swift6-modernization-scan.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-throughput-plan.sh | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-token-contract-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-token-drift-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-token-generate.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-train-family-frontend-extraction-check.py | batch-runner | active | makefile-exposed | none | scripts/ambitions-codex-train.sh | preserve as active entrypoint | false |  |
| scripts/ambitions-ui-decision-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-ui-decision-final-gate.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-ui-decision-implementation-prompt.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-ui-decision-new.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-ui-decision-recipe-link-check.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-ui-decision-sync.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-unsupported-claim-scan.py | claim-scan | supporting | helper | none | scripts/codex-forbidden-claim-scan.sh | preserve as supporting helper | false |  |
| scripts/ambitions-visible-copy-drift-scan.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-visual-100-accessibility-adhd-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-anti-generic-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-atlas-subordination-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-false-green-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-gate-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-hidden-automation-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-local-first-trust-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-native-believability-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-no-false-momentum-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-object-depth-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-primitive-operationality-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-priority-registry-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-prompt-authority-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-proof-dashboard.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-proof-source-receipt-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-recipe-contract-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-scorecard-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-source-debt-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-transaction-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-upgrade-p0-recipes.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-100-vocabulary-full-corpus-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-dashboard.py | visual | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-visual-design-lock-repair-05-final-gate.py | visual | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-visual-direction-change-protocol-check.py | visual | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-item-registry-check.py | visual | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-no-orphan-graph-check.py | visual | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-visual-reference-ledger-check.py | visual | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-regression-readiness-check.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions-visual-source-linkage-check.py | visual | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-visual-surface-graph-check.py | visual | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-visual-template-residue-check.py | visual | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-visual-vocabulary-boundary-check.py | visual | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-vocabulary-drift-scan.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions-wrap-prompt.sh | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/ambitions-xcode-build-for-testing.sh | xcode | supporting | executable-helper | none | scripts/ambitions-xcode-validate.sh | preserve as supporting helper | false |  |
| scripts/ambitions-xcode-failure-classifier.py | xcode | supporting | executable-helper | none | scripts/ambitions-xcode-validate.sh | preserve as supporting helper | false |  |
| scripts/ambitions-xcode-result-extract.sh | xcode | supporting | executable-helper | none | scripts/ambitions-xcode-validate.sh | preserve as supporting helper | false |  |
| scripts/ambitions-xcode-sim-health.sh | xcode | supporting | executable-helper | none | scripts/ambitions-xcode-validate.sh | preserve as supporting helper | false |  |
| scripts/ambitions-xcode-test-focused.sh | xcode | supporting | executable-helper | none | scripts/ambitions-xcode-validate.sh | preserve as supporting helper | false |  |
| scripts/ambitions-xcode-test-plan.sh | xcode | supporting | executable-helper | none | scripts/ambitions-xcode-validate.sh | preserve as supporting helper | false |  |
| scripts/ambitions-xcode-validate.sh | xcode | active | canonical-entrypoint | none | scripts/ambitions-xcode-validate.sh | preserve as active entrypoint | false | Canonical Xcode validation wrapper |
| scripts/ambitions-xcode-version-check.sh | xcode | supporting | executable-helper | none | scripts/ambitions-xcode-validate.sh | preserve as supporting helper | false |  |
| scripts/ambitions-xcodebuildmcp-register.sh | xcode | active | makefile-exposed | none | scripts/ambitions-xcode-validate.sh | preserve as active entrypoint | false |  |
| scripts/ambitions-xcodegen-needed.sh | xcode | supporting | executable-helper | none | scripts/ambitions-xcode-validate.sh | preserve as supporting helper | false |  |
| scripts/ambitions_design_system_15_common.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions_frontend_authority_common.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions_signature_visual_instruments.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions_validate_accessibility_gates.py | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions_validate_authority_drift.py | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions_validate_batch_ids.py | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/ambitions_validate_claim_registry.py | claim-scan | supporting | executable-helper | none | scripts/codex-forbidden-claim-scan.sh | preserve as supporting helper | false |  |
| scripts/ambitions_validate_continuity_claims.py | claim-scan | supporting | executable-helper | none | scripts/codex-forbidden-claim-scan.sh | preserve as supporting helper | false |  |
| scripts/ambitions_validate_moat_install.py | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions_validate_projection_contracts.py | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions_validate_prompt_headers.py | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions_validate_proof_receipts.py | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions_validate_runtime_authority.py | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions_validate_trust_privacy.py | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ambitions_validate_visual_proof.py | visual | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions_visual_100_common.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/ambitions_visual_design_lock_repair_05_common.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/batch-prompt-completeness-scan.sh | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/batch-train-gate-check.sh | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/batch-train-preflight.sh | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/build-local.sh | xcode | supporting | executable-helper | none | scripts/ambitions-xcode-validate.sh | preserve as supporting helper | false | Legacy build helper retained because current prompts still reference it; prefer wrapper for new validation. |
| scripts/canon-language-drift-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/capture-routing-readiness-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/changed-file-boundary-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ci-local-parity.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/codex-forbidden-claim-scan.sh | claim-scan | active | canonical-entrypoint | none | scripts/codex-forbidden-claim-scan.sh | preserve as active entrypoint | false | Canonical forbidden-claim scanner |
| scripts/codex-os/ambitions-codex-os-batch-selector.py | codex-os | active | makefile-exposed | none | scripts/ambitions-codex-os-validate.py | preserve as active entrypoint | false |  |
| scripts/codex-os/ambitions-codex-os-context-pack.py | codex-os | active | makefile-exposed | none | scripts/ambitions-codex-os-validate.py | preserve as active entrypoint | false |  |
| scripts/codex-os/ambitions-codex-os-next-action.py | codex-os | active | makefile-exposed | none | scripts/ambitions-codex-os-validate.py | preserve as active entrypoint | false |  |
| scripts/codex-os/ambitions-codex-os-performance-check.py | codex-os | active | makefile-exposed | none | scripts/ambitions-codex-os-validate.py | preserve as active entrypoint | false |  |
| scripts/codex-os/ambitions-codex-os-repair-router.py | codex-os | active | makefile-exposed | none | scripts/ambitions-codex-os-validate.py | preserve as active entrypoint | false |  |
| scripts/codex-os/ambitions-codex-os-sync-governance.py | codex-os | active | makefile-exposed | none | scripts/ambitions-codex-os-validate.py | preserve as active entrypoint | false |  |
| scripts/codex-os/ambitions_codex_os_common.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/codex-os/context_pack.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/codex-post-pk03-dirty-reconciliation.sh | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/cqs-accessibility-motion-scan.sh | cqs | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/cqs-architecture-boundary-scan.sh | cqs | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/cqs-performance-budget-scan.sh | cqs | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/cqs-preview-coverage-scan.sh | cqs | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/cqs-privacy-security-claim-scan.sh | claim-scan | supporting | executable-helper | none | scripts/codex-forbidden-claim-scan.sh | preserve as supporting helper | false |  |
| scripts/cqs-product-drift-scan.sh | cqs | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/cqs-prompt-built-smell-scan.sh | cqs | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/dav-dynamic-type-evidence-check.sh | dav | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/dav-generic-ui-drift-scan.sh | dav | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/dav-preview-fixture-check.sh | dav | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/dav-product-experience-scorecard.sh | dav | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/dav-reduce-motion-check.sh | dav | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/dav-state-driven-visual-check.sh | visual | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/dav-surface-implementation-check.sh | dav | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/dav-visual-performance-risk-scan.sh | visual | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/dav-visual-primitive-inventory.sh | visual | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/dav-voiceover-evidence-check.sh | dav | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/eb-accessibility-cognitive-load-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/eb-active-train-integration-gate.sh | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/eb-capture-routing-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/eb-dedupe-source-truth-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/eb-implementation-boundary-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/eb-kernel-inventory.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/eb-memory-claim-scan.sh | claim-scan | supporting | executable-helper | none | scripts/codex-forbidden-claim-scan.sh | preserve as supporting helper | false |  |
| scripts/eb-no-5-version-drift-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/eb-no-unsupported-claim-scan.sh | claim-scan | supporting | executable-helper | none | scripts/codex-forbidden-claim-scan.sh | preserve as supporting helper | false |  |
| scripts/eb-privacy-boundary-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/external-brain-evidence-package-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/external-brain-risk-register-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/fet-bottom-chrome-conflict-scan.sh | fet | supporting | executable-helper | claim-sensitive |  | preserve as supporting helper | false |  |
| scripts/fet-copy-density-scan.sh | fet | supporting | executable-helper | claim-sensitive |  | preserve as supporting helper | false |  |
| scripts/fet-first-viewport-budget-scan.sh | fet | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/fet-primitive-density-scan.sh | fet | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/fet-readiness-gate.sh | fet | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/fet-visual-qa-packet-check.sh | visual | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/fixture-coverage-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/focused-test-lane-discovery.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/generic-product-drift-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/global-order-topology-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/global-train-handoff-prompt.sh | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/global-train-next-batch.sh | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/global-train-red-repair-hint.sh | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/global-train-status-summary.sh | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | classify first; consider later archive pass | false |  |
| scripts/governance/ambitions-architecture-debt-score.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-ast-mutation-safety.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-authority-diff-report.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-auto-archive-candidates.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-autonomous-codemod-engine.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-batch-closeout-validate.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-branch-orchestration.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-canon-impact-map.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-canon-installer.py | governance | active | makefile-exposed | none | scripts/governance/ambitions-repo-doctor.py | preserve as active entrypoint | false |  |
| scripts/governance/ambitions-canon-propagation-engine.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-cleanup-action-plan.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-drift-forecast.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-generated-freshness-check.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-global-train-resequencer.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-governance-dashboard.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-governance-reconcile.py | governance | supporting | helper | claim-sensitive | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-governance-trend-report.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-governance-validate.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-historical-registry-extract.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-implementation-expectation-map.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-lineage-confidence-score.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-no-orphan-file-gate.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-orphan-prompt-provenance-classifier.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-pr-segmentation-plan.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-prompt-rewrite-planner.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-repo-doctor.py | governance | active | canonical-entrypoint | none | scripts/governance/ambitions-repo-doctor.py | preserve as active entrypoint | false | Canonical repo doctor |
| scripts/governance/ambitions-repo-shrinker.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-semantic-code-graph.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-sequence-plan.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-spec-synthesis.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-sprawl-budget-check.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-supersession-rewriter.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/governance/ambitions-symbol-ownership-map.py | governance | supporting | helper | none | scripts/governance/ambitions-repo-doctor.py | preserve as supporting helper | false |  |
| scripts/implementation-boundary-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/ios26-api-ledger-check.py | ios26 | supporting | executable-helper | none | iOS 26 gate family | preserve as supporting helper | false |  |
| scripts/ios26-flagship-preflight.py | ios26 | active | canonical-entrypoint | claim-sensitive | iOS 26 gate family | preserve as active entrypoint | false | Canonical iOS 26 preflight gate |
| scripts/ios26-flagship-proof-packet-check.py | ios26 | active | canonical-entrypoint | claim-sensitive | iOS 26 gate family | preserve as active entrypoint | false | Canonical iOS 26 proof-packet gate |
| scripts/ios26-flagship-run-sequential.sh | ios26 | active | canonical-entrypoint | none | iOS 26 gate family | preserve as active entrypoint | false | Canonical iOS 26 sequential runner |
| scripts/ldi-gate-check.sh | ldi | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ldi-global-order-consistency-check.sh | ldi | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ldi-handling-lane-scan.sh | ldi | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ldi-pack-supply-chain-scan.py | ldi | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ldi-release-claim-scan.sh | claim-scan | supporting | executable-helper | none | scripts/codex-forbidden-claim-scan.sh | preserve as supporting helper | false |  |
| scripts/ldi-safety-redteam-fixture-check.py | ldi | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/ldi-source-pack-schema-check.py | ldi | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/local-global-train-supervisor.sh | batch-runner | archive-candidate | executable-helper | none | scripts/ambitions-codex-train.sh | repaired to refuse broad staging | false | Local supervisor now stops before staging/push to preserve path-limited review. |
| scripts/memory-safety-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/memory-source-confidence-readiness-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/no-creepy-intelligence-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/no-duplicate-canon-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/no-existing-status-regression-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/no-fake-proof-gate.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/no-production-swift-touch-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/no-unsupported-ai-claim-scan.sh | claim-scan | supporting | executable-helper | none | scripts/codex-forbidden-claim-scan.sh | preserve as supporting helper | false |  |
| scripts/openai-build-suite-dry-run.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/openai-build-suite-validate.py | misc | active | makefile-exposed | none |  | preserve as active entrypoint | false |  |
| scripts/photo-matched-reference-assets-check.sh | misc | supporting | executable-helper | claim-sensitive |  | preserve as supporting helper | false |  |
| scripts/privacy-boundary-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/privacy-export-delete-readiness-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/pxeq-generic-card-stack-scan.sh | pxeq | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/pxeq-living-module-evidence-scan.sh | pxeq | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/pxeq-motion-meaning-scan.sh | pxeq | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/pxeq-static-ui-drift-scan.sh | pxeq | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/pxeq-surface-evidence-check.sh | pxeq | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/pxeq-ui-batch-readiness-gate.sh | pxeq | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/pxeq-visual-noise-scan.sh | visual | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/release-claim-safety-scan.sh | claim-scan | supporting | executable-helper | none | scripts/codex-forbidden-claim-scan.sh | preserve as supporting helper | false |  |
| scripts/run-doc-qa.sh | misc | supporting | executable-helper | old-canon-reference |  | preserve as supporting helper | false |  |
| scripts/run-visual-design-authority-lock-prep-03.sh | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/run-visual-design-final-form-lock-repair-05.sh | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
| scripts/sa-alternative-path-option-value-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-composition-projection-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-fixture-coverage-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-generated-step-boundary-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-high-risk-claim-scan.sh | claim-scan | supporting | executable-helper | none | scripts/codex-forbidden-claim-scan.sh | preserve as supporting helper | false |  |
| scripts/sa-no-claim-scan.sh | claim-scan | supporting | executable-helper | none | scripts/codex-forbidden-claim-scan.sh | preserve as supporting helper | false |  |
| scripts/sa-ocr-review-required-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-offline-fallback-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-pack-duplication-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-pack-revocation-rollback-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-pack-schema-validate.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-pack-validate.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-private-document-leak-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-projection-fixture-coverage-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-research-seeds-integrity-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-source-container-coverage-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-source-freshness-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-source-ui-fvq-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/sa-user-source-not-official-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/setup-ambitions-proof-mcp.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/setup-ambitions-repo-mcp.sh | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/setup_macos_ios_dev.sh | xcode | supporting | executable-helper | none | scripts/ambitions-xcode-validate.sh | preserve as supporting helper | false |  |
| scripts/si-accessibility-scan.sh | si | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/si-anti-generic-ui-scan.sh | si | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/si-component-inventory.sh | si | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/si-file-size-scan.sh | si | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/si-motion-reduce-motion-scan.sh | si | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/si-preview-coverage-scan.sh | si | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/si-readiness-gate.sh | si | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/si-symbol-grammar-scan.sh | si | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/si-top-level-composition-scan.sh | si | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/si-visual-qa-report.sh | visual | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/sig-accessibility-evidence-check.sh | sig | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/sig-haptics-intent-check.sh | sig | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/sig-no-generic-drift-scan.sh | sig | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/sig-performance-risk-scan.sh | sig | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/sig-preview-gallery-check.sh | sig | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/sig-product-experience-scorecard.sh | sig | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/sig-reduce-motion-coverage-check.sh | sig | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/sig-signature-primitives-inventory.sh | sig | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/sig-surface-polish-check.sh | sig | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/sig-transformative-motion-check.sh | sig | supporting | executable-helper | none |  | preserve as supporting helper | false |  |
| scripts/skeletal-prompt-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/source-truth-duplicate-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/swiftui-architecture-scan.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/test-local.sh | xcode | supporting | executable-helper | none | scripts/ambitions-xcode-validate.sh | rewritten wrapper-first compatibility entrypoint | false | Compatibility shim now delegates to the Xcode wrapper. |
| scripts/transformative-motion-boundary-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/transformative-motion-inventory.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/transformative-motion-preview-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/transformative-motion-reduce-motion-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/transformative-motion-state-meaning-check.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/validate-dev-tools.sh | misc | archive-candidate | executable-helper | none |  | classify first; consider later archive pass | false |  |
| scripts/validate-gate-result-manifest.py | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/validate-github-workflow-policy.sh | misc | archive-candidate | helper | none |  | classify first; consider later archive pass | false |  |
| scripts/validate-repo-authority.sh | misc | stale | helper | old-ia, old-canon-reference |  | do not use as front door; repair or replace before active use | false |  |
| scripts/visual_final_form_common.py | visual | supporting | helper | none |  | preserve as supporting helper | false |  |
