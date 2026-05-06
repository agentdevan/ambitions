#!/usr/bin/env bash
set -euo pipefail

# Advisory scan for Source Atlas Research Seeds v1.
# Non-mutating. Does not print private source contents.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

DEST="Resources/SourceAtlas/ResearchSeeds"
MANIFEST="$DEST/source_atlas_research_seeds_v1_import_manifest.json"
STATUS=0

if [[ ! -d "$DEST" ]]; then
  echo "SA RESEARCH SEEDS WARNING: $DEST is missing. Run tools/source-atlas/research-import/import_source_atlas_research_seeds.py."
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "SA RESEARCH SEEDS WARNING: import manifest missing: $MANIFEST"
  STATUS=1
fi

if [[ -f "$DEST/source_atlas_goal_corpus_10000.jsonl" || -f "$DEST/source_atlas_goal_corpus_10000.csv" ]]; then
  echo "SA RESEARCH SEEDS WARNING: misleading 10000 corpus filename remains. Use seed_5880 names."
  STATUS=1
fi

if [[ ! -f "$DEST/source_atlas_goal_corpus_seed_5880.jsonl" ]]; then
  echo "SA RESEARCH SEEDS WARNING: source_atlas_goal_corpus_seed_5880.jsonl missing."
  STATUS=1
else
  ROWS=$(grep -cve '^\s*$' "$DEST/source_atlas_goal_corpus_seed_5880.jsonl" || true)
  if [[ "$ROWS" != "5880" ]]; then
    echo "SA RESEARCH SEEDS WARNING: expected 5880 JSONL rows, got $ROWS."
    STATUS=1
  fi
fi

for file in \
  source_atlas_backlog_500.json \
  source_atlas_fixtures_500.json \
  source_atlas_projection_recipes.json \
  source_atlas_source_registry_candidates_250.json \
  source_atlas_capability_graph_seeds.json \
  source_atlas_domain_taxonomy.json; do
  if [[ ! -f "$DEST/$file" ]]; then
    echo "SA RESEARCH SEEDS WARNING: missing $DEST/$file"
    STATUS=1
  fi
done

if [[ -f "$MANIFEST" ]]; then
  python3 - <<'PY'
import json, pathlib, sys
p = pathlib.Path('Resources/SourceAtlas/ResearchSeeds/source_atlas_research_seeds_v1_import_manifest.json')
try:
    data = json.loads(p.read_text())
except Exception as exc:
    print(f"SA RESEARCH SEEDS WARNING: manifest invalid JSON: {exc}")
    sys.exit(1)
if data.get('classification') != 'research_seed':
    print('SA RESEARCH SEEDS WARNING: manifest classification must be research_seed')
    sys.exit(1)
if data.get('production_use') is not False:
    print('SA RESEARCH SEEDS WARNING: manifest production_use must be false')
    sys.exit(1)
files = data.get('files', [])
if len(files) < 24:
    print(f'SA RESEARCH SEEDS WARNING: manifest should include at least 24 files, got {len(files)}')
    sys.exit(1)
print('SA RESEARCH SEEDS OK: manifest classification and file inventory present.')
PY
fi

exit "$STATUS"
