# Source Atlas Research Seeds v1 Import Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-21433652, AMB28-same_source_file_targeted_by_multiple_active_batches-42833998, AMB28-same_source_file_targeted_by_multiple_active_batches-57517626, AMB28-same_source_file_targeted_by_multiple_active_batches-95827206, AMB28-same_surface_multiple_active_batches-13212827, AMB28-stale_or_unknown_active_status-8702757

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Use this prompt only after the `ambitions_source_atlas_machine_readable_appendices.zip` file is available on the local machine running Codex.

## Prompt

```markdown
You are continuing the Ambitions global batch train.

Task: Import Source Atlas Research Seeds v1 from the Deep Research appendices ZIP as research seed data only.

Do not implement production Source Atlas runtime in this batch.
Do not create production source packs in this batch.
Do not claim official/current requirements from this seed package.
Do not rename this to a top-10,000 goal corpus; verified count is 5,880 rows.
Do not treat source registry candidates as approved sources.
Do not bypass Source Atlas validators.
Do not replay completed batches.

Inputs:
- Local ZIP path: ask the operator or infer only if the file exists locally.
- Expected ZIP SHA-256: `952617c70572fbcc8e42301c893412059c08556186e584366a88604e2cf51d81`

Read first:
- `docs/codex/SOURCE_ATLAS_RESEARCH_SEEDS_V1_IMPORT_REPORT.md`
- `docs/codex/SOURCE_ATLAS_RESEARCH_SEEDS_V1_LIMITATIONS.md`
- `tools/source-atlas/research-import/README.md`
- `tools/source-atlas/research-import/import_source_atlas_research_seeds.py`
- `scripts/sa-research-seeds-integrity-scan.sh`
- `docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md`
- `docs/codex/SOURCE_ATLAS_GATE_MATRIX.md`

Required actions:
1. Verify repo is clean or document existing active-train changes.
2. Run the local importer against the provided ZIP:
   `python3 tools/source-atlas/research-import/import_source_atlas_research_seeds.py --zip <ZIP_PATH> --repo-root .`
3. Run:
   `bash scripts/sa-research-seeds-integrity-scan.sh`
4. Verify files are under `Resources/SourceAtlas/ResearchSeeds/`.
5. Verify misleading `source_atlas_goal_corpus_10000.*` files were renamed to:
   - `source_atlas_goal_corpus_seed_5880.csv`
   - `source_atlas_goal_corpus_seed_5880.jsonl`
6. Verify manifest says `classification: research_seed` and `production_use: false`.
7. Add a short import audit report if the importer did not already create enough manifest proof.
8. Commit with message:
   `SA Research Seeds: Import v1 appendices as research seeds`

Required validation:
- `git status --short`
- `git diff --check`
- `python3 tools/source-atlas/research-import/import_source_atlas_research_seeds.py --help`
- `bash scripts/sa-research-seeds-integrity-scan.sh`
- `scripts/sa-composition-projection-scan.sh || true`
- `scripts/sa-pack-duplication-scan.sh || true`
- `scripts/sa-projection-fixture-coverage-scan.sh || true`

Hard Red stop conditions:
- ZIP hash mismatch.
- Import creates production pack claims.
- Import keeps misleading `10000` corpus filename as canonical.
- Import treats source registry candidates as approved sources.
- Import bypasses limitations document.
- Import places seed data in app runtime path without research-seed classification.
- Import creates one-pack-per-goal architecture.
- Import logs private source contents.

Closeout report must include:
- ZIP hash verified.
- File count imported.
- Goal rows verified.
- Renames performed.
- Destination path.
- Manifest path.
- Validation commands and results.
- Explicit no-claim boundary.
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
