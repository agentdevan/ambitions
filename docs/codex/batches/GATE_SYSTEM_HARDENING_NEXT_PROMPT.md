# Gate System Hardening Next Prompt

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Use this when resuming the global train and you want Codex to reconcile the new gate-system hardening layer.

```markdown
You are continuing the Ambitions global batch train.

Task: Reconcile and validate the Gate System Hardening layer.

Do not replay completed batches.
Do not convert all advisory gates into hard blocking CI unless a strictness policy explicitly allows it.
Do not claim TestFlight/App Store/release/legal compliance from this governance work.
Do not modify production Swift unless the active batch explicitly requires it.

Read first:
- `docs/codex/GATE_SYSTEM_HARDENING_IMPLEMENTATION_PLAN.md`
- `docs/codex/GATE_RESULT_MANIFEST_SCHEMA.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_BATCH_REPORT_TEMPLATE.md`
- `.github/workflows/cqs-advisory-gates.yml`
- `scripts/validate-gate-result-manifest.py`
- `docs/audits/gate-results/example-gate-result.json`
- `docs/codex/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT.md`
- `docs/codex/SOURCE_ATLAS_RESEARCH_SEEDS_V1_LIMITATIONS.md`

Required actions:
1. Inspect git state and current active batch.
2. Validate the gate result schema and example manifest:
   `python3 scripts/validate-gate-result-manifest.py docs/audits/gate-results/example-gate-result.json`
3. Run the CQS advisory scans locally, advisory mode only:
   `CQS_STRICT=0 scripts/cqs-architecture-boundary-scan.sh || true`
   `CQS_STRICT=0 scripts/cqs-product-drift-scan.sh || true`
   `CQS_STRICT=0 scripts/cqs-accessibility-motion-scan.sh || true`
   `CQS_STRICT=0 scripts/cqs-performance-budget-scan.sh || true`
   `CQS_STRICT=0 scripts/cqs-prompt-built-smell-scan.sh || true`
   `CQS_STRICT=0 scripts/cqs-privacy-security-claim-scan.sh || true`
4. Run Source Atlas advisory scans if scripts exist:
   `scripts/sa-composition-projection-scan.sh || true`
   `scripts/sa-pack-duplication-scan.sh || true`
   `scripts/sa-generated-step-boundary-scan.sh || true`
   `scripts/sa-projection-fixture-coverage-scan.sh || true`
   `scripts/sa-research-seeds-integrity-scan.sh || true`
5. Verify the GitHub Actions workflow is advisory-first and does not hard-fail on normal advisory warnings.
6. For the current or next completed batch, create a real gate result manifest at:
   `docs/audits/gate-results/<batch-id>-gate-result.json`
7. Validate that manifest with:
   `python3 scripts/validate-gate-result-manifest.py docs/audits/gate-results/<batch-id>-gate-result.json`
8. Update the batch report to link the manifest and commit provenance.
9. Commit with a focused message if changes are made.

Hard Red stop conditions:
- Invalid gate-result manifest schema.
- CI workflow hard-fails all advisory warnings without strictness approval.
- Release/TestFlight/App Store/legal compliance claims are introduced without evidence.
- Research seeds are treated as production source truth.
- Active batch work is overwritten.
- Force push would be required.

Closeout report must include:
- validation commands and results
- whether CI is advisory or strict
- manifest paths
- any Yellow caveats
- next eligible batch
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
