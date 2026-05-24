#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

LOG_ROOT="build/reports/ios26-flagship-sequential"
mkdir -p "$LOG_ROOT"
LOG="$LOG_ROOT/run-$(date -u +%Y%m%dT%H%M%SZ).log"
REPO_INTELLIGENCE_PREFLIGHT="scripts/ambitions-repo-intelligence-preflight.py"
REPO_INTELLIGENCE_SNAPSHOT="scripts/ambitions-repo-intelligence-snapshot.py"
REPO_INTELLIGENCE_CONTEXT="scripts/ambitions-repo-intelligence-context.py"
REPO_INTELLIGENCE_ENABLED="${REPO_INTELLIGENCE_ENABLED:-1}"
AUTO_BRANCH="${AUTO_BRANCH:-0}"
START_AT="${START_AT:-}"
SKIP_COMPLETED="${SKIP_COMPLETED:-1}"
COMPLETE_THROUGH="${COMPLETE_THROUGH:-}"
DRY_RUN_RESUME="${DRY_RUN_RESUME:-0}"
FORCE_RERUN="${FORCE_RERUN:-0}"
ALLOW_MAIN_COMMIT="${ALLOW_MAIN_COMMIT:-0}"

for required in scripts/ambitions-codex-train.sh scripts/ios26-flagship-preflight.py scripts/ios26-flagship-proof-packet-check.py scripts/ios26-execution-state-reconcile.py docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml; do
  if [[ ! -f "$required" ]]; then
    echo "RED: required IOS26 runner dependency missing: $required" | tee -a "$LOG"
    exit 1
  fi
done

if [[ "${AUTO_COMMIT:-1}" == "1" && "$(git rev-parse --abbrev-ref HEAD)" == "main" && "$ALLOW_MAIN_COMMIT" != "1" ]]; then
  echo "YELLOW: AUTO_COMMIT=1 on main requires ALLOW_MAIN_COMMIT=1 for autonomous main commits; runner will still invoke the batch runner, which may stop at its own commit gate." | tee -a "$LOG"
fi

emit_resume_plan() {
  local args=(--runner-plan)
  if [[ "$FORCE_RERUN" != "1" && "$SKIP_COMPLETED" == "1" ]]; then
    args+=(--skip-completed)
  fi
  if [[ -n "$START_AT" ]]; then
    args+=(--start-at "$START_AT")
  elif [[ -n "$COMPLETE_THROUGH" ]]; then
    args+=(--complete-through "$COMPLETE_THROUGH")
  fi
  python3 scripts/ios26-execution-state-reconcile.py "${args[@]}"
}

RESUME_PLAN="$(emit_resume_plan)"
printf "%s\n" "$RESUME_PLAN" | tee -a "$LOG"
NEXT_RUN_BATCH="$(printf "%s\n" "$RESUME_PLAN" | awk -F "\t" '/^NEXT_RUN_BATCH\t/ {print $2; exit}')"
if [[ -z "$NEXT_RUN_BATCH" ]]; then
  echo "RED: resume plan did not emit NEXT_RUN_BATCH" | tee -a "$LOG"
  echo "NEXT_FAILED_BATCH=RESUME_PLAN" | tee -a "$LOG"
  exit 1
fi
echo "NEXT_RUN_BATCH=$NEXT_RUN_BATCH" | tee -a "$LOG"
if [[ "$DRY_RUN_RESUME" == "1" ]]; then
  mkdir -p build/reports/ios26-execution-state
  printf "%s\n" "$RESUME_PLAN" > build/reports/ios26-execution-state/resume-dry-run.md
  echo "GREEN: IOS26 resume dry run completed" | tee -a "$LOG"
  exit 0
fi
if [[ "$NEXT_RUN_BATCH" == "COMPLETE" ]]; then
  echo "GREEN: IOS26 resume plan has no runnable batches" | tee -a "$LOG"
  exit 0
fi

repo_intelligence_sequence_preflight() {
  if [[ "$REPO_INTELLIGENCE_ENABLED" != "1" || ! -f "$REPO_INTELLIGENCE_PREFLIGHT" ]]; then
    echo "YELLOW: repo-intelligence preflight unavailable or disabled; continuing with existing IOS26 gates" | tee -a "$LOG"
    return 0
  fi
  python3 "$REPO_INTELLIGENCE_PREFLIGHT" --json 2>&1 | tee -a "$LOG"
  local status=${PIPESTATUS[0]}
  case "$status" in
    0)
      echo "GREEN: repo-intelligence sequence preflight" | tee -a "$LOG"
      ;;
    2)
      echo "YELLOW: optional repo-intelligence tools unavailable; continuing with fallback" | tee -a "$LOG"
      ;;
    *)
      echo "RED: repo-intelligence hygiene preflight failed status=$status" | tee -a "$LOG"
      exit "$status"
      ;;
  esac
}

repo_intelligence_batch_snapshot() {
  local batch_id="$1"
  local phase="$2"
  if [[ "$REPO_INTELLIGENCE_ENABLED" != "1" || ! -f "$REPO_INTELLIGENCE_SNAPSHOT" ]]; then
    echo "YELLOW: repo-intelligence snapshot unavailable or disabled for $batch_id phase=$phase" | tee -a "$LOG"
    return 0
  fi
  python3 "$REPO_INTELLIGENCE_SNAPSHOT" --batch "$batch_id" --phase "$phase" --status GREEN 2>&1 | tee -a "$LOG"
  local status=${PIPESTATUS[0]}
  if [[ "$status" -ne 0 ]]; then
    echo "RED: repo-intelligence snapshot failed for $batch_id phase=$phase status=$status" | tee -a "$LOG"
    echo "NEXT_FAILED_BATCH=$batch_id" | tee -a "$LOG"
    exit "$status"
  fi
}

repo_intelligence_batch_context() {
  local batch_id="$1"
  local prompt="$2"
  if [[ "$REPO_INTELLIGENCE_ENABLED" != "1" || ! -f "$REPO_INTELLIGENCE_CONTEXT" ]]; then
    echo "YELLOW: repo-intelligence context unavailable or disabled for $batch_id; continuing with direct repo search/read fallback" | tee -a "$LOG"
    return 0
  fi
  local context_path
  set +e
  context_path="$(python3 "$REPO_INTELLIGENCE_CONTEXT" --batch "$batch_id" --prompt "$prompt" --print-path 2>&1)"
  local status=$?
  set -e
  printf "%s\n" "$context_path" | tee -a "$LOG"
  if [[ "$status" -ne 0 ]]; then
    echo "YELLOW: repo-intelligence context generation failed for $batch_id status=$status; continuing with direct repo search/read fallback" | tee -a "$LOG"
    return 0
  fi
  AMBITIONS_REPO_INTELLIGENCE_CONTEXT="$context_path"
  export AMBITIONS_REPO_INTELLIGENCE_CONTEXT
  echo "GREEN: repo-intelligence context ready for $batch_id: $AMBITIONS_REPO_INTELLIGENCE_CONTEXT" | tee -a "$LOG"
}

run_batch() {
  local batch_id="$1"
  local prompt="$2"
  if [[ "$batch_id" != "$NEXT_RUN_BATCH" && "$STARTED_RESUME" != "1" ]]; then
    return 0
  fi
  STARTED_RESUME="1"
  echo "RUNNING $batch_id $prompt" | tee -a "$LOG"
  repo_intelligence_batch_snapshot "$batch_id" "pre"
  repo_intelligence_batch_context "$batch_id" "$prompt"
  python3 scripts/ios26-flagship-preflight.py --batch "$batch_id" 2>&1 | tee -a "$LOG"
  local preflight_status=${PIPESTATUS[0]}
  if [[ "$preflight_status" -ne 0 ]]; then
    echo "FAILED preflight $batch_id status=$preflight_status" | tee -a "$LOG"
    echo "NEXT_FAILED_BATCH=$batch_id" | tee -a "$LOG"
    exit "$preflight_status"
  fi
  AUTO_BRANCH="$AUTO_BRANCH" ALLOW_MAIN_COMMIT="$ALLOW_MAIN_COMMIT" scripts/ambitions-codex-train.sh "$batch_id" "$prompt" 2>&1 | tee -a "$LOG"
  local runner_status=${PIPESTATUS[0]}
  if [[ "$runner_status" -ne 0 ]]; then
    echo "FAILED runner $batch_id status=$runner_status" | tee -a "$LOG"
    echo "NEXT_FAILED_BATCH=$batch_id" | tee -a "$LOG"
    exit "$runner_status"
  fi
  python3 scripts/ios26-flagship-proof-packet-check.py --batch "$batch_id" 2>&1 | tee -a "$LOG"
  local proof_status=${PIPESTATUS[0]}
  if [[ "$proof_status" -ne 0 ]]; then
    echo "FAILED proof-packet $batch_id status=$proof_status" | tee -a "$LOG"
    echo "NEXT_FAILED_BATCH=$batch_id" | tee -a "$LOG"
    exit "$proof_status"
  fi
  repo_intelligence_batch_snapshot "$batch_id" "post"
}

repo_intelligence_sequence_preflight
STARTED_RESUME="0"

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
run_batch IOS26-T03-B01 prompts/batches/IOS26-T03-B01-broad-suite-yellow-repair.md
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
run_batch IOS26-T04A-B06 prompts/batches/IOS26-T04A-B06-anti-bucket-factor-ledger-proof.md
run_batch IOS26-T04B-B01 prompts/batches/IOS26-T04B-B01-step-candidate-field.md
run_batch IOS26-T04B-B02 prompts/batches/IOS26-T04B-B02-rejection-reasoning-loop.md
run_batch IOS26-T04B-B03 prompts/batches/IOS26-T04B-B03-deadline-simulation-engine.md
run_batch IOS26-T04B-B04 prompts/batches/IOS26-T04B-B04-approval-receipts-learning.md
run_batch IOS26-T04B-B05 prompts/batches/IOS26-T04B-B05-exhaustive-simulation-gauntlet.md
run_batch IOS26-T04B-B06 prompts/batches/IOS26-T04B-B06-today-optionality-ui.md
run_batch IOS26-T04C-B01 prompts/batches/IOS26-T04C-B01-source-atlas-match-and-pack-selection.md
run_batch IOS26-T04C-B02 prompts/batches/IOS26-T04C-B02-capability-graph-to-path-composition.md
run_batch IOS26-T04C-B03 prompts/batches/IOS26-T04C-B03-path-to-step-candidate-expansion.md
run_batch IOS26-T04C-B04 prompts/batches/IOS26-T04C-B04-runtime-compiler-receipts-replay.md
run_batch IOS26-T04C-B05 prompts/batches/IOS26-T04C-B05-source-atlas-coverage-gauntlet.md
run_batch IOS26-T04C-B06 prompts/batches/IOS26-T04C-B06-source-atlas-you-inspection-surface.md
run_batch IOS26-T04D-B01 prompts/batches/IOS26-T04D-B01-capture-semantic-extraction.md
run_batch IOS26-T04D-B02 prompts/batches/IOS26-T04D-B02-goal-relevance-scanner.md
run_batch IOS26-T04D-B03 prompts/batches/IOS26-T04D-B03-plan-insertion-approval.md
run_batch IOS26-T04D-B04 prompts/batches/IOS26-T04D-B04-future-proof-context-storage.md
run_batch IOS26-T04D-B05 prompts/batches/IOS26-T04D-B05-receipts-replay-corrections.md
run_batch IOS26-T04D-B06 prompts/batches/IOS26-T04D-B06-capture-runtime-gauntlet.md
run_batch IOS26-T04D-B07 prompts/batches/IOS26-T04D-B07-capture-ui-review-surface.md
run_batch IOS26-T04E-B01 prompts/batches/IOS26-T04E-B01-calendar-p0-contract-harness.md
run_batch IOS26-T04E-B02 prompts/batches/IOS26-T04E-B02-reminders-p0-contract-harness.md
run_batch IOS26-T04E-B03 prompts/batches/IOS26-T04E-B03-todoist-p0-contract-harness.md
run_batch IOS26-T04E-B04 prompts/batches/IOS26-T04E-B04-things-p0-contract-harness.md
run_batch IOS26-T04E-B05 prompts/batches/IOS26-T04E-B05-notion-p0-contract-harness.md
run_batch IOS26-T04E-B06 prompts/batches/IOS26-T04E-B06-cross-app-journey-contract-harness.md
run_batch IOS26-T04E-B07 prompts/batches/IOS26-T04E-B07-contract-closeout-and-downstream-gates.md
run_batch IOS26-T04F-B01 prompts/batches/IOS26-T04F-B01-local-schedule-models-and-repositories.md
run_batch IOS26-T04F-B02 prompts/batches/IOS26-T04F-B02-eventkit-mirror-and-permission-boundary.md
run_batch IOS26-T04F-B03 prompts/batches/IOS26-T04F-B03-recurrence-availability-and-free-time-engine.md
run_batch IOS26-T04F-B04 prompts/batches/IOS26-T04F-B04-conflict-pressure-protected-time-engine.md
run_batch IOS26-T04F-B05 prompts/batches/IOS26-T04F-B05-schedule-mutation-receipts-and-replay.md
run_batch IOS26-T04F-B06 prompts/batches/IOS26-T04F-B06-calendar-replacement-gauntlet.md
run_batch IOS26-T04G-B01 prompts/batches/IOS26-T04G-B01-reminder-trigger-models-and-repositories.md
run_batch IOS26-T04G-B02 prompts/batches/IOS26-T04G-B02-local-notification-scheduling-abstraction.md
run_batch IOS26-T04G-B03 prompts/batches/IOS26-T04G-B03-natural-reminder-capture-parser.md
run_batch IOS26-T04G-B04 prompts/batches/IOS26-T04G-B04-recurring-reminders-and-followups.md
run_batch IOS26-T04G-B05 prompts/batches/IOS26-T04G-B05-reminder-closure-recovery-receipts.md
run_batch IOS26-T04G-B06 prompts/batches/IOS26-T04G-B06-reminders-replacement-gauntlet.md
run_batch IOS26-T04H-B01 prompts/batches/IOS26-T04H-B01-goal-thread-project-commitment-hierarchy.md
run_batch IOS26-T04H-B02 prompts/batches/IOS26-T04H-B02-step-dependencies-deadlines-priority-without-scores.md
run_batch IOS26-T04H-B03 prompts/batches/IOS26-T04H-B03-labels-filters-and-saved-views.md
run_batch IOS26-T04H-B04 prompts/batches/IOS26-T04H-B04-today-upcoming-open-held-view-engine.md
run_batch IOS26-T04H-B05 prompts/batches/IOS26-T04H-B05-bulk-operations-and-low-friction-planning.md
run_batch IOS26-T04H-B06 prompts/batches/IOS26-T04H-B06-project-step-closure-proof-replay.md
run_batch IOS26-T04H-B07 prompts/batches/IOS26-T04H-B07-todoist-things-replacement-gauntlet.md
run_batch IOS26-T04I-B01 prompts/batches/IOS26-T04I-B01-context-entry-collection-template-models.md
run_batch IOS26-T04I-B02 prompts/batches/IOS26-T04I-B02-attachments-links-and-source-records.md
run_batch IOS26-T04I-B03 prompts/batches/IOS26-T04I-B03-relations-backlinks-and-life-knowledge-graph.md
run_batch IOS26-T04I-B04 prompts/batches/IOS26-T04I-B04-local-knowledge-search-and-filters.md
run_batch IOS26-T04I-B05 prompts/batches/IOS26-T04I-B05-knowledge-to-runtime-source-bridge.md
run_batch IOS26-T04I-B06 prompts/batches/IOS26-T04I-B06-notion-replacement-gauntlet.md
run_batch IOS26-T04J-B01 prompts/batches/IOS26-T04J-B01-universal-quick-capture-router.md
run_batch IOS26-T04J-B02 prompts/batches/IOS26-T04J-B02-object-action-engine.md
run_batch IOS26-T04J-B03 prompts/batches/IOS26-T04J-B03-everything-search.md
run_batch IOS26-T04J-B04 prompts/batches/IOS26-T04J-B04-native-command-surface-without-chat.md
run_batch IOS26-T04J-B05 prompts/batches/IOS26-T04J-B05-onboarding-empty-states-and-obviousness.md
run_batch IOS26-T04J-B06 prompts/batches/IOS26-T04J-B06-command-search-obviousness-gauntlet.md
run_batch IOS26-T04K-B01 prompts/batches/IOS26-T04K-B01-foundation-source-adapters.md
run_batch IOS26-T04K-B02 prompts/batches/IOS26-T04K-B02-multi-path-execution-compiler-over-real-life-objects.md
run_batch IOS26-T04K-B03 prompts/batches/IOS26-T04K-B03-accomplishment-proof-adaptation-engine.md
run_batch IOS26-T04K-B04 prompts/batches/IOS26-T04K-B04-personal-operating-model-and-what-ambitions-knows.md
run_batch IOS26-T04K-B05 prompts/batches/IOS26-T04K-B05-start-here-decision-contract-for-t05.md
run_batch IOS26-T04K-B06 prompts/batches/IOS26-T04K-B06-cross-surface-private-life-runtime-gauntlet.md
run_batch IOS26-T04K-B07 prompts/batches/IOS26-T04K-B07-foundation-and-moat-closeout.md
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
repo_intelligence_batch_snapshot "IOS26-SEQUENCE" "sequence-end"
