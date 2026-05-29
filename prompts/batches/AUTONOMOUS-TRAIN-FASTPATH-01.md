<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AUTONOMOUS-TRAIN-FASTPATH-01

## Batch ID

AUTONOMOUS-TRAIN-FASTPATH-01

## Runner command

```bash
scripts/ambitions-codex-train.sh AUTONOMOUS-TRAIN-FASTPATH-01 prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md
```

Equivalent:

```bash
make batch BATCH=AUTONOMOUS-TRAIN-FASTPATH-01 PROMPT=prompts/batches/AUTONOMOUS-TRAIN-FASTPATH-01.md
```

## Objective

Install and verify the speed-layer runtime for the Install / Review / Advance Train / Push repeat loop so `make autonomous-train` and natural-language "run autonomous train" can use the full global train with HBI and MRI factored into applicable batches.

## Active source truth to inspect

- `prompts/batches/GLOBAL-TRAIN-AUTOPILOT-FROM-PK18-TO-COMPLETE-01.md`
- `docs/codex/AUTONOMOUS_TRAIN_FASTPATH.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`
- `docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md`
- `docs/codex/OBJECT_OS_MRI25_34_UPGRADE_OVERLAY.md`
- `.codex/skills/README.md`
- `Makefile`
- `Makefile.mri`

## Allowed scope

- Speed-layer scripts.
- Codex skills.
- Fastpath docs.
- Runner-compatible prompt.
- Existing autonomous-train entrypoint wiring.
- Install report.

## Forbidden scope

- App implementation.
- New tests or new test frameworks.
- New hosted services.
- New external dependencies.
- Queue rewrite.
- Release/device/App Store/TestFlight/accessibility/privacy/legal readiness claims.

## Validation expectations

Use existing checks only. Suggested commands:

```bash
python3 scripts/ambitions-autonomous-train-fastpath.py --status
python3 scripts/ambitions-autonomous-train-fastpath.py --next
python3 scripts/ambitions-autonomous-train-fastpath.py --once --dry-run --no-push
python3 scripts/ambitions-next-batch-router.py --dry-run --prefer-hbi
python3 scripts/ambitions-historical-baseline-train-guard.py
make -f Makefile.mri help || true
make prompt-audit
```

Record true exit codes. Do not invent Green if a command is not run.

## Visual proof expectations

None. This batch is tooling/governance only.

## Hard Red stop conditions

Stop if the fastpath bypasses the Ambitions runner, corrupts canonical queue order, stages unrelated files by default, introduces new test frameworks, introduces hosted dependencies, bypasses HBI/MRI overlays, or makes unproven readiness claims.

## Rollback expectations

Revert only fastpath scripts, skill docs, fastpath docs, prompt, entrypoint wiring, and install report unless a broader rollback is proven necessary.

## Final report expectations

Create `docs/audits/autonomous-train-fastpath-install-report.md` with installed files, commands run, exit codes, claims not made, and next recommended command.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
