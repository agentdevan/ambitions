# MRI00 Moat Runtime Gap Lock Report

Status: GitHub-side control-plane install complete. Local validation was not run in this chat.  
Date: 2026-05-12

## Objective

Install the Moat Runtime Integration control-plane overlay so future Ambitions batches are evaluated against end-to-end product loops instead of component completion alone.

## Files Installed

- `docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md`
- `docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md`
- `docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md`
- `docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md`
- `docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json`
- `scripts/ambitions-mri-materialize-prompts.py`
- `Makefile.mri`
- `prompts/batches/MRI00-MOAT-RUNTIME-GAP-LOCK.md`
- `docs/audits/mri00-moat-runtime-gap-lock-report.md`

## MRI Operating Systems Installed

1. Ambition Lifecycle Engine
2. Inspectable Intelligence Engine
3. Reality Fit Engine
4. Native Signature Interface
5. Assurance Lab

## Product Loops Covered

- Capture-to-meaning
- Source-to-recommendation
- Start Here daily execution
- Goal-to-life-direction
- Reality Fit / LifeShape
- Recovery and re-entry
- Personal Runtime trust/control
- Native Apple surfaces with receipts
- Visual runtime acceptance
- Final proof/release gates

## MRI01-MRI50 Prompt Materialization

MRI01-MRI50 are defined in:

```text
docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json
```

They are materialized with:

```bash
make -f Makefile.mri mri-materialize-prompts
```

Dry run:

```bash
make -f Makefile.mri mri-materialize-prompts-dry-run
```

The materializer writes runner-compatible prompt files under `prompts/batches/` using the required Ambitions runner header.

## Recommended Local Validation

```bash
git pull --ff-only
python3 -m json.tool docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json >/tmp/mri-batch-overlay-check.json
python3 -m py_compile scripts/ambitions-mri-materialize-prompts.py
python3 scripts/ambitions-mri-materialize-prompts.py --dry-run
make -f Makefile.mri mri-status
make -f Makefile.mri mri-materialize-prompts-dry-run
python3 scripts/ambitions-unsupported-claim-scan.py docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md docs/audits/mri00-moat-runtime-gap-lock-report.md
```

## Boundaries

This install is docs/control-plane/tooling only. It intentionally does not touch runtime app source, tests, package/project files, signing, entitlements, hosted backend, telemetry, analytics, or app runtime OpenAI integration.

## Claims Not Made

This report does not claim:

- MRI implementation complete
- app runtime changed
- visual runtime implemented
- release readiness
- TestFlight readiness
- App Store readiness
- signed archive readiness
- physical-device validation
- public accessibility conformance
- performance validation
- privacy/legal approval
- global train completion

## Next Recommended Action

Keep the active SA train moving. Use MRI00 as a control-plane overlay for future SA/AOS/LDI/FCP/PFC/visual/runtime work.

When ready to create the future MRI prompts locally, run:

```bash
make -f Makefile.mri mri-materialize-prompts
```

Do not run MRI01-MRI50 automatically until the active train strategy explicitly chooses the MRI lane.
