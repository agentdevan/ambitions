<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-23731427, AMB28-same_source_file_targeted_by_multiple_active_batches-3188896, AMB28-same_source_file_targeted_by_multiple_active_batches-50973887, AMB28-same_source_file_targeted_by_multiple_active_batches-62868623, AMB28-same_source_file_targeted_by_multiple_active_batches-86629836, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01

## Objective

Install regression coverage that prevents `Plan` from reappearing as an active top-level destination while preserving internal compatibility seams where current source/truth allows them.

## Active Source Truth To Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `Native/AmbitionsTests/App/AppShellChromeTests.swift`
- `scripts/validate-repo-authority.sh`

## Allowed Scope

- `Native/Ambitions/App/AppTab.swift` only if a small compatibility bug is found
- `Native/Ambitions/App/AmbitionsRootView.swift` only if a user-facing Plan leak is found
- `Native/AmbitionsTests/App/**`
- `scripts/ambitions-vocabulary-drift-scan.py` or adjacent validation script only if needed for automated guard coverage
- status docs only to record conservative proof limits

## Required Work

- Add focused tests proving top-level user-facing destinations are exactly `Today / Goals / Capture / Time / You`.
- Add or repair tests proving legacy `plan` routes map to Time rather than a Time surface.
- Scan front-door/status docs for active `Today / Goals / Capture / Plan / You` leaks and repair only active/supporting files, not historical archives.

## Validation Expectations

- Focused app shell/navigation tests.
- `bash scripts/validate-repo-authority.sh .`
- `git diff --check`

## Forbidden Scope

- No product IA redesign.
- No sixth tab.
- No deletion of compatibility aliases unless tests and truth require it.

## Runner Command

```bash
make batch BATCH=TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01 PROMPT=prompts/batches/TOP-LEVEL-IA-PLAN-LEAK-REGRESSION-01.md
```

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
