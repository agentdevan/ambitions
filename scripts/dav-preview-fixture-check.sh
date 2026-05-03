#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-preview-fixture-check"
required=(
  "calm normal day"
  "overloaded day"
  "recovery day"
  "empty capture"
  "routed capture"
  "blocked step"
  "Still Counts"
  "goal with proof"
  "goal with blocker"
  "stale memory"
  "rejected memory"
  "Private memory"
  "Dynamic Type"
  "Reduce Motion"
)

missing=0
for pattern in "${required[@]}"; do
  if ! rg -n "$pattern" Native/Ambitions/PreviewSupport Sources/Previews docs/audits docs/codex >/dev/null 2>&1; then
    echo "RED missing DAV preview scenario: $pattern"
    missing=1
  fi
done

if [[ "$missing" -eq 0 ]]; then
  echo "GREEN DAV12 preview fixture inventory present"
else
  echo "RED DAV12 preview fixture inventory incomplete"
fi
exit "$missing"
