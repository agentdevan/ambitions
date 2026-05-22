#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

LOG_ROOT="build/reports/ios26-flagship-sequential"
mkdir -p "$LOG_ROOT"
LOG="$LOG_ROOT/run-$(date -u +%Y%m%dT%H%M%SZ).log"

run_batch() {
  local batch_id="$1"
  local prompt="$2"
  echo "RUNNING $batch_id $prompt" | tee -a "$LOG"
  python3 scripts/ios26-flagship-preflight.py --batch "$batch_id" | tee -a "$LOG"
  scripts/ambitions-codex-train.sh "$batch_id" "$prompt" 2>&1 | tee -a "$LOG"
  local status="${PIPESTATUS[0]}"
  if [[ "$status" -ne 0 ]]; then
    echo "FAILED $batch_id status=$status" | tee -a "$LOG"
    echo "NEXT_FAILED_BATCH=$batch_id" | tee -a "$LOG"
    exit "$status"
  fi
  python3 scripts/ios26-flagship-proof-packet-check.py --batch "$batch_id" | tee -a "$LOG"
}

run_batch IOS26-T00-B01 prompts/batches/IOS26-T00-B01-repo-source-inventory.md
run_batch IOS26-T00-B02 prompts/batches/IOS26-T00-B02-validation-baseline.md
run_batch IOS26-T00-B03 prompts/batches/IOS26-T00-B03-naming-api-drift-inventory.md
run_batch IOS26-T01-B01 prompts/batches/IOS26-T01-B01-toolchain-confirmation.md
run_batch IOS26-T01-B02 prompts/batches/IOS26-T01-B02-deployment-target-bump.md
run_batch IOS26-T01-B03 prompts/batches/IOS26-T01-B03-availability-compatibility-cleanup.md
run_batch IOS26-T02-B00 prompts/batches/IOS26-T02-B00-safe-area-root-invariant.md
run_batch IOS26-T02-B01 prompts/batches/IOS26-T02-B01-native-ios26-shell.md
run_batch IOS26-T02-B02 prompts/batches/IOS26-T02-B02-liquid-glass-token-layer.md
run_batch IOS26-T02-B03 prompts/batches/IOS26-T02-B03-icon-screenshot-foundation.md
run_batch IOS26-T03-B01 prompts/batches/IOS26-T03-B01-runtime-kernel-contracts.md
run_batch IOS26-T03-B02 prompts/batches/IOS26-T03-B02-local-only-proof-harness.md
run_batch IOS26-T03-B03 prompts/batches/IOS26-T03-B03-replayable-decision-traces.md
run_batch IOS26-T04-B01 prompts/batches/IOS26-T04-B01-compiler-input-output-model.md
run_batch IOS26-T04-B02 prompts/batches/IOS26-T04-B02-capacity-aware-compilation.md
run_batch IOS26-T04-B03 prompts/batches/IOS26-T04-B03-compiler-persistence-receipts.md
run_batch IOS26-T04A-B01 prompts/batches/IOS26-T04A-B01-life-context-domain.md
run_batch IOS26-T04A-B02 prompts/batches/IOS26-T04A-B02-historical-catchup-intake.md
run_batch IOS26-T04A-B03 prompts/batches/IOS26-T04A-B03-runtime-effect-proof.md
run_batch IOS26-T04A-B04 prompts/batches/IOS26-T04A-B04-you-controls-receipts.md
run_batch IOS26-T04A-B05 prompts/batches/IOS26-T04A-B05-you-life-context-premium-panel.md
run_batch IOS26-T05-B01 prompts/batches/IOS26-T05-B01-reality-meridian-recomposition.md
run_batch IOS26-T05-B02 prompts/batches/IOS26-T05-B02-closure-still-counts.md
run_batch IOS26-T05-B03 prompts/batches/IOS26-T05-B03-today-explainability-privacy.md
run_batch IOS26-T06-B01 prompts/batches/IOS26-T06-B01-time-plan-seam-retirement.md
run_batch IOS26-T06-B02 prompts/batches/IOS26-T06-B02-lifeshape-field-surface.md
run_batch IOS26-T06-B03 prompts/batches/IOS26-T06-B03-calendar-reality-provider.md
run_batch IOS26-T07-B01 prompts/batches/IOS26-T07-B01-constellation-atlas-root.md
run_batch IOS26-T07-B02 prompts/batches/IOS26-T07-B02-goals-language-drift.md
run_batch IOS26-T07-B03 prompts/batches/IOS26-T07-B03-goal-relationship-proof.md
run_batch IOS26-T08-B01 prompts/batches/IOS26-T08-B01-atmosphere-composer-dominance.md
run_batch IOS26-T08-B02 prompts/batches/IOS26-T08-B02-capture-placement-receipts.md
run_batch IOS26-T08-B03 prompts/batches/IOS26-T08-B03-external-capture-intake.md
run_batch IOS26-T09-B01 prompts/batches/IOS26-T09-B01-runtime-affecting-profile.md
run_batch IOS26-T09-B02 prompts/batches/IOS26-T09-B02-trust-memory-controls.md
run_batch IOS26-T09-B03 prompts/batches/IOS26-T09-B03-export-delete-accessibility-status.md
run_batch IOS26-T10-B01 prompts/batches/IOS26-T10-B01-receipt-lineage-service.md
run_batch IOS26-T10-B02 prompts/batches/IOS26-T10-B02-cross-surface-proof-drawer.md
run_batch IOS26-T10-B03 prompts/batches/IOS26-T10-B03-recovery-replay.md
run_batch IOS26-T11-B01 prompts/batches/IOS26-T11-B01-versioned-migration-foundation.md
run_batch IOS26-T11-B02 prompts/batches/IOS26-T11-B02-export-delete-reset.md
run_batch IOS26-T11-B03 prompts/batches/IOS26-T11-B03-app-group-atomicity.md
run_batch IOS26-T12-B01 prompts/batches/IOS26-T12-B01-widget-live-activity-modernization.md
run_batch IOS26-T12-B02 prompts/batches/IOS26-T12-B02-app-intents-shortcuts-cleanup.md
run_batch IOS26-T12-B03 prompts/batches/IOS26-T12-B03-share-extension-hardening.md
run_batch IOS26-T13-B01 prompts/batches/IOS26-T13-B01-dynamic-type-layouts.md
run_batch IOS26-T13-B02 prompts/batches/IOS26-T13-B02-voiceover-traversal.md
run_batch IOS26-T13-B03 prompts/batches/IOS26-T13-B03-motion-contrast-transparency-assistive-path.md
run_batch IOS26-T14-B01 prompts/batches/IOS26-T14-B01-performance-budgets-scripts.md
run_batch IOS26-T14-B02 prompts/batches/IOS26-T14-B02-ui-effect-optimization.md
run_batch IOS26-T14-B03 prompts/batches/IOS26-T14-B03-runtime-background-efficiency.md
run_batch IOS26-T15-B01 prompts/batches/IOS26-T15-B01-active-docs-front-door.md
run_batch IOS26-T15-B02 prompts/batches/IOS26-T15-B02-historical-quarantine-plan.md
run_batch IOS26-T15-B03 prompts/batches/IOS26-T15-B03-source-naming-final-sweep.md
run_batch IOS26-T16-B01 prompts/batches/IOS26-T16-B01-full-local-validation-packet.md
run_batch IOS26-T16-B02 prompts/batches/IOS26-T16-B02-privacy-app-store-packet.md
run_batch IOS26-T16-B03 prompts/batches/IOS26-T16-B03-signed-archive-testflight-gate.md

echo "GREEN: IOS26 flagship sequence completed" | tee -a "$LOG"
