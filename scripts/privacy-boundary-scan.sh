#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"
files=$(git diff --name-only HEAD -- | tr "\n" " ")
[ -z "$files" ] && files="docs/truth README.md AGENTS.md docs/README.md docs/native-build-and-release.md .agents/skills"
case "$name" in
  release-claim-safety-scan.sh) pattern="production ready|TestFlight ready|App Store ready|market proven|physical device passed|legal signoff|privacy certified|accessibility compliant|fully autonomous|AI understands everything|remembers everything|guaranteed" ;;
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
# shellcheck disable=SC2086
rg -n -i "$pattern" $files 2>/dev/null | head -80 || true
echo "YELLOW advisory scan complete; review hits for context and explicit non-claims"
