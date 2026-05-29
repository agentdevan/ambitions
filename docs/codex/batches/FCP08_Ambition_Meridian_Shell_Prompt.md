# FCP08 Ambition Meridian Shell Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-23731427, AMB28-same_source_file_targeted_by_multiple_active_batches-64094379, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-78130534, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-66425070

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Complete Green on 2026-05-05
Train: FCP Flagship Completion
Owner: App shell / navigation
Type: Implementation

## Purpose

Promote the existing feature-flagged Ambition Meridian Shell into the default
shell presentation while preserving native rollback, canonical five-destination
topology, and route ownership.

FCP08 must deepen the shell as a navigation/trust/context layer. It must not
create a sixth tab, hide navigation, rewrite routes, add persistence, add
runtime intelligence, or claim release/accessibility proof.

## Source Truth

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Ambition_Meridian_Shell_SwiftUI_Build_Spec.md`
- `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md`
- `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`

## Allowed Files

- `Native/Ambitions/App/AppShellPresentationMode.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `docs/codex/batches/FCP08_Ambition_Meridian_Shell_Prompt.md`
- `docs/audits/fcp08-ambition-meridian-shell-report.md`
- global order, registry, context, and run-state docs needed to record batch truth

## Forbidden Files

- `AppTab.swift` raw values or canonical tab order unless a hard blocker appears
- external route, widget, App Intent, Live Activity, persistence, schema, sync,
  auth, network, AI, LDI runtime, CI, signing, entitlement, workflow, dependency,
  or release/legal/privacy claim files

## Acceptance

- Meridian is the default shell presentation.
- `--ambitions-shell=native` remains a tested rollback path.
- Five canonical destinations remain Today, Goals, Capture, Plan, You.
- Meridian exposes a compact shell-chrome contract for destination rail,
  receipt overlay zone, global action, safe-area posture, and rollback.
- No route ownership moves into the shell.
- No generic surface, sci-fi command center, AI command button, or hidden
  navigation is introduced.

## Validation

- `xcodegen generate`
- focused `AppShellNavigationTests` and `AppShellChromeTests`
- `scripts/build-local.sh`
- CQS advisory scans
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
