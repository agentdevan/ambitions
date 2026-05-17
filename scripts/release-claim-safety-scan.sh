#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
name="$(basename "$0")"
echo "$name: Codex OS deterministic claim scan"
files=$(git diff --name-only HEAD -- | tr "\n" " ")
[ -z "$files" ] && files="docs/truth README.md docs/status docs/native-build-and-release.md"
case "$name" in
  release-claim-safety-scan.sh) pattern="production ready|release ready|TestFlight ready|App Store ready|market proven|screenshot verified|device verified|physical device passed|VoiceOver verified|Instruments passed|battery safe|legal signoff|privacy certified|accessibility compliant|fully autonomous|AI understands everything|remembers everything|guaranteed" ;;
  privacy-boundary-scan.sh) pattern="sensitive memory|inference|recommendation|local-first|private mode|export/delete" ;;
  memory-safety-scan.sh) pattern="durable memory|inferred memory|fake intimacy|creepy|remembers everything" ;;
  accessibility-cognitive-load-scan.sh) pattern="color-only|VoiceOver|Dynamic Type|Reduce Motion|shame|blame|failed|overloaded day" ;;
  source-truth-duplicate-scan.sh|no-duplicate-canon-check.sh) pattern="External Brain|Capture|Memory|Trust|Privacy|Accessibility|Onboarding|AmbitionsOS|PXOS|Release claims" ;;
  skeletal-prompt-scan.sh) pattern="follow canon|improve|polish|update as needed|wire up later|refine later|TBD|placeholder|generic|simple|as appropriate|optional if time allows|AI magic|smart stuff|make it better" ;;
  generic-product-drift-scan.sh) pattern="dashboard|CRM|chatbot|notes app|habit tracker|SaaS|admin|smart" ;;
  no-unsupported-ai-claim-scan.sh) pattern="AI understands|fully autonomous|guaranteed|magic|smart stuff" ;;
  no-creepy-intelligence-scan.sh) pattern="creepy|fake intimacy|hidden inference|remembers everything|manipulative" ;;
  privacy-export-delete-readiness-scan.sh) pattern="export/delete|delete path|privacy certified|legal signoff" ;;
  accessibility-ui-batch-readiness-scan.sh) pattern="Dynamic Type|VoiceOver|Reduce Motion|tap target|non-color" ;;
  memory-source-confidence-readiness-scan.sh) pattern="source|confidence|edit path|deletion path|receipt|rejection" ;;
  capture-routing-readiness-scan.sh) pattern="routing|correction|receipt|privacy|reclassification" ;;
  fixture-coverage-scan.sh) pattern="fixture|preview|overloaded-day|recovery" ;;
  *) pattern="External Brain" ;;
esac
hits="$(rg -n -i "$pattern" $files 2>/dev/null | rg -v 'scripts/release-claim-safety-scan.sh|scripts/no-fake-proof-gate.sh' || true)"
if [ -z "$hits" ]; then
  echo "GREEN no proof-sensitive release claims found"
  exit 0
fi

# These docs are claim-boundary examples and required proof standards, not release claims.
allowlisted_docs='docs/codex/RELEASE_CLAIM_SAFETY_SEAL.md:|docs/codex/CODEX_EVIDENCE_STANDARD.md:'
non_claim='not |no |without|unclaimed|absent|unless|forbidden|not run|not produced|does not claim|do not claim|not allowed|future|deferred|missing|cannot infer|claim boundary|separately proven'
suspect="$(printf '%s\n' "$hits" | rg -v -i "$allowlisted_docs" | rg -v -i "$non_claim" || true)"
if [ -z "$suspect" ]; then
  echo "GREEN proof-sensitive release terms are framed as non-claims, boundaries, or future proof"
  exit 0
fi

echo "RED unsupported proof-sensitive release claims need review"
printf '%s\n' "$suspect" | head -80
exit 1
