#!/usr/bin/env bash
set -euo pipefail
rg -n "Dynamic Type|VoiceOver|Reduce Motion|non-color|tap target|motor|plain-language|cognitive-load|overloaded-day" docs/canon/Ambitions_4_0_Accessibility_And_Cognitive_Load_Kernel.md docs/codex/batches/EB*.md
