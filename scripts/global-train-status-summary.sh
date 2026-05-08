#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

QUEUE_FILE="docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json"
STATUS_SOURCES=(
  "docs/codex/BATCH_REGISTRY.md"
  ".codex/reports/current-run-state.md"
  ".codex/reports/current-batch-train-state.md"
  "docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md"
  "docs/codex/GLOBAL_QUEUE_MATURITY_LEDGER.md"
)

echo "global-train-status-summary.sh: Codex OS deterministic status summary"

completed() {
  local id="$1"
  rg -q "Complete: ${id}\b|${id} is complete|${id} .*complete Green|${id} .*Complete / Green|${id} .*Complete / Accepted Yellow|${id} .*closed Green|${id} .*closed Accepted Yellow|${id} .*historical complete" "${STATUS_SOURCES[@]}" 2>/dev/null
}

live_next="$(sed -n 's/^Next eligible batch: //p' .codex/reports/current-run-state.md 2>/dev/null | head -n 1 || true)"
if [[ -n "$live_next" ]]; then
  live_id="${live_next%% *}"
  if [[ "$live_id" =~ ^(AFI|PK|SA|LDI|AOS|FCP|PFC|RHC)[0-9A-Z]+$ ]] && ! completed "$live_id"; then
    echo "Active train: Global full-stack execution"
    echo "Total post-PK03 ledger count: 146"
    echo "Next eligible batch: $live_next"
    echo "Queue classification reason: live unfinished current-run state wins"
    echo "Blocking prerequisites: none recorded by live state"
    echo "EFC applies: invoked when relevant"
    echo "Source: .codex/reports/current-run-state.md"
    echo "Working tree:"
    git status --short
    exit 0
  fi
fi

python3 - "$QUEUE_FILE" <<'PY'
import json, sys
from pathlib import Path
from collections import Counter
path=Path(sys.argv[1])
data=json.loads(path.read_text())
counts=Counter(item['classification'] for item in data['batches'])
next_item=None
for item in data['batches']:
    if item['classification'] in {'executable_now','executable_later'}:
        next_item=item
        break
print('Active train: Global full-stack execution')
print(f"Total post-PK03 ledger count: {data['post_pk03_total']}")
for key in ['executable_now','executable_later','blocked_until_dependency','absorbed_as_overlay','conditional_trigger_only','historical_complete_do_not_run','deleted_obsolete','evidence_preserved_minimal','unknown_requires_repair']:
    print(f"{key}: {counts.get(key,0)}")
if next_item:
    print(f"Next eligible batch: {next_item['id']} {next_item['title']}")
    print(f"Queue classification reason: {next_item['classification']} - {next_item['reason']}")
    print(f"Blocking prerequisites: {next_item['blocking_prerequisites'] or 'none'}")
    print(f"EFC applies: {next_item['efc_applicability']}")
else:
    print('Next eligible batch: none')
    print('Queue classification reason: no executable fallback batch found')
    print('Blocking prerequisites: none')
    print('EFC applies: not applicable')
print(f"Source: {path}")
PY
echo "Working tree:"
git status --short
