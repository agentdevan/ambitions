# Source Atlas Research Import

This directory contains local-only import tooling for Source Atlas Research Seeds v1.

## Purpose

The Deep Research appendices are accepted as research seed data, not production source packs.

Use this importer to place the uploaded ZIP contents under:

```text
Resources/SourceAtlas/ResearchSeeds/
```

## Expected source ZIP

```text
ambitions_source_atlas_machine_readable_appendices.zip
```

Expected SHA-256:

```text
952617c70572fbcc8e42301c893412059c08556186e584366a88604e2cf51d81
```

## Run

```bash
python3 tools/source-atlas/research-import/import_source_atlas_research_seeds.py \
  --zip /path/to/ambitions_source_atlas_machine_readable_appendices.zip \
  --repo-root .

bash scripts/sa-research-seeds-integrity-scan.sh
```

## Import rules

- Verify ZIP hash before import.
- Extract all 24 appendices.
- Rename `source_atlas_goal_corpus_10000.*` to `source_atlas_goal_corpus_seed_5880.*`.
- Write import manifest with counts and hashes.
- Mark artifacts as `research_seed`.
- Do not treat these files as production packs.

## No-claim boundary

This importer does not validate official claims, compile packs, approve sources, implement runtime Source Atlas, or make release claims.
