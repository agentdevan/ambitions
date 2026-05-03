#!/usr/bin/env bash
set -euo pipefail
rg -n "Today|Goals|Capture|Plan|You|route|classification|clarification|receipt|reclassification" docs/canon/Ambitions_4_0_Universal_Capture_Kernel.md docs/codex/batches/EB0*.md docs/codex/batches/EB31*.md docs/codex/batches/EB34*.md
