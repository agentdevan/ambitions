#!/usr/bin/env bash
set -euo pipefail

# Reads one repo-relative changed path per line. Exit 0 means Xcode/Needs Repair
# validation applies; exit 1 means the supplied paths are outside that scope.
grep -Eq '^((docs/qa/evidence/2026-07-05-needs-repair-proof-trigger\.md$)|(Native/)|(Packages/AmbitionsDesignSystem/)|(Ambitions\.xcodeproj/)|(Native/Ambitions\.xcodeproj/)|(project\.yml$)|(scripts/)|(.github/workflows/))'
