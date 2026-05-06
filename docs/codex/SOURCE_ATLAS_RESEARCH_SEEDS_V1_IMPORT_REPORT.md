# Source Atlas Research Seeds v1 Import Report

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
