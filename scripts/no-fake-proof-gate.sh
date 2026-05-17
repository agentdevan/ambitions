#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "no-fake-proof-gate"

scope=$(git diff --name-only HEAD -- docs .codex 2>/dev/null | tr '\n' ' ')
if [ -z "$scope" ]; then
  scope="docs/audits docs/codex .codex/reports"
fi

pattern='screenshot verified|device verified|physical device passed|VoiceOver verified|manual VoiceOver passed|Instruments passed|battery safe|production ready|release ready|TestFlight ready|App Store ready|accessibility compliant|fully accessible'
non_claim='not |no |without|unclaimed|absent|unless|forbidden|not run|not produced|does not claim|do not claim|not allowed|future|deferred|missing|cannot infer|separately proven|claim boundary'

hits="$(rg -n -i "$pattern" $scope 2>/dev/null || true)"
if [ -z "$hits" ]; then
  echo "GREEN no unsupported proof claims found"
  exit 0
fi

# Claim-boundary policy docs intentionally enumerate forbidden terms as examples.
allowlisted_docs='docs/codex/RELEASE_CLAIM_SAFETY_SEAL.md:|docs/codex/CODEX_EVIDENCE_STANDARD.md:'
suspect="$(printf '%s\n' "$hits" | rg -v -i "$allowlisted_docs" | rg -v -i "$non_claim" || true)"
if [ -z "$suspect" ]; then
  echo "GREEN proof-sensitive terms are framed as non-claims or future proof"
  exit 0
fi

echo "RED potential unsupported proof claims need review"
printf '%s\n' "$suspect" | head -80
exit 1
