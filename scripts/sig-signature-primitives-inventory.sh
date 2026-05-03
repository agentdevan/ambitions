#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "sig-signature-primitives-inventory"
rg -n "Signature Experience|GoalMissionControlLanes|SystemProfilePanel|CaptureAtmosphereComposer|LifeShapeMap|DayTimelineRail|TrustReceipt|ContextRecall|ProofPulse|AdaptiveModuleChrome" docs/canon docs/codex Native/Ambitions Sources .codex 2>/dev/null || true
test -f docs/canon/Ambitions_4_0_Signature_Experience_Layer.md || { echo "RED missing Signature Experience Layer"; exit 1; }
echo "GREEN signature primitives inventory available"
