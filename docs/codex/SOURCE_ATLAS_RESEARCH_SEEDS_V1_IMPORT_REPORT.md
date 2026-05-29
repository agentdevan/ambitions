# Source Atlas Research Seeds v1 Import Report

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Ready for local Codex ingestion; not production Source Atlas packs.
Date: 2026-05-06
Source package: `ambitions_source_atlas_machine_readable_appendices.zip`

## Decision

The uploaded Deep Research appendices are accepted as **Source Atlas Research Seeds v1**.

They must be imported as research seed data for Pack Factory, Goal Projection, QA fixtures, source registry candidates, and Codex implementation planning.

They must not be treated as production source packs, official source truth, complete world coverage, current legal/career/education requirements, or a statistically proven list of the top 10,000 global goals.

## Verified local package facts

The uploaded ZIP was inspected locally before this report was created.

- ZIP file name: `ambitions_source_atlas_machine_readable_appendices.zip`
- ZIP size: `655182` bytes
- ZIP SHA-256: `952617c70572fbcc8e42301c893412059c08556186e584366a88604e2cf51d81`
- Uncompressed file count: `24`
- Uncompressed total size: `17620855` bytes

## Verified high-value counts

| Artifact | Verified count |
|---|---:|
| Goal corpus rows | 5,880 |
| Domain taxonomy entries | 32 |
| Pack backlog items | 500 |
| QA fixtures | 500 |
| Projection recipes | 500 |
| Source registry candidates | 250 |
| Capability graph seeds | 600 |

## Required import behavior

Local Codex should ingest the ZIP through the import tooling, not by manually pasting JSON into the repo.

The importer must:

1. Verify the ZIP SHA-256.
2. Extract all 24 files.
3. Rename misleading `10000` goal-corpus files to honest seed names:
   - `source_atlas_goal_corpus_seed_5880.csv`
   - `source_atlas_goal_corpus_seed_5880.jsonl`
4. Preserve original package metadata in an import manifest.
5. Store seed artifacts under `Resources/SourceAtlas/ResearchSeeds/`.
6. Mark every artifact as `research_seed`, not `production_pack`.
7. Treat all source registry records as candidates until validated by Source Atlas gates.
8. Treat all goals as representative phrase/fixture seeds, not statistically proven global frequency data.

## Required destination

Recommended import destination after local Codex runs the importer:

```text
Resources/SourceAtlas/ResearchSeeds/
  README.md
  source_atlas_research_seeds_v1_import_manifest.json
  source_atlas_goal_corpus_seed_5880.csv
  source_atlas_goal_corpus_seed_5880.jsonl
  source_atlas_backlog_500.json
  source_atlas_fixtures_500.json
  source_atlas_projection_recipes.json
  source_atlas_source_registry_candidates_250.json
  source_atlas_capability_graph_seeds.json
  source_atlas_domain_taxonomy.json
  ...remaining appendices...
```

## Integration status

This report commits the import contract, limitations, and tooling hooks. It does not commit the large seed data itself through the GitHub connector because the connector cannot directly ingest `/mnt/data` bytes into repository paths safely.

Local Codex should run:

```bash
python3 tools/source-atlas/research-import/import_source_atlas_research_seeds.py \
  --zip /path/to/ambitions_source_atlas_machine_readable_appendices.zip \
  --repo-root .

bash scripts/sa-research-seeds-integrity-scan.sh
```

## No-claim boundary

This import report does not implement Source Atlas runtime, Universal Source Binder, Pack Factory, Freshness Broker, AOS runtime, LDI runtime, source pack validation, bundled production packs, official source completeness, or release readiness.

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
