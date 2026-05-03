#!/usr/bin/env bash
set -euo pipefail
test -f docs/audits/ambitions-4-external-brain-dedupe-and-merge-map.md
rg -n "do not touch|reference|update|Active source truth|Historical/audit truth" docs/audits/ambitions-4-external-brain-dedupe-and-merge-map.md
