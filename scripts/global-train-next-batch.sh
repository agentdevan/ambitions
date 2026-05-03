#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"
echo "Next eligible batch: EB01 External Brain Source Truth And Kernel Architecture"
echo "Reason: no EB batch is complete; EB01 precedes all EB work"
