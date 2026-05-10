#!/usr/bin/env bash
set -Eeuo pipefail

LEDGER="docs/codex/KNOWN_YELLOW_QUARANTINE_LEDGER.md"
ACTIVE_BATCH=".codex/state/active-batch.yml"
STATE_FILE=".codex/reports/current-batch-train-state.md"
printf 'Known-yellow scan\n'
printf 'Source: %s\n' "$LEDGER"

if [[ ! -f "$LEDGER" ]]; then
  echo "KNOWN_YELLOW_LEDGER_MISSING"
  exit 1
fi

printf '\nOpen/known entries:\n'
awk '{
  if ($0 ~ /^ID: |^Source: |^Observed in: |^Status: |^Owner: |^Why it is quarantined: |^When it blocks:|^When it does not block:|^Recheck command:|^No-claim boundary:/)
    print
}' "$LEDGER"

echo ""
echo "Current batch state check:"
if [[ -f "$ACTIVE_BATCH" ]]; then
  awk -F': ' '
    /^[[:space:]]*batch:/ {gsub(/^"|"$/, "", $2); printf("current batch: %s\n", $2)}
    /^[[:space:]]*next_eligible_batch:/ {gsub(/^"|"$/, "", $2); printf("next eligible batch: %s\n", $2)}
  ' "$ACTIVE_BATCH"
elif [[ -f "$STATE_FILE" ]]; then
  awk -F': ' '
    /^Current batch:/ {printf("current batch: %s\n", $2)}
    /^Next recommended implementation pass:/ {printf("next recommended: %s\n", $2)}
  ' "$STATE_FILE"
else
  echo "No current batch state file found at $ACTIVE_BATCH or $STATE_FILE"
fi

echo ""
echo "Queue status file references:"
if [[ -f "docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json" ]]; then
  python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/dev/null
  executable_now=$(python3 - <<'PY'
import json
path='docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json'
with open(path) as f:
    d=json.load(f)
for batch in d.get('batches',[]):
    if batch.get('classification') == 'executable_now':
        print(batch.get('id',''))
        break
PY
)
  echo "Queue executable_now: ${executable_now:-none}"
else
  echo "No queue file found"
fi

echo "Known-yellow scan complete"
