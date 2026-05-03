#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "dav-surface-implementation-check"
rg -n "DAV0[3-9]|DayTimelineRail|HeroStepPanel|CaptureAtmosphereComposer|LifeShapeMap|MissionControlLanes|SystemProfilePanel|ContextRecall|TrustReceiptStack" Native/Ambitions Sources docs/audits docs/codex 2>/dev/null || true
echo "YELLOW until implemented surface evidence is committed"

