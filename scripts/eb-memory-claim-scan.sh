#!/usr/bin/env bash
set -euo pipefail
rg -n "source|confidence|delete|correction|receipt|stale|rejected|sensitive" docs/canon/Ambitions_4_0_Life_Memory_Graph_Kernel.md docs/codex/batches/EB07*.md docs/codex/batches/EB08*.md docs/codex/batches/EB09*.md docs/codex/batches/EB10*.md docs/codex/batches/EB11*.md docs/codex/batches/EB12*.md
