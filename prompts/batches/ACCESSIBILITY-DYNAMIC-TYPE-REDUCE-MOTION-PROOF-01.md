<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-58973986, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

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

ACCESSIBILITY-DYNAMIC-TYPE-REDUCE-MOTION-PROOF-01

## Objective

Install focused proof coverage for Dynamic Type, Reduce Motion, VoiceOver/accessibility labels, contrast-safe state meaning, and visible non-gesture alternatives on current key surfaces.

This batch may add tests/previews and small accessibility fixes. It must not claim full public accessibility conformance.

## Active Source Truth To Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `Sources/Accessibility/`
- `Sources/Previews/`
- `Native/Ambitions/Features/Today/`
- `Native/Ambitions/Features/Capture/`
- `Native/Ambitions/Features/Time/`
- `Native/Ambitions/Features/Goals/`
- `Native/Ambitions/Features/You/`
- `Native/AmbitionsTests/App/Accessibility*`
- `Native/AmbitionsTests/DesignSystem/`
- `scripts/dav-dynamic-type-evidence-check.sh`
- `scripts/dav-reduce-motion-check.sh`
- `scripts/dav-voiceover-evidence-check.sh`

## Allowed Scope

- `Sources/Accessibility/**`
- `Sources/Previews/**`
- `Sources/Components/**`
- `Native/Ambitions/Features/**`
- `Native/AmbitionsTests/**`
- relevant accessibility validation scripts

## Required Work

- Add or repair focused tests/proof fixtures for Dynamic Type and Reduce Motion on at least Today, Capture, Time, Goals, and You primary objects where feasible.
- Repair small missing accessibility labels or reduce-motion fallbacks if tests expose them.
- Report any coverage not run as not verified.

## Validation Expectations

- Focused accessibility/design-system tests.
- Relevant local accessibility scripts when non-mutating.
- `git diff --check`

## Forbidden Scope

- No claim of full accessibility conformance.
- No visual redesign unrelated to accessibility proof.
- No release/readiness claims.

## Runner Command

```bash
make batch BATCH=ACCESSIBILITY-DYNAMIC-TYPE-REDUCE-MOTION-PROOF-01 PROMPT=prompts/batches/ACCESSIBILITY-DYNAMIC-TYPE-REDUCE-MOTION-PROOF-01.md
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
