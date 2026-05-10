# Direct Pro Control-Plane Upgrade Report

Status: Applied as direct repo patch  
Date: 2026-05-10  
Scope: control-plane docs and read-only enforcement only

## Summary

This pass installed direct, read-only Ambitions control-plane gates without using Codex and without touching production Swift/UI/schema/signing/workflow behavior.

The live repo state observed during this patch had already advanced beyond the earlier PK16 assumption:

```text
PK16 Trust History Query: Green
Next eligible batch: PK17 Today Read Model Extraction
```

The patch therefore protects the newer live state instead of reverting queue authority to stale PK16 assumptions.

## Files added

- `scripts/ambitions-queue-snapshot.py` — read-only active mirror / queue snapshot checker.
- `scripts/ambitions-source-atlas-title-check.py` — read-only Source Atlas manifest-title checker.
- `scripts/ambitions-final-report-gate.py` — read-only final-report structure and forbidden-claim gate.
- `scripts/ambitions-control-plane-check.py` — read-only aggregate control-plane gate.
- `scripts/ambitions-batch-scope-guard.py` — read-only batch prompt allowed/forbidden scope guard.
- `docs/codex/AMB_CONTROL_PLANE_DIRECT_RUNBOOK.md` — command runbook.
- `docs/codex/AMB_CONTROL_PLANE_GATE_INDEX.md` — gate ownership and acceptance index.
- `docs/audits/direct-pro-control-plane-upgrade-report.md` — this audit report.

## What these upgrades block

- advancing a batch while active mirrors disagree
- accepting generic Source Atlas titles where manifest titles exist
- accepting weak Green/Yellow final reports without required closeout sections
- accepting reports that smuggle release/readiness claims without non-claim framing
- accepting changed files outside a batch prompt's allowed scope
- accepting changed files inside a batch prompt's forbidden scope

## Recommended commands

```bash
python3 scripts/ambitions-control-plane-check.py
python3 scripts/ambitions-source-atlas-title-check.py --strict
python3 scripts/ambitions-final-report-gate.py docs/audits/<report>.md --strict
python3 scripts/ambitions-batch-scope-guard.py prompts/batches/<BATCH>.md --strict
```

## Validation not run

This direct patch was applied through GitHub writes from ChatGPT. I did not run local repo commands, XcodeGen, Xcode, unit tests, or Git diff validation in the repo environment.

Required local follow-up:

```bash
python3 -m json.tool docs/codex/AMB_REMAINING_BATCH_REFERENCE.json >/dev/null
python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/dev/null
python3 scripts/ambitions-control-plane-check.py
python3 scripts/ambitions-source-atlas-title-check.py --strict
git diff --check
```

## Known live-state correction

Earlier planning assumed PK16 was next. Live repo evidence during this patch showed:

- `.codex/state/active-batch.yml` records current batch as `PK16 Trust History Query` and next eligible as `PK17 Today Read Model Extraction`.
- `.codex/reports/current-run-state.md` records PK16 Green and PK17 next.
- `.codex/reports/current-batch-train-state.md` records PK16 Green and PK17 next.
- Existing remaining-batch references also record PK16 historical-complete / Green and PK17 executable.

Therefore this patch must not be interpreted as instruction to rerun PK16.

## Claims not made

This patch does not claim:

- PK17 is implemented
- any production Swift behavior changed
- app build success
- unit test success
- UI test success
- visual QA
- accessibility conformance
- performance validation
- privacy/legal approval
- release readiness
- TestFlight readiness
- App Store readiness
- physical-device proof
- sync/cloud readiness
- global train completion

## Next safe action

Run the aggregate gate locally. If it is Green, the next implementation batch remains:

```bash
make batch BATCH=PK17 PROMPT=prompts/batches/PK17.md
```

If the aggregate gate is Red, repair the specific control-plane defect before running PK17.
