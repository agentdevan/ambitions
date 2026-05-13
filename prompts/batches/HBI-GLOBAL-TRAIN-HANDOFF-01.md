<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-GLOBAL-TRAIN-HANDOFF-01

## Batch ID

HBI-GLOBAL-TRAIN-HANDOFF-01

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-GLOBAL-TRAIN-HANDOFF-01 prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md
```

Equivalent:

```bash
make batch BATCH=HBI-GLOBAL-TRAIN-HANDOFF-01 PROMPT=prompts/batches/HBI-GLOBAL-TRAIN-HANDOFF-01.md
```

## Objective

Make the Historical Baseline train discoverable by the active global batch train without corrupting canonical queue order.

This is a handoff/governance batch. It does not implement app features and does not prove Historical Baseline runtime completion.

## Active source truth to inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`
- `scripts/ambitions-historical-baseline-train-guard.py`
- `prompts/batches/GLOBAL-TRAIN-AUTOPILOT-FROM-PK18-TO-COMPLETE-01.md`

## Allowed scope

- Verify the Historical Baseline overlay, manifest, train doc, guard, and batch prompts are installed.
- Run the Historical Baseline train guard.
- Update active train governance only if the change is bounded and does not corrupt canonical queue order.
- Report whether HBI is ready for Codex pickup after Source Atlas import/review foundations.

## Forbidden scope

- Do not implement Swift app features in this handoff batch.
- Do not skip SA17-SA25 if they are next in canonical queue order.
- Do not mutate completed batches.
- Do not collapse the HBI train into one mega-patch.
- Do not claim build, device, TestFlight, App Store, accessibility, privacy/legal, release, investor, or commercial readiness.

## Validation expectations

Run and record true exit codes:

```bash
python3 -m json.tool docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json >/tmp/ambitions-hbi-manifest-json-check.txt
python3 scripts/ambitions-historical-baseline-train-guard.py
python3 scripts/ambitions-queue-snapshot.py || true
python3 scripts/ambitions-control-plane-check.py || true
```

The queue/control-plane commands may expose unrelated existing state; report honestly rather than making false Green claims.

## Visual proof expectations

None. This batch is governance-only.

## Hard Red stop conditions

Stop if the HBI manifest is invalid, any required HBI runner prompt is missing, the guard fails, canonical queue order is corrupted, or the handoff would require implementation claims.

## Rollback expectations

Revert only HBI handoff/governance files if this handoff must be undone.

## Final report expectations

Create or update `docs/audits/historical-baseline-global-train-install-report.md` with installed files, guard output, queue relationship, claims not made, and next recommended runner command.

## Next eligible behavior

If active queue truth still says `SA17` is next, continue with `SA17` and apply the Historical Baseline overlay to SA17-SA25. After Source Atlas import/review foundations are complete, run the HBI/SCI/IRQ/PRI/RHE/PPL/LSF/MGP/RRE batch sequence from the manifest before making downstream source-aware personalization maturity claims.
