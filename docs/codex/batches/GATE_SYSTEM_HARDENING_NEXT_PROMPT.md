# Gate System Hardening Next Prompt

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
