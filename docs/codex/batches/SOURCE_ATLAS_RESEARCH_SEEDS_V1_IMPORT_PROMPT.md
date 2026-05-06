# Source Atlas Research Seeds v1 Import Prompt

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
