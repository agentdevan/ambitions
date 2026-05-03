#!/usr/bin/env bash
set -euo pipefail
rg -n "privacy|delete|export|undo|correction|receipt|sensitive|source" docs/canon/Ambitions_4_0_*External_Brain* docs/canon/Ambitions_4_0_*Kernel.md docs/codex/batches/EB*.md
