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

# Batch ID

MRI00-MOAT-RUNTIME-GAP-LOCK

# Runner Command

```bash
make batch BATCH=MRI00-MOAT-RUNTIME-GAP-LOCK PROMPT=prompts/batches/MRI00-MOAT-RUNTIME-GAP-LOCK.md
```

# Objective

Install the Moat Runtime Integration control-plane overlay for Ambitions.

This batch does not implement runtime app source. It installs authority docs, loop matrices, acceptance criteria, golden scenarios, machine-readable MRI01-MRI50 overlay data, a prompt materializer, and Makefile helpers so future Codex runs can generate and execute MRI prompts without manual copy/paste.

# Active Source Truth To Inspect

- docs/truth/README.md
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/truth/RELEASE_TRUTH.md
- docs/truth/CODEX_PROCESS_TRUTH.md
- docs/truth/HISTORICAL_POLICY.md
- AGENTS.md
- .codex/reports/current-run-state.md
- docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json
- docs/codex/VISUAL_CANON_MOAT_BATCH_TRAIN.md
- docs/codex/POST_PK_SPEED_TRAIN_OPERATING_MODEL.md
- docs/codex/POST_PK_PROOF_LIGHT_POLICY.md
- docs/codex/POST_PK_CLOSEOUT_CONTRACT.md

# Allowed Scope

- docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md
- docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md
- docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json
- docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md
- docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md
- docs/audits/mri00-moat-runtime-gap-lock-report.md
- scripts/ambitions-mri-materialize-prompts.py
- Makefile.mri
- prompts/batches/MRI00-MOAT-RUNTIME-GAP-LOCK.md

# Forbidden Scope

- No Native/Ambitions/** changes.
- No Native/AmbitionsTests/** changes.
- No Package.swift changes.
- No project.yml changes.
- No .github workflow changes.
- No signing, entitlement, release automation, hosted backend, analytics, telemetry, or app runtime OpenAI integration.
- No active SA state advancement or interruption.
- No runtime implementation claim.
- No visual runtime completion claim.
- No release/TestFlight/App Store/device/accessibility/performance/privacy/legal/global completion claim.

# Validation Expectations

```bash
git diff --check
python3 -m json.tool docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json >/tmp/mri-batch-overlay-check.json
python3 -m py_compile scripts/ambitions-mri-materialize-prompts.py
python3 scripts/ambitions-mri-materialize-prompts.py --dry-run
make -f Makefile.mri mri-status
make -f Makefile.mri mri-materialize-prompts-dry-run
python3 scripts/ambitions-unsupported-claim-scan.py docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md docs/audits/mri00-moat-runtime-gap-lock-report.md
```

No xcodegen or xcodebuild required. This is docs/control-plane/tooling only.

# Hard Red Conditions

- Any app runtime source is changed.
- Any active SA/PK queue state is altered without explicit scope.
- MRI is claimed implemented rather than installed as control-plane overlay.
- Runtime visual completion is claimed from docs/tooling only.
- Release/readiness/accessibility/device/performance/privacy/legal/global completion claims appear.
- Materializer does not create runner-compatible prompt headers.

# Rollback Expectations

Rollback only MRI00-created docs/prompts/scripts/Makefile.mri. Do not rollback active SA/PK/global train work.

# Final Report Requirements

Create or update:

```text
docs/audits/mri00-moat-runtime-gap-lock-report.md
```

Report must include:

- status
- files created
- validation commands
- MRI operating systems installed
- MRI prompt materialization path
- no-claim boundaries
- rollback notes
- next recommended action

# Claims Not Made

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
