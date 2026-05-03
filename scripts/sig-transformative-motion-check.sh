#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "sig-transformative-motion-check"
rg -n "CaptureToReceiptMorph|HeroToSessionExpansion|RailRowToStepDetailTransition|PlanBlockToTodayTransition|GoalLaneFocusTransition|EvidenceToRecallBloom|ReceiptStackSettle|OverloadToRecoveryCollapse|ProofPulseSettle|QuietCommandFocus" docs/canon docs/codex .codex Native/Ambitions Sources 2>/dev/null || true
test -f docs/canon/Ambitions_4_0_Transformative_Motion_System.md || { echo "RED missing Transformative Motion System"; exit 1; }
echo "GREEN transformative motion source truth available"
