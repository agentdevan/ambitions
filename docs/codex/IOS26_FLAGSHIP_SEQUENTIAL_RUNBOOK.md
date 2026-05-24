# iOS 26 Flagship Sequential Runbook

Status: installed_not_run. Supporting note: this file supports current Ambitions work but does not override `docs/truth/`.

IOS26 now runs as a three-pass operating model:

1. Plan-freeze: `python3 scripts/ios26-plan-freeze.py`
2. Frozen implementation: `scripts/ios26-flagship-run-sequential.sh`
3. Review/compile/proof sweep: `python3 scripts/ios26-review-sweep.py`

Do not run the implementation pass until the plan-freeze artifacts and prompt hashes are current.

## Plan-Freeze Command

```bash
python3 scripts/ios26-plan-freeze.py
python3 scripts/ios26-generate-sequential-runner.py
python3 scripts/ios26-prompt-freeze-check.py --write
```

## Frozen Implementation Command

```bash
scripts/ios26-flagship-run-sequential.sh
```

For `IOS26-*` batches with prompt freeze hashes, `scripts/ambitions-codex-train.sh` replaces strategic Phase 01 replanning with Boundary Verification. Phase 02 may implement only the sealed work order. Phase 03 reviews actual diff, validation, proof, and no-claim boundaries. Repair remains allowed only inside the sealed boundary.

## Review Sweep Command

```bash
python3 scripts/ios26-review-sweep.py
```

## Replan Escape Hatch

Use `IOS26_REPLAN_ALLOWED=1` only when explicitly authorized to replan and refreeze an IOS26 prompt. After replanning, rerun the plan-freeze, generated-runner, and prompt-freeze commands.

## Prompt Freeze Hashes

Frozen hashes live at `docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json`. Frozen implementation fails when a prompt hash differs unless `IOS26_REPLAN_ALLOWED=1`.

## Generated Sequential Runner

`scripts/ios26-flagship-run-sequential.sh` is generated from `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`; do not hand-maintain batch lines. The generated runner calls:

```bash
python3 scripts/ios26-flagship-preflight.py --batch "$batch_id"
scripts/ambitions-codex-train.sh "$batch_id" "$prompt"
python3 scripts/ios26-flagship-proof-packet-check.py --batch "$batch_id"
```

## Stop Rules

- Stop on Red.
- Never skip Train 0.
- Do not run source-changing trains until Train 0 baseline artifacts exist.
- Do not weaken `stop_on_red`.
- Continue on Yellow only with owner, reason, no-claim boundary, follow-up gate, and affected files.

## Proof Expectations

Proof is written under the manifest proof roots plus `build/reports/ios26-flagship-sequential/`, `build/reports/ios26-planning/`, and `build/reports/ios26-review-sweep/`. Simulator/local proof is not release, TestFlight, App Store, device, public accessibility, performance, privacy/legal, or CI proof.

## No-Claim Boundaries

Do not claim release readiness, TestFlight readiness, App Store readiness, accessibility verification, performance validation, privacy/legal approval, Private Life Runtime moat completion, or implementation completion without current source, test, and proof evidence.

## Full Sequence

```bash
scripts/ambitions-codex-train.sh IOS26-T00-B01 prompts/batches/IOS26-T00-B01-repo-source-inventory.md
scripts/ambitions-codex-train.sh IOS26-T00-B02 prompts/batches/IOS26-T00-B02-validation-baseline.md
scripts/ambitions-codex-train.sh IOS26-T00-B03 prompts/batches/IOS26-T00-B03-naming-api-drift-inventory.md
scripts/ambitions-codex-train.sh IOS26-T01-B01 prompts/batches/IOS26-T01-B01-toolchain-confirmation.md
scripts/ambitions-codex-train.sh IOS26-T01-B02 prompts/batches/IOS26-T01-B02-deployment-target-bump.md
scripts/ambitions-codex-train.sh IOS26-T01-B03 prompts/batches/IOS26-T01-B03-availability-compatibility-cleanup.md
scripts/ambitions-codex-train.sh IOS26-T02-B00 prompts/batches/IOS26-T02-B00-safe-area-root-invariant.md
scripts/ambitions-codex-train.sh IOS26-T02-B01 prompts/batches/IOS26-T02-B01-native-ios26-shell.md
scripts/ambitions-codex-train.sh IOS26-T02-B02 prompts/batches/IOS26-T02-B02-liquid-glass-token-layer.md
scripts/ambitions-codex-train.sh IOS26-T02-B03 prompts/batches/IOS26-T02-B03-icon-screenshot-foundation.md
scripts/ambitions-codex-train.sh IOS26-T03-B01 prompts/batches/IOS26-T03-B01-broad-suite-yellow-repair.md
scripts/ambitions-codex-train.sh IOS26-T03-B02 prompts/batches/IOS26-T03-B02-local-only-proof-harness.md
scripts/ambitions-codex-train.sh IOS26-T03-B03 prompts/batches/IOS26-T03-B03-replayable-decision-traces.md
scripts/ambitions-codex-train.sh IOS26-T04-B01 prompts/batches/IOS26-T04-B01-compiler-input-output-model.md
scripts/ambitions-codex-train.sh IOS26-T04-B02 prompts/batches/IOS26-T04-B02-capacity-aware-compilation.md
scripts/ambitions-codex-train.sh IOS26-T04-B03 prompts/batches/IOS26-T04-B03-compiler-persistence-receipts.md
scripts/ambitions-codex-train.sh IOS26-T04A-B01 prompts/batches/IOS26-T04A-B01-life-context-domain.md
scripts/ambitions-codex-train.sh IOS26-T04A-B02 prompts/batches/IOS26-T04A-B02-historical-catchup-intake.md
scripts/ambitions-codex-train.sh IOS26-T04A-B03 prompts/batches/IOS26-T04A-B03-runtime-effect-proof.md
scripts/ambitions-codex-train.sh IOS26-T04A-B04 prompts/batches/IOS26-T04A-B04-you-controls-receipts.md
scripts/ambitions-codex-train.sh IOS26-T04A-B05 prompts/batches/IOS26-T04A-B05-you-life-context-premium-panel.md
scripts/ambitions-codex-train.sh IOS26-T04A-B06 prompts/batches/IOS26-T04A-B06-anti-bucket-factor-ledger-proof.md
scripts/ambitions-codex-train.sh IOS26-T04B-B01 prompts/batches/IOS26-T04B-B01-step-candidate-field.md
scripts/ambitions-codex-train.sh IOS26-T04B-B02 prompts/batches/IOS26-T04B-B02-rejection-reasoning-loop.md
scripts/ambitions-codex-train.sh IOS26-T04B-B03 prompts/batches/IOS26-T04B-B03-deadline-simulation-engine.md
scripts/ambitions-codex-train.sh IOS26-T04B-B04 prompts/batches/IOS26-T04B-B04-approval-receipts-learning.md
scripts/ambitions-codex-train.sh IOS26-T04B-B05 prompts/batches/IOS26-T04B-B05-exhaustive-simulation-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04B-B06 prompts/batches/IOS26-T04B-B06-today-optionality-ui.md
scripts/ambitions-codex-train.sh IOS26-T04C-B01 prompts/batches/IOS26-T04C-B01-source-atlas-match-and-pack-selection.md
scripts/ambitions-codex-train.sh IOS26-T04C-B02 prompts/batches/IOS26-T04C-B02-capability-graph-to-path-composition.md
scripts/ambitions-codex-train.sh IOS26-T04C-B03 prompts/batches/IOS26-T04C-B03-path-to-step-candidate-expansion.md
scripts/ambitions-codex-train.sh IOS26-T04C-B04 prompts/batches/IOS26-T04C-B04-runtime-compiler-receipts-replay.md
scripts/ambitions-codex-train.sh IOS26-T04C-B05 prompts/batches/IOS26-T04C-B05-source-atlas-coverage-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04C-B06 prompts/batches/IOS26-T04C-B06-source-atlas-you-inspection-surface.md
scripts/ambitions-codex-train.sh IOS26-T04D-B01 prompts/batches/IOS26-T04D-B01-capture-semantic-extraction.md
scripts/ambitions-codex-train.sh IOS26-T04D-B02 prompts/batches/IOS26-T04D-B02-goal-relevance-scanner.md
scripts/ambitions-codex-train.sh IOS26-T04D-B03 prompts/batches/IOS26-T04D-B03-plan-insertion-approval.md
scripts/ambitions-codex-train.sh IOS26-T04D-B04 prompts/batches/IOS26-T04D-B04-future-proof-context-storage.md
scripts/ambitions-codex-train.sh IOS26-T04D-B05 prompts/batches/IOS26-T04D-B05-receipts-replay-corrections.md
scripts/ambitions-codex-train.sh IOS26-T04D-B06 prompts/batches/IOS26-T04D-B06-capture-runtime-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04D-B07 prompts/batches/IOS26-T04D-B07-capture-ui-review-surface.md
scripts/ambitions-codex-train.sh IOS26-T04E-B01 prompts/batches/IOS26-T04E-B01-calendar-p0-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B02 prompts/batches/IOS26-T04E-B02-reminders-p0-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B03 prompts/batches/IOS26-T04E-B03-todoist-p0-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B04 prompts/batches/IOS26-T04E-B04-things-p0-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B05 prompts/batches/IOS26-T04E-B05-notion-p0-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B06 prompts/batches/IOS26-T04E-B06-cross-app-journey-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B07 prompts/batches/IOS26-T04E-B07-contract-closeout-and-downstream-gates.md
scripts/ambitions-codex-train.sh IOS26-T04F-B01 prompts/batches/IOS26-T04F-B01-local-schedule-models-and-repositories.md
scripts/ambitions-codex-train.sh IOS26-T04F-B02 prompts/batches/IOS26-T04F-B02-eventkit-mirror-and-permission-boundary.md
scripts/ambitions-codex-train.sh IOS26-T04F-B03 prompts/batches/IOS26-T04F-B03-recurrence-availability-and-free-time-engine.md
scripts/ambitions-codex-train.sh IOS26-T04F-B04 prompts/batches/IOS26-T04F-B04-conflict-pressure-protected-time-engine.md
scripts/ambitions-codex-train.sh IOS26-T04F-B05 prompts/batches/IOS26-T04F-B05-schedule-mutation-receipts-and-replay.md
scripts/ambitions-codex-train.sh IOS26-T04F-B06 prompts/batches/IOS26-T04F-B06-calendar-replacement-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04G-B01 prompts/batches/IOS26-T04G-B01-reminder-trigger-models-and-repositories.md
scripts/ambitions-codex-train.sh IOS26-T04G-B02 prompts/batches/IOS26-T04G-B02-local-notification-scheduling-abstraction.md
scripts/ambitions-codex-train.sh IOS26-T04G-B03 prompts/batches/IOS26-T04G-B03-natural-reminder-capture-parser.md
scripts/ambitions-codex-train.sh IOS26-T04G-B04 prompts/batches/IOS26-T04G-B04-recurring-reminders-and-followups.md
scripts/ambitions-codex-train.sh IOS26-T04G-B05 prompts/batches/IOS26-T04G-B05-reminder-closure-recovery-receipts.md
scripts/ambitions-codex-train.sh IOS26-T04G-B06 prompts/batches/IOS26-T04G-B06-reminders-replacement-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04H-B01 prompts/batches/IOS26-T04H-B01-goal-thread-project-commitment-hierarchy.md
scripts/ambitions-codex-train.sh IOS26-T04H-B02 prompts/batches/IOS26-T04H-B02-step-dependencies-deadlines-priority-without-scores.md
scripts/ambitions-codex-train.sh IOS26-T04H-B03 prompts/batches/IOS26-T04H-B03-labels-filters-and-saved-views.md
scripts/ambitions-codex-train.sh IOS26-T04H-B04 prompts/batches/IOS26-T04H-B04-today-upcoming-open-held-view-engine.md
scripts/ambitions-codex-train.sh IOS26-T04H-B05 prompts/batches/IOS26-T04H-B05-bulk-operations-and-low-friction-planning.md
scripts/ambitions-codex-train.sh IOS26-T04H-B06 prompts/batches/IOS26-T04H-B06-project-step-closure-proof-replay.md
scripts/ambitions-codex-train.sh IOS26-T04H-B07 prompts/batches/IOS26-T04H-B07-todoist-things-replacement-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04I-B01 prompts/batches/IOS26-T04I-B01-context-entry-collection-template-models.md
scripts/ambitions-codex-train.sh IOS26-T04I-B02 prompts/batches/IOS26-T04I-B02-attachments-links-and-source-records.md
scripts/ambitions-codex-train.sh IOS26-T04I-B03 prompts/batches/IOS26-T04I-B03-relations-backlinks-and-life-knowledge-graph.md
scripts/ambitions-codex-train.sh IOS26-T04I-B04 prompts/batches/IOS26-T04I-B04-local-knowledge-search-and-filters.md
scripts/ambitions-codex-train.sh IOS26-T04I-B05 prompts/batches/IOS26-T04I-B05-knowledge-to-runtime-source-bridge.md
scripts/ambitions-codex-train.sh IOS26-T04I-B06 prompts/batches/IOS26-T04I-B06-notion-replacement-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04J-B01 prompts/batches/IOS26-T04J-B01-universal-quick-capture-router.md
scripts/ambitions-codex-train.sh IOS26-T04J-B02 prompts/batches/IOS26-T04J-B02-object-action-engine.md
scripts/ambitions-codex-train.sh IOS26-T04J-B03 prompts/batches/IOS26-T04J-B03-everything-search.md
scripts/ambitions-codex-train.sh IOS26-T04J-B04 prompts/batches/IOS26-T04J-B04-native-command-surface-without-chat.md
scripts/ambitions-codex-train.sh IOS26-T04J-B05 prompts/batches/IOS26-T04J-B05-onboarding-empty-states-and-obviousness.md
scripts/ambitions-codex-train.sh IOS26-T04J-B06 prompts/batches/IOS26-T04J-B06-command-search-obviousness-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04K-B01 prompts/batches/IOS26-T04K-B01-foundation-source-adapters.md
scripts/ambitions-codex-train.sh IOS26-T04K-B02 prompts/batches/IOS26-T04K-B02-multi-path-execution-compiler-over-real-life-objects.md
scripts/ambitions-codex-train.sh IOS26-T04K-B03 prompts/batches/IOS26-T04K-B03-accomplishment-proof-adaptation-engine.md
scripts/ambitions-codex-train.sh IOS26-T04K-B04 prompts/batches/IOS26-T04K-B04-personal-operating-model-and-what-ambitions-knows.md
scripts/ambitions-codex-train.sh IOS26-T04K-B05 prompts/batches/IOS26-T04K-B05-start-here-decision-contract-for-t05.md
scripts/ambitions-codex-train.sh IOS26-T04K-B06 prompts/batches/IOS26-T04K-B06-cross-surface-private-life-runtime-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04K-B07 prompts/batches/IOS26-T04K-B07-foundation-and-moat-closeout.md
scripts/ambitions-codex-train.sh IOS26-T05-B01 prompts/batches/IOS26-T05-B01-reality-meridian-recomposition.md
scripts/ambitions-codex-train.sh IOS26-T05-B02 prompts/batches/IOS26-T05-B02-closure-still-counts.md
scripts/ambitions-codex-train.sh IOS26-T05-B03 prompts/batches/IOS26-T05-B03-today-explainability-privacy.md
scripts/ambitions-codex-train.sh IOS26-T06-B01 prompts/batches/IOS26-T06-B01-time-plan-seam-retirement.md
scripts/ambitions-codex-train.sh IOS26-T06-B02 prompts/batches/IOS26-T06-B02-lifeshape-field-surface.md
scripts/ambitions-codex-train.sh IOS26-T06-B03 prompts/batches/IOS26-T06-B03-calendar-reality-provider.md
scripts/ambitions-codex-train.sh IOS26-T07-B01 prompts/batches/IOS26-T07-B01-constellation-atlas-root.md
scripts/ambitions-codex-train.sh IOS26-T07-B02 prompts/batches/IOS26-T07-B02-goals-language-drift.md
scripts/ambitions-codex-train.sh IOS26-T07-B03 prompts/batches/IOS26-T07-B03-goal-relationship-proof.md
scripts/ambitions-codex-train.sh IOS26-T08-B01 prompts/batches/IOS26-T08-B01-atmosphere-composer-dominance.md
scripts/ambitions-codex-train.sh IOS26-T08-B02 prompts/batches/IOS26-T08-B02-capture-placement-receipts.md
scripts/ambitions-codex-train.sh IOS26-T08-B03 prompts/batches/IOS26-T08-B03-external-capture-intake.md
scripts/ambitions-codex-train.sh IOS26-T09-B01 prompts/batches/IOS26-T09-B01-runtime-affecting-profile.md
scripts/ambitions-codex-train.sh IOS26-T09-B02 prompts/batches/IOS26-T09-B02-trust-memory-controls.md
scripts/ambitions-codex-train.sh IOS26-T09-B03 prompts/batches/IOS26-T09-B03-export-delete-accessibility-status.md
scripts/ambitions-codex-train.sh IOS26-T10-B01 prompts/batches/IOS26-T10-B01-receipt-lineage-service.md
scripts/ambitions-codex-train.sh IOS26-T10-B02 prompts/batches/IOS26-T10-B02-cross-surface-proof-drawer.md
scripts/ambitions-codex-train.sh IOS26-T10-B03 prompts/batches/IOS26-T10-B03-recovery-replay.md
scripts/ambitions-codex-train.sh IOS26-T11-B01 prompts/batches/IOS26-T11-B01-versioned-migration-foundation.md
scripts/ambitions-codex-train.sh IOS26-T11-B02 prompts/batches/IOS26-T11-B02-export-delete-reset.md
scripts/ambitions-codex-train.sh IOS26-T11-B03 prompts/batches/IOS26-T11-B03-app-group-atomicity.md
scripts/ambitions-codex-train.sh IOS26-T12-B01 prompts/batches/IOS26-T12-B01-widget-live-activity-modernization.md
scripts/ambitions-codex-train.sh IOS26-T12-B02 prompts/batches/IOS26-T12-B02-app-intents-shortcuts-cleanup.md
scripts/ambitions-codex-train.sh IOS26-T12-B03 prompts/batches/IOS26-T12-B03-share-extension-hardening.md
scripts/ambitions-codex-train.sh IOS26-T13-B01 prompts/batches/IOS26-T13-B01-dynamic-type-layouts.md
scripts/ambitions-codex-train.sh IOS26-T13-B02 prompts/batches/IOS26-T13-B02-voiceover-traversal.md
scripts/ambitions-codex-train.sh IOS26-T13-B03 prompts/batches/IOS26-T13-B03-motion-contrast-transparency-assistive-path.md
scripts/ambitions-codex-train.sh IOS26-T14-B01 prompts/batches/IOS26-T14-B01-performance-budgets-scripts.md
scripts/ambitions-codex-train.sh IOS26-T14-B02 prompts/batches/IOS26-T14-B02-ui-effect-optimization.md
scripts/ambitions-codex-train.sh IOS26-T14-B03 prompts/batches/IOS26-T14-B03-runtime-background-efficiency.md
scripts/ambitions-codex-train.sh IOS26-T15-B01 prompts/batches/IOS26-T15-B01-active-docs-front-door.md
scripts/ambitions-codex-train.sh IOS26-T15-B02 prompts/batches/IOS26-T15-B02-historical-quarantine-plan.md
scripts/ambitions-codex-train.sh IOS26-T15-B03 prompts/batches/IOS26-T15-B03-source-naming-final-sweep.md
scripts/ambitions-codex-train.sh IOS26-T16-B01 prompts/batches/IOS26-T16-B01-full-local-validation-packet.md
scripts/ambitions-codex-train.sh IOS26-T16-B02 prompts/batches/IOS26-T16-B02-privacy-app-store-packet.md
scripts/ambitions-codex-train.sh IOS26-T16-B03 prompts/batches/IOS26-T16-B03-signed-archive-testflight-gate.md
```

## Optional Autonomous Loop

The optional sequential script is `scripts/ios26-flagship-run-sequential.sh`. It uses the generated manifest order, stops on the first nonzero exit, writes logs under `build/reports/ios26-flagship-sequential/`, and does not auto-push, auto-release, sign, upload, or bypass the runner.
