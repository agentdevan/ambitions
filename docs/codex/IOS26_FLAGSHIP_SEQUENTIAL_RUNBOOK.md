# iOS 26 Flagship Sequential Runbook

Status: installed_not_run. Required runner command: `scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>`.

This is the current runnable global batch train under `docs/codex/GLOBAL_BATCH_SEQUENCE.md` and `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`. Non-`IOS26-*` batch IDs are historical for Codex global train selection.

Run batches in Train 0 through Train 16 order. Stop on Red. Continue on Green. Continue on Yellow only with explicit reason, owner, no-claim boundary, and post-batch gate. Never skip Train 0. Do not run source-changing trains until Train 0 baseline artifacts exist. Do not run iOS 26 target bump until toolchain proof exists. Do not run release trains until build/test/accessibility/performance/privacy proof exists. Never treat docs-only installation as app implementation.

## Installed Tooling

Run the train preflight before starting or resuming IOS26 work:

```bash
python3 scripts/ios26-flagship-preflight.py
```

Run the proof packet shape check after each batch or before continuing through an accepted Yellow:

```bash
python3 scripts/ios26-flagship-proof-packet-check.py --batch <BATCH_ID>
```

Generate the local iOS 26 API verification ledger before Train 1 and before any API adoption:

```bash
python3 scripts/ios26-api-ledger-check.py --write
```

The optional sequential runner is installed but must be invoked explicitly:

```bash
scripts/ios26-flagship-run-sequential.sh
```

`ambitionsProof` is the preferred local MCP for allowlisted validation commands. `xcodebuildmcp` is configured for simulator workflows through `.xcodebuildmcp/config.yaml`; device, signing, App Store, hosted CI, and upload automation remain out of scope.

After changing MCP config or XcodeBuildMCP defaults, restart Codex or verify the active session with `codex mcp list` and XcodeBuildMCP `session_show_defaults` before treating the MCP context as loaded.

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
scripts/ambitions-codex-train.sh IOS26-T03-B01 prompts/batches/IOS26-T03-B01-runtime-kernel-contracts.md
scripts/ambitions-codex-train.sh IOS26-T03-B02 prompts/batches/IOS26-T03-B02-local-only-proof-harness.md
scripts/ambitions-codex-train.sh IOS26-T03-B03 prompts/batches/IOS26-T03-B03-replayable-decision-traces.md
scripts/ambitions-codex-train.sh IOS26-T04-B01 prompts/batches/IOS26-T04-B01-compiler-input-output-model.md
scripts/ambitions-codex-train.sh IOS26-T04-B02 prompts/batches/IOS26-T04-B02-capacity-aware-compilation.md
scripts/ambitions-codex-train.sh IOS26-T04-B03 prompts/batches/IOS26-T04-B03-compiler-persistence-receipts.md
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
The optional sequential script is installed at `scripts/ios26-flagship-run-sequential.sh`. It runs the exact sequence above through the Ambitions runner, stops on the first nonzero exit, writes logs under `build/reports/ios26-flagship-sequential/`, and does not auto-push, auto-release, sign, upload, or bypass the runner.
