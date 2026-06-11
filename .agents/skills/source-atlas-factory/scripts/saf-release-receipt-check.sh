#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p artifacts/source-atlas-factory/script-output; rg -n "release receipt|revocation|rollback|freshness|hash" artifacts/source-atlas-factory > artifacts/source-atlas-factory/script-output/saf-release-receipt.log 2>&1; exit 0
