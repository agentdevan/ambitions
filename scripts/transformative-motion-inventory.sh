#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "transformative-motion-inventory"
rg -n "CaptureToReceiptMorph|HeroToSessionExpansion|RailRowToStepDetailTransition|PlanBlockToTodayTransition|GoalLaneFocusTransition|EvidenceToRecallBloom|ReceiptStackSettle|OverloadToRecoveryCollapse|ProofPulseSettle|QuietCommandFocus" docs/canon docs/codex .codex Native/Ambitions Sources 2>/dev/null || true
echo "GREEN transformative motion inventory complete"
