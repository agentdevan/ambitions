#!/usr/bin/env bash
set -euo pipefail
pattern_a="Ambitions "
pattern_b="5[.]0"
rg -n "${pattern_a}${pattern_b}|post-4[.]0 only|blocked until Ambitions 4[.]0 completion|Start Ambitions ${pattern_b} External Brain Foundation Train" docs/canon docs/codex .codex scripts || true
