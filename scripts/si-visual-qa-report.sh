#!/usr/bin/env bash
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

echo "== Signature Interface visual QA advisory report =="
echo "Generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Non-claim: this report does not assert screenshot proof, human visual approval, device proof, or release readiness."
echo

scripts/si-component-inventory.sh || true
echo
scripts/si-anti-generic-ui-scan.sh || true
echo
scripts/si-top-level-composition-scan.sh || true
echo
scripts/si-preview-coverage-scan.sh || true
echo
scripts/si-accessibility-scan.sh || true
echo
scripts/si-motion-reduce-motion-scan.sh || true
echo
scripts/si-file-size-scan.sh || true
echo
scripts/si-symbol-grammar-scan.sh || true
echo
echo "Visual QA advisory report complete; attach screenshots/previews separately when a UI batch requires them."
