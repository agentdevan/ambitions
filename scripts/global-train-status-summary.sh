#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
name="$(basename "$0")"
echo "$name: Codex OS deterministic advisory scan"
echo "Active train: Ambitions 4.0 External Brain Foundation"
echo "Current global order: 047"
echo "Total planned batches: 153"
echo "Last completed/accepted state: CS09 accepted Yellow / parked; External Brain integration committed"
echo "Next eligible batch: EB01 External Brain Source Truth And Kernel Architecture"
echo "Working tree:"
git status --short
